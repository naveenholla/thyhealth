import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Creates a database connection for mobile and desktop platforms
QueryExecutor connect() {
  return LazyDatabase(() async {
    // Get a location for the database file
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'thyhealth.db'));
    
    // Make sure the directory exists
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    
    // Return a NativeDatabase, which uses the sqlite3 library
    return NativeDatabase(file);
  });
} 