import 'package:flutter/material.dart';
import 'manager_dashboard.dart';
import 'field_visitor_dashboard.dart';
// manager_dashboard.dart import is already at top
import '../session.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscure = true;
  int _selectedRole = 0; // 0 = Field Visitor, 1 = Manager
  String _selectedRoleStr = 'field'; // 'field' or 'manager'
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background image (subtle) with gradient overlay for contrast
            Positioned.fill(
              child: Image.asset(
                'assets/images/alovera.webp',
                fit: BoxFit.cover,
                color: const Color.fromRGBO(255, 255, 255, 0.6),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x80F6FFF7), Color(0x80EFF9F0)],
                  ),
                ),
              ),
            ),

            // Decorative green watercolor-like circle
            Positioned(
              right: -size.width * 0.15,
              top: -size.width * 0.25,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(76, 175, 80, 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/nf logo.jpg', height: 36),
                        const SizedBox(width: 8),
                        const Text(
                          'NF Farming',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Card container
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _roleTab(0, 'FIELD VISITOR'),
                              const SizedBox(width: 16),
                              _roleTab(1, 'MANAGER'),
                            ],
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'User ID',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _userController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              hintText: 'Enter Your User ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              hintText: 'Enter Your Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      final username = _userController.text
                                          .trim();
                                      final password = _passController.text
                                          .trim();
                                      final role =
                                          _selectedRoleStr; // 'field' or 'manager'

                                      if (username.isEmpty ||
                                          password.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please enter User ID and password.',
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => _isLoading = true);

                                      try {
                                        // DB Login
                                        // Real API Login
                                        final response = await ApiService.login(
                                          username,
                                          password,
                                          role,
                                        );

                                        if (!mounted) return;
                                        setState(() => _isLoading = false);

                                        if (response['success'] == true) {
                                          final data = response['data'];
                                          // Debug: Print received data
                                          debugPrint('Login response data: $data');
                                          
                                          // Proceed with data from API
                                          if (role == 'field') {
                                            await AppSession.setFieldVisitor(
                                              name:
                                                  data['name'] ??
                                                  'Field Visitor',
                                              phone: data['phone'] ?? '',
                                              code: data['code'] ?? data['userId'] ?? 'FV-001',
                                              id:
                                                  data['id']?.toString() ??
                                                  data['_id']?.toString(),
                                              branchId: data['branchId']?.toString(),
                                              jwtToken: data['token'],
                                            );
                                            
                                            // Debug: Print saved session
                                            debugPrint('Session saved - Name: ${AppSession.fieldName}, ID: ${AppSession.fieldVisitorId}');
                                            // ID is now set inside setFieldVisitor, redundant line removed

                                            if (!context.mounted) return;
                                            Navigator.of(
                                              context,
                                            ).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const FieldVisitorDashboard(),
                                              ),
                                            );
                                          } else {
                                            await AppSession.setManager(
                                              name: data['name'] ?? 'Manager',
                                              code: data['code'] ?? 'MGR-001',
                                              branchId: data['branchId']?.toString(),
                                              jwtToken: data['token'],
                                              id: data['id']?.toString() ?? data['_id']?.toString(),
                                            );
                                            
                                            // Debug: Print saved session
                                            debugPrint('Manager session saved - Name: ${AppSession.managerName}');

                                            if (!context.mounted) return;
                                            Navigator.of(
                                              context,
                                            ).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ManagerDashboard(),
                                              ),
                                            );
                                          }
                                        } else {
                                          throw Exception(
                                            response['message'] ??
                                                'Login failed',
                                          );
                                        }
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        setState(() => _isLoading = false);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  _isLoading ? 'Logging in...' : 'Log in',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleTab(int index, String label) {
    final selected = _selectedRole == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRole = index;
        _selectedRoleStr = index == 0 ? 'field' : 'manager';
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(76, 175, 80, 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.green.shade700 : Colors.green.shade400,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
