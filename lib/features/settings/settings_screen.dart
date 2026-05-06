import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/settings_provider.dart';

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _CurrencyField(
                initial: settings.currency,
                onChanged: notifier.setCurrency,
                hint: l.currencyHint,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(l.about),
          _Card(
            child: ListTile(
              title: Text(l.appName),
              subtitle: Text('${l.version} 1.0.0'),
              leading: const Icon(Icons.info_outline_rounded),
            ),
          ),
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
        child: child,
      );
}

class _CurrencyField extends StatefulWidget {
  const _CurrencyField({
    required this.initial,
    required this.onChanged,
    required this.hint,
  });
  final String initial;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  State<_CurrencyField> createState() => _CurrencyFieldState();
}

class _CurrencyFieldState extends State<_CurrencyField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).currency,
          hintText: widget.hint,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onSubmitted: widget.onChanged,
        onEditingComplete: () => widget.onChanged(_ctrl.text.trim()),
        textInputAction: TextInputAction.done,
      );
}
