import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_animal/data/models.dart';

void main() {
  test('Animal se sérialise et se désérialise sans perte', () {
    final a = Animal(
      name: 'Félix',
      species: Species.chat,
      weight: 4.2,
      chronicConditions: 'Diabète',
    );
    final back = Animal.fromMap(a.toMap());
    expect(back.name, 'Félix');
    expect(back.species, Species.chat);
    expect(back.weight, 4.2);
    expect(back.chronicConditions, 'Diabète');
  });

  test('emoji choisi selon l\'espèce', () {
    expect(Species.chien.emoji, '🐶');
    expect(Species.chat.emoji, '🐱');
    expect(Species.lapin.emoji, '🐰');
    expect(Species.fromName('inconnu'), Species.chat); // valeur par défaut
  });

  test('Treatment conserve ses horaires et sa forme', () {
    final t = Treatment(
      animalId: 1,
      name: 'Insuline',
      dosage: '2 UI',
      form: TreatmentForm.injection,
      times: ['08:00', '20:00'],
    );
    final back = Treatment.fromMap(t.toMap());
    expect(back.name, 'Insuline');
    expect(back.dosage, '2 UI');
    expect(back.form, TreatmentForm.injection);
    expect(back.times, ['08:00', '20:00']);
  });

  test('Measure dérive son unité du type', () {
    final m = Measure(animalId: 1, type: MeasureType.poids, value: 4.2);
    final back = Measure.fromMap(m.toMap());
    expect(back.type, MeasureType.poids);
    expect(back.value, 4.2);
    expect(back.unit, 'kg');
    expect(MeasureType.glycemie.unit, 'g/L');
  });

  test('LogEvent expose un libellé lisible', () {
    expect(LogEvent(animalId: 1, type: LogType.dose).label, 'Médicament donné');
    expect(
      LogEvent(animalId: 1, type: LogType.symptome, description: 'fatigue')
          .label,
      'Symptôme · fatigue',
    );
  });
}
