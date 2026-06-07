import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import 'app_repository.dart';
import 'models.dart';

/// Injection de dépendances (Riverpod). Les instances réelles sont fournies
/// par des `overrides` dans main.dart (créées et initialisées une seule fois).
final repositoryProvider = Provider<AppRepository>(
  (ref) => throw UnimplementedError('repositoryProvider doit être overridé'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError(
      'notificationServiceProvider doit être overridé'),
);

/// Liste des animaux (rechargée automatiquement après invalidation).
final animalsProvider = FutureProvider.autoDispose<List<Animal>>(
  (ref) => ref.watch(repositoryProvider).getAnimals(),
);

/// Données agrégées d'une fiche animal.
class AnimalDetail {
  final Animal animal;
  final List<Treatment> treatments;
  final List<LogEvent> recentEvents;
  final Measure? lastWeight;
  const AnimalDetail({
    required this.animal,
    required this.treatments,
    required this.recentEvents,
    this.lastWeight,
  });
}

final animalDetailProvider =
    FutureProvider.autoDispose.family<AnimalDetail, int>((ref, id) async {
  final repo = ref.watch(repositoryProvider);
  final animal = await repo.getAnimal(id);
  if (animal == null) throw RepositoryException('Animal introuvable');
  final treatments = await repo.getTreatments(id, onlyActive: true);
  final events = await repo.getLogEvents(id, limit: 5);
  final weights = await repo.getMeasures(id, type: MeasureType.poids);
  return AnimalDetail(
    animal: animal,
    treatments: treatments,
    recentEvents: events,
    lastWeight: weights.isEmpty ? null : weights.last,
  );
});

/// Données de l'écran de suivi (courbes + journal complet).
class AnimalHistory {
  final List<Measure> weights;
  final List<Measure> glucose;
  final List<LogEvent> events;
  const AnimalHistory({
    required this.weights,
    required this.glucose,
    required this.events,
  });
}

final animalHistoryProvider =
    FutureProvider.autoDispose.family<AnimalHistory, int>((ref, id) async {
  final repo = ref.watch(repositoryProvider);
  return AnimalHistory(
    weights: await repo.getMeasures(id, type: MeasureType.poids),
    glucose: await repo.getMeasures(id, type: MeasureType.glycemie),
    events: await repo.getLogEvents(id),
  );
});
