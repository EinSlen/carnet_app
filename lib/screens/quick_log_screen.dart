import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../theme/app_theme.dart';

/// Le log en 1 tap : l'action quotidienne, instantanée (promesse coeur).
class QuickLogScreen extends ConsumerStatefulWidget {
  final Animal animal;
  const QuickLogScreen({super.key, required this.animal});

  @override
  ConsumerState<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends ConsumerState<QuickLogScreen> {
  int get _aid => widget.animal.id!;

  Future<void> _run(Future<void> Function() op, String okMessage) async {
    try {
      await op();
      if (mounted) _toast(okMessage);
    } catch (_) {
      if (mounted) _toast('Enregistrement impossible.');
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));

  Future<void> _doseGiven() async {
    final repo = ref.read(repositoryProvider);
    final treatments = await repo.getTreatments(_aid, onlyActive: true);
    if (!mounted) return;
    Treatment? chosen;
    if (treatments.isNotEmpty) {
      chosen = await showModalBottomSheet<Treatment>(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text('Quel médicament ?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              ...treatments.map((t) => ListTile(
                    leading: const Text('💊'),
                    title: Text(t.name),
                    subtitle: Text(t.dosage),
                    onTap: () => Navigator.pop(context, t),
                  )),
            ],
          ),
        ),
      );
      if (chosen == null) return;
    }
    await _run(
      () => repo.insertLogEvent(LogEvent(
        animalId: _aid,
        treatmentId: chosen?.id,
        type: LogType.dose,
        status: 'donné',
        description: chosen?.name ?? '',
      )),
      'Dose enregistrée ✓',
    );
  }

  Future<void> _addMeasure() async {
    var type = MeasureType.poids;
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Ajouter une mesure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<MeasureType>(
                initialValue: type,
                items: [
                  for (final t in MeasureType.values)
                    DropdownMenuItem(
                        value: t, child: Text('${t.label} (${t.unit})')),
                ],
                onChanged: (v) => setLocal(() => type = v ?? MeasureType.poids),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valeur'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ajouter')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final value = double.tryParse(ctrl.text.replaceAll(',', '.'));
    if (value == null) return;
    await _run(
      () => ref
          .read(repositoryProvider)
          .insertMeasure(Measure(animalId: _aid, type: type, value: value)),
      'Mesure enregistrée ✓',
    );
  }

  Future<void> _addText(LogType type, String title) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Décris en quelques mots'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(
      () => ref.read(repositoryProvider).insertLogEvent(
          LogEvent(animalId: _aid, type: type, description: ctrl.text.trim())),
      'Noté ✓',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Noter · ${widget.animal.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionBtn(
              emoji: '💊',
              label: 'Médicament donné',
              primary: true,
              onTap: _doseGiven),
          _ActionBtn(
              emoji: '🩸',
              label: 'Mesure (poids / glycémie)',
              onTap: _addMeasure),
          _ActionBtn(
              emoji: '⚠️',
              label: 'Symptôme',
              onTap: () => _addText(LogType.symptome, 'Noter un symptôme')),
          _ActionBtn(
              emoji: '📝',
              label: 'Note libre',
              onTap: () => _addText(LogType.note, 'Note libre')),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String emoji, label;
  final bool primary;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.emoji,
      required this.label,
      this.primary = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: primary ? AppColors.teal : Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: primary ? AppColors.teal : AppColors.line),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: primary ? Colors.white : AppColors.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
