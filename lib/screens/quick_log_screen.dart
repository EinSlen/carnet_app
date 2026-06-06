import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';

/// Le log en 1 tap : l'action quotidienne, instantanée (promesse coeur).
class QuickLogScreen extends StatefulWidget {
  final Animal animal;
  const QuickLogScreen({super.key, required this.animal});

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen> {
  final _repo = AppRepository.instance;
  bool _changed = false;

  int get _aid => widget.animal.id!;

  Future<void> _doseGiven() async {
    final treatments = await _repo.getTreatments(_aid, onlyActive: true);
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
    await _repo.insertLogEvent(LogEvent(
      animalId: _aid,
      treatmentId: chosen?.id,
      type: 'dose',
      status: 'donné',
      description: chosen?.name ?? '',
    ));
    _done('Dose enregistrée ✓');
  }

  Future<void> _addMeasure() async {
    String type = 'poids';
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Ajouter une mesure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'poids', child: Text('Poids (kg)')),
                  DropdownMenuItem(
                      value: 'glycemie', child: Text('Glycémie (g/L)')),
                ],
                onChanged: (v) => setLocal(() => type = v ?? 'poids'),
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
    await _repo.insertMeasure(Measure(
      animalId: _aid,
      type: type,
      value: value,
      unit: type == 'poids' ? 'kg' : 'g/L',
    ));
    _done('Mesure enregistrée ✓');
  }

  Future<void> _addText(String type, String title) async {
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
    await _repo.insertLogEvent(LogEvent(
      animalId: _aid,
      type: type,
      description: ctrl.text.trim(),
    ));
    _done('Noté ✓');
  }

  void _done(String msg) {
    _changed = true;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        appBar: AppBar(
          title: Text('Noter · ${widget.animal.name}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
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
                onTap: () => _addText('symptome', 'Noter un symptôme')),
            _ActionBtn(
                emoji: '📝',
                label: 'Note libre',
                onTap: () => _addText('note', 'Note libre')),
          ],
        ),
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
