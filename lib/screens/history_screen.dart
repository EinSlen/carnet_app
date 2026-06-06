import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_repository.dart';
import '../data/models.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final Animal animal;
  const HistoryScreen({super.key, required this.animal});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = AppRepository.instance;
  List<Measure> _weights = [];
  List<Measure> _glucose = [];
  List<LogEvent> _events = [];
  bool _loading = true;

  int get _aid => widget.animal.id!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final w = await _repo.getMeasures(_aid, type: 'poids');
    final g = await _repo.getMeasures(_aid, type: 'glycemie');
    final e = await _repo.getLogEvents(_aid);
    setState(() {
      _weights = w;
      _glucose = g;
      _events = e;
      _loading = false;
    });
  }

  Future<void> _exportPdf() async {
    final treatments = await _repo.getTreatments(_aid);
    final measures = await _repo.getMeasures(_aid);
    await PdfService.shareVetReport(
      animal: widget.animal,
      treatments: treatments,
      events: _events,
      measures: measures,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi · ${widget.animal.name}'),
        actions: [
          IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: _exportPdf),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _ChartCard(
                    title: 'Poids (kg)',
                    data: _weights,
                    color: AppColors.coral),
                _ChartCard(
                    title: 'Glycémie (g/L)',
                    data: _glucose,
                    color: AppColors.teal),
                const SizedBox(height: 8),
                Text('Journal', style: Theme.of(context).textTheme.titleMedium),
                if (_events.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucune entrée.',
                        style: TextStyle(color: AppColors.muted)),
                  ),
                ..._events.map((e) => ListTile(
                      dense: true,
                      leading: Text(_emoji(e.type)),
                      title: Text(_label(e)),
                      subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(e.dateTime)),
                    )),
              ],
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

String _emoji(String type) => switch (type) {
      'dose' => '💊',
      'symptome' => '⚠️',
      'repas' => '🍽️',
      _ => '📝',
    };

String _label(LogEvent e) {
  final base = switch (e.type) {
    'dose' => 'Médicament donné',
    'symptome' => 'Symptôme',
    'repas' => 'Repas',
    _ => 'Note',
  };
  return e.description.isEmpty ? base : '$base · ${e.description}';
}
