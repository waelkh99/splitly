import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/groups_provider.dart';
import '../../core/providers/people_provider.dart';
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
import '../people_selection/widgets/person_chip.dart';


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
  Map<String, int> _personQuantities = {};

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
    _personQuantities = {};
    setState(() {
      _popupRelX = x ?? 0.5;
      _popupRelY = y ?? 0.35;
      _popupItem = null;
    });
  }

  void _openEdit(BillItem item) {
    _nameCtrl.text = item.name;
    _priceCtrl.text = item.price.toStringAsFixed(2);
    _personQuantities = Map.from(item.personQuantities);
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
        ).copyWith(personQuantities: Map.from(_personQuantities)),
      );
    } else {
      notifier.updateItem(_popupItem!.copyWith(
        name: name,
        price: price,
        personQuantities: Map.from(_personQuantities),
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

  void _openAddPeople(List<Person> currentPeople) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPeopleSheet(
        currentPeople: currentPeople,
        onAddPerson: (person) =>
            ref.read(splitSessionProvider.notifier).addPerson(person),
      ),
    );
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
        onSave: () => Navigator.pop(sheetCtx),
      ),
    ).whenComplete(() {
      if (mounted) _saveAdjustments();
    });
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
                        onItemMoved: (item, rx, ry) => notifier.updateItem(
                          item.copyWith(imageX: rx, imageY: ry),
                        ),
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
                          personQuantities: _personQuantities,
                          isEdit: _popupItem != null,
                          onSave: _saveItem,
                          onDelete:
                              _popupItem != null ? _deletePopupItem : null,
                          onClose: _closePopup,
                          onTogglePerson: (id) => setState(() {
                            if (_personQuantities.containsKey(id)) {
                              _personQuantities.remove(id);
                            } else {
                              _personQuantities[id] = 1;
                            }
                          }),
                          onChangeQuantity: (id, qty) => setState(() {
                            if (qty <= 0) {
                              _personQuantities.remove(id);
                            } else {
                              _personQuantities[id] = qty;
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
                          onAddPeople: () => _openAddPeople(session.people),
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
  // Generous estimate: base fields + up to 6 person rows with steppers
  static const _estimatedHeight = 320.0;

  @override
  Widget build(BuildContext context) {
    final ax = relX * canvasSize.width;
    final ay = relY * canvasSize.height;

    // Horizontal: centre on tap, clamped to screen edges
    final leftMax =
        math.max(_margin, canvasSize.width - _popupWidth - _margin);
    final left = (ax - _popupWidth / 2).clamp(_margin, leftMax);

    // Vertical: prefer above the tap; fall back to below if near the top.
    // Also ensure the popup doesn't go below the keyboard.
    final maxBottom = canvasSize.height - keyboardHeight;
    final spaceAbove = ay - _gap;
    final spaceBelow = maxBottom - ay - _gap - 40; // 40 = approx pin height

    if (spaceAbove >= _estimatedHeight || spaceAbove >= spaceBelow) {
      // Show above — anchor bottom at tap point, clamp so popup top stays in canvas.
      final clampMin = keyboardHeight + _margin;
      final clampMax = math.max(clampMin, canvasSize.height - _estimatedHeight - _margin);
      final bottom = (canvasSize.height - ay + _gap).clamp(clampMin, clampMax);
      // maxH = space from canvas top to popup's bottom anchor, minus top margin.
      final maxH = math.max(80.0, canvasSize.height - bottom - _margin);
      return Positioned(
        left: left,
        bottom: bottom,
        width: _popupWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: child,
        ),
      );
    } else {
      // Show below — top edge is _gap below the tap point.
      final topMax = math.max(_margin, maxBottom - _estimatedHeight);
      final top = (ay + 40 + _gap).clamp(_margin, topMax);
      // maxH = space from popup top down to keyboard top, minus bottom margin.
      final maxH = math.max(80.0, maxBottom - top - _margin);
      return Positioned(
        left: left,
        top: top,
        width: _popupWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: child,
        ),
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
    required this.personQuantities,
    required this.isEdit,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    required this.onTogglePerson,
    required this.onChangeQuantity,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final List<Person> people;
  final Map<String, int> personQuantities;
  final bool isEdit;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;
  final ValueChanged<String> onTogglePerson;
  final void Function(String personId, int qty) onChangeQuantity;

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
        child: SingleChildScrollView(
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

            // Person chips with quantity steppers
            if (people.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...people.asMap().entries.map((e) {
                final person = e.value;
                final qty = personQuantities[person.id];
                final selected = qty != null;
                final color = AppColors.avatarFor(e.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      // Name chip (toggles selection)
                      GestureDetector(
                        onTap: () => onTogglePerson(person.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 130),
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
                      ),
                      // Quantity stepper — only visible when selected
                      if (selected) ...[
                        const Spacer(),
                        _QuantityStepper(
                          quantity: qty,
                          color: color,
                          onDecrement: () =>
                              onChangeQuantity(person.id, qty - 1),
                          onIncrement: () =>
                              onChangeQuantity(person.id, qty + 1),
                        ),
                      ],
                    ],
                  ),
                );
              }),
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
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.color,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final Color color;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          color: color,
          onTap: onDecrement,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          color: color,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
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
    required this.onAddPeople,
  });

  final List<Person> people;
  final dynamic result;
  final String currency;
  final void Function(BillItem item, String personId) onDrop;
  final VoidCallback onAddPeople;

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
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: people.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          if (i == people.length) {
            return GestureDetector(
              onTap: onAddPeople,
              child: Container(
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_rounded,
                        size: 22, color: Colors.grey.shade500),
                    const SizedBox(height: 4),
                    Text('Add',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }
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

// ─── Add people sheet ──────────────────────────────────────────────────────

class _AddPeopleSheet extends ConsumerStatefulWidget {
  const _AddPeopleSheet({
    required this.currentPeople,
    required this.onAddPerson,
  });

  final List<Person> currentPeople;
  final ValueChanged<Person> onAddPerson;

  @override
  ConsumerState<_AddPeopleSheet> createState() => _AddPeopleSheetState();
}

class _AddPeopleSheetState extends ConsumerState<_AddPeopleSheet> {
  final _nameCtrl = TextEditingController();
  final List<Person> _pending = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool _inCurrent(String id) =>
      widget.currentPeople.any((p) => p.id == id);

  bool _isPending(String id) => _pending.any((p) => p.id == id);

  void _stageByName() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _pending.add(Person.create(name)));
    _nameCtrl.clear();
  }

  void _togglePerson(Person person) {
    setState(() {
      if (_isPending(person.id)) {
        _pending.removeWhere((p) => p.id == person.id);
      } else {
        _pending.add(person);
      }
    });
  }

  void _toggleGroup(List<Person> members) {
    final available = members.where((m) => !_inCurrent(m.id)).toList();
    final allSelected = available.every((m) => _isPending(m.id));
    setState(() {
      for (final m in available) {
        if (allSelected) {
          _pending.removeWhere((p) => p.id == m.id);
        } else if (!_isPending(m.id)) {
          _pending.add(m);
        }
      }
    });
  }

  void _confirm() {
    // Commit any name still typed in the field
    final name = _nameCtrl.text.trim();
    final toAdd = List<Person>.from(_pending);
    if (name.isNotEmpty) toAdd.add(Person.create(name));
    for (final p in toAdd) {
      widget.onAddPerson(p);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final recent = ref.watch(recentPeopleProvider);
    final recentIds = recent.map((p) => p.id).toSet();
    // Typed people are pending entries that don't appear in the recent list
    final typedPending =
        _pending.where((p) => !recentIds.contains(p.id)).toList();
    // Only show recent people not already in the split
    final availableRecent =
        recent.where((p) => !_inCurrent(p.id)).take(12).toList();

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = MediaQuery.sizeOf(context).height - keyboardHeight;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight * 0.92),
        child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fixed header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
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
                    'Add people',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  // Name text field — + stages, Done commits
                  TextField(
                    controller: _nameCtrl,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle_rounded),
                        color: AppColors.primary,
                        onPressed: _stageByName,
                      ),
                    ),
                    onSubmitted: (_) => _stageByName(),
                  ),
                  // Staged typed names (lit up, tap to remove)
                  if (typedPending.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: typedPending
                          .map((p) => PersonChip(
                                person: p,
                                selected: true,
                                onTap: () => setState(() =>
                                    _pending.removeWhere((x) => x.id == p.id)),
                                index: widget.currentPeople.length +
                                    typedPending.indexOf(p),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            // ── Scrollable middle (groups + recent) ───────────────────────
            if (groups.isNotEmpty || availableRecent.isNotEmpty)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Groups
                      if (groups.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Groups',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: groups.map((group) {
                            final available = group.members
                                .where((m) => !_inCurrent(m.id))
                                .toList();
                            final allInCurrent =
                                group.members.every((m) => _inCurrent(m.id));
                            final allSelected = available.isNotEmpty &&
                                available.every((m) => _isPending(m.id));
                            return GestureDetector(
                              onTap: allInCurrent
                                  ? null
                                  : () => _toggleGroup(group.members),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: allInCurrent
                                      ? Colors.grey.shade100
                                      : allSelected
                                          ? AppColors.primary
                                              .withValues(alpha: 0.12)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: allInCurrent
                                        ? Colors.grey.shade300
                                        : allSelected
                                            ? AppColors.primary
                                            : const Color(0xFFE0E0E0),
                                    width: allSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: allSelected || allInCurrent
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          )
                                        ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      allInCurrent || allSelected
                                          ? Icons.check_rounded
                                          : Icons.group_rounded,
                                      size: 13,
                                      color: allInCurrent
                                          ? Colors.grey.shade400
                                          : allSelected
                                              ? AppColors.primary
                                              : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      group.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: allSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: allInCurrent
                                            ? Colors.grey.shade400
                                            : allSelected
                                                ? AppColors.primary
                                                : const Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${group.members.length})',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      // Recent people (already-in-split filtered out)
                      if (availableRecent.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          'Recent',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableRecent
                              .asMap()
                              .entries
                              .map((e) => PersonChip(
                                    person: e.value,
                                    selected: _isPending(e.value.id),
                                    onTap: () => _togglePerson(e.value),
                                    index: e.key,
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

            // ── Fixed footer ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _pending.isEmpty ? 'Done' : 'Add ${_pending.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
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
