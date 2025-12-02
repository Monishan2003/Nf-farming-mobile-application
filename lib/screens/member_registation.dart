// lib/main.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../field_footer.dart';
import 'memberlist.dart';
import 'buy_sell.dart';

// Preview entrypoint removed. Use `lib/main.dart` as the canonical app entrypoint.
// void main() { runApp(const NatureFarmingApp()); }

class NatureFarmingApp extends StatelessWidget {
  const NatureFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nature Farming Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeFormScreen(),
    );
  }
}

// Colors moved to `lib/theme/app_colors.dart` to keep a single source of truth.

// ---------- Helpers ----------
Widget headerBox({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
    decoration: BoxDecoration(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

Widget appHeader() {
  // Developer-supplied local image path (used as file URL here)
  const String localLogoPath = '/mnt/data/bd7d6869-1479-4245-9512-9179aa036e98.png';
  final fileUrl = 'file://$localLogoPath';

  return headerBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Attempt to load local file URL. If it fails, show fallback icon.
            Image.network(
              fileUrl,
              height: 56,
              errorBuilder: (_, __, ___) => Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nature Farming",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Member Registration",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Icon(Icons.person, color: Colors.white, size: 28),
            Icon(Icons.eco, color: Colors.white, size: 28),
            Icon(Icons.calendar_month, color: Colors.white, size: 28),
            Icon(Icons.assignment, color: Colors.white, size: 28),
          ],
        ),
      ],
    ),
  );
}

InputDecoration formDecoration({String? hint, IconData? prefixIcon}) {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.fieldBg,
    hintText: hint,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryGreen) : null,
    hintStyle: const TextStyle(color: AppColors.greyText, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}

void showSuccessDialog(BuildContext ctx, String title, String message, {VoidCallback? onOk}) {
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (c) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              radius: 30,
              child: const Icon(Icons.check, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(c).pop();
                if (onOk != null) onOk();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    },
  );
}

// ---------- 1) Welcome Form Screen ----------
class WelcomeFormScreen extends StatefulWidget {
  const WelcomeFormScreen({super.key});

  @override
  State<WelcomeFormScreen> createState() => _WelcomeFormScreenState();
}

