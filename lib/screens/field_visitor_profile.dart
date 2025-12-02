import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../manager_footer.dart';
import 'buy_sell.dart';
import '../visitor_store.dart';

class FieldVisitorProfileScreen extends StatefulWidget {
  final String name;
  final String code; // e.g., k001 / AF 0252
  final String phone;
  final String address;
  final String email;
  final int membersTarget;

  const FieldVisitorProfileScreen({
    super.key,
    required this.name,
    required this.code,
    required this.phone,
    required this.address,
    required this.email,
    this.membersTarget = 150,
  });

  @override
  State<FieldVisitorProfileScreen> createState() => _FieldVisitorProfileScreenState();
}

class _FieldVisitorProfileScreenState extends State<FieldVisitorProfileScreen> {
  @override
  void initState() {
    super.initState();
    farmerStore.addListener(_onChange);
    visitorStore.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    farmerStore.removeListener(_onChange);
    visitorStore.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FFF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _headerCard(context),
              const SizedBox(height: 16),
              _detailsCard(context),
              const SizedBox(height: 16),
              _totalsCard(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ManagerFooter(currentIndex: 1),
    );
  }

  double get progress {
    final membersCurrent = _membersCurrent;
    final target = widget.membersTarget == 0 ? 1 : widget.membersTarget;
    return membersCurrent / target;
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,3))],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    '${widget.name} (${widget.code})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Field visitor Details',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailsRow('Name', widget.name),
          _detailsRow('Mobile Number', widget.phone),
          _detailsRow('Address', widget.address),
          _detailsRow('Email', widget.email),
          const SizedBox(height: 8),
          const _SectionTitle(icon: Icons.bar_chart, title: 'Members'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2FBF5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$_membersCurrent/${widget.membersTarget}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('${(progress*100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progress.clamp(0, 1),
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Intentionally left unconnected: members button does not
                // navigate to the members list per requested behavior.
              },
              child: const Text('members', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalsCard(BuildContext context) {
    TextStyle titleStyle(Color c) => TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 16);
    final textGrey = TextStyle(color: Colors.grey[700]);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Buy', style: titleStyle(AppColors.primaryGreen)),
              Text('Total Sell', style: titleStyle(Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_rs(_visitorTotals.buy), style: textGrey),
              Text(_rs(_visitorTotals.sell), style: textGrey),
            ],
          ),
        ],
      ),
    );
  }

  int get _membersCurrent => farmerStore.farmers.where((f) => f.fieldVisitorCode == widget.code).length;

  // Totals struct
  _Totals get _visitorTotals {
    final visits = billHistory.where((b) => b.fieldVisitorCode == widget.code).toList();
    final buy = visits.where((b) => b.type == 'BUY').fold<double>(0.0, (p, e) => p + e.total).toInt();
    final sell = visits.where((b) => b.type == 'SELL').fold<double>(0.0, (p, e) => p + e.total).toInt();
    return _Totals(buy: buy, sell: sell);
  }

  String _rs(int v) {
    final s = v.toString();
    // simple thousands formatting from the right
    final chars = s.split('').reversed.toList();
    final buf = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buf.write(',');
      buf.write(chars[i]);
    }
    final withCommas = buf.toString().split('').reversed.join();
    return '$withCommas RS';
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 18),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _Totals {
  final int buy;
  final int sell;
  _Totals({required this.buy, required this.sell});
}
