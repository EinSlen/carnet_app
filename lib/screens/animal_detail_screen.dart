import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import 'animal_form_screen.dart';
import 'history_screen.dart';
import 'quick_log_screen.dart';
import 'treatment_form_screen.dart';

class AnimalDetailScreen extends ConsumerStatefulWidget {
  final int animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  ConsumerState<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends ConsumerState<AnimalDetailScreen> {
  int get _id => widget.animalId;

  void _refresh() => ref.invalidate(animalDetailProvider(_id));

  Future<void> _push(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) _refresh();
  }

  Future<void> _deleteTreatment(Treatment t) async {
    try {
      await ref.read(repositoryProvider).deleteTreatment(t.id!);
      await ref.read(notificationServiceProvider).cancelForTreatment(t.id!);
      if (mounted) _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Suppression impossible.')));
      }
    }
  }

  Future<void> _exportPdf(AnimalDetail d) async {
    final repo = ref.read(repositoryProvider);
    await PdfService.shareVetReport(
      animal: d.animal,
      treatments: await repo.getTreatments(_id),
      events: await repo.getLogEvents(_id),
      measures: await repo.getMeasures(_id),
    );
  }

  /// Prochaine heure de prise à venir (parmi tous les traitements).
  String? _nextReminder(List<Treatment> treatments) {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    int? best;
    String? bestName;
    for (final t in treatments) {
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

  @override
  Widget build(BuildContext context) {
    return ref.watch(animalDetailProvider(_id)).when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) =>
              Scaffold(appBar: AppBar(), body: ErrorView(onRetry: _refresh)),
          data: (d) => _content(context, d),
        );
  }

  Widget _content(BuildContext context, AnimalDetail d) {
    final a = d.animal;
    final sub = [
      a.species.label,
      if (a.breed.isNotEmpty) a.breed,
      if (a.ageYears != null) '${a.ageYears} ans',
    ].join(' · ');
    final nextReminder = _nextReminder(d.treatments);

    return Scaffold(
      appBar: AppBar(
        title: Text(a.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _push(AnimalFormScreen(animal: a)),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportPdf(d),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _push(QuickLogScreen(animal: a)),
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
                  value: d.lastWeight != null
                      ? '${d.lastWeight!.value}'
                      : (a.weight?.toString() ?? '—'),
                  label: 'kg'),
              const SizedBox(width: 8),
              _Kpi(value: '${d.treatments.length}', label: 'traitements'),
              const SizedBox(width: 8),
              _Kpi(value: '${d.recentEvents.length}', label: 'notes récentes'),
            ],
          ),
          const SizedBox(height: 8),
          if (nextReminder != null)
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
                      child: Text('Prochain rappel : $nextReminder',
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
                onPressed: () => _push(TreatmentFormScreen(animalId: _id)),
              ),
            ],
          ),
          if (d.treatments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  'Aucun traitement. Ajoute-en un pour créer des rappels.',
                  style: TextStyle(color: AppColors.muted)),
            ),
          ...d.treatments.map((t) => Card(
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
                onPressed: () => _push(HistoryScreen(animal: a)),
                child: const Text('Tout voir'),
              ),
            ],
          ),
          if (d.recentEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Rien de noté pour l\'instant.',
                  style: TextStyle(color: AppColors.muted)),
            ),
          ...d.recentEvents.map((e) => ListTile(
                dense: true,
                leading: Text(e.type.emoji),
                title: Text(e.label),
                subtitle: Text(DateFormat('dd/MM HH:mm').format(e.dateTime)),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
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
