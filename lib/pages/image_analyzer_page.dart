import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/report_service.dart';

class ImageAnalyzerPage extends StatefulWidget {
  final dynamic patient;

  const ImageAnalyzerPage({super.key, this.patient});

  @override
  State<ImageAnalyzerPage> createState() => _ImageAnalyzerPageState();
}

class _ImageAnalyzerPageState extends State<ImageAnalyzerPage> {
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;
  String _error = '';
  List<Map<String, dynamic>> _results = [];
  final ReportService _reportService = ReportService();
  final TextEditingController _apiKeyController = TextEditingController();
  final String _defaultPrompt =
      'Extract the following information from this medical report:\n1. Patient name\n2. Report date\n3. All test results\n\nadd food suggestions (in kannada) also for each of the test which will help to get in normal range\n\nReturn the data in this JSON format:\n{\n  "patient_info": {"name": "Patient Name", "date": "Report Date"},\n  "test_results": [{"test": "Test Name", "result": "Result Value", "reference_range": "Normal Range", "food_suggestions": "Food Suggestions"}]\n}';
  Map<String, Map<String, dynamic>> _patientReports = {};

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showSuccess(String message) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Success'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to previous screen
                  },
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context); // Return to previous screen
    }
  }

  void _showDeleteConfirmation(PlatformFile file) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Delete File'),
              content: Text('Are you sure you want to delete ${file.name}?'),
              actions: [
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    setState(() {
                      _selectedFiles.removeWhere((f) => f.name == file.name);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      // Existing Material delete functionality remains unchanged
      setState(() {
        _selectedFiles.removeWhere((f) => f.name == file.name);
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: true,
        allowCompression: true,
        onFileLoading: (FilePickerStatus status) {
          if (status == FilePickerStatus.done) {
            Future.delayed(const Duration(milliseconds: 500));
          }
        },
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
          _error = '';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking files: ${e.toString()}';
      });
      _showError(_error);
    }
  }

  Future<void> _processFiles() async {
    if (_selectedFiles.isEmpty) {
      setState(() {
        _error = 'Please select at least one file first';
      });
      _showError(_error);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = '';
        _results = [];
        _patientReports = {};
      });

      // Initialize Gemini API with your API key from .env file
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key not found. Please add it in Settings.');
      }

      final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);

      // Process each file individually
      for (final file in _selectedFiles) {
        try {
          // Create content parts for the current file
          final List<Content> contentParts = [
            Content.text(_defaultPrompt),
            Content.data(
              file.extension?.toLowerCase() == 'pdf'
                  ? 'application/pdf'
                  : 'image/${file.extension?.toLowerCase() ?? 'jpeg'}',
              file.bytes!,
            ),
          ];

          final response = await model.generateContent(contentParts);
          final responseText = response.text;

          if (responseText != null) {
            String jsonStr = responseText;
            if (responseText.contains('```')) {
              final codeBlockMatch = RegExp(
                r'```(?:json)?\s*([\s\S]*?)\s*```',
              ).firstMatch(responseText);
              if (codeBlockMatch != null && codeBlockMatch.group(1) != null) {
                jsonStr = codeBlockMatch.group(1)!.trim();
              }
            }

            final parsedData = jsonDecode(jsonStr);
            if (parsedData is Map<String, dynamic>) {
              final rawPatientName =
                  widget.patient?.name ??
                  parsedData['patient_info']?['name']?.toString() ??
                  'Unknown Patient';
              final patientName = _normalizePatientName(rawPatientName);
              final reportDate =
                  parsedData['patient_info']?['date']?.toString() ??
                  'Unknown Date';

              if (!_patientReports.containsKey(patientName)) {
                _patientReports[patientName] = {
                  'dates': <String>{},
                  'results': <Map<String, dynamic>>[],
                  'original_names': <String>{rawPatientName},
                };
              } else {
                _patientReports[patientName]!['original_names'].add(
                  rawPatientName,
                );
              }

              _patientReports[patientName]!['dates'].add(reportDate);

              // Add test results to the patient's results list
              if (parsedData['test_results'] != null) {
                final List<Map<String, dynamic>> fileResults =
                    List<Map<String, dynamic>>.from(parsedData['test_results']);
                _patientReports[patientName]!['results'].addAll(fileResults);
              }
            }
          }
        } catch (e) {
          print('Error processing file ${file.name}: $e');
          _showError('Error processing file ${file.name}. Please try again.');
        }
      }

      // Save reports
      await _saveReportsToDatabase();

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showSuccess('Reports processed and saved successfully');
      }
    } catch (e) {
      setState(() {
        _error = 'Error processing files: ${e.toString()}';
        _isLoading = false;
      });
      _showError(_error);
    }
  }

  Future<void> _saveReportsToDatabase() async {
    try {
      for (final patientName in _patientReports.keys) {
        final patientData = _patientReports[patientName]!;
        final reportDates = (patientData['dates'] as Set<String>).toList();

        // Save report for each date
        for (final reportDate in reportDates) {
          await _reportService.saveReport(
            patientName: patientName,
            reportDate: reportDate,
            testResults: List<Map<String, dynamic>>.from(
              patientData['results'],
            ),
            originalFilePath: _selectedFiles.first.path,
            existingPatientId: widget.patient?.id,
          );
        }
      }
    } catch (e) {
      throw Exception('Error saving reports: ${e.toString()}');
    }
  }

  Widget _buildIOSContent() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.patient != null
              ? 'Add Report for ${widget.patient!.name}'
              : 'New Medical Report',
        ),
      ),
      child: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildMaterialContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patient != null
              ? 'Add Report for ${widget.patient!.name}'
              : 'New Medical Report',
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (Platform.isIOS)
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _pickFiles,
                child: Text(
                  _selectedFiles.isEmpty ? 'Select Files' : 'Change Files',
                ),
              )
            else
              FilledButton.icon(
                onPressed: _isLoading ? null : _pickFiles,
                icon: const Icon(Icons.file_upload),
                label: Text(
                  _selectedFiles.isEmpty ? 'Select Files' : 'Change Files',
                ),
              ),
            const SizedBox(height: 16),
            if (_selectedFiles.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color:
                      Platform.isIOS
                          ? CupertinoColors.systemBackground
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Platform.isIOS
                            ? CupertinoColors.systemGrey4
                            : Theme.of(context).dividerColor,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Files',
                      style:
                          Platform.isIOS
                              ? const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              )
                              : Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _selectedFiles.map((file) {
                            if (Platform.isIOS) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Dismissible(
                                  key: Key(file.name),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.destructiveRed,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    child: const Icon(
                                      CupertinoIcons.delete,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    bool delete = false;
                                    await showCupertinoDialog(
                                      context: context,
                                      builder:
                                          (context) => CupertinoAlertDialog(
                                            title: const Text('Delete File'),
                                            content: Text(
                                              'Are you sure you want to delete ${file.name}?',
                                            ),
                                            actions: [
                                              CupertinoDialogAction(
                                                isDestructiveAction: true,
                                                onPressed: () {
                                                  delete = true;
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              CupertinoDialogAction(
                                                child: const Text('Cancel'),
                                                onPressed: () {
                                                  delete = false;
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                    );
                                    return delete;
                                  },
                                  onDismissed: (direction) {
                                    setState(() {
                                      _selectedFiles.removeWhere(
                                        (f) => f.name == file.name,
                                      );
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemGrey6,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.doc,
                                            size: 20,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              file.name,
                                              style: const TextStyle(
                                                color: CupertinoColors.label,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            CupertinoIcons.right_chevron,
                                            size: 16,
                                            color: CupertinoColors.systemGrey3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Chip(
                                avatar: const Icon(Icons.description, size: 16),
                                label: Text(file.name),
                                onDeleted: () {
                                  setState(() {
                                    _selectedFiles.removeWhere(
                                      (f) => f.name == file.name,
                                    );
                                  });
                                },
                              );
                            }
                          }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (Platform.isIOS)
                CupertinoButton.filled(
                  onPressed: _isLoading ? null : _processFiles,
                  child: Text(_isLoading ? 'Processing...' : 'Analyze Files'),
                )
              else
                FilledButton.icon(
                  onPressed: _isLoading ? null : _processFiles,
                  icon: const Icon(Icons.analytics),
                  label: Text(_isLoading ? 'Processing...' : 'Analyze Files'),
                ),
            ],
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Platform.isIOS
                            ? CupertinoColors.systemRed.withOpacity(0.1)
                            : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Platform.isIOS
                              ? CupertinoColors.systemRed.withOpacity(0.3)
                              : Theme.of(
                                context,
                              ).colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Platform.isIOS
                            ? CupertinoIcons.exclamationmark_triangle
                            : Icons.error_outline,
                        color:
                            Platform.isIOS
                                ? CupertinoColors.systemRed
                                : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error,
                          style: TextStyle(
                            color:
                                Platform.isIOS
                                    ? CupertinoColors.systemRed
                                    : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child:
                      Platform.isIOS
                          ? const CupertinoActivityIndicator()
                          : const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSContent() : _buildMaterialContent();
  }

  String _normalizePatientName(String name) {
    return name
        .replaceAll(RegExp(r'^Mr\.\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^Mrs\.\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Widget _buildResultsForPatient(
    String patientName,
    Map<String, dynamic> patientData,
  ) {
    final dates = (patientData['dates'] as Set<String>).toList()..sort();
    final originalNames =
        (patientData['original_names'] as Set<String>).toList()..sort();
    final displayName =
        originalNames.length > 1
            ? '$patientName (also known as: ${originalNames.where((n) => n != patientName).join(", ")})'
            : patientName;

    if (Platform.isIOS) {
      return Dismissible(
        key: Key(patientName),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.destructiveRed,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(
            CupertinoIcons.delete,
            color: CupertinoColors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          bool delete = false;
          await showCupertinoDialog(
            context: context,
            builder:
                (context) => CupertinoAlertDialog(
                  title: const Text('Delete Patient'),
                  content: Text(
                    'Are you sure you want to delete all reports for $displayName?',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () {
                        delete = true;
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        delete = false;
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
          );
          return delete;
        },
        onDismissed: (direction) {
          setState(() {
            _patientReports.remove(patientName);
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CupertinoColors.systemGrey5),
          ),
          child: CupertinoListTile(
            title: Text(displayName),
            subtitle: Text('${dates.length} reports'),
            trailing: const CupertinoListTileChevron(),
            onTap: () => _showDatesForPatient(displayName, patientData),
          ),
        ),
      );
    } else {
      // Existing Material implementation
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Patient',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                subtitle: Text(
                  patientName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                title: Text(
                  'Report Dates',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                subtitle: Text(
                  dates.join(', '),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:
                    patientData['results'].isEmpty
                        ? const Text('No test results found')
                        : DataTable(
                          columns:
                              patientData['results'].first.keys.map<DataColumn>(
                                (key) {
                                  return DataColumn(
                                    label: Text(
                                      key
                                          .toString()
                                          .split('_')
                                          .map(
                                            (word) =>
                                                word[0].toUpperCase() +
                                                word.substring(1).toLowerCase(),
                                          )
                                          .join(' '),
                                    ),
                                  );
                                },
                              ).toList(),
                          rows:
                              patientData['results'].map<DataRow>((result) {
                                return DataRow(
                                  cells:
                                      result.values.map<DataCell>((value) {
                                        return DataCell(
                                          Text(value?.toString() ?? ''),
                                        );
                                      }).toList(),
                                );
                              }).toList(),
                        ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showDatesForPatient(
    String patientName,
    Map<String, dynamic> patientData,
  ) {
    final dates = (patientData['dates'] as Set<String>).toList()..sort();

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder:
            (context) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Reports for $patientName'),
              ),
              child: SafeArea(
                child: ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    return Dismissible(
                      key: Key('$patientName-$date'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.destructiveRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          CupertinoIcons.delete,
                          color: CupertinoColors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        bool delete = false;
                        await showCupertinoDialog(
                          context: context,
                          builder:
                              (context) => CupertinoAlertDialog(
                                title: const Text('Delete Report'),
                                content: Text(
                                  'Are you sure you want to delete the report from $date?',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      delete = true;
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      delete = false;
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                        );
                        return delete;
                      },
                      onDismissed: (direction) {
                        setState(() {
                          _patientReports[patientName]!['dates'].remove(date);
                          if ((_patientReports[patientName]!['dates']
                                  as Set<String>)
                              .isEmpty) {
                            _patientReports.remove(patientName);
                            Navigator.pop(
                              context,
                            ); // Return to patient list if no more dates
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: CupertinoColors.systemGrey5,
                          ),
                        ),
                        child: CupertinoListTile(
                          title: Text(date),
                          trailing: const CupertinoListTileChevron(),
                          onTap:
                              () => _showReportDetails(
                                patientName,
                                date,
                                patientData['results'],
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      ),
    );
  }

  void _showReportDetails(
    String patientName,
    String date,
    List<dynamic> results,
  ) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder:
            (context) => CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(
                middle: Text('Report Details'),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Report Date: $date',
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...results
                            .map(
                              (result) => Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemBackground,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: CupertinoColors.systemGrey5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result['test'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Result: ${result['result'] ?? ''}'),
                                    Text(
                                      'Reference Range: ${result['reference_range'] ?? ''}',
                                    ),
                                    if (result['food_suggestions'] != null) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Food Suggestions:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(result['food_suggestions']),
                                    ],
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
