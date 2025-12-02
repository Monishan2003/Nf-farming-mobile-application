import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../notifications.dart';
import 'bill_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    notificationStore.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    notificationStore.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = notificationStore.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.clear_all),
            onPressed: () => notificationStore.clear(),
          )
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('No notifications', style: TextStyle(color: Colors.grey)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final n = items[i];
                return ListTile(
                  leading: const Icon(Icons.notifications, color: AppColors.primaryGreen),
                  title: Text(n.title),
                  subtitle: Text(n.body),
                  trailing: Text('${n.date.hour.toString().padLeft(2, '0')}:${n.date.minute.toString().padLeft(2, '0')}'),
                  onTap: () async {
                    // If the notification has bill data, open the bill screen
                    if (n.billData != null) {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => BillDetailScreen(data: n.billData!)));
                    }
                  },
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: items.length,
            ),
    );
  }
}
