import 'package:flutter/material.dart';
import 'buy_sell.dart';
import 'member_registation.dart';
import '../app_colors.dart';
import '../field_footer.dart';
import '../session.dart';
import 'field_visitor_my_profile.dart';
import '../services/api_service.dart';

// Preview entrypoint removed. Use `lib/main.dart` as the canonical app entrypoint.
// void main() => runApp(const FarmerManagementApp(homeOverride: FieldVisitorDashboard()));

class MambersList extends StatefulWidget {
  final String? fieldVisitorCode;
  final String? fieldVisitorName;
  const MambersList({super.key, this.fieldVisitorCode, this.fieldVisitorName});

  @override
  State<MambersList> createState() => _MambersListState();
}

class _MambersListState extends State<MambersList> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = false;

  // Local/sample members removed — member list is driven by `farmerStore`.

  List<Map<String, dynamic>> get _filteredMembers {
    final q = _searchCtrl.text.trim().toLowerCase();
    final all = _allMembers;
    if (q.isEmpty) return all; // show full list by default
    return all.where((m) {
      final name = (m['name'] as String).toLowerCase();
      final mobile = (m['mobile'] as String?) ?? '';
      final bill = (m['billNumber'] as String?) ?? '';
      return name.contains(q) || mobile.toLowerCase().contains(q) || bill.toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> get _allMembers {
    try {
      final list = farmerStore.farmers.map((f) => {
            'name': f.name,
            'location': f.address,
            'mobile': f.mobile,
            'nic': f.nic,
            'address': f.address,
            'billNumber': f.billNumber,
            'fieldVisitorCode': f.fieldVisitorCode,
            'progress': 0.0,
          }).toList();
      if (widget.fieldVisitorCode == null) return list;
      return list.where((m) => (m['fieldVisitorCode'] as String?) == widget.fieldVisitorCode).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
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
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      final fieldVisitorId = AppSession.fieldVisitorId;
      if (fieldVisitorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session error. Please login again.')),
        );
        return;
      }
      
      final response = await ApiService.getMembers(fieldVisitorId: fieldVisitorId.toString());
      
      if (response['success'] == true) {
        final List<dynamic> membersData = response['data'] ?? [];
        for (var memberData in membersData) {
          final farmer = Farmer(
            id: memberData['id']?.toString() ?? '',
            name: memberData['full_name'] ?? '',
            phone: memberData['mobile'] ?? '',
            mobile: memberData['mobile'] ?? '',
            nic: memberData['nic'] ?? '',
            address: memberData['postal_address'] ?? memberData['permanent_address'] ?? '',
            billNumber: memberData['member_code']?.toString() ?? '',
            fieldVisitorCode: AppSession.fieldCode ?? '',
          );
          
          if (!farmerStore.farmers.any((f) => f.id == farmer.id)) {
            farmerStore.addFarmer(farmer);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to load members')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading members: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onStoreChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // Field visitor target values (include registered members from farmerStore)
    final int target = 150;
    final int registeredMembers = farmerStore.farmers.length;
    final int addedCount = registeredMembers;
    final double targetPct = (addedCount / target).clamp(0.0, 1.0);

    // Totals for header: total members (source = member list), monthly buy/sell sums
    final int totalMembers = _allMembers.length;
    final double monthlyBuy = farmerStore.totalBuyAll;
    final double monthlySell = farmerStore.totalSellAll;
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
                        InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FieldVisitorMyProfileScreen())),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.fieldVisitorName != null ? '${widget.fieldVisitorName} 👋' : '${AppSession.displayFieldName} 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(height: 4),
                              Text(AppSession.displayFieldPhone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
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

                    const SizedBox(height: 12),
                    // Summary stats: total members and aggregated buy/sell
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Members', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('$totalMembers', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Monthly Buy', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('${monthlyBuy.toInt()} Kg', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Monthly Sell', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('${monthlySell.toInt()} Kg', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
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

      bottomNavigationBar: const AppFooter(currentIndex: 1),
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
            fieldVisitorCode: AppSession.displayFieldCode,
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