import 'package:flutter/material.dart';
import 'manager_dashboard.dart';
import 'field_visitor_dashboard.dart';
import '../session.dart';

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
            // Background decorative gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF6FFF7), Color(0xFFEFF9F0)],
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.eco, color: Colors.green, size: 36),
                        SizedBox(width: 8),
                        Text(
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final username = _userController.text.trim();
                                final password = _passController.text.trim();
                                final role = _selectedRoleStr; // 'field' or 'manager'

                                bool valid = false;

                                if (role == 'field') {
                                  if (username == 'field' && password == '1234') {
                                    valid = true;
                                    AppSession.setFieldVisitor(name: 'Ravi Mohan', code: 'k001', phone: '0717000000');
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                                      builder: (_) => const FieldVisitorDashboard(),
                                    ));
                                  }
                                } else {
                                  if (username == 'manager' && password == '1234') {
                                    valid = true;
                                    AppSession.setManager(name: 'Ravi Mohan', code: 'k001');
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                                      builder: (_) => const ManagerDashboard(),
                                    ));
                                  }
                                }

                                if (!valid) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Invalid username or password.'),
                                    backgroundColor: Colors.redAccent,
                                  ));
                                }
                              },
                              icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('Log in', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
          color: selected ? const Color.fromRGBO(76, 175, 80, 0.12) : Colors.transparent,
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
