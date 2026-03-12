import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/fade_slide_in.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rateController.text =
        widget.project['expected_hourly_rate']?.toString() ?? '';
    _hoursController.text =
        widget.project['expected_duration_hours']?.toString() ?? '';
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _rateController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submitProposal() async {
    if (_coverLetterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a cover letter')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ApiService.submitProposal({
      'project_id': widget.project['id'],
      'cover_letter': _coverLetterController.text.trim(),
      'proposed_hourly_rate': double.parse(_rateController.text),
      'estimated_hours': double.parse(_hoursController.text),
    });

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal submitted successfully!'),
          backgroundColor: AppColors.statusSuccess,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit proposal'),
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
        title: const Text('Project Details'),
      ),
      body: SafeArea(
        child: FadeSlideIn(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Title
            Text(
              widget.project['title'] ?? 'Untitled',
              style: TextStyle(
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Description Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      widget.project['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: size.width * 0.038,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Budget & Duration
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                return Flex(
                  direction: isNarrow ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.04),
                          child: Column(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: AppColors.primary,
                                size: size.width * 0.08,
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                '\$${widget.project['expected_hourly_rate']?.toStringAsFixed(0) ?? '0'}',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Per Hour',
                                style: TextStyle(
                                  fontSize: size.width * 0.032,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow ? 0 : size.width * 0.03,
                      height: isNarrow ? size.height * 0.015 : 0,
                    ),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.04),
                          child: Column(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: AppColors.secondary,
                                size: size.width * 0.08,
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                '${widget.project['expected_duration_hours']?.toStringAsFixed(0) ?? '0'}',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                'Hours',
                                style: TextStyle(
                                  fontSize: size.width * 0.032,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: size.height * 0.02),

            // Skills
            if (widget.project['tags'] != null &&
                (widget.project['tags'] as List).isNotEmpty) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Skills',
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            (widget.project['tags'] as List).map<Widget>((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.withAlpha(AppColors.primary, 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.withAlpha(AppColors.primary, 0.32),
                              ),
                            ),
                            child: Text(
                              tag.toString(),
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
            ],

            // Proposal Form
            Text(
              'Submit Your Proposal',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Cover Letter
            TextField(
              controller: _coverLetterController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Cover Letter *',
                hintText:
                    'Explain why you\'re the best fit for this project...',
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Rate and Hours
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                return Flex(
                  direction: isNarrow ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Your Hourly Rate',
                          prefixText: '\$',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow ? 0 : size.width * 0.03,
                      height: isNarrow ? size.height * 0.015 : 0,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _hoursController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Est. Hours',
                          suffixText: 'hrs',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: size.height * 0.03),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: size.height * 0.06,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProposal,
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
                        'Submit Proposal',
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
    );
  }
}
