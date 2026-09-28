import 'dart:html' as html;
import 'package:flutter/material.dart';

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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
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
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFF16222D),
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
                      color: Colors.white,
                      fontSize: 42,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Manage users, commitments, activity,\nsubscriptions and operational health from\none professional workspace.',
                    style: TextStyle(
                      color: Color(0xFFB9C5CF),
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
                          prefixIcon:
                              const Icon(Icons.lock_outline),
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
                            backgroundColor:
                                CommitmentAdminApp.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF16222D),
            size: 31,
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Commitment App',
          style: TextStyle(
            color: Colors.white,
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
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  String selectedItem = 'Dashboard';

  void selectItem(String item) {
    setState(() {
      selectedItem = item;
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
      body: Row(
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
    );
  }

  Widget _buildPage() {
    switch (selectedItem) {
      case 'Dashboard':
        return DashboardPage(
          onCommitmentsPressed: () =>
              selectItem('Commitments'),
        );

      case 'Users':
        return const UsersPage();

      case 'Commitments':
        return const CommitmentsPage();

      default:
        return PlaceholderPage(
          title: selectedItem,
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
      decoration: const BoxDecoration(
        color: Color(0xFFF1F6FA),
        border: Border(
          right: BorderSide(
            color: Color(0xFFE0E7ED),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              25,
              18,
              25,
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF17232E),
                    borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = item[0] as String;
                final icon = item[1] as IconData;
                final selected = selectedItem == title;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () => onSelected(title),
                    child: Container(
                      height: 47,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFDDEFFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 21,
                            color: selected
                                ? CommitmentAdminApp.primary
                                : const Color(0xFF52606D),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: selected
                                    ? CommitmentAdminApp.primary
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
            color: Color(0xFFD5DEE6),
          ),
          InkWell(
            onTap: onLogout,
            child: const SizedBox(
              height: 68,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Color(0xFF53616D),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
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

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CommitmentAdminApp.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CommitmentAdminApp.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: CommitmentAdminApp.primary,
              size: 25,
            ),
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
                      fontWeight: FontWeight.w700,
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

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: CommitmentAdminApp.border,
    ),
  );
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  final VoidCallback onCommitmentsPressed;

  const DashboardPage({
    super.key,
    required this.onCommitmentsPressed,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String chartMode = 'Monthly';

  final monthlyValues = [
    42.0,
    55.0,
    49.0,
    70.0,
    64.0,
    82.0,
    76.0,
    91.0,
    87.0,
    102.0,
    112.0,
    126.0,
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
        padding: const EdgeInsets.fromLTRB(
          32,
          30,
          32,
          45,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Dashboard',
              subtitle:
                  'Overview of your Commitment App',
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                if (width < 1000) {
                  return const Column(
                    children: [
                      SummaryCard(
                        title: 'Total Users',
                        value: '1,284',
                        icon: Icons.people_outline,
                      ),
                      SizedBox(height: 12),
                      SummaryCard(
                        title: 'Active Users',
                        value: '927',
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 12),
                      SummaryCard(
                        title: 'Trial Users',
                        value: '642',
                        icon: Icons.schedule_outlined,
                      ),
                      SizedBox(height: 12),
                      SummaryCard(
                        title: 'Paid Users',
                        value: '927',
                        icon: Icons.workspace_premium_outlined,
                      ),
                    ],
                  );
                }

                return const Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Users',
                        value: '1,284',
                        icon: Icons.people_outline,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: SummaryCard(
                        title: 'Active Users',
                        value: '927',
                        icon: Icons.person_outline,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: SummaryCard(
                        title: 'Trial Users',
                        value: '642',
                        icon: Icons.schedule_outlined,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: SummaryCard(
                        title: 'Paid Users',
                        value: '927',
                        icon: Icons.workspace_premium_outlined,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

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
                    Expanded(
                      flex: 3,
                      child: _buildGrowthCard(),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _buildAlertCard(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            _buildCommitmentToday(),

            const SizedBox(height: 22),

            _buildBusinessSnapshot(),
          ],
        ),
      ),
    );
  }

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
        : List.generate(
            27,
            (index) => '${2000 + index}',
          );

    final values =
        chartMode == 'Monthly' ? monthlyValues : yearlyValues;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        22,
      ),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Growth',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'New registered users',
                      style: TextStyle(
                        color: CommitmentAdminApp.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 125,
                height: 42,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: CommitmentAdminApp.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: chartMode,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: 'Yearly',
                        child: Text('Yearly'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          chartMode = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Horizontal scroll prevents yearly labels from
          // overflowing.
          SizedBox(
            height: 310,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartMode == 'Monthly'
                    ? 760
                    : 1450,
                child: CustomPaint(
                  painter: GrowthChartPainter(
                    values: values,
                    labels: labels,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alert Health',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 25),
          _healthBar('Popup Delivered', 94),
          const SizedBox(height: 22),
          _healthBar('Notification Delivered', 97),
          const SizedBox(height: 22),
          _healthBar('Email Delivered', 89),
          const SizedBox(height: 22),
          _healthBar('Failed Delivery', 6),
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
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 7,
            backgroundColor: const Color(0xFFDCEBF5),
            color: CommitmentAdminApp.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCommitmentToday() {
    final data = [
      ['Team Meeting', 'Riya Sharma', 'Created'],
      ['Complete Assignment', 'Arun Kumar', 'Completed'],
      ['Client Meeting', 'Meera Patel', 'Late'],
      ['Doctor Appointment', 'Rahul Kumar', 'Missed'],
      ['Project Review', 'Ananya Singh', 'Cancelled'],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        18,
      ),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Commitment Today',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onCommitmentsPressed,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _TodayNumber(
                number: '25',
                label: 'Created',
              ),
              _TodayNumber(
                number: '18',
                label: 'Completed',
              ),
              _TodayNumber(
                number: '3',
                label: 'Late',
              ),
              _TodayNumber(
                number: '2',
                label: 'Missed',
              ),
              _TodayNumber(
                number: '2',
                label: 'Cancelled',
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          ...data.map(
            (item) => _todayRow(
              item[0],
              item[1],
              item[2],
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayRow(
    String title,
    String user,
    String status,
  ) {
    Color statusColor = const Color(0xFF8A949E);

    if (status == 'Completed') {
      statusColor = const Color(0xFF2EAD54);
    } else if (status == 'Late') {
      statusColor = const Color(0xFFE99A13);
    } else if (status == 'Missed') {
      statusColor = const Color(0xFFE83E3E);
    }

    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user,
              style: const TextStyle(
                color: CommitmentAdminApp.textGrey,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              status,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessSnapshot() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Business Snapshot',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                'Month',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 19,
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return const Column(
                  children: [
                    _BusinessBox(
                      label: 'New',
                      value: '+128',
                    ),
                    SizedBox(height: 12),
                    _BusinessBox(
                      label: 'Cancel',
                      value: '-12',
                    ),
                    SizedBox(height: 12),
                    _BusinessBox(
                      label: 'Revenue',
                      value: '₹40,500',
                    ),
                    SizedBox(height: 12),
                    _BusinessBox(
                      label: 'Net Growth',
                      value: '+18.4%',
                    ),
                  ],
                );
              }

              return const Row(
                children: [
                  Expanded(
                    child: _BusinessBox(
                      label: 'New',
                      value: '+128',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _BusinessBox(
                      label: 'Cancel',
                      value: '-12',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _BusinessBox(
                      label: 'Revenue',
                      value: '₹40,500',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _BusinessBox(
                      label: 'Net Growth',
                      value: '+18.4%',
                    ),
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

class _TodayNumber extends StatelessWidget {
  final String number;
  final String label;

  const _TodayNumber({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: CommitmentAdminApp.textGrey,
          ),
        ),
      ],
    );
  }
}

class _BusinessBox extends StatelessWidget {
  final String label;
  final String value;

  const _BusinessBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CommitmentAdminApp.textGrey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
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
      ..color = CommitmentAdminApp.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFFDCEFFF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i <= 4; i++) {
      final y =
          top + (chartHeight / 4) * i;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );

      final value =
          ((4 - i) * 25).toString();

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

    if (values.isEmpty) return;

    final maxValue =
        values.reduce((a, b) => a > b ? a : b);

    final step = values.length == 1
        ? chartWidth
        : chartWidth / (values.length - 1);

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = left + step * i;
      final normalized =
          values[i] / maxValue;

      final y =
          top + chartHeight - normalized * chartHeight;

      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, top + chartHeight);

    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }

    fillPath
      ..lineTo(
        points.last.dx,
        top + chartHeight,
      )
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    final linePath = Path()
      ..moveTo(
        points.first.dx,
        points.first.dy,
      );

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      canvas.drawCircle(
        point,
        4,
        Paint()..color = CommitmentAdminApp.primary,
      );

      final textWidth =
          _textWidth(labels[i]);

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
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(
    covariant GrowthChartPainter oldDelegate,
  ) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels;
  }
}

// ============================================================
// USERS MODEL
// ============================================================

class UserRecord {
  String name;
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
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'
          .toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}

// ============================================================
// USERS PAGE
// ============================================================

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final searchController = TextEditingController();

  String statusFilter = 'All';
  String planFilter = 'All';

  int currentPage = 1;
  final int pageSize = 5;

  final List<UserRecord> users = [
    UserRecord(
      name: 'Riya Sharma',
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
    super.dispose();
  }

  List<UserRecord> get filteredUsers {
    final query =
        searchController.text.trim().toLowerCase();

    return users.where((user) {
      final searchMatch =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.business.toLowerCase().contains(query);

      final statusMatch =
          statusFilter == 'All' ||
          user.status == statusFilter;

      final planMatch =
          planFilter == 'All' ||
          user.plan == planFilter;

      return searchMatch && statusMatch && planMatch;
    }).toList();
  }

  List<UserRecord> get currentUsers {
    final list = filteredUsers;

    final start =
        (currentPage - 1) * pageSize;

    if (start >= list.length) {
      return [];
    }

    final end =
        (start + pageSize).clamp(0, list.length);

    return list.sublist(start, end);
  }

  int get totalPages {
    if (filteredUsers.isEmpty) return 1;
    return (filteredUsers.length / pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          32,
          30,
          32,
          45,
        ),
        child: Column(
          children: [
            PageHeader(
              title: 'Users',
              subtitle:
                  'Manage and monitor application users',
              action: FilledButton.icon(
                onPressed: _addUser,
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      CommitmentAdminApp.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            _buildFilters(),
            const SizedBox(height: 18),
            _buildTable(),
            const SizedBox(height: 16),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {
                  currentPage = 1;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 145,
            child: _dropdown(
              value: statusFilter,
              items: const [
                'All',
                'Active',
                'Pending',
                'Inactive',
              ],
              onChanged: (value) {
                setState(() {
                  statusFilter = value!;
                  currentPage = 1;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 145,
            child: _dropdown(
              value: planFilter,
              items: const [
                'All',
                'Trial',
                'Premium',
              ],
              onChanged: (value) {
                setState(() {
                  planFilter = value!;
                  currentPage = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CommitmentAdminApp.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
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

  Widget _buildTable() {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('User'),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Business'),
                ),
                Expanded(
                  child: Text('Plan'),
                ),
                Expanded(
                  child: Text('Commitments'),
                ),
                Expanded(
                  child: Text('Status'),
                ),
                Expanded(
                  child: Text('Created Date'),
                ),
                SizedBox(
                  width: 45,
                  child: Text(''),
                ),
              ],
            ),
          ),
          if (currentUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(50),
              child: Text(
                'No users found',
                style: TextStyle(
                  color: CommitmentAdminApp.textGrey,
                ),
              ),
            )
          else
            ...currentUsers.map(
              (user) => _userRow(user),
            ),
        ],
      ),
    );
  }

  Widget _userRow(UserRecord user) {
    return InkWell(
      onTap: () => _showUserDetails(user),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 72,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: CommitmentAdminApp.border,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor:
                        CommitmentAdminApp.lightBlue,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color:
                            CommitmentAdminApp.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color:
                                CommitmentAdminApp.textGrey,
                            fontSize: 12,
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
              ),
            ),
            Expanded(
              child: _planChip(user.plan),
            ),
            Expanded(
              child: Text(
                '${user.commitments}',
              ),
            ),
            Expanded(
              child: _statusChip(user.status),
            ),
            Expanded(
              child: Text(
                user.createdDate,
              ),
            ),
            SizedBox(
              width: 45,
              child: PopupMenuButton<String>(
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
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: CommitmentAdminApp.lightBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          plan,
          style: const TextStyle(
            fontSize: 12,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Showing ${filteredUsers.isEmpty ? 0 : ((currentPage - 1) * pageSize) + 1}'
          '–${((currentPage - 1) * pageSize + currentUsers.length)}'
          ' of ${filteredUsers.length}',
          style: const TextStyle(
            color: CommitmentAdminApp.textGrey,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 18),
        IconButton(
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate(
          totalPages,
          (index) {
            final page = index + 1;
            final selected = page == currentPage;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () {
                  setState(() {
                    currentPage = page;
                  });
                },
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? CommitmentAdminApp.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: selected
                          ? CommitmentAdminApp.primary
                          : CommitmentAdminApp.border,
                    ),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : CommitmentAdminApp.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _showUserDetails(UserRecord user) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                        backgroundColor:
                            CommitmentAdminApp.lightBlue,
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            color:
                                CommitmentAdminApp.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color:
                                    CommitmentAdminApp.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(context),
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
        _detailItem('Phone', user.phone),
        _detailItem('Business', user.business),
        _detailItem('Plan', user.plan),
        _detailItem('Status', user.status),
        _detailItem(
          'Commitments',
          '${user.commitments}',
        ),
        _detailItem(
          'Created Date',
          user.createdDate,
        ),
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
            style: const TextStyle(
              color: CommitmentAdminApp.textGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _performanceBox(
    String title,
    int value,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
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
    final email = TextEditingController();
    final business = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add User'),
          content: SizedBox(
            width: 450,
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
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: business,
                  decoration: const InputDecoration(
                    labelText: 'Business',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty ||
                    email.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  users.insert(
                    0,
                    UserRecord(
                      name: name.text.trim(),
                      email: email.text.trim(),
                      phone: '+91 XXXXX XXXXX',
                      business:
                          business.text.trim().isEmpty
                              ? '—'
                              : business.text.trim(),
                      plan: 'Trial',
                      commitments: 0,
                      status: 'Active',
                      createdDate: '25 Sep 2026',
                      completed: 0,
                      late: 0,
                      missed: 0,
                    ),
                  );
                  currentPage = 1;
                });

                Navigator.pop(context);
              },
              child: const Text('Add User'),
            ),
          ],
        );
      },
    );
  }

  void _editUser(UserRecord user) {
    final name =
        TextEditingController(text: user.name);
    final email =
        TextEditingController(text: user.email);
    final business =
        TextEditingController(text: user.business);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(
            width: 450,
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
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: business,
                  decoration: const InputDecoration(
                    labelText: 'Business',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  user.name = name.text.trim();
                  user.email = email.text.trim();
                  user.business =
                      business.text.trim();
                });

                Navigator.pop(context);
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
  const CommitmentsPage({super.key});

  @override
  State<CommitmentsPage> createState() =>
      _CommitmentsPageState();
}

class _CommitmentsPageState
    extends State<CommitmentsPage> {
  final searchController = TextEditingController();

  String statusFilter = 'All';
  String typeFilter = 'All';
  String userFilter = 'All';
  String dateFilter = 'All';

  int currentPage = 1;
  final int pageSize = 5;

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
    super.dispose();
  }

  List<CommitmentRecord> get filteredCommitments {
    final query =
        searchController.text.trim().toLowerCase();

    return commitments.where((item) {
      final searchMatch =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.user.toLowerCase().contains(query);

      final statusMatch =
          statusFilter == 'All' ||
          item.status == statusFilter;

      final typeMatch =
          typeFilter == 'All' ||
          item.type == typeFilter;

      final userMatch =
          userFilter == 'All' ||
          item.user == userFilter;

      final dateMatch =
          dateFilter == 'All' ||
          item.dateTime.contains(dateFilter);

      return searchMatch &&
          statusMatch &&
          typeMatch &&
          userMatch &&
          dateMatch;
    }).toList();
  }

  List<CommitmentRecord> get currentCommitments {
    final list = filteredCommitments;
    final start =
        (currentPage - 1) * pageSize;

    if (start >= list.length) {
      return [];
    }

    final end =
        (start + pageSize).clamp(0, list.length);

    return list.sublist(start, end);
  }

  int get totalPages {
    if (filteredCommitments.isEmpty) return 1;
    return (filteredCommitments.length / pageSize)
        .ceil();
  }

  int get total =>
      commitments.length;

  int get dueToday =>
      commitments.where(
        (e) => e.dateTime.contains('25 Sep 2026'),
      ).length;

  int get completed =>
      commitments.where(
        (e) => e.status == 'Completed',
      ).length;

  int get late =>
      commitments.where(
        (e) => e.status == 'Late',
      ).length;

  int get missed =>
      commitments.where(
        (e) => e.status == 'Missed',
      ).length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          32,
          30,
          32,
          45,
        ),
        child: Column(
          children: [
            PageHeader(
              title: 'Commitments',
              subtitle:
                  'Manage and monitor all user commitments',
              action: FilledButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(
                  Icons.download_outlined,
                ),
                label: const Text('Export CSV'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF17232E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            _buildSummaryCards(),

            const SizedBox(height: 22),

            _buildFilters(),

            const SizedBox(height: 18),

            _buildTable(),

            const SizedBox(height: 16),

            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          SummaryCard(
            title: 'Total',
            value: '$total',
            icon: Icons.calendar_month_outlined,
          ),
          SummaryCard(
            title: 'Due Today',
            value: '$dueToday',
            icon: Icons.today_outlined,
          ),
          SummaryCard(
            title: 'Completed',
            value: '$completed',
            icon: Icons.check_circle_outline,
          ),
          SummaryCard(
            title: 'Late',
            value: '$late',
            icon: Icons.schedule_outlined,
          ),
          SummaryCard(
            title: 'Missed',
            value: '$missed',
            icon: Icons.cancel_outlined,
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
              if (i != cards.length - 1)
                const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    final users = [
      'All',
      ...{
        ...commitments.map((e) => e.user),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) {
              setState(() {
                currentPage = 1;
              });
            },
            decoration: const InputDecoration(
              hintText:
                  'Search commitment / user',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _filterBox(
                      'Status',
                      statusFilter,
                      const [
                        'All',
                        'Created',
                        'Completed',
                        'Late',
                        'Missed',
                        'Cancelled',
                      ],
                      (value) {
                        setState(() {
                          statusFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                    _filterBox(
                      'Type',
                      typeFilter,
                      const [
                        'All',
                        'Task',
                        'Online',
                        'In-person',
                      ],
                      (value) {
                        setState(() {
                          typeFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                    _filterBox(
                      'User',
                      userFilter,
                      users,
                      (value) {
                        setState(() {
                          userFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                    _filterBox(
                      'Date',
                      dateFilter,
                      const [
                        'All',
                        '25 Sep 2026',
                        '26 Sep 2026',
                        '27 Sep 2026',
                        '28 Sep 2026',
                        '29 Sep 2026',
                        '30 Sep 2026',
                      ],
                      (value) {
                        setState(() {
                          dateFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                    OutlinedButton(
                      onPressed: _clearFilters,
                      child:
                          const Text('Clear Filters'),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _filterBox(
                      'Status',
                      statusFilter,
                      const [
                        'All',
                        'Created',
                        'Completed',
                        'Late',
                        'Missed',
                        'Cancelled',
                      ],
                      (value) {
                        setState(() {
                          statusFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _filterBox(
                      'Type',
                      typeFilter,
                      const [
                        'All',
                        'Task',
                        'Online',
                        'In-person',
                      ],
                      (value) {
                        setState(() {
                          typeFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _filterBox(
                      'User',
                      userFilter,
                      users,
                      (value) {
                        setState(() {
                          userFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _filterBox(
                      'Date',
                      dateFilter,
                      const [
                        'All',
                        '25 Sep 2026',
                        '26 Sep 2026',
                        '27 Sep 2026',
                        '28 Sep 2026',
                        '29 Sep 2026',
                        '30 Sep 2026',
                      ],
                      (value) {
                        setState(() {
                          dateFilter = value!;
                          currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _clearFilters,
                    child:
                        const Text('Clear Filters'),
                  ),
                ],
              );
            },
          ),
        ],
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
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CommitmentAdminApp.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow:
                        TextOverflow.ellipsis,
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
    return Container(
      decoration: cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1100,
          child: Column(
            children: [
              Container(
                height: 56,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                color: const Color(0xFFF8FAFC),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 220,
                      child: Text('Commitment'),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text('User'),
                    ),
                    SizedBox(
                      width: 115,
                      child: Text('Type'),
                    ),
                    SizedBox(
                      width: 190,
                      child: Text('Date / Time'),
                    ),
                    SizedBox(
                      width: 110,
                      child: Text('Reminder'),
                    ),
                    SizedBox(
                      width: 130,
                      child: Text('Status'),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('Actions'),
                    ),
                  ],
                ),
              ),
              if (currentCommitments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                    'No commitments found',
                    style: TextStyle(
                      color:
                          CommitmentAdminApp.textGrey,
                    ),
                  ),
                )
              else
                ...currentCommitments.map(
                  _commitmentRow,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _commitmentRow(
    CommitmentRecord item,
  ) {
    return InkWell(
      onTap: () => _showDetails(item),
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: CommitmentAdminApp.border,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 220,
              child: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(item.user),
            ),
            SizedBox(
              width: 115,
              child: _typeChip(item.type),
            ),
            SizedBox(
              width: 190,
              child: Text(item.dateTime),
            ),
            SizedBox(
              width: 110,
              child: Text(item.reminder),
            ),
            SizedBox(
              width: 130,
              child: _commitmentStatus(
                item.status,
              ),
            ),
            SizedBox(
              width: 60,
              child: PopupMenuButton<String>(
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
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                ),
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
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          type,
          style: const TextStyle(
            fontSize: 12,
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
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final totalItems = filteredCommitments.length;
    final start = totalItems == 0
        ? 0
        : ((currentPage - 1) * pageSize) + 1;
    final end =
        ((currentPage - 1) * pageSize +
                currentCommitments.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Showing $start–$end of $totalItems',
          style: const TextStyle(
            color: CommitmentAdminApp.textGrey,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 18),
        IconButton(
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate(
          totalPages,
          (index) {
            final page = index + 1;
            final selected =
                page == currentPage;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 3,
              ),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(7),
                onTap: () {
                  setState(() {
                    currentPage = page;
                  });
                },
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? CommitmentAdminApp.primary
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(7),
                    border: Border.all(
                      color: selected
                          ? CommitmentAdminApp.primary
                          : CommitmentAdminApp.border,
                    ),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : CommitmentAdminApp.textDark,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      searchController.clear();
      statusFilter = 'All';
      typeFilter = 'All';
      userFilter = 'All';
      dateFilter = 'All';
      currentPage = 1;
    });
  }

  void _showDetails(CommitmentRecord item) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(item.title),
          content: SizedBox(
            width: 550,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _commitmentDetail(
                  'User',
                  item.user,
                ),
                _commitmentDetail(
                  'Type',
                  item.type,
                ),
                _commitmentDetail(
                  'Date / Time',
                  item.dateTime,
                ),
                _commitmentDetail(
                  'Reminder',
                  item.reminder,
                ),
                _commitmentDetail(
                  'Status',
                  item.status,
                ),
                _commitmentDetail(
                  'Description',
                  item.description,
                ),
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
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _commitmentDetail(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CommitmentAdminApp.border,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color:
                    CommitmentAdminApp.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editCommitment(
    CommitmentRecord item,
  ) {
    final title =
        TextEditingController(text: item.title);
    final description =
        TextEditingController(
      text: item.description,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Edit Commitment',
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration:
                      const InputDecoration(
                    labelText: 'Commitment',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  item.title =
                      title.text.trim();
                  item.description =
                      description.text.trim();
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCommitment(
    CommitmentRecord item,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Delete Commitment?',
          ),
          content: Text(
            'Are you sure you want to delete "${item.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFE83E3E),
              ),
              onPressed: () {
                setState(() {
                  commitments.remove(item);

                  if (currentPage > totalPages) {
                    currentPage = totalPages;
                  }
                });

                Navigator.pop(context);
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
              .map(
                (value) =>
                    '"${value.replaceAll('"', '""')}"',
              )
              .join(','),
        )
        .join('\n');

    final bytes = html.Blob(
      [csv],
      'text/csv;charset=utf-8',
    );

    final url =
        html.Url.createObjectUrlFromBlob(bytes);

    final anchor = html.AnchorElement(
      href: url,
    )
      ..setAttribute(
        'download',
        'commitments.csv',
      )
      ..click();

    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Commitments CSV exported successfully',
        ),
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER
// ============================================================

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          32,
          30,
          32,
          45,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: title,
              subtitle:
                  '$title management and monitoring',
            ),
            Container(
              width: double.infinity,
              height: 350,
              decoration: cardDecoration(),
              child: const Center(
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    color:
                        CommitmentAdminApp.textGrey,
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