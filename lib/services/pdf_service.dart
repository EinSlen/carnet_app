import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/models.dart';

/// Export "prêt pour le véto" — une des 3 promesses coeur.
class PdfService {
  static Future<void> shareVetReport({
    required Animal animal,
    required List<Treatment> treatments,
    required List<LogEvent> events,
    required List<Measure> measures,
  }) async {
    final df = DateFormat('dd/MM/yyyy');
    final dfh = DateFormat('dd/MM HH:mm');
    final doc = pw.Document();

    pw.Widget sectionTitle(String t) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12, bottom: 2),
          child: pw.Text(t,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Carnet de santé — ${animal.name}',
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('${animal.species.label} · ${animal.breed} · '
              '${animal.ageYears != null ? '${animal.ageYears} ans' : ''}'
              '${animal.weight != null ? ' · ${animal.weight} kg' : ''}'),
          if (animal.chronicConditions.isNotEmpty)
            pw.Text('Maladies chroniques : ${animal.chronicConditions}'),
          pw.SizedBox(height: 4),
          pw.Text('Édité le ${df.format(DateTime.now())}',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
          sectionTitle('Traitements en cours'),
          if (treatments.isEmpty) pw.Text('—'),
          ...treatments.map((t) => pw.Bullet(
              text: '${t.name} · ${t.dosage} · ${t.times.join(" / ")}')),
          sectionTitle('Mesures'),
          if (measures.isEmpty) pw.Text('—'),
          if (measures.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Type', 'Valeur'],
              cellStyle: const pw.TextStyle(fontSize: 9),
              data: measures.reversed
                  .take(40)
                  .map((m) => [
                        dfh.format(m.dateTime),
                        m.type.label,
                        '${m.value} ${m.unit}'
                      ])
                  .toList(),
            ),
          sectionTitle('Journal récent'),
          if (events.isEmpty) pw.Text('—'),
          ...events.take(40).map((e) => pw.Bullet(
              text: '${dfh.format(e.dateTime)} · ${e.type.label}'
                  '${e.status != null ? " (${e.status})" : ""}'
                  '${e.description.isNotEmpty ? " — ${e.description}" : ""}')),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'carnet_${animal.name}.pdf');
  }
}
