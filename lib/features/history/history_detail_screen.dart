import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/share_formatter.dart';
import '../../data/models/history_entry.dart';

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(settingsProvider).currency;
    final session = entry.session;
    final result = entry.result;
    final date = entry.date;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return Scaffold(
      appBar: AppBar(title: Text(l.splitOn(dateStr))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total card
                _TotalCard(total: result.total, currency: currency),
                const SizedBox(height: 16),
                // Per-person list
                ...session.people.map((person) {
                  final amount = result.amountFor(person);
                  final index = session.people.indexOf(person);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PersonTile(
                      name: person.name,
                      amount: amount,
                      currency: currency,
                      color: AppColors.avatarFor(index),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Builder(
              builder: (btnCtx) => ElevatedButton.icon(
                onPressed: () {
                  final box = btnCtx.findRenderObject() as RenderBox?;
                  final origin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  final text = buildShareText(
                    people: session.people,
                    result: result,
                    currency: currency,
                  );
                  Share.share(text, sharePositionOrigin: origin);
                },
                icon: const Icon(Icons.share_rounded),
                label: Text(l.shareViaWhatsApp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.currency});
  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).total,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              formatAmount(total, currency),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.name,
    required this.amount,
    required this.currency,
    required this.color,
  });
  final String name;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            Text(
              formatAmount(amount, currency),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
}
