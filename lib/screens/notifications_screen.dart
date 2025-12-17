import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../app_colors.dart';
import '../notifications.dart';
import '../services/api_service.dart';
import 'bill_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    notificationStore.addListener(_onChange);
    _fetchNotifications();
  }

  void _onChange() => setState(() {});

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiItems = await ApiService.getNotifications();
      final entries = apiItems.map<NotificationEntry>((n) {
        DateTime parsedDate;
        final dateVal = n['date']?.toString();
        try {
          parsedDate = dateVal != null ? DateTime.parse(dateVal) : DateTime.now();
        } catch (_) {
          parsedDate = DateTime.now();
        }

        return NotificationEntry(
          id: (n['_id'] ?? DateTime.now().microsecondsSinceEpoch).toString(),
          title: (n['title'] ?? 'Notification').toString(),
          body: (n['body'] ?? '').toString(),
          date: parsedDate,
        );
      }).toList();

      notificationStore.setNotifications(entries);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading && items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 240),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _fetchNotifications,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text('No notifications', style: TextStyle(color: Colors.grey)),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (_, i) {
                          final n = items[i];
                          final timeStr = '${n.date.hour.toString().padLeft(2, '0')}:${n.date.minute.toString().padLeft(2, '0')}';
                          return ListTile(
                            leading: const Icon(Icons.notifications, color: AppColors.primaryGreen),
                            title: Text(n.title),
                            subtitle: Text(n.body),
                            trailing: Text(timeStr),
                            onTap: () async {
                              if (n.billData != null) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => BillDetailScreen(data: n.billData!)),
                                );
                                return;
                              }
                              if (n.pdfData != null) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _PdfPreviewScreen(
                                      pdf: n.pdfData!,
                                      fileName: n.pdfFileName,
                                    ),
                                  ),
                                );
                                return;
                              }
                            },
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: items.length,
                      ),
      ),
    );
  }
}

class _PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdf;
  final String? fileName;
  const _PdfPreviewScreen({required this.pdf, this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName ?? 'PDF Preview'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await Printing.sharePdf(bytes: pdf, filename: fileName ?? 'document.pdf');
            },
          )
        ],
      ),
      body: PdfPreview(
        build: (format) async => pdf,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
