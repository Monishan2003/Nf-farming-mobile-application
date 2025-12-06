// main.dart
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../notifications.dart';
import '../app_colors.dart';
import '../manager_footer.dart';
import '../visitor_store.dart';
import 'field_visitors_list.dart';

// Preview entrypoint removed. Use `lib/main.dart` as the canonical app entrypoint.
// void main() { runApp(const NatureFarmingApp()); }

// Color constants are centralized in `lib/theme/app_colors.dart`.

/// Single in-memory model for all form data
class RegistrationModel {
  // Personal
  String applicationFor = '';
  String branch = '';
  String fullName = '';
  String postalAddress = '';
  String permanentAddress = '';
  String mobile = '';
  String homePhone = '';
  String email = '';
  String gender = 'Male';
  String civilStatus = 'Single';
  DateTime? dob;
  String nic = '';

  // Education - simple lists
  List<Map<String, String>> olevel = List.generate(9, (i) => {'sub': 'Subject ${i + 1}', 'grade': ''});
  List<Map<String, String>> alevel = List.generate(4, (i) => {'sub': 'Subject ${i + 1}', 'grade': ''});
  List<String> otherQualifications = List.generate(6, (i) => '');

  // Work Experience
  List<Map<String, String>> prevExp = List.generate(5, (i) => {'company': '', 'designation': '', 'period': ''});
  String presentEmployer = '';
  String presentAddress = '';
  String designation = '';
  String epfNo = '';

  // References
  List<Map<String, String>> references = List.generate(2, (i) => {'name': '', 'address': '', 'occupation': '', 'contact': ''});

  // Additional
  List<String> activities = List.generate(7, (i) => '');
  bool convicted = false;
  String bank = '';
  String branchName = '';
  String accountNo = '';

  // Declaration
  String signature = '';
  DateTime? signDate;
}

class NatureFarmingApp extends StatelessWidget {
  const NatureFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nature Farming - Field Visitor Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.lightGreen,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const RegistrationScreen(),
    );
  }
}

/// Top header widget (logo + title)
class TopHeader extends StatelessWidget {
  final int stepIndex;
  final bool showProgress;
  const TopHeader({super.key, this.stepIndex = 0, this.showProgress = true});

  Widget _circleIcon(IconData icon, bool active) {
    // Compact icon circle: smaller padding and icon size so all icons fit horizontally
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? AppColors.iconGreen : AppColors.cardBg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: active ? Colors.white : AppColors.greyText, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.person,
      Icons.school,
      Icons.work,
      Icons.group,
      Icons.check_box,
      Icons.send,
    ];
    return SafeArea(
      top: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: ClipOval(child: Image.asset('assets/images/nf logo.jpg', fit: BoxFit.cover)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Nature Farming', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Field Visitors Registration', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // icon row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(icons.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _circleIcon(icons[i], i <= stepIndex),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // progress bar (can be hidden)
          if (showProgress)
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: LinearProgressIndicator(
                value: (stepIndex + 1) / icons.length,
                minHeight: 6,
                backgroundColor: AppColors.cardBg,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            const SizedBox(height: 6),
        ],
      ),
    ),
  ),
);
  }
}

/// Reusable input field
class LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;
  const LabeledInput({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.greyText)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderGrey)),
        ),
      ),
    ]);
  }
}

// --- Validation helpers for Field Visitor registration ---
bool _isValidSriLankaMobileField(String input) {
  if (input.trim().isEmpty) return false;
  // Remove all non-digit characters so we can validate the numeric form
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  // Accept formats:
  // - 9 digits starting with 7 (e.g. 772345678)
  // - 10 digits starting with 07 (e.g. 0772345678)
  // - 11 digits starting with 94 (e.g. 94772345678) -> from +94
  // - 13 digits starting with 0094 (e.g. 0094772345678)
  if (digits.length == 9 && digits.startsWith('7')) return true;
  if (digits.length == 10 && digits.startsWith('07')) return true;
  if (digits.length == 11 && digits.startsWith('94')) return true;
  if (digits.length == 13 && digits.startsWith('0094')) return true;
  return false;
}

