import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../database/medical_repository.dart';
import '../database/database.dart';

/// Service to handle medical report operations
class ReportService {
  final MedicalRepository _repository = MedicalRepository();
  
  /// Save a medical report from JSON data
  Future<int> saveReportFromJson(String jsonData, {String? originalFilePath, int? patientId}) async {
    try {
      // Parse the JSON data
      final data = jsonDecode(jsonData);
      
      // Extract patient info
      final patientInfo = data['patient_info'];
      final patientName = patientInfo['name'] as String;
      final reportDate = patientInfo['date'] as String;
      
      // Extract test results
      final testResults = (data['test_results'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      
      // Save to database
      return await _repository.saveMedicalReport(
        patientName: patientName,
        reportDate: reportDate,
        originalFilePath: originalFilePath,
        testResults: testResults,
        existingPatientId: patientId,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Save a medical report from the analysis results
  Future<int> saveReport({
    required String patientName,
    required String reportDate,
    required List<Map<String, dynamic>> testResults,
    String? originalFilePath,
    int? existingPatientId,
  }) async {
    try {
      return await _repository.saveMedicalReport(
        patientName: patientName,
        reportDate: reportDate,
        originalFilePath: originalFilePath,
        testResults: testResults,
        existingPatientId: existingPatientId,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get all patients
  Future<List<Patient>> getAllPatients() async {
    return await _repository.getAllPatients();
  }
  
  /// Get all reports for a patient
  Future<List<dynamic>> getReportsForPatient(int patientId) async {
    return await _repository.getReportsByPatientId(patientId);
  }
  
  /// Get a report with all its test results
  Future<Map<dynamic, List<dynamic>>> getReportWithTestResults(int reportId) async {
    return await _repository.getReportWithTestResults(reportId);
  }
  
  /// Delete a patient and all their associated data
  Future<void> deletePatient(int patientId) async {
    await _repository.deletePatient(patientId);
  }

  /// Delete a medical report and its test results
  Future<void> deleteMedicalReport(int reportId) async {
    await _repository.deleteMedicalReport(reportId);
  }

  /// Delete a specific test result
  Future<void> deleteTestResult(int testResultId) async {
    await _repository.deleteTestResult(testResultId);
  }

  /// Close the database
  Future<void> closeDatabase() async {
    await _repository.closeDatabase();
  }

  /// Debug: Print all reports for a patient
  Future<void> debugPrintAllReports(int patientId) async {
    final reports = await getReportsForPatient(patientId);
    print('Debug: Found ${reports.length} reports for patient $patientId');
    for (var report in reports) {
      print('Report: $report');
    }
  }

  /// Get a patient by ID
  Future<Patient?> getPatient(int patientId) async {
    final patients = await getAllPatients();
    try {
      return patients.firstWhere((patient) => patient.id == patientId);
    } catch (e) {
      return null;
    }
  }

  /// Update a patient's information
  Future<void> updatePatient(Patient patient) async {
    await _repository.updatePatient(patient);
  }
} 