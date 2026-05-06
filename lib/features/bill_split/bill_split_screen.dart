import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/session_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/step_indicator.dart';
import '../../data/models/adjustment.dart';
import '../../data/models/bill_item.dart';
import '../../data/models/person.dart';
import 'widgets/receipt_canvas.dart';


class BillSplitScreen extends ConsumerStatefulWidget {
  const BillSplitScreen({super.key});

  @override
  ConsumerState<BillSplitScreen> createState() => _BillSplitScreenState();
}

class _BillSplitScreenState extends ConsumerState<BillSplitScreen> {
  // Popup state (null = no popup open)
  double? _popupRelX, _popupRelY;
  BillItem? _popupItem; // null = adding new

  // Item form
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  Set<String> _selectedPersonIds = {};

  // Adjustments form
  final _taxCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _overrideCtrl = TextEditingController();

  bool get _popupOpen => _popupRelX != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _taxCtrl.dispose();
    _deliveryCtrl.dispose();
    _discountCtrl.dispose();
    _overrideCtrl.dispose();
    super.dispose();
  }

  void _openAdd(double? x, double? y) {
    _nameCtrl.clear();
    _priceCtrl.clear();
    _selectedPersonIds = {};
    setState(() {
      _popupRelX = x ?? 0.5;
      _popupRelY = y ?? 0.35;
      _popupItem = null;
    });
  }

  void _openEdit(BillItem item) {
    _nameCtrl.text = item.name;
    _priceCtrl.text = item.price.toStringAsFixed(2);
    _selectedPersonIds = Set.from(item.assignedPersonIds);
    setState(() {
      _popupRelX = item.imageX ?? 0.5;
      _popupRelY = item.imageY ?? 0.35;
      _popupItem = item;
    });
  }

  void _closePopup() {
    FocusScope.of(context).unfocus();
    setState(() {
      _popupRelX = null;
      _popupRelY = null;
      _popupItem = null;
    });
  }

  void _saveItem() {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (name.isEmpty || price <= 0) return;
    final notifier = ref.read(splitSessionProvider.notifier);
    if (_popupItem == null) {
      notifier.addItem(
        BillItem.create(
          name: name,
          price: price,
          imageX: _popupRelX == 0.5 ? null : _popupRelX,
          imageY: _popupRelY == 0.35 ? null : _popupRelY,
        ).copyWith(assignedPersonIds: _selectedPersonIds.toList()),
      );
    } else {
      notifier.updateItem(_popupItem!.copyWith(
        name: name,
        price: price,
        assignedPersonIds: _selectedPersonIds.toList(),
      ));
    }
    _closePopup();
  }

  void _deletePopupItem() {
    if (_popupItem != null) {
      ref.read(splitSessionProvider.notifier).removeItem(_popupItem!.id);
    }
    _closePopup();
  }

  void _openAdjustments() {
    final adj = ref.read(splitSessionProvider).adjustment;
    _taxCtrl.text = adj.tax > 0 ? adj.tax.toStringAsFixed(2) : '';
    _deliveryCtrl.text =
        adj.deliveryFee > 0 ? adj.deliveryFee.toStringAsFixed(2) : '';
    _discountCtrl.text =
        adj.discount > 0 ? adj.discount.toStringAsFixed(2) : '';
    _overrideCtrl.text = adj.totalOverride != null
        ? adj.totalOverride!.toStringAsFixed(2)
        : '';
    _closePopup();
    final currency = ref.read(settingsProvider).currency;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _AdjustmentsSheet(
        taxCtrl: _taxCtrl,
        deliveryCtrl: _deliveryCtrl,
        discountCtrl: _discountCtrl,
        overrideCtrl: _overrideCtrl,
        currency: currency,
        onSave: () {
          _saveAdjustments();
          Navigator.pop(sheetCtx);
        },
      ),
    );
  }

  void _saveAdjustments() {
    double parse(TextEditingController c) =>
        double.tryParse(c.text.trim()) ?? 0;
    final override = _overrideCtrl.text.trim();
    ref.read(splitSessionProvider.notifier).setAdjustment(Adjustment(
      tax: parse(_taxCtrl),
      deliveryFee: parse(_deliveryCtrl),
      discount: parse(_discountCtrl),
      totalOverride: override.isNotEmpty ? double.tryParse(override) : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(splitSessionProvider);
    final result = ref.watch(splitResultProvider);
    final currency = ref.watch(settingsProvider).currency;
    final notifier = ref.read(splitSessionProvider.notifier);
    final unassigned = session.unassignedCount;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l.stepSplit),
        actions: [
          if (unassigned > 0)
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  l.unassignedItems(unassigned),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: _openAdjustments,
            child: Text(l.adjustments),
          ),
        ],
      ),
      body: Column(
        children: [
          StepIndicator(current: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = Size(
                    constraints.maxWidth, constraints.maxHeight);
                final kb = MediaQuery.of(context).viewInsets.bottom;

                return Stack(
                  children: [
                    // Canvas — always full size, never compressed
                    Positioned.fill(
                      child: ReceiptCanvas(
                        imagePath: session.receiptImagePath,
                        items: session.items,
                        currency: currency,
                        onImagePicked: notifier.setReceiptImage,
                        onRequestAddItem: _openAdd,
                        onItemTapped: _openEdit,
                        onDeleteItem: (id) {
                          notifier.removeItem(id);
                          if (_popupItem?.id == id) _closePopup();
                        },
                        pendingPin: _popupOpen &&
                                _popupItem == null &&
                                _popupRelX != 0.5
                            ? Offset(_popupRelX!, _popupRelY!)
                            : null,
                      ),
                    ),

                    // Floating item popup — appears at tap location
                    if (_popupOpen)
                      _ItemPopupPositioner(
                        relX: _popupRelX!,
                        relY: _popupRelY!,
                        canvasSize: canvasSize,
                        keyboardHeight: kb,
                        child: _ItemFormPopup(
                          nameCtrl: _nameCtrl,
                          priceCtrl: _priceCtrl,
                          people: session.people,
                          selectedPersonIds: _selectedPersonIds,
                          isEdit: _popupItem != null,
                          onSave: _saveItem,
                          onDelete:
                              _popupItem != null ? _deletePopupItem : null,
                          onClose: _closePopup,
                          onTogglePerson: (id) => setState(() {
                            if (!_selectedPersonIds.remove(id)) {
                              _selectedPersonIds.add(id);
                            }
                          }),
                        ),
                      ),

                    // Bottom strip — hidden while item popup is open
                    if (!_popupOpen)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: kb,
                        child: _PeopleDropStrip(
                          people: session.people,
                          result: result,
                          currency: currency,
                          onDrop: (item, personId) => notifier
                              .togglePersonOnItem(item.id, personId),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        hasItems: session.items.isNotEmpty,
        onNext: session.items.isNotEmpty
            ? () => Navigator.pushNamed(context, AppRoutes.summary)
            : null,
        l: l,
      ),
    );
  }
}

// ─── Popup positioner ──────────────────────────────────────────────────────

class _ItemPopupPositioner extends StatelessWidget {
  const _ItemPopupPositioner({
    required this.relX,
    required this.relY,
    required this.canvasSize,
    required this.keyboardHeight,
    required this.child,
  });

  final double relX, relY;
  final Size canvasSize;
  final double keyboardHeight;
  final Widget child;

  static const _popupWidth = 272.0;
  static const _margin = 10.0;
  static const _gap = 12.0;
  static const _estimatedHeight = 190.0;

  @override
  Widget build(BuildContext context) {
    final ax = relX * canvasSize.width;
    final ay = relY * canvasSize.height;

    // Horizontal: centre on tap, clamped to screen edges
    final left = (ax - _popupWidth / 2)
        .clamp(_margin, canvasSize.width - _popupWidth - _margin);

    // Vertical: prefer above the tap; fall back to below if near the top.
    // Also ensure the popup doesn't go below the keyboard.
    final maxBottom = canvasSize.height - keyboardHeight;
    final spaceAbove = ay - _gap;
    final spaceBelow = maxBottom - ay - _gap - 40; // 40 = approx pin height

    if (spaceAbove >= _estimatedHeight || spaceAbove >= spaceBelow) {
      // Show above — bottom edge is _gap above the tap point
      return Positioned(
        left: left,
        bottom: (canvasSize.height - ay + _gap)
            .clamp(keyboardHeight + _margin, canvasSize.height - _margin),
        width: _popupWidth,
        child: child,
      );
    } else {
      // Show below — top edge is _gap below the tap point
      final top =
          (ay + 40 + _gap).clamp(_margin, maxBottom - _estimatedHeight);
      return Positioned(
        left: left,
        top: top,
        width: _popupWidth,
        child: child,
      );
    }
  }
}

// ─── Floating item form popup ──────────────────────────────────────────────

class _ItemFormPopup extends StatelessWidget {
  const _ItemFormPopup({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.people,
    required this.selectedPersonIds,
    required this.isEdit,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    required this.onTogglePerson,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final List<Person> people;
  final Set<String> selectedPersonIds;
  final bool isEdit;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;
  final ValueChanged<String> onTogglePerson;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  isEdit ? l.editItem : l.newItem,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.error),
                    ),
                  ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close_rounded,
                      size: 18, color: Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Name + price fields
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l.itemName,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l.price,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                    ),
                    onSubmitted: (_) => onSave(),
                  ),
                ),
              ],
            ),

            // Person chips
            if (people.isNotEmpty) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: people.asMap().entries.map((e) {
                    final person = e.value;
                    final selected = selectedPersonIds.contains(person.id);
                    final color = AppColors.avatarFor(e.key);
                    return GestureDetector(
                      onTap: () => onTogglePerson(person.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 130),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.12)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? color : Colors.grey.shade300,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected) ...[
                              Icon(Icons.check_rounded,
                                  size: 11, color: color),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              person.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? color
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 38),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                isEdit ? l.save : l.addItem,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── People drop strip ─────────────────────────────────────────────────────

class _PeopleDropStrip extends StatelessWidget {
  const _PeopleDropStrip({
    required this.people,
    required this.result,
    required this.currency,
    required this.onDrop,
  });

  final List<Person> people;
  final dynamic result;
  final String currency;
  final void Function(BillItem item, String personId) onDrop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: people.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context).yourPeopleWillAppearHere,
                style:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              itemCount: people.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final person = people[i];
                return _PersonDropTarget(
                  person: person,
                  amount: result.amountFor(person),
                  currency: currency,
                  color: AppColors.avatarFor(i),
                  onDrop: (item) => onDrop(item, person.id),
                );
              },
            ),
    );
  }
}

