import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    CommitmentAdminApp(restoredAdminId: preferences.getString('admin.id')),
  );
}

// ============================================================
// APP
// ============================================================

class CommitmentAdminApp extends StatelessWidget {
  const CommitmentAdminApp({super.key, this.restoredAdminId});

  final String? restoredAdminId;

  static const Color primary = Color(0xFF2F80B7);
  static const Color lightBlue = Color(0xFFEAF5FD);
  static const Color background = Color(0xFFF6F9FC);
  static const Color border = Color(0xFFE1E8EF);
  static const Color textDark = Color(0xFF18232E);
  static const Color textGrey = Color(0xFF7D8995);
  static const Color navy = Color(0xFF16222D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commitment App Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8FD0FF),
            foregroundColor: const Color(0xFF12324A),
            elevation: 2,
            shadowColor: const Color(0x338FD0FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textDark, fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
      home: restoredAdminId == null || restoredAdminId!.isEmpty
          ? const AdminLoginScreen()
          : AdminDashboardScreen(adminId: restoredAdminId!),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final roleController = TextEditingController(text: 'Super Admin');
  final phoneController = TextEditingController();
  final AdminApiService _adminApi = AdminApiService();

  bool obscurePassword = true;
  bool isSignup = false;
  bool _showPortal = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    roleController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> submitAuth() async {
    final email = emailController.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _message('Enter a valid email address');
      return;
    }

    if (passwordController.text.length < 8) {
      _message('Password must contain at least 8 characters');
      return;
    }

    if (isSignup) {
      if (nameController.text.trim().isEmpty ||
          roleController.text.trim().isEmpty) {
        _message('Name and role are required');
        return;
      }
      if (!RegExp(r'^[+0-9() .-]{7,25}$')
          .hasMatch(phoneController.text.trim())) {
        _message('Enter a valid phone number');
        return;
      }
    }

    setState(() => isLoading = true);
    try {
      if (isSignup) {
        await _adminApi.signup(
          name: nameController.text.trim(),
          email: email,
          password: passwordController.text,
          role: roleController.text.trim(),
          phone: phoneController.text.trim(),
        );
        if (!mounted) return;
        setState(() {
          isSignup = false;
          passwordController.clear();
        });
        _message('Admin account created. Sign in with your new account.');
        return;
      }

      final admin = await _adminApi.login(
        email: email,
        password: passwordController.text,
      );
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('admin.id', admin.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(adminId: admin.id),
        ),
      );
    } on AdminApiException catch (exception) {
      _message(exception.message);
    } catch (_) {
      _message('Unable to reach the admin service. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final panelWidth = compact
                ? constraints.maxWidth
                : constraints.maxWidth / 2;
            final brandWidth = _showPortal && compact
                ? constraints.maxWidth
                : _showPortal
                ? panelWidth
                : constraints.maxWidth;
            final brandLeft = _showPortal && compact
                ? -constraints.maxWidth
                : 0.0;
            final portalLeft = _showPortal
                ? (compact ? 0.0 : panelWidth)
                : constraints.maxWidth;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOutCubic,
                  left: brandLeft,
                  top: 0,
                  bottom: 0,
                  width: brandWidth,
                  child: ClipRect(child: _buildBrandPanel(compact: compact)),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOutCubic,
                  left: portalLeft,
                  top: 0,
                  bottom: 0,
                  width: panelWidth,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: _showPortal ? 1 : 0,
                    child: ClipRect(
                      child: _showPortal
                          ? _buildAuthPanel()
                          : const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandPanel({required bool compact}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      color: _showPortal ? const Color(0x55FFFFFF) : Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 28 : 56,
        vertical: 32,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 590),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _BrandLogo(),
                const SizedBox(height: 32),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    color: CommitmentAdminApp.textDark,
                    fontSize: _showPortal ? 34 : 42,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                  child: const Text(
                    'One clear view of\nevery commitment.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Manage users, commitments, activity,\nsubscriptions and operational health from\none professional workspace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF52606D),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                if (!_showPortal) ...[
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 220,
                    height: 50,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _showPortal = true;
                          isSignup = false;
                        });
                      },
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthPanel() {
    return Container(
      color: const Color(0x22FFFFFF),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.18, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _buildAuthForm(key: ValueKey(isSignup)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSignup ? 'Create Admin Account' : 'Super Admin Portal',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          isSignup
              ? 'Register an administrator account.'
              : 'Sign in to continue to the admin workspace.',
          style: const TextStyle(color: Color(0xFF7D8995)),
        ),
        const SizedBox(height: 28),
        if (isSignup) ...[
          const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Admin name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: roleController,
            decoration: const InputDecoration(
              hintText: 'Super Admin',
              prefixIcon: Icon(Icons.admin_panel_settings_outlined),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '9876543210',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 14),
        ],
        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => obscurePassword = !obscurePassword);
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: isLoading ? null : submitAuth,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    isSignup ? 'CREATE ACCOUNT' : 'LOGIN',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() => isSignup = !isSignup),
            child: Text(
              isSignup
                  ? 'Already have an account? Sign in'
                  : 'Create admin account',
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: CommitmentAdminApp.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 31,
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Commitment App',
          style: TextStyle(
            color: Color(0xFF18232E),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MAIN ADMIN SHELL
// ============================================================

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.adminId});

  final String adminId;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedItem = 'Dashboard';
  final List<String> navigationHistory = [];
  final AdminApiService _adminApi = AdminApiService();
  late final Future<AdminModel?> _profileFuture;
  AdminModel? _admin;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadAdminProfile();
  }

  Future<AdminModel?> _loadAdminProfile() async {
    try {
      final admin = await _adminApi.getAdminById(widget.adminId);
      if (mounted) setState(() => _admin = admin);
      return admin;
    } on AdminApiException catch (exception) {
      _profileError = exception.message;
      return null;
    } catch (_) {
      _profileError = 'Could not load the admin profile. Please try again.';
      return null;
    }
  }

  void selectItem(String item) {
    if (item == selectedItem) return;

    setState(() {
      navigationHistory.add(selectedItem);
      selectedItem = item;
    });
  }