bool _isValidNicField(String input) {
  final v = input.trim();
  if (v.isEmpty) return false;
  try {
     if (RegExp(r'^\d{9}[VXvx]$').hasMatch(v) || RegExp(r'^\d{12}$').hasMatch(v)) return true;
  } catch (_) {}
  return false;
}

// Replaced earlier small radio helper with modern matching widgets in-place.

/// Main registration screen with step navigation
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final RegistrationModel model = RegistrationModel();

  int currentStep = 0;

  // controllers for personal info
  final tcApplicationFor = TextEditingController();
  final tcBranch = TextEditingController();
  final tcFullName = TextEditingController();
  final tcPostal = TextEditingController();
  final tcPermanent = TextEditingController();
  final tcMobile = TextEditingController();
  final tcHome = TextEditingController();
  final tcEmail = TextEditingController();
  final tcNIC = TextEditingController();

  // OTP overlay state and controllers
  bool showOtpOverlay = false;
  int otpStage = 0; // 0 = mobile, 1 = email
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<TextEditingController> emailOtpControllers = List.generate(6, (_) => TextEditingController());

  // generated OTP storage for verification
  String generatedMobileOtp = '';
  String generatedEmailOtp = '';

  // declaration
  bool _acceptedDeclaration = false;


  PageController pageController = PageController();

  @override
  void dispose() {
    tcApplicationFor.dispose();
    tcBranch.dispose();
    tcFullName.dispose();
    tcPostal.dispose();
    tcPermanent.dispose();
    tcMobile.dispose();
    tcHome.dispose();
    tcEmail.dispose();
    tcNIC.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var c in emailOtpControllers) {
      c.dispose();
    }
    pageController.dispose();
    super.dispose();
  }

  void goToStep(int step) {
    setState(() {
      currentStep = step.clamp(0, 4);
    });
    pageController.animateToPage(currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _savePersonalToModel() {
    model.applicationFor = tcApplicationFor.text;
    model.branch = tcBranch.text;
    model.fullName = tcFullName.text;
    model.postalAddress = tcPostal.text;
    model.permanentAddress = tcPermanent.text;
    model.homePhone = tcHome.text;
    model.nic = tcNIC.text;
  }

  // validate basic personal info
  bool _validatePersonal() {
    _savePersonalToModel();
    if (model.fullName.trim().isEmpty) {
      _showSnack('Enter full name');
      return false;
    }

    // Mobile is collected in the OTP verification overlay; allow empty here
    // so the user can enter the mobile number in the overlay before sending OTP.
    final mobileVal = tcMobile.text.trim();
    if (mobileVal.isNotEmpty && !_isValidSriLankaMobileField(mobileVal)) {
      _showSnack('Enter valid Sri Lanka mobile number');
      return false;
    }

    // NIC validation (required)
    final nicVal = tcNIC.text.trim();
    if (nicVal.isEmpty) {
      _showSnack('Enter NIC number');
      return false;
    }
    if (!_isValidNicField(nicVal)) {
      _showSnack('Enter valid NIC (9 digits + V/X or 12 digits)');
      return false;
    }

    // Email optional but if provided should be valid
    final emailVal = tcEmail.text.trim();
    if (emailVal.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailVal)) {
      _showSnack('Enter valid email address');
      return false;
    }

    return true;
  }

  // OTP helpers (simulated)
  void _sendOtp(String forWhat) {
    // Generate new 6-digit OTP
    final otp = (100000 + Random().nextInt(900000)).toString();

    if (otpStage == 0) {
      generatedMobileOtp = otp;
      for (var c in otpControllers) {
        c.text = '';
      }
    } else {
      generatedEmailOtp = otp;
      for (var c in emailOtpControllers) {
        c.text = '';
      }
    }

    _showSnack('OTP sent to $forWhat: $otp (simulated)'); // show for testing
    // log for debugging
    // ignore: avoid_print
    print('Generated OTP: $otp');
  }

  bool _verifyOtp() {
    final code = otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showSnack('Enter full mobile OTP');
      return false;
    }
    if (code != generatedMobileOtp) {
      _showSnack('Wrong mobile OTP');
      return false;
    }
    return true;
  }

  bool _verifyEmailOtp() {
    final code = emailOtpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showSnack('Enter full email OTP');
      return false;
    }
    if (code != generatedEmailOtp) {
      _showSnack('Wrong email OTP');
      return false;
    }
    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Shared styled "Previous" button to match new design (rounded pill, light green background, grey text)
  Widget _previousButton(VoidCallback? onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.lightGreen,
        side: const BorderSide(color: AppColors.borderGrey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      child: Text('<< Previous', style: TextStyle(color: AppColors.greyText)),
    );
  }

  // OTP functionality removed per request.

  void _showSuccessPopup(String title, String subtitle, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryGreen),
                child: const Center(child: Icon(Icons.card_giftcard, color: Colors.white, size: 44)),
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: 84,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onOk != null) onOk();
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication({VoidCallback? onOkOverride}) async {
    // For demo: do minimal validation and show success
    model.signature = _acceptedDeclaration ? 'Accepted' : '';
    model.signDate ??= DateTime.now();
    // Add to central visitor store so dashboard updates live
    try {
      // create a simple visitor entry from the model
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final name = tcFullName.text.trim().isNotEmpty ? tcFullName.text.trim() : 'Unnamed';
      final code = 'VF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      final address = tcPostal.text.trim().isNotEmpty ? tcPostal.text.trim() : (tcPermanent.text.trim().isNotEmpty ? tcPermanent.text.trim() : '');
      visitorStore.addVisitor(Visitor(id: id, name: name, code: code, address: address));
      // Build registration PDF and add a notification with the PDF attached
      try {
        final pdfBytes = await _buildRegistrationPdfBytes();
          notificationStore.addNotification(NotificationEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Registration Complete: $name',
          body: 'Field visitor registration completed. Tap to view/download PDF.',
          date: DateTime.now(),
          pdfData: pdfBytes,
          pdfFileName: 'Registration_${name.replaceAll(' ', '_')}_$id.pdf',
        ));
      } catch (e) {
        // ignore pdf attach errors but log
        // ignore: avoid_print
        print('Failed to attach registration PDF: $e');
      }
    } catch (_) {}
    _showSuccessPopup('Successfully Registered', 'Your application has been submitted successfully.', onOk: () {
      if (onOkOverride != null) {
        onOkOverride();
        return;
      }
      // reset or go to first
      setState(() {
        goToStep(0);
        pageController.jumpToPage(0);
      });
    });
  }

  // UI for Education DataTable-like display
  Widget _educationTable(String title, List<Map<String, String>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.borderGrey), color: Colors.white, borderRadius: BorderRadius.circular(6)),
          child: Column(
                    children: List.generate(rows.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    // Subject name shown as an editable input with the original subject as hint
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onChanged: (v) => rows[i]['sub'] = v,
                        decoration: InputDecoration(
                          hintText: rows[i]['sub'] ?? 'Subject ${i + 1}',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderGrey)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (v) => rows[i]['grade'] = v,
                        decoration: InputDecoration(
                          hintText: 'Grade',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderGrey)),
                          filled: true,
                          fillColor: AppColors.veryLight,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Reference table UI
  Widget _referencesTable() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: AppColors.borderGrey)),
          child: Column(
            children: List.generate(model.references.length, (i) {
              final ref = model.references[i];
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Referee ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                        decoration: InputDecoration(labelText: 'Name', hintText: 'Enter name', border: const OutlineInputBorder(), isDense: true),
                    onChanged: (v) => ref['name'] = v,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(labelText: 'Address', hintText: 'Enter address', border: const OutlineInputBorder(), isDense: true),
                    onChanged: (v) => ref['address'] = v,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Occupation', hintText: 'Enter occupation', border: const OutlineInputBorder(), isDense: true),
                        onChanged: (v) => ref['occupation'] = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Contact No', hintText: 'Enter contact number', border: const OutlineInputBorder(), isDense: true),
                        keyboardType: TextInputType.phone,
                        onChanged: (v) => ref['contact'] = v,
                      ),
                    ),
                  ]),
                ]),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Additional info UI
  Widget _additionalInfo() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Extra-Curricular Activities', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: List.generate(model.activities.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                decoration: InputDecoration(hintText: 'Activity ${i + 1}', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                onChanged: (v) => model.activities[i] = v,
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 8),
      const Text('Criminal Record', style: TextStyle(fontWeight: FontWeight.bold)),
      Row(
        children: [
          ChoiceChip(
            selected: model.convicted == true,
            label: const Text('Yes'),
            onSelected: (_) => setState(() => model.convicted = true),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            selected: model.convicted == false,
            label: const Text('No'),
            onSelected: (_) => setState(() => model.convicted = false),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text('Bank Details of Salary', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextField(
        decoration: InputDecoration(labelText: 'Bank Name', hintText: 'Enter bank name', border: const OutlineInputBorder(), filled: true, fillColor: Colors.white),
        onChanged: (v) => model.bank = v,
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(labelText: 'Branch', hintText: 'Enter branch name', border: const OutlineInputBorder(), filled: true, fillColor: Colors.white),
        onChanged: (v) => model.branchName = v,
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(labelText: 'Account No', hintText: 'Enter account number', border: const OutlineInputBorder(), filled: true, fillColor: Colors.white),
        keyboardType: TextInputType.number,
        onChanged: (v) => model.accountNo = v,
      ),
    ]);
  }

  // Review & Declaration view
  Widget _reviewAndSubmit() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Declaration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              'I agree to any salary / allowance being remitted to Bank A/C. I hereby certify that particulars furnished by me in this application are true and accurate. If any particulars are found incorrect I am liable to be disqualified.'),
          const SizedBox(height: 10),
          CheckboxListTile(
            value: _acceptedDeclaration,
            onChanged: (v) => setState(() => _acceptedDeclaration = v ?? false),
            title: const Text('I agree to the declaration above'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Date:'),
            const SizedBox(width: 8),
            Text(model.signDate == null ? '-' : model.signDate!.toLocal().toString().split(' ').first),
            const Spacer(),
            ElevatedButton(
              onPressed: () => setState(() => model.signDate = DateTime.now()),
              child: const Text('Set Date'),
            )
          ])
        ]),
      ),
      const SizedBox(height: 12),
    ]);
  }

  // Screen content builder
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _personalInfoScreen();
      case 1:
        return _educationWorkScreen();
      case 2:
        return _workExperienceScreen();
      case 3:
        return _referencesAndAdditionalScreen();
      case 4:
        return _reviewScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _personalInfoScreen() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 6),
        const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LabeledInput(label: 'Application for the post', controller: tcApplicationFor, hint: 'Enter application for the post'),
        const SizedBox(height: 10),
        LabeledInput(label: 'Branch', controller: tcBranch, hint: 'Enter branch'),
        const SizedBox(height: 10),
        LabeledInput(label: 'Full Name*', controller: tcFullName, hint: 'Enter full name'),
        const SizedBox(height: 10),
        LabeledInput(label: 'Postal Address*', controller: tcPostal, maxLines: 2, hint: 'Enter postal address'),
        const SizedBox(height: 10),
        LabeledInput(label: 'Permanent Address', controller: tcPermanent, maxLines: 2, hint: 'Enter permanent address'),
        const SizedBox(height: 10),
        // Mobile and Email are collected in the OTP verification overlay
        LabeledInput(label: 'Home phone', controller: tcHome, keyboardType: TextInputType.phone, hint: 'Enter home phone'),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Gender:'),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: model.gender,
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => model.gender = v ?? 'Male'),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Civil status:'),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: model.civilStatus,
            items: const [DropdownMenuItem(value: 'Single', child: Text('Single')), DropdownMenuItem(value: 'Married', child: Text('Married')), DropdownMenuItem(value: 'Divorced', child: Text('Divorced'))],
            onChanged: (v) => setState(() => model.civilStatus = v ?? 'Single'),
          )
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: LabeledInput(label: 'Date of Birth', controller: TextEditingController(text: model.dob == null ? '' : model.dob!.toLocal().toString().split(' ').first), hint: 'YYYY-MM-DD')),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () async {
            final d = await showDatePicker(context: context, initialDate: DateTime(1990), firstDate: DateTime(1950), lastDate: DateTime.now());
            if (d != null) setState(() => model.dob = d);
          }, child: const Text('Pick', style: TextStyle(color: Colors.white)))
        ]),
        const SizedBox(height: 8),
        LabeledInput(label: 'NIC no', controller: tcNIC, hint: 'Enter NIC number'),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _previousButton(currentStep > 0 ? () => goToStep(currentStep - 1) : null),
          ElevatedButton(
            onPressed: () {
              if (_validatePersonal()) {
                // Save controllers to model and show OTP overlay (mobile -> email)
                _savePersonalToModel();
                otpStage = 0;
                showOtpOverlay = true;
                // let user enter mobile/email in overlay and press Send OTP there
                setState(() {});
              }
            },
            child: const Text('Next', style: TextStyle(color: Colors.white)),
          )
        ])
      ]),
    );
  }

  // OTP screens removed — flow now goes Personal -> Education -> References -> Review -> Submit

  Widget _educationWorkScreen() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        const Text('Educational Qualifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _educationTable('G.C.E Ordinary Level', model.olevel),
        const SizedBox(height: 10),
        _educationTable('G.C.E Advanced Level', model.alevel),
        const SizedBox(height: 10),
        const Text('Other Qualifications', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Column(children: List.generate(model.otherQualifications.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                decoration: InputDecoration(hintText: 'Qualification ${i + 1}', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
              onChanged: (v) => model.otherQualifications[i] = v,
            ),
          );
        })),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _previousButton(() => goToStep(0)),
          ElevatedButton(onPressed: () => goToStep(2), child: const Text('Next', style: TextStyle(color: Colors.white))),
        ])
      ]),
    );
  }

  // Separate Work Experience screen (moved out from education screen)
  Widget _workExperienceScreen() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        const Text('Work Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          decoration: const InputDecoration(labelText: 'Present Working Details (Name & Address)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
          onChanged: (v) => model.presentEmployer = v,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(decoration: InputDecoration(labelText: 'Designation', hintText: 'Enter designation', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), onChanged: (v) => model.designation = v)),
          const SizedBox(width: 8),
          Expanded(child: TextField(decoration: InputDecoration(labelText: 'EPF No', hintText: 'Enter EPF number', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), onChanged: (v) => model.epfNo = v)),
        ]),
        const SizedBox(height: 8),
        const Text('Previous Experience (up to 5)'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(8)),
          child: Column(children: List.generate(model.prevExp.length, (i) {
            final e = model.prevExp[i];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Company', hintText: 'Enter company name', border: const OutlineInputBorder(), isDense: true), onChanged: (v) => e['company'] = v)),
                const SizedBox(width: 8),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Designation', hintText: 'Enter designation', border: const OutlineInputBorder(), isDense: true), onChanged: (v) => e['designation'] = v)),
                const SizedBox(width: 8),
                SizedBox(width: 90, child: TextField(decoration: InputDecoration(labelText: 'Period', hintText: 'Enter period', border: const OutlineInputBorder(), isDense: true), onChanged: (v) => e['period'] = v)),
              ]),
            );
          })),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _previousButton(() => goToStep(1)),
          ElevatedButton(onPressed: () => goToStep(3), child: const Text('Next', style: TextStyle(color: Colors.white))),
        ])
      ]),
    );
  }

  Widget _referencesAndAdditionalScreen() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('References', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _referencesTable(),
        const SizedBox(height: 12),
        const Text('Additional Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _additionalInfo(),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _previousButton(() => goToStep(2)),
          ElevatedButton(onPressed: () => goToStep(4), child: const Text('Next', style: TextStyle(color: Colors.white))),
        ])
      ]),
    );
  }

  Widget _reviewScreen() {
    // show summary items
    return Padding(
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Review & Submit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderGrey), borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Summary rows generated from registration data
              ..._buildSummaryRows(),
              const SizedBox(height: 12),
              const Text('References:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...model.references.map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('${r['name']} - ${r['contact']}'))),
            ]),
          ),
          const SizedBox(height: 12),
          _reviewAndSubmit(),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _previousButton(() => goToStep(3)),
            Row(children: [
              ElevatedButton(
                onPressed: _exportSummaryPdf,
                child: const Text('Export PDF'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  // Require declaration acceptance before submit
                  if (!_acceptedDeclaration) {
                    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
                      title: const Text('Declaration Required'),
                      content: const Text('You must accept the declaration before submitting the application.'),
                      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                    ));
                    return;
                  }

                  // show confirmation dialog before final submit
                  final ok = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Submission'),
                      content: const Text('Are you sure you want to submit this application? Please review the details before confirming.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
                      ],
                    ),
                  );

                  if (ok == true) {
                    _submitApplication(onOkOverride: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const FieldVisitorsListScreen()));
                    });
                  }
                },
                child: const Text('Confirm & Submit'),
              ),
            ]),
          ])
        ]),
      ),
    );
  }

  // Collect key registration fields into a map for summary display
  Map<String, String> _collectRegistrationData() {
    final Map<String, String> data = {};
    data['Application For'] = tcApplicationFor.text.trim();
    data['Branch'] = tcBranch.text.trim();
    data['Full Name'] = tcFullName.text.trim();
    data['Postal Address'] = tcPostal.text.trim();
    data['Permanent Address'] = tcPermanent.text.trim();
    data['Mobile'] = tcMobile.text.trim();
    data['Home Phone'] = tcHome.text.trim();
    data['Email'] = tcEmail.text.trim();
    data['NIC'] = tcNIC.text.trim();
    data['Gender'] = model.gender;
    data['Civil Status'] = model.civilStatus;
    data['Date of Birth'] = model.dob == null ? '' : model.dob!.toLocal().toString().split(' ').first;
    data['EPF No'] = model.epfNo;
    data['Present Employer'] = model.presentEmployer;
    data['Designation'] = model.designation;
    // Education summaries
    final ol = model.olevel.where((r) => (r['sub']?.trim().isNotEmpty ?? false) || (r['grade']?.trim().isNotEmpty ?? false)).map((r) => '${r['sub'] ?? ''}${(r['grade'] ?? '').isNotEmpty ? ' (${r['grade']})' : ''}').toList();
    final al = model.alevel.where((r) => (r['sub']?.trim().isNotEmpty ?? false) || (r['grade']?.trim().isNotEmpty ?? false)).map((r) => '${r['sub'] ?? ''}${(r['grade'] ?? '').isNotEmpty ? ' (${r['grade']})' : ''}').toList();
    if (ol.isNotEmpty) data['O/L Subjects'] = ol.join(', ');
    if (al.isNotEmpty) data['A/L Subjects'] = al.join(', ');
    final others = model.otherQualifications.where((s) => s.trim().isNotEmpty).toList();
    if (others.isNotEmpty) data['Other Qualifications'] = others.join(', ');

    // Previous experience
    final prev = model.prevExp.where((e) => (e['company']?.trim().isNotEmpty ?? false) || (e['designation']?.trim().isNotEmpty ?? false)).map((e) => '${e['company'] ?? ''}${(e['designation'] ?? '').isNotEmpty ? ' - ${e['designation']}' : ''}${(e['period'] ?? '').isNotEmpty ? ' (${e['period']})' : ''}').toList();
    if (prev.isNotEmpty) data['Previous Experience'] = prev.join(' ; ');

    // References
    final refs = model.references.where((r) => (r['name']?.trim().isNotEmpty ?? false)).map((r) => '${r['name'] ?? ''}${(r['contact'] ?? '').isNotEmpty ? ' (${r['contact']})' : ''}').toList();
    if (refs.isNotEmpty) data['References'] = refs.join(' ; ');

    // Activities
    final acts = model.activities.where((s) => s.trim().isNotEmpty).toList();
    if (acts.isNotEmpty) data['Activities'] = acts.join(', ');

    // Bank / additional
    data['Convicted'] = model.convicted ? 'Yes' : 'No';
    if (model.bank.isNotEmpty) data['Bank'] = model.bank;
    if (model.branchName.isNotEmpty) data['Bank Branch'] = model.branchName;
    if (model.accountNo.isNotEmpty) data['Account No'] = model.accountNo;

    // Declaration
    data['Declaration Accepted'] = _acceptedDeclaration ? 'Yes' : 'No';
    data['Signed On'] = model.signDate == null ? '' : model.signDate!.toLocal().toString().split(' ').first;

    return data;
  }

  // Build summary rows from collected registration data
  List<Widget> _buildSummaryRows() {
    final registrationData = _collectRegistrationData();
    final entries = registrationData.entries.toList();
    return entries
        .map((e) {
          // Render list-like keys as multi-line blocks
          const listKeys = {'O/L Subjects', 'A/L Subjects', 'Other Qualifications', 'Previous Experience', 'References', 'Activities'};
          final isListKey = listKeys.contains(e.key);
          Widget valueWidget;
            if (isListKey && e.value.toString().trim().isNotEmpty) {
            // split by separators used in _collectRegistrationData
            final parts = e.value.toString().split(RegExp(r', | ; '));
            valueWidget = Column(crossAxisAlignment: CrossAxisAlignment.start, children: parts.map((p) => Text('- ${p.trim()}')).toList());
          } else {
            valueWidget = Text(e.value.toString());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              Expanded(flex: 5, child: valueWidget),
            ]),
          );
        }).toList();
  }

  // Export current summary to PDF and open print/share dialog
  Future<void> _exportSummaryPdf() async {
    try {
      final bytes = await _buildRegistrationPdfBytes();
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      _showSnack('Failed to generate PDF: $e');
    }
  }

  Future<Uint8List> _buildRegistrationPdfBytes() async {
    final doc = pw.Document();
    final registrationData = _collectRegistrationData();
    final entries = registrationData.entries.toList();

    // Styles
    final keyStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final valStyle = pw.TextStyle(fontSize: 10);

    doc.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(24), build: (ctx) {
      return [
        pw.Container(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Text('Field Visitor Registration Summary', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 6),
        // Use a table-like layout for key/value pairs
        pw.Column(children: entries.map((e) {
          if (e.value.toString().trim().isEmpty) return pw.SizedBox();
          final listKeys = {'O/L Subjects', 'A/L Subjects', 'Other Qualifications', 'Previous Experience', 'References', 'Activities'};
          if (listKeys.contains(e.key)) {
            final parts = e.value.toString().split(RegExp(r', | ; ')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(e.key, style: keyStyle), pw.SizedBox(height: 4), pw.Column(children: parts.map((p) => pw.Row(children: [pw.Text('• ', style: valStyle), pw.Expanded(child: pw.Text(p, style: valStyle))])).toList()), pw.SizedBox(height: 8)]);
          }
          return pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 6), child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Expanded(flex: 3, child: pw.Text(e.key, style: keyStyle)), pw.SizedBox(width: 8), pw.Expanded(flex: 5, child: pw.Text(e.value.toString(), style: valStyle))]));
        }).toList())
      ];
    }));

    return Uint8List.fromList(await doc.save());
  }

  // _submitScreen removed — confirmation now happens on the review screen

  @override
  Widget build(BuildContext context) {
    // ensure controllers show current model
    tcFullName.text = tcFullName.text.isNotEmpty ? tcFullName.text : model.fullName;
    tcMobile.text = tcMobile.text.isNotEmpty ? tcMobile.text : model.mobile;
    tcEmail.text = tcEmail.text.isNotEmpty ? tcEmail.text : model.email;

    return Scaffold(
      body: Stack(children: [
        Column(children: [
          TopHeader(stepIndex: currentStep),
        Expanded(
          child: PageView.builder(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (_, index) {
              return SingleChildScrollView(child: _buildStepContent(index));
            },
          ),
        ),
        
        ]),

        // OTP overlay (blurred background)
        if (showOtpOverlay)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withAlpha((0.35 * 255).round()),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(otpStage == 0 ? 'Mobile OTP Verification' : 'Email OTP Verification', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          if (otpStage == 0)
                            LabeledInput(label: 'Mobile number', controller: tcMobile, hint: '+94 77 123 4567', keyboardType: TextInputType.phone)
                          else
                            LabeledInput(label: 'Email address', controller: tcEmail, hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            ElevatedButton(
                              onPressed: () {
                                _sendOtp(otpStage == 0 ? 'Mobile ${tcMobile.text}' : 'Email ${tcEmail.text}');
                              },
                              child: const Text('Send OTP'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(onPressed: () {
                              _sendOtp(otpStage == 0 ? 'Mobile ${tcMobile.text}' : 'Email ${tcEmail.text}');
                            }, child: const Text('Resend'))
                          ]),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(otpStage == 0 ? otpControllers.length : emailOtpControllers.length, (i) {
                              final controller = otpStage == 0 ? otpControllers[i] : emailOtpControllers[i];
                              return SizedBox(
                                width: 42,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: TextField(
                                    controller: controller,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    maxLength: 1,
                                    obscureText: true,
                                    obscuringCharacter: '●',
                                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
                                    cursorColor: AppColors.darkGreen,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderGrey)),
                                    ),
                                    onChanged: (v) {
                                      if (v.isNotEmpty) FocusScope.of(context).nextFocus();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            OutlinedButton(onPressed: () {
                              // cancel OTP overlay, keep on personal screen
                              showOtpOverlay = false;
                              setState(() {});
                            }, child: const Text('Cancel')),
                            ElevatedButton(onPressed: () {
                              if (otpStage == 0) {
                                if (_verifyOtp()) {
                                  // save verified mobile, move to email stage
                                  model.mobile = tcMobile.text;
                                  otpStage = 1;
                                  // let user send email OTP from overlay
                                  setState(() {});
                                }
                              } else {
                                if (_verifyEmailOtp()) {
                                  // save verified email, hide overlay and go next
                                  model.email = tcEmail.text;
                                  showOtpOverlay = false;
                                  setState(() {
                                    goToStep(1);
                                  });
                                }
                              }
                            }, child: Text(otpStage == 0 ? 'Verify & Next' : 'Verify', style: const TextStyle(color: Colors.white))),
                          ])
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

      ]),
      bottomNavigationBar: const ManagerFooter(currentIndex: 1),
    );
  }
}
