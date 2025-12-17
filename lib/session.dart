import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static String? role; // 'manager' or 'field'
  static String? managerName;
  static String? managerCode;
  static String? managerBranchId;
  static String? fieldName;
  static String? fieldCode;
  static String? fieldPhone;
  static String? fieldVisitorId; // Add field visitor ID for API calls
  static String? fieldBranchId;
  static String? token; // JWT Token

  // Load session data from SharedPreferences
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    managerName = prefs.getString('managerName');
    managerCode = prefs.getString('managerCode');
    managerBranchId = prefs.getString('managerBranchId');
    fieldName = prefs.getString('fieldName');
    fieldCode = prefs.getString('fieldCode');
    fieldPhone = prefs.getString('fieldPhone');
    fieldVisitorId = prefs.getString('fieldVisitorId');
    fieldBranchId = prefs.getString('fieldBranchId');
    token = prefs.getString('token');
  }

  // Save manager session
  static Future<void> setManager({
    required String name,
    required String code,
    String? branchId,
    String? jwtToken,
    String? id,
  }) async {
    role = 'manager';
    managerName = name;
    managerCode = code;
    managerBranchId = branchId;
    token = jwtToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', 'manager');
    await prefs.setString('managerName', name);
    await prefs.setString('managerCode', code);
    if (branchId != null) await prefs.setString('managerBranchId', branchId);
    if (jwtToken != null) await prefs.setString('token', jwtToken);
    if (id != null) await prefs.setString('managerId', id);
  }

  static String get displayManagerName => managerName ?? 'Manager';
  static String get displayManagerCode => managerCode ?? 'k001';

  // Save field visitor session
  static Future<void> setFieldVisitor({
    required String name,
    required String code,
    String? phone,
    String? id,
    String? branchId,
    String? jwtToken,
  }) async {
    role = 'field';
    fieldName = name;
    fieldCode = code;
    fieldPhone = phone;
    fieldVisitorId = id;
    fieldBranchId = branchId;
    token = jwtToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', 'field');
    await prefs.setString('fieldName', name);
    await prefs.setString('fieldCode', code);
    if (phone != null) await prefs.setString('fieldPhone', phone);
    if (id != null) await prefs.setString('fieldVisitorId', id);
    if (branchId != null) await prefs.setString('fieldBranchId', branchId);
    if (jwtToken != null) await prefs.setString('token', jwtToken);
  }

  // Clear session data
  static Future<void> clear() async {
    role = null;
    managerName = null;
    managerCode = null;
    managerBranchId = null;
    fieldName = null;
    fieldCode = null;
    fieldPhone = null;
    fieldVisitorId = null;
    fieldBranchId = null;
    token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  static bool get isLoggedIn => role != null && token != null;

  static String get displayFieldName => fieldName ?? 'Field Visitor';
  static String get displayFieldCode => fieldCode ?? 'k001';
  static String get displayFieldPhone => fieldPhone ?? 'N/A';
}
