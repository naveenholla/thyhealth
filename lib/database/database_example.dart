import 'package:flutter/material.dart';
import 'medical_repository.dart';
import 'database.dart';

/// Example widget to demonstrate how to use the MedicalRepository
class DatabaseExample extends StatefulWidget {
  const DatabaseExample({super.key});

  @override
  State<DatabaseExample> createState() => _DatabaseExampleState();
}

class _DatabaseExampleState extends State<DatabaseExample> {
  final MedicalRepository _repository = MedicalRepository();
  final Map<int, Stream<List<MedicalReport>>> _reportStreams = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Medical Reports'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Patient>>(
              stream: _repository.watchAllPatients().asBroadcastStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final patients = snapshot.data ?? [];
                
                if (patients.isEmpty) {
                  return const Center(child: Text('No patients found'));
                }
                
                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return ExpansionTile(
                      title: Text(patient.name),
                      subtitle: Text('Patient ID: ${patient.id}'),
                      children: [
                        _buildReportsList(patient.id),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleData,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildReportsList(int patientId) {
    // Get or create a broadcast stream for this patient
    _reportStreams[patientId] ??= _repository.watchReportsByPatientId(patientId).asBroadcastStream();
    
    return StreamBuilder<List<MedicalReport>>(
      stream: _reportStreams[patientId],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final reports = snapshot.data ?? [];
        
        if (reports.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No reports found for this patient'),
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return ListTile(
              title: Text('Report Date: ${report.reportDate}'),
              subtitle: Text('Uploaded: ${report.uploadedAt}'),
              onTap: () => _showReportDetails(report.id),
            );
          },
        );
      },
    );
  }
  
  void _showReportDetails(int reportId) async {
    final reportWithResults = await _repository.getReportWithTestResults(reportId);
    if (!mounted) return;
    
    if (reportWithResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data found for this report')),
      );
      return;
    }
    
    final report = reportWithResults.keys.first;
    final results = reportWithResults.values.first;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report from ${report.reportDate}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                title: Text(result.testName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Result: ${result.result}'),
                    if (result.referenceRange != null)
                      Text('Reference Range: ${result.referenceRange}'),
                    if (result.foodSuggestions != null)
                      Text('Food Suggestions: ${result.foodSuggestions}'),
                  ],
                ),
                tileColor: result.isAbnormal ? Colors.red.shade100 : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Add sample data for testing
  Future<void> _addSampleData() async {
    try {
      await _repository.saveMedicalReport(
        patientName: 'John Doe',
        reportDate: '2023-05-15',
        originalFilePath: null,
        testResults: [
          {
            'test': 'Hemoglobin',
            'result': '14.5 g/dL',
            'reference_range': '13.5-17.5 g/dL',
            'food_suggestions': 'ಕಬ್ಬಿಣಾಂಶ ಹೆಚ್ಚಿರುವ ಆಹಾರಗಳು: ಬೀಟ್‌ರೂಟ್, ಪಾಲಕ್, ಕಾಳುಮೆಣಸು',
          },
          {
            'test': 'Glucose',
            'result': '110 mg/dL',
            'reference_range': '70-99 mg/dL',
            'food_suggestions': 'ಸಕ್ಕರೆ ಕಡಿಮೆ ಇರುವ ಆಹಾರಗಳು: ಸೇಬು, ಬಾದಾಮಿ, ಕಡ್ಲೆಕಾಳು',
          },
          {
            'test': 'Cholesterol',
            'result': '220 mg/dL',
            'reference_range': '<200 mg/dL',
            'food_suggestions': 'ಕೊಬ್ಬು ಕಡಿಮೆ ಇರುವ ಆಹಾರಗಳು: ಮೀನು, ಓಟ್ಸ್, ಬೀನ್ಸ್',
          },
        ],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample data added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding sample data: $e')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _repository.closeDatabase();
    super.dispose();
  }
} 