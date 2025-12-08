// ==========================================
// FILE: lib/services/api_service.dart
// ==========================================
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator (default)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Uncomment one of these based on your testing device:
  // For iOS simulator use: static const String baseUrl = 'http://localhost:3000/api';
  // For physical device, replace 192.168.x.x with your machine IP:
  // static const String baseUrl = 'http://192.168.x.x:3000/api';

  // Login
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Register Member
  static Future<Map<String, dynamic>> registerMember({
    required String fullName,
    required String mobile,
    required String email,
    required String fieldVisitorId,
    required String companyId,
    String? nic,
    String? dateOfBirth,
    String? gender,
    String? postalAddress,
    String? permanentAddress,
    String? locationCoordinates,
    // Resident details
    String? residentFullName,
    String? residentNic,
    String? residentMobile,
    String? residentDob,
    String? residentOccupation,
    String? residentEducation,
    // Business details
    String? landSize,
    String? activity,
    String? waterFacility,
    String? electricity,
    String? machinery,
    String? quantityPlants,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/members'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'mobile': mobile,
          'email': email,
          'fieldVisitorId': fieldVisitorId,
          'companyId': companyId,
          'nic': nic,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'postalAddress': postalAddress,
          'permanentAddress': permanentAddress,
          'locationCoordinates': locationCoordinates,
          // Resident data
          'residentFullName': residentFullName,
          'residentNic': residentNic,
          'residentMobile': residentMobile,
          'residentDob': residentDob,
          'residentOccupation': residentOccupation,
          'residentEducation': residentEducation,
          // Business data
          'landSize': landSize,
          'activity': activity,
          'waterFacility': waterFacility,
          'electricity': electricity,
          'machinery': machinery,
          'quantityPlants': quantityPlants,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Get Members
  static Future<Map<String, dynamic>> getMembers({
    String? fieldVisitorId,
    String? status,
  }) async {
    try {
      String url = '$baseUrl/members?';
      
      if (fieldVisitorId != null) {
        url += 'fieldVisitorId=$fieldVisitorId&';
      }
      
      if (status != null) {
        url += 'status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch members',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Register Field Visitor
  static Future<Map<String, dynamic>> registerFieldVisitor({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String managerId,
    required String companyId,
    String? address,
    String? nic,
    String? gender,
    String? civilStatus,
    String? dateOfBirth,
    String? applicationFor,
    String? branch,
    String? designation,
    String? epfNo,
    String? bankName,
    String? bankBranch,
    String? accountNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fieldvisitors'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'mobile': mobile,
          'password': password,
          'managerId': managerId,
          'companyId': companyId,
          'address': address,
          'nic': nic,
          'gender': gender,
          'civilStatus': civilStatus,
          'dateOfBirth': dateOfBirth,
          'applicationFor': applicationFor,
          'branch': branch,
          'designation': designation,
          'epfNo': epfNo,
          'bankName': bankName,
          'bankBranch': bankBranch,
          'accountNumber': accountNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Get Field Visitors
  static Future<Map<String, dynamic>> getFieldVisitors({
    String? managerId,
    String? status,
  }) async {
    try {
      String url = '$baseUrl/fieldvisitors?';
      
      if (managerId != null) {
        url += 'managerId=$managerId&';
      }
      
      if (status != null) {
        url += 'status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch field visitors',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Create Transaction
  static Future<Map<String, dynamic>> createTransaction({
    required String transactionType, // 'BUY' or 'SELL'
    required String memberId,
    required String fieldVisitorId,
    required String productId,
    required String companyId,
    required int quantity,
    required String unitType,
    required double unitPrice,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'transactionType': transactionType,
          'memberId': memberId,
          'fieldVisitorId': fieldVisitorId,
          'productId': productId,
          'companyId': companyId,
          'quantity': quantity,
          'unitType': unitType,
          'unitPrice': unitPrice,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Transaction failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Get Transactions
  static Future<Map<String, dynamic>> getTransactions({
    String? fieldVisitorId,
    String? memberId,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$baseUrl/transactions?';
      
      if (fieldVisitorId != null) {
        url += 'fieldVisitorId=$fieldVisitorId&';
      }
      
      if (memberId != null) {
        url += 'memberId=$memberId&';
      }
      
      if (type != null) {
        url += 'type=$type&';
      }
      
      if (startDate != null) {
        url += 'startDate=$startDate&';
      }
      
      if (endDate != null) {
        url += 'endDate=$endDate';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch transactions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}

// ==========================================
// USAGE EXAMPLE: lib/screens/login_page.dart
// ==========================================
/*
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'field_visitor';
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final result = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Login successful
      final userData = result['data'];
      
      // Navigate based on role
      if (_selectedRole == 'field_visitor') {
        Navigator.pushReplacementNamed(context, '/field_dashboard');
      } else if (_selectedRole == 'manager') {
        Navigator.pushReplacementNamed(context, '/manager_dashboard');
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'field_visitor', child: Text('Field Visitor')),
                DropdownMenuItem(value: 'manager', child: Text('Manager')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ==========================================
// USAGE EXAMPLE: Member Registration
// ==========================================
/*
Future<void> registerNewMember() async {
  final result = await ApiService.registerMember(
    fullName: 'John Doe',
    mobile: '+94771234567',
    email: 'john@example.com',
    fieldVisitorId: 'visitor-uuid-here',
    companyId: 'company-001',
    nic: '123456789V',
    postalAddress: 'Jaffna, Sri Lanka',
    // Optional resident details
    residentFullName: 'Jane Doe',
    residentMobile: '+94777654321',
    // Optional business details
    landSize: '5.5',
    waterFacility: 'Yes',
  );

  if (result['success']) {
    print('Member registered: ${result['data']}');
  } else {
    print('Error: ${result['message']}');
  }
}
*/

// ==========================================
// USAGE EXAMPLE: Get Members List
// ==========================================
/*
Future<void> loadMembers() async {
  final result = await ApiService.getMembers(
    fieldVisitorId: 'your-visitor-id',
    status: 'approved',
  );

  if (result['success']) {
    final List members = result['data'];
    print('Found ${members.length} members');
    // Update your UI with the members list
  } else {
    print('Error: ${result['message']}');
  }
}
*/

// ==========================================
// USAGE EXAMPLE: Create Transaction
// ==========================================
/*
Future<void> createBuyTransaction() async {
  final result = await ApiService.createTransaction(
    transactionType: 'BUY',
    memberId: 'member-uuid',
    fieldVisitorId: 'visitor-uuid',
    productId: 'prod-001',
    companyId: 'company-001',
    quantity: 10,
    unitType: 'kg',
    unitPrice: 50.0,
  );

  if (result['success']) {
    print('Transaction created: ${result['data']}');
  } else {
    print('Error: ${result['message']}');
  }
}
*/