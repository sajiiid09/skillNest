import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/fade_slide_in.dart';
import 'login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.heroGradient,
              ),
            ),
          ),
          Positioned(
            top: -size.width * 0.32,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.72,
              height: size.width * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.withAlpha(AppColors.secondary, 0.28),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.4,
            left: -size.width * 0.25,
            child: Container(
              width: size.width * 0.95,
              height: size.width * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.withAlpha(AppColors.primary, 0.12),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: size.height * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    beginOffsetY: 0.03,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.withAlpha(AppColors.primary, 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: AppColors.withAlpha(AppColors.primary, 0.2),
                        ),
                      ),
                      child: const Text(
                        'SMART JOB DISCOVERY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeSlideIn(
                    child: Text(
                      'Find better projects.\nHire faster.',
                      style: TextStyle(
                        fontSize: size.width * 0.11,
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.018),
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 420),
                    child: Text(
                      'A clean workspace for buyers, developers, and admins to track project progress from one place.',
                      style: TextStyle(
                        fontSize: size.width * 0.039,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  FadeSlideIn(
                    duration: const Duration(milliseconds: 520),
                    child: SizedBox(
                      width: double.infinity,
                      height: size.height * 0.066,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: size.width * 0.043,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