class _WelcomeFormScreenState extends State<WelcomeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _normalizeSriLankanNumber(String input) {
    var s = input.replaceAll(RegExp(r'\s+'), '');
    if (s.startsWith('0')) {
      s = '+94${s.substring(1)}';
    } else if (!s.startsWith('+')) {
      s = '+94$s';
    }
    return s;
  }

  void _goToOtp() {
    if (!_formKey.currentState!.validate()) return;
    final normalized = _normalizeSriLankanNumber(_mobileController.text.trim());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          mobileNumber: normalized,
          onOtpVerifiedNavigate: (mergedData) {
            // after OTP success or Skip -> open residents screen with merged data
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ResidentsScreen(registrationData: mergedData)),
            );
          },
          prefillData: collectData(), // pass collected data so later forms have it
        ),
      ),
    );
  }

  Map<String, dynamic> collectData() {
    return {
      'fullName': _fullNameController.text.trim(),
      'nic': _nicController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'email': _emailController.text.trim(),
      'location': _locationController.text.trim(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appHeader(),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                    SizedBox(height: 6),
                    Text("Let's get started with your personal information", style: TextStyle(fontSize: 14, color: AppColors.darkText)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Full Name *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: formDecoration(hint: 'Enter your full name', prefixIcon: Icons.person),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // NIC
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('N.I.C Number *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nicController,
                          decoration: formDecoration(hint: '123456789V', prefixIcon: Icons.badge),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter NIC' : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Mobile
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mobile number *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\+\s]'))],
                          decoration: formDecoration(hint: '+94 77 123 4567', prefixIcon: Icons.phone),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter mobile number';
                            final s = v.replaceAll(RegExp(r'\s+'), '');
                            if (!(s.startsWith('+94') || s.startsWith('07') || s.startsWith('7'))) {
                              return 'Enter valid Sri Lanka number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email address *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: formDecoration(hint: 'name@example.com', prefixIcon: Icons.email),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Please enter email';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter valid email';
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Complete location *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _locationController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: formDecoration(hint: 'Enter full address', prefixIcon: Icons.location_on),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter location' : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Text(
                      "✔ All fields marked with * are required to complete your registration",
                      style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _goToOtp,
                        child: const Text("Next →", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

// ---------- 2) OTP Screen (with Skip) ----------
class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final Function(Map<String, dynamic> mergedData) onOtpVerifiedNavigate;
  final Map<String, dynamic> prefillData;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
    required this.onOtpVerifiedNavigate,
    required this.prefillData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int otpTimeoutSeconds = 120;
  Timer? _timer;
  int _remaining = otpTimeoutSeconds;

  String _generatedOtp = '';
  final TextEditingController _otpController = TextEditingController();
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _sendOtp();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remaining = otpTimeoutSeconds;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        setState(() {
          _remaining = 0;
          _canResend = true;
        });
        t.cancel();
      } else {
        setState(() {
          _remaining -= 1;
        });
      }
    });
  }

  void _sendOtp() {
    final rnd = Random.secure();
    final otp = 100000 + rnd.nextInt(900000);
    _generatedOtp = otp.toString();
    // Simulate sending. Print to console so you can test.
    // ignore: avoid_print
    print('Simulated OTP sent to ${widget.mobileNumber}: $_generatedOtp');
    _otpController.text = '';
  }

  void _resendOtp() {
    if (!_canResend) return;
    _sendOtp();
    _startTimer();
  }

  void _verifyOtp() async {
    setState(() {
      _isVerifying = true;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    if (_otpController.text.trim() == _generatedOtp) {
      // success popup then navigate with merged data
      final merged = {...widget.prefillData, 'mobile_normalized': widget.mobileNumber};
      showSuccessDialog(context, 'Success!', 'Your mobile number was successfully verified.', onOk: () {
        widget.onOtpVerifiedNavigate(merged);
      });
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: const Text('Invalid OTP'),
            content: const Text('The OTP you entered is incorrect. Please try again or resend.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK'))
            ],
          );
        },
      );
    }
    setState(() {
      _isVerifying = false;
    });
  }

  void _skipOtp() {
    // Skip OTP - still add normalized mobile into data and continue
    final merged = {...widget.prefillData, 'mobile_normalized': widget.mobileNumber, 'otp_skipped': true};
    widget.onOtpVerifiedNavigate(merged);
  }

  String _formatRemaining() {
    final mm = (_remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_remaining % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              appHeader(),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('OTP Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Mobile number', style: TextStyle(color: AppColors.darkText)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.mobileNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                            onPressed: () {
                              if (_canResend) _resendOtp();
                            },
                            child: const Text('Send OTP'),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Enter OTP sent to your mobile'),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: formDecoration(hint: 'Enter 6-digit OTP', prefixIcon: Icons.lock),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time remaining: ${_formatRemaining()}'),
                        _canResend
                            ? TextButton(onPressed: _resendOtp, child: const Text('Resend OTP'))
                            : TextButton(onPressed: () {}, child: const Text('Resend (disabled)')),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonGreen),
                            child: _isVerifying ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Verify OTP'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Skip button for no-SMS environments
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _skipOtp,
                        child: const Text('Skip OTP (continue without verification)', style: TextStyle(decoration: TextDecoration.underline)),
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('< Back'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

// ---------- 3) Residents Form ----------
class ResidentsScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  const ResidentsScreen({super.key, required this.registrationData});

  @override
  State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController nic = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController occupation = TextEditingController();
  final TextEditingController education = TextEditingController();

  @override
  void initState() {
    super.initState();
    // prefill resident fullName with main fullName if present
    fullName.text = widget.registrationData['fullName'] ?? '';
    mobile.text = widget.registrationData['mobile'] ?? widget.registrationData['mobile_normalized'] ?? '';
  }

  @override
  void dispose() {
    fullName.dispose();
    nic.dispose();
    mobile.dispose();
    dob.dispose();
    occupation.dispose();
    education.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> residentsData = {
      'resident_fullName': fullName.text.trim(),
      'resident_nic': nic.text.trim(),
      'resident_mobile': mobile.text.trim(),
      'resident_dob': dob.text.trim(),
      'resident_occupation': occupation.text.trim(),
      'resident_education': education.text.trim(),
    };

    final merged = {...widget.registrationData, ...residentsData};

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessDetailsScreen(registrationData: merged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Residents'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              appHeader(),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2)),
                ]),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Align(alignment: Alignment.centerLeft, child: Text('Residents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),

                      TextFormField(controller: fullName, decoration: formDecoration(hint: 'Full Name', prefixIcon: Icons.person), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 10),

                      TextFormField(controller: nic, decoration: formDecoration(hint: 'N.I.C Number', prefixIcon: Icons.badge), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 10),

                      TextFormField(controller: mobile, decoration: formDecoration(hint: '+94 77 123 4567', prefixIcon: Icons.phone), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 10),

                      TextFormField(controller: dob, decoration: formDecoration(hint: 'Date of birth', prefixIcon: Icons.calendar_month), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 10),

                      TextFormField(controller: occupation, decoration: formDecoration(hint: 'Occupation', prefixIcon: Icons.work)),
                      const SizedBox(height: 10),

                      TextFormField(controller: education, decoration: formDecoration(hint: 'Education Level', prefixIcon: Icons.school)),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryGreen),
                              child: const Text('< Back'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonGreen),
                              child: const Text('Next →'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

// ---------- 4) Business Details ----------
class BusinessDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  const BusinessDetailsScreen({super.key, required this.registrationData});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController landSize = TextEditingController();
  final TextEditingController activity = TextEditingController();
  final TextEditingController waterFacility = TextEditingController();
  final TextEditingController electricity = TextEditingController();
  final TextEditingController machinery = TextEditingController();
  final TextEditingController quantityPlants = TextEditingController();

  @override
  void dispose() {
    landSize.dispose();
    activity.dispose();
    waterFacility.dispose();
    electricity.dispose();
    machinery.dispose();
    quantityPlants.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    final businessData = {
      'landSize': landSize.text.trim(),
      'activity': activity.text.trim(),
      'waterFacility': waterFacility.text.trim(),
      'electricity': electricity.text.trim(),
      'machinery': machinery.text.trim(),
      'quantityPlants': quantityPlants.text.trim(),
    };

    final merged = {...widget.registrationData, ...businessData};

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinalStepScreen(registrationData: merged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              appHeader(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2)),
                ]),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Align(alignment: Alignment.centerLeft, child: Text('Business Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      TextFormField(controller: landSize, decoration: formDecoration(hint: 'Total land scale', prefixIcon: Icons.landscape)),
                      const SizedBox(height: 10),

                      TextFormField(controller: activity, decoration: formDecoration(hint: 'Allocated land size / Activity', prefixIcon: Icons.work)),
                      const SizedBox(height: 10),

                      TextFormField(controller: waterFacility, decoration: formDecoration(hint: 'Water facility', prefixIcon: Icons.water)),
                      const SizedBox(height: 10),

                      TextFormField(controller: electricity, decoration: formDecoration(hint: 'Electricity facility', prefixIcon: Icons.electrical_services)),
                      const SizedBox(height: 10),

                      TextFormField(controller: machinery, decoration: formDecoration(hint: 'Machinery/Equipment', prefixIcon: Icons.precision_manufacturing)),
                      const SizedBox(height: 10),

                      TextFormField(controller: quantityPlants, decoration: formDecoration(hint: 'Quantity of plants', prefixIcon: Icons.grass)),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryGreen),
                              child: const Text('< Back'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonGreen),
                              child: const Text('Next →'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

// ---------- 5) Final Step - Review & Confirm ----------
class FinalStepScreen extends StatelessWidget {
  final Map<String, dynamic> registrationData;
  const FinalStepScreen({super.key, required this.registrationData});

  void _confirm(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(18),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 48, color: AppColors.primaryGreen),
              const SizedBox(height: 12),
              const Text('Final step', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('By submitting, you agree to comply with all membership requirements and company policies. All information will be verified.', textAlign: TextAlign.center),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Back')),
                  ),
                  const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonGreen),
                          onPressed: () {
                            // Build a Farmer entry and add to global store so member lists update automatically
                            final id = DateTime.now().millisecondsSinceEpoch.toString();
                            final name = (registrationData['fullName'] ?? registrationData['resident_fullName'] ?? '').toString();
                            final mobile = (registrationData['mobile'] ?? registrationData['resident_mobile'] ?? '').toString();
                            final address = (registrationData['location'] ?? '').toString();
                            final nic = (registrationData['nic'] ?? registrationData['resident_nic'] ?? '').toString();
                            final billNo = 'B${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                            try {
                              final f = Farmer(id: id, name: name.isEmpty ? 'Unnamed' : name, phone: '', address: address, mobile: mobile, nic: nic, billNumber: billNo);
                              farmerStore.addFarmer(f);
                            } catch (_) {}

                            Navigator.of(c).pop();
                            showSuccessDialog(ctx, 'Successfully Registered', 'Your request is registered and added to members.', onOk: () {
                              Navigator.of(ctx).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MambersList()), (r) => false);
                            });
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSummaryRows() {
    final entries = registrationData.entries.toList();
    return entries
        .map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  Expanded(flex: 5, child: Text((e.value ?? '').toString())),
                ],
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final step'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              appHeader(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2)),
                ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Please confirm all details below:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._buildSummaryRows(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('< Back')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(onPressed: () => _confirm(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonGreen), child: const Text('Confirm')),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

// ---------- 6) Registration Complete ----------
class RegistrationCompleteScreen extends StatelessWidget {
  const RegistrationCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 44, backgroundColor: AppColors.primaryGreen, child: const Icon(Icons.check, color: Colors.white, size: 44)),
            const SizedBox(height: 18),
            const Text('Successfully Registered', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text('Your request is registered and currently in process. We will notify you...', textAlign: TextAlign.center),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonGreen),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeFormScreen()), (r) => false);
              },
              child: const Text('OK'),
            )
          ]),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}