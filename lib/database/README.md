# Drift Database Implementation for ThyHealth

This directory contains the implementation of a cross-platform local database using Drift for the ThyHealth app. Drift provides a unified API to interact with databases while handling platform-specific storage under the hood: it uses SQLite for mobile (Android, iOS) and desktop (Windows, macOS, Linux) platforms, and IndexedDB for the web.

## Directory Structure

- `tables.dart`: Defines the database tables (Patients, MedicalReports, TestResults)
- `database.dart`: Main database class with CRUD operations
- `database_provider.dart`: Singleton provider for database access
- `medical_repository.dart`: Repository class with business logic
- `database_example.dart`: Example widget to demonstrate database usage
- `connection/`: Platform-specific connection implementations
  - `connection.dart`: Exports the appropriate connection implementation
  - `connection_vm.dart`: Connection for mobile and desktop platforms
  - `connection_web.dart`: Connection for web platform

## How to Use

### 1. Initialize the Database

The database is automatically initialized when you first access it through the `DatabaseProvider`:

```dart
final dbProvider = DatabaseProvider();
final db = await dbProvider.database;
```

### 2. Save a Medical Report

Use the `MedicalRepository` to save a medical report:

```dart
final repository = MedicalRepository();
final reportId = await repository.saveMedicalReport(
  patientName: 'John Doe',
  reportDate: '2023-05-15',
  originalFilePath: '/path/to/file.pdf',
  testResults: [
    {
      'test': 'Hemoglobin',
      'result': '14.5 g/dL',
      'reference_range': '13.5-17.5 g/dL',
      'food_suggestions': 'Food suggestions here',
    },
    // More test results...
  ],
);
```

### 3. Query Data

Use the repository methods to query data:

```dart
// Get all patients
final patients = await repository.getAllPatients();

// Get reports for a patient
final reports = await repository.getReportsByPatientId(patientId);

// Get a report with its test results
final reportWithResults = await repository.getReportWithTestResults(reportId);
```

### 4. Reactive Streams

Drift supports reactive programming with streams:

```dart
// Watch all patients (updates UI when data changes)
StreamBuilder<List<Patient>>(
  stream: repository.watchAllPatients(),
  builder: (context, snapshot) {
    // Build UI based on snapshot
  },
)
```

### 5. Close the Database

Always close the database when you're done with it:

```dart
@override
void dispose() {
  repository.closeDatabase();
  super.dispose();
}
```

## Code Generation

After making changes to the database schema, run the following command to generate the necessary Dart code:

```
flutter pub run build_runner build
```

## Schema Migrations

When changing the database schema, increment the `schemaVersion` in `database.dart` and define a migration strategy:

```dart
@override
int get schemaVersion => 2; // Increment this when schema changes

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) {
    return m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      // Migration logic for version 1 to 2
    }
  },
);
``` 