import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(l.language),
          _Card(
            child: RadioGroup<String>(
              groupValue: settings.locale.languageCode,
              onChanged: (v) => notifier.setLocale(
                v == 'ar' ? const Locale('ar') : const Locale('en'),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l.english),
                    value: 'en',
                  ),
                  const Divider(height: 0),
                  RadioListTile<String>(
                    title: Text(l.arabic),
                    value: 'ar',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(l.currency),
          _Card(
            child: RadioGroup<String>(
              groupValue: settings.currency,
              onChanged: (v) {
                if (v != null) notifier.setCurrency(v);
              },
              child: Column(
                children: [
                  for (var i = 0; i < supportedCurrencies.length; i++) ...[
                    if (i > 0) const Divider(height: 0),
                    _CurrencyRow(info: supportedCurrencies[i]),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(l.help),
          _Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb_outline_rounded),
              title: Text(l.howItWorks),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: Colors.grey),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.onboarding),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(l.about),
          _Card(
            child: ListTile(
              title: Text(l.appName),
              subtitle: const _VersionText(),
              leading: const Icon(Icons.info_outline_rounded),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/Tag black.png',
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // ListTile + ink splashes need a Material ancestor; without it Flutter
        // warns that splashes/background colour may be invisible.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      );
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({required this.info});
  final CurrencyInfo info;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: info.code,
      title: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              info.symbol,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  info.code,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionText extends StatefulWidget {
  const _VersionText();

  @override
  State<_VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<_VersionText> {
  String? _version;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (!mounted) return;
      // Display major.minor.buildNumber (e.g. 1.1.0+3 → 1.1.3).
      final parts = info.version.split('.');
      final major = parts.isNotEmpty ? parts[0] : '0';
      final minor = parts.length > 1 ? parts[1] : '0';
      setState(() => _version = '$major.$minor.${info.buildNumber}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Text('${l.version} ${_version ?? '…'}');
  }
}
