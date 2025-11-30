import 'package:flutter/material.dart';
import 'buy_sell.dart';
import 'farmer.dart';
import '../app_colors.dart';
import '../bottom_footer.dart';

// Preview entrypoint removed. Use `lib/main.dart` as the canonical app entrypoint.
// void main() => runApp(const FarmerManagementApp(homeOverride: FieldVisitorDashboard()));

class FieldVisitorDashboard extends StatefulWidget {
  const FieldVisitorDashboard({super.key});

  @override
  State<FieldVisitorDashboard> createState() => _FieldVisitorDashboardState();
}

class _FieldVisitorDashboardState extends State<FieldVisitorDashboard> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _members = List.generate(12, (i) => {
        'name': 'Member ${i + 1}',
        'location': ['Green Road', 'River Bank', 'Hill Side', 'Lake View'][i % 4],
        'mobile': '0717${(100000 + i).toString().padLeft(6, '0')}',
        'nic': 'NIC${1000 + i}',
        'address': '${['Green Road', 'River Bank', 'Hill Side', 'Lake View'][i % 4]}, District',
        'billNumber': 'B${100 + i}',
        'progress': ((i + 1) * 7 % 100) / 100.0,
      });

  List<Map<String, dynamic>> get _filteredMembers {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _members; // show full list by default
    return _members.where((m) => (m['name'] as String).toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Field visitor target values
    final int target = 150;
    final int addedCount = _members.length;
    final double targetPct = (addedCount / target).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: const Color(0xFFE8F7EE), // light green (same as Figma)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ----- TOP GREEN CARD -----
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome ,",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 4),
                    Text(
                      "Field visitor Name 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Field Visitor Dashboard",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 16),

                    // Search Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Search by name or id",
                                      hintStyle: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                Icon(Icons.search, color: Colors.black54)
                              ],
                            ),
                          ),

                    // ----- FIELD VISITOR TARGET (moved inside header so it's visible) -----
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Field Visitor Target",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              shadows: [Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)],
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: targetPct,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$addedCount of $target added (${(targetPct * 100).round()}%)",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // reduced vertical spacing to make the header more compact
                  ],
                ),
              ),

              const SizedBox(height: 12),
              // Add New Members button placed under the green header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WelcomeFormScreen()));
                    },
                    child: const Text(
                      "+  Add New Members",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),

              // ----- LIST ITEMS -----
              const SizedBox(height: 8),
              if (_filteredMembers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Please enter a farmer name to search/verify', style: TextStyle(color: Colors.grey[600])),
                  ),
                )
              else ..._buildMembersWithAdd(context),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AppFooter(),
    );
  }

  // Build member list widgets and insert Add button after the first item
  List<Widget> _buildMembersWithAdd(BuildContext context) {
    final List<Widget> widgets = [];
    for (var i = 0; i < _filteredMembers.length; i++) {
      final m = _filteredMembers[i];
      widgets.add(_buildMemberTile(context, m));
    }
    return widgets;
  }

  Widget _buildMemberTile(BuildContext context, Map<String, dynamic> m) {
    
    return InkWell(
      onTap: () {
        // Select an existing farmer by name if present, otherwise create one
        // using the placeholder contact details available in `m`, then navigate
        // to the main HomeScreen which shows farmer details.
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

        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.green.shade100,
              child: Text(
                (m['name'] as String).split(' ').map((s) => s.isEmpty ? '' : s[0]).take(2).join(),
                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(child: Text(m['location'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)))
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Member detail screen removed — navigation reverted to original behavior.