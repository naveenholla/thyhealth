import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Report Analyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ImageAnalyzerPage(),
    );
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
  final TextEditingController _promptController = TextEditingController(
    text: 'Extract the following information from this medical report:\n1. Patient name\n2. Report date\n3. All test results\n\nadd food suggestions (in kannada) also for each of the test which will help to get in normal range\n\nReturn the data in this JSON format:\n{\n  "patient_info": {"name": "Patient Name", "date": "Report Date"},\n  "test_results": [{"test": "Test Name", "result": "Result Value", "reference_range": "Normal Range", "food_suggestions": "Food Suggestions"}]\n}',
  );

  @override
  void dispose() {
    _promptController.dispose();
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
        Content.text(_promptController.text),
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
        print('Raw response: $responseText'); // Debug print
        try {
          // Extract JSON from the response, handling markdown code blocks
          String jsonStr = responseText;
          
          // If the response contains markdown code blocks, extract the JSON from them
          if (responseText.contains('```')) {
            final codeBlockMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(responseText);
            if (codeBlockMatch != null && codeBlockMatch.group(1) != null) {
              jsonStr = codeBlockMatch.group(1)!.trim();
            }
          }
          
          print('Extracted JSON string: $jsonStr'); // Debug print

          dynamic parsedData = jsonDecode(jsonStr);
          print('Parsed JSON data: $parsedData'); // Debug print
          
          setState(() {
            if (parsedData is Map<String, dynamic>) {
              // New format with patient info
              _patientName = parsedData['patient_info']?['name']?.toString() ?? '';
              _reportDate = parsedData['patient_info']?['date']?.toString() ?? '';
              if (parsedData.containsKey('test_results')) {
                _results = List<Map<String, dynamic>>.from(parsedData['test_results'] ?? []);
              } else {
                // If no test_results key, treat the entire object as a single result
                _results = [Map<String, dynamic>.from(parsedData)];
              }
            } else if (parsedData is List) {
              // Old format (just an array of test results)
              _results = List<Map<String, dynamic>>.from(parsedData.map((item) => 
                item is Map ? Map<String, dynamic>.from(item) : {'value': item.toString()}
              ));
            } else {
              throw FormatException('Unexpected JSON format');
            }
            print('Set state with results: $_results'); // Debug print
            _isLoading = false;
          });
        } catch (e) {
          print('JSON parsing error: $e');
          print('Response text: $responseText');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Report Analyzer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Prompt',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _pickFiles,
                    child: const Text('Select Files'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _selectedFiles.isEmpty 
                        ? null 
                        : _processFiles,
                    child: Text(_isLoading ? 'Processing...' : 'Analyze Files'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedFiles.isNotEmpty) ...[
              Text(
                'Selected Files (${_selectedFiles.length}):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFiles.map((file) => Chip(
                  label: Text(file.name),
                  onDeleted: () {
                    setState(() {
                      _selectedFiles = _selectedFiles
                          .where((f) => f.name != file.name)
                          .toList();
                    });
                  },
                )).toList(),
              ),
            ],
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            // Debug text to show number of results
            Text('Number of results: ${_results.length}'),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_patientName.isNotEmpty || _reportDate.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_patientName.isNotEmpty)
                                  Text(
                                    'Patient: $_patientName',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (_reportDate.isNotEmpty)
                                  Text(
                                    'Date: $_reportDate',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                        Table(
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          columnWidths: _results.isNotEmpty
                            ? Map.fromIterables(
                                List.generate(_results.first.keys.length, (index) => index),
                                List.generate(_results.first.keys.length, (index) => const FlexColumnWidth(1)),
                              )
                            : const {},
                          children: [
                            if (_results.isNotEmpty) TableRow(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              children: _results.first.keys.map((header) => Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  header.toString().split('_').map((word) => 
                                    word[0].toUpperCase() + word.substring(1).toLowerCase()
                                  ).join(' '),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )).toList(),
                            ),
                            ..._results.map((result) => TableRow(
                              children: result.values.map((value) => Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  value?.toString() ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )).toList(),
                            )).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
