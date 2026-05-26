import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoiceGenerator {
  static Future<void> generateAndPrintInvoice({
    required String txId,
    required double total,
    double discount = 0.0,
    required double received,
    required double change,
    required List<Map<String, dynamic>> items,
    String? clientName,
    String? clientPhone,
  }) async {
    final pdf = pw.Document();

    // Déductions et calculs fiscaux tunisiens
    final totalArticlesBeforeDiscount =
        total > 1.0 ? total + discount - 1.0 : total + discount;
    final totalArticlesTTC = total > 1.0 ? total - 1.0 : total;
    final totalHT = totalArticlesTTC / 1.19;
    final totalTVA = totalArticlesTTC - totalHT;
    final timbreFiscal = total > 1.0 ? 1.0 : 0.0;
    final netAPayer = total;

    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('MotoStock Pro',
                          style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.deepOrange)),
                      pw.SizedBox(height: 4),
                      pw.Text('Facture de vente au comptoir',
                          style: const pw.TextStyle(fontSize: 14)),
                      pw.SizedBox(height: 6),
                      pw.Text('M.F. : 1483920/A/M/000',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.Text('R.C. : B011242021 | Tunis, Tunisie',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Facture #$txId',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                          'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              if (clientName != null && clientName.isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Client / Facturé à :',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                              color: PdfColors.deepOrange,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            clientName,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (clientPhone != null &&
                              clientPhone.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Téléphone : $clientPhone',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ] else ...[
                pw.SizedBox(height: 10),
              ],

              // Table header
              pw.Container(
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom:
                            pw.BorderSide(width: 1, color: PdfColors.grey))),
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('Désignation',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('Qté',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('P.U. (DT)',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('Total (DT)',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ]),
              ),
              pw.SizedBox(height: 8),

              // Table rows
              ...items.map((item) {
                return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(children: [
                      pw.Expanded(
                          flex: 3,
                          child: pw.Text('${item['nom']} (${item['ref']})')),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('${item['qty']}',
                              textAlign: pw.TextAlign.center)),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('${item['pu'].toStringAsFixed(3)}',
                              textAlign: pw.TextAlign.right)),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                              '${(item['qty'] * item['pu']).toStringAsFixed(3)}',
                              textAlign: pw.TextAlign.right)),
                    ]));
              }),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Totals
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Total Articles (TTC) : '),
                            pw.SizedBox(width: 20),
                            pw.Text(
                                '${totalArticlesBeforeDiscount.toStringAsFixed(3)} DT'),
                          ]),
                      if (discount > 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text('Remise : '),
                              pw.SizedBox(width: 20),
                              pw.Text('-${discount.toStringAsFixed(3)} DT'),
                            ]),
                      ],
                      pw.SizedBox(height: 5),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Total HT (Hors Taxe) : '),
                            pw.SizedBox(width: 20),
                            pw.Text('${totalHT.toStringAsFixed(3)} DT'),
                          ]),
                      pw.SizedBox(height: 5),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('TVA (19%) : '),
                            pw.SizedBox(width: 20),
                            pw.Text('${totalTVA.toStringAsFixed(3)} DT'),
                          ]),
                      pw.SizedBox(height: 5),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Timbre Fiscal : '),
                            pw.SizedBox(width: 20),
                            pw.Text('${timbreFiscal.toStringAsFixed(3)} DT'),
                          ]),
                      pw.SizedBox(height: 10),
                      pw.Container(
                          height: 1, width: 220, color: PdfColors.grey400),
                      pw.SizedBox(height: 10),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Net à Payer (TTC) : ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16)),
                            pw.SizedBox(width: 20),
                            pw.Text('${netAPayer.toStringAsFixed(3)} DT',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16,
                                    color: PdfColors.deepOrange)),
                          ]),
                      pw.SizedBox(height: 8),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Montant reçu : '),
                            pw.SizedBox(width: 20),
                            pw.Text('${received.toStringAsFixed(3)} DT'),
                          ]),
                      pw.SizedBox(height: 5),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Rendu : '),
                            pw.SizedBox(width: 20),
                            pw.Text('${change.toStringAsFixed(3)} DT'),
                          ]),
                    ])
              ]),

              pw.Spacer(),
              pw.Center(
                  child: pw.Text('Merci de votre visite !',
                      style: const pw.TextStyle(color: PdfColors.grey700)))
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Facture_$txId',
    );
  }
}
