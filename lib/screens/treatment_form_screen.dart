import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../data/models.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class TreatmentFormScreen extends StatefulWidget {
  final int animalId;
  const TreatmentFormScreen({super.key, required this.animalId});

  @override
  State<TreatmentFormScreen> createState() => _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends State<TreatmentFormScreen> {
  final _form = GlobalKey<FormState>();
  final _repo = AppRepository.instance;

  final _name = TextEditingController();
  final _dosage = TextEditingController();
  String _formType = 'comprimé';
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _addTime() async {
    final t = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
    if (t != null) setState(() => _times.add(t));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final treatment = Treatment(
      animalId: widget.animalId,
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      form: _formType,
      times: _times.map(_fmt).toList(),
    );
    final id = await _repo.insertTreatment(treatment);
    // Planifie les rappels fiables pour chaque créneau.
    final saved = Treatment(
      id: id,
      animalId: treatment.animalId,
      name: treatment.name,
      dosage: treatment.dosage,
      form: treatment.form,
      times: treatment.times,
      startDate: treatment.startDate,
    );
    await NotificationService.instance.scheduleForTreatment(saved);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau traitement')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Médicament *', hintText: 'Insuline, AINS...'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Indique le médicament'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dosage,
              decoration: const InputDecoration(
                  labelText: 'Dose', hintText: '2 UI, 1 comprimé...'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _formType,
              decoration: const InputDecoration(labelText: 'Forme'),
              items: const [
                DropdownMenuItem(value: 'comprimé', child: Text('Comprimé')),
                DropdownMenuItem(value: 'liquide', child: Text('Liquide')),
                DropdownMenuItem(value: 'injection', child: Text('Injection')),
                DropdownMenuItem(value: 'pommade', child: Text('Pommade')),
              ],
              onChanged: (v) => setState(() => _formType = v ?? 'comprimé'),
            ),
            const SizedBox(height: 20),
            Text('Heures de prise (rappels)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _times.length; i++)
                  Chip(
                    backgroundColor: AppColors.tealSoft,
                    label: Text(_fmt(_times[i])),
                    onDeleted: _times.length > 1
                        ? () => setState(() => _times.removeAt(i))
                        : null,
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  onPressed: _addTime,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7EF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC5E9D2)),
              ),
              child: Text(
                  '✓ ${_times.length} rappel(s) seront créés et se répèteront chaque jour.',
                  style: const TextStyle(color: Color(0xFF1F7A45))),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}
