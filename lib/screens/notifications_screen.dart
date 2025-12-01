import 'package:flutter/material.dart';
import '../app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[]; // placeholder list
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('No notifications', style: TextStyle(color: Colors.grey)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.notifications, color: AppColors.green),
                title: Text(items[i]['title'] ?? ''),
                subtitle: Text(items[i]['body'] ?? ''),
              ),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: items.length,
            ),
    );
  }
}
