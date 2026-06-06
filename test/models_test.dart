import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_animal/data/models.dart';

void main() {
  test('Animal se sérialise et se désérialise sans perte', () {
    final a = Animal(
      name: 'Félix',
      species: 'chat',
      weight: 4.2,
      chronicConditions: 'Diabète',
    );
    final back = Animal.fromMap(a.toMap());
    expect(back.name, 'Félix');
    expect(back.species, 'chat');
    expect(back.weight, 4.2);
    expect(back.chronicConditions, 'Diabète');
  });

  test('emoji choisi selon l\'espèce', () {
    expect(Animal(name: 'x', species: 'chien').emoji, '🐶');
    expect(Animal(name: 'x', species: 'chat').emoji, '🐱');
    expect(Animal(name: 'x', species: 'lapin').emoji, '🐰');
    expect(Animal(name: 'x', species: 'autre').emoji, '🐾');
  });

  test('Treatment conserve ses horaires de prise', () {
    final t = Treatment(
      animalId: 1,
      name: 'Insuline',
      dosage: '2 UI',
      times: ['08:00', '20:00'],
    );
    final back = Treatment.fromMap(t.toMap());
    expect(back.name, 'Insuline');
    expect(back.dosage, '2 UI');
    expect(back.times, ['08:00', '20:00']);
  });

  test('Measure conserve sa valeur et son unité', () {
    final m = Measure(animalId: 1, type: 'poids', value: 4.2, unit: 'kg');
    final back = Measure.fromMap(m.toMap());
    expect(back.type, 'poids');
    expect(back.value, 4.2);
    expect(back.unit, 'kg');
  });
}
