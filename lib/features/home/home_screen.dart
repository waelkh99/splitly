import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/session_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Image.asset(
                'assets/logo.png',
                width: 110,
                height: 110,
              ),
              const SizedBox(height: 20),
              Text(
                l.appName,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.homeTagline,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(flex: 3),
              // New Split CTA
              ElevatedButton(
                onPressed: () {
                  ref.read(splitSessionProvider.notifier).reset();
                  Navigator.pushNamed(context, AppRoutes.people);
                },
                child: Text(l.newSplit),
              ),
              const SizedBox(height: 16),
              // Secondary actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.history),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: Text(l.history),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.groups),
                    icon: const Icon(Icons.group_rounded, size: 18),
                    label: Text(l.groups),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 1,
        tooltip: l.settings,
        child: const Icon(Icons.settings_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
