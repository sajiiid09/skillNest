import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/api_service.dart';
import '../utils/constants.dart';

class ProjectProgressPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectProgressPage({super.key, required this.project});

  @override
  State<ProjectProgressPage> createState() => _ProjectProgressPageState();
}

class _ProjectProgressPageState extends State<ProjectProgressPage> {
  late Map<String, dynamic> _projectDetails;
  List<dynamic> _tasks = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadProgress = '';

  @override
  void initState() {
    super.initState();
    _projectDetails = widget.project;
    _loadProjectTasks();
  }

  Future<void> _loadProjectTasks() async {
    setState(() => _isLoading = true);

    try {
      print('========== FETCHING PROJECT TASKS ==========');
      print('Project ID: ${_projectDetails['id']}');

      final tasks = await ApiService.getProjectTasks(_projectDetails['id']);

      print('Tasks Retrieved: ${tasks.length}');
      print('Tasks Response:');
      print(JsonEncoder.withIndent('  ').convert(tasks));
      print('==========================================\n');

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('========== ERROR LOADING TASKS ==========');
      print('Error: $e');
      print('=======================================\n');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tasks: $e')),
      );
    }
  }

  Future<void> _makePayment(int taskId) async {
    print('========== MAKING PAYMENT ==========');
    print('Task ID: $taskId');

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.makePayment(taskId);

      print('Payment Status: $success');
      print('====================================\n');

      if (success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload tasks to update status
        _loadProjectTasks();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('========== ERROR MAKING PAYMENT ==========');
      print('Error: $e');
      print('======================================\n');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadFile(int taskId, String fileName) async {
    print('========== DOWNLOADING FILE ==========');
    print('Task ID: $taskId');
    print('File Name: $fileName');

    setState(() {
      _isDownloading = true;
      _downloadProgress = 'Starting download...';
    });

    try {
      // Get the download directory
      final directory = await getDownloadsDirectory();
      final savePath = '${directory?.path}/$fileName';

      print('Save Path: $savePath');

      // Call download endpoint
      final fileBytes = await ApiService.downloadTaskFile(taskId);

      if (fileBytes == null || fileBytes.isEmpty) {
        throw Exception('File download failed');
      }

      // Save file
      final file = File(savePath);
      await file.writeAsBytes(fileBytes);

      print('========== FILE DOWNLOADED SUCCESSFULLY ==========');
      print('File Path: $savePath');
      print('File Size: ${fileBytes.length} bytes');
      print('================================================\n');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded: $fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('========== ERROR DOWNLOADING FILE ==========');
      print('Error: $e');
      print('=========================================\n');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_projectDetails['title'] ?? 'Project'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Project Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8)
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _projectDetails['title'] ?? 'Untitled Project',
                          style: TextStyle(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          _projectDetails['description'] ?? 'No description',
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'IN PROGRESS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Budget Info
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Budget',
                            '\$${_projectDetails['budget']?.toStringAsFixed(2) ?? '0'}',
                            Icons.attach_money,
                            size,
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: _buildInfoCard(
                            'Status',
                            'Running',
                            Icons.hourglass_bottom,
                            size,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tasks Section
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work Progress',
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        if (_tasks.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(size.width * 0.05),
                              child: const Text('No tasks assigned'),
                            ),
                          )
                        else
                          ..._tasks.map((task) {
                            return _buildTaskProgressCard(task, size);
                          }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Size size,
  ) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: size.width * 0.05,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                title,
                style: TextStyle(
                  fontSize: size.width * 0.03,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskProgressCard(Map<String, dynamic> task, Size size) {
    final status = task['status'] ?? 'todo';
    final hasFile = task['solution_file_path'] != null &&
        (task['solution_file_path'] as String).isNotEmpty;
    final isPaid = status == 'paid';

    Color statusColor = _getStatusColor(status);

    return Card(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title & Status
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
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

            // Task Description
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

            // Time & Rate
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: size.width * 0.04,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  '${task['time_spent']?.toStringAsFixed(1) ?? '0'} hours logged',
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.attach_money,
                  size: size.width * 0.04,
                  color: AppColors.primary,
                ),
                Text(
                  '\$${task['hourly_rate']?.toStringAsFixed(0) ?? '0'}/hr',
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.015),

            // File Status & Actions
            if (hasFile) ...[
              Container(
                padding: EdgeInsets.all(size.width * 0.03),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.secondary,
                      size: size.width * 0.05,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solution Submitted',
                            style: TextStyle(
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            task['submitted_at'] ?? 'Submitted',
                            style: TextStyle(
                              fontSize: size.width * 0.03,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.015),

              // Payment & Download Section
              if (!isPaid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _makePayment(task['id']),
                    icon: const Icon(Icons.payment),
                    label: Text(
                      'Pay \$${((task['time_spent'] ?? 0) * (task['hourly_rate'] ?? 0)).toStringAsFixed(2)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                )
              else ...[
                // Show "Paid" status
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.secondary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.secondary,
                        size: size.width * 0.05,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Payment Completed',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.01),

                // Download Button (only after payment)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading
                        ? null
                        : () => _downloadFile(
                              task['id'],
                              'task_${task['id']}_solution.zip',
                            ),
                    icon: _isDownloading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(
                      _isDownloading ? _downloadProgress : 'Download Solution',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ] else if (status == 'submitted') ...[
              // File submitted but not yet paid
              Container(
                padding: EdgeInsets.all(size.width * 0.03),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.orange,
                      size: size.width * 0.05,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Text(
                        'Ready for Payment & Download',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.015),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _makePayment(task['id']),
                  icon: const Icon(Icons.payment),
                  label: Text(
                    'Pay & Download \$${((task['time_spent'] ?? 0) * (task['hourly_rate'] ?? 0)).toStringAsFixed(2)}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              // Still in progress
              Container(
                padding: EdgeInsets.all(size.width * 0.03),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.hourglass_bottom,
                      color: Colors.blue,
                      size: size.width * 0.05,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Text(
                        'Work in Progress',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'submitted':
        return Colors.orange;
      case 'paid':
        return AppColors.secondary;
      default:
        return Colors.grey;
    }
  }
}
