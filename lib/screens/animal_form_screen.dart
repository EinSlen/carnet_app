import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/providers.dart';

class AnimalFormScreen extends ConsumerStatefulWidget {
  final Animal? animal; // null = création
  const AnimalFormScreen({super.key, this.animal});

  @override
  ConsumerState<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends ConsumerState<AnimalFormScreen> {
  final _form = GlobalKey<FormState>();

  late final _name = TextEditingController(text: widget.animal?.name ?? '');
  late final _breed = TextEditingController(text: widget.animal?.breed ?? '');
  late final _weight =
      TextEditingController(text: widget.animal?.weight?.toString() ?? '');
  late final _microchip =
      TextEditingController(text: widget.animal?.microchip ?? '');
  late final _chronic =
      TextEditingController(text: widget.animal?.chronicConditions ?? '');
  late final _allergies =
      TextEditingController(text: widget.animal?.allergies ?? '');

  late Species _species = widget.animal?.species ?? Species.chat;
  late DateTime? _birth = widget.animal?.birthDate;
  bool _saving = false;

  bool get _isEdit => widget.animal != null;

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _weight.dispose();
    _microchip.dispose();
    _chronic.dispose();
    _allergies.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(DateTime.now().year - 5),
      firstDate: DateTime(1995),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final a = Animal(
      id: widget.animal?.id,
      name: _name.text.trim(),
      species: _species,
      breed: _breed.text.trim(),
      birthDate: _birth,
      weight: double.tryParse(_weight.text.replaceAll(',', '.')),
      microchip: _microchip.text.trim(),
      chronicConditions: _chronic.text.trim(),
      allergies: _allergies.text.trim(),
      createdAt: widget.animal?.createdAt,
    );
    try {
      final repo = ref.read(repositoryProvider);
      if (_isEdit) {
        await repo.updateAnimal(a);
      } else {
        await repo.insertAnimal(a);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enregistrement impossible.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(_isEdit ? 'Modifier l\'animal' : 'Nouvel animal')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nom *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indique un nom' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Species>(
              initialValue: _species,
              decoration: const InputDecoration(labelText: 'Espèce'),
              items: [
                for (final s in Species.values)
                  DropdownMenuItem(
                      value: s, child: Text('${s.emoji} ${s.label}')),
              ],
              onChanged: (v) => setState(() => _species = v ?? Species.chat),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _breed,
              decoration: const InputDecoration(labelText: 'Race'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickBirth,
              child: InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Date de naissance'),
                child: Text(_birth == null
                    ? 'Choisir une date'
                    : DateFormat('dd/MM/yyyy').format(_birth!)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Poids (kg)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _microchip,
              decoration: const InputDecoration(labelText: 'N° de puce'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _chronic,
              decoration: const InputDecoration(
                  labelText: 'Maladies chroniques',
                  hintText: 'Diabète, insuffisance rénale...'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _allergies,
              decoration: const InputDecoration(labelText: 'Allergies'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
