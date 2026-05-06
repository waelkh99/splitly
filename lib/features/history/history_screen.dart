import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/history_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/providers/settings_provider.dart';
import '../../data/models/history_entry.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final entries = ref.watch(historyProvider);
    final currency = ref.watch(settingsProvider).currency;

    return Scaffold(
      appBar: AppBar(title: Text(l.history)),
      body: entries.isEmpty
          ? _EmptyState(l: l)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) =>
                  _HistoryTile(entry: entries[i], currency: currency),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(l.noHistory,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l.noHistoryDesc,
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.entry, required this.currency});
  final HistoryEntry entry;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final date = entry.date;
    final dateStr =
        '${date.day}/${date.month}/${date.year}';

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirm(context, l),
      onDismissed: (_) =>
          ref.read(historyProvider.notifier).delete(entry.id),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.historyDetail,
          arguments: entry,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.splitOn(dateStr),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.peopleCount(entry.session.people.length),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Text(
                formatAmount(entry.result.total, currency),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirm(BuildContext context, AppLocalizations l) =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l.deleteConfirm),
          content: Text(l.deleteHistoryConfirm),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.no)),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.yes)),
          ],
        ),
      );
}
