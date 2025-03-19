import 'package:drift/drift.dart';
import 'database.dart';
import 'database_provider.dart';

/// Repository class to handle business logic for medical data
class MedicalRepository {
  final DatabaseProvider _provider = DatabaseProvider();

  /// Save a medical report with patient info and test results
  Future<int> saveMedicalReport({
    required String patientName,
    required String reportDate,
    String? originalFilePath,
    required List<Map<String, dynamic>> testResults,
    int? existingPatientId,
  }) async {
    final db = await _provider.database;
    
    // Start a transaction to ensure all operations succeed or fail together
    return db.transaction(() async {
      // Use existing patient ID if provided, otherwise look up or create new patient
      int patientId;
      if (existingPatientId != null) {
        patientId = existingPatientId;
      } else {
        final existingPatients = await (db.select(db.patients)
          ..where((p) => p.name.equals(patientName)))
          .get();
        
        if (existingPatients.isEmpty) {
          // Create new patient
          patientId = await db.addPatient(
            PatientsCompanion.insert(name: patientName),
          );
        } else {
          // Use existing patient
          patientId = existingPatients.first.id;
        }
      }
      
      // Create medical report
      final reportId = await db.addMedicalReport(
        MedicalReportsCompanion.insert(
          patientId: patientId,
          reportDate: reportDate,
          originalFilePath: Value(originalFilePath),
        ),
      );
      
      // Add test results
      for (final result in testResults) {
        await db.addTestResult(
          TestResultsCompanion.insert(
            reportId: reportId,
            testName: result['test'] as String,
            result: result['result'] as String,
            referenceRange: Value(result['reference_range'] as String?),
            foodSuggestions: Value(result['food_suggestions'] as String?),
            isAbnormal: Value(
              _isAbnormalResult(
                result['result'] as String,
                result['reference_range'] as String?,
              ),
            ),
          ),
        );
      }
      
      return reportId;
    });
  }

  /// Get all patients
  Future<List<Patient>> getAllPatients() async {
    final db = await _provider.database;
    return db.getAllPatients();
  }

  /// Get all reports for a patient
  Future<List<MedicalReport>> getReportsByPatientId(int patientId) async {
    final db = await _provider.database;
    return db.getReportsByPatientId(patientId);
  }

  /// Get a report with all its test results
  Future<Map<MedicalReport, List<TestResult>>> getReportWithTestResults(int reportId) async {
    final db = await _provider.database;
    return db.getReportWithTestResults(reportId);
  }

  /// Get all reports with their test results for a patient
  Future<Map<MedicalReport, List<TestResult>>> getAllReportsWithTestResultsForPatient(int patientId) async {
    final db = await _provider.database;
    return db.getAllReportsWithTestResultsForPatient(patientId);
  }

  /// Watch all patients (reactive)
  Stream<List<Patient>> watchAllPatients() async* {
    final db = await _provider.database;
    yield* db.watchAllPatients();
  }

  /// Watch reports for a patient (reactive)
  Stream<List<MedicalReport>> watchReportsByPatientId(int patientId) async* {
    final db = await _provider.database;
    yield* db.watchReportsByPatientId(patientId);
  }

  /// Watch test results for a report (reactive)
  Stream<List<TestResult>> watchTestResultsByReportId(int reportId) async* {
    final db = await _provider.database;
    yield* db.watchTestResultsByReportId(reportId);
  }

  /// Delete a patient and all their associated data
  Future<void> deletePatient(int patientId) async {
    final db = await _provider.database;
    await db.transaction(() async {
      // First delete all test results for all reports of this patient
      final reports = await db.getReportsByPatientId(patientId);
      for (final report in reports) {
        await db.deleteTestResultsForReport(report.id);
      }
      // Then delete all reports
      await db.deleteReportsForPatient(patientId);
      // Finally delete the patient
      await db.deletePatient(patientId);
    });
  }

  /// Delete a medical report and its test results
  Future<void> deleteMedicalReport(int reportId) async {
    final db = await _provider.database;
    await db.transaction(() async {
      // First delete all test results
      await db.deleteTestResultsForReport(reportId);
      // Then delete the report
      await db.deleteMedicalReport(reportId);
    });
  }

  /// Delete a specific test result
  Future<void> deleteTestResult(int testResultId) async {
    final db = await _provider.database;
    await db.deleteTestResult(testResultId);
  }

  /// Close the database
  Future<void> closeDatabase() async {
    await _provider.closeDatabase();
  }

  /// Update a patient's information
  Future<void> updatePatient(Patient patient) async {
    final db = await _provider.database;
    await db.transaction(() async {
      await (db.update(db.patients)..where((p) => p.id.equals(patient.id)))
          .write(PatientsCompanion(
        name: Value(patient.name),
        // Add other fields as needed
      ));
    });
  }

  /// Helper method to determine if a test result is abnormal
  bool _isAbnormalResult(String result, String? referenceRange) {
    if (referenceRange == null) return false;
    
    try {
      // Try to parse the result as a number
      final numericResult = double.tryParse(result.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (numericResult == null) return false;

      // Parse reference range
      // Expected format: "X-Y" or "< X" or "> Y"
      if (referenceRange.contains('-')) {
        final parts = referenceRange.split('-');
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim());
          final max = double.tryParse(parts[1].trim());
          if (min != null && max != null) {
            return numericResult < min || numericResult > max;
          }
        }
      } else if (referenceRange.contains('<')) {
        final max = double.tryParse(referenceRange.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (max != null) {
          return numericResult >= max;
        }
      } else if (referenceRange.contains('>')) {
        final min = double.tryParse(referenceRange.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (min != null) {
          return numericResult <= min;
        }
      }
    } catch (e) {
      // If any parsing fails, assume not abnormal
      return false;
    }

    return false;
  }
} 