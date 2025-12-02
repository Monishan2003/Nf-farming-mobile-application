import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_sell.dart';
import '../app_colors.dart';
import 'field_visitor_profile.dart';
import 'field_visitos_registation.dart';
import '../manager_footer.dart';
import '../session.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);
    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        bottomNavigationBar: const ManagerFooter(currentIndex: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildSearchBar(),
                const SizedBox(height: 14),
                _buildTopCards(),
                const SizedBox(height: 18),
                _buildVisitorsMembersCards(),
                const SizedBox(height: 18),
                _buildMonthlyAmountCards(),
                const SizedBox(height: 18),
                _buildMonthlyTrendBarChart(),
                const SizedBox(height: 20),
                _buildAddFieldVisitorButton(context),
                const SizedBox(height: 28),
                _buildRecentVisitorsList(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8, top: 6),
      child: Material(
        color: Colors.transparent,
        elevation: 2,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Text(
                  'NF',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nature Farming',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Manager: ${AppSession.displayManagerName} (${AppSession.displayManagerCode})',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        // Compute totals from billHistory for the current month
        final now = DateTime.now();
        final month = now.month;
        final totalBuy = billHistory.where((b) => b.date.month == month && b.type == 'BUY').fold<int>(0, (p, e) => p + e.quantity);
        final totalSell = billHistory.where((b) => b.date.month == month && b.type == 'SELL').fold<int>(0, (p, e) => p + e.quantity);
        final items = [
          _statCard('Monthly Buy (KG)', totalBuy.toString()),
          _statCard('Monthly Sell (KG)', totalSell.toString()),
        ];
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map((w) => SizedBox(width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth, child: w))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildVisitorsMembersCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        // Field visitors: unique visitor codes from bill history
        final visitorCodes = billHistory.map((b) => b.fieldVisitorCode).where((c) => c.isNotEmpty).toSet();
        final visitorsCount = visitorCodes.length;
        final membersCount = farmerStore.farmers.length;
        final cards = [
          _infoCard('Field Visitors', visitorsCount.toString(), Icons.badge),
          _infoCard('All Members', membersCount.toString(), Icons.group),
        ];
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((w) => SizedBox(width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth, child: w))
              .toList(),
        );
      },
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.lightGreen, child: Icon(icon, color: AppColors.green)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey)),
              const SizedBox(height: 6),
              Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }
  

  Widget _buildMonthlyAmountCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('October Month Total Buy and Sell', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _amountTile('Total Buy Amount', '₹ 10,000')),
              const SizedBox(width: 12),
              Expanded(child: _amountTile('Total Sell Amount', '₹ 20,000')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green, width: 1.25),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.green, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search field visitors...',
                border: InputBorder.none,
                hintStyle: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendBarChart() {
    // Build monthly buys/sells from central bill history
    final buys = List<int>.generate(12, (i) => billHistory.where((b) => b.date.month == i + 1 && b.type == 'BUY').fold<int>(0, (p, e) => p + e.quantity));
    final sells = List<int>.generate(12, (i) => billHistory.where((b) => b.date.month == i + 1 && b.type == 'SELL').fold<int>(0, (p, e) => p + e.quantity));
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final maxValue = [...buys, ...sells].isNotEmpty ? [...buys, ...sells].reduce((a, b) => a > b ? a : b) : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buys vs Sells - Monthly Trend', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
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
                        child: Text(months[value.toInt()], style: GoogleFonts.inter(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final isSell = rod.color == Colors.red;
                    return BarTooltipItem(
                      '${isSell ? 'Sell' : 'Buy'}: ${rod.toY.toInt()}',
                      GoogleFonts.inter(fontWeight: FontWeight.w600, color: rod.color),
                    );
                  },
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
        const SizedBox(height: 12),
        Row(
          children: [
            _legendDot(Colors.red), const SizedBox(width: 6), Text('Total Sell', style: GoogleFonts.inter(fontSize: 12)),
            const SizedBox(width: 18),
            _legendDot(Colors.blue), const SizedBox(width: 6), Text('Total Buy', style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color c) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _buildAddFieldVisitorButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RegistrationScreen()),
          );
        },
        child: Text('+  Add Field Visitor', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // Removed old bar chart groups as spec requires a line chart.

  Widget _buildRecentVisitorsList(BuildContext context) {
    // Build recent visitors list from bill history (most recent field visitor codes)
    final recentCodes = billHistory.reversed.map((b) => b.fieldVisitorCode).where((c) => c.isNotEmpty).toSet().take(6).toList();
    final visitors = recentCodes.map((code) {
      final visits = billHistory.where((b) => b.fieldVisitorCode == code).toList();
      final totalKg = visits.fold<int>(0, (p, e) => p + e.quantity);
      final percent = 0; // percent not easily computed here without targets
      final displayName = code; // fallback to code
      return _visitorTile(context, displayName, 'Visitor', '${totalKg}Kg', percent);
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Field Visitors', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(onPressed: () {}, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 10),
        ...visitors.take(4),
      ],
    );
  }

  Widget _visitorTile(BuildContext context, String name, String type, String weight, int percent) {
    return InkWell(
      onTap: () {
        final codeMatch = RegExp(r"\(([^)]+)\)").firstMatch(name);
        final code = codeMatch != null ? codeMatch.group(1)! : 'k001';
        const membersTarget = 150;
        final membersCurrent = (percent * membersTarget / 100).round();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FieldVisitorProfileScreen(
              name: name.split(' (').first,
              code: code,
              phone: '071 2345 678',
              address: 'Jaffna,Srilanka',
              email: 'ravimohan@gmail.com',
              membersCurrent: membersCurrent,
              membersTarget: membersTarget,
              totalBuyRs: 250000,
              totalSellRs: 150000,
            ),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.lightGreen,
            child: const Icon(Icons.person, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 7,
                        backgroundColor: Colors.grey.shade300,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$percent%', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(type, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey)),
              const SizedBox(height: 6),
              Text(weight, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    ),
    );
  }

  // Footer moved to dedicated ManagerFooter widget (see lib/manager_footer.dart).
}