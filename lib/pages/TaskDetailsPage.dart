import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/constants.dart';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late Map<String, dynamic> _taskDetails;
  File? _selectedFile;
  double _timeSpent = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  final TextEditingController _progressController = TextEditingController();
  final TextEditingController _timeSpentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taskDetails = widget.task;
    _loadTaskDetails();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timeSpentController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    setState(() => _isLoading = true);

    try {
      print('========== FETCHING TASK DETAILS ==========');
      print('Task ID: ${_taskDetails['id']}');
      print('===========================================\n');

      // Fetch full task details from API
      final response = await ApiService.getTaskDetails(_taskDetails['id']);

      print('========== TASK DETAILS API RESPONSE ==========');
      print(JsonEncoder.withIndent('  ').convert(response));
      print('=============================================\n');

      setState(() {
        _taskDetails = response;
        _isLoading = false;
      });
    } catch (e) {
      print('========== ERROR LOADING TASK DETAILS ==========');
      print('Error: $e');
      print('==============================================\n');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading task details: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      print('========== FILE PICKER OPENED ==========');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', '7z'],
        allowMultiple: false,
      );

      if (result != null) {
        _selectedFile = File(result.files.single.path!);

        print('========== FILE SELECTED ==========');
        print('File Name: ${_selectedFile!.path.split('/').last}');
        print('File Size: ${_selectedFile!.lengthSync()} bytes');
        print('===================================\n');

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File selected: ${_selectedFile!.path.split('/').last}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('File picker cancelled');
      }
    } catch (e) {
      print('========== ERROR PICKING FILE ==========');
      print('Error: $e');
      print('=======================================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitTask() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to submit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_timeSpentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter time spent'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final timeSpent = double.parse(_timeSpentController.text);

      print('========== SUBMITTING TASK ==========');
      print('Task ID: ${_taskDetails['id']}');
      print('Time Spent: $timeSpent hours');
      print('File: ${_selectedFile!.path.split('/').last}');
      print('====================================\n');

      final success = await ApiService.submitTask(
        _taskDetails['id'],
        timeSpent,
        _selectedFile!,
      );

      print('========== TASK SUBMISSION RESPONSE ==========');
      print('Success: $success');
      print('===========================================\n');

      if (success) {
        if (!mounted) return;

        print('========== TASK SUBMITTED SUCCESSFULLY ==========');
        print('Task ID: ${_taskDetails['id']}');
        print('Status updated to: SUBMITTED');
        print('================================================\n');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        print('========== TASK SUBMISSION FAILED ==========');
        print('Task ID: ${_taskDetails['id']}');
        print('==========================================\n');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('========== ERROR SUBMITTING TASK ==========');
      print('Error: $e');
      print('========================================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateProgress() async {
    if (_progressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter progress details'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      print('========== UPDATING TASK PROGRESS ==========');
      print('Task ID: ${_taskDetails['id']}');
      print('Progress: ${_progressController.text}');
      print('===========================================\n');

      // Here you can add API call to update progress
      // For now, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress updated!'),
          backgroundColor: Colors.green,
        ),
      );

      _progressController.clear();
    } catch (e) {
      print('========== ERROR UPDATING PROGRESS ==========');
      print('Error: $e');
      print('=========================================\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Task Details'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Task Header
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
                          _taskDetails['title'] ?? 'Untitled Task',
                          style: TextStyle(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
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
                            (_taskDetails['status'] ?? 'UNKNOWN')
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Task Information
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description Section
                        _buildInfoSection(
                          'Description',
                          _taskDetails['description'] ?? 'No description',
                          size,
                        ),
                        SizedBox(height: size.height * 0.02),

                        // Project & Developer Info
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Project ID',
                                '${_taskDetails['project_id']}',
                                Icons.assignment,
                                size,
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: _buildInfoCard(
                                'Hourly Rate',
                                '\$${_taskDetails['hourly_rate']}/hr',
                                Icons.attach_money,
                                size,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),

                        // Progress Update Section
                        if (_taskDetails['status'] != 'paid') ...[
                          // File Submission Section
                          Text(
                            'Submit Work',
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          // Time Spent Input
                          TextField(
                            controller: _timeSpentController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter hours spent on this task',
                              prefixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 15,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          // File Selection
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedFile != null
                                    ? AppColors.secondary
                                    : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _pickFile,
                                child: Padding(
                                  padding: EdgeInsets.all(size.width * 0.04),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        color: _selectedFile != null
                                            ? AppColors.secondary
                                            : Colors.grey,
                                        size: size.width * 0.08,
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedFile != null
                                                  ? 'File Selected'
                                                  : 'Select ZIP File',
                                              style: TextStyle(
                                                fontSize: size.width * 0.04,
                                                fontWeight: FontWeight.w600,
                                                color: _selectedFile != null
                                                    ? AppColors.secondary
                                                    : Colors.grey,
                                              ),
                                            ),
                                            if (_selectedFile != null)
                                              Text(
                                                _selectedFile!.path
                                                    .split('/')
                                                    .last,
                                                style: TextStyle(
                                                  fontSize: size.width * 0.03,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            else
                                              Text(
                                                'Tap to choose a ZIP file',
                                                style: TextStyle(
                                                  fontSize: size.width * 0.03,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: _selectedFile != null
                                            ? AppColors.secondary
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitTask,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Submit Task',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ] else ...[
                          // Completed/Paid state
                          Container(
                            padding: EdgeInsets.all(size.width * 0.04),
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
                                  Icons.check_circle,
                                  color: AppColors.secondary,
                                  size: size.width * 0.08,
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Task Completed',
                                        style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      Text(
                                        'This task has been paid and completed.',
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
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection(String title, String content, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          content,
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
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
}