  void goBack() {
    if (navigationHistory.isEmpty) return;

    setState(() {
      selectedItem = navigationHistory.removeLast();
    });
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('admin.id');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (_) => false,
    );
  }

  void showProfileDetails() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<AdminModel?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            final admin = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Dialog(
                child: SizedBox(
                  width: 460,
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (admin == null) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  width: 460,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Profile unavailable',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(_profileError ?? 'Admin profile was not found.'),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            Widget row(String label, String value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: CommitmentAdminApp.textGrey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 460,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFFE3EAF1),
                            child: Icon(
                              Icons.person,
                              size: 34,
                              color: Color(0xFF9AA8B5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  admin.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  admin.role,
                                  style: TextStyle(
                                    color: CommitmentAdminApp.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      row('Name', admin.name),
                      row('Email', admin.email),
                      row('Role', admin.role),
                      row('Phone', admin.phone),
                      row('Last Login', _formatAdminLastLogin(admin.lastLogin)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showSettings() {
    bool emailAlerts = true;
    bool popupAlerts = true;
    bool twoFactor = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Settings'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Email alerts'),
                      value: emailAlerts,
                      onChanged: (v) => setDialogState(() => emailAlerts = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Popup alerts'),
                      value: popupAlerts,
                      onChanged: (v) => setDialogState(() => popupAlerts = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Two-factor authentication'),
                      value: twoFactor,
                      onChanged: (v) => setDialogState(() => twoFactor = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: Row(
          children: [
            AdminSidebar(selectedItem: selectedItem, onSelected: selectItem),
            Expanded(child: _buildPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    final profile = _ProfileMenu(
      adminName: _admin?.name ?? 'Admin',
      onProfile: showProfileDetails,
      onSettings: showSettings,
      onLogout: logout,
    );

    // Keep route cases in the same order as the managed pages in the sidebar.
    switch (selectedItem) {
      case 'Dashboard':
        return DashboardPage(
          onCommitmentsPressed: () => selectItem('Commitments'),
          onBack: goBack,
          profile: profile,
        );

      case 'Users':
        return UsersPage(onBack: goBack, profile: profile);

      case 'Commitments':
        return CommitmentsPage(onBack: goBack, profile: profile);

      case 'People':
        return PeoplePage(onBack: goBack, profile: profile);

      case 'Location & Maps':
        return LocationMapsPage(onBack: goBack, profile: profile);

      case 'Follow-ups':
        return FollowUpsPage(onBack: goBack, profile: profile);

      case 'Notifications':
        return NotificationsPage(onBack: goBack, profile: profile);

      case 'Analytics':
        return AnalyticsPage(onBack: goBack, profile: profile);

      case 'Attachments':
        return AttachmentsPage(onBack: goBack, profile: profile);

      case 'Subscription':
        return SubscriptionPage(onBack: goBack, profile: profile);

      case 'Support':
        return SupportPage(onBack: goBack, profile: profile);

      case 'Reports':
        return ReportsPage(onBack: goBack, profile: profile);

      default:
        return PlaceholderPage(
          title: selectedItem,
          onBack: goBack,
          profile: profile,
        );
    }
  }
}

// ============================================================
// SIDEBAR
// ============================================================

class AdminSidebar extends StatelessWidget {
  final String selectedItem;
  final Function(String) onSelected;

  const AdminSidebar({
    super.key,
    required this.selectedItem,
    required this.onSelected,
  });

  static const items = [
    ['Dashboard', Icons.dashboard_outlined],
    ['Users', Icons.people_outline],
    ['Commitments', Icons.calendar_month_outlined],
    ['People', Icons.group_outlined],
    ['Location & Maps', Icons.location_on_outlined],
    ['Follow-ups', Icons.notifications_active_outlined],
    ['Notifications', Icons.notifications_none_outlined],
    ['Analytics', Icons.analytics_outlined],
    ['Attachments', Icons.attach_file],
    ['Subscription', Icons.card_membership_outlined],
    ['Support', Icons.support_agent_outlined],
    ['Reports', Icons.description_outlined],
    ['Configuration', Icons.settings_outlined],
    ['Admin Management', Icons.admin_panel_settings_outlined],
    ['Audit Logs', Icons.history_outlined],
    ['Security', Icons.security_outlined],
    ['System Update', Icons.system_update_outlined],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      decoration: glassDecoration(radius: 28),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5DB2EC), Color(0xFF2F80B7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x662F80B7),
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Commitment App',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: CommitmentAdminApp.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = item[0] as String;
                final icon = item[1] as IconData;
                final selected = selectedItem == title;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelected(title),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFA8DCFF), Color(0xFF7CC4F5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: Color(0x668FD0FF),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 21,
                            color: selected
                                ? const Color(0xFF12324A)
                                : const Color(0xFF52606D),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF12324A)
                                    : const Color(0xFF34404B),
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMON
// ============================================================

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;
  final VoidCallback? onBack;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: CommitmentAdminApp.textDark,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: CommitmentAdminApp.textGrey,
                  ),
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = CommitmentAdminApp.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Tilt3D(child: _card());
  }

  Widget _card() {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withAlpha(170)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(110),
                  blurRadius: 9,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration glassDecoration({double radius = 24}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xEBFFFFFF), Color(0x99F2FAFF)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xCCFFFFFF), width: 1.6),
    boxShadow: const [
      // soft blue glow below (depth)
      BoxShadow(
        color: Color(0x408FC8F0),
        blurRadius: 32,
        offset: Offset(0, 16),
      ),
      // light highlight on top-left (3D edge)
      BoxShadow(
        color: Color(0xCCFFFFFF),
        blurRadius: 10,
        offset: Offset(-4, -4),
      ),
    ],
  );
}

BoxDecoration cardDecoration({double radius = 20}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Color(0xFFFAFCFE)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFDCE6EF)),
    boxShadow: const [
      BoxShadow(color: Color(0x10182F45), blurRadius: 16, offset: Offset(0, 5)),
    ],
  );
}

/// Flat white card used on the dashboard (clean, light style).
BoxDecoration dashCardDecoration({double radius = 16}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Color(0xFFF7FBFF)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFDCEAF5)),
    boxShadow: const [
      BoxShadow(color: Color(0x1A1E5A8C), blurRadius: 16, offset: Offset(0, 5)),
    ],
  );
}

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEAF5FC),
                  Color(0xFFDDEFFA),
                  Color(0xFFF6FAFD),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -140,
          left: -120,
          child: Container(
            width: 420,
            height: 420,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x557CC4EC),
            ),
          ),
        ),
        Positioned(
          bottom: -170,
          right: -120,
          child: Container(
            width: 460,
            height: 460,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x447CC4EC),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// Hover 3D effect: card tilts toward the mouse and lifts up.
class Tilt3D extends StatefulWidget {
  final Widget child;
  final double maxTilt;

  const Tilt3D({super.key, required this.child, this.maxTilt = 0.08});

  @override
  State<Tilt3D> createState() => _Tilt3DState();
}

class _Tilt3DState extends State<Tilt3D> {
  double rx = 0;
  double ry = 0;
  bool hover = false;

  void _onHover(PointerHoverEvent event) {
    final size = context.size;
    if (size == null || size.width == 0 || size.height == 0) return;

    final dx = (event.localPosition.dx / size.width - 0.5).clamp(-0.5, 0.5);
    final dy = (event.localPosition.dy / size.height - 0.5).clamp(-0.5, 0.5);

    setState(() {
      hover = true;
      ry = dx * widget.maxTilt * 2;
      rx = -dy * widget.maxTilt * 2;
    });
  }

  void _reset() {
    setState(() {
      hover = false;
      rx = 0;
      ry = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: (_) => _reset(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateX(rx)
          ..rotateY(ry)
          ..translateByDouble(0.0, hover ? -6.0 : 0.0, 0.0, 1.0),
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

const Color _dashTitle = Color(0xFF0B2A5B);
const Color _dashBlue = Color(0xFF2A7DE1);
const EdgeInsets _adminPagePadding = EdgeInsets.fromLTRB(32, 28, 32, 32);

class DashboardPage extends StatefulWidget {
  final VoidCallback onCommitmentsPressed;
  final VoidCallback onBack;
  final Widget profile;

  const DashboardPage({
    super.key,
    required this.onCommitmentsPressed,
    required this.onBack,
    required this.profile,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String chartMode = 'Monthly';
  String snapshotMode = 'Month';

  static const double _bottomRowHeight = 230;

  final monthlyValues = [
    28.0,
    37.0,
    35.0,
    46.0,
    50.0,
    55.0,
    62.0,
    58.0,
    70.0,
    78.0,
    84.0,
    96.0,
  ];

  final yearlyValues = [
    12.0,
    15.0,
    18.0,
    20.0,
    24.0,
    28.0,
    31.0,
    36.0,
    40.0,
    45.0,
    49.0,
    53.0,
    58.0,
    64.0,
    70.0,
    75.0,
    81.0,
    88.0,
    96.0,
    104.0,
    113.0,
    121.0,
    130.0,
    141.0,
    151.0,
    163.0,
    178.0,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildStatRow(),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1050) {
                  return Column(
                    children: [
                      _buildGrowthCard(),
                      const SizedBox(height: 20),
                      _buildCommitmentToday(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildGrowthCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _buildCommitmentToday()),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1050) {
                  return Column(
                    children: [
                      _buildAlertCard(),
                      const SizedBox(height: 20),
                      _buildBusinessSnapshot(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildAlertCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _buildBusinessSnapshot()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Header + profile (top right) ----------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: _dashTitle,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Overview of your Commitment App',
                  style: TextStyle(
                    fontSize: 15,
                    color: CommitmentAdminApp.textGrey,
                  ),
                ),
              ],
            ),
          ),
          widget.profile,
        ],
      ),
    );
  }

  // ---------- Stat cards ----------

  Widget _buildStatRow() {
    const cards = [
      _DashStatCard(
        title: 'Total Users',
        value: '1,284',
        trend: '+12%',
        icon: Icons.people_outline,
        color: Color(0xFF5AA9F0),
      ),
      _DashStatCard(
        title: 'Active Users',
        value: '927',
        trend: '+8%',
        icon: Icons.person_outline,
        color: Color(0xFF2EAD54),
      ),
      _DashStatCard(
        title: 'Trial Users',
        value: '642',
        trend: '+5%',
        icon: Icons.schedule_outlined,
        color: Color(0xFFF5A623),
      ),
      _DashStatCard(
        title: 'Paid Users',
        value: '927',
        trend: '+11%',
        icon: Icons.workspace_premium_outlined,
        color: Color(0xFF7B61FF),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [for (final c in cards) SizedBox(width: 240, child: c)],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }

  // ---------- User Growth ----------

  Widget _buildGrowthCard() {
    final labels = chartMode == 'Monthly'
        ? const [
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
          ]
        : List.generate(27, (index) => '${2000 + index}');

    final values = chartMode == 'Monthly' ? monthlyValues : yearlyValues;

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: dashCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: _dashBlue, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'User Growth',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _dashTitle,
                  ),
                ),
              ),
              _dashDropdown(
                value: chartMode,
                items: const ['Monthly', 'Yearly'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      chartMode = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = chartMode == 'Monthly'
                    ? constraints.maxWidth
                    : 1450.0;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    height: constraints.maxHeight,
                    child: CustomPaint(
                      painter: GrowthChartPainter(
                        values: values,
                        labels: labels,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    double width = 118,
  }) {
    return Container(
      width: width,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CommitmentAdminApp.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _dashTitle,
          ),
          dropdownColor: Colors.white,
          focusColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------- Alert Health ----------

  Widget _buildAlertCard() {
    return Container(
      height: _bottomRowHeight,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: dashCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 38,
            child: Row(
              children: [
                Icon(Icons.shield, color: _dashBlue, size: 22),
                SizedBox(width: 12),
                Text(
                  'Alert Health',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _dashTitle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _healthBar('Popup Delivered', 94, const Color(0xFF2A7DE1)),
                _healthBar(
                  'Notification Delivered',
                  97,
                  const Color(0xFF2EAD54),
                ),
                _healthBar('Email Delivered', 89, const Color(0xFF7B61FF)),
                _healthBar('Failed Delivery', 6, const Color(0xFFE83E3E)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthBar(String title, int percentage, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: CommitmentAdminApp.textDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: color.withAlpha(35),
            color: color,
          ),
        ),
      ],
    );
  }

  // ---------- Commitment Today ----------

  Widget _buildCommitmentToday() {
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: dashCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: _dashBlue, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Commitment Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _dashTitle,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onCommitmentsPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: _dashBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: _dashBlue),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TodayBox(
                          label: 'Created',
                          value: '25',
                          icon: Icons.calendar_month_outlined,
                          color: Color(0xFF5AA9F0),
                          background: Color(0xFFEAF3FD),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _TodayBox(
                          label: 'Completed',
                          value: '18',
                          icon: Icons.check,
                          color: Color(0xFF2EAD54),
                          background: Color(0xFFE8F6EC),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TodayBox(
                          label: 'Late',
                          value: '3',
                          icon: Icons.schedule,
                          color: Color(0xFFF5A623),
                          background: Color(0xFFFFF3E0),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _TodayBox(
                          label: 'Missed',
                          value: '2',
                          icon: Icons.priority_high,
                          color: Color(0xFFE83E3E),
                          background: Color(0xFFFFE9E9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TodayBox(
                          label: 'Cancelled',
                          value: '2',
                          icon: Icons.close,
                          color: Color(0xFF9B87F5),
                          background: Color(0xFFEFEBFF),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _TodayBox(
                          label: 'Rescheduled',
                          value: '1',
                          icon: Icons.update,
                          color: Color(0xFF7B61FF),
                          background: Color(0xFFF2E9FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ---------- Business Snapshot (Month / Year) ----------

  Widget _buildBusinessSnapshot() {
    final yearly = snapshotMode == 'Year';

    final newBox = _BusinessBox(
      label: 'New',
      value: yearly ? '+1,420' : '+128',
      trend: yearly ? '+15%' : '+12%',
      trendUp: true,
      icon: Icons.add,
      color: const Color(0xFF5AA9F0),
      background: const Color(0xFFEAF3FD),
    );

    final cancelBox = _BusinessBox(
      label: 'Cancel',
      value: yearly ? '-96' : '-12',
      trend: yearly ? '-8%' : '-5%',
      trendUp: false,
      icon: Icons.remove,
      color: const Color(0xFFE83E3E),
      background: const Color(0xFFFFE9E9),
    );

    final revenueBox = _BusinessBox(
      label: 'Revenue',
      value: yearly ? '₹4,86,000' : '₹40,500',
      trend: yearly ? '+21%' : '+18%',
      trendUp: true,
      icon: Icons.currency_rupee,
      color: const Color(0xFF6DCB8B),
      background: const Color(0xFFE8F6EC),
    );

    final growthBox = _BusinessBox(
      label: 'Net Growth',
      value: yearly ? '+24.7%' : '+18.4%',
      trend: yearly ? '+12%' : '+8%',
      trendUp: true,
      icon: Icons.trending_up,
      color: const Color(0xFF9B87F5),
      background: const Color(0xFFEFEBFF),
    );

    return Container(
      height: _bottomRowHeight,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: dashCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: _dashBlue, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Business Snapshot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _dashTitle,
                    ),
                  ),
                ),
                _dashDropdown(
                  value: snapshotMode,
                  items: const ['Month', 'Year'],
                  width: 104,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        snapshotMode = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: newBox),
                      const SizedBox(width: 12),
                      Expanded(child: cancelBox),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: revenueBox),
                      const SizedBox(width: 12),
                      Expanded(child: growthBox),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Analytics chart and metric widgets used by AnalyticsPage.
class _AnalyticsMetric {
  final String title;
  final String value;
  final String change;
  final bool positive;
  final Color color;
  final IconData icon;

  const _AnalyticsMetric({
    required this.title,
    required this.value,
    required this.change,
    required this.positive,
    required this.color,
    required this.icon,
  });
}

class _AnalyticsMetricCard extends StatelessWidget {
  final _AnalyticsMetric metric;

  const _AnalyticsMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(metric.icon, size: 17, color: metric.color),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.value,
            style: const TextStyle(
              color: CommitmentAdminApp.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            metric.change,
            style: TextStyle(
              color: metric.positive
                  ? const Color(0xFF26945A)
                  : const Color(0xFFE35D5D),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTrendCard extends StatelessWidget {
  const _AnalyticsTrendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 284,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commitment Score Trend',
            style: TextStyle(
              color: CommitmentAdminApp.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(painter: _AnalyticsTrendPainter()),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnalyticsDayLabel('Mon'),
              _AnalyticsDayLabel('Tue'),
              _AnalyticsDayLabel('Wed'),
              _AnalyticsDayLabel('Thu'),
              _AnalyticsDayLabel('Fri'),
              _AnalyticsDayLabel('Sat'),
              _AnalyticsDayLabel('Sun'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsDayLabel extends StatelessWidget {
  final String day;

  const _AnalyticsDayLabel(this.day);

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: const TextStyle(
        color: CommitmentAdminApp.textGrey,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _AnalyticsTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const values = [0.72, 0.52, 0.56, 0.31, 0.27, 0.48, 0.44];
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(size.width * i / (values.length - 1), size.height * values[i]),
    ];
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF0F5)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final trendPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final middleX = (current.dx + next.dx) / 2;
      trendPath.cubicTo(
        middleX,
        current.dy,
        middleX,
        next.dy,
        next.dx,
        next.dy,
      );
    }

    final fillPath = Path.from(trendPath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x332F80B7), Color(0x002F80B7)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF2F80B7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(trendPath, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF2F80B7);
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnalyticsOutcomeCard extends StatelessWidget {
  const _AnalyticsOutcomeCard();

  @override
  Widget build(BuildContext context) {
    const outcomes = [
      (
        label: 'Kept',
        value: 72,
        detail: 'On-time commitments',
        color: Color(0xFF2EAD67),
      ),
      (
        label: 'Late',
        value: 18,
        detail: 'Completed after due date',
        color: Color(0xFFE5A534),
      ),
      (
        label: 'Missed',
        value: 10,
        detail: 'Not completed',
        color: Color(0xFFE35D5D),
      ),
    ];

    return Container(
      width: double.infinity,
      height: 284,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Outcome Breakdown',
            style: TextStyle(
              color: CommitmentAdminApp.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Commitment outcomes this period',
            style: TextStyle(color: CommitmentAdminApp.textGrey, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final outcome in outcomes)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: outcome.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              outcome.label,
                              style: const TextStyle(
                                color: CommitmentAdminApp.textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${outcome.value}%',
                            style: TextStyle(
                              color: outcome.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          outcome.detail,
                          style: const TextStyle(
                            color: CommitmentAdminApp.textGrey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: outcome.value / 100,
                          minHeight: 9,
                          color: outcome.color,
                          backgroundColor: outcome.color.withAlpha(35),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Profile (top right, shown on every page) ----------

String _formatAdminLastLogin(DateTime? lastLogin) {
  if (lastLogin == null) return 'Never';
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
  final date = lastLogin.toLocal();
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _ProfileMenu extends StatelessWidget {
  final String adminName;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _ProfileMenu({
    required this.adminName,
    required this.onProfile,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'Profile') {
          onProfile();
        } else if (value == 'Settings') {
          onSettings();
        } else if (value == 'Logout') {
          onLogout();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'Profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 10),
              Text('My Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 18),
              SizedBox(width: 10),
              Text('Settings'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE8EEF4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1E5A8C),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE3EAF1),
              child: Icon(Icons.person, color: Color(0xFF9AA8B5), size: 24),
            ),
            SizedBox(width: 10),
            Text(
              adminName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _dashTitle,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------- Dashboard small widgets ----------

class _DashStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  const _DashStatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tilt3D(
      maxTilt: 0.045,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: dashCardDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withAlpha(185)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(70),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CommitmentAdminApp.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _dashTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.north_east,
                        size: 12,
                        color: Color(0xFF2EAD54),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: const TextStyle(
                          color: Color(0xFF2EAD54),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _TodayBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: CommitmentAdminApp.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: _dashTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessBox extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool trendUp;
  final IconData icon;
  final Color color;
  final Color background;

  const _BusinessBox({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = trendUp
        ? const Color(0xFF2EAD54)
        : const Color(0xFFE83E3E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: CommitmentAdminApp.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: _dashTitle,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp ? Icons.north_east : Icons.south_east,
                        size: 11,
                        color: trendColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        trend,
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

// ============================================================
// GROWTH CHART
// ============================================================

class GrowthChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  GrowthChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    const left = 45.0;
    const right = 20.0;
    const top = 20.0;
    const bottom = 42.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridPaint = Paint()
      ..color = const Color(0xFFE8EEF3)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = _dashBlue
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (values.isEmpty) return;

    final rawMax = values.reduce((a, b) => a > b ? a : b);
    final axisMax = ((rawMax / 100).ceil() * 100).toDouble().clamp(100.0, 1e9);

    for (int i = 0; i <= 4; i++) {
      final y = top + (chartHeight / 4) * i;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );

      final value = ((4 - i) * axisMax / 4).round().toString();

      _drawText(
        canvas,
        value,
        Offset(4, y - 7),
        const TextStyle(color: CommitmentAdminApp.textGrey, fontSize: 11),
      );
    }

    final step = values.length == 1
        ? chartWidth
        : chartWidth / (values.length - 1);

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = left + step * i;
      final normalized = values[i] / axisMax;
      final y = top + chartHeight - normalized * chartHeight;
      points.add(Offset(x, y));
    }

    // Smooth curve
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final cur = points[i];
      final midX = (prev.dx + cur.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, cur.dy, cur.dx, cur.dy);
    }

    // Gradient fill
    final baseY = top + chartHeight;
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, baseY)
      ..lineTo(points.first.dx, baseY)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x552A7DE1), Color(0x082A7DE1)],
      ).createShader(Rect.fromLTWH(0, top, size.width, chartHeight));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      canvas.drawCircle(point, 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3, Paint()..color = _dashBlue);

      final textWidth = _textWidth(labels[i]);

      _drawText(
        canvas,
        labels[i],
        Offset(point.dx - textWidth / 2, top + chartHeight + 14),
        const TextStyle(color: CommitmentAdminApp.textGrey, fontSize: 11),
      );
    }
  }

  double _textWidth(String text) {
    return text.length * 6.5;
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant GrowthChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}

// ============================================================
// USERS MODEL
// ============================================================

class UserRecord {
  String name;
  String username;
  String email;
  String phone;
  String business;
  String plan;
  int commitments;
  String status;
  String createdDate;
  int completed;
  int late;
  int missed;

  UserRecord({
    required this.name,
    this.username = '—',
    required this.email,
    required this.phone,
    required this.business,
    required this.plan,
    required this.commitments,
    required this.status,
    required this.createdDate,
    required this.completed,
    required this.late,
    required this.missed,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }
}

// ============================================================
// USERS PAGE
// ============================================================

class UsersPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const UsersPage({super.key, required this.onBack, required this.profile});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final searchController = TextEditingController();
  final tableScroll = ScrollController();

  String statusFilter = 'All';
  String planFilter = 'All';

  // Table box keeps the same height as before (5 rows x 90px = 450px),
  // but now shows 10 compact rows (45px each) inside it.
  static const int visibleRows = 10;
  static const double boxHeight = 450;
  static const double rowHeight = boxHeight / visibleRows;

  final List<UserRecord> users = [
    UserRecord(
      name: 'Riya Sharma',
      username: 'riya_sharma',
      email: 'riya@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'Tech Solutions',
      plan: 'Premium',
      commitments: 24,
      status: 'Active',
      createdDate: '12 Sep 2026',
      completed: 18,
      late: 3,
      missed: 2,
    ),
    UserRecord(
      name: 'Arun Kumar',
      username: 'arun_kumar',
      email: 'arun@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'ABC Corp',
      plan: 'Trial',
      commitments: 12,
      status: 'Active',
      createdDate: '10 Sep 2026',
      completed: 9,
      late: 1,
      missed: 1,
    ),
    UserRecord(
      name: 'Meera Patel',
      username: 'meera_patel',
      email: 'meera@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'Patel Designs',
      plan: 'Trial',
      commitments: 8,
      status: 'Pending',
      createdDate: '08 Sep 2026',
      completed: 4,
      late: 2,
      missed: 1,
    ),
    UserRecord(
      name: 'Vinoth Kumar',
      username: 'vinoth_kumar',
      email: 'vinoth@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'V-Systems',
      plan: 'Premium',
      commitments: 31,
      status: 'Active',
      createdDate: '05 Sep 2026',
      completed: 25,
      late: 3,
      missed: 2,
    ),
    UserRecord(
      name: 'Rahul Kumar',
      username: 'rahul_kumar',
      email: 'rahul@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'Kumar Enterprises',
      plan: 'Premium',
      commitments: 18,
      status: 'Active',
      createdDate: '03 Sep 2026',
      completed: 12,
      late: 2,
      missed: 1,
    ),
    UserRecord(
      name: 'Ananya Singh',
      username: 'ananya_singh',
      email: 'ananya@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'Singh Media',
      plan: 'Trial',
      commitments: 10,
      status: 'Pending',
      createdDate: '01 Sep 2026',
      completed: 7,
      late: 1,
      missed: 0,
    ),
    UserRecord(
      name: 'Karthik Raj',
      username: 'karthik_raj',
      email: 'karthik@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'KR Technologies',
      plan: 'Premium',
      commitments: 29,
      status: 'Active',
      createdDate: '29 Aug 2026',
      completed: 23,
      late: 2,
      missed: 2,
    ),
    UserRecord(
      name: 'Priya Menon',
      username: 'priya_menon',
      email: 'priya@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'PM Studios',
      plan: 'Trial',
      commitments: 6,
      status: 'Inactive',
      createdDate: '27 Aug 2026',
      completed: 3,
      late: 1,
      missed: 1,
    ),
    UserRecord(
      name: 'Sanjay Kumar',
      username: 'sanjay_kumar',
      email: 'sanjay@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'SK Solutions',
      plan: 'Premium',
      commitments: 22,
      status: 'Active',
      createdDate: '25 Aug 2026',
      completed: 17,
      late: 2,
      missed: 1,
    ),
    UserRecord(
      name: 'Divya Raj',
      username: 'divya_raj',
      email: 'divya@gmail.com',
      phone: '+91 XXXXX XXXXX',
      business: 'DR Designs',
      plan: 'Trial',
      commitments: 7,
      status: 'Pending',
      createdDate: '22 Aug 2026',
      completed: 5,
      late: 1,
      missed: 0,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    tableScroll.dispose();
    super.dispose();
  }

  List<UserRecord> get filteredUsers {
    final query = searchController.text.trim().toLowerCase();

    return users.where((user) {
      final searchMatch =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query) ||
          user.business.toLowerCase().contains(query);

      final statusMatch = statusFilter == 'All' || user.status == statusFilter;

      final planMatch = planFilter == 'All' || user.plan == planFilter;

      return searchMatch && statusMatch && planMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          children: [
            PageHeader(
              title: 'Users',
              subtitle: 'Manage and monitor application users',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildFilters(),
            const SizedBox(height: 20),
            _buildTable(),
            const SizedBox(height: 20),
            _buildCount(),
          ],
        ),
      ),
    );
  }

  // Search | Status | Plan | + Add User | Export CSV
  Widget _buildFilters() {
    final search = TextField(
      controller: searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: const InputDecoration(
        hintText: 'Search users...',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        prefixIcon: Icon(Icons.search, size: 20),
      ),
    );

    final status = _dropdown(
      label: 'Status',
      value: statusFilter,
      items: const ['All', 'Active', 'Pending', 'Inactive'],
      onChanged: (value) {
        setState(() {
          statusFilter = value!;
        });
      },
    );

    final plan = _dropdown(
      label: 'Plan',
      value: planFilter,
      items: const ['All', 'Trial', 'Premium'],
      onChanged: (value) {
        setState(() {
          planFilter = value!;
        });
      },
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(width: constraints.maxWidth, child: search),
                SizedBox(width: 126, child: status),
                SizedBox(width: 126, child: plan),
                _addUserButton(),
                _exportButton(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 10),
              SizedBox(width: 126, child: status),
              const SizedBox(width: 10),
              SizedBox(width: 126, child: plan),
              const SizedBox(width: 10),
              _addUserButton(),
              const SizedBox(width: 10),
              _exportButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CommitmentAdminApp.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          selectedItemBuilder: (_) => items
              .map(
                (item) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item == 'All' ? label : item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item == 'All' ? 'All $label' : item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTable() {
    final rows = filteredUsers;

    const headStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF34404B),
    );

    return Container(
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: const Color(0xFFE3F3FF),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('User', style: headStyle)),
                  Expanded(flex: 2, child: Text('Business', style: headStyle)),
                  Expanded(child: Text('Plan', style: headStyle)),
                  Expanded(child: Text('Commitments', style: headStyle)),
                  Expanded(child: Text('Status', style: headStyle)),
                  Expanded(child: Text('Created Date', style: headStyle)),
                  SizedBox(width: 40, child: Text('')),
                ],
              ),
            ),
            // Same box size as before; 10 compact rows fit inside it.
            SizedBox(
              height: boxHeight,
              child: rows.isEmpty
                  ? const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: CommitmentAdminApp.textGrey),
                      ),
                    )
                  : Scrollbar(
                      controller: tableScroll,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: tableScroll,
                        itemCount: rows.length,
                        itemExtent: rowHeight,
                        itemBuilder: (_, index) => _userRow(rows[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userRow(UserRecord user) {
    const cellStyle = TextStyle(fontSize: 12);

    return InkWell(
      onTap: () => _showUserDetails(user),
      child: Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: CommitmentAdminApp.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: CommitmentAdminApp.lightBlue,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: CommitmentAdminApp.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CommitmentAdminApp.textGrey,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                user.business,
                overflow: TextOverflow.ellipsis,
                style: cellStyle,
              ),
            ),
            Expanded(child: _planChip(user.plan)),
            Expanded(child: Text('${user.commitments}', style: cellStyle)),
            Expanded(child: _statusChip(user.status)),
            Expanded(child: Text(user.createdDate, style: cellStyle)),
            SizedBox(
              width: 40,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'View') {
                    _showUserDetails(user);
                  } else if (value == 'Edit') {
                    _editUser(user);
                  } else if (value == 'Disable') {
                    _disableUser(user);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'View', child: Text('View Details')),
                  PopupMenuItem(value: 'Edit', child: Text('Edit User')),
                  PopupMenuItem(value: 'Disable', child: Text('Disable User')),
                ],
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planChip(String plan) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: CommitmentAdminApp.lightBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          plan,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color background;
    Color text;

    if (status == 'Active') {
      background = const Color(0xFFE6F6EA);
      text = const Color(0xFF2E9E4B);
    } else if (status == 'Pending') {
      background = const Color(0xFFFFF1D9);
      text = const Color(0xFFE59416);
    } else {
      background = const Color(0xFFF0F2F4);
      text = const Color(0xFF737E88);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: text,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCount() {
    final total = filteredUsers.length;

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Showing $total of $total',
        style: const TextStyle(
          color: CommitmentAdminApp.textGrey,
          fontSize: 13,
        ),
      ),
    );
  }

  // Button only - intentionally does nothing (no download).
  Widget _exportButton() {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_outlined, size: 17),
        label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF12324A),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _addUserButton() {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: _addUser,
        icon: const Icon(Icons.add, size: 17),
        label: const Text('Add User', style: TextStyle(fontSize: 12)),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  void _showUserDetails(UserRecord user) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 650,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: CommitmentAdminApp.lightBlue,
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            color: CommitmentAdminApp.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: CommitmentAdminApp.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 18),
                  _detailGrid(user),
                  const SizedBox(height: 22),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Commitment Performance',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _performanceBox(
                          'Completed',
                          user.completed,
                          const Color(0xFFE6F6EA),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _performanceBox(
                          'Late',
                          user.late,
                          const Color(0xFFFFF1D9),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _performanceBox(
                          'Missed',
                          user.missed,
                          const Color(0xFFFFE6E6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailGrid(UserRecord user) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 4.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _detailItem('Username', user.username),
        _detailItem('Phone', user.phone),
        _detailItem('Business', user.business),
        _detailItem('Plan', user.plan),
        _detailItem('Status', user.status),
        _detailItem('Commitments', '${user.commitments}'),
        _detailItem('Created Date', user.createdDate),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(color: CommitmentAdminApp.textGrey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _performanceBox(String title, int value, Color background) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }

  void _addUser() {
    final name = TextEditingController();
    final username = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final business = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add User'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: username,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixText: '+91 ',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: business,
                        decoration: const InputDecoration(
                          labelText: 'Business',
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            error!,
                            style: const TextStyle(
                              color: Color(0xFFE83E3E),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (name.text.trim().isEmpty ||
                        username.text.trim().isEmpty ||
                        !email.text.contains('@')) {
                      setDialogState(() {
                        error = 'Enter name, username and a valid email';
                      });
                      return;
                    }

                    if (phone.text.length != 10) {
                      setDialogState(() {
                        error = 'Phone number must be 10 digits';
                      });
                      return;
                    }

                    setState(() {
                      users.insert(
                        0,
                        UserRecord(
                          name: name.text.trim(),
                          username: username.text.trim(),
                          email: email.text.trim(),
                          phone: '+91 ${phone.text}',
                          business: business.text.trim().isEmpty
                              ? '—'
                              : business.text.trim(),
                          plan: 'Trial',
                          commitments: 0,
                          status: 'Active',
                          createdDate: '28 Sep 2026',
                          completed: 0,
                          late: 0,
                          missed: 0,
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editUser(UserRecord user) {
    final name = TextEditingController(text: user.name);
    final username = TextEditingController(text: user.username);
    final email = TextEditingController(text: user.email);
    final business = TextEditingController(text: user.business);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: username,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: business,
                    decoration: const InputDecoration(labelText: 'Business'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  user.name = name.text.trim();
                  user.username = username.text.trim();
                  user.email = email.text.trim();
                  user.business = business.text.trim();
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _disableUser(UserRecord user) {
    setState(() {
      user.status = 'Inactive';
    });
  }
}

// ============================================================
// COMMITMENT MODEL
// ============================================================

class CommitmentRecord {
  String title;
  String user;
  String type;
  String dateTime;
  String reminder;
  String status;
  String description;
  String locationOrLink;

  CommitmentRecord({
    required this.title,
    required this.user,
    required this.type,
    required this.dateTime,
    required this.reminder,
    required this.status,
    required this.description,
    required this.locationOrLink,
  });
}

// ============================================================
// COMMITMENTS PAGE
// ============================================================

class CommitmentsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const CommitmentsPage({
    super.key,
    required this.onBack,
    required this.profile,
  });

  @override
  State<CommitmentsPage> createState() => _CommitmentsPageState();
}

class _CommitmentsPageState extends State<CommitmentsPage> {
  final searchController = TextEditingController();
  final tableScroll = ScrollController();

  String statusFilter = 'All';
  String typeFilter = 'All';
  String dateFilter = 'All';

  // Table box keeps the same height as before (5 rows x 78px = 390px),
  // but now shows 10 compact rows (39px each) inside it.
  static const int visibleRows = 10;
  static const double boxHeight = 390;
  static const double rowHeight = boxHeight / visibleRows;

  final List<CommitmentRecord> commitments = [
    CommitmentRecord(
      title: 'Team Meeting',
      user: 'Riya Sharma',
      type: 'Online',
      dateTime: '25 Sep 2026 • 10:00 AM',
      reminder: '15 min',
      status: 'Created',
      description: 'Weekly team meeting.',
      locationOrLink: 'https://meet.example.com/team',
    ),
    CommitmentRecord(
      title: 'Complete Assignment',
      user: 'Arun Kumar',
      type: 'Task',
      dateTime: '25 Sep 2026 • 11:30 AM',
      reminder: '30 min',
      status: 'Completed',
      description: 'Complete college assignment.',
      locationOrLink: '—',
    ),
    CommitmentRecord(
      title: 'Client Meeting',
      user: 'Meera Patel',
      type: 'Online',
      dateTime: '25 Sep 2026 • 02:00 PM',
      reminder: '15 min',
      status: 'Late',
      description: 'Client project discussion.',
      locationOrLink: 'https://meet.example.com/client',
    ),
    CommitmentRecord(
      title: 'Doctor Appointment',
      user: 'Rahul Kumar',
      type: 'In-person',
      dateTime: '25 Sep 2026 • 04:00 PM',
      reminder: '1 hr',
      status: 'Missed',
      description: 'Doctor appointment.',
      locationOrLink: 'Chennai',
    ),
    CommitmentRecord(
      title: 'Project Review',
      user: 'Ananya Singh',
      type: 'In-person',
      dateTime: '25 Sep 2026 • 05:30 PM',
      reminder: '30 min',
      status: 'Cancelled',
      description: 'Project review.',
      locationOrLink: 'Office',
    ),
    CommitmentRecord(
      title: 'Design Review',
      user: 'Vinoth Kumar',
      type: 'Online',
      dateTime: '26 Sep 2026 • 09:00 AM',
      reminder: '15 min',
      status: 'Created',
      description: 'Review UI design.',
      locationOrLink: 'https://meet.example.com/design',
    ),
    CommitmentRecord(
      title: 'Database Task',
      user: 'Karthik Raj',
      type: 'Task',
      dateTime: '26 Sep 2026 • 11:00 AM',
      reminder: '30 min',
      status: 'Created',
      description: 'Database implementation task.',
      locationOrLink: '—',
    ),
    CommitmentRecord(
      title: 'Marketing Call',
      user: 'Priya Menon',
      type: 'Online',
      dateTime: '27 Sep 2026 • 10:00 AM',
      reminder: '15 min',
      status: 'Completed',
      description: 'Marketing discussion.',
      locationOrLink: 'https://meet.example.com/marketing',
    ),
    CommitmentRecord(
      title: 'Office Visit',
      user: 'Sanjay Kumar',
      type: 'In-person',
      dateTime: '27 Sep 2026 • 01:00 PM',
      reminder: '1 hr',
      status: 'Late',
      description: 'Office visit.',
      locationOrLink: 'Chennai Office',
    ),
    CommitmentRecord(
      title: 'Study Task',
      user: 'Divya Raj',
      type: 'Task',
      dateTime: '28 Sep 2026 • 06:00 PM',
      reminder: '30 min',
      status: 'Created',
      description: 'Study task.',
      locationOrLink: '—',
    ),
    CommitmentRecord(
      title: 'Planning Meeting',
      user: 'Riya Sharma',
      type: 'Online',
      dateTime: '29 Sep 2026 • 09:30 AM',
      reminder: '15 min',
      status: 'Created',
      description: 'Planning meeting.',
      locationOrLink: 'https://meet.example.com/planning',
    ),
    CommitmentRecord(
      title: 'Gym Session',
      user: 'Arun Kumar',
      type: 'In-person',
      dateTime: '30 Sep 2026 • 06:30 PM',
      reminder: '30 min',
      status: 'Created',
      description: 'Gym session.',
      locationOrLink: 'Fitness Centre',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    tableScroll.dispose();
    super.dispose();
  }

  List<CommitmentRecord> get filteredCommitments {
    final query = searchController.text.trim().toLowerCase();

    return commitments.where((item) {
      final searchMatch =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.user.toLowerCase().contains(query);

      final statusMatch = statusFilter == 'All' || item.status == statusFilter;

      final typeMatch = typeFilter == 'All' || item.type == typeFilter;

      final dateMatch =
          dateFilter == 'All' || item.dateTime.contains(dateFilter);

      return searchMatch && statusMatch && typeMatch && dateMatch;
    }).toList();
  }

  int get total => commitments.length;

  int get dueToday =>
      commitments.where((e) => e.dateTime.contains('25 Sep 2026')).length;

  int get completed => commitments.where((e) => e.status == 'Completed').length;

  int get late => commitments.where((e) => e.status == 'Late').length;

  int get missed => commitments.where((e) => e.status == 'Missed').length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
        child: Column(
          children: [
            PageHeader(
              title: 'Commitments',
              subtitle: 'Manage and monitor all user commitments',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildSummaryCards(),
            const SizedBox(height: 14),
            _buildFilters(),
            const SizedBox(height: 14),
            _buildTable(),
            const SizedBox(height: 12),
            _buildCount(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = <Widget>[
          SummaryCard(
            title: 'Total',
            value: '$total',
            icon: Icons.calendar_month_outlined,
            color: const Color(0xFF2F80B7),
          ),
          SummaryCard(
            title: 'Due Today',
            value: '$dueToday',
            icon: Icons.today_outlined,
            color: const Color(0xFF7B61FF),
          ),
          SummaryCard(
            title: 'Completed',
            value: '$completed',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF2EAD54),
          ),
          SummaryCard(
            title: 'Late',
            value: '$late',
            icon: Icons.schedule_outlined,
            color: const Color(0xFFE99A13),
          ),
          SummaryCard(
            title: 'Missed',
            value: '$missed',
            icon: Icons.cancel_outlined,
            color: const Color(0xFFE83E3E),
          ),
        ];

        if (constraints.maxWidth < 1050) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards
                .map((card) => SizedBox(width: 190, child: card))
                .toList(),
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }

  // Search | Status | Type | Date | Export CSV
  Widget _buildFilters() {
    const statusItems = [
      'All',
      'Created',
      'Completed',
      'Late',
      'Missed',
      'Cancelled',
    ];
    const typeItems = ['All', 'Task', 'Online', 'In-person'];
    const dateItems = [
      'All',
      '25 Sep 2026',
      '26 Sep 2026',
      '27 Sep 2026',
      '28 Sep 2026',
      '29 Sep 2026',
      '30 Sep 2026',
    ];

    final search = TextField(
      controller: searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: const InputDecoration(
        hintText: 'Search commitments...',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        prefixIcon: Icon(Icons.search, size: 20),
      ),
    );

    final statusBox = _filterBox('Status', statusFilter, statusItems, (value) {
      setState(() {
        statusFilter = value!;
      });
    });

    final typeBox = _filterBox('Type', typeFilter, typeItems, (value) {
      setState(() {
        typeFilter = value!;
      });
    });

    final dateBox = _filterBox('Date', dateFilter, dateItems, (value) {
      setState(() {
        dateFilter = value!;
      });
    });

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(width: constraints.maxWidth, child: search),
                SizedBox(width: 150, child: statusBox),
                SizedBox(width: 150, child: typeBox),
                SizedBox(width: 170, child: dateBox),
                _exportButton(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 10),
              SizedBox(width: 140, child: statusBox),
              const SizedBox(width: 10),
              SizedBox(width: 140, child: typeBox),
              const SizedBox(width: 10),
              SizedBox(width: 160, child: dateBox),
              const SizedBox(width: 10),
              _exportButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _exportButton() {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: _exportCsv,
        icon: const Icon(Icons.download_outlined, size: 18),
        label: const Text('Export CSV'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF12324A),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }

  Widget _filterBox(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CommitmentAdminApp.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label),
          selectedItemBuilder: (_) => items
              .map(
                (item) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item == 'All' ? label : item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item == 'All' ? 'All $label' : item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTable() {
    final rows = filteredCommitments;

    const headStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF34404B),
    );

    return Container(
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 1100
                ? 1100.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: const Color(0xFFE3F3FF),
                      child: const Row(
                        children: [
                          Expanded(child: Text('Commitment', style: headStyle)),
                          SizedBox(
                            width: 150,
                            child: Text('User', style: headStyle),
                          ),
                          SizedBox(
                            width: 115,
                            child: Text('Type', style: headStyle),
                          ),
                          SizedBox(
                            width: 190,
                            child: Text('Date / Time', style: headStyle),
                          ),
                          SizedBox(
                            width: 110,
                            child: Text('Reminder', style: headStyle),
                          ),
                          SizedBox(
                            width: 130,
                            child: Text('Status', style: headStyle),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text('Actions', style: headStyle),
                          ),
                        ],
                      ),
                    ),
                    // Same box size as before; 10 compact rows fit inside it.
                    SizedBox(
                      height: boxHeight,
                      child: rows.isEmpty
                          ? const Center(
                              child: Text(
                                'No commitments found',
                                style: TextStyle(
                                  color: CommitmentAdminApp.textGrey,
                                ),
                              ),
                            )
                          : Scrollbar(
                              controller: tableScroll,
                              thumbVisibility: true,
                              child: ListView.builder(
                                controller: tableScroll,
                                itemCount: rows.length,
                                itemExtent: rowHeight,
                                itemBuilder: (_, index) =>
                                    _commitmentRow(rows[index]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _commitmentRow(CommitmentRecord item) {
    const cellStyle = TextStyle(fontSize: 12);

    return InkWell(
      onTap: () => _showDetails(item),
      child: Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: CommitmentAdminApp.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(width: 150, child: Text(item.user, style: cellStyle)),
            SizedBox(width: 115, child: _typeChip(item.type)),
            SizedBox(width: 190, child: Text(item.dateTime, style: cellStyle)),
            SizedBox(width: 110, child: Text(item.reminder, style: cellStyle)),
            SizedBox(width: 130, child: _commitmentStatus(item.status)),
            SizedBox(
              width: 60,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'View') {
                    _showDetails(item);
                  } else if (value == 'Edit') {
                    _editCommitment(item);
                  } else if (value == 'Delete') {
                    _deleteCommitment(item);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'View', child: Text('View Details')),
                  PopupMenuItem(value: 'Edit', child: Text('Edit')),
                  PopupMenuItem(value: 'Delete', child: Text('Delete')),
                ],
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          type,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _commitmentStatus(String status) {
    Color bg = const Color(0xFFEAF5FD);
    Color fg = CommitmentAdminApp.primary;

    if (status == 'Completed') {
      bg = const Color(0xFFE6F6EA);
      fg = const Color(0xFF2E9E4B);
    } else if (status == 'Late') {
      bg = const Color(0xFFFFF1D9);
      fg = const Color(0xFFE59416);
    } else if (status == 'Missed') {
      bg = const Color(0xFFFFE6E6);
      fg = const Color(0xFFE83E3E);
    } else if (status == 'Cancelled') {
      bg = const Color(0xFFF0F2F4);
      fg = const Color(0xFF737E88);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: fg,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCount() {
    final total = filteredCommitments.length;

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Showing $total of $total',
        style: const TextStyle(
          color: CommitmentAdminApp.textGrey,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showDetails(CommitmentRecord item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item.title),
          content: SizedBox(
            width: 550,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _commitmentDetail('User', item.user),
                _commitmentDetail('Type', item.type),
                _commitmentDetail('Date / Time', item.dateTime),
                _commitmentDetail('Reminder', item.reminder),
                _commitmentDetail('Status', item.status),
                _commitmentDetail('Description', item.description),
                _commitmentDetail(
                  item.type == 'Online'
                      ? 'Meeting Link'
                      : item.type == 'In-person'
                      ? 'Location'
                      : 'Details',
                  item.locationOrLink,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _commitmentDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CommitmentAdminApp.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(color: CommitmentAdminApp.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _editCommitment(CommitmentRecord item) {
    final title = TextEditingController(text: item.title);
    final description = TextEditingController(text: item.description);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Commitment'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Commitment'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  item.title = title.text.trim();
                  item.description = description.text.trim();
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCommitment(CommitmentRecord item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Commitment?'),
          content: Text('Are you sure you want to delete "${item.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE83E3E),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  commitments.remove(item);
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _exportCsv() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export is for demonstration only.')),
    );
  }
}

// ============================================================
// PEOPLE PAGE
// ============================================================

class PeoplePage extends StatelessWidget {
  final VoidCallback onBack;
  final Widget profile;

  const PeoplePage({super.key, required this.onBack, required this.profile});

  static const List<_PersonRecord> _people = [
    _PersonRecord(
      name: 'Meera Patel',
      company: 'TechNova Solutions',
      linkedPerson: 'Rahul Kumar',
      commitments: 5,
      lastInteraction: '25 Sep 2026 · 10:30 AM',
    ),
    _PersonRecord(
      name: 'Rahul Kumar',
      company: 'HealthPlus Clinic',
      linkedPerson: 'Meera Patel',
      commitments: 3,
      lastInteraction: '25 Sep 2026 · 09:15 AM',
    ),
    _PersonRecord(
      name: 'Ananya Singh',
      company: 'BuildPro Developers',
      linkedPerson: 'Vinoth Kumar',
      commitments: 4,
      lastInteraction: '25 Sep 2026 · 08:45 AM',
    ),
    _PersonRecord(
      name: 'Vinoth Kumar',
      company: 'Innovate Design Studio',
      linkedPerson: 'Ananya Singh',
      commitments: 2,
      lastInteraction: '24 Sep 2026 · 06:20 PM',
    ),
    _PersonRecord(
      name: 'Karthik Raj',
      company: 'DataCore Systems',
      linkedPerson: 'Divya Raj',
      commitments: 6,
      lastInteraction: '24 Sep 2026 · 05:10 PM',
    ),
    _PersonRecord(
      name: 'Priya Menon',
      company: 'MarketEdge Pvt Ltd',
      linkedPerson: 'Sanjay Kumar',
      commitments: 3,
      lastInteraction: '24 Sep 2026 · 03:50 PM',
    ),
    _PersonRecord(
      name: 'Sanjay Kumar',
      company: 'Prime Office Services',
      linkedPerson: 'Priya Menon',
      commitments: 2,
      lastInteraction: '24 Sep 2026 · 02:30 PM',
    ),
    _PersonRecord(
      name: 'Divya Raj',
      company: 'EduSphere Academy',
      linkedPerson: 'Karthik Raj',
      commitments: 4,
      lastInteraction: '24 Sep 2026 · 01:20 PM',
    ),
    _PersonRecord(
      name: 'Riya Sharma',
      company: 'PlanAhead Consultants',
      linkedPerson: 'Arun Kumar',
      commitments: 3,
      lastInteraction: '24 Sep 2026 · 11:40 AM',
    ),
    _PersonRecord(
      name: 'Arun Kumar',
      company: 'FitLife Gym',
      linkedPerson: 'Riya Sharma',
      commitments: 2,
      lastInteraction: '24 Sep 2026 · 10:00 AM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'People',
              subtitle: 'People management and monitoring',
              onBack: onBack,
              action: profile,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 1020
                    ? 1020.0
                    : constraints.maxWidth;

                return Container(
                  width: constraints.maxWidth,
                  decoration: cardDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                            4: FlexColumnWidth(1),
                          },
                          border: const TableBorder(
                            horizontalInside: BorderSide(
                              color: Color(0xFFE8EEF4),
                            ),
                          ),
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE3F3FF),
                              ),
                              children: [
                                _peopleCell(_peopleHeading('Person')),
                                _peopleCell(_peopleHeading('Company')),
                                _peopleCell(_peopleHeading('Linked Person')),
                                _peopleCell(_peopleHeading('Commitments')),
                                _peopleCell(_peopleHeading('Last Interaction')),
                              ],
                            ),
                            for (final person in _people)
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                children: [
                                  _peopleCell(
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor:
                                              CommitmentAdminApp.lightBlue,
                                          child: Text(
                                            person.initials,
                                            style: const TextStyle(
                                              color: CommitmentAdminApp.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            person.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () =>
                                        _showPersonDetails(context, person),
                                  ),
                                  _peopleCell(
                                    _peopleValue(person.company),
                                    onTap: () =>
                                        _showPersonDetails(context, person),
                                  ),
                                  _peopleCell(
                                    _peopleValue(person.linkedPerson),
                                    onTap: () =>
                                        _showPersonDetails(context, person),
                                  ),
                                  _peopleCell(
                                    _peopleValue('${person.commitments}'),
                                    onTap: () =>
                                        _showPersonDetails(context, person),
                                  ),
                                  _peopleCell(
                                    _peopleValue(person.lastInteraction),
                                    onTap: () =>
                                        _showPersonDetails(context, person),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _peopleCell(
    Widget child, {
    Alignment alignment = Alignment.centerLeft,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: child,
      ),
    );
  }

  Widget _peopleHeading(String label) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF34404B),
      ),
    );
  }

  Widget _peopleValue(String value) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 12, color: Color(0xFF34404B)),
    );
  }

  void _showPersonDetails(BuildContext context, _PersonRecord person) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(person.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${person.company}'),
            Text('Linked Person: ${person.linkedPerson}'),
            Text('Commitments: ${person.commitments}'),
            Text('Last Interaction: ${person.lastInteraction}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _PersonRecord {
  const _PersonRecord({
    required this.name,
    required this.company,
    required this.linkedPerson,
    required this.commitments,
    required this.lastInteraction,
  });

  final String name;
  final String company;
  final String linkedPerson;
  final int commitments;
  final String lastInteraction;

  String get initials =>
      name.split(' ').map((part) => part[0]).take(2).join().toUpperCase();
}

// ============================================================
// LOCATION & MAPS PAGE
// ============================================================

class LocationMapsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const LocationMapsPage({
    super.key,
    required this.onBack,
    required this.profile,
  });

  @override
  State<LocationMapsPage> createState() => _LocationMapsPageState();
}

class _LocationMapsPageState extends State<LocationMapsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_MapLocation> _locations = [
    _MapLocation(name: 'Meera Patel', x: 0.16, y: 0.33),
    _MapLocation(name: 'Rahul Kumar', x: 0.48, y: 0.43),
    _MapLocation(name: 'Ananya Singh', x: 0.76, y: 0.60),
    _MapLocation(name: 'Vinoth Kumar', x: 0.34, y: 0.76),
  ];

  List<_MapLocation> get _visibleLocations {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _locations;
    return _locations
        .where((location) => location.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchLocations() {
    setState(() => _searchQuery = _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Location & Maps',
              subtitle: 'User location and travel monitoring',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildSearch(),
            const SizedBox(height: 14),
            _buildMap(),
            const SizedBox(height: 14),
            _buildOverview(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final searchField = TextField(
            controller: _searchController,
            onSubmitted: (_) => _searchLocations(),
            decoration: const InputDecoration(
              hintText: 'Search location or user...',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          );

          final searchButton = SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: _searchLocations,
              icon: const Icon(Icons.search, size: 17),
              label: const Text('Search'),
            ),
          );

          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [searchField, const SizedBox(height: 10), searchButton],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12),
              searchButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 260,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEAF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x161E5A8C),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const CustomPaint(painter: _MapPlaceholderPainter()),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(235),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x180B2A5B),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 16, color: _dashBlue),
                      SizedBox(width: 6),
                      Text(
                        'Live user locations',
                        style: TextStyle(
                          color: _dashTitle,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final location in _visibleLocations)
                Positioned(
                  left: (constraints.maxWidth * location.x).clamp(
                    10.0,
                    constraints.maxWidth - 155,
                  ),
                  top: (constraints.maxHeight * location.y).clamp(
                    48.0,
                    constraints.maxHeight - 42,
                  ),
                  child: _MapUserPin(name: location.name),
                ),
              if (_visibleLocations.isEmpty)
                const Center(
                  child: Text(
                    'No matching locations found',
                    style: TextStyle(
                      color: _dashTitle,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(235),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_visibleLocations.length} users shown',
                    style: const TextStyle(
                      color: _dashTitle,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverview() {
    const cards = [
      _LocationSummary(
        title: 'Total Distance',
        value: '42 km',
        icon: Icons.route_outlined,
        color: Color(0xFF2F80B7),
      ),
      _LocationSummary(
        title: 'Average Distance',
        value: '8.4 km',
        icon: Icons.straighten_outlined,
        color: Color(0xFF7B61FF),
      ),
      _LocationSummary(
        title: 'Average Travel',
        value: '32 min',
        icon: Icons.directions_car_outlined,
        color: Color(0xFF2EAD67),
      ),
      _LocationSummary(
        title: 'Leave By Alerts',
        value: '5 alerts',
        icon: Icons.alarm_on_outlined,
        color: Color(0xFFE5A534),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location & Travel Overview',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CommitmentAdminApp.textDark,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              final spacing = 10.0;
              final cardWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 10,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width: cardWidth,
                      child: _LocationSummaryCard(summary: card),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MapLocation {
  final String name;
  final double x;
  final double y;

  const _MapLocation({required this.name, required this.x, required this.y});
}

class _MapUserPin extends StatelessWidget {
  final String name;

  const _MapUserPin({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 4, 9, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDEAF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0B2A5B),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF53A9E8), Color(0xFF287DB8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              color: _dashTitle,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  const _MapPlaceholderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFEAF3E9);
    canvas.drawRect(Offset.zero & size, background);

    final parkPaint = Paint()..color = const Color(0xFFD7EAD1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.55,
          size.width * 0.2,
          size.height * 0.28,
        ),
        const Radius.circular(26),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.64,
          size.height * 0.08,
          size.width * 0.25,
          size.height * 0.22,
        ),
        const Radius.circular(30),
      ),
      parkPaint,
    );

    final thinRoad = Paint()
      ..color = const Color(0xFFFCFDF8)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roadBorder = Paint()
      ..color = const Color(0xFFD5E0D5)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roads = [
      Path()
        ..moveTo(size.width * 0.08, size.height * 0.42)
        ..cubicTo(
          size.width * 0.32,
          size.height * 0.35,
          size.width * 0.55,
          size.height * 0.52,
          size.width * 0.92,
          size.height * 0.37,
        ),
      Path()
        ..moveTo(size.width * 0.55, size.height * 0.05)
        ..cubicTo(
          size.width * 0.48,
          size.height * 0.32,
          size.width * 0.61,
          size.height * 0.63,
          size.width * 0.52,
          size.height * 0.96,
        ),
      Path()
        ..moveTo(size.width * 0.07, size.height * 0.86)
        ..cubicTo(
          size.width * 0.34,
          size.height * 0.68,
          size.width * 0.72,
          size.height * 0.83,
          size.width * 0.94,
          size.height * 0.62,
        ),
    ];

    for (final road in roads) {
      canvas.drawPath(road, roadBorder);
      canvas.drawPath(road, thinRoad);
    }

    final minorRoad = Paint()
      ..color = const Color(0xFFF9FCF7)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 1; i <= 5; i++) {
      final x = size.width * i / 6;
      final path = Path()
        ..moveTo(x, 0)
        ..cubicTo(
          x - 18,
          size.height * 0.35,
          x + 20,
          size.height * 0.65,
          x - 8,
          size.height,
        );
      canvas.drawPath(path, minorRoad);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationSummary {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _LocationSummary({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _LocationSummaryCard extends StatelessWidget {
  final _LocationSummary summary;

  const _LocationSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Tilt3D(
      maxTilt: 0.045,
      child: _LocationSummaryTile(summary: summary),
    );
  }
}

class _LocationSummaryTile extends StatefulWidget {
  final _LocationSummary summary;

  const _LocationSummaryTile({required this.summary});

  @override
  State<_LocationSummaryTile> createState() => _LocationSummaryTileState();
}

class _LocationSummaryTileState extends State<_LocationSummaryTile> {
  String _period = 'Today';

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    return Container(
      height: 118,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: dashCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [summary.color, summary.color.withAlpha(175)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: summary.color.withAlpha(65),
                  blurRadius: 9,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(summary.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    summary.value,
                    style: const TextStyle(
                      color: _dashTitle,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  height: 26,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _period,
                      isDense: true,
                      iconSize: 15,
                      style: const TextStyle(
                        color: CommitmentAdminApp.textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(
                          value: 'This week',
                          child: Text('This week'),
                        ),
                        DropdownMenuItem(
                          value: 'This month',
                          child: Text('This month'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _period = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FOLLOW-UPS PAGE
// ============================================================

class FollowUpsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const FollowUpsPage({super.key, required this.onBack, required this.profile});

  @override
  State<FollowUpsPage> createState() => _FollowUpsPageState();
}

class _FollowUpsPageState extends State<FollowUpsPage> {
  static const List<String> _filters = [
    'All',
    'Open',
    'Due Today',
    'Overdue',
    'Completed',
  ];

  String _selectedFilter = 'Due Today';

  static const List<_FollowUpRecord> _followUps = [
    _FollowUpRecord(
      title: 'Call client',
      user: 'Meera',
      commitment: 'Marketing Meeting',
      due: 'Today',
    ),
    _FollowUpRecord(
      title: 'Send proposal',
      user: 'Rahul',
      commitment: 'Project Discussion',
      due: 'Oct 6',
    ),
    _FollowUpRecord(
      title: 'Check payment',
      user: 'Ananya',
      commitment: 'Payment Follow-up',
      due: 'Oct 7',
    ),
    _FollowUpRecord(
      title: 'Meeting reminder',
      user: 'Vinoth',
      commitment: 'Client Meeting',
      due: 'Oct 4',
    ),
    _FollowUpRecord(
      title: 'Review document',
      user: 'Priya',
      commitment: 'Document Request',
      due: 'Oct 8',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Follow Ups',
              subtitle: 'Track and manage follow-up commitments',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildStats(),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < _filters.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(_filters[index]),
                      selected: _selectedFilter == _filters[index],
                      onSelected: (_) {
                        setState(() => _selectedFilter = _filters[index]);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 2),
              child: Text(
                _selectedFilter == 'All' ? 'All follow-ups' : _selectedFilter,
                style: const TextStyle(
                  color: _dashTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _buildFollowUpsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    const stats = [
      _FollowUpStat(
        title: 'Open',
        value: '24',
        icon: Icons.pending_actions_outlined,
        color: Color(0xFF2F80B7),
      ),
      _FollowUpStat(
        title: 'Due Today',
        value: '8',
        icon: Icons.today_outlined,
        color: Color(0xFFE5A534),
      ),
      _FollowUpStat(
        title: 'Overdue',
        value: '5',
        icon: Icons.warning_amber_rounded,
        color: Color(0xFFE35D5D),
      ),
      _FollowUpStat(
        title: 'Completed',
        value: '42',
        icon: Icons.task_alt_outlined,
        color: Color(0xFF2EAD67),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const spacing = 10.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: tileWidth,
                child: _FollowUpStatTile(
                  stat: stat,
                  selected: _selectedFilter == stat.title,
                  onTap: () => setState(() => _selectedFilter = stat.title),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFollowUpsTable() {
    final visibleFollowUps =
        _selectedFilter == 'All' || _selectedFilter == 'Due Today'
        ? _followUps
        : const <_FollowUpRecord>[];

    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minWidth = 720.0;
            final tableWidth = constraints.maxWidth < minWidth
                ? minWidth
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    const _FollowUpTableRow(
                      isHeader: true,
                      followUp: 'Follow Up',
                      user: 'User',
                      commitment: 'Original Commitment',
                      due: 'Due',
                    ),
                    if (visibleFollowUps.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 26),
                        child: Text(
                          'No follow-up details for this selection',
                          style: TextStyle(
                            color: CommitmentAdminApp.textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      for (final followUp in visibleFollowUps)
                        _FollowUpTableRow(
                          followUp: followUp.title,
                          user: followUp.user,
                          commitment: followUp.commitment,
                          due: followUp.due,
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FollowUpRecord {
  final String title;
  final String user;
  final String commitment;
  final String due;

  const _FollowUpRecord({
    required this.title,
    required this.user,
    required this.commitment,
    required this.due,
  });
}

class _FollowUpStat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _FollowUpStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _FollowUpStatTile extends StatelessWidget {
  final _FollowUpStat stat;
  final bool selected;
  final VoidCallback onTap;

  const _FollowUpStatTile({
    required this.stat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tilt3D(
      maxTilt: 0.045,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? stat.color : const Color(0xFFE4EDF4),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x101E5A8C),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [stat.color, stat.color.withAlpha(175)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: stat.color.withAlpha(55),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(stat.icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CommitmentAdminApp.textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.value,
                        style: const TextStyle(
                          color: _dashTitle,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
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
}

class _FollowUpTableRow extends StatelessWidget {
  final bool isHeader;
  final String followUp;
  final String user;
  final String commitment;
  final String due;

  const _FollowUpTableRow({
    this.isHeader = false,
    required this.followUp,
    required this.user,
    required this.commitment,
    required this.due,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isHeader ? const Color(0xFF34404B) : CommitmentAdminApp.textDark,
      fontSize: 12,
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
    );

    Widget cell(String value, {int flex = 2}) {
      return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFE3F3FF) : Colors.white,
        border: isHeader
            ? null
            : const Border(top: BorderSide(color: CommitmentAdminApp.border)),
      ),
      child: Row(
        children: [
          cell(followUp, flex: 2),
          cell(user, flex: 1),
          cell(commitment, flex: 3),
          cell(due, flex: 1),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS PAGE
// ============================================================

class NotificationsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const NotificationsPage({
    super.key,
    required this.onBack,
    required this.profile,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const List<_NotificationDelivery> _deliveries = [
    _NotificationDelivery(
      time: '10:42 AM',
      user: 'Meera Patel',
      alert: 'Commitment Due',
      channel: 'Push',
      status: 'Delivered',
    ),
    _NotificationDelivery(
      time: '10:35 AM',
      user: 'Rahul Kumar',
      alert: 'Follow-up Due',
      channel: 'Email',
      status: 'Delivered',
    ),
    _NotificationDelivery(
      time: '10:21 AM',
      user: 'Ananya Singh',
      alert: 'Reminder',
      channel: 'Push',
      status: 'Pending',
    ),
    _NotificationDelivery(
      time: '09:58 AM',
      user: 'Vinoth Kumar',
      alert: 'Commitment',
      channel: 'Email',
      status: 'Failed',
    ),
    _NotificationDelivery(
      time: '09:42 AM',
      user: 'Priya Menon',
      alert: 'Follow-up',
      channel: 'Push',
      status: 'Delivered',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Notifications',
              subtitle: 'Notification delivery monitoring',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildDeliveryHealth(),
            const SizedBox(height: 18),
            _buildDeliveryTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryHealth() {
    const metrics = [
      _DeliveryMetric(
        label: 'Sent',
        value: '92%',
        color: Color(0xFF2F80B7),
        icon: Icons.send_outlined,
        progress: 0.92,
      ),
      _DeliveryMetric(
        label: 'Delivered',
        value: '87%',
        color: Color(0xFF2EAD67),
        icon: Icons.mark_email_read_outlined,
        progress: 0.87,
      ),
      _DeliveryMetric(
        label: 'Failed',
        value: '3%',
        color: Color(0xFFE35D5D),
        icon: Icons.error_outline,
        progress: 0.03,
      ),
      _DeliveryMetric(
        label: 'Pending',
        value: '2%',
        color: Color(0xFFE5A534),
        icon: Icons.schedule_outlined,
        progress: 0.02,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Push & Email Delivery Health',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: CommitmentAdminApp.textDark,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 520
                ? 2
                : 1;
            const spacing = 10.0;
            final metricWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final metric in metrics)
                  SizedBox(
                    width: metricWidth,
                    child: _DeliveryHealthMetric(metric: metric),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Delivery',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: CommitmentAdminApp.textDark,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const minTableWidth = 760.0;
              final tableWidth = constraints.maxWidth < minTableWidth
                  ? minTableWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      const _NotificationDeliveryRow(
                        isHeader: true,
                        time: 'Time',
                        user: 'User',
                        alert: 'Alert',
                        channel: 'Channel',
                        status: 'Status',
                      ),
                      for (final delivery in _deliveries)
                        _NotificationDeliveryRow(
                          time: delivery.time,
                          user: delivery.user,
                          alert: delivery.alert,
                          channel: delivery.channel,
                          status: delivery.status,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeliveryMetric {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final double progress;

  const _DeliveryMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.progress,
  });
}

class _DeliveryHealthMetric extends StatefulWidget {
  final _DeliveryMetric metric;

  const _DeliveryHealthMetric({required this.metric});

  @override
  State<_DeliveryHealthMetric> createState() => _DeliveryHealthMetricState();
}

class _DeliveryHealthMetricState extends State<_DeliveryHealthMetric> {
  String _period = 'Last 24h';

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;
    return Tilt3D(
      maxTilt: 0.045,
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: dashCardDecoration(),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [metric.color, metric.color.withAlpha(175)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: metric.color.withAlpha(55),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(metric.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          metric.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CommitmentAdminApp.textGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        metric.value,
                        style: TextStyle(
                          color: metric.color,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _period,
                        isDense: true,
                        iconSize: 15,
                        style: const TextStyle(
                          color: CommitmentAdminApp.textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        items: const [
                          DropdownMenuItem(
                            value: 'Last 24h',
                            child: Text('Last 24h'),
                          ),
                          DropdownMenuItem(
                            value: 'Last 7d',
                            child: Text('Last 7d'),
                          ),
                          DropdownMenuItem(
                            value: 'Last 30d',
                            child: Text('Last 30d'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _period = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: metric.progress,
                      minHeight: 4,
                      color: metric.color,
                      backgroundColor: metric.color.withAlpha(35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDelivery {
  final String time;
  final String user;
  final String alert;
  final String channel;
  final String status;

  const _NotificationDelivery({
    required this.time,
    required this.user,
    required this.alert,
    required this.channel,
    required this.status,
  });
}

class _NotificationDeliveryRow extends StatelessWidget {
  final bool isHeader;
  final String time;
  final String user;
  final String alert;
  final String channel;
  final String status;

  const _NotificationDeliveryRow({
    this.isHeader = false,
    required this.time,
    required this.user,
    required this.alert,
    required this.channel,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      'Delivered' => const Color(0xFF248A55),
      'Failed' => const Color(0xFFC74343),
      _ => const Color(0xFFB07812),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFF2F8FC) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE8EEF4))),
      ),
      child: Row(
        children: [
          _cell(time, flex: 2, isHeader: isHeader),
          _cell(user, flex: 3, isHeader: isHeader),
          _cell(alert, flex: 3, isHeader: isHeader),
          _cell(channel, flex: 2, isHeader: isHeader),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: isHeader
                  ? Text(
                      status,
                      style: const TextStyle(
                        color: CommitmentAdminApp.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, {required int flex, required bool isHeader}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isHeader
                ? CommitmentAdminApp.textGrey
                : CommitmentAdminApp.textDark,
            fontSize: 12,
            fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ANALYTICS PAGE
// ============================================================

class AnalyticsPage extends StatelessWidget {
  final VoidCallback onBack;
  final Widget profile;

  const AnalyticsPage({super.key, required this.onBack, required this.profile});

  @override
  Widget build(BuildContext context) {
    const metrics = [
      _AnalyticsMetric(
        title: 'Platform',
        value: '84%',
        change: '↑ 6.2%',
        positive: true,
        color: Color(0xFF2F80B7),
        icon: Icons.insights_outlined,
      ),
      _AnalyticsMetric(
        title: 'Score',
        value: '86',
        change: '↑ 4.5%',
        positive: true,
        color: Color(0xFF7B61FF),
        icon: Icons.stars_outlined,
      ),
      _AnalyticsMetric(
        title: 'Kept',
        value: '72%',
        change: '↑ 8.1%',
        positive: true,
        color: Color(0xFF2EAD67),
        icon: Icons.task_alt_outlined,
      ),
      _AnalyticsMetric(
        title: 'Late',
        value: '18%',
        change: '↓ 3.2%',
        positive: true,
        color: Color(0xFFE5A534),
        icon: Icons.schedule_outlined,
      ),
      _AnalyticsMetric(
        title: 'Missed',
        value: '10%',
        change: '↓ 2%',
        positive: true,
        color: Color(0xFFE35D5D),
        icon: Icons.event_busy_outlined,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Analytics',
              subtitle: 'Commitment performance overview',
              onBack: onBack,
              action: profile,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1100
                    ? 5
                    : constraints.maxWidth >= 600
                    ? 3
                    : 2;
                const spacing = 12.0;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        width: width,
                        child: _AnalyticsMetricCard(metric: metric),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                const trendCard = _AnalyticsTrendCard();
                const outcomeCard = _AnalyticsOutcomeCard();
                if (constraints.maxWidth < 760) {
                  return const Column(
                    children: [trendCard, SizedBox(height: 14), outcomeCard],
                  );
                }
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: trendCard),
                    SizedBox(width: 14),
                    Expanded(flex: 2, child: outcomeCard),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ATTACHMENTS PAGE
// ============================================================

class AttachmentsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const AttachmentsPage({
    super.key,
    required this.onBack,
    required this.profile,
  });

  @override
  State<AttachmentsPage> createState() => _AttachmentsPageState();
}

class _AttachmentsPageState extends State<AttachmentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _typeFilter = 'All types';
  String _userFilter = 'All users';

  static const _files = [
    _AttachmentRecord(
      name: 'Contract.pdf',
      type: 'PDF',
      size: '2.4 MB',
      user: 'John Smith',
      commitment: 'Project A',
      date: 'Sep 30',
    ),
    _AttachmentRecord(
      name: 'Report.docx',
      type: 'DOCX',
      size: '1.8 MB',
      user: 'Sarah Lee',
      commitment: 'Meeting',
      date: 'Sep 29',
    ),
    _AttachmentRecord(
      name: 'Image.png',
      type: 'PNG',
      size: '840 KB',
      user: 'Alex Kumar',
      commitment: 'Follow Up',
      date: 'Sep 29',
    ),
    _AttachmentRecord(
      name: 'Agreement.pdf',
      type: 'PDF',
      size: '3.1 MB',
      user: 'John Smith',
      commitment: 'Project B',
      date: 'Sep 28',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_AttachmentRecord> get _filteredFiles {
    final query = _query.trim().toLowerCase();
    return _files.where((file) {
      final matchesQuery =
          query.isEmpty ||
          file.name.toLowerCase().contains(query) ||
          file.user.toLowerCase().contains(query) ||
          file.commitment.toLowerCase().contains(query);
      return matchesQuery &&
          (_typeFilter == 'All types' || file.type == _typeFilter) &&
          (_userFilter == 'All users' || file.user == _userFilter);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Attachments',
              subtitle: 'Manage uploaded files and commitment documents',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildSummaryCards(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 14),
            _buildFilesTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    const summaries = [
      _AttachmentSummaryData(
        'Files',
        '248',
        '↑ 12.4%',
        Icons.attach_file_outlined,
        Color(0xFF2F80B7),
      ),
      _AttachmentSummaryData(
        'Storage',
        '12.6 GB',
        '↑ 4.2%',
        Icons.storage_outlined,
        Color(0xFF7B61FF),
      ),
      _AttachmentSummaryData(
        'Upload Today',
        '18',
        '↑ 8.6%',
        Icons.cloud_upload_outlined,
        Color(0xFF2EAD67),
      ),
      _AttachmentSummaryData(
        'Access Events',
        '1,284',
        '↑ 6.8%',
        Icons.visibility_outlined,
        Color(0xFFE5A534),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 950
            ? 4
            : constraints.maxWidth >= 540
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final summary in summaries)
              SizedBox(
                width: width,
                child: _AttachmentSummaryCard(summary: summary),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Search files...',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
          ),
        );
        final type = _buildFilterDropdown(
          value: _typeFilter,
          options: const ['All types', 'PDF', 'DOCX', 'PNG'],
          onChanged: (value) => setState(() => _typeFilter = value),
        );
        final user = _buildFilterDropdown(
          value: _userFilter,
          options: const ['All users', 'John Smith', 'Sarah Lee', 'Alex Kumar'],
          onChanged: (value) => setState(() => _userFilter = value),
        );
        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              search,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: type),
                  const SizedBox(width: 10),
                  Expanded(child: user),
                ],
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 5, child: search),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: type),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: user),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CommitmentAdminApp.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ),
    );
  }

  Widget _buildFilesTable() {
    final files = _filteredFiles;
    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minWidth = 820.0;
            final width = constraints.maxWidth < minWidth
                ? minWidth
                : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    const _AttachmentTableRow(
                      isHeader: true,
                      name: 'File',
                      type: 'Type',
                      size: 'Size',
                      user: 'Uploaded By',
                      commitment: 'Commitment',
                      date: 'Uploaded',
                    ),
                    if (files.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          'No matching files found',
                          style: TextStyle(
                            color: CommitmentAdminApp.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      for (final file in files)
                        _AttachmentTableRow(
                          name: file.name,
                          type: file.type,
                          size: file.size,
                          user: file.user,
                          commitment: file.commitment,
                          date: file.date,
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AttachmentSummaryData {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _AttachmentSummaryData(
    this.title,
    this.value,
    this.change,
    this.icon,
    this.color,
  );
}

class _AttachmentSummaryCard extends StatelessWidget {
  final _AttachmentSummaryData summary;

  const _AttachmentSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(radius: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: summary.color.withAlpha(24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(summary.icon, color: summary.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  summary.value,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  summary.change,
                  style: const TextStyle(
                    color: Color(0xFF26945A),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentRecord {
  final String name;
  final String type;
  final String size;
  final String user;
  final String commitment;
  final String date;

  const _AttachmentRecord({
    required this.name,
    required this.type,
    required this.size,
    required this.user,
    required this.commitment,
    required this.date,
  });
}

class _AttachmentTableRow extends StatelessWidget {
  final bool isHeader;
  final String name;
  final String type;
  final String size;
  final String user;
  final String commitment;
  final String date;

  const _AttachmentTableRow({
    this.isHeader = false,
    required this.name,
    required this.type,
    required this.size,
    required this.user,
    required this.commitment,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHeader
        ? CommitmentAdminApp.textGrey
        : CommitmentAdminApp.textDark;
    final weight = isHeader ? FontWeight.w700 : FontWeight.w500;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFF4F8FB) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFEAF0F5))),
      ),
      child: Row(
        children: [
          _cell(5, name, color, weight, isFile: !isHeader),
          _cell(2, type, color, weight),
          _cell(2, size, color, weight),
          _cell(3, user, color, weight),
          _cell(3, commitment, color, weight),
          _cell(2, date, color, weight),
        ],
      ),
    );
  }

  Widget _cell(
    int flex,
    String text,
    Color color,
    FontWeight weight, {
    bool isFile = false,
  }) {
    final content = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: color, fontSize: 11, fontWeight: weight),
    );
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: isFile
            ? Row(
                children: [
                  Icon(_fileIcon(text), size: 17, color: _fileColor(text)),
                  const SizedBox(width: 8),
                  Expanded(child: content),
                ],
              )
            : content,
      ),
    );
  }

  IconData _fileIcon(String fileName) {
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (fileName.endsWith('.docx')) return Icons.article_outlined;
    if (fileName.endsWith('.png')) return Icons.image_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color _fileColor(String fileName) {
    if (fileName.endsWith('.pdf')) return const Color(0xFFE35D5D);
    if (fileName.endsWith('.docx')) return const Color(0xFF2F80B7);
    if (fileName.endsWith('.png')) return const Color(0xFF7B61FF);
    return CommitmentAdminApp.textGrey;
  }
}

// ============================================================
// SUBSCRIPTION PAGE
// ============================================================

class SubscriptionPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const SubscriptionPage({
    super.key,
    required this.onBack,
    required this.profile,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String _selectedPlan = 'All plans';
  String _selectedStatus = 'All statuses';

  static const List<_SubscriptionRecord> _subscriptions = [
    _SubscriptionRecord(
      user: 'John Smith',
      plan: 'Pro',
      amount: '₹499',
      nextCharge: '₹499',
      date: 'Oct 01',
      status: 'Active',
    ),
    _SubscriptionRecord(
      user: 'Sarah Lee',
      plan: 'Basic',
      amount: '₹199',
      nextCharge: '₹199',
      date: 'Oct 12',
      status: 'Active',
    ),
    _SubscriptionRecord(
      user: 'Alex Kumar',
      plan: 'Pro',
      amount: '₹499',
      nextCharge: '₹499',
      date: 'Oct 20',
      status: 'Expiring Soon',
    ),
    _SubscriptionRecord(
      user: 'Mike Johnson',
      plan: 'Basic',
      amount: '₹199',
      nextCharge: '—',
      date: '—',
      status: 'Cancelled',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SubscriptionRecord> get _filteredSubscriptions {
    final query = _search.trim().toLowerCase();
    return _subscriptions.where((subscription) {
      final matchesSearch =
          query.isEmpty || subscription.user.toLowerCase().contains(query);
      final matchesPlan =
          _selectedPlan == 'All plans' || subscription.plan == _selectedPlan;
      final matchesStatus =
          _selectedStatus == 'All statuses' ||
          subscription.status == _selectedStatus;
      return matchesSearch && matchesPlan && matchesStatus;
    }).toList();
  }

  void _showExportDemoMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription export is for demonstration only.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Subscription',
              subtitle: 'Plans, trials and billing status',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildSummary(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 14),
            _buildSubscriptionTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    const summaries = [
      _SubscriptionSummaryData(
        title: 'Trial',
        value: '842',
        change: '+8.4%',
        icon: Icons.hourglass_bottom_rounded,
        color: Color(0xFF2F80B7),
      ),
      _SubscriptionSummaryData(
        title: 'Active',
        value: '720',
        change: '+12.2%',
        icon: Icons.check_circle_outline,
        color: Color(0xFF2EAD67),
      ),
      _SubscriptionSummaryData(
        title: 'Cancelled',
        value: '36',
        change: '+4.1%',
        icon: Icons.cancel_outlined,
        color: Color(0xFFE5A534),
      ),
      _SubscriptionSummaryData(
        title: 'Payment Failed',
        value: '18',
        change: '-2.6%',
        icon: Icons.credit_card_off_outlined,
        color: Color(0xFFE35D5D),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final summary in summaries)
              SizedBox(
                width: width,
                child: _SubscriptionSummaryCard(summary: summary),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _search = value),
          decoration: const InputDecoration(
            hintText: 'Search user...',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
          ),
        );
        final plan = _buildDropdown(
          value: _selectedPlan,
          options: const ['All plans', 'Pro', 'Basic'],
          onChanged: (value) => setState(() => _selectedPlan = value),
        );
        final status = _buildDropdown(
          value: _selectedStatus,
          options: const [
            'All statuses',
            'Active',
            'Expiring Soon',
            'Cancelled',
            'Payment Failed',
          ],
          onChanged: (value) => setState(() => _selectedStatus = value),
        );
        final exportButton = SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _showExportDemoMessage,
            icon: const Icon(Icons.download_outlined, size: 17),
            label: const Text('Export'),
          ),
        );
        if (constraints.maxWidth < 740) {
          return Column(
            children: [
              search,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: plan),
                  const SizedBox(width: 10),
                  Expanded(child: status),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: exportButton),
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 5, child: search),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: plan),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: status),
            const SizedBox(width: 12),
            exportButton,
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CommitmentAdminApp.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          onChanged: (selection) {
            if (selection != null) onChanged(selection);
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionTable() {
    final subscriptions = _filteredSubscriptions;
    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minimumTableWidth = 800.0;
            final tableWidth = constraints.maxWidth < minimumTableWidth
                ? minimumTableWidth
                : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    const _SubscriptionTableRow(
                      isHeader: true,
                      user: 'User',
                      plan: 'Plan',
                      amount: 'Amount',
                      nextCharge: 'Next Charge',
                      date: 'Date',
                      status: 'Status',
                    ),
                    if (subscriptions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          'No matching subscriptions found',
                          style: TextStyle(
                            color: CommitmentAdminApp.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      for (final subscription in subscriptions)
                        _SubscriptionTableRow(
                          user: subscription.user,
                          plan: subscription.plan,
                          amount: subscription.amount,
                          nextCharge: subscription.nextCharge,
                          date: subscription.date,
                          status: subscription.status,
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubscriptionSummaryData {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _SubscriptionSummaryData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });
}

class _SubscriptionSummaryCard extends StatelessWidget {
  final _SubscriptionSummaryData summary;

  const _SubscriptionSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(radius: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: summary.color.withAlpha(24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(summary.icon, color: summary.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.value,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary.change,
                  style: TextStyle(
                    color: summary.change.startsWith('-')
                        ? const Color(0xFFE35D5D)
                        : const Color(0xFF26945A),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionRecord {
  final String user;
  final String plan;
  final String amount;
  final String nextCharge;
  final String date;
  final String status;

  const _SubscriptionRecord({
    required this.user,
    required this.plan,
    required this.amount,
    required this.nextCharge,
    required this.date,
    required this.status,
  });
}

class _SubscriptionTableRow extends StatelessWidget {
  final bool isHeader;
  final String user;
  final String plan;
  final String amount;
  final String nextCharge;
  final String date;
  final String status;

  const _SubscriptionTableRow({
    this.isHeader = false,
    required this.user,
    required this.plan,
    required this.amount,
    required this.nextCharge,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHeader
        ? CommitmentAdminApp.textGrey
        : CommitmentAdminApp.textDark;
    final weight = isHeader ? FontWeight.w700 : FontWeight.w500;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFF4F8FB) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFEAF0F5))),
      ),
      child: Row(
        children: [
          _subscriptionCell(3, user, color, weight),
          _subscriptionCell(1, plan, color, weight),
          _subscriptionCell(2, amount, color, weight),
          _subscriptionCell(2, nextCharge, color, weight),
          _subscriptionCell(2, date, color, weight),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: isHeader
                  ? Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: weight,
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withAlpha(22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscriptionCell(
    int flex,
    String text,
    Color color,
    FontWeight weight,
  ) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontSize: 11, fontWeight: weight),
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    return switch (value) {
      'Active' => const Color(0xFF2EAD67),
      'Expiring Soon' => const Color(0xFFE5A534),
      'Cancelled' => const Color(0xFF7D8995),
      'Payment Failed' => const Color(0xFFE35D5D),
      _ => CommitmentAdminApp.textGrey,
    };
  }
}

// ============================================================
// SUPPORT PAGE
// ============================================================

class SupportPage extends StatefulWidget {
  final VoidCallback onBack;
  final Widget profile;

  const SupportPage({super.key, required this.onBack, required this.profile});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String _priority = 'All priorities';
  String _status = 'All statuses';

  static const List<_SupportTicket> _tickets = [
    _SupportTicket(
      id: '1024',
      user: 'John',
      issue: 'Login',
      priority: 'High',
      assigned: 'Admin 1',
      status: 'Open',
    ),
    _SupportTicket(
      id: '1023',
      user: 'Sarah',
      issue: 'Billing',
      priority: 'Medium',
      assigned: 'Admin 2',
      status: 'In Progress',
    ),
    _SupportTicket(
      id: '1022',
      user: 'Alex',
      issue: 'Account',
      priority: 'Low',
      assigned: 'Admin 1',
      status: 'Resolved',
    ),
    _SupportTicket(
      id: '1021',
      user: 'Mike',
      issue: 'Payment',
      priority: 'Urgent',
      assigned: 'Admin 3',
      status: 'Open',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SupportTicket> get _filteredTickets {
    final query = _search.trim().toLowerCase();
    return _tickets.where((ticket) {
      final matchesQuery =
          query.isEmpty ||
          ticket.id.contains(query) ||
          ticket.user.toLowerCase().contains(query) ||
          ticket.issue.toLowerCase().contains(query);
      final matchesPriority =
          _priority == 'All priorities' || ticket.priority == _priority;
      final matchesStatus =
          _status == 'All statuses' || ticket.status == _status;
      return matchesQuery && matchesPriority && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Support',
              subtitle: 'Customer support operations',
              onBack: widget.onBack,
              action: widget.profile,
            ),
            _buildSummaryCards(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 14),
            _buildTicketTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    const summaries = [
      _SupportSummary(
        'Open',
        '42',
        '+8.2%',
        Color(0xFF2F80B7),
        Icons.markunread_mailbox_outlined,
      ),
      _SupportSummary(
        'New Today',
        '18',
        '+4.5%',
        Color(0xFF7B61FF),
        Icons.fiber_new_outlined,
      ),
      _SupportSummary(
        'Waiting',
        '126',
        '+12.4%',
        Color(0xFFE5A534),
        Icons.hourglass_top_outlined,
      ),
      _SupportSummary(
        'Resolved',
        '6',
        '-2.1%',
        Color(0xFF2EAD67),
        Icons.task_alt_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final summary in summaries)
              SizedBox(
                width: width,
                child: _SupportSummaryCard(summary: summary),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _search = value),
          decoration: const InputDecoration(
            hintText: 'Search tickets...',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
          ),
        );
        final priorityFilter = _buildDropdown(
          value: _priority,
          options: const ['All priorities', 'Urgent', 'High', 'Medium', 'Low'],
          onChanged: (value) => setState(() => _priority = value),
        );
        final statusFilter = _buildDropdown(
          value: _status,
          options: const [
            'All statuses',
            'Open',
            'In Progress',
            'Resolved',
            'Waiting',
          ],
          onChanged: (value) => setState(() => _status = value),
        );
        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: priorityFilter),
                  const SizedBox(width: 10),
                  Expanded(child: statusFilter),
                ],
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 5, child: searchField),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: priorityFilter),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: statusFilter),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CommitmentAdminApp.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ),
    );
  }

  Widget _buildTicketTable() {
    final tickets = _filteredTickets;
    return Container(
      width: double.infinity,
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minTableWidth = 760.0;
            final width = constraints.maxWidth < minTableWidth
                ? minTableWidth
                : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    const _SupportTicketRow(
                      isHeader: true,
                      id: 'Ticket',
                      user: 'User',
                      issue: 'Issue',
                      priority: 'Priority',
                      assigned: 'Assigned',
                      status: 'Status',
                    ),
                    if (tickets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          'No matching support tickets',
                          style: TextStyle(
                            color: CommitmentAdminApp.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      for (final ticket in tickets)
                        _SupportTicketRow(
                          id: '#${ticket.id}',
                          user: ticket.user,
                          issue: ticket.issue,
                          priority: ticket.priority,
                          assigned: ticket.assigned,
                          status: ticket.status,
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SupportSummary {
  final String title;
  final String value;
  final String change;
  final Color color;
  final IconData icon;

  const _SupportSummary(
    this.title,
    this.value,
    this.change,
    this.color,
    this.icon,
  );
}

class _SupportSummaryCard extends StatelessWidget {
  final _SupportSummary summary;

  const _SupportSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(radius: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: summary.color.withAlpha(24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(summary.icon, color: summary.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.value,
                  style: const TextStyle(
                    color: CommitmentAdminApp.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  summary.change,
                  style: TextStyle(
                    color: summary.change.startsWith('-')
                        ? const Color(0xFFE35D5D)
                        : const Color(0xFF26945A),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportTicket {
  final String id;
  final String user;
  final String issue;
  final String priority;
  final String assigned;
  final String status;

  const _SupportTicket({
    required this.id,
    required this.user,
    required this.issue,
    required this.priority,
    required this.assigned,
    required this.status,
  });
}

class _SupportTicketRow extends StatelessWidget {
  final bool isHeader;
  final String id;
  final String user;
  final String issue;
  final String priority;
  final String assigned;
  final String status;

  const _SupportTicketRow({
    this.isHeader = false,
    required this.id,
    required this.user,
    required this.issue,
    required this.priority,
    required this.assigned,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isHeader
        ? CommitmentAdminApp.textGrey
        : CommitmentAdminApp.textDark;
    final weight = isHeader ? FontWeight.w700 : FontWeight.w500;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFF4F8FB) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFEAF0F5))),
      ),
      child: Row(
        children: [
          _cell(2, id, baseColor, weight),
          _cell(2, user, baseColor, weight),
          _cell(3, issue, baseColor, weight),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: isHeader
                  ? Text(priority, style: _style(baseColor, weight))
                  : _badge(priority, _priorityColor(priority)),
            ),
          ),
          _cell(2, assigned, baseColor, weight),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: isHeader
                  ? Text(status, style: _style(baseColor, weight))
                  : _badge(status, _statusColor(status)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(int flex, String text, Color color, FontWeight weight) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _style(color, weight),
        ),
      ),
    );
  }

  TextStyle _style(Color color, FontWeight weight) {
    return TextStyle(color: color, fontSize: 11, fontWeight: weight);
  }

  Widget _badge(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String value) {
    return switch (value) {
      'Urgent' => const Color(0xFFE35D5D),
      'High' => const Color(0xFFE57836),
      'Medium' => const Color(0xFFE5A534),
      'Low' => const Color(0xFF2F80B7),
      _ => CommitmentAdminApp.textGrey,
    };
  }

  Color _statusColor(String value) {
    return switch (value) {
      'Open' => const Color(0xFF2F80B7),
      'In Progress' => const Color(0xFFE5A534),
      'Resolved' => const Color(0xFF2EAD67),
      'Waiting' => const Color(0xFF7B61FF),
      _ => CommitmentAdminApp.textGrey,
    };
  }
}

class ReportsPage extends StatelessWidget {
  final VoidCallback onBack;
  final Widget profile;

  const ReportsPage({super.key, required this.onBack, required this.profile});

  static const List<_ReportDefinition> _reports = [
    _ReportDefinition(
      title: 'User Activity',
      description: 'Growth, Active Users,\nTrial Users',
      icon: Icons.people_alt_outlined,
      color: Color(0xFF2F80B7),
    ),
    _ReportDefinition(
      title: 'Commitment Report',
      description: 'Created, Completed,\nLate, Missed',
      icon: Icons.assignment_outlined,
      color: Color(0xFF7B61FF),
    ),
    _ReportDefinition(
      title: 'Score Report',
      description: 'Late, Missed,\nEnd Score',
      icon: Icons.star_outline_rounded,
      color: Color(0xFFE5A534),
    ),
    _ReportDefinition(
      title: 'Revenue Report',
      description: 'Subscriptions,\nRenewals, Revenue',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF2EAD67),
    ),
    _ReportDefinition(
      title: 'Notification Report',
      description: 'Push/Email Delivery\nHealth',
      icon: Icons.notifications_none_outlined,
      color: Color(0xFFE35D5D),
    ),
    _ReportDefinition(
      title: 'Travel Report',
      description: 'Distance and\nTravel Time',
      icon: Icons.map_outlined,
      color: Color(0xFF4389C7),
    ),
  ];

  void _showGeneratedMessage(BuildContext context, String reportName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$reportName is ready to view (demo).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Reports',
              subtitle: 'Generate operational and business reports',
              onBack: onBack,
              action: profile,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050
                    ? 3
                    : constraints.maxWidth >= 650
                    ? 2
                    : 1;
                const spacing = 16.0;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final report in _reports)
                      SizedBox(
                        width: width,
                        child: _ReportCard(
                          report: report,
                          onGenerate: () =>
                              _showGeneratedMessage(context, report.title),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportDefinition {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _ReportDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _ReportCard extends StatelessWidget {
  final _ReportDefinition report;
  final VoidCallback onGenerate;

  const _ReportCard({required this.report, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 242,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: report.color.withAlpha(22),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(report.icon, color: report.color, size: 25),
          ),
          const SizedBox(height: 13),
          Text(
            report.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CommitmentAdminApp.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                report.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CommitmentAdminApp.textGrey,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGenerate,
              style: OutlinedButton.styleFrom(
                foregroundColor: report.color,
                side: BorderSide(color: report.color.withAlpha(100)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'View & Generate Report',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget profile;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.onBack,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: _adminPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: title,
              subtitle: '$title management and monitoring',
              onBack: onBack,
              action: profile,
            ),
            Container(
              width: double.infinity,
              height: 350,
              decoration: cardDecoration(),
              child: const Center(
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: CommitmentAdminApp.textGrey,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminModel {
  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.lastLogin,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final DateTime? lastLogin;

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.tryParse(json['lastLogin'] as String),
    );
  }
}

class AdminApiService {
  AdminApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final http.Client _client;

  Future<AdminModel> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    final response = await _send(
      () => _client.post(
        Uri.parse('$baseUrl/api/admin/signup'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone,
        }),
      ),
    );
    _checkStatus(response, 201);
    return AdminModel.fromJson(_decode(response.body));
  }

  Future<AdminModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _send(
      () => _client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    _checkStatus(response, 200);
    final body = _decode(response.body);
    return AdminModel.fromJson(body['admin'] as Map<String, dynamic>);
  }

  Future<AdminModel> getAdminById(String id) async {
    final response = await _send(
      () => _client.get(
        Uri.parse('$baseUrl/api/admin/${Uri.encodeComponent(id)}'),
        headers: const {'Accept': 'application/json'},
      ),
    );
    _checkStatus(response, 200);
    return AdminModel.fromJson(_decode(response.body));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AdminApiException('The server took too long to respond.');
    } on http.ClientException {
      throw const AdminApiException(
        'Could not reach the admin API at $baseUrl. Start the backend on port 8080 and confirm it allows this localhost web origin.',
      );
    }
  }

  void _checkStatus(http.Response response, int expectedStatus) {
    if (response.statusCode == expectedStatus) return;
    final body = _decode(response.body, allowInvalid: true);
    final message = body['message'] as String?;
    if (response.statusCode == 401) {
      throw const AdminApiException('Invalid email or password.');
    }
    throw AdminApiException(
      message ??
          switch (response.statusCode) {
            400 => 'Please check the information and try again.',
            404 => 'Admin profile was not found.',
            409 => 'An admin with this email already exists.',
            >= 500 =>
              'The server is unavailable right now. Please try again later.',
            _ => 'Request failed (HTTP ${response.statusCode}).',
          },
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decode(String body, {bool allowInvalid = false}) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } on FormatException {
      if (allowInvalid) return const {};
      throw const AdminApiException('The server returned an invalid response.');
    } on TypeError {
      if (allowInvalid) return const {};
      throw const AdminApiException('The server returned an invalid response.');
    }
  }
}

class AdminApiException implements Exception {
  const AdminApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

void downloadCsv(String csv) {
  if (!kIsWeb) {
    throw UnsupportedError('CSV downloads are available in the web dashboard.');
  }

  final blob = html.Blob([csv], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'commitments.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
