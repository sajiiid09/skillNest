import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/fade_slide_in.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _durationController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final result = await ApiService.createProject({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'expected_hourly_rate': double.parse(_hourlyRateController.text),
      'expected_duration_hours': double.parse(_durationController.text),
      'tags': tags,
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project created successfully!'),
          backgroundColor: AppColors.statusSuccess,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create project'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Job'),
      ),
      body: SafeArea(
        child: FadeSlideIn(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                'Post a New Job',
                style: TextStyle(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
                  ),
                  SizedBox(height: size.height * 0.02),

              // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Job Title *',
                    hintText: 'e.g., Flutter Mobile App Developer',
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),

              SizedBox(height: size.height * 0.02),

              // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Job Description *',
                    hintText: 'Describe the project requirements...',
                  ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              SizedBox(height: size.height * 0.02),

              // Hourly Rate & Duration
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 360;
                  return Flex(
                    direction: isNarrow ? Axis.vertical : Axis.horizontal,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hourlyRateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Hourly Rate *',
                            prefixText: '\$',
                            hintText: '50',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: isNarrow ? 0 : size.width * 0.03,
                        height: isNarrow ? size.height * 0.015 : 0,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duration *',
                            suffixText: 'hrs',
                            hintText: '40',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: size.height * 0.02),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Skills/Tags (comma-separated)',
                  hintText: 'flutter, firebase, api, mobile',
                  helperText: 'Separate tags with commas',
                ),
              ),

              SizedBox(height: size.height * 0.04),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: size.height * 0.06,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _createProject,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          'Post Job',
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}
