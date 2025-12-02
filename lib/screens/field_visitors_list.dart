import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../manager_footer.dart';
import '../session.dart';
import 'field_visitor_profile.dart';
import 'field_visitos_registation.dart';
import '../visitor_store.dart';

class FieldVisitorsListScreen extends StatefulWidget {
  const FieldVisitorsListScreen({super.key});

  @override
  State<FieldVisitorsListScreen> createState() => _FieldVisitorsListScreenState();
}

class _FieldVisitorsListScreenState extends State<FieldVisitorsListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    visitorStore.addListener(_onStoreChanged);
  }

  void _onStoreChanged() => setState(() {});

  List<Map<String, String>> get filtered {
    final q = _search.text.trim().toLowerCase();
    final src = visitorStore.visitors.map((v) => {'name': v.name, 'code': v.code, 'address': v.address}).toList();
    if (q.isEmpty) return src;
    return src.where((v) => (v['name'] ?? '').toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    visitorStore.removeListener(_onStoreChanged);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      bottomNavigationBar: const ManagerFooter(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final v = filtered[i];
                  return _visitorTile(context, v);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add new field visitor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Welcome ,', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 6),
          Text('${AppSession.displayManagerName} 👋', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: AppColors.primaryGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitorTile(BuildContext context, Map<String, String> v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,3))],
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(radius: 22, backgroundColor: AppColors.lightGreen, child: const Icon(Icons.person, color: AppColors.primaryGreen)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.primaryGreen),
                      const SizedBox(width: 4),
                      Flexible(child: Text(v['address'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FieldVisitorProfileScreen(
                      name: v['name'] ?? '',
                      code: v['code'] ?? '',
                      phone: '071 2345 678',
                      address: v['address'] ?? '',
                      email: 'manager@example.com',
                    ),
                  ),
                );
              },
              child: const Text('View', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
