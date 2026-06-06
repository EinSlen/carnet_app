import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_repository.dart';
import '../data/models.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal; // null = création
  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _form = GlobalKey<FormState>();
  final _repo = AppRepository.instance;

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

  late String _species = widget.animal?.species ?? 'chat';
  late DateTime? _birth = widget.animal?.birthDate;

  bool get _isEdit => widget.animal != null;

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
    if (!_form.currentState!.validate()) return;
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
    if (_isEdit) {
      await _repo.updateAnimal(a);
    } else {
      await _repo.insertAnimal(a);
    }
    if (mounted) Navigator.pop(context, true);
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
            DropdownButtonFormField<String>(
              initialValue: _species,
              decoration: const InputDecoration(labelText: 'Espèce'),
              items: const [
                DropdownMenuItem(value: 'chat', child: Text('🐱 Chat')),
                DropdownMenuItem(value: 'chien', child: Text('🐶 Chien')),
                DropdownMenuItem(value: 'lapin', child: Text('🐰 Lapin')),
                DropdownMenuItem(value: 'rongeur', child: Text('🐹 Rongeur')),
                DropdownMenuItem(value: 'oiseau', child: Text('🐦 Oiseau')),
                DropdownMenuItem(value: 'reptile', child: Text('🦎 Reptile')),
                DropdownMenuItem(value: 'cheval', child: Text('🐴 Cheval')),
                DropdownMenuItem(value: 'autre', child: Text('🐾 Autre')),
              ],
              onChanged: (v) => setState(() => _species = v ?? 'chat'),
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
            FilledButton(onPressed: _save, child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}
