import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int total) {
    if (_page >= total - 1) {
      Navigator.pop(context);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cards = <_OnboardCardData>[
      _OnboardCardData(
        icon: Icons.celebration_rounded,
        tint: AppColors.primary,
        title: l.onboardCard1Title,
        body: l.onboardCard1Body,
      ),
      _OnboardCardData(
        icon: Icons.group_add_rounded,
        tint: AppColors.secondary,
        title: l.onboardCard2Title,
        body: l.onboardCard2Body,
      ),
      _OnboardCardData(
        icon: Icons.receipt_long_rounded,
        tint: AppColors.primary,
        title: l.onboardCard3Title,
        body: l.onboardCard3Body,
      ),
      _OnboardCardData(
        icon: Icons.share_rounded,
        tint: AppColors.secondary,
        title: l.onboardCard4Title,
        body: l.onboardCard4Body,
      ),
    ];
    final isLast = _page == cards.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l.skip,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: cards.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnboardCard(data: cards[i]),
              ),
            ),
            const SizedBox(height: 12),
            _Dots(count: cards.length, current: _page),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _next(cards.length),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(isLast ? l.getStarted : l.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardCardData {
  const _OnboardCardData({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color tint;
  final String title;
  final String body;
}

class _OnboardCard extends StatelessWidget {
  const _OnboardCard({required this.data});
  final _OnboardCardData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 156,
            height: 156,
            decoration: BoxDecoration(
              color: data.tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.tint, size: 72),
          ),
          const SizedBox(height: 36),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
