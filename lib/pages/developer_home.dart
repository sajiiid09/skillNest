import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/fade_slide_in.dart';
import 'TaskDetailsPage.dart';
import 'login_page.dart';
import 'project_details_page.dart';

class DeveloperHome extends StatefulWidget {
  const DeveloperHome({super.key});

  @override
  State<DeveloperHome> createState() => _DeveloperHomeState();
}

class _DeveloperHomeState extends State<DeveloperHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String? _userName;
  List<dynamic> _allJobs = [];
  List<dynamic> _appliedJobs = [];
  List<dynamic> _runningProjects = [];
  List<dynamic> _completedJobs = [];
  bool _isLoading = true;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final email = await AuthService.getEmail();
      _userName = email?.split('@')[0] ?? 'Developer';
      print('========== USER EMAIL LOADED ==========');
      print('User Name: $_userName');
      print('=====================================\n');

      // Load all open projects
      print('========== FETCHING ALL JOBS ==========');
      _allJobs = await ApiService.getProjects();
      print('All Jobs API Response:');
      print(JsonEncoder.withIndent('  ').convert(_allJobs));
      print('Total Jobs: ${_allJobs.length}');
      print('=====================================\n');

      // Load applied jobs (proposals)
      print('========== FETCHING APPLIED JOBS ==========');
      _appliedJobs = await ApiService.getMyProposals();
      print('Applied Jobs (Proposals) API Response:');
      print(JsonEncoder.withIndent('  ').convert(_appliedJobs));
      print('Total Applied Jobs: ${_appliedJobs.length}');
      print('==========================================\n');

      // Load running and completed tasks
      print('========== FETCHING MY TASKS ==========');
      final tasks = await ApiService.getMyTasks();
      print('All Tasks API Response:');
      print(JsonEncoder.withIndent('  ').convert(tasks));
      print('Total Tasks: ${tasks.length}');
      print('======================================\n');

      _runningProjects = tasks.where((t) => t['status'] != 'paid').toList();
      print('========== FILTERING RUNNING PROJECTS ==========');
      print('Running Projects: ${_runningProjects.length}');
      print(JsonEncoder.withIndent('  ').convert(_runningProjects));
      print('==============================================\n');

      _completedJobs = tasks.where((t) => t['status'] == 'paid').toList();
      print('========== FILTERING COMPLETED JOBS ==========');
      print('Completed Jobs (Status: paid): ${_completedJobs.length}');
      print(JsonEncoder.withIndent('  ').convert(_completedJobs));
      print('============================================\n');

      setState(() => _isLoading = false);
    } catch (e) {
      print('========== ERROR LOADING DATA ==========');
      print('Error: $e');
      print('======================================\n');
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  List<dynamic> get _filteredJobs {
    if (_searchQuery.isEmpty) return _allJobs;
    return _allJobs.where((job) {
      final tags = (job['tags'] as List).map((e) => e.toString().toLowerCase());
      final query = _searchQuery.toLowerCase();
      return tags.any((tag) => tag.contains(query)) ||
          job['title'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
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
                    color: AppColors.withAlpha(AppColors.primary, 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.08,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
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
                              _userName ?? 'Developer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Role: Developer',
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
                  SizedBox(height: size.height * 0.02),
                  // Welcome Text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(text: 'Welcome to '),
                          TextSpan(
                            text: 'Smarter Job Discovery',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  // Search Box
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by skill tag (flutter, ai, etc.)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: AppColors.background,
              child: TabBar(
                controller: _tabController,
                isScrollable: size.width < 380,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'All Jobs'),
                  Tab(text: 'Applied'),
                  Tab(text: 'Running'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FadeSlideIn(
                        key: const ValueKey('dev-content'),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAllJobsTab(),
                            _buildAppliedJobsTab(),
                            _buildRunningProjectsTab(),
                            _buildCompletedJobsTab(),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllJobsTab() {
    final jobs = _filteredJobs;

    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs available'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final size = MediaQuery.of(context).size;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailsPage(project: job),
            ),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job['title'] ?? 'Untitled',
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job['is_open'] ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                job['description'] ?? 'No description',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: size.width * 0.045,
                    color: AppColors.primary,
                  ),
                  Text(
                    '\$${job['expected_hourly_rate']?.toStringAsFixed(0) ?? '0'}/hr',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  Icon(
                    Icons.access_time,
                    size: size.width * 0.045,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    '${job['expected_duration_hours']?.toStringAsFixed(0) ?? '0'}hrs',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (job['tags'] != null && (job['tags'] as List).isNotEmpty) ...[
                SizedBox(height: size.height * 0.015),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (job['tags'] as List).take(3).map<Widget>((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag.toString(),
                        style: TextStyle(
                          fontSize: size.width * 0.03,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppliedJobsTab() {
    if (_appliedJobs.isEmpty) {
      return const Center(child: Text('No applied jobs yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appliedJobs.length,
      itemBuilder: (context, index) {
        final proposal = _appliedJobs[index];
        return _buildProposalCard(proposal);
      },
    );
  }

  Widget _buildProposalCard(Map<String, dynamic> proposal) {
    final size = MediaQuery.of(context).size;
    final status = proposal['status'] ?? 'pending';

    Color statusColor;
    if (status == 'accepted') {
      statusColor = AppColors.secondary;
    } else if (status == 'rejected') {
      statusColor = AppColors.statusError;
    } else {
      statusColor = AppColors.statusWarning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Project #${proposal['project_id']}',
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: size.width * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Rate: \$${proposal['proposed_hourly_rate']}/hr',
              style: TextStyle(
                fontSize: size.width * 0.038,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Est. Hours: ${proposal['estimated_hours']}',
              style: TextStyle(
                fontSize: size.width * 0.038,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunningProjectsTab() {
    if (_runningProjects.isEmpty) {
      return const Center(child: Text('No running projects'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _runningProjects.length,
        itemBuilder: (context, index) {
          final task = _runningProjects[index];
          return _buildRunningTaskCard(task);
        },
      ),
    );
  }

  Widget _buildRunningTaskCard(Map<String, dynamic> task) {
    final size = MediaQuery.of(context).size;
    final rate = task['hourly_rate'] ?? 0;
    final rateStr =
        rate is int ? rate.toString() : (rate as double).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailsPage(task: task),
            ),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task['title'] ?? 'Untitled Task',
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (task['status'] ?? 'unknown').toString().toUpperCase(),
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                task['description'] ?? 'No description',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: size.width * 0.045,
                    color: AppColors.primary,
                  ),
                  Text(
                    '\$$rateStr/hr',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  Icon(
                    Icons.assignment,
                    size: size.width * 0.045,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    'Project #${task['project_id']}',
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedJobsTab() {
    if (_completedJobs.isEmpty) {
      return const Center(child: Text('No completed jobs'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedJobs.length,
      itemBuilder: (context, index) {
        final task = _completedJobs[index];
        return _buildCompletedTaskCard(task);
      },
    );
  }

  Widget _buildCompletedTaskCard(Map<String, dynamic> task) {
    final size = MediaQuery.of(context).size;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task['title'] ?? 'Untitled Task',
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PAID',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: size.width * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              task['description'] ?? 'No description',
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: size.height * 0.015),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: size.width * 0.045,
                  color: AppColors.secondary,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  'Completed and Paid',
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
