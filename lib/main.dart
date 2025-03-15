import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'database/database_example.dart'; // Import the database example
import 'services/report_service.dart'; // Import the report service

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'Medical Report Analyzer',
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.systemBlue,
          brightness: Brightness.light,
        ),
        home: const ImageAnalyzerPage(),
      );
    } else {
      return MaterialApp(
        title: 'Medical Report Analyzer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const ImageAnalyzerPage(),
      );
    }
  }
}

class ImageAnalyzerPage extends StatefulWidget {
  const ImageAnalyzerPage({super.key});

  @override
  State<ImageAnalyzerPage> createState() => _ImageAnalyzerPageState();
}

class _ImageAnalyzerPageState extends State<ImageAnalyzerPage> {
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;
  String _error = '';
  List<Map<String, dynamic>> _results = [];
  String _patientName = '';
  String _reportDate = '';
  final ReportService _reportService = ReportService(); // Add report service
  final TextEditingController _apiKeyController = TextEditingController();
  int _selectedIndex = 0;
  bool _isExtended = true;
  final String _defaultPrompt = 'Extract the following information from this medical report:\n1. Patient name\n2. Report date\n3. All test results\n\nadd food suggestions (in kannada) also for each of the test which will help to get in normal range\n\nReturn the data in this JSON format:\n{\n  "patient_info": {"name": "Patient Name", "date": "Report Date"},\n  "test_results": [{"test": "Test Name", "result": "Result Value", "reference_range": "Normal Range", "food_suggestions": "Food Suggestions"}]\n}';

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _reportService.closeDatabase(); // Close the database when disposing
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
      });

      // Initialize Gemini API with your API key from .env file
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      );

      // Create content parts for each file
      final List<Content> contentParts = [
        Content.text(_defaultPrompt),
        ..._selectedFiles.map((file) {
          final mimeType = file.extension?.toLowerCase() == 'pdf' 
              ? 'application/pdf' 
              : 'image/${file.extension?.toLowerCase() ?? 'jpeg'}';
          return Content.data(mimeType, file.bytes!);
        }),
      ];

      final response = await model.generateContent(contentParts);
      final responseText = response.text;

      if (responseText != null) {
        try {
          String jsonStr = responseText;
          if (responseText.contains('```')) {
            final codeBlockMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(responseText);
            if (codeBlockMatch != null && codeBlockMatch.group(1) != null) {
              jsonStr = codeBlockMatch.group(1)!.trim();
            }
          }

          final parsedData = jsonDecode(jsonStr);
          setState(() {
            if (parsedData is Map<String, dynamic>) {
              _patientName = parsedData['patient_info']?['name']?.toString() ?? '';
              _reportDate = parsedData['patient_info']?['date']?.toString() ?? '';
              _results = List<Map<String, dynamic>>.from(parsedData['test_results'] ?? []);
            } else if (parsedData is List) {
              _results = List<Map<String, dynamic>>.from(parsedData);
            }
            _isLoading = false;
            
            if (_patientName.isNotEmpty && _reportDate.isNotEmpty && _results.isNotEmpty) {
              _saveReportToDatabase();
            }
          });
        } catch (e) {
          setState(() {
            _error = 'Could not parse JSON data from response: ${e.toString()}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error processing files: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Add a method to save the report to the database
  Future<void> _saveReportToDatabase() async {
    try {
      // Get the original file path if available
      String? originalFilePath = _selectedFiles.isNotEmpty ? _selectedFiles.first.path : null;
      
      // Save the report to the database
      final reportId = await _reportService.saveReport(
        patientName: _patientName,
        reportDate: _reportDate,
        testResults: _results,
        originalFilePath: originalFilePath,
      );
      
      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to database (ID: $reportId)'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DatabaseExample()),
                ).then((_) {
                  setState(() {
                    _selectedIndex = 0;
                  });
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving report: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildIOSContent(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;

    if (isSmallScreen) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar),
              label: 'Analysis',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const DatabaseExample()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            }
          },
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) {
              switch (index) {
                case 0:
                  return _buildIOSAnalysisPanel();
                case 1:
                  return const DatabaseExample();
                case 2:
                  return _buildIOSSettingsPanel();
                default:
                  return _buildIOSAnalysisPanel();
              }
            },
          );
        },
      );
    } else {
      // iPad layout with split view
      return CupertinoPageScaffold(
        child: Row(
          children: [
            Container(
              width: _isExtended ? 250 : 72,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50), // Safe area padding
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _isExtended = !_isExtended;
                      });
                    },
                    child: Icon(
                      _isExtended ? CupertinoIcons.sidebar_left : CupertinoIcons.sidebar_right,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  if (_isExtended && isLargeScreen)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Medical Report\nAnalyzer',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildIOSNavigationItem(
                          icon: CupertinoIcons.chart_bar,
                          label: 'Analysis',
                          index: 0,
                        ),
                        _buildIOSNavigationItem(
                          icon: CupertinoIcons.clock,
                          label: 'History',
                          index: 1,
                        ),
                        _buildIOSNavigationItem(
                          icon: CupertinoIcons.settings,
                          label: 'Settings',
                          index: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedIndex == 2
                  ? _buildIOSSettingsPanel()
                  : _buildIOSAnalysisPanel(),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildIOSNavigationItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return CupertinoButton(
      padding: EdgeInsets.symmetric(
        horizontal: _isExtended ? 16 : 8,
        vertical: 12,
      ),
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const DatabaseExample()),
          ).then((_) {
            setState(() {
              _selectedIndex = 0;
            });
          });
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.inactiveGray,
          ),
          if (_isExtended) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.inactiveGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIOSAnalysisPanel() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Analysis'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CupertinoButton.filled(
                      onPressed: _isLoading ? null : _pickFiles,
                      child: const Text('Select Files'),
                    ),
                    const SizedBox(width: 16),
                    CupertinoButton.filled(
                      onPressed: _isLoading || _selectedFiles.isEmpty
                          ? null
                          : _processFiles,
                      child: Text(_isLoading ? 'Processing...' : 'Analyze Files'),
                    ),
                  ],
                ),
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CupertinoColors.systemGrey5),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Files',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedFiles.map((file) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.doc,
                                  size: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  file.name,
                                  style: const TextStyle(
                                    color: CupertinoColors.label,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 0,
                                  onPressed: () {
                                    setState(() {
                                      _selectedFiles.removeWhere((f) => f.name == file.name);
                                    });
                                  },
                                  child: const Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    size: 16,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CupertinoColors.systemRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: CupertinoColors.systemRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: const TextStyle(
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  if (_patientName.isNotEmpty || _reportDate.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CupertinoColors.systemGrey5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (_patientName.isNotEmpty) ...[
                            const Text(
                              'Patient',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _patientName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (_reportDate.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Report Date',
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _reportDate,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CupertinoColors.systemGrey5),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - (isSmallScreen ? 48 : 298),
                        ),
                        child: CupertinoTableView(
                          results: _results,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add a new widget for iOS-style table view
  Widget CupertinoTableView({required List<Map<String, dynamic>> results}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.systemGrey5,
              ),
            ),
          ),
          child: Row(
            children: results.first.keys.map((header) {
              return Expanded(
                child: Text(
                  header.toString().split('_').map((word) =>
                    word[0].toUpperCase() + word.substring(1).toLowerCase()
                  ).join(' '),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Data rows
        ...results.map((result) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                ),
              ),
            ),
            child: Row(
              children: result.values.map((value) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      value?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildIOSSettingsPanel() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API Configuration',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _apiKeyController,
                placeholder: 'Google Gemini API Key',
                obscureText: true,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () {
                  dotenv.env['GEMINI_API_KEY'] = _apiKeyController.text;
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Success'),
                      content: const Text('API Key saved'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Save API Key'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIOSContent(context);
    } else {
      // Keep existing Material Design implementation
      final isSmallScreen = MediaQuery.of(context).size.width < 600;
      final isLargeScreen = MediaQuery.of(context).size.width >= 900;
      
      return Scaffold(
        body: Row(
          children: [
            // Side Panel
            if (!isSmallScreen)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isExtended ? 250 : 72,
                child: NavigationRail(
                  extended: _isExtended && !isSmallScreen,
                  minExtendedWidth: 250,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DatabaseExample()),
                      ).then((_) {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      });
                    }
                  },
                  leading: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: _isExtended ? 16 : 0,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _isExtended ? 250 : 72,
                          ),
                          child: Row(
                            mainAxisAlignment: _isExtended 
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isExtended) ...[
                                const Icon(Icons.medical_information, size: 32),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExtended = false;
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_left),
                                  tooltip: 'Collapse',
                                ),
                              ] else
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExtended = true;
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_right),
                                  tooltip: 'Expand',
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_isExtended && isLargeScreen)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Medical Report\nAnalyzer',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics),
                      label: Text('Analysis'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
              ),
            if (!isSmallScreen) 
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: VerticalDivider(thickness: 1, width: 1),
              ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  if (isSmallScreen)
                    NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DatabaseExample()),
                          ).then((_) {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          });
                        }
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.analytics),
                          label: 'Analysis',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.history),
                          label: 'History',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.settings),
                          label: 'Settings',
                        ),
                      ],
                    ),
                  Expanded(
                    child: _selectedIndex == 2
                        ? _buildSettingsPanel()
                        : _buildAnalysisPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSettingsPanel() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Configuration',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _apiKeyController,
                          decoration: const InputDecoration(
                            labelText: 'Google Gemini API Key',
                            border: OutlineInputBorder(),
                            helperText: 'Enter your API key from Google AI Studio',
                          ),
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            // Save API key to .env file
                            dotenv.env['GEMINI_API_KEY'] = _apiKeyController.text;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('API Key saved')),
                            );
                            // Dismiss keyboard
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save API Key'),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisPanel() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Analysis',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _pickFiles,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Select Files'),
                    ),
                    FilledButton.icon(
                      onPressed: _isLoading || _selectedFiles.isEmpty
                          ? null
                          : _processFiles,
                      icon: const Icon(Icons.analytics),
                      label: Text(_isLoading ? 'Processing...' : 'Analyze Files'),
                    ),
                  ],
                ),
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 24),
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
                ],
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  if (_patientName.isNotEmpty || _reportDate.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (_patientName.isNotEmpty)
                              ListTile(
                                title: Text(
                                  'Patient',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                subtitle: Text(
                                  _patientName,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            if (_reportDate.isNotEmpty)
                              ListTile(
                                title: Text(
                                  'Report Date',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                subtitle: Text(
                                  _reportDate,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - (isSmallScreen ? 48 : 298),
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primaryContainer,
                          ),
                          dataRowMinHeight: 64,
                          dataRowMaxHeight: 120,
                          columns: _results.first.keys.map((header) {
                            return DataColumn(
                              label: Expanded(
                                child: Text(
                                  header.toString().split('_').map((word) =>
                                    word[0].toUpperCase() + word.substring(1).toLowerCase()
                                  ).join(' '),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                          rows: _results.map((result) {
                            return DataRow(
                              cells: result.values.map((value) {
                                return DataCell(
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      value?.toString() ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
