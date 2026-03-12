import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/fade_slide_in.dart';
import 'login_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String? _userName;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final email = await AuthService.getEmail();
    _userName = email?.split('@')[0] ?? 'Admin';

    _stats = await ApiService.getDashboardStats();

    setState(() => _isLoading = false);
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(size.width * 0.05),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.headerGradient,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.withAlpha(AppColors.primary, 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: size.width * 0.08,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: size.width * 0.08,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName ?? 'Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),

            // Stats
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FadeSlideIn(
                        key: const ValueKey('admin-content'),
                        child: RefreshIndicator(
                            onRefresh: _loadData,
                            child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Platform Statistics',
                              style: TextStyle(
                                fontSize: size.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: size.height * 0.03),

                            // Users
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Buyers',
                                    _stats?['total_buyers']?.toString() ?? '0',
                                    Icons.business,
                                    AppColors.primary,
                                    size,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: _buildStatCard(
                                    'Developers',
                                    _stats?['total_developers']?.toString() ??
                                        '0',
                                    Icons.code,
                                    AppColors.secondary,
                                    size,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.02),

                            // Projects & Tasks
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Projects',
                                    _stats?['total_projects']?.toString() ??
                                        '0',
                                    Icons.work,
                                    AppColors.statusWarning,
                                    size,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: _buildStatCard(
                                    'Total Tasks',
                                    _stats?['total_tasks']?.toString() ?? '0',
                                    Icons.task,
                                    AppColors.statusInfo,
                                    size,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 0.03),

                            Text(
                              'Task Breakdown',
                              style: TextStyle(
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: size.height * 0.02),

                            // Task Status
                            _buildFullWidthCard(
                              'To Do',
                              _stats?['tasks_todo']?.toString() ?? '0',
                              Icons.pending_actions,
                              AppColors.statusNeutral,
                              size,
                            ),
                            SizedBox(height: size.height * 0.015),
                            _buildFullWidthCard(
                              'In Progress',
                              _stats?['tasks_in_progress']?.toString() ?? '0',
                              Icons.autorenew,
                              AppColors.statusInfo,
                              size,
                            ),
                            SizedBox(height: size.height * 0.015),
                            _buildFullWidthCard(
                              'Submitted',
                              _stats?['tasks_submitted']?.toString() ?? '0',
                              Icons.upload_file,
                              AppColors.statusWarning,
                              size,
                            ),
                            SizedBox(height: size.height * 0.015),
                            _buildFullWidthCard(
                              'Completed (Paid)',
                              _stats?['tasks_completed']?.toString() ?? '0',
                              Icons.check_circle,
                              AppColors.secondary,
                              size,
                            ),

                            SizedBox(height: size.height * 0.03),

                            // Revenue
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(size.width * 0.05),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.withAlpha(AppColors.primary, 0.82),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: size.width * 0.12,
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    Text(
                                      'Total Revenue',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: size.width * 0.04,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                    Text(
                                      '\$${_stats?['total_revenue']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size.width * 0.08,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              '${_stats?['total_payments'] ?? 0}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size.width * 0.05,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Payments',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: size.width * 0.032,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '${_stats?['total_developer_hours']?.toStringAsFixed(0) ?? 0}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size.width * 0.05,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Total Hours',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: size.width * 0.032,
                                              ),
                                            ),
                                          ],
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
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Size size,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Icon(icon, color: color, size: size.width * 0.1),
            SizedBox(height: size.height * 0.01),
            Text(
              value,
              style: TextStyle(
                fontSize: size.width * 0.08,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: size.width * 0.032,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Size size,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Row(
          children: [
            Icon(icon, color: color, size: size.width * 0.08),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
