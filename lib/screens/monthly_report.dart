import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_colors.dart';
import '../manager_footer.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pww;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      bottomNavigationBar: const ManagerFooter(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Monthly Buy & Sell Reports'),
        actions: [
          IconButton(
            tooltip: 'Download PDF',
            icon: const Icon(Icons.download),
            onPressed: () async {
              final bytes = await _buildPdf();
              await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: 'monthly_report.pdf');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryCards(),
              const SizedBox(height: 16),
              _barChart(),
              const SizedBox(height: 16),
              _monthlyBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCards() {
    return Row(
      children: [
        Expanded(child: _statCard('Total Buy (KG)', '3,420')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Total Sell (KG)', '2,950')),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _barChart() {
    const buys = [20, 25, 22, 30, 35, 40, 42, 50, 54, 60, 68, 72];
    const sells = [28, 30, 32, 35, 40, 45, 48, 55, 58, 62, 70, 75];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final maxValue = [...buys, ...sells].reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buys vs Sells - Monthly Trend', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                maxY: (maxValue * 1.15).ceilToDouble(),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: true, border: const Border.symmetric(horizontal: BorderSide(color: Colors.black12))),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > 11) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(months[value.toInt()], style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(12, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 8,
                    barRods: [
                      BarChartRodData(toY: buys[i].toDouble(), color: Colors.blue, width: 12, borderRadius: BorderRadius.circular(4)),
                      BarChartRodData(toY: sells[i].toDouble(), color: Colors.red, width: 12, borderRadius: BorderRadius.circular(4)),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: const [
            _LegendDot(color: Colors.red), SizedBox(width: 6), Text('Total Sell', style: TextStyle(fontSize: 12)),
            SizedBox(width: 18),
            _LegendDot(color: Colors.blue), SizedBox(width: 6), Text('Total Buy', style: TextStyle(fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _monthlyBreakdown() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const buys = [20, 25, 22, 30, 35, 40, 42, 50, 54, 60, 68, 72];
    const sells = [28, 30, 32, 35, 40, 45, 48, 55, 58, 62, 70, 75];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(months.length, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.veryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(months[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                  Row(children: [
                    Text('Buy: ${buys[i]}kg', style: const TextStyle(color: Colors.blue)),
                    const SizedBox(width: 12),
                    Text('Sell: ${sells[i]}kg', style: const TextStyle(color: Colors.red)),
                  ]),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

Future<List<int>> _buildPdf() async {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const buys = [20, 25, 22, 30, 35, 40, 42, 50, 54, 60, 68, 72];
  const sells = [28, 30, 32, 35, 40, 45, 48, 55, 58, 62, 70, 75];
  final doc = pww.Document();
  doc.addPage(
    pww.MultiPage(
      pageTheme: const pww.PageTheme(pageFormat: pw.PdfPageFormat.a4),
      build: (context) => [
        pww.Header(level: 0, child: pww.Text('Monthly Buy & Sell Report', style: pww.TextStyle(fontSize: 20, fontWeight: pww.FontWeight.bold))),
        pww.SizedBox(height: 8),
        pww.TableHelper.fromTextArray(
          headers: const ['Month', 'Buy (KG)', 'Sell (KG)'],
          data: List.generate(months.length, (i) => [months[i], buys[i].toString(), sells[i].toString()]),
        ),
        pww.SizedBox(height: 12),
        pww.Text('Summary', style: pww.TextStyle(fontSize: 16, fontWeight: pww.FontWeight.bold)),
        pww.SizedBox(height: 4),
        pww.Bullet(text: 'Total Buy (KG): ${buys.reduce((a,b)=>a+b)}'),
        pww.Bullet(text: 'Total Sell (KG): ${sells.reduce((a,b)=>a+b)}'),
      ],
    ),
  );
  return doc.save();
}
