import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'screens/bill_detail_screen.dart';

class NotificationEntry {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final BillDetailData? billData;
  final Uint8List? pdfData;
  final String? pdfFileName;

  NotificationEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.billData,
    this.pdfData,
    this.pdfFileName,
  });
}

class NotificationStore extends ChangeNotifier {
  final List<NotificationEntry> _items = [];

  List<NotificationEntry> get items => List.unmodifiable(_items.reversed);

  void addNotification(NotificationEntry e) {
    _items.add(e);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final NotificationStore notificationStore = NotificationStore();
