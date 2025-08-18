import 'package:projectconvert/modelflight/flight_model.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'flights.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE flights (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          airlineName TEXT,
          airlineCode TEXT,
          departureTime TEXT,
          arrivalTime TEXT,
          departureAirport TEXT,
          arrivalAirport TEXT,
          price TEXT
        )
      ''');
      },
    );
  }

  static Future<void> insertFlight(Flight flight) async {
    final db = await database;
    await db.insert(
      'flights',
      flight.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Flight>> getFlights() async {
    final db = await database;
    final maps = await db.query('flights');
    return maps.map((map) => Flight.fromMap(map)).toList();
  }
}
