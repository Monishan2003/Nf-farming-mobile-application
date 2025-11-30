import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppFooter({super.key, this.currentIndex = 0, this.onTap});

  // Use centralized AppColors.primaryGreen

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
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // small centre handle/pill
            Container(
              width: 76,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FooterItem(
                  icon: Icons.home,
                  label: 'Home',
                  active: currentIndex == 0,
                  onTap: () => onTap?.call(0),
                ),
                _FooterItem(
                  icon: Icons.group,
                  label: 'Members',
                  active: currentIndex == 1,
                  onTap: () => onTap?.call(1),
                ),
                _FooterItem(
                  icon: Icons.note,
                  label: 'Notes',
                  active: currentIndex == 2,
                  onTap: () => onTap?.call(2),
                ),
                _FooterItem(
                  icon: Icons.notifications,
                  label: 'Notify',
                  active: currentIndex == 3,
                  onTap: () => onTap?.call(3),
                ),
                _FooterItem(
                  icon: Icons.person,
                  label: 'Profile',
                  active: currentIndex == 4,
                  onTap: () => onTap?.call(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _FooterItem({required this.icon, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryGreen : Colors.grey[600];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
}
