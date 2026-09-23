import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndShareReport(
    Map<String, dynamic> patient,
    List<Map<String, dynamic>> sessions,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Smart Rehab Glove',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Detailed Medical Report',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 25),

              pw.Text(
                'Patient Information:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue600,
                ),
              ),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Name: ${patient['name']}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Age: ${patient['age']} Years',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Patient ID: ${patient['id']}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Diagnosis: ${patient['diagnosis']}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              pw.Text(
                'Therapy Sessions History (Finger Analytics):',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue600,
                ),
              ),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),

              sessions.isEmpty
                  ? pw.Text(
                      'No therapy sessions recorded for this patient yet.',
                      style: const pw.TextStyle(color: PdfColors.grey600),
                    )
                  : pw.Table.fromTextArray(
                      headerStyle: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      cellStyle: const pw.TextStyle(fontSize: 10),
                      headerDecoration: const pw.BoxDecoration(
                        color: PdfColors.blueAccent,
                      ),
                      cellAlignment: pw.Alignment.center,
                      // ضفنا كل صباع في الـ Headers
                      headers: [
                        'Date',
                        'Time',
                        'Duration',
                        'Thumb',
                        'Index',
                        'Middle',
                        'Ring',
                        'Pinky',
                        'Avg',
                      ],
                      data: sessions.map((s) {
                        DateTime d = DateTime.parse(s['date']);
                        String dateStr =
                            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                        String timeStr =
                            '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

                        // بنجيب بيانات الأصابع، ولو دي جلسة قديمة متسجلتش بأصابع بنحطلها 0 عشان التطبيق ميكراشش
                        List<dynamic> fingers =
                            s['fingers'] ?? [0.0, 0.0, 0.0, 0.0, 0.0];

                        return [
                          dateStr,
                          timeStr,
                          '${s['duration']}s',
                          '${(fingers[0] * 100).toInt()}%',
                          '${(fingers[1] * 100).toInt()}%',
                          '${(fingers[2] * 100).toInt()}%',
                          '${(fingers[3] * 100).toInt()}%',
                          '${(fingers[4] * 100).toInt()}%',
                          '${(s['score'] * 100).toInt()}%',
                        ];
                      }).toList(),
                    ),

              pw.Spacer(),

              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Text(
                  'Generated automatically by Smart Rehab Glove System\nFaculty of Engineering Graduation Project',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${patient['name']}_Analytics_Report.pdf',
    );
  }
}
