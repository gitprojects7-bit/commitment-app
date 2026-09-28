import 'dart:html' as html;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CommitmentAdminApp());
}

// ============================================================
// APP
// ============================================================

class CommitmentAdminApp extends StatelessWidget {
  const CommitmentAdminApp({super.key});

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
            elevation: 6,
            shadowColor: const Color(0x808FD0FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: textDark,
            fontSize: 14,
          ),
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
            borderSide: BorderSide(
              color: primary,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const AdminLoginScreen(),
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (!emailController.text.contains('@')) {
      _message('Enter a valid email address');
      return;
    }

    if (passwordController.text.length < 4) {
      _message('Password must contain at least 4 characters');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboardScreen(),
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0x55FFFFFF),
              padding: const EdgeInsets.all(60),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandLogo(),
                  SizedBox(height: 35),
                  Text(
                    'One clear view of\nevery commitment.',
                    style: TextStyle(
                      color: Color(0xFF18232E),
                      fontSize: 42,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Manage users, commitments, activity,\nsubscriptions and operational health from\none professional workspace.',
                    style: TextStyle(
                      color: Color(0xFF52606D),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(50),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Super Admin Portal',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue to the admin workspace.',
                        style: TextStyle(
                          color: Color(0xFF7D8995),
                        ),
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'admin@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: login,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'Frontend demo',
                          style: TextStyle(
                            color: Color(0xFF9AA5AE),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
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
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedItem = 'Dashboard';
  final List<String> navigationHistory = [];

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

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: Row(
        children: [
          AdminSidebar(
            selectedItem: selectedItem,
            onSelected: selectItem,
            onLogout: logout,
          ),
          Expanded(
            child: _buildPage(),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (selectedItem) {
      case 'Dashboard':
        return DashboardPage(
          onCommitmentsPressed: () => selectItem('Commitments'),
          onBack: goBack,
          onLogout: logout,
        );

      case 'Users':
        return UsersPage(
          onBack: goBack,
        );

      case 'Commitments':
        return CommitmentsPage(
          onBack: goBack,
        );

      default:
        return PlaceholderPage(
          title: selectedItem,
          onBack: goBack,
        );
    }
  }
}

// ============================================================
// SIDEBAR  (unchanged)
// ============================================================

class AdminSidebar extends StatelessWidget {
  final String selectedItem;
  final Function(String) onSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedItem,
    required this.onSelected,
    required this.onLogout,
  });

  static const items = [
    ['Dashboard', Icons.dashboard_outlined],
    ['Users', Icons.people_outline],
    ['Commitments', Icons.calendar_month_outlined],
    ['People', Icons.group_outlined],
    ['Location & Maps', Icons.location_on_outlined],
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
            padding: const EdgeInsets.fromLTRB(22, 25, 18, 20),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = item[0] as String;
                final icon = item[1] as IconData;
                final selected = selectedItem == title;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelected(title),
                    child: Container(
                      height: 47,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFA8DCFF),
                                  Color(0xFF7CC4F5),
                                ],
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
                          const SizedBox(width: 15),
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
          const Divider(
            height: 1,
            color: Color(0x332F80B7),
          ),
          InkWell(
            onTap: onLogout,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            child: const SizedBox(
              height: 68,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Color(0xFF52606D),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: CommitmentAdminApp.textDark,
                      ),
                    ),
                  ],
                ),
              ),
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
      padding: const EdgeInsets.only(bottom: 26),
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
          if (action != null) action!,
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
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withAlpha(170)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(110),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 27,
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

BoxDecoration cardDecoration() => glassDecoration(radius: 24);

/// Flat white card used on the dashboard (clean, light style).
BoxDecoration dashCardDecoration({double radius = 16}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFE8EEF4)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0F1E5A8C),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
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
                  Color(0xFFE4F4FF),
                  Color(0xFFD3EBFF),
                  Color(0xFFF2FAFF),
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
              color: Color(0x88B6E2FF),
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
              color: Color(0x77A9DBFF),
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

  const Tilt3D({
    super.key,
    required this.child,
    this.maxTilt = 0.08,
  });

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
          ..translate(0.0, hover ? -6.0 : 0.0, 0.0),
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

class DashboardPage extends StatefulWidget {
  final VoidCallback onCommitmentsPressed;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const DashboardPage({
    super.key,
    required this.onCommitmentsPressed,
    required this.onBack,
    required this.onLogout,
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
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
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
                      const SizedBox(height: 18),
                      _buildAlertCard(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildGrowthCard()),
                    const SizedBox(width: 18),
                    Expanded(flex: 5, child: _buildAlertCard()),
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
                      _buildCommitmentToday(),
                      const SizedBox(height: 18),
                      _buildBusinessSnapshot(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildCommitmentToday()),
                    const SizedBox(width: 18),
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
      padding: const EdgeInsets.only(bottom: 16),
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
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _dashTitle,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Overview of your Commitment App',
                  style: TextStyle(
                    fontSize: 13,
                    color: CommitmentAdminApp.textGrey,
                  ),
                ),
              ],
            ),
          ),
          _ProfileMenu(onLogout: widget.onLogout),
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
            children: [
              for (final c in cards) SizedBox(width: 240, child: c),
            ],
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
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------- Alert Health ----------

