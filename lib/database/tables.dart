import 'package:drift/drift.dart';

// Table for storing patient information
class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Table for storing medical reports
class MedicalReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get reportDate => text()();
  DateTimeColumn get uploadedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get originalFilePath => text().nullable()();
}

// Table for storing test results from medical reports
class TestResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reportId => integer().references(MedicalReports, #id)();
  TextColumn get testName => text()();
  TextColumn get result => text()();
  TextColumn get referenceRange => text().nullable()();
  TextColumn get foodSuggestions => text().nullable()();
  BoolColumn get isAbnormal => boolean().withDefault(const Constant(false))();
} 