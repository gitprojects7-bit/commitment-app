import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _restoreUserProfile();
  runApp(const MyApp());
}

Future<void> _restoreUserProfile() async {
  final preferences = await SharedPreferences.getInstance();
  final name = preferences.getString('profile.name');
  final email = preferences.getString('profile.email');
  final mobile = preferences.getString('profile.mobile');
  final password = preferences.getString('profile.password');
  if (name == null || email == null || mobile == null || password == null) {
    return;
  }
  final subscriptionDataMigrated =
      preferences.getBool('profile.subscriptionDataMigrated') ?? false;
  if (!subscriptionDataMigrated) {
    await preferences.remove('profile.subscriptionPlan');
    await preferences.setBool('profile.subscriptionActive', false);
    await preferences.setBool('profile.subscriptionDataMigrated', true);
  }
  currentUser = UserProfile(
    name: name,
    email: email,
    mobile: mobile,
    password: password,
    subscriptionPlan: preferences.getString('profile.subscriptionPlan') ?? '',
    subscriptionActive: subscriptionDataMigrated
        ? preferences.getBool('profile.subscriptionActive') ?? false
        : false,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color pageBackground = Color(0xFFEAF7FF);
  static const Color ink = Color(0xFF1D2430);
  static const Color skyAccent = Color(0xFF9FD9FF);

  static BoxDecoration clayCardDecoration({
    double radius = 30,
    Color start = const Color(0xFFF8FDFF),
    Color end = const Color(0xFFD8F1FF),
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [start, end],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.92),
        width: 1.6,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF78BFEA).withValues(alpha: 0.48),
          blurRadius: 34,
          spreadRadius: 2,
          offset: const Offset(13, 18),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.95),
          blurRadius: 20,
          offset: const Offset(-11, -11),
        ),
        BoxShadow(
          color: const Color(0xFFB5E5FF).withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static ButtonStyle clayButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 17),
      backgroundColor: skyAccent,
      foregroundColor: ink,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  static InputDecoration clayInputDecoration({
    String? hintText,
    String? labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.72),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF78C9FF), width: 2),
      ),
    );
  }

  static Widget buildPageBody({
    required Widget child,
    bool showBackButton = false,
  }) {
    return Stack(
      children: [
        Positioned(
          top: -70,
          left: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFBFEAFF).withValues(alpha: 0.78),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -50,
          bottom: -60,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFBFEAFF).withValues(alpha: 0.95),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Center(child: child),
        if (showBackButton)
          Positioned(
            top: 8,
            left: 8,
            child: Builder(
              builder: (context) => SafeArea(
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: MyApp.ink,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commitment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7CCAFF),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: ink),
        ),
        cardTheme: CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(26)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: skyAccent,
            foregroundColor: ink,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ink,
            side: const BorderSide(color: Color(0xFF78BFEA), width: 1.4),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24, color: Color(0xFF1D2430)),
          headlineMedium: TextStyle(fontSize: 21, color: Color(0xFF1D2430)),
          titleLarge: TextStyle(fontSize: 19, color: Color(0xFF1D2430)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1D2430)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF1D2430)),
        ),
      ),
      home: currentUser == null
          ? const WelcomeScreen()
          : const DashboardScreen(showSetupPopups: false),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: MyApp.clayCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'COMMITMENT APP',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 28),
                _buildOptionRow('1. Schedule day'),
                _buildOptionRow('2. Attend meeting'),
                _buildOptionRow('3. Be aware of day'),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileInputScreen(),
                        ),
                      );
                    },
                    style: MyApp.clayButtonStyle(),
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: MyApp.clayCardDecoration(radius: 26),
              child: user == null
                  ? const Text('No profile details available.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: MyApp.clayCardDecoration(
                            radius: 22,
                            start: const Color(0xFFBFEAFF),
                            end: const Color(0xFF8EDBFF),
                          ),
                          child: const Icon(
                            Icons.account_circle_rounded,
                            size: 64,
                            color: Color(0xFF245D8F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your account details',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'PROFILE INFORMATION',
                          style: TextStyle(
                            color: Color(0xFF3478B8),
                            fontSize: 12,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _profileDetail(
                          Icons.person_outline_rounded,
                          'User name',
                          user.name,
                        ),
                        _profileDetail(
                          Icons.email_outlined,
                          'Email',
                          user.email,
                        ),
                        _profileDetail(
                          Icons.phone_outlined,
                          'Mobile',
                          user.mobile,
                        ),
                        _profileDetail(
                          Icons.lock_outline_rounded,
                          'Password',
                          '••••••',
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileDetail(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: MyApp.clayCardDecoration(
        radius: 18,
        start: const Color(0xFFF8FDFF),
        end: const Color(0xFFE0F4FF),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFBFEAFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF3478B8), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final plan = user?.subscriptionPlan ?? '';
    final isActive = user?.subscriptionActive ?? false;

    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: MyApp.clayCardDecoration(radius: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: MyApp.clayCardDecoration(
                      radius: 22,
                      start: const Color(0xFFBFEAFF),
                      end: const Color(0xFF8EDBFF),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 62,
                      color: Color(0xFF245D8F),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your subscription',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? 'abc',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: MyApp.clayCardDecoration(
                      radius: 20,
                      start: const Color(0xFFF8FDFF),
                      end: const Color(0xFFD6F0FF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Monthly plan',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _SubscriptionStatusBadge(isActive: isActive),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Full access to commitments, reminders, saved data, and meeting tools.',
                          style: TextStyle(color: Colors.black54, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isActive ? 'Plan: $plan' : 'No active plan',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? 'Demo subscription · Renews monthly'
                              : 'Choose an upgrade plan to continue',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const UpgradeSubscriptionScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      isActive
                          ? Icons.autorenew_rounded
                          : Icons.arrow_upward_rounded,
                    ),
                    label: Text(
                      isActive ? 'MANAGE SUBSCRIPTION' : 'UPGRADE SUBSCRIPTION',
                    ),
                    style: MyApp.clayButtonStyle(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpgradeSubscriptionScreen extends StatelessWidget {
  const UpgradeSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        title: const Text('Upgrade Subscription'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              children: [
                _SubscriptionPlanCard(
                  title: 'Monthly',
                  price: '₹199 / month',
                  description: 'Flexible access with monthly renewal.',
                  highlighted: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _SubscriptionPlanCard(
                  title: 'Yearly',
                  price: '₹1,999 / year',
                  description: 'Save more with annual access.',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Yearly plan is coming soon. Choose Monthly for this demo.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  const _SubscriptionPlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.onPressed,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String description;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: MyApp.clayCardDecoration(
        radius: 24,
        start: highlighted ? const Color(0xFFE8F8FF) : const Color(0xFFF8FDFF),
        end: highlighted ? const Color(0xFFBFE6F8) : const Color(0xFFD6F0FF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF245D8F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            style: MyApp.clayButtonStyle(),
            child: Text('CHOOSE $title PLAN'),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final TextEditingController _cardController = TextEditingController();
  String _method = 'UPI';

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _completePayment() async {
    if (_method == 'Card' && _cardController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the last four digits of the card')),
      );
      return;
    }
    currentUser = currentUser?.copyWith(
      subscriptionPlan: 'Monthly',
      subscriptionActive: true,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('profile.subscriptionPlan', 'Monthly');
    await preferences.setBool('profile.subscriptionActive', true);
    await preferences.setBool('profile.subscriptionDataMigrated', true);
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        title: const Text('Payment Method'),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: MyApp.clayCardDecoration(radius: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Complete monthly upgrade',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Demo payment only. No real payment will be processed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 22),
                  DropdownButtonFormField<String>(
                    initialValue: _method,
                    decoration: MyApp.clayInputDecoration(
                      labelText: 'Payment method',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      DropdownMenuItem(
                        value: 'Card',
                        child: Text('Credit / debit card'),
                      ),
                      DropdownMenuItem(
                        value: 'Net banking',
                        child: Text('Net banking'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _method = value);
                    },
                  ),
                  if (_method == 'Card') ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _cardController,
                      keyboardType: TextInputType.number,
                      decoration: MyApp.clayInputDecoration(
                        labelText: 'Card last four digits',
                        hintText: '1234',
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: _completePayment,
                    icon: const Icon(Icons.lock_rounded),
                    label: const Text('PAY ₹199 AND UPGRADE'),
                    style: MyApp.clayButtonStyle(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionStatusBadge extends StatelessWidget {
  const _SubscriptionStatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD8F5E3) : const Color(0xFFFFE0E0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? const Color(0xFF19713A) : const Color(0xFF9A3030),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class MobileInputScreen extends StatefulWidget {
  const MobileInputScreen({super.key});

  @override
  State<MobileInputScreen> createState() => _MobileInputScreenState();
}

class _MobileInputScreenState extends State<MobileInputScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        showBackButton: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: MyApp.clayCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'COMMITMENT APP',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Enter mobile/email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: MyApp.clayInputDecoration(
                    hintText: 'Mobile or email',
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter your mobile number or email',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OtpVerificationScreen(),
                      ),
                    );
                  },
                  style: MyApp.clayButtonStyle(),
                  child: const Text(
                    'SEND OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        showBackButton: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: MyApp.clayCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'OTP VERIFICATION',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Enter OTP',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: MyApp.clayInputDecoration(hintText: '_ _ _ _ _ _')
                      .copyWith(counterText: ''),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dummy OTP e.g. 123456',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    final otp = _otpController.text.trim();
                    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid 6-digit OTP'),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  style: MyApp.clayButtonStyle(),
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'abc',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'abc@example.com',
  );
  final TextEditingController _mobileController = TextEditingController(
    text: '123',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '123',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        showBackButton: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: MyApp.clayCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'COMPLETE PROFILE',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildField('User Name', _nameController),
                const SizedBox(height: 14),
                _buildField(
                  'Email ID',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _buildField(
                  'Mobile Number',
                  _mobileController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _buildField('Password', _passwordController, obscureText: true),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty ||
                        _emailController.text.trim().isEmpty ||
                        _mobileController.text.trim().isEmpty ||
                        _passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all profile fields'),
                        ),
                      );
                      return;
                    }
                    currentUser = UserProfile(
                      name: _nameController.text.trim(),
                      email: _emailController.text.trim(),
                      mobile: _mobileController.text.trim(),
                      password: _passwordController.text.trim(),
                      subscriptionPlan: '',
                      subscriptionActive: false,
                    );
                    final preferences = await SharedPreferences.getInstance();
                    await preferences.setString(
                      'profile.name',
                      currentUser!.name,
                    );
                    await preferences.setString(
                      'profile.email',
                      currentUser!.email,
                    );
                    await preferences.setString(
                      'profile.mobile',
                      currentUser!.mobile,
                    );
                    await preferences.setString(
                      'profile.password',
                      currentUser!.password,
                    );
                    await preferences.setString(
                      'profile.subscriptionPlan',
                      currentUser!.subscriptionPlan,
                    );
                    await preferences.setBool(
                      'profile.subscriptionActive',
                      currentUser!.subscriptionActive,
                    );
                    await preferences.setBool(
                      'profile.subscriptionDataMigrated',
                      true,
                    );
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(
                          showAccountCreatedMessage: true,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: MyApp.clayButtonStyle(),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: MyApp.clayInputDecoration(),
        ),
      ],
    );
  }
}

class AccessSetupScreen extends StatefulWidget {
  const AccessSetupScreen({super.key});

  @override
  State<AccessSetupScreen> createState() => _AccessSetupScreenState();
}

class _AccessSetupScreenState extends State<AccessSetupScreen> {
  bool _notificationsAllowed = false;
  bool _locationAllowed = false;
  bool _requestingPermission = false;
  static const bool _batteryAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionState();
  }

  Future<void> _loadPermissionState() async {
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    setState(() {
      _notificationsAllowed = notificationStatus.isGranted;
      _locationAllowed = locationStatus.isGranted;
    });
  }

  Future<void> _requestNotifications() async {
    setState(() => _requestingPermission = true);
    final status = await Permission.notification.request();
    if (!mounted) return;
    setState(() {
      _notificationsAllowed = status.isGranted;
      _requestingPermission = false;
    });
  }

  Future<void> _requestLocation() async {
    setState(() => _requestingPermission = true);
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    setState(() {
      _locationAllowed = status.isGranted;
      _requestingPermission = false;
    });
  }

  void _continueToDashboard() {
    if (!_notificationsAllowed || !_locationAllowed || !_batteryAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Allow notifications and location before continuing.'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReminderSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        showBackButton: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  decoration: MyApp.clayCardDecoration(radius: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Commitment App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MyApp.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Let’s set things up',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: MyApp.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'To give you the best experience,\nallow the following access.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 26),
                      _buildAccessCard(
                        icon: Icons.notifications_active_rounded,
                        title: 'Notifications',
                        subtitle: 'Get reminders for meetings',
                        status: _notificationsAllowed ? 'Allowed ✓' : 'Allow →',
                        onTap: _requestNotifications,
                        enabled: !_requestingPermission,
                      ),
                      const SizedBox(height: 14),
                      _buildAccessCard(
                        icon: Icons.battery_charging_full_rounded,
                        title: 'Battery Level',
                        subtitle: 'Monitor your battery',
                        status: _batteryAvailable
                            ? 'Available ✓'
                            : 'Unavailable',
                        onTap: null,
                        enabled: false,
                      ),
                      const SizedBox(height: 14),
                      _buildAccessCard(
                        icon: Icons.location_on_rounded,
                        title: 'Location',
                        subtitle: 'Enable location reminders',
                        status: _locationAllowed ? 'Allowed ✓' : 'Allow →',
                        onTap: _requestLocation,
                        enabled: !_requestingPermission,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _requestingPermission
                            ? null
                            : _continueToDashboard,
                        style: MyApp.clayButtonStyle(),
                        child: const Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required VoidCallback? onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: MyApp.clayCardDecoration(
          radius: 20,
          start: const Color(0xFFF8FDFF),
          end: const Color(0xFFE0F4FF),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF9AD7FF),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF78BFEA).withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(3, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: MyApp.ink, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: MyApp.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: status.contains('✓')
                    ? const Color(0xFF327A5A)
                    : const Color(0xFF3478B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderSetupScreen extends StatefulWidget {
  const ReminderSetupScreen({super.key});

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> {
  String? _reminderOption;
  String _reminderMethod = 'Email';
  String _reminderTiming = 'Before';
  String _customUnit = 'Minutes';
  int _customAmount = 45;

  Future<void> _editCustomReminder() async {
    final result = await showDialog<CustomReminderValue>(
      context: context,
      builder: (context) => CustomReminderDialog(
        initialAmount: _customAmount.toString(),
        initialUnit: _customUnit,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _customAmount = result.amount;
        _customUnit = result.unit;
        _reminderOption = 'Custom';
      });
    }
  }

  void _continueToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(showSetupPopups: false),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        showBackButton: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: MyApp.clayCardDecoration(radius: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Commitment App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MyApp.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Set your reminder',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MyApp.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose how and when you want to be reminded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: MyApp.clayCardDecoration(
                        radius: 22,
                        start: const Color(0xFFF8FDFF),
                        end: const Color(0xFFDDF3FF),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 14),
                            child: Icon(Icons.alarm_rounded),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildReminderDropdown(
                              value: _reminderMethod,
                              hint: 'Remind by',
                              items: const ['Email', 'Popup', 'Notification'],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _reminderMethod = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildReminderDropdown(
                              value: _reminderTiming,
                              hint: 'Timing',
                              items: const ['Before', 'After'],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _reminderTiming = value);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            tooltip: 'Clear reminder',
                            onPressed: _reminderOption == null
                                ? null
                                : () => setState(() {
                                    _reminderOption = null;
                                  }),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: MyApp.clayCardDecoration(
                        radius: 20,
                        start: const Color(0xFFF8FDFF),
                        end: const Color(0xFFDDF3FF),
                      ),
                      child: SingleChildScrollView(
                        child: RadioGroup<String>(
                          groupValue: _reminderOption,
                          onChanged: (value) {
                            if (value != null) {
                              if (value == 'Custom') {
                                _editCustomReminder();
                              } else {
                                setState(() => _reminderOption = value);
                              }
                            }
                          },
                          child: Column(
                            children: [
                              _buildReminderOption(
                                '5 minutes ${_reminderTiming.toLowerCase()}',
                                '5 minutes',
                              ),
                              _buildReminderOption(
                                '10 minutes ${_reminderTiming.toLowerCase()}',
                                '10 minutes',
                              ),
                              _buildReminderOption(
                                '15 minutes ${_reminderTiming.toLowerCase()}',
                                '15 minutes',
                              ),
                              _buildReminderOption(
                                '30 minutes ${_reminderTiming.toLowerCase()}',
                                '30 minutes',
                              ),
                              _buildReminderOption(
                                '1 hour ${_reminderTiming.toLowerCase()}',
                                '1 hour',
                              ),
                              _buildReminderOption(
                                '1 day ${_reminderTiming.toLowerCase()}',
                                '1 day',
                              ),
                              _buildReminderOption('Custom', 'Custom'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _reminderOption == null
                          ? null
                          : _continueToDashboard,
                      style: MyApp.clayButtonStyle(),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: MyApp.clayInputDecoration(hintText: hint).copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildReminderOption(String label, String value) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      value: value,
    );
  }
}

class NotificationSetupScreen extends StatelessWidget {
  const NotificationSetupScreen({super.key});

  Future<void> _requestNotifications(BuildContext context) async {
    final status = await Permission.notification.request();
    if (!context.mounted) return;
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are disabled. Enable them in Android settings.',
          ),
        ),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SetupPermissionScreen(
      icon: Icons.notifications_active_rounded,
      title: 'Let’s set things up',
      subtitle: 'Get reminders for meetings & tasks',
      description:
          'Stay on track with gentle notifications for your commitments.',
      buttonLabel: 'ALLOW',
      onPressed: () => _requestNotifications(context),
    );
  }
}

class LocationSetupScreen extends StatelessWidget {
  const LocationSetupScreen({super.key});

  Future<void> _requestLocation(BuildContext context) async {
    final status = await Permission.locationWhenInUse.request();
    if (!context.mounted) return;
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is disabled. Enable it in Android settings.'),
        ),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BatterySetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SetupPermissionScreen(
      icon: Icons.location_on_rounded,
      title: 'Location Access',
      subtitle: 'Enable location for location-based reminders',
      description: 'Use your location to make nearby and time-sensitive reminders more useful.',
      buttonLabel: 'ALLOW',
      onPressed: () => _requestLocation(context),
    );
  }
}

class BatterySetupScreen extends StatelessWidget {
  const BatterySetupScreen({super.key});

  void _continueToDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SetupPermissionScreen(
      icon: Icons.battery_charging_full_rounded,
      title: 'Battery Access',
      subtitle: 'Monitor your battery level during the day',
      description: 'This helps us keep reminders reliable while your day is in progress.',
      buttonLabel: 'CONTINUE',
      onPressed: () => _continueToDashboard(context),
    );
  }
}

class SetupPermissionScreen extends StatelessWidget {
  const SetupPermissionScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        showBackButton: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
            decoration: MyApp.clayCardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'COMMITMENT APP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.center,
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9AD7FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF78BFEA).withValues(alpha: 0.55),
                        blurRadius: 20,
                        offset: const Offset(5, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.85),
                        blurRadius: 10,
                        offset: const Offset(-4, -5),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 38, color: MyApp.ink),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: onPressed,
                  style: MyApp.clayButtonStyle(),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum CommitmentType { task, online, inPerson }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    this.subscriptionPlan = '',
    this.subscriptionActive = false,
  });

  final String name;
  final String email;
  final String mobile;
  final String password;
  final String subscriptionPlan;
  final bool subscriptionActive;

  UserProfile copyWith({
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? subscriptionPlan,
    bool? subscriptionActive,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
    );
  }
}

// Demo-only account state. Replace this with the authenticated backend user.
UserProfile? currentUser;

class SavedCommitment {
  SavedCommitment({
    required this.type,
    required this.title,
    required this.remarks,
    required this.reminder,
    required this.reminderMethod,
    required this.reminderTiming,
    required this.repeat,
    this.customRepeatDates = const [],
    this.date,
    this.time,
    this.meetingLink,
    this.meetingPerson,
    this.myLocation,
    this.location,
    this.rescheduleReason = '',
    this.reachedAt,
    this.personAvailable,
    this.importantNotes = '',
  });

  final CommitmentType type;
  String title;
  String remarks;
  String reminder;
  String reminderMethod;
  String reminderTiming;
  String repeat;
  List<DateTime> customRepeatDates;
  DateTime? date;
  TimeOfDay? time;
  String? meetingLink;
  String? meetingPerson;
  String? myLocation;
  String? location;
  String rescheduleReason;
  DateTime? reachedAt;
  bool? personAvailable;
  String importantNotes;
}

final List<SavedCommitment> savedCommitments = [
  SavedCommitment(
    type: CommitmentType.task,
    title: 'Complete Assignment',
    remarks: 'Finish the mathematics assignment and submit it online.',
    reminder: '30 minutes',
    reminderMethod: 'Notification',
    reminderTiming: 'Before',
    repeat: 'Does not repeat',
    date: DateTime(2026, 9, 25),
    time: const TimeOfDay(hour: 17, minute: 0),
  ),
  SavedCommitment(
    type: CommitmentType.task,
    title: 'Submit Project',
    remarks: 'Upload the final project files before the deadline.',
    reminder: '15 minutes',
    reminderMethod: 'Email',
    reminderTiming: 'Before',
    repeat: 'Does not repeat',
    date: DateTime(2026, 9, 26),
    time: const TimeOfDay(hour: 18, minute: 0),
  ),
  SavedCommitment(
    type: CommitmentType.online,
    title: 'Team Meeting',
    remarks: 'Discuss the sprint progress with the project team.',
    reminder: '10 minutes',
    reminderMethod: 'Popup',
    reminderTiming: 'Before',
    repeat: 'Weekly',
    date: DateTime(2026, 9, 25),
    time: const TimeOfDay(hour: 19, minute: 0),
    meetingLink: 'https://meet.google.com/team-demo',
  ),
  SavedCommitment(
    type: CommitmentType.online,
    title: 'Client Meeting',
    remarks: 'Review the design updates with the client.',
    reminder: '30 minutes',
    reminderMethod: 'Email',
    reminderTiming: 'Before',
    repeat: 'Does not repeat',
    date: DateTime(2026, 9, 27),
    time: const TimeOfDay(hour: 20, minute: 0),
    meetingLink: 'https://meet.google.com/client-demo',
  ),
  SavedCommitment(
    type: CommitmentType.inPerson,
    title: 'College Meeting',
    remarks: 'Meet the coordinator to discuss the event schedule.',
    reminder: '1 hour',
    reminderMethod: 'Notification',
    reminderTiming: 'Before',
    repeat: 'Does not repeat',
    date: DateTime(2026, 9, 28),
    time: const TimeOfDay(hour: 21, minute: 0),
    meetingPerson: 'Department Coordinator',
    myLocation: 'College Main Gate',
    location: 'College Conference Room',
  ),
  SavedCommitment(
    type: CommitmentType.inPerson,
    title: 'Client Meeting',
    remarks: 'Present the completed project walkthrough.',
    reminder: '15 minutes',
    reminderMethod: 'Popup',
    reminderTiming: 'Before',
    repeat: 'Does not repeat',
    date: DateTime(2026, 9, 29),
    time: const TimeOfDay(hour: 22, minute: 0),
    meetingPerson: 'Arun Kumar',
    myLocation: 'Chennai Office',
    location: 'Client Office',
  ),
];

class NewCommitmentScreen extends StatefulWidget {
  const NewCommitmentScreen({
    this.editingCommitment,
    this.isRescheduling = false,
    super.key,
  });

  final SavedCommitment? editingCommitment;
  final bool isRescheduling;

  @override
  State<NewCommitmentScreen> createState() => _NewCommitmentScreenState();
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _searchController = TextEditingController();
  String _selectedLocation = 'Chennai Office';
  bool _locationDetected = false;
  final List<String> _samplePlaces = const [
    'Chennai Office',
    'Marina Beach',
    'Chennai Central',
    'Guindy National Park',
    'T Nagar',
    'Anna Nagar',
  ];
  List<String> _filteredPlaces = const [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _useCurrentLocation() {
    setState(() {
      _locationDetected = true;
      _selectedLocation = 'Current location';
      _searchController.text = _selectedLocation;
      _filteredPlaces = const [];
    });
  }

  void _selectLocation(String location) {
    setState(() {
      _selectedLocation = location;
      _searchController.text = location;
      _locationDetected = false;
      _filteredPlaces = const [];
    });
  }

  void _confirmLocation() {
    final location = _searchController.text.trim().isEmpty
        ? _selectedLocation
        : _searchController.text.trim();
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Choose location',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    final query = value.trim().toLowerCase();
                    setState(() {
                      _filteredPlaces = query.isEmpty
                          ? const []
                          : _samplePlaces
                                .where(
                                  (place) =>
                                      place.toLowerCase().contains(query),
                                )
                                .toList();
                    });
                  },
                  decoration: MyApp.clayInputDecoration(
                    hintText: 'Search for a place',
                  ).copyWith(prefixIcon: const Icon(Icons.search_rounded)),
                ),
                if (_filteredPlaces.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: MyApp.clayCardDecoration(
                      radius: 18,
                      start: const Color(0xFFF8FDFF),
                      end: const Color(0xFFE0F4FF),
                    ),
                    child: Column(
                      children: _filteredPlaces
                          .map(
                            (place) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.place_outlined),
                              title: Text(place),
                              onTap: () => _selectLocation(place),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  height: 390,
                  decoration: MyApp.clayCardDecoration(
                    radius: 28,
                    start: const Color(0xFFDDF3FF),
                    end: const Color(0xFFBFE6F8),
                  ),
                  child: GestureDetector(
                    onTap: () => _selectLocation('Selected map location'),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(double.infinity, 390),
                          painter: _MapPatternPainter(),
                        ),
                        const Positioned(
                          top: 18,
                          child: Text(
                            'MAP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Color(0xFF3478B8),
                              size: 52,
                            ),
                            Container(
                              width: 12,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3478B8)
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _selectedLocation,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: MyApp.ink,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 18,
                          bottom: 18,
                          child: Column(
                            children: [
                              FloatingActionButton.small(
                                heroTag: 'current-location',
                                onPressed: _useCurrentLocation,
                                backgroundColor: const Color(0xFF9AD7FF),
                                foregroundColor: MyApp.ink,
                                elevation: 8,
                                child: const Icon(Icons.my_location_rounded),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'My location',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: MyApp.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _locationDetected
                      ? '📍 Location detected'
                      : 'Tap the map or use My location',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _confirmLocation,
                  style: MyApp.clayButtonStyle(),
                  child: const Text(
                    'CONFIRM LOCATION',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke;
    final waterPaint = Paint()
      ..color = const Color(0xFF9BD6FF).withValues(alpha: 0.5)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke;

    final roadOne = Path()
      ..moveTo(-20, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.08,
        size.width + 20,
        size.height * 0.3,
      );
    final roadTwo = Path()
      ..moveTo(size.width * 0.12, size.height + 20)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.62,
        size.width * 0.9,
        -20,
      );
    final water = Path()
      ..moveTo(-20, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.55,
        size.width + 20,
        size.height * 0.7,
      );

    canvas.drawPath(water, waterPaint);
    canvas.drawPath(roadOne, roadPaint);
    canvas.drawPath(roadTwo, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CustomReminderValue {
  const CustomReminderValue({required this.amount, required this.unit});

  final int amount;
  final String unit;
}

class CustomReminderDialog extends StatefulWidget {
  const CustomReminderDialog({
    required this.initialAmount,
    required this.initialUnit,
    super.key,
  });

  final String initialAmount;
  final String initialUnit;

  @override
  State<CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<CustomReminderDialog> {
  late final TextEditingController _amountController;
  late String _unit;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount);
    _unit = widget.initialUnit;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _validationMessage = 'Enter a number greater than zero');
      return;
    }
    Navigator.of(context).pop(CustomReminderValue(amount: amount, unit: _unit));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFEAF7FF),
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: const Color(0xFF78BFEA).withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
      ),
      title: const Text(
        'Custom reminder',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remind me:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: MyApp.clayInputDecoration(hintText: '45'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: MyApp.clayInputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'Minutes', child: Text('Minutes')),
                    DropdownMenuItem(value: 'Hours', child: Text('Hours')),
                    DropdownMenuItem(value: 'Days', child: Text('Days')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _unit = value);
                  },
                ),
              ),
            ],
          ),
          if (_validationMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _validationMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: MyApp.clayButtonStyle(),
          child: const Text(
            'SAVE',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _NewCommitmentScreenState extends State<NewCommitmentScreen> {
  CommitmentType _selectedType = CommitmentType.task;
  String? _selectedReminder;
  String _reminderMethod = 'Email';
  String _reminderTiming = 'Before';
  String _repeatOption = 'Does not repeat';
  List<DateTime> _customRepeatDates = [];
  String _customReminderUnit = 'Minutes';
  int _customReminderAmount = 45;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _titleController = TextEditingController();
  final _remarksController = TextEditingController();
  final _linkController = TextEditingController();
  final _meetingPersonController = TextEditingController();
  final _myLocationController = TextEditingController();
  final _locationController = TextEditingController();
  final _rescheduleReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final commitment = widget.editingCommitment;
    if (commitment == null) return;
    _selectedType = commitment.type;
    _selectedReminder = commitment.reminder;
    _reminderMethod = commitment.reminderMethod;
    _reminderTiming = commitment.reminderTiming;
    _repeatOption = commitment.repeat.startsWith('Custom:')
        ? 'Custom...'
        : commitment.repeat;
    _customRepeatDates = List<DateTime>.from(commitment.customRepeatDates);
    _selectedDate = commitment.date;
    _selectedTime = commitment.time;
    _titleController.text = commitment.title;
    _remarksController.text = commitment.remarks;
    _linkController.text = commitment.meetingLink ?? '';
    _meetingPersonController.text = commitment.meetingPerson ?? '';
    _myLocationController.text = commitment.myLocation ?? '';
    _locationController.text = commitment.location ?? '';
    _rescheduleReasonController.text = commitment.rescheduleReason;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _remarksController.dispose();
    _linkController.dispose();
    _meetingPersonController.dispose();
    _myLocationController.dispose();
    _locationController.dispose();
    _rescheduleReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate ?? DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _openLocationPicker(TextEditingController controller) async {
    final selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );
    if (selectedLocation != null && mounted) {
      setState(() => controller.text = selectedLocation);
    }
  }

  Future<void> _editCustomReminder() async {
    final result = await showDialog<CustomReminderValue>(
      context: context,
      builder: (context) => CustomReminderDialog(
        initialAmount: _customReminderAmount.toString(),
        initialUnit: _customReminderUnit,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _customReminderAmount = result.amount;
        _customReminderUnit = result.unit;
        _selectedReminder = 'Custom';
      });
    }
  }

  Future<void> _selectCustomRepeatDates() async {
    final dates = await showDialog<List<DateTime>>(
      context: context,
      builder: (context) {
        final selectedDates = <DateTime>{
          ..._customRepeatDates.map(DateUtils.dateOnly),
        };
        var focusedDate = DateTime.now();
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final sortedDates = selectedDates.toList()..sort();
            return AlertDialog(
              title: const Text('Select repeat dates'),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CalendarDatePicker(
                        initialDate: focusedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                        onDateChanged: (date) {
                          final day = DateUtils.dateOnly(date);
                          setDialogState(() {
                            focusedDate = day;
                            if (selectedDates.contains(day)) {
                              selectedDates.remove(day);
                            } else {
                              selectedDates.add(day);
                            }
                          });
                        },
                      ),
                      if (sortedDates.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Selected: ${sortedDates.map(_formatDate).join(', ')}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: selectedDates.isEmpty
                      ? null
                      : () => Navigator.pop(context, sortedDates),
                  style: MyApp.clayButtonStyle(),
                  child: const Text('DONE'),
                ),
              ],
            );
          },
        );
      },
    );
    if (dates != null && mounted) {
      setState(() {
        _customRepeatDates = dates;
        _repeatOption = 'Custom...';
      });
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _saveCommitment() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a commitment title')),
      );
      return;
    }
    if (_selectedType == CommitmentType.online &&
        _linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the meeting link')),
      );
      return;
    }
    if (_selectedType == CommitmentType.inPerson &&
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the location')),
      );
      return;
    }
    if (_selectedType == CommitmentType.inPerson &&
        _meetingPersonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the meeting person')),
      );
      return;
    }
    if (_selectedReminder == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a reminder')));
      return;
    }
    final reminder = _selectedReminder == 'Custom'
        ? '$_customReminderAmount $_customReminderUnit'
        : _selectedReminder!;
    final repeat = _repeatOption == 'Custom...'
        ? 'Custom: ${_customRepeatDates.map(_formatDate).join(', ')}'
        : _repeatOption;
    final existing = widget.editingCommitment;
    if (existing != null) {
      existing
        ..title = _titleController.text.trim()
        ..remarks = _remarksController.text.trim()
        ..reminder = reminder
        ..reminderMethod = _reminderMethod
        ..reminderTiming = _reminderTiming
        ..repeat = repeat
        ..customRepeatDates = _customRepeatDates
        ..date = _selectedDate
        ..time = _selectedTime
        ..meetingLink = _selectedType == CommitmentType.online
            ? _linkController.text.trim()
            : null
        ..meetingPerson = _selectedType == CommitmentType.inPerson
            ? _meetingPersonController.text.trim()
            : null
        ..myLocation = _selectedType == CommitmentType.inPerson
            ? _myLocationController.text.trim()
            : null
        ..location = _selectedType == CommitmentType.inPerson
            ? _locationController.text.trim()
            : null
        ..rescheduleReason = widget.isRescheduling
            ? _rescheduleReasonController.text.trim()
            : existing.rescheduleReason;
    } else {
      savedCommitments.add(
        SavedCommitment(
          type: _selectedType,
          title: _titleController.text.trim(),
          remarks: _remarksController.text.trim(),
          reminder: reminder,
          reminderMethod: _reminderMethod,
          reminderTiming: _reminderTiming,
          repeat: repeat,
          customRepeatDates: _customRepeatDates,
          date: _selectedDate,
          time: _selectedTime,
          meetingLink: _selectedType == CommitmentType.online
              ? _linkController.text.trim()
              : null,
          meetingPerson: _selectedType == CommitmentType.inPerson
              ? _meetingPersonController.text.trim()
              : null,
          myLocation: _selectedType == CommitmentType.inPerson
              ? _myLocationController.text.trim()
              : null,
          location: _selectedType == CommitmentType.inPerson
              ? _locationController.text.trim()
              : null,
        ),
      );
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.isRescheduling
              ? 'Reschedule Commitment'
              : widget.editingCommitment != null
              ? 'Edit Commitment'
              : 'New Commitment',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Set commitment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MyApp.ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a type and add only the details you need.',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 22),
                _buildTypeSelector(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: MyApp.clayCardDecoration(radius: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLabel('Title'),
                      TextField(
                        controller: _titleController,
                        decoration: MyApp.clayInputDecoration(
                          hintText: 'What do you need to do?',
                        ),
                      ),
                      if (widget.isRescheduling) ...[
                        const SizedBox(height: 18),
                        _buildLabel('Reschedule Reason'),
                        TextField(
                          controller: _rescheduleReasonController,
                          maxLines: 3,
                          decoration: MyApp.clayInputDecoration(
                            hintText: 'Why are you rescheduling?',
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerField(
                              label: 'Date',
                              value: _selectedDate == null
                                  ? 'Select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              icon: Icons.calendar_today_rounded,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPickerField(
                              label: 'Time',
                              value:
                                  _selectedTime?.format(context) ??
                                  'Select time',
                              icon: Icons.schedule_rounded,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedType == CommitmentType.online) ...[
                        const SizedBox(height: 18),
                        _buildLabel('Meeting Link'),
                        TextField(
                          controller: _linkController,
                          keyboardType: TextInputType.url,
                          decoration:
                              MyApp.clayInputDecoration(
                                hintText: 'https://meet.google.com/',
                              ).copyWith(
                                prefixIcon: const Icon(Icons.link_rounded),
                              ),
                        ),
                      ],
                      if (_selectedType == CommitmentType.inPerson) ...[
                        const SizedBox(height: 18),
                        _buildLabel('Meeting Person'),
                        TextField(
                          controller: _meetingPersonController,
                          decoration: MyApp.clayInputDecoration(
                            hintText: 'Who are you meeting?',
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildLocationField(
                          label: 'My Location',
                          controller: _myLocationController,
                        ),
                        const SizedBox(height: 14),
                        _buildLocationField(
                          label: 'Meeting Location',
                          controller: _locationController,
                        ),
                      ],
                      const SizedBox(height: 18),
                      _buildLabel('Reminder'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildReminderDropdown(
                            value: _reminderMethod,
                            hint: 'Remind by',
                            items: const ['Email', 'Popup', 'Notification'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _reminderMethod = value);
                              }
                            },
                          ),
                          _buildReminderDropdown(
                            value: _reminderTiming,
                            hint: 'Timing',
                            items: const ['Before', 'After'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _reminderTiming = value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedReminder,
                        isExpanded: true,
                        decoration: MyApp.clayInputDecoration(
                          hintText: 'Reminder duration',
                        ).copyWith(prefixIcon: const Icon(Icons.alarm_rounded)),
                        items: [
                          for (final option in const [
                            ('5 minutes', '5 minutes'),
                            ('10 minutes', '10 minutes'),
                            ('15 minutes', '15 minutes'),
                            ('30 minutes', '30 minutes'),
                            ('1 hour', '1 hour'),
                            ('1 day', '1 day'),
                          ])
                            DropdownMenuItem<String>(
                              value: option.$2,
                              child: Text('${option.$1} $_reminderTiming'),
                            ),
                          const DropdownMenuItem<String>(
                            value: 'Custom',
                            child: Text('Custom'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == 'Custom') {
                            _editCustomReminder();
                          } else if (value != null) {
                            setState(() => _selectedReminder = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('Repeat'),
                      DropdownButtonFormField<String>(
                        initialValue: _repeatOption,
                        isExpanded: true,
                        decoration:
                            MyApp.clayInputDecoration(hintText: 'Repeat')
                                .copyWith(
                                  prefixIcon: const Icon(Icons.repeat_rounded),
                                ),
                        items:
                            const [
                                  'Does not repeat',
                                  'Daily',
                                  'Weekly',
                                  'Weekdays',
                                  'Monthly',
                                  'Yearly',
                                  'Custom...',
                                ]
                                .map(
                                  (option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            if (value == 'Custom...') {
                              _selectCustomRepeatDates();
                            } else {
                              setState(() {
                                _repeatOption = value;
                                _customRepeatDates = [];
                              });
                            }
                          }
                        },
                      ),
                      if (_repeatOption == 'Custom...' &&
                          _customRepeatDates.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: MyApp.clayCardDecoration(
                            radius: 18,
                            start: const Color(0xFFF8FDFF),
                            end: const Color(0xFFDDF3FF),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.event_rounded,
                                size: 20,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _customRepeatDates
                                      .map(_formatDate)
                                      .join(', '),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _selectCustomRepeatDates,
                                icon: const Icon(Icons.edit_rounded, size: 16),
                                label: const Text('EDIT'),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _buildLabel('Remarks'),
                      TextField(
                        controller: _remarksController,
                        maxLines: 3,
                        decoration: MyApp.clayInputDecoration(
                          hintText: 'Add any additional notes',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saveCommitment,
                        style: MyApp.clayButtonStyle(),
                        child: Text(
                          widget.isRescheduling
                              ? 'RESCHEDULE'
                              : widget.editingCommitment != null
                              ? 'SAVE CHANGES'
                              : 'SAVE COMMITMENT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: () => _openLocationPicker(controller),
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
            decoration: MyApp.clayInputDecoration().copyWith(
              prefixIcon: const Icon(Icons.location_on_rounded),
              suffixIcon: const Icon(Icons.my_location_rounded),
            ),
            child: Text(
              controller.text.isEmpty ? 'Choose location' : controller.text,
              style: TextStyle(
                color: controller.text.isEmpty ? Colors.black45 : MyApp.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 145,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: MyApp.clayInputDecoration(hintText: hint).copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: MyApp.clayCardDecoration(
        radius: 22,
        start: const Color(0xFFF8FDFF),
        end: const Color(0xFFDDF3FF),
      ),
      child: Row(
        children: [
          _buildTypeOption(
            CommitmentType.task,
            Icons.check_circle_outline_rounded,
          ),
          _buildTypeOption(CommitmentType.online, Icons.video_call_rounded),
          _buildTypeOption(CommitmentType.inPerson, Icons.groups_rounded),
        ],
      ),
    );
  }

  Widget _buildTypeOption(CommitmentType type, IconData icon) {
    final selected = type == _selectedType;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF9AD7FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF78BFEA).withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(3, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: MyApp.ink, size: 23),
              const SizedBox(height: 5),
              Text(
                type == CommitmentType.inPerson
                    ? 'In-person'
                    : type.name.capitalize(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
            decoration: MyApp.clayInputDecoration().copyWith(
              prefixIcon: Icon(icon, size: 19),
            ),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: value.startsWith('Select') ? Colors.black45 : MyApp.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

class AccessSetupDialog extends StatefulWidget {
  const AccessSetupDialog({super.key});

  @override
  State<AccessSetupDialog> createState() => _AccessSetupDialogState();
}

class _AccessSetupDialogState extends State<AccessSetupDialog> {
  bool _notificationsAllowed = false;
  bool _locationAllowed = false;
  bool _requestingPermission = false;

  @override
  void initState() {
    super.initState();
    _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final notification = await Permission.notification.status;
    final location = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    setState(() {
      _notificationsAllowed = notification.isGranted;
      _locationAllowed = location.isGranted;
    });
  }

  Future<void> _requestNotification() async {
    setState(() => _requestingPermission = true);
    final status = await Permission.notification.request();
    if (!mounted) return;
    setState(() {
      _notificationsAllowed = status.isGranted;
      _requestingPermission = false;
    });
  }

  Future<void> _requestLocation() async {
    setState(() => _requestingPermission = true);
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    setState(() {
      _locationAllowed = status.isGranted;
      _requestingPermission = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final complete = _notificationsAllowed && _locationAllowed;
    return AlertDialog(
      backgroundColor: const Color(0xFFEAF7FF),
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: const Color(0xFF78BFEA).withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
      ),
      title: const Text(
        'ACCESS SETUP',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAccessRow(
            icon: Icons.notifications_active_rounded,
            title: 'Notification',
            allowed: _notificationsAllowed,
            onTap: _requestNotification,
          ),
          _buildAccessRow(
            icon: Icons.location_on_rounded,
            title: 'Location',
            allowed: _locationAllowed,
            onTap: _requestLocation,
          ),
          _buildAccessRow(
            icon: Icons.battery_charging_full_rounded,
            title: 'Battery',
            allowed: true,
            onTap: null,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: !_requestingPermission && complete
                ? () => Navigator.pop(context, true)
                : null,
            style: MyApp.clayButtonStyle(),
            child: const Text(
              'CONTINUE',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessRow({
    required IconData icon,
    required String title,
    required bool allowed,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: MyApp.ink),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: Switch(
        value: allowed,
        onChanged: onTap == null || _requestingPermission
            ? null
            : (_) => onTap(),
        activeThumbColor: const Color(0xFF327A5A),
        activeTrackColor: const Color(0xFFB7E7CE),
      ),
    );
  }
}

class ReminderSelectionDialog extends StatefulWidget {
  const ReminderSelectionDialog({super.key});

  @override
  State<ReminderSelectionDialog> createState() =>
      _ReminderSelectionDialogState();
}

class _ReminderSelectionDialogState extends State<ReminderSelectionDialog> {
  String? _selectedReminder;
  int _customAmount = 45;
  String _customUnit = 'Minutes';

  Future<void> _selectCustom() async {
    final result = await showDialog<CustomReminderValue>(
      context: context,
      builder: (context) => CustomReminderDialog(
        initialAmount: _customAmount.toString(),
        initialUnit: _customUnit,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _customAmount = result.amount;
        _customUnit = result.unit;
        _selectedReminder = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      ('5 minutes', '5 minutes'),
      ('10 minutes', '10 minutes'),
      ('15 minutes', '15 minutes'),
      ('30 minutes', '30 minutes'),
      ('1 hour', '1 hour'),
      ('1 day', '1 day'),
    ];
    return AlertDialog(
      backgroundColor: const Color(0xFFEAF7FF),
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: const Color(0xFF78BFEA).withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
      ),
      title: const Text(
        'REMINDER',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: RadioGroup<String>(
          groupValue: _selectedReminder,
          onChanged: (value) => setState(() => _selectedReminder = value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(option.$1),
                  value: option.$2,
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_rounded),
                title: const Text('Custom'),
                subtitle: _selectedReminder == 'Custom'
                    ? Text('$_customAmount $_customUnit')
                    : null,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _selectCustom,
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedReminder == null
                ? null
                : () => Navigator.pop(context),
            style: MyApp.clayButtonStyle(),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class SavedCommitmentsScreen extends StatefulWidget {
  const SavedCommitmentsScreen({required this.type, super.key});

  final CommitmentType type;

  @override
  State<SavedCommitmentsScreen> createState() => _SavedCommitmentsScreenState();
}

class _SavedCommitmentsScreenState extends State<SavedCommitmentsScreen> {
  String get _typeLabel {
    switch (widget.type) {
      case CommitmentType.task:
        return 'Task';
      case CommitmentType.online:
        return 'Online';
      case CommitmentType.inPerson:
        return 'In person';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case CommitmentType.task:
        return Icons.task_alt_rounded;
      case CommitmentType.online:
        return Icons.videocam_rounded;
      case CommitmentType.inPerson:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final commitments = savedCommitments
        .where((commitment) => commitment.type == widget.type)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Saved $_typeLabel commitments',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: commitments.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'No saved $_typeLabel commitments yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                  itemCount: commitments.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final commitment = commitments[index];
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: MyApp.clayCardDecoration(radius: 26),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9AD7FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(_icon, color: Colors.black87),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commitment.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (commitment.remarks.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    commitment.remarks,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _openView(commitment),
                                    child: const Text('VIEW'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _openView(SavedCommitment commitment) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CommitmentDetailsScreen(
          commitment: commitment,
          icon: _icon,
          typeLabel: _typeLabel,
        ),
      ),
    );
    if (changed == true && mounted) setState(() {});
  }
}

class CommitmentDetailsScreen extends StatefulWidget {
  const CommitmentDetailsScreen({
    required this.commitment,
    required this.icon,
    required this.typeLabel,
    super.key,
  });

  final SavedCommitment commitment;
  final IconData icon;
  final String typeLabel;

  @override
  State<CommitmentDetailsScreen> createState() =>
      _CommitmentDetailsScreenState();
}

class _CommitmentDetailsScreenState extends State<CommitmentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final commitment = widget.commitment;
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Commitment Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: MyApp.clayCardDecoration(radius: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: MyApp.clayCardDecoration(
                          radius: 18,
                          start: const Color(0xFFBFEAFF),
                          end: const Color(0xFF8EDBFF),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 30,
                          color: const Color(0xFF245D8F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9AD7FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.typeLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF245D8F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              commitment.title,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (commitment.remarks.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      commitment.remarks,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  _buildScheduleSummary(commitment),
                  const SizedBox(height: 18),
                  _buildSectionLabel('Commitment information'),
                  if (commitment.date != null)
                    _buildDetail(
                      Icons.calendar_today_rounded,
                      'Date',
                      '${commitment.date!.day.toString().padLeft(2, '0')}/'
                          '${commitment.date!.month.toString().padLeft(2, '0')}/'
                          '${commitment.date!.year}',
                    ),
                  if (commitment.time != null)
                    _buildDetail(
                      Icons.schedule_rounded,
                      'Time',
                      commitment.time!.format(context),
                    ),
                  _buildDetail(
                    Icons.notifications_active_rounded,
                    'Reminder',
                    '${commitment.reminderMethod} · '
                        '${commitment.reminderTiming} · '
                        '${commitment.reminder}',
                  ),
                  _buildDetail(
                    Icons.repeat_rounded,
                    'Repeat',
                    commitment.repeat,
                  ),
                  if (commitment.meetingPerson != null)
                    _buildDetail(
                      Icons.person_outline_rounded,
                      'Meeting person',
                      commitment.meetingPerson!,
                    ),
                  if (commitment.myLocation != null)
                    _buildDetail(
                      Icons.my_location_rounded,
                      'My location',
                      commitment.myLocation!,
                    ),
                  if (commitment.location != null)
                    _buildDetail(
                      Icons.location_on_rounded,
                      'Meeting location',
                      commitment.location!,
                    ),
                  if (commitment.meetingLink != null)
                    _buildDetail(
                      Icons.link_rounded,
                      'Meeting link',
                      commitment.meetingLink!,
                    ),
                  if (commitment.reachedAt != null)
                    _buildDetail(
                      Icons.flag_rounded,
                      'Reached',
                      TimeOfDay.fromDateTime(commitment.reachedAt!)
                          .format(context),
                    ),
                  if (commitment.personAvailable != null)
                    _buildDetail(
                      Icons.person_pin_rounded,
                      'Person available',
                      commitment.personAvailable! ? 'Yes' : 'No',
                    ),
                  if (commitment.importantNotes.isNotEmpty)
                    _buildDetail(
                      Icons.sticky_note_2_rounded,
                      'Important notes',
                      commitment.importantNotes,
                    ),
                  if (commitment.type == CommitmentType.inPerson) ...[
                    const SizedBox(height: 6),
                    _buildSectionLabel('Meeting actions'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _openStartNow,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('START NOW'),
                              ),
                              style: MyApp.clayButtonStyle(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _openOnTheWay,
                              icon: const Icon(Icons.directions_car_rounded),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("I'M ON THE WAY"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _openReached,
                        icon: const Icon(Icons.flag_rounded),
                        label: const Text('REACHED'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  _buildSectionLabel('Manage commitment'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _openReschedule,
                            style: MyApp.clayButtonStyle(),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('RESCHEDULE'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _openEdit,
                            child: const Text('EDIT'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _deleteCommitment,
                      icon: const Icon(Icons.delete_outline_rounded),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      label: const Text('DELETE COMMITMENT'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w800,
        color: Color(0xFF3478B8),
      ),
    );
  }

  Widget _buildScheduleSummary(SavedCommitment commitment) {
    final date = commitment.date;
    final time = commitment.time;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: MyApp.clayCardDecoration(
        radius: 20,
        start: const Color(0xFFE8F8FF),
        end: const Color(0xFFBFE6F8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 28,
            color: Color(0xFF3478B8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date == null
                      ? 'Date not scheduled'
                      : _formatCommitmentDate(date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time == null ? 'Time not scheduled' : time.format(context),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEdit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NewCommitmentScreen(editingCommitment: widget.commitment),
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _openStartNow() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingRouteScreen(
          commitment: widget.commitment,
          mode: RouteMode.startNow,
        ),
      ),
    );
  }

  Future<void> _openOnTheWay() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingRouteScreen(
          commitment: widget.commitment,
          mode: RouteMode.onTheWay,
        ),
      ),
    );
  }

  Future<void> _openReached() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReachedCommitmentScreen(commitment: widget.commitment),
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _openReschedule() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewCommitmentScreen(
          editingCommitment: widget.commitment,
          isRescheduling: true,
        ),
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _deleteCommitment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Commitment?'),
        content: const Text('Are you sure you want to delete this commitment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      savedCommitments.remove(widget.commitment);
      Navigator.pop(context, true);
    }
  }
}

enum RouteMode { startNow, onTheWay }

class MeetingRouteScreen extends StatefulWidget {
  const MeetingRouteScreen({
    required this.commitment,
    required this.mode,
    super.key,
  });

  final SavedCommitment commitment;
  final RouteMode mode;

  @override
  State<MeetingRouteScreen> createState() => _MeetingRouteScreenState();
}

class _MeetingRouteScreenState extends State<MeetingRouteScreen> {
  late String _fromLocation;
  late String _toLocation;

  @override
  void initState() {
    super.initState();
    _fromLocation = widget.commitment.myLocation ?? 'Current location';
    _toLocation = widget.commitment.location ?? 'Meeting location';
  }

  Future<void> _chooseFromLocation() async {
    final location = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );
    if (location != null && mounted) {
      setState(() => _fromLocation = location);
    }
  }

  Future<void> _chooseToLocation() async {
    final location = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );
    if (location != null && mounted) {
      setState(() => _toLocation = location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == RouteMode.startNow
        ? 'Start Now'
        : "I'm on the Way";
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300,
                  decoration: MyApp.clayCardDecoration(
                    radius: 26,
                    start: const Color(0xFFDDF3FF),
                    end: const Color(0xFFBFE6F8),
                  ),
                  child: CustomPaint(
                    painter: _RoutePainter(),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 52,
                            color: Color(0xFF3478B8),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Route / Path',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _RouteLocationTile(
                  label: 'From location',
                  value: _fromLocation,
                  icon: Icons.my_location_rounded,
                  onTap: _chooseFromLocation,
                ),
                const SizedBox(height: 12),
                _RouteLocationTile(
                  label: 'To location',
                  value: _toLocation,
                  icon: Icons.location_on_rounded,
                  onTap: _chooseToLocation,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.commitment
                      ..myLocation = _fromLocation
                      ..location = _toLocation;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route updated.')),
                    );
                  },
                  icon: const Icon(Icons.navigation_rounded),
                  label: const Text('SHOW ROUTE'),
                  style: MyApp.clayButtonStyle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteLocationTile extends StatelessWidget {
  const _RouteLocationTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: MyApp.clayCardDecoration(radius: 18),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3478B8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_location_alt_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0xFF3478B8)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * .18, size.height * .75)
      ..quadraticBezierTo(
        size.width * .42,
        size.height * .18,
        size.width * .82,
        size.height * .28,
      );
    canvas.drawPath(path, pathPaint);
    final markerPaint = Paint()..color = const Color(0xFF1E9E68);
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .75),
      10,
      markerPaint,
    );
    markerPaint.color = const Color(0xFFD64A5E);
    canvas.drawCircle(
      Offset(size.width * .82, size.height * .28),
      10,
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ReachedCommitmentScreen extends StatefulWidget {
  const ReachedCommitmentScreen({required this.commitment, super.key});

  final SavedCommitment commitment;

  @override
  State<ReachedCommitmentScreen> createState() =>
      _ReachedCommitmentScreenState();
}

class _ReachedCommitmentScreenState extends State<ReachedCommitmentScreen> {
  late TimeOfDay _reachedTime;
  bool _personAvailable = true;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _reachedTime = widget.commitment.reachedAt == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(widget.commitment.reachedAt!);
    _personAvailable = widget.commitment.personAvailable ?? true;
    _notesController = TextEditingController(
      text: widget.commitment.importantNotes,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reachedTime,
    );
    if (time != null) setState(() => _reachedTime = time);
  }

  void _save() {
    final now = DateTime.now();
    widget.commitment
      ..reachedAt = DateTime(
        now.year,
        now.month,
        now.day,
        _reachedTime.hour,
        _reachedTime.minute,
      )
      ..personAvailable = _personAvailable
      ..importantNotes = _notesController.text.trim();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return _CommitmentFormScaffold(
      title: 'Reached',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'What time did you reach?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _CommitmentPicker(
            label: 'Reached time',
            value: _reachedTime.format(context),
            icon: Icons.schedule_rounded,
            onTap: _pickTime,
          ),
          const SizedBox(height: 18),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _personAvailable,
            onChanged: (value) =>
                setState(() => _personAvailable = value ?? false),
            title: const Text('Person available'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          const Text(
            'Important notes',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: MyApp.clayInputDecoration(
              hintText: 'Add important notes',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: MyApp.clayButtonStyle(),
            child: const Text('SAVE REACHED DETAILS'),
          ),
        ],
      ),
    );
  }
}

class EditCommitmentScreen extends StatefulWidget {
  const EditCommitmentScreen({required this.commitment, super.key});

  final SavedCommitment commitment;

  @override
  State<EditCommitmentScreen> createState() => _EditCommitmentScreenState();
}

class _EditCommitmentScreenState extends State<EditCommitmentScreen> {
  late final TextEditingController _titleController;
  late DateTime? _date;
  late TimeOfDay? _time;
  late String _reminder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.commitment.title);
    _date = widget.commitment.date;
    _time = widget.commitment.time;
    _reminder = widget.commitment.reminder;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: _date ?? DateTime.now(),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _time = time);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    widget.commitment
      ..title = _titleController.text.trim()
      ..date = _date
      ..time = _time
      ..reminder = _reminder;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return _CommitmentFormScaffold(
      title: 'Edit Commitment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Title'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: MyApp.clayInputDecoration(hintText: 'Commitment title'),
          ),
          const SizedBox(height: 18),
          _CommitmentPicker(
            label: 'Date',
            value: _date == null
                ? 'Select date'
                : _formatCommitmentDate(_date!),
            icon: Icons.calendar_today_rounded,
            onTap: _pickDate,
          ),
          const SizedBox(height: 14),
          _CommitmentPicker(
            label: 'Time',
            value: _time?.format(context) ?? 'Select time',
            icon: Icons.schedule_rounded,
            onTap: _pickTime,
          ),
          const SizedBox(height: 18),
          const Text('Reminder'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _reminder,
            decoration: MyApp.clayInputDecoration(),
            items:
                const [
                      '5 minutes',
                      '10 minutes',
                      '15 minutes',
                      '30 minutes',
                      '1 hour',
                      '1 day',
                      'Custom',
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _reminder = value);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: MyApp.clayButtonStyle(),
            child: const Text('SAVE CHANGES'),
          ),
        ],
      ),
    );
  }
}

class RescheduleCommitmentScreen extends StatefulWidget {
  const RescheduleCommitmentScreen({required this.commitment, super.key});

  final SavedCommitment commitment;

  @override
  State<RescheduleCommitmentScreen> createState() =>
      _RescheduleCommitmentScreenState();
}

class _RescheduleCommitmentScreenState
    extends State<RescheduleCommitmentScreen> {
  late DateTime? _date = widget.commitment.date;
  late TimeOfDay? _time = widget.commitment.time;
  late String _reminder = widget.commitment.reminder;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: _date ?? DateTime.now(),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _time = time);
  }

  void _reschedule() {
    widget.commitment
      ..date = _date
      ..time = _time
      ..reminder = _reminder
      ..rescheduleReason = _reasonController.text.trim();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return _CommitmentFormScaffold(
      title: 'Reschedule Commitment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Original', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(widget.commitment.title),
          const SizedBox(height: 18),
          _CommitmentPicker(
            label: 'New Date',
            value: _date == null
                ? 'Select date'
                : _formatCommitmentDate(_date!),
            icon: Icons.calendar_today_rounded,
            onTap: _pickDate,
          ),
          const SizedBox(height: 14),
          _CommitmentPicker(
            label: 'New Time',
            value: _time?.format(context) ?? 'Select time',
            icon: Icons.schedule_rounded,
            onTap: _pickTime,
          ),
          const SizedBox(height: 18),
          const Text('Reminder'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _reminder,
            decoration: MyApp.clayInputDecoration(),
            items:
                const [
                      '5 minutes',
                      '10 minutes',
                      '15 minutes',
                      '30 minutes',
                      '1 hour',
                      '1 day',
                      'Custom',
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _reminder = value);
            },
          ),
          const SizedBox(height: 18),
          const Text('Reschedule Reason'),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: MyApp.clayInputDecoration(
              hintText: 'Why are you rescheduling?',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _reschedule,
            style: MyApp.clayButtonStyle(),
            child: const Text('RESCHEDULE'),
          ),
        ],
      ),
    );
  }
}

class _CommitmentFormScaffold extends StatelessWidget {
  const _CommitmentFormScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: MyApp.clayCardDecoration(radius: 26),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommitmentPicker extends StatelessWidget {
  const _CommitmentPicker({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
            decoration: MyApp.clayInputDecoration().copyWith(
              prefixIcon: Icon(icon),
            ),
            child: Text(value),
          ),
        ),
      ],
    );
  }
}

String _formatCommitmentDate(DateTime date) =>
    '${date.day} ${_monthName(date.month)} ${date.year}';

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    this.showSetupPopups = true,
    this.showAccountCreatedMessage = false,
    super.key,
  });

  final bool showSetupPopups;
  final bool showAccountCreatedMessage;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedDockIndex = 0;
  late DateTime _currentDateTime;
  Timer? _clockTimer;

  Future<void> _openNewCommitment() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const NewCommitmentScreen()),
    );
    if (saved == true && mounted) setState(() {});
  }

  void _openSavedCommitments(CommitmentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedCommitmentsScreen(type: type),
      ),
    );
  }

  void _openCommitmentDetails(SavedCommitment commitment) {
    final icon = switch (commitment.type) {
      CommitmentType.task => Icons.task_alt_rounded,
      CommitmentType.online => Icons.videocam_rounded,
      CommitmentType.inPerson => Icons.location_on_rounded,
    };
    final typeLabel = switch (commitment.type) {
      CommitmentType.task => 'Task',
      CommitmentType.online => 'Online',
      CommitmentType.inPerson => 'In person',
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommitmentDetailsScreen(
          commitment: commitment,
          icon: icon,
          typeLabel: typeLabel,
        ),
      ),
    );
  }

  void _openSubscription() {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentDateTime = DateTime.now());
      }
    });
    if (widget.showAccountCreatedMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully.')),
          );
        }
      });
    }
    if (!widget.showSetupPopups) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAccessSetup();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String get _currentDay {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[_currentDateTime.weekday - 1];
  }

  String get _currentDate =>
      '${_currentDateTime.day.toString().padLeft(2, '0')} '
      '${_monthName(_currentDateTime.month)} '
      '${_currentDateTime.year}';

  String get _currentTime =>
      TimeOfDay.fromDateTime(_currentDateTime).format(context);

  String get _greeting {
    final hour = _currentDateTime.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _showAccessSetup() async {
    if (!mounted) return;
    final accessGranted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AccessSetupDialog(),
    );
    if (!mounted || accessGranted != true) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.pageBackground,
      body: MyApp.buildPageBody(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: MyApp.clayCardDecoration(
                    radius: 26,
                    start: const Color(0xFFF8FDFF),
                    end: const Color(0xFFD6F0FF),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              currentUser?.name ?? 'abc',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _openSubscription,
                              icon: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 17,
                              ),
                              label: Text(
                                currentUser?.subscriptionActive ?? false
                                    ? 'Monthly subscription'
                                    : 'Subscribe now',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: MyApp.clayCardDecoration(
                              radius: 16,
                              start: const Color(0xFFE8F8FF),
                              end: const Color(0xFFBFE6F8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _currentTime,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _currentDay,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  _currentDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Upcoming Commitments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                _buildUpcomingGroup(CommitmentType.task, 'Task'),
                const SizedBox(height: 14),
                _buildUpcomingGroup(CommitmentType.online, 'Online'),
                const SizedBox(height: 14),
                _buildUpcomingGroup(CommitmentType.inPerson, 'In-Person'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openNewCommitment,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('NEW COMMITMENT'),
                    style: MyApp.clayButtonStyle(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildUpcomingGroup(CommitmentType type, String label) {
    final now = _currentDateTime;
    final commitments =
        savedCommitments.where((commitment) {
          if (commitment.type != type) return false;
          final scheduledAt = _scheduledDateTime(commitment);
          return scheduledAt == null || !scheduledAt.isBefore(now);
        }).toList()..sort((first, second) {
          final firstDate = _scheduledDateTime(first);
          final secondDate = _scheduledDateTime(second);
          if (firstDate == null && secondDate == null) return 0;
          if (firstDate == null) return 1;
          if (secondDate == null) return -1;
          return firstDate.compareTo(secondDate);
        });
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
      decoration: MyApp.clayCardDecoration(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (commitments.isEmpty)
            const Text(
              'No upcoming commitments',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...commitments.take(5).map(_buildUpcomingRow),
        ],
      ),
    );
  }

  DateTime? _scheduledDateTime(SavedCommitment commitment) {
    final date = commitment.date;
    if (date == null) return null;
    final time = commitment.time;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 23,
      time?.minute ?? 59,
    );
  }

  Widget _buildUpcomingRow(SavedCommitment commitment) {
    final time = commitment.time?.format(context) ?? '--:--';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        commitment.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      leading: SizedBox(
        width: 62,
        child: Text(time, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      trailing: TextButton(
        onPressed: () => _openCommitmentDetails(commitment),
        child: const Text('View'),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: MyApp.clayCardDecoration(
            radius: 28,
            start: const Color(0xFFF8FDFF),
            end: const Color(0xFFD6F0FF),
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _buildBottomAction(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () => setState(() => _selectedDockIndex = 0),
                ),
                _buildBottomAction(
                  index: 1,
                  icon: Icons.task_alt_rounded,
                  label: 'Task',
                  onTap: () {
                    setState(() => _selectedDockIndex = 1);
                    _openSavedCommitments(CommitmentType.task);
                  },
                ),
                _buildBottomAction(
                  index: 2,
                  icon: Icons.videocam_rounded,
                  label: 'Online',
                  onTap: () {
                    setState(() => _selectedDockIndex = 2);
                    _openSavedCommitments(CommitmentType.online);
                  },
                ),
                _buildBottomAction(
                  index: 3,
                  icon: Icons.groups_rounded,
                  label: 'In-person',
                  onTap: () {
                    setState(() => _selectedDockIndex = 3);
                    _openSavedCommitments(CommitmentType.inPerson);
                  },
                ),
                _buildBottomAction(
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: () {
                    setState(() => _selectedDockIndex = 4);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserDetailsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final selected = _selectedDockIndex == index;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: selected
              ? BoxDecoration(
                  color: const Color(0xFF9AD7FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF78BFEA).withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(2, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.85),
                      blurRadius: 7,
                      offset: const Offset(-2, -3),
                    ),
                  ],
                )
              : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: selected ? 23 : 21, color: MyApp.ink),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: MyApp.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