  Widget _buildAlertCard() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: dashCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: _dashBlue, size: 24),
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
          const Spacer(),
          _healthBar('Popup Delivered', 94),
          const Spacer(),
          _healthBar('Notification Delivered', 97),
          const Spacer(),
          _healthBar('Email Delivered', 89),
          const Spacer(),
          _healthBar('Failed Delivery', 6),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _healthBar(String title, int percentage) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: CommitmentAdminApp.textDark,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFFE6EEF5),
            color: _dashBlue,
          ),
        ),
      ],
    );
  }

  // ---------- Commitment Today ----------

  Widget _buildCommitmentToday() {
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
          const Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _TodayTile(
                    number: '25',
                    label: 'Created',
                    icon: Icons.calendar_month_outlined,
                    color: Color(0xFF2A7DE1),
                    background: Color(0xFFEAF3FD),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TodayTile(
                    number: '18',
                    label: 'Completed',
                    icon: Icons.check_circle,
                    color: Color(0xFF2EAD54),
                    background: Color(0xFFE8F6EC),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TodayTile(
                    number: '3',
                    label: 'Late',
                    icon: Icons.schedule,
                    color: Color(0xFFF5A623),
                    background: Color(0xFFFFF3E0),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TodayTile(
                    number: '2',
                    label: 'Missed',
                    icon: Icons.warning_rounded,
                    color: Color(0xFFE83E3E),
                    background: Color(0xFFFFE9E9),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TodayTile(
                    number: '2',
                    label: 'Cancelled',
                    icon: Icons.cancel,
                    color: Color(0xFF7B61FF),
                    background: Color(0xFFEFEBFF),
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

// ---------- Profile (top right) ----------

class _ProfileMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileMenu({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              tooltip: 'Notifications',
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF52606D),
                size: 26,
              ),
            ),
            Positioned(
              top: 10,
              right: 11,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE83E3E),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        PopupMenuButton<String>(
          tooltip: 'Profile',
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'Logout') onLogout();
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE3EAF1),
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF9AA8B5),
                    size: 24,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _dashTitle,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ),
      ],
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
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: dashCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
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
    );
  }
}

