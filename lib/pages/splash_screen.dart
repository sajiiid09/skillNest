import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Bottom Content with Blur
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.06,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Find Your Dream Job',
                        style: TextStyle(
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: size.height * 0.015),

                      // Subtitle
                      Text(
                        'Connect with top companies and talented developers',
                        style: TextStyle(
                          fontSize: size.width * 0.038,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.065,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: AppColors.primary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
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
        ],
      ),
    );
  }
}