class _PersonDropTarget extends StatelessWidget {
  const _PersonDropTarget({
    required this.person,
    required this.amount,
    required this.currency,
    required this.color,
    required this.onDrop,
  });
  final Person person;
  final double amount;
  final String currency;
  final Color color;
  final ValueChanged<BillItem> onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<BillItem>(
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (_, candidateData, _) {
        final hovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: hovering
                ? color.withValues(alpha: 0.22)
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hovering ? color : color.withValues(alpha: 0.25),
              width: hovering ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      person.name.isNotEmpty
                          ? person.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: color),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(person.name,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ],
              ),
              const SizedBox(height: 4),
              hovering
                  ? Icon(Icons.add_circle_outline_rounded,
                      color: color, size: 18)
                  : Text(
                      formatAmount(amount, currency),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color),
                    ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Adjustments sheet (modal bottom sheet) ───────────────────────────────

class _AdjustmentsSheet extends StatelessWidget {
  const _AdjustmentsSheet({
    required this.taxCtrl,
    required this.deliveryCtrl,
    required this.discountCtrl,
    required this.overrideCtrl,
    required this.currency,
    required this.onSave,
  });

  final TextEditingController taxCtrl;
  final TextEditingController deliveryCtrl;
  final TextEditingController discountCtrl;
  final TextEditingController overrideCtrl;
  final String currency;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.adjustments,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _AdjField(
                        ctrl: taxCtrl, label: '${l.tax} ($currency)')),
                const SizedBox(width: 12),
                Expanded(
                    child: _AdjField(
                        ctrl: deliveryCtrl,
                        label: '${l.deliveryFee} ($currency)')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _AdjField(
                        ctrl: discountCtrl,
                        label: '${l.discount} ($currency)')),
                const SizedBox(width: 12),
                Expanded(
                    child: _AdjField(
                        ctrl: overrideCtrl,
                        label: l.totalOverride,
                        hint: l.totalOverrideHint)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l.done,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjField extends StatelessWidget {
  const _AdjField({required this.ctrl, required this.label, this.hint});
  final TextEditingController ctrl;
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? '0.00',
          isDense: true,
        ),
      );
}

// ─── Bottom bar ────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar(
      {required this.hasItems, required this.onNext, required this.l});
  final bool hasItems;
  final VoidCallback? onNext;
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
        child: ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                hasItems ? AppColors.primary : Colors.grey.shade300,
            foregroundColor: hasItems ? Colors.white : Colors.grey,
          ),
          child: Text(l.next),
        ),
      );
}
