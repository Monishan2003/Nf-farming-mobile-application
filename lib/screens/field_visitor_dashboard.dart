import 'package:flutter/material.dart';
import '../session.dart';
import 'buy_sell.dart';
import 'member_registation.dart';
import '../app_colors.dart';
import '../field_footer.dart';
import 'field_visitor_my_profile.dart';
import 'memberlist.dart';

// Preview entrypoint removed. Use `lib/main.dart` as the canonical app entrypoint.
// void main() => runApp(const FarmerManagementApp(homeOverride: FieldVisitorDashboard()));

class FieldVisitorDashboard extends StatefulWidget {
  const FieldVisitorDashboard({super.key});

  @override
  State<FieldVisitorDashboard> createState() => _FieldVisitorDashboardState();
}

class _FieldVisitorDashboardState extends State<FieldVisitorDashboard> {
  final TextEditingController _searchCtrl = TextEditingController();

  // Members are sourced from the shared `farmerStore`; remove local sample members.
  List<Map<String, dynamic>> get _filteredMembers {
    final q = _searchCtrl.text.trim().toLowerCase();
    final all = farmerStore.farmers.map((f) => {
          'name': f.name,
          'location': f.address,
          'mobile': f.mobile,
          'nic': f.nic,
          'address': f.address,
          'billNumber': f.billNumber,
          'lastSeen': '',
        }).toList();
    if (q.isEmpty) return all;
    return all
        .where((m) => (m['name'] as String).toLowerCase().contains(q) || (m['mobile'] as String).toLowerCase().contains(q) || (m['billNumber'] as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    farmerStore.removeListener(_onStoreChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    farmerStore.addListener(_onStoreChanged);
  }

  void _onStoreChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // Dynamic counts: use registered members from farmerStore only
    final int registeredMembers = farmerStore.farmers.length;
    final int myMembers = registeredMembers;
    final int reminders = 0;
    // Use farmerStore totals so values update when members record buy/sell are changed
    final double monthlyBuy = farmerStore.totalBuyAll;
    final double monthlySell = farmerStore.totalSellAll;
    const int target = 150; // keep same target baseline
    final double targetProgress = (myMembers / target).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F7EE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo and profile
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.eco, color: Colors.green, size: 24),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Nature Farming',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FieldVisitorMyProfileScreen())),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(AppSession.displayFieldName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(AppSession.displayFieldCode, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(AppSession.displayFieldPhone, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.orange,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search by name, mobile or Bill number...",
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('My Members', myMembers.toString(), Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Reminders (Visit)', reminders.toString(), Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Monthly Buy/Sell Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Monthly Buy (Kg)', monthlyBuy.toString(), Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Monthly Sell (Kg)', monthlySell.toString(), Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Target Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Target Progress\nThis Month',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          Text(
                            '${(targetProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: targetProgress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(Colors.green),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$myMembers of $target added (${(targetProgress * 100).toInt()}%)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pie Charts Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPieChartCard(
                        'Total Buy',
                        '10,000 KG',
                        [
                          {'label': 'Local Buyer', 'value': 0.6, 'color': const Color(0xFF90EE90)},
                          {'label': 'Distributors', 'value': 0.4, 'color': const Color(0xFF228B22)},
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPieChartCard(
                        'Total Sell',
                        '20,000 BS',
                        [
                          {'label': 'Export Buyer', 'value': 0.7, 'color': const Color(0xFFFF6B6B)},
                          {'label': 'Direct Export', 'value': 0.3, 'color': const Color(0xFFDC143C)},
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Add Member Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WelcomeFormScreen()),
                      );
                    },
                    child: const Text(
                      "+ Add Member",
                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // My Members Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MambersList())),
                  child: Text(
                    'My Members — ${AppSession.displayFieldName} (${AppSession.displayFieldCode})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Members List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: _filteredMembers.map((m) => _buildMemberTile(context, m)).toList(),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildStatCard(String title, String value, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(String title, String total, List<Map<String, dynamic>> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            width: 100,
            child: CustomPaint(
              painter: PieChartPainter(data),
            ),
          ),
          const SizedBox(height: 12),
          ...data.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['label'],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text(
            'Total $title Amount',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            total,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, Map<String, dynamic> m) {
    return InkWell(
      onTap: () {
        final name = m['name'] as String;
        Farmer? existing;
        try {
          existing = farmerStore.farmers.firstWhere((f) => f.name == name);
        } catch (e) {
          existing = null;
        }

        if (existing != null) {
          farmerStore.selectFarmer(existing);
        } else {
          final id = DateTime.now().millisecondsSinceEpoch.toString();
          final f = Farmer(
            id: id,
            name: name,
            phone: '',
            address: m['address'] ?? '',
            mobile: m['mobile'] ?? '',
            nic: m['nic'] ?? '',
            billNumber: m['billNumber'] ?? '',
          );
          farmerStore.addFarmer(f);
          farmerStore.selectFarmer(f);
        }

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE8D5FF),
              child: const Icon(Icons.person, color: Color(0xFF9C27B0), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m['location'] ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              m['lastSeen'] ?? '',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -90 * (3.14159 / 180);

    for (var item in data) {
      final sweepAngle = (item['value'] as double) * 2 * 3.14159;
      final paint = Paint()
        ..color = item['color']
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}