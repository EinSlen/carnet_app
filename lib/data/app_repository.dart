import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Accès aux données locales (sqflite). Singleton simple, pas de codegen.
/// 100% local : rien ne quitte le téléphone (promesse du produit).
class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'carnet_animal.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE animals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, species TEXT, breed TEXT, sex TEXT,
        birth_date INTEGER, weight REAL, microchip TEXT,
        chronic_conditions TEXT, allergies TEXT, notes TEXT,
        photo_path TEXT, created_at INTEGER
      )''');
    await db.execute('''
      CREATE TABLE treatments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER NOT NULL, name TEXT NOT NULL, dosage TEXT,
        form TEXT, times TEXT, start_date INTEGER, end_date INTEGER,
        stock INTEGER, active INTEGER, notes TEXT, created_at INTEGER
      )''');
    await db.execute('''
      CREATE TABLE log_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER NOT NULL, treatment_id INTEGER, type TEXT,
        status TEXT, date_time INTEGER, description TEXT, severity INTEGER
      )''');
    await db.execute('''
      CREATE TABLE measures(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER NOT NULL, type TEXT, value REAL, unit TEXT,
        date_time INTEGER, note TEXT
      )''');
  }

  // ---- Animaux ----
  Future<List<Animal>> getAnimals() async {
    final db = await _database;
    final rows = await db.query('animals', orderBy: 'created_at DESC');
    return rows.map(Animal.fromMap).toList();
  }

  Future<Animal?> getAnimal(int id) async {
    final db = await _database;
    final rows =
        await db.query('animals', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Animal.fromMap(rows.first);
  }

  Future<int> insertAnimal(Animal a) async {
    final db = await _database;
    final map = a.toMap()..remove('id');
    return db.insert('animals', map);
  }

  Future<void> updateAnimal(Animal a) async {
    final db = await _database;
    await db.update('animals', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<void> deleteAnimal(int id) async {
    final db = await _database;
    await db.delete('animals', where: 'id = ?', whereArgs: [id]);
    await db.delete('treatments', where: 'animal_id = ?', whereArgs: [id]);
    await db.delete('log_events', where: 'animal_id = ?', whereArgs: [id]);
    await db.delete('measures', where: 'animal_id = ?', whereArgs: [id]);
  }

  // ---- Traitements ----
  Future<List<Treatment>> getTreatments(int animalId,
      {bool onlyActive = false}) async {
    final db = await _database;
    final rows = await db.query('treatments',
        where: onlyActive ? 'animal_id = ? AND active = 1' : 'animal_id = ?',
        whereArgs: [animalId],
        orderBy: 'created_at DESC');
    return rows.map(Treatment.fromMap).toList();
  }

  Future<int> insertTreatment(Treatment t) async {
    final db = await _database;
    final map = t.toMap()..remove('id');
    return db.insert('treatments', map);
  }

  Future<void> updateTreatment(Treatment t) async {
    final db = await _database;
    await db
        .update('treatments', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> deleteTreatment(int id) async {
    final db = await _database;
    await db.delete('treatments', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Journal ----
  Future<List<LogEvent>> getLogEvents(int animalId, {int? limit}) async {
    final db = await _database;
    final rows = await db.query('log_events',
        where: 'animal_id = ?',
        whereArgs: [animalId],
        orderBy: 'date_time DESC',
        limit: limit);
    return rows.map(LogEvent.fromMap).toList();
  }

  Future<int> insertLogEvent(LogEvent e) async {
    final db = await _database;
    final map = e.toMap()..remove('id');
    return db.insert('log_events', map);
  }

  // ---- Mesures ----
  Future<List<Measure>> getMeasures(int animalId, {String? type}) async {
    final db = await _database;
    final rows = await db.query('measures',
        where: type == null ? 'animal_id = ?' : 'animal_id = ? AND type = ?',
        whereArgs: type == null ? [animalId] : [animalId, type],
        orderBy: 'date_time ASC');
    return rows.map(Measure.fromMap).toList();
  }

  Future<int> insertMeasure(Measure m) async {
    final db = await _database;
    final map = m.toMap()..remove('id');
    return db.insert('measures', map);
  }
}
