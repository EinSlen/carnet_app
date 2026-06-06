// Modèles de données du MVP (voir Spec-app-animaux.pdf §7).
// Stockés en local via sqflite. Les dates sont des millisecondsSinceEpoch.

int? _dt(DateTime? d) => d?.millisecondsSinceEpoch;
DateTime? _fromDt(Object? v) =>
    v == null ? null : DateTime.fromMillisecondsSinceEpoch(v as int);

class Animal {
  final int? id;
  final String name;
  final String species; // 'chien' | 'chat'
  final String breed;
  final String sex; // 'M' | 'F' | 'M stérilisé' | 'F stérilisée'
  final DateTime? birthDate;
  final double? weight;
  final String microchip;
  final String chronicConditions;
  final String allergies;
  final String notes;
  final String? photoPath;
  final DateTime createdAt;

  Animal({
    this.id,
    required this.name,
    this.species = 'chat',
    this.breed = '',
    this.sex = '',
    this.birthDate,
    this.weight,
    this.microchip = '',
    this.chronicConditions = '',
    this.allergies = '',
    this.notes = '',
    this.photoPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get emoji => switch (species) {
        'chien' => '🐶',
        'chat' => '🐱',
        'lapin' => '🐰',
        'rongeur' => '🐹',
        'oiseau' => '🐦',
        'reptile' => '🦎',
        'cheval' => '🐴',
        _ => '🐾',
      };

  int? get ageYears => birthDate == null
      ? null
      : ((DateTime.now().difference(birthDate!).inDays) / 365).floor();

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'species': species,
        'breed': breed,
        'sex': sex,
        'birth_date': _dt(birthDate),
        'weight': weight,
        'microchip': microchip,
        'chronic_conditions': chronicConditions,
        'allergies': allergies,
        'notes': notes,
        'photo_path': photoPath,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Animal.fromMap(Map<String, Object?> m) => Animal(
        id: m['id'] as int?,
        name: m['name'] as String? ?? '',
        species: m['species'] as String? ?? 'chat',
        breed: m['breed'] as String? ?? '',
        sex: m['sex'] as String? ?? '',
        birthDate: _fromDt(m['birth_date']),
        weight: (m['weight'] as num?)?.toDouble(),
        microchip: m['microchip'] as String? ?? '',
        chronicConditions: m['chronic_conditions'] as String? ?? '',
        allergies: m['allergies'] as String? ?? '',
        notes: m['notes'] as String? ?? '',
        photoPath: m['photo_path'] as String?,
        createdAt: _fromDt(m['created_at']) ?? DateTime.now(),
      );

  Animal copyWith({int? id}) => Animal(
        id: id ?? this.id,
        name: name,
        species: species,
        breed: breed,
        sex: sex,
        birthDate: birthDate,
        weight: weight,
        microchip: microchip,
        chronicConditions: chronicConditions,
        allergies: allergies,
        notes: notes,
        photoPath: photoPath,
        createdAt: createdAt,
      );
}

class Treatment {
  final int? id;
  final int animalId;
  final String name;
  final String dosage;
  final String form; // comprimé | liquide | injection | pommade
  final List<String> times; // ['08:00','20:00']
  final DateTime startDate;
  final DateTime? endDate;
  final int? stock;
  final bool active;
  final String notes;
  final DateTime createdAt;

  Treatment({
    this.id,
    required this.animalId,
    required this.name,
    this.dosage = '',
    this.form = 'comprimé',
    this.times = const [],
    DateTime? startDate,
    this.endDate,
    this.stock,
    this.active = true,
    this.notes = '',
    DateTime? createdAt,
  })  : startDate = startDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, Object?> toMap() => {
        'id': id,
        'animal_id': animalId,
        'name': name,
        'dosage': dosage,
        'form': form,
        'times': times.join(','),
        'start_date': startDate.millisecondsSinceEpoch,
        'end_date': _dt(endDate),
        'stock': stock,
        'active': active ? 1 : 0,
        'notes': notes,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Treatment.fromMap(Map<String, Object?> m) => Treatment(
        id: m['id'] as int?,
        animalId: m['animal_id'] as int,
        name: m['name'] as String? ?? '',
        dosage: m['dosage'] as String? ?? '',
        form: m['form'] as String? ?? 'comprimé',
        times: ((m['times'] as String?) ?? '')
            .split(',')
            .where((s) => s.trim().isNotEmpty)
            .toList(),
        startDate: _fromDt(m['start_date']) ?? DateTime.now(),
        endDate: _fromDt(m['end_date']),
        stock: m['stock'] as int?,
        active: (m['active'] as int? ?? 1) == 1,
        notes: m['notes'] as String? ?? '',
        createdAt: _fromDt(m['created_at']) ?? DateTime.now(),
      );
}

class LogEvent {
  final int? id;
  final int animalId;
  final int? treatmentId;
  final String type; // dose | symptome | repas | note
  final String? status; // pour dose : 'donné'
  final DateTime dateTime;
  final String description;
  final int? severity; // symptôme 1-5

  LogEvent({
    this.id,
    required this.animalId,
    this.treatmentId,
    required this.type,
    this.status,
    DateTime? dateTime,
    this.description = '',
    this.severity,
  }) : dateTime = dateTime ?? DateTime.now();

  Map<String, Object?> toMap() => {
        'id': id,
        'animal_id': animalId,
        'treatment_id': treatmentId,
        'type': type,
        'status': status,
        'date_time': dateTime.millisecondsSinceEpoch,
        'description': description,
        'severity': severity,
      };

  factory LogEvent.fromMap(Map<String, Object?> m) => LogEvent(
        id: m['id'] as int?,
        animalId: m['animal_id'] as int,
        treatmentId: m['treatment_id'] as int?,
        type: m['type'] as String? ?? 'note',
        status: m['status'] as String?,
        dateTime: _fromDt(m['date_time']) ?? DateTime.now(),
        description: m['description'] as String? ?? '',
        severity: m['severity'] as int?,
      );
}

class Measure {
  final int? id;
  final int animalId;
  final String type; // poids | glycemie
  final double value;
  final String unit; // kg | g/L
  final DateTime dateTime;
  final String note;

  Measure({
    this.id,
    required this.animalId,
    required this.type,
    required this.value,
    this.unit = '',
    DateTime? dateTime,
    this.note = '',
  }) : dateTime = dateTime ?? DateTime.now();

  Map<String, Object?> toMap() => {
        'id': id,
        'animal_id': animalId,
        'type': type,
        'value': value,
        'unit': unit,
        'date_time': dateTime.millisecondsSinceEpoch,
        'note': note,
      };

  factory Measure.fromMap(Map<String, Object?> m) => Measure(
        id: m['id'] as int?,
        animalId: m['animal_id'] as int,
        type: m['type'] as String? ?? 'poids',
        value: (m['value'] as num?)?.toDouble() ?? 0,
        unit: m['unit'] as String? ?? '',
        dateTime: _fromDt(m['date_time']) ?? DateTime.now(),
        note: m['note'] as String? ?? '',
      );
}
