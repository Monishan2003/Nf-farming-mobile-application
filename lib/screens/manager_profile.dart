import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../manager_footer.dart';
import '../session.dart';
import 'monthly_report.dart';
import 'field_visitors_list.dart';

class ManagerProfileScreen extends StatelessWidget {
  const ManagerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      bottomNavigationBar: const ManagerFooter(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              _profileHeader(context),
              const SizedBox(height: 16),
              _sectionTitle('Settings'),
              _navTile(context, Icons.settings, 'Preferences', onTap: () => _todo(context)),
              _navTile(context, Icons.person_outline, 'Account', onTap: () => _todo(context)),
              const SizedBox(height: 16),
              _sectionTitle('Resources'),
              _navTile(context, Icons.support_outlined, 'Community Support', onTap: () => _todo(context)),
              _navTile(context, Icons.event, 'Monthly Summary', onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MonthlyReportScreen()));
              }),
              _navTile(context, Icons.group, 'Field visitors', onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FieldVisitorsListScreen()));
              }),
              const SizedBox(height: 16),
              _sectionTitle('Account'),
              _navTile(
                context,
                Icons.logout,
                'Logout',
                onTap: () {
                  showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            AppSession.clear();
                            Navigator.of(ctx).pop();
                            Navigator.of(ctx).pushNamedAndRemoveUntil('/login', (route) => false);
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: AppColors.primaryGreen),
        ),
      ],
    );
  }

  Widget _profileHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,3))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppSession.displayManagerName} (${AppSession.displayManagerCode})', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Manager', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800, fontSize: 16)),
    );
  }

  Widget _navTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primaryGreen),
        onTap: onTap,
      ),
    );
  }

  void _todo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
  }
}
