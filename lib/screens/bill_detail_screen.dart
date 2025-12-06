import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../app_colors.dart';
import '../session.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class BillDetailData {
  final String billNo;
  final String type; // BUY or SELL
  final DateTime date;
  final String memberName;
  final String memberPhone;
  final String memberAddress;
  final String product;
  final String quantityLabel; // Weight / Count
  final int quantity;
  final double unitPrice;
  final double total;
  final String fieldVisitorName;
  final String fieldVisitorPhone;
  final String fieldVisitorCode;
  final String? companyName;
  final String? companyAddress;
  final String? companyPhone;

  const BillDetailData({
    required this.billNo,
    required this.type,
    required this.date,
    required this.memberName,
    required this.memberPhone,
    required this.memberAddress,
    required this.product,
    required this.quantityLabel,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.fieldVisitorName,
    required this.fieldVisitorPhone,
    required this.fieldVisitorCode,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
  });
}

class BillDetailScreen extends StatelessWidget {
  final BillDetailData data;
  const BillDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text('${data.type} Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final bytes = await _buildPdf(data);
              await Printing.sharePdf(bytes: bytes, filename: 'NF_${data.type}_${data.billNo}.pdf');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _sectionTitle('Bill Information'),
            _infoGrid({
              'Bill No': data.billNo,
              'Date': _fmtDate(data.date),
              'Type': data.type,
              'Product': data.product,
            }),
            const SizedBox(height: 16),
            _sectionTitle('Member Details'),
            _infoGrid({
              'Name': data.memberName,
              'Phone': data.memberPhone,
              'Address': data.memberAddress,
            }),
            const SizedBox(height: 16),
            _sectionTitle('Field Visitor'),
            _infoGrid({
              'Name': data.fieldVisitorName,
              'Phone': data.fieldVisitorPhone,
              'Code': AppSession.displayFieldCode,
            }),
            const SizedBox(height: 16),
            _sectionTitle('Line Item'),
            _lineItemTable(),
            const SizedBox(height: 24),
            _totalsCard(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final bytes = await _buildPdf(data);
                  await Printing.sharePdf(bytes: bytes, filename: 'NF_${data.type}_${data.billNo}.pdf');
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ClipOval(child: Image.asset('assets/images/nf logo.jpg', fit: BoxFit.cover)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.companyName ?? 'Nature Farming', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(data.companyAddress ?? 'Kilinochi, Sri Lanka', style: const TextStyle(color: Colors.white70)),
                Text('Phone: ${data.companyPhone ?? '0712345678'}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.w700)),
      );

  Widget _infoGrid(Map<String, String> items) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: items.entries
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Flexible(child: Text(e.value, textAlign: TextAlign.right)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _lineItemTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FlexColumnWidth(),
          2: FixedColumnWidth(70),
          3: FixedColumnWidth(60),
          4: FixedColumnWidth(70),
          5: FixedColumnWidth(80),
        },
        border: TableBorder.all(color: AppColors.border),
        children: [
          _tableHeader(),
          TableRow(children: [
            _cell('1'),
            _cell(data.product),
            _cell(data.quantityLabel),
            _cell(data.quantity.toString()),
            _cell(data.unitPrice.toStringAsFixed(2)),
            _cell(data.total.toStringAsFixed(2)),
          ])
        ],
      ),
    );
  }

  TableRow _tableHeader() => TableRow(
        decoration: const BoxDecoration(color: Color(0xFFE6FFEF)),
        children: const [
          _HeaderCell('S.No'),
          _HeaderCell('Goods Description'),
          _HeaderCell('HSN'),
          _HeaderCell('QTY'),
          _HeaderCell('MRP'),
          _HeaderCell('Amount'),
        ],
      );

  Widget _totalsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(data.total.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Discount', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('0.00'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text(data.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<Uint8List> _buildPdf(BillDetailData d) async {
    final pdf = pw.Document();
    final c = AppColors.primaryGreen;
    final int a = ((c.a * 255.0).round() & 0xff);
    final int r = ((c.r * 255.0).round() & 0xff);
    final int g = ((c.g * 255.0).round() & 0xff);
    final int b = ((c.b * 255.0).round() & 0xff);
    final headerColor = PdfColor.fromInt((a << 24) | (r << 16) | (g << 8) | b);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              color: headerColor,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(d.companyName ?? 'Nature Farming', style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(d.companyAddress ?? 'Kilinochi, Sri Lanka', style: const pw.TextStyle(color: PdfColors.white)),
                    pw.Text('Phone: ${d.companyPhone ?? '0712345678'}', style: const pw.TextStyle(color: PdfColors.white)),
                  ]),
                  pw.Text('${d.type} BILL', style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            _pdfKV('Bill No', d.billNo),
            _pdfKV('Date', _fmtDate(d.date)),
            _pdfKV('Type', d.type),
            _pdfKV('Product', d.product),
            pw.SizedBox(height: 12),
            pw.Text('Member Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _pdfKV('Name', d.memberName),
            _pdfKV('Phone', d.memberPhone),
            _pdfKV('Address', d.memberAddress),
            pw.SizedBox(height: 12),
            pw.Text('Field Visitor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _pdfKV('Name', d.fieldVisitorName),
            _pdfKV('Phone', d.fieldVisitorPhone),
            _pdfKV('Code', AppSession.displayFieldCode),
            pw.SizedBox(height: 12),
            pw.Text('Line Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {
                0: pw.FixedColumnWidth(40),
                1: pw.FlexColumnWidth(),
                2: pw.FixedColumnWidth(70),
                3: pw.FixedColumnWidth(60),
                4: pw.FixedColumnWidth(70),
                5: pw.FixedColumnWidth(70),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: ['S.No', 'Goods Description', 'HSN', 'QTY', 'MRP', 'Amount']
                      .map((h) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))))
                      .toList(),
                ),
                pw.TableRow(children: [
                  _pdfCell('1'),
                  _pdfCell(d.product),
                  _pdfCell(d.quantityLabel),
                  _pdfCell(d.quantity.toString()),
                  _pdfCell(d.unitPrice.toStringAsFixed(2)),
                  _pdfCell(d.total.toStringAsFixed(2)),
                ])
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(d.total.toStringAsFixed(2)),
            ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Discount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('0.00'),
            ]),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(d.total.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ]),
          ]),
        ),
      ),
    );
    return Uint8List.fromList(await pdf.save());
  }

  pw.Widget _pdfKV(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(k, style: const pw.TextStyle(color: PdfColors.grey600)),
          pw.Expanded(child: pw.Text(v, textAlign: pw.TextAlign.right)),
        ]),
      );

  pw.Widget _pdfCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      );
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

Widget _cell(String v) => Padding(
      padding: const EdgeInsets.all(6),
      child: Text(v, style: const TextStyle(fontSize: 12)),
    );