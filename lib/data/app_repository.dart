import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Erreur remontée par la couche de données (pour un affichage propre côté UI).
class RepositoryException implements Exception {
  final String message;
  final Object? cause;
  RepositoryException(this.message, [this.cause]);
  @override
  String toString() => 'RepositoryException: $message (${cause ?? ''})';
}

/// Accès aux données locales (sqflite). 100 % local : rien ne quitte le téléphone.
/// Injecté via Riverpod (voir providers.dart) — pas de singleton global.
class AppRepository {
  AppRepository();

  static const _dbVersion = 1;
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'carnet_animal.db');
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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

  /// Migrations de schéma entre versions. Exemple pour la suite :
  /// `if (oldVersion < 2) await db.execute('ALTER TABLE animals ADD COLUMN ...');`
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aucune migration pour l'instant (version 1).
  }

  /// Enveloppe toutes les opérations DB pour remonter une erreur claire à l'UI.
  Future<T> _guard<T>(String op, Future<T> Function(Database db) body) async {
    try {
      final db = await _database;
      return await body(db);
    } catch (e) {
      throw RepositoryException('Échec : $op', e);
    }
  }

  // ---- Animaux ----
  Future<List<Animal>> getAnimals() =>
      _guard('chargement des animaux', (db) async {
        final rows = await db.query('animals', orderBy: 'created_at DESC');
        return rows.map(Animal.fromMap).toList();
      });

  Future<Animal?> getAnimal(int id) =>
      _guard('chargement de l\'animal', (db) async {
        final rows = await db.query('animals',
            where: 'id = ?', whereArgs: [id], limit: 1);
        return rows.isEmpty ? null : Animal.fromMap(rows.first);
      });

  Future<int> insertAnimal(Animal a) => _guard('ajout de l\'animal', (db) {
        final map = a.toMap()..remove('id');
        return db.insert('animals', map);
      });

  Future<void> updateAnimal(Animal a) =>
      _guard('mise à jour de l\'animal', (db) async {
        await db
            .update('animals', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
      });

  Future<void> deleteAnimal(int id) =>
      _guard('suppression de l\'animal', (db) async {
        await db.delete('animals', where: 'id = ?', whereArgs: [id]);
        await db.delete('treatments', where: 'animal_id = ?', whereArgs: [id]);
        await db.delete('log_events', where: 'animal_id = ?', whereArgs: [id]);
        await db.delete('measures', where: 'animal_id = ?', whereArgs: [id]);
      });

  // ---- Traitements ----
  Future<List<Treatment>> getTreatments(int animalId,
          {bool onlyActive = false}) =>
      _guard('chargement des traitements', (db) async {
        final rows = await db.query('treatments',
            where:
                onlyActive ? 'animal_id = ? AND active = 1' : 'animal_id = ?',
            whereArgs: [animalId],
            orderBy: 'created_at DESC');
        return rows.map(Treatment.fromMap).toList();
      });

  /// Tous les traitements actifs (tous animaux) — utilisé pour replanifier
  /// les rappels au démarrage de l'app.
  Future<List<Treatment>> getAllActiveTreatments() =>
      _guard('chargement des traitements actifs', (db) async {
        final rows = await db.query('treatments', where: 'active = 1');
        return rows.map(Treatment.fromMap).toList();
      });

  Future<int> insertTreatment(Treatment t) =>
      _guard('ajout du traitement', (db) {
        final map = t.toMap()..remove('id');
        return db.insert('treatments', map);
      });

  Future<void> updateTreatment(Treatment t) =>
      _guard('mise à jour du traitement', (db) async {
        await db.update('treatments', t.toMap(),
            where: 'id = ?', whereArgs: [t.id]);
      });

  Future<void> deleteTreatment(int id) =>
      _guard('suppression du traitement', (db) async {
        await db.delete('treatments', where: 'id = ?', whereArgs: [id]);
      });

  // ---- Journal ----
  Future<List<LogEvent>> getLogEvents(int animalId, {int? limit}) =>
      _guard('chargement du journal', (db) async {
        final rows = await db.query('log_events',
            where: 'animal_id = ?',
            whereArgs: [animalId],
            orderBy: 'date_time DESC',
            limit: limit);
        return rows.map(LogEvent.fromMap).toList();
      });

  Future<int> insertLogEvent(LogEvent e) =>
      _guard('enregistrement de l\'entrée', (db) {
        final map = e.toMap()..remove('id');
        return db.insert('log_events', map);
      });

  // ---- Mesures ----
  Future<List<Measure>> getMeasures(int animalId, {MeasureType? type}) =>
      _guard('chargement des mesures', (db) async {
        final rows = await db.query('measures',
            where:
                type == null ? 'animal_id = ?' : 'animal_id = ? AND type = ?',
            whereArgs: type == null ? [animalId] : [animalId, type.name],
            orderBy: 'date_time ASC');
        return rows.map(Measure.fromMap).toList();
      });

  Future<int> insertMeasure(Measure m) =>
      _guard('enregistrement de la mesure', (db) {
        final map = m.toMap()..remove('id');
        return db.insert('measures', map);
      });
}
