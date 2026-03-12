import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/fade_slide_in.dart';
import 'create_project_page.dart';
import 'login_page.dart';
import 'project_progress_page.dart';

class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  String? _userName;
  List<dynamic> _runningProjects = [];
  List<dynamic> _openProjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      print('========== BUYER HOME - LOADING DATA ==========');
      final email = await AuthService.getEmail();
      _userName = email?.split('@')[0] ?? 'Buyer';
      print('Buyer Name: $_userName');
      print('==============================================\n');

      print('========== FETCHING PROJECTS ==========');
      final projects = await ApiService.getProjects();
      print('Projects API Response:');
      print(JsonEncoder.withIndent('  ').convert(projects));
      print('Total Projects: ${projects.length}');
      print('======================================\n');

      // Split into running (has tasks) and open (needs developer)
      _runningProjects = projects.where((p) => !p['is_open']).toList();
      _openProjects = projects.where((p) => p['is_open']).toList();

      print('========== PROJECTS SPLIT ==========');
      print('Running Projects: ${_runningProjects.length}');
      print(JsonEncoder.withIndent('  ').convert(_runningProjects));
      print('Open Projects: ${_openProjects.length}');
      print(JsonEncoder.withIndent('  ').convert(_openProjects));
      print('====================================\n');

      setState(() => _isLoading = false);
    } catch (e) {
      print('========== ERROR LOADING DATA ==========');
      print('Error: $e');
      print('=======================================\n');
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.08,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.business,
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
                              _userName ?? 'Buyer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Role: Buyer',
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
                            text: 'Smarter Developer Discovery',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FadeSlideIn(
                        key: const ValueKey('buyer-content'),
                        child: SingleChildScrollView(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Running Projects
                          Text(
                            'Running Projects',
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          if (_runningProjects.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No running projects'),
                              ),
                            )
                          else
                            SizedBox(
                              height: size.height * 0.22,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _runningProjects.length,
                                itemBuilder: (context, index) {
                                  final project = _runningProjects[index];
                                  return _buildProjectCard(project, size);
                                },
                              ),
                            ),

                          SizedBox(height: size.height * 0.03),

                          // Open Projects (Awaiting Developer)
                          Text(
                            'Awaiting Developer Assignment',
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          if (_openProjects.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No projects awaiting assignment'),
                              ),
                            )
                          else
                            ..._openProjects.map((project) {
                              return _buildOpenProjectCard(project, size);
                            }),
                        ],
                      ),
                    ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateProjectPage()),
          ).then((_) => _loadData());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Job'),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, Size size) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          print('========== OPENING PROJECT PROGRESS ==========');
          print('Project ID: ${project['id']}');
          print('Project Title: ${project['title']}');
          print('=============================================\n');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectProgressPage(project: project),
            ),
          ).then((_) {
            print('========== RETURNED FROM PROJECT PROGRESS ==========');
            print('Reloading data...');
            print('===================================================\n');
            _loadData();
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: size.width * 0.7,
          constraints: BoxConstraints(minHeight: size.height * 0.19),
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['title'] ?? 'Untitled',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                project['description'] ?? 'No description',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.secondary,
                    size: size.width * 0.04,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'In Progress',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: size.width * 0.04,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenProjectCard(Map<String, dynamic> project, Size size) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          _showProposals(project);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['title'] ?? 'Untitled',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                project['description'] ?? 'No description',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.withAlpha(AppColors.statusWarning, 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AWAITING DEVELOPER',
                      style: TextStyle(
                        color: AppColors.statusWarning,
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.025),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showProposals(project),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text(
                          'View Proposals',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

  Future<void> _showProposals(Map<String, dynamic> project) async {
    print('========== FETCHING PROPOSALS ==========');
    print('Project ID: ${project['id']}');

    final proposals = await ApiService.getProjectProposals(project['id']);

    print('Proposals API Response:');
    print(JsonEncoder.withIndent('  ').convert(proposals));
    print('Total Proposals: ${proposals.length}');
    print('=======================================\n');

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    'Proposals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: proposals.isEmpty
                      ? const Center(child: Text('No proposals yet'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: proposals.length,
                          itemBuilder: (context, index) {
                            final proposal = proposals[index];
                            return _buildProposalTile(proposal, project['id']);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProposalTile(Map<String, dynamic> proposal, int projectId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal['developer_name'] ?? 'Developer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        proposal['developer_email'] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Cover Letter:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(proposal['cover_letter'] ?? 'No cover letter'),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Rate: \$${proposal['proposed_hourly_rate']}/hr'),
                const SizedBox(width: 20),
                Text('Est: ${proposal['estimated_hours']}hrs'),
              ],
            ),
            if (proposal['status'] == 'pending') ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await _acceptProposalAndCreateTask(proposal['id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                child: const Text('Accept Proposal'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _acceptProposalAndCreateTask(int proposalId) async {
    print('========== ACCEPT PROPOSAL & CREATE TASK ==========');
    print('Proposal ID: $proposalId');
    print('==================================================\n');

    try {
      final success = await ApiService.acceptProposalAndCreateTask(proposalId);

      if (success) {
        if (!mounted) return;

        print('========== PROPOSAL & TASK ACCEPTED ==========');
        print('Proposal ID: $proposalId');
        print('Task created successfully');
        print('Project is_open set to FALSE');
        print('============================================\n');

        Navigator.pop(context);
        _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proposal accepted & task created!'),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
      } else {
        print('========== ERROR ACCEPTING PROPOSAL ==========');
        print('Failed to accept proposal');
        print('===========================================\n');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept proposal'),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    } catch (e) {
      print('========== ERROR IN ACCEPT PROPOSAL ==========');
      print('Error: $e');
      print('=========================================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }
}
