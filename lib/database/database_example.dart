import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../services/report_service.dart';

/// Example widget to demonstrate how to use the MedicalRepository
class DatabaseExample extends StatefulWidget {
  const DatabaseExample({super.key});

  @override
  State<DatabaseExample> createState() => _DatabaseExampleState();
}

class _DatabaseExampleState extends State<DatabaseExample> {
  final ReportService _reportService = ReportService();
  int? _selectedPatientId;
  int? _selectedReportId;

  Future<void> _showDeleteConfirmation(BuildContext context, String title, String content, VoidCallback onConfirm) async {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPatientsList() {
    return FutureBuilder<List<dynamic>>(
      future: _reportService.getAllPatients(),
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
            return ListTile(
              title: Text(patient.name),
              subtitle: Text('Added: ${patient.createdAt.toString()}'),
              selected: _selectedPatientId == patient.id,
              onTap: () {
                setState(() {
                  _selectedPatientId = patient.id;
                  _selectedReportId = null;
                });
              },
              trailing: IconButton(
                icon: Icon(
                  Platform.isIOS ? CupertinoIcons.delete : Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  _showDeleteConfirmation(
                    context,
                    'Delete Patient',
                    'Are you sure you want to delete ${patient.name} and all their reports? This action cannot be undone.',
                    () async {
                      await _reportService.deletePatient(patient.id);
                      setState(() {
                        if (_selectedPatientId == patient.id) {
                          _selectedPatientId = null;
                          _selectedReportId = null;
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportsList() {
    if (_selectedPatientId == null) {
      return const Center(child: Text('Select a patient to view their reports'));
    }

    return FutureBuilder<List<dynamic>>(
      future: _reportService.getReportsByPatientId(_selectedPatientId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return const Center(child: Text('No reports found for this patient'));
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return ListTile(
              title: Text('Report Date: ${report.reportDate}'),
              subtitle: Text('Uploaded: ${report.uploadedAt.toString()}'),
              selected: _selectedReportId == report.id,
              onTap: () {
                setState(() {
                  _selectedReportId = report.id;
                });
              },
              trailing: IconButton(
                icon: Icon(
                  Platform.isIOS ? CupertinoIcons.delete : Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  _showDeleteConfirmation(
                    context,
                    'Delete Report',
                    'Are you sure you want to delete this report? This action cannot be undone.',
                    () async {
                      await _reportService.deleteMedicalReport(report.id);
                      setState(() {
                        if (_selectedReportId == report.id) {
                          _selectedReportId = null;
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTestResultsList() {
    if (_selectedReportId == null) {
      return const Center(child: Text('Select a report to view test results'));
    }

    return FutureBuilder<Map<dynamic, List<dynamic>>>(
      future: _reportService.getReportWithTestResults(_selectedReportId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return const Center(child: Text('No test results found for this report'));
        }

        final testResults = data.values.first;
        return ListView.builder(
          itemCount: testResults.length,
          itemBuilder: (context, index) {
            final result = testResults[index];
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
              trailing: IconButton(
                icon: Icon(
                  Platform.isIOS ? CupertinoIcons.delete : Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  _showDeleteConfirmation(
                    context,
                    'Delete Test Result',
                    'Are you sure you want to delete this test result? This action cannot be undone.',
                    () async {
                      await _reportService.deleteTestResult(result.id);
                      setState(() {}); // Refresh the view
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Medical Reports'),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Patients'),
                    ),
                    Expanded(child: _buildPatientsList()),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Reports'),
                    ),
                    Expanded(child: _buildReportsList()),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Test Results'),
                    ),
                    Expanded(child: _buildTestResultsList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medical Reports'),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Patients'),
                  ),
                  Expanded(child: _buildPatientsList()),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Reports'),
                  ),
                  Expanded(child: _buildReportsList()),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Test Results'),
                  ),
                  Expanded(child: _buildTestResultsList()),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
} 