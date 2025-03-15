import 'database.dart';

/// A singleton class to provide access to the database throughout the app
class DatabaseProvider {
  // Singleton instance
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  
  // Factory constructor to return the singleton instance
  factory DatabaseProvider() => _instance;
  
  // Private constructor
  DatabaseProvider._internal();
  
  // Database instance
  AppDatabase? _database;
  
  // Get the database instance, creating it if it doesn't exist
  Future<AppDatabase> get database async {
    if (_database != null) return _database!;
    
    _database = AppDatabase();
    return _database!;
  }
  
  // Close the database
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
} 