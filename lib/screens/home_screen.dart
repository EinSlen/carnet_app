import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import 'animal_detail_screen.dart';
import 'animal_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Demande les permissions de notification au démarrage.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).requestPermissions();
    });
  }

  Future<void> _addAnimal() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AnimalFormScreen()));
    if (mounted) ref.invalidate(animalsProvider);
  }

  Future<void> _openAnimal(Animal a) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => AnimalDetailScreen(animalId: a.id!)));
    if (mounted) ref.invalidate(animalsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final animals = ref.watch(animalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes animaux')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnimal,
        child: const Icon(Icons.add),
      ),
      body: animals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ErrorView(onRetry: () => ref.invalidate(animalsProvider)),
        data: (list) => list.isEmpty
            ? _EmptyState(onAdd: _addAnimal)
            : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: list.length,
                itemBuilder: (context, i) => _AnimalCard(
                  animal: list[i],
                  onTap: () => _openAnimal(list[i]),
                ),
              ),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  const _AnimalCard({required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sub = [
      animal.species.label,
      if (animal.ageYears != null) '${animal.ageYears} ans',
      if (animal.weight != null) '${animal.weight} kg',
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.tealSoft,
                child: Text(animal.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(animal.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(sub,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    if (animal.chronicConditions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _Chip(animal.chronicConditions,
                            bg: AppColors.coralSoft,
                            fg: const Color(0xFFC0492A)),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const _Chip(this.text, {required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐾', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('Aucun animal pour l\'instant',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'Ajoute ton premier compagnon pour commencer à suivre sa santé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un animal'),
            ),
          ],
        ),
      ),
    );
  }
}
