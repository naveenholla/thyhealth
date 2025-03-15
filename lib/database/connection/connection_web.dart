import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Creates a database connection for web platform
QueryExecutor connect() {
  // For web, we use IndexedDB
  return WebDatabase('thyhealth_db');
} 