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
  // Core palette
  static const Color primary = Color(0xFF41431B);
  static const Color secondary = Color(0xFFAEB784);
  static const Color accent = Color(0xFFE3DBBB);
  static const Color background = Color(0xFFF8F3E1);

  // Semantic surfaces and text
  static const Color cardBg = Color(0xFFFBF7EA);
  static const Color surfaceSoft = Color(0xFFF1E9D0);
  static const Color textPrimary = Color(0xFF41431B);
  static const Color textSecondary = Color(0xFF717649);
  static const Color border = Color(0xFFD9CFAD);
  static const Color onPrimary = Color(0xFFF8F3E1);

  // Status tokens
  static const Color statusNeutral = Color(0xFF8C9363);
  static const Color statusInfo = Color(0xFF6E7641);
  static const Color statusWarning = Color(0xFF8A7A3D);
  static const Color statusSuccess = Color(0xFF6C7E42);
  static const Color statusError = Color(0xFFB2453F);

  // Decorative tokens
  static const List<Color> headerGradient = [
    Color(0xFF41431B),
    Color(0xFF59612B),
  ];
  static const List<Color> heroGradient = [
    Color(0xFFF8F3E1),
    Color(0xFFE3DBBB),
  ];

  static Color withAlpha(Color color, double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return color.withOpacity(safeOpacity);
  }
}

class AppSpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 30;
}

class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

class AppElevation {
  static const double flat = 0;
  static const double card = 1.5;
  static const double raised = 3;
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
