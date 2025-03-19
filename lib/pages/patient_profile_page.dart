import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import '../services/report_service.dart';
import 'image_analyzer_page.dart';
import '../services/background_service.dart';
import 'notification_center.dart';
import '../database/database.dart';

class PatientProfilePage extends StatefulWidget {
  final Patient? patient;

  const PatientProfilePage({super.key, this.patient});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final ReportService _reportService = ReportService();
  final BackgroundService _backgroundService = BackgroundService();
  Map<dynamic, List<dynamic>>? _selectedReport;
  Future<List<dynamic>>? _reports;
  int _unreadNotifications = 0; // Fallback counter for notifications

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      print('PatientProfilePage: Patient loaded - ID: ${widget.patient!.id}, Name: ${widget.patient!.name}');
    } else {
      print('PatientProfilePage: No patient information available');
    }
    _loadReports();
    
    // Listen to notification updates
    _backgroundService.notificationStream.listen((notification) {
      setState(() {
        // BackgroundService.unreadNotificationsCount is non-nullable
        _unreadNotifications = _backgroundService.unreadNotificationsCount;
      });
    });
  }

  void _loadReports() {
    if (widget.patient != null && widget.patient!.id != null) {
      print('PatientProfilePage: Loading reports for patient ID: ${widget.patient!.id}');
      
      // Print debug information for all reports
      _reportService.debugPrintAllReports(widget.patient!.id!);
      
      setState(() {
        _reports = _reportService.getReportsForPatient(widget.patient!.id!);
      });
      
      // Debug: Check if reports are loaded successfully
      _reports?.then((reports) {
        print('PatientProfilePage: Loaded ${reports.length} reports for patient ${widget.patient!.name}');
        if (reports.isNotEmpty) {
          print('PatientProfilePage: First report ID: ${reports.first.id}, date: ${reports.first.reportDate}');
          
          // Debug: Print each report's details
          for (int i = 0; i < reports.length; i++) {
            final report = reports[i];
            print('PatientProfilePage: DEBUG - Report ${i+1}/${reports.length}:');
            print('  ID: ${report.id}');
            print('  Patient ID: ${report.patientId}');
            print('  Report Date: ${report.reportDate}');
            print('  Test Count: ${report.testResults.length}');
            
            // Print test results
            if (report.testResults.isNotEmpty) {
              print('  Test Results:');
              for (int j = 0; j < report.testResults.length; j++) {
                final test = report.testResults[j];
                print('    Test ${j+1}: ${test.testName} = ${test.result}');
              }
            } else {
              print('  No test results in this report');
            }
            
            // Print full report as JSON
            try {
              print('PatientProfilePage: DEBUG - Full report JSON: ${jsonEncode(report.toJson())}');
            } catch (e) {
              print('PatientProfilePage: Could not convert report to JSON: $e');
            }
          }
        }
      }).catchError((error) {
        print('PatientProfilePage: Error loading reports: $error');
      });
    } else {
      print('PatientProfilePage: Cannot load reports - no patient ID available');
    }
  }

  Widget _buildIOSContent() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.patient?.name ?? 'Patient'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Refresh button
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.arrow_clockwise),
              onPressed: () => _refreshData(),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(CupertinoIcons.bell),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: CupertinoColors.systemRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _unreadNotifications.toString(),
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const NotificationCenter()),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add),
              onPressed: () => _showIOSAddReportOptions(context),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: _buildReportsList(),
      ),
    );
  }

  Widget _buildMaterialContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient?.name ?? 'Patient'} Profile'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
          // Notification bell icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationCenter(),
                    ),
                  );
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildReportsList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Add Report button
          FloatingActionButton(
            heroTag: 'addReport',
            onPressed: _navigateToAnalyzer,
            tooltip: 'Add Report',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          // Edit Patient button
          FloatingActionButton(
            heroTag: 'editPatient',
            onPressed: _showEditDialog,
            tooltip: 'Edit Patient',
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return FutureBuilder<List<dynamic>>(
      future: _reports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          print('PatientProfilePage: Error loading reports: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: CupertinoColors.systemRed,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading reports',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Text('Retry'),
                  onPressed: () {
                    setState(() {
                      _loadReports();
                    });
                  },
                ),
              ],
            ),
          );
        }

        final reports = snapshot.data ?? [];
        
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.doc_text,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No reports found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a report to get started',
                  style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  child: const Text('Add Report'),
                  onPressed: () => _showIOSAddReportOptions(context),
                ),
              ],
            ),
          );
        }
        
        print('PatientProfilePage: Displaying ${reports.length} reports');
        
        return ListView.builder(
          itemCount: reports.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportTile(report);
          },
        );
      },
    );
  }

  Widget _buildReportTile(dynamic report) {
    print('PatientProfilePage: Building report tile for report ID: ${report.id}');
    // Debug report object
    print('PatientProfilePage: Report object type: ${report.runtimeType}');
    try {
      print('PatientProfilePage: Report JSON: ${jsonEncode(report.toJson())}');
    } catch (e) {
      print('PatientProfilePage: Could not convert report to JSON: $e');
    }
    
    return FutureBuilder<Map<dynamic, List<dynamic>>>(
      future: _reportService.getReportWithTestResults(report.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print('PatientProfilePage: No data for report ID: ${report.id}');
          return const SizedBox.shrink();
        }

        final reportWithResults = snapshot.data!;
        final testResults = reportWithResults.values.first;
        
        print('PatientProfilePage: Fetched ${testResults.length} test results for report ID: ${report.id}');
        
        // Debug: Print report with results
        final dbReport = reportWithResults.keys.first;
        print('PatientProfilePage: Report details - ID: ${dbReport.id}, Date: ${dbReport.reportDate}');
        
        // Debug: Print test results
        for (int i = 0; i < testResults.length; i++) {
          final test = testResults[i];
          print('PatientProfilePage: Test ${i+1}/${testResults.length}: ${test.testName} = ${test.result}');
        }

        // For macOS, use a different approach without swipe gestures
        if (Platform.isMacOS) {
          final bool isSelected = _selectedReport?.keys.first.id == report.id;
          
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CupertinoListTile(
                  title: Text('Report Date: ${report.reportDate}'),
                  subtitle: Text('${testResults.length} test results'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View details button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.eye,
                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                        ),
                        onPressed: () => _toggleReportDetails(reportWithResults),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.delete,
                          color: CupertinoColors.systemRed,
                        ),
                        onPressed: () => _confirmReportDelete(context, report),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Test Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Text(
                              'Delete Report',
                              style: TextStyle(
                                color: CupertinoColors.systemRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => _confirmReportDelete(context, report),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...testResults.map((result) {
                        final bool isAboveReference = _isAboveReference(result.result, result.referenceRange);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  result.testName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.result,
                                      style: TextStyle(
                                        fontWeight: isAboveReference ? FontWeight.bold : FontWeight.normal,
                                        color: isAboveReference ? CupertinoColors.systemRed : null,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (result.referenceRange != null && result.referenceRange.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Reference: ${result.referenceRange}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ],
          );
        }

        // For iOS and Android, use dismissible with swipe gestures
        return Dismissible(
          key: Key('report-${report.id}'),
          direction: DismissDirection.endToStart, // Only allow left swipe for delete
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Platform.isIOS ? CupertinoIcons.delete : Icons.delete,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delete (Requires Confirmation)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Left swipe - delete with confirmation
              return await _confirmReportDelete(context, report);
            }
            return false;
          },
          child: Platform.isIOS || Platform.isMacOS
              ? CupertinoListTile(
                  title: Text('Report Date: ${report.reportDate}'),
                  subtitle: Text('${testResults.length} test results'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.eye,
                          color: CupertinoColors.activeBlue,
                        ),
                        onPressed: () => _toggleReportDetails(reportWithResults),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.delete,
                          color: CupertinoColors.systemRed,
                        ),
                        onPressed: () => _confirmReportDelete(context, report),
                      ),
                    ],
                  ),
                )
              : ListTile(
                  title: Text('Report Date: ${report.reportDate}'),
                  subtitle: Text('${testResults.length} test results'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        color: Colors.blue,
                        onPressed: () => _toggleReportDetails(reportWithResults),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => _confirmReportDelete(context, report),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<bool> _confirmReportDelete(BuildContext context, dynamic report) async {
    if (Platform.isIOS || Platform.isMacOS) {
      return await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Delete Report'),
          content: const Text(
            'Are you sure you want to delete this report? All test results for this report will also be deleted. This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                try {
                  await _reportService.deleteMedicalReport(report.id);
                  if (_selectedReport?.keys.first.id == report.id) {
                    setState(() {
                      _selectedReport = null;
                    });
                  }
                  Navigator.of(context).pop(true);
                } catch (e) {
                  Navigator.of(context).pop(false);
                  _showErrorDialog(context, 'Delete Failed', e.toString());
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ?? false;
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Report'),
          content: const Text(
            'Are you sure you want to delete this report? All test results for this report will also be deleted. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _reportService.deleteMedicalReport(report.id);
                  if (_selectedReport?.keys.first.id == report.id) {
                    setState(() {
                      _selectedReport = null;
                    });
                  }
                  Navigator.of(context).pop(true);
                } catch (e) {
                  Navigator.of(context).pop(false);
                  _showErrorDialog(context, 'Delete Failed', e.toString());
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;
    }
  }

  Widget _buildTestResultsTable(List<dynamic> testResults) {
    if (Platform.isIOS || Platform.isMacOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: CupertinoColors.systemGrey5,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Test', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Result', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: testResults.length,
              itemBuilder: (context, index) {
                final result = testResults[index];
                final isAbnormal = result.isAbnormal ?? false;
                
                // For macOS, don't use Dismissible
                if (Platform.isMacOS) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isAbnormal ? CupertinoColors.systemYellow.withOpacity(0.2) : null,
                      border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              result.testName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.result,
                                  style: TextStyle(
                                    fontWeight: isAbnormal ? FontWeight.bold : FontWeight.normal,
                                    color: isAbnormal ? CupertinoColors.systemRed : null,
                                    fontSize: 15,
                                  ),
                                ),
                                if (result.referenceRange != null && result.referenceRange.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Reference: ${result.referenceRange}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.delete,
                              color: CupertinoColors.systemRed,
                              size: 20,
                            ),
                            onPressed: () => _confirmTestResultDelete(context, result),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Dismissible(
                  key: Key('test-result-${result.id}'),
                  direction: DismissDirection.endToStart, // Only allow left swipe for delete
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.delete,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _confirmTestResultDelete(context, result);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isAbnormal ? CupertinoColors.systemYellow.withOpacity(0.2) : null,
                      border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  result.testName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.result,
                                      style: TextStyle(
                                        fontWeight: isAbnormal ? FontWeight.bold : FontWeight.normal,
                                        color: isAbnormal ? CupertinoColors.systemRed : null,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (result.referenceRange != null && result.referenceRange.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Reference: ${result.referenceRange}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (result.foodSuggestions != null && result.foodSuggestions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Food Suggestions:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: CupertinoColors.activeGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  result.foodSuggestions,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Test')),
            DataColumn(label: Text('Result')),
            DataColumn(label: Text('Reference Range')),
            DataColumn(label: Text('Food Suggestions')),
            DataColumn(label: Text('Actions')),
          ],
          rows: testResults.map((result) {
            return DataRow(
              cells: [
                DataCell(Text(result.testName)),
                DataCell(Text(result.result)),
                DataCell(Text(result.referenceRange ?? '-')),
                DataCell(Text(result.foodSuggestions ?? '-')),
                DataCell(IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmTestResultDelete(context, result);
                  },
                )),
              ],
            );
          }).toList(),
        ),
      );
    }
  }

  Future<bool> _confirmTestResultDelete(BuildContext context, dynamic result) async {
    if (Platform.isIOS) {
      return await showCupertinoDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Delete Test Result'),
            content: const Text(
              'Are you sure you want to delete this test result? This action cannot be undone.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  try {
                    await _reportService.deleteTestResult(result.id);
                    // Refresh the selected report
                    if (_selectedReport != null) {
                      final updatedReport = await _reportService.getReportWithTestResults(_selectedReport!.keys.first.id);
                      setState(() {
                        _selectedReport = updatedReport;
                      });
                    }
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    Navigator.of(context).pop(false);
                    _showErrorDialog(context, 'Delete Failed', e.toString());
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      ) ?? false;
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Test Result'),
          content: const Text(
            'Are you sure you want to delete this test result? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _reportService.deleteTestResult(result.id);
                  // Refresh the selected report
                  if (_selectedReport != null) {
                    final updatedReport = await _reportService.getReportWithTestResults(_selectedReport!.keys.first.id);
                    setState(() {
                      _selectedReport = updatedReport;
                    });
                  }
                  Navigator.of(context).pop(true);
                } catch (e) {
                  Navigator.of(context).pop(false);
                  _showErrorDialog(context, 'Delete Failed', e.toString());
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;
    }
  }

  void _toggleReportDetails(Map<dynamic, List<dynamic>> report) {
    setState(() {
      if (_selectedReport?.keys.first.id == report.keys.first.id) {
        _selectedReport = null;
      } else {
        _selectedReport = report;
      }
    });
  }

  Future<void> _navigateToAnalyzer() async {
    if (widget.patient != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageAnalyzerPage(patient: widget.patient),
        ),
      );
    } else {
      // Show error dialog instead of using ScaffoldMessenger
      if (Platform.isIOS || Platform.isMacOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Patient information is required'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Patient information is required'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    if (Platform.isIOS || Platform.isMacOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: widget.patient?.name ?? '');
    
    if (Platform.isIOS || Platform.isMacOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Edit Patient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: nameController,
                placeholder: 'Name',
                padding: const EdgeInsets.all(10),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: const Text('Save'),
              onPressed: () {
                _savePatientChanges(nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Patient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _savePatientChanges(nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
  
  void _savePatientChanges(String name) {
    if (name.isEmpty) return;
    
    if (widget.patient != null && widget.patient!.id != null) {
      final updatedPatient = Patient(
        id: widget.patient!.id,
        name: name,
        createdAt: widget.patient!.createdAt,
      );
      
      _reportService.updatePatient(updatedPatient).then((_) {
        setState(() {
          _loadPatientData(updatedPatient.id!);
        });
      });
    }
  }

  void _loadPatientData(int patientId) async {
    // Reload the patient data
    final patient = await _reportService.getPatient(patientId);
    if (patient != null) {
      setState(() {
        // Update the UI with the refreshed patient data
        _reports = _reportService.getReportsForPatient(patientId);
      });
    }
  }

  void _showIOSAddReportOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add Medical Report'),
        message: const Text('Choose a method to add a medical report'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAnalyzer();
            },
            child: const Text('Upload from Camera/Files'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _createManualReport();
            },
            child: const Text('Create Report Manually'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }
  
  void _createManualReport() {
    // This functionality will be implemented later
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Manual report entry will be available in a future update.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Add this new method for refreshing data
  Future<void> _refreshData() async {
    if (widget.patient != null && widget.patient!.id != null) {
      setState(() {
        _reports = _reportService.getReportsForPatient(widget.patient!.id!);
      });
      
      // Also refresh patient data
      final refreshedPatient = await _reportService.getPatient(widget.patient!.id!);
      if (refreshedPatient != null) {
        // Instead of modifying the widget's patient field, we'll just refresh the reports
        // since the patient data is already up to date in the database
        setState(() {
          _reports = _reportService.getReportsForPatient(refreshedPatient.id!);
        });
      }
    }
  }

  // Add this helper method to check if a value is above reference range
  bool _isAboveReference(String result, String? referenceRange) {
    if (referenceRange == null || referenceRange.isEmpty) return false;
    
    try {
      // Extract numeric values from result and reference range
      final resultValue = double.tryParse(result.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (resultValue == null) return false;
      
      // Handle different reference range formats
      if (referenceRange.contains('-')) {
        // Range format (e.g., "70-100")
        final range = referenceRange.split('-');
        final min = double.tryParse(range[0].replaceAll(RegExp(r'[^0-9.]'), ''));
        final max = double.tryParse(range[1].replaceAll(RegExp(r'[^0-9.]'), ''));
        if (min != null && max != null) {
          return resultValue > max;
        }
      } else if (referenceRange.contains('<')) {
        // Less than format (e.g., "<100")
        final max = double.tryParse(referenceRange.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (max != null) {
          return resultValue > max;
        }
      } else if (referenceRange.contains('>')) {
        // Greater than format (e.g., ">100")
        final min = double.tryParse(referenceRange.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (min != null) {
          return resultValue > min;
        }
      }
      
      return false;
    } catch (e) {
      print('Error parsing reference range: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS || Platform.isMacOS ? _buildIOSContent() : _buildMaterialContent();
  }
}