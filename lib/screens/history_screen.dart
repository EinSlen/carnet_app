import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';

class HistoryScreen extends ConsumerWidget {
  final Animal animal;
  const HistoryScreen({super.key, required this.animal});

  Future<void> _exportPdf(WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final id = animal.id!;
    await PdfService.shareVetReport(
      animal: animal,
      treatments: await repo.getTreatments(id),
      events: await repo.getLogEvents(id),
      measures: await repo.getMeasures(id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(animalHistoryProvider(animal.id!));
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi · ${animal.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportPdf(ref),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
            onRetry: () => ref.invalidate(animalHistoryProvider(animal.id!))),
        data: (h) => ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _ChartCard(
                title: 'Poids (kg)', data: h.weights, color: AppColors.coral),
            _ChartCard(
                title: 'Glycémie (g/L)',
                data: h.glucose,
                color: AppColors.teal),
            const SizedBox(height: 8),
            Text('Journal', style: Theme.of(context).textTheme.titleMedium),
            if (h.events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Aucune entrée.',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ...h.events.map((e) => ListTile(
                  dense: true,
                  leading: Text(e.type.emoji),
                  title: Text(e.label),
                  subtitle:
                      Text(DateFormat('dd/MM/yyyy HH:mm').format(e.dateTime)),
                )),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<Measure> data;
  final Color color;
  const _ChartCard(
      {required this.title, required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: data.length < 2
                  ? const Center(
                      child: Text('Pas encore assez de données',
                          style: TextStyle(color: AppColors.muted)))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 32)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < data.length; i++)
                                FlSpot(i.toDouble(), data[i].value),
                            ],
                            isCurved: true,
                            color: color,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                                show: true,
                                color: color.withValues(alpha: 0.12)),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