class _TodayTile extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _TodayTile({
    required this.number,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
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
    final trendColor =
        trendUp ? const Color(0xFF2EAD54) : const Color(0xFFE83E3E);

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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
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

  GrowthChartPainter({
    required this.values,
    required this.labels,
  });

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
        const TextStyle(
          color: CommitmentAdminApp.textGrey,
          fontSize: 11,
        ),
      );
    }

    final step =
        values.length == 1 ? chartWidth : chartWidth / (values.length - 1);

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

      canvas.drawCircle(
        point,
        4.5,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        point,
        3,
        Paint()..color = _dashBlue,
      );

      final textWidth = _textWidth(labels[i]);

      _drawText(
        canvas,
        labels[i],
        Offset(
          point.dx - textWidth / 2,
          top + chartHeight + 14,
        ),
        const TextStyle(
          color: CommitmentAdminApp.textGrey,
          fontSize: 11,
        ),
      );
    }
  }

  double _textWidth(String text) {
    return text.length * 6.5;
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
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

  const UsersPage({
    super.key,
    required this.onBack,
  });

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
      final searchMatch = query.isEmpty ||
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
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 45),
        child: Column(
          children: [
            PageHeader(
              title: 'Users',
              subtitle: 'Manage and monitor application users',
              onBack: widget.onBack,
            ),
            _buildFilters(),
            const SizedBox(height: 18),
            _buildTable(),
            const SizedBox(height: 16),
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
        prefixIcon: Icon(Icons.search),
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
      padding: const EdgeInsets.all(14),
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
                SizedBox(width: 140, child: status),
                SizedBox(width: 140, child: plan),
                _addUserButton(),
                _exportButton(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 10),
              SizedBox(width: 140, child: status),
              const SizedBox(width: 10),
              SizedBox(width: 140, child: plan),
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
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  Expanded(
                    flex: 2,
                    child: Text('Business', style: headStyle),
                  ),
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
          border: Border(
            top: BorderSide(color: CommitmentAdminApp.border),
          ),
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
                  PopupMenuItem(
                    value: 'View',
                    child: Text('View Details'),
                  ),
                  PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit User'),
                  ),
                  PopupMenuItem(
                    value: 'Disable',
                    child: Text('Disable User'),
                  ),
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
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
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
      height: 52,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_outlined, size: 20),
        label: const Text('Export CSV'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF12324A),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );
  }

  Widget _addUserButton() {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: _addUser,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Add User'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18),
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
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
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
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

  const CommitmentsPage({
    super.key,
    required this.onBack,
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
      final searchMatch = query.isEmpty ||
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

  int get completed =>
      commitments.where((e) => e.status == 'Completed').length;

  int get late => commitments.where((e) => e.status == 'Late').length;

  int get missed => commitments.where((e) => e.status == 'Missed').length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 45),
        child: Column(
          children: [
            PageHeader(
              title: 'Commitments',
              subtitle: 'Manage and monitor all user commitments',
              onBack: widget.onBack,
            ),
            _buildSummaryCards(),
            const SizedBox(height: 22),
            _buildFilters(),
            const SizedBox(height: 18),
            _buildTable(),
            const SizedBox(height: 16),
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
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: 210,
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 12),
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
        prefixIcon: Icon(Icons.search),
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
      padding: const EdgeInsets.all(14),
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
      height: 52,
      child: FilledButton.icon(
        onPressed: _exportCsv,
        icon: const Icon(Icons.download_outlined, size: 20),
        label: const Text('Export CSV'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF12324A),
          padding: const EdgeInsets.symmetric(horizontal: 18),
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
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
            final width =
                constraints.maxWidth < 1100 ? 1100.0 : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: const Color(0xFFE3F3FF),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text('Commitment', style: headStyle),
                          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: CommitmentAdminApp.border),
          ),
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
            SizedBox(
              width: 150,
              child: Text(item.user, style: cellStyle),
            ),
            SizedBox(width: 115, child: _typeChip(item.type)),
            SizedBox(
              width: 190,
              child: Text(item.dateTime, style: cellStyle),
            ),
            SizedBox(
              width: 110,
              child: Text(item.reminder, style: cellStyle),
            ),
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
                  PopupMenuItem(
                    value: 'View',
                    child: Text('View Details'),
                  ),
                  PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
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
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
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
        border: Border(
          bottom: BorderSide(color: CommitmentAdminApp.border),
        ),
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
                  decoration: const InputDecoration(
                    labelText: 'Commitment',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
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
          content: Text(
            'Are you sure you want to delete "${item.title}"?',
          ),
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
    final rows = <List<String>>[
      [
        'Commitment',
        'User',
        'Type',
        'Date / Time',
        'Reminder',
        'Status',
      ],
      ...filteredCommitments.map(
        (item) => [
          item.title,
          item.user,
          item.type,
          item.dateTime,
          item.reminder,
          item.status,
        ],
      ),
    ];

    final csv = rows
        .map(
          (row) => row
              .map((value) => '"${value.replaceAll('"', '""')}"')
              .join(','),
        )
        .join('\n');

    final blob = html.Blob(
      [csv],
      'text/csv;charset=utf-8',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', 'commitments.csv')
      ..click();

    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commitments CSV exported successfully'),
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER
// ============================================================

class PlaceholderPage extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: title,
              subtitle: '$title management and monitoring',
              onBack: onBack,
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