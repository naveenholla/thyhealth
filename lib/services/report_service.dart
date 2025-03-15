import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../database/medical_repository.dart';

/// Service to handle medical report operations
class ReportService {
  final MedicalRepository _repository = MedicalRepository();
  
  /// Save a medical report from JSON data
  Future<int> saveReportFromJson(String jsonData, {String? originalFilePath}) async {
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
  }) async {
    try {
      return await _repository.saveMedicalReport(
        patientName: patientName,
        reportDate: reportDate,
        originalFilePath: originalFilePath,
        testResults: testResults,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get all patients
  Future<List<dynamic>> getAllPatients() async {
    return await _repository.getAllPatients();
  }
  
  /// Get all reports for a patient
  Future<List<dynamic>> getReportsByPatientId(int patientId) async {
    return await _repository.getReportsByPatientId(patientId);
  }
  
  /// Get a report with all its test results
  Future<Map<dynamic, List<dynamic>>> getReportWithTestResults(int reportId) async {
    return await _repository.getReportWithTestResults(reportId);
  }
  
  /// Close the database
  Future<void> closeDatabase() async {
    await _repository.closeDatabase();
  }
} 