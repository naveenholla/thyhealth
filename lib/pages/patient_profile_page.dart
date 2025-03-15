import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../services/report_service.dart';
import 'image_analyzer_page.dart';

class PatientProfilePage extends StatefulWidget {
  final dynamic patient;

  const PatientProfilePage({super.key, required this.patient});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final ReportService _reportService = ReportService();
  Map<dynamic, List<dynamic>>? _selectedReport;

  Widget _buildIOSContent() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.patient.name),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _navigateToAnalyzer,
          child: const Icon(CupertinoIcons.add),
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
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAnalyzer,
          ),
        ],
      ),
      body: _buildReportsList(),
    );
  }

  Widget _buildReportsList() {
    return FutureBuilder<List<dynamic>>(
      future: _reportService.getReportsByPatientId(widget.patient.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final reports = snapshot.data ?? [];

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No medical reports found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                if (Platform.isIOS)
                  CupertinoButton.filled(
                    onPressed: _navigateToAnalyzer,
                    child: const Text('Upload Medical Report'),
                  )
                else
                  FilledButton.icon(
                    onPressed: _navigateToAnalyzer,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Medical Report'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportTile(report);
          },
        );
      },
    );
  }

  Widget _buildReportTile(dynamic report) {
    return FutureBuilder<Map<dynamic, List<dynamic>>>(
      future: _reportService.getReportWithTestResults(report.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final reportWithResults = snapshot.data!;
        final testResults = reportWithResults.values.first;

        if (Platform.isIOS) {
          return Column(
            children: [
              CupertinoListTile(
                title: Text('Report Date: ${report.reportDate}'),
                subtitle: Text('${testResults.length} test results'),
                trailing: const CupertinoListTileChevron(),
                onTap: () => _toggleReportDetails(reportWithResults),
              ),
              if (_selectedReport?.keys.first.id == report.id)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildTestResultsTable(testResults),
                ),
            ],
          );
        } else {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text('Report Date: ${report.reportDate}'),
              subtitle: Text('${testResults.length} test results'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildTestResultsTable(testResults),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildTestResultsTable(List<dynamic> testResults) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Test')),
          DataColumn(label: Text('Result')),
          DataColumn(label: Text('Reference Range')),
          DataColumn(label: Text('Food Suggestions')),
        ],
        rows: testResults.map((result) {
          return DataRow(
            cells: [
              DataCell(Text(result.testName)),
              DataCell(Text(result.result)),
              DataCell(Text(result.referenceRange ?? '-')),
              DataCell(Text(result.foodSuggestions ?? '-')),
            ],
          );
        }).toList(),
      ),
    );
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

  void _navigateToAnalyzer() {
    Navigator.push(
      context,
      Platform.isIOS
          ? CupertinoPageRoute(
              builder: (context) => const ImageAnalyzerPage(),
            )
          : MaterialPageRoute(
              builder: (context) => const ImageAnalyzerPage(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSContent() : _buildMaterialContent();
  }
} 