import 'dart:collection';
import 'package:flutter/foundation.dart';

class Visitor {
  final String id;
  String name;
  String code;
  String address;

  Visitor({required this.id, required this.name, required this.code, required this.address});
}

class VisitorStore extends ChangeNotifier {
  final List<Visitor> _visitors = [];

  UnmodifiableListView<Visitor> get visitors => UnmodifiableListView(_visitors);

  void addVisitor(Visitor v) {
    _visitors.add(v);
    notifyListeners();
  }

  void removeVisitor(String id) {
    _visitors.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  int get count => _visitors.length;
}

final VisitorStore visitorStore = VisitorStore();
