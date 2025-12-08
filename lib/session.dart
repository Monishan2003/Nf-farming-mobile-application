class AppSession {
  static String? role; // 'manager' or 'field'
  static String? managerName;
  static String? managerCode;
  static String? fieldName;
  static String? fieldCode;
  static String? fieldPhone;
  static String? fieldVisitorId; // Add field visitor ID for API calls

  static void setManager({required String name, required String code}) {
    role = 'manager';
    managerName = name;
    managerCode = code;
  }

  static String get displayManagerName => managerName ?? 'Manager';
  static String get displayManagerCode => managerCode ?? 'k001';

  static void setFieldVisitor({required String name, required String code, String? phone}) {
    role = 'field';
    fieldName = name;
    fieldCode = code;
    fieldPhone = phone;
  }

  static void clear() {
    role = null;
    managerName = null;
    managerCode = null;
    fieldName = null;
    fieldCode = null;
    fieldPhone = null;
    fieldVisitorId = null;
  }

  static String get displayFieldName => fieldName ?? 'Field Visitor';
  static String get displayFieldCode => fieldCode ?? 'k001';
  static String get displayFieldPhone => fieldPhone ?? 'N/A';
}
