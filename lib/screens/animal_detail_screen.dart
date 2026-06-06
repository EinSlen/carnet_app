import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_repository.dart';
import '../data/models.dart';
import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import 'animal_form_screen.dart';
import 'history_screen.dart';
import 'quick_log_screen.dart';
import 'treatment_form_screen.dart';

class AnimalDetailScreen extends StatefulWidget {
  final int animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final _repo = AppRepository.instance;

  Animal? _animal;
  List<Treatment> _treatments = [];
  List<LogEvent> _events = [];
  Measure? _lastWeight;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final animal = await _repo.getAnimal(widget.animalId);
    final treatments =
        await _repo.getTreatments(widget.animalId, onlyActive: true);
    final events = await _repo.getLogEvents(widget.animalId, limit: 5);
    final weights = await _repo.getMeasures(widget.animalId, type: 'poids');
    setState(() {
      _animal = animal;
      _treatments = treatments;
      _events = events;
      _lastWeight = weights.isEmpty ? null : weights.last;
      _loading = false;
    });
  }

  /// Prochaine heure de prise à venir (parmi tous les traitements).
  String? get _nextReminder {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    int? best;
    String? bestName;
    for (final t in _treatments) {
      for (final s in t.times) {
        final p = s.split(':');
        if (p.length != 2) continue;
        final m = (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
        final delta = m >= nowMin ? m - nowMin : m + 1440 - nowMin;
        if (best == null || delta < best) {
          best = delta;
          bestName = '${t.name} — $s';
        }
      }
    }
    return bestName;
  }

  Future<void> _exportPdf() async {
    final treatments = await _repo.getTreatments(widget.animalId);
    final events = await _repo.getLogEvents(widget.animalId);
    final measures = await _repo.getMeasures(widget.animalId);
    await PdfService.shareVetReport(
      animal: _animal!,
      treatments: treatments,
      events: events,
      measures: measures,
    );
  }

  Future<void> _deleteTreatment(Treatment t) async {
    await _repo.deleteTreatment(t.id!);
    await NotificationService.instance.cancelForTreatment(t.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _animal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final a = _animal!;
    final sub = [
      a.species,
      if (a.breed.isNotEmpty) a.breed,
      if (a.ageYears != null) '${a.ageYears} ans',
    ].join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: Text(a.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AnimalFormScreen(animal: a)));
              if (ok == true) _load();
            },
          ),
          IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: _exportPdf),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(context,
              MaterialPageRoute(builder: (_) => QuickLogScreen(animal: a)));
          if (ok == true) _load();
        },
        icon: const Icon(Icons.bolt),
        label: const Text('Noter'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.tealSoft,
                    child: Text(a.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(height: 6),
                  Text(a.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(sub, style: const TextStyle(color: AppColors.muted)),
                  if (a.chronicConditions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Chip(
                        backgroundColor: AppColors.coralSoft,
                        label: Text(a.chronicConditions),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _Kpi(
                  value: _lastWeight != null
                      ? '${_lastWeight!.value}'
                      : (a.weight?.toString() ?? '—'),
                  label: 'kg'),
              const SizedBox(width: 8),
              _Kpi(value: '${_treatments.length}', label: 'traitements'),
              const SizedBox(width: 8),
              _Kpi(value: '${_events.length}', label: 'notes récentes'),
            ],
          ),
          const SizedBox(height: 8),
          if (_nextReminder != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFAD5CF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('Prochain rappel : ${_nextReminder!}',
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Traitements actifs',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
                onPressed: () async {
                  final ok = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TreatmentFormScreen(animalId: a.id!)));
                  if (ok == true) _load();
                },
              ),
            ],
          ),
          if (_treatments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  'Aucun traitement. Ajoute-en un pour créer des rappels.',
                  style: TextStyle(color: AppColors.muted)),
            ),
          ..._treatments.map((t) => Card(
                child: ListTile(
                  leading: const Text('💊', style: TextStyle(fontSize: 22)),
                  title: Text(t.name),
                  subtitle: Text(
                      '${t.dosage}${t.dosage.isNotEmpty ? " · " : ""}${t.times.join(" / ")}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.muted),
                    onPressed: () => _deleteTreatment(t),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Journal récent',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HistoryScreen(animal: a)));
                  _load();
                },
                child: const Text('Tout voir'),
              ),
            ],
          ),
          if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Rien de noté pour l\'instant.',
                  style: TextStyle(color: AppColors.muted)),
            ),
          ..._events.map((e) => ListTile(
                dense: true,
                leading: Text(_eventEmoji(e.type)),
                title: Text(_eventLabel(e)),
                subtitle: Text(DateFormat('dd/MM HH:mm').format(e.dateTime)),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

String _eventEmoji(String type) => switch (type) {
      'dose' => '💊',
      'symptome' => '⚠️',
      'repas' => '🍽️',
      _ => '📝',
    };

String _eventLabel(LogEvent e) {
  final base = switch (e.type) {
    'dose' => 'Médicament donné',
    'symptome' => 'Symptôme',
    'repas' => 'Repas',
    _ => 'Note',
  };
  return e.description.isEmpty ? base : '$base · ${e.description}';
}

class _Kpi extends StatelessWidget {
  final String value, label;
  const _Kpi({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tealDark)),
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
        ),
      );
}
