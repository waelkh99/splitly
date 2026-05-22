import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/history_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/step_indicator.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/history_entry.dart';
import '../../data/models/split_result.dart';
import '../../data/models/split_session.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _saved = false;
  final _shareCardKey = GlobalKey();
  final _payToCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _payToCtrl.text = ref.read(splitSessionProvider).payTo ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveToHistory());
  }

  @override
  void dispose() {
    _payToCtrl.dispose();
    super.dispose();
  }

  void _saveToHistory() {
    if (_saved) return;
    _saved = true;
    final session = ref.read(splitSessionProvider);
    final result = ref.read(splitResultProvider);
    if (session.people.isEmpty || session.items.isEmpty) return;
    final entry = HistoryEntry.create(session: session, result: result);
    ref.read(historyProvider.notifier).add(entry);
  }

  Future<void> _share(Rect? origin) async {
    final l = AppLocalizations.of(context);
    final boundary = _shareCardKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary != null) {
      try {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final bytes = byteData.buffer.asUint8List();
          final file = File(
              '${Directory.systemTemp.path}/splitly_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(bytes);
          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'image/png')],
            sharePositionOrigin: origin,
          );
          return;
        }
      } catch (_) {
        // fall through to text fallback
      }
    }

    // Fallback: plain text
    final session = ref.read(splitSessionProvider);
    final result = ref.read(splitResultProvider);
    final currency = ref.read(settingsProvider).currency;
    final lines = session.people
        .map((p) => '${p.name}: ${formatAmount(result.amountFor(p), currency)}')
        .join('\n');
    final body = l.splitSummary(formatAmount(result.total, currency), lines);
    final payTo = session.payTo;
    await Share.share(
      payTo != null && payTo.isNotEmpty
          ? '$body\n${l.payTo}: $payTo'
          : body,
      sharePositionOrigin: origin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(splitSessionProvider);
    final result = ref.watch(splitResultProvider);
    final currency = ref.watch(settingsProvider).currency;

    return Scaffold(
      appBar: AppBar(title: Text(l.billSummary)),
      body: Column(
        children: [
          StepIndicator(current: 3),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _PayToField(
                  controller: _payToCtrl,
                  label: l.payTo,
                  hint: l.payToHint,
                  onChanged: (v) =>
                      ref.read(splitSessionProvider.notifier).setPayTo(v),
                ),
                const SizedBox(height: 12),
                RepaintBoundary(
                  key: _shareCardKey,
                  child: _ShareCard(
                    session: session,
                    result: result,
                    currency: currency,
                    date: DateTime.now(),
                  ),
                ),
              ],
            ),
          ),
          _BottomActions(
            onShare: (origin) => _share(origin),
            onNewSplit: () {
              ref.read(splitSessionProvider.notifier).reset();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (_) => false);
            },
            l: l,
          ),
        ],
      ),
    );
  }
}

// ─── Share card ────────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.session,
    required this.result,
    required this.currency,
    required this.date,
  });

  final SplitSession session;
  final SplitResult result;
  final String currency;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final people = session.people;
    final items = session.items;
    final adj = session.adjustment;
    final hasItems = items.isNotEmpty;
    final hasAdj = adj.hasAny && adj.totalOverride == null && hasItems;
    final itemsSubtotal = items.fold<double>(0, (s, i) => s + i.price);
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline_rounded,
                            color: Colors.white60, size: 11),
                        const SizedBox(width: 3),
                        Text(
                          '${people.length}',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Items list (flows naturally after header)
          if (hasItems) ...[
            const SizedBox(height: 14),
            ...items.map((item) {
              final assignedPeople = people
                  .where((p) => item.assignedPersonIds.contains(p.id))
                  .toList();
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 10, top: 1),
                      decoration: BoxDecoration(
                        color: item.isAssigned
                            ? AppColors.primary.withValues(alpha: 0.45)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                    if (assignedPeople.isNotEmpty) ...[
                      ...assignedPeople.take(3).map((p) {
                        final idx = people.indexOf(p);
                        final color = AppColors.avatarFor(idx);
                        return Container(
                          width: 17,
                          height: 17,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: color.withValues(alpha: 0.35),
                                width: 0.8),
                          ),
                          child: Center(
                            child: Text(
                              p.name.isNotEmpty
                                  ? p.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                        );
                      }),
                      if (assignedPeople.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Text(
                            '+${assignedPeople.length - 3}',
                            style: TextStyle(
                                fontSize: 9, color: Colors.grey.shade400),
                          ),
                        ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      formatAmount(item.price, currency),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // ── Adjustments breakdown
          if (hasAdj) ...[
            const _DashedDivider(),
            _SubRow(
                label: l.subtotal,
                amount: itemsSubtotal,
                currency: currency),
            if (adj.tax > 0)
              _SubRow(label: l.tax, amount: adj.tax, currency: currency),
            if (adj.deliveryFee > 0)
              _SubRow(
                  label: l.deliveryFee,
                  amount: adj.deliveryFee,
                  currency: currency),
            if (adj.discount > 0)
              _SubRow(
                  label: l.discount,
                  amount: -adj.discount,
                  currency: currency,
                  isDiscount: true),
          ],

          // ── Grand total
          const _DashedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l.total,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                const Spacer(),
                Text(
                  formatAmount(result.total, currency),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),

          // ── Per-person breakdown
          const _DashedDivider(),
          const SizedBox(height: 4),
          ...people.asMap().entries.map((e) {
            final person = e.value;
            final amount = result.amountFor(person);
            final color = AppColors.avatarFor(e.key);
            return Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: color, width: 3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: color.withValues(alpha: 0.18),
                    child: Text(
                      person.name.isNotEmpty
                          ? person.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      person.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  Text(
                    formatAmount(amount, currency),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Pay-to badge (when set)
          if (session.payTo != null && session.payTo!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${l.payTo}:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        session.payTo!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Footer
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            color: const Color(0xFFF8F9FA),
            child: Center(
              child: Text(
                l.splitWithApp(l.appName),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CustomPaint(
          painter: _DashPainter(),
          child: const SizedBox(height: 1),
        ),
      );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    const dash = 5.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter _) => false;
}

class _SubRow extends StatelessWidget {
  const _SubRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.isDiscount = false,
  });
  final String label;
  final double amount;
  final String currency;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDiscount
                    ? Colors.green.shade600
                    : Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              isDiscount
                  ? '- ${formatAmount(amount.abs(), currency)}'
                  : formatAmount(amount, currency),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDiscount
                    ? Colors.green.shade600
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
}

// ─── Bottom actions ────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onShare,
    required this.onNewSplit,
    required this.l,
  });
  final void Function(Rect? origin) onShare;
  final VoidCallback onNewSplit;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final box = context.findRenderObject() as RenderBox?;
                final origin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                onShare(origin);
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(l.shareViaWhatsApp),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onNewSplit,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(l.startNewSplit),
              ),
            ),
          ],
        ),
      );
}

// ─── Pay-to field ──────────────────────────────────────────────────────────

class _PayToField extends StatelessWidget {
  const _PayToField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        LengthLimitingTextInputFormatter(40),
      ],
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
