import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'screens/manager_dashboard.dart';
import 'screens/field_visitors_list.dart';
import 'screens/monthly_report.dart';
import 'screens/manager_profile.dart';
import 'screens/notifications_screen.dart';

class ManagerFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const ManagerFooter({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(context, Icons.dashboard, 'Dashboard', 0),
            _item(context, Icons.group, 'Field Visitors', 1),
            _item(context, Icons.report, 'Report', 2),
            _item(context, Icons.notifications, 'Notifications', 3),
            _item(context, Icons.person, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, int index) {
    final active = currentIndex == index;
    final color = active ? AppColors.primaryGreen : AppColors.grey;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (onTap != null) {
          onTap!(index);
          return;
        }
        _defaultNavigate(context, index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _defaultNavigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManagerDashboard()));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FieldVisitorsListScreen()));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MonthlyReportScreen()));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())); 
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManagerProfileScreen()));
        break;
      default:
        break;
    }
  }
}
