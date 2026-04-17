import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../services/auth_service.dart';
import 'complete_dashboard_screen.dart';

/// Rota raiz: exibe LoginScreen ou Dashboard conforme estado de auth.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return const CompleteDashboardScreen();
  }
}
