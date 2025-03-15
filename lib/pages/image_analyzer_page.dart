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
  final String _defaultPrompt = 'Extract the following information from this medical report:\n1. Patient name\n2. Report date\n3. All test results\n\nadd food suggestions (in kannada) also for each of the test which will help to get in normal range\n\nReturn the data in this JSON format:\n{\n  "patient_info": {"name": "Patient Name", "date": "Report Date"},\n  "test_results": [{"test": "Test Name", "result": "Result Value", "reference_range": "Normal Range", "food_suggestions": "Food Suggestions"}]\n}';
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

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: true,
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
    }
  }

  Future<void> _processFiles() async {
    if (_selectedFiles.isEmpty) {
      setState(() {
        _error = 'Please select at least one file first';
      });
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
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      );

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
              file.bytes!
            ),
          ];

          final response = await model.generateContent(contentParts);
          final responseText = response.text;

          if (responseText != null) {
            String jsonStr = responseText;
            if (responseText.contains('```')) {
              final codeBlockMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(responseText);
              if (codeBlockMatch != null && codeBlockMatch.group(1) != null) {
                jsonStr = codeBlockMatch.group(1)!.trim();
              }
            }

            final parsedData = jsonDecode(jsonStr);
            if (parsedData is Map<String, dynamic>) {
              final patientName = widget.patient?.name ?? parsedData['patient_info']?['name']?.toString() ?? 'Unknown Patient';
              final reportDate = parsedData['patient_info']?['date']?.toString() ?? 'Unknown Date';
              
              if (!_patientReports.containsKey(patientName)) {
                _patientReports[patientName] = {
                  'dates': <String>{},
                  'results': <Map<String, dynamic>>[],
                };
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
          // Log error for this file but continue processing others
          print('Error processing file ${file.name}: $e');
        }
      }

      // Save reports
      await _saveReportsToDatabase();

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pop(context); // Return to previous screen after processing
      }
    } catch (e) {
      setState(() {
        _error = 'Error processing files: ${e.toString()}';
        _isLoading = false;
      });
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
            testResults: List<Map<String, dynamic>>.from(patientData['results']),
            originalFilePath: _selectedFiles.first.path,
            existingPatientId: widget.patient?.id,
          );
        }
      }
      
      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reports saved successfully')),
        );
      }
    } catch (e) {
      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reports: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildIOSContent() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.patient != null ? 'Add Report for ${widget.patient!.name}' : 'New Medical Report'),
      ),
      child: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildMaterialContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient != null ? 'Add Report for ${widget.patient!.name}' : 'New Medical Report'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (Platform.isIOS)
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _pickFiles,
              child: Text(_selectedFiles.isEmpty ? 'Select Files' : 'Change Files'),
            )
          else
            FilledButton.icon(
              onPressed: _isLoading ? null : _pickFiles,
              icon: const Icon(Icons.file_upload),
              label: Text(_selectedFiles.isEmpty ? 'Select Files' : 'Change Files'),
            ),
          const SizedBox(height: 16),
          if (_selectedFiles.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Files',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedFiles.map((file) => Chip(
                        avatar: const Icon(Icons.description, size: 16),
                        label: Text(file.name),
                        onDeleted: () {
                          setState(() {
                            _selectedFiles.removeWhere((f) => f.name == file.name);
                          });
                        },
                      )).toList(),
                    ),
                  ],
                ),
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
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSContent() : _buildMaterialContent();
  }
} 