import 'dart:ui';

class ApiConstants {
  static const String baseUrl = 'http://192.168.0.108:8000/api/v1';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Projects
  static const String projects = '$baseUrl/projects';

  // Tasks
  static const String tasks = '$baseUrl/tasks';
  // ✅ FIXED: Changed from /tasks/my-tasks to /tasks/
  static const String myTasks = '$baseUrl/tasks/';

  // Proposals
  static const String proposals = '$baseUrl/proposals';
  static const String myProposals = '$baseUrl/proposals/my-proposals';

  // Payments
  static const String payments = '$baseUrl/payments';

  // Admin
  static const String adminDashboard = '$baseUrl/admin/dashboard';
}

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color border = Color(0xFFDFE6E9);
}

enum UserRole {
  buyer,
  developer,
  admin,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.buyer:
        return 'buyer';
      case UserRole.developer:
        return 'developer';
      case UserRole.admin:
        return 'admin';
    }
  }
}
