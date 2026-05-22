import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/bill_item.dart';

class ReceiptCanvas extends StatelessWidget {
  const ReceiptCanvas({
    super.key,
    required this.imagePath,
    required this.items,
    required this.currency,
    required this.onImagePicked,
    required this.onRequestAddItem,
    required this.onItemTapped,
    required this.onItemMoved,
    required this.onDeleteItem,
    this.pendingPin,
  });

  final String? imagePath;
  final List<BillItem> items;
  final String currency;
  final ValueChanged<String?> onImagePicked;
  // null relX/relY = FAB / manual add (no canvas position)
  final void Function(double? relX, double? relY) onRequestAddItem;
  final ValueChanged<BillItem> onItemTapped;
  final void Function(BillItem item, double relX, double relY) onItemMoved;
  final ValueChanged<String> onDeleteItem;
  // Ghost pin shown while the item form is open (0.0–1.0 relative coords)
  final Offset? pendingPin;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return _NoImagePlaceholder(
        onPickImage: () => _pickImage(context),
        onAddManual: () => onRequestAddItem(null, null),
        items: items,
        currency: currency,
        onTapItem: onItemTapped,
        onDeleteItem: onDeleteItem,
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (_, constraints) {
              final sz = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => onRequestAddItem(
                  d.localPosition.dx / sz.width,
                  d.localPosition.dy / sz.height,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.contain,
                        color: Colors.black.withValues(alpha: 0.04),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    ...items.where((i) => i.isPinned).map((item) => _ItemPin(
                          key: ValueKey(item.id),
                          item: item,
                          index: items.indexOf(item),
                          canvasSize: sz,
                          currency: currency,
                          onTap: () => onItemTapped(item),
                          onMove: (rx, ry) => onItemMoved(item, rx, ry),
                        )),
                    if (pendingPin != null)
                      _GhostPin(position: pendingPin!, canvasSize: sz),
                  ],
                ),
              );
            },
          ),
        ),

        Positioned(
          top: 8,
          left: 8,
          child: _PhotoButton(
            onPick: () => _pickImage(context),
            onRemove: () => onImagePicked(null),
          ),
        ),

        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'add_item_fab',
            onPressed: () => onRequestAddItem(null, null),
            tooltip: AppLocalizations.of(context).addItem,
            child: const Icon(Icons.add_rounded),
          ),
        ),

        if (items.any((i) => !i.isPinned))
          Positioned(
            bottom: 0,
            left: 0,
            right: 60,
            child: _UnpinnedStrip(
              items: items.where((i) => !i.isPinned).toList(),
              currency: currency,
              onTap: onItemTapped,
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(AppLocalizations.of(context).camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(AppLocalizations.of(context).photoLibrary),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file =
        await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (file != null) onImagePicked(file.path);
  }
}

// ─── Item pin (pan to reposition, long-press to drag onto a person) ────────

class _ItemPin extends StatefulWidget {
  const _ItemPin({
    super.key,
    required this.item,
    required this.index,
    required this.canvasSize,
    required this.currency,
    required this.onTap,
    required this.onMove,
  });

  final BillItem item;
  final int index;
  final Size canvasSize;
  final String currency;
  final VoidCallback onTap;
  // Called with new center coords in 0.0–1.0 relative space when drag ends.
  final void Function(double relX, double relY) onMove;

  @override
  State<_ItemPin> createState() => _ItemPinState();
}

class _ItemPinState extends State<_ItemPin> {
  static const _pinSize = 36.0;

  // Top-left pixel position during an active pan; null when not dragging.
  Offset? _dragTopLeft;

  double get _maxLeft => widget.canvasSize.width - _pinSize;
  double get _maxTop => widget.canvasSize.height - _pinSize;

  @override
  Widget build(BuildContext context) {
    final baseX = widget.item.imageX! * widget.canvasSize.width - _pinSize / 2;
    final baseY = widget.item.imageY! * widget.canvasSize.height - _pinSize / 2;
    final left = (_dragTopLeft?.dx ?? baseX).clamp(0.0, _maxLeft);
    final top = (_dragTopLeft?.dy ?? baseY).clamp(0.0, _maxTop);
    final dragging = _dragTopLeft != null;

    final color =
        widget.item.isAssigned ? AppColors.primary : Colors.grey.shade600;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onPanStart: (_) => setState(() => _dragTopLeft = Offset(left, top)),
        onPanUpdate: (d) {
          if (_dragTopLeft == null) return;
          setState(() {
            _dragTopLeft = Offset(
              (_dragTopLeft!.dx + d.delta.dx).clamp(0.0, _maxLeft),
              (_dragTopLeft!.dy + d.delta.dy).clamp(0.0, _maxTop),
            );
          });
        },
        onPanEnd: (_) {
          final lt = _dragTopLeft;
          if (lt == null) return;
          final relX = (lt.dx + _pinSize / 2) / widget.canvasSize.width;
          final relY = (lt.dy + _pinSize / 2) / widget.canvasSize.height;
          widget.onMove(relX, relY);
          setState(() => _dragTopLeft = null);
        },
        onPanCancel: () => setState(() => _dragTopLeft = null),
        child: AnimatedScale(
          scale: dragging ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: LongPressDraggable<BillItem>(
            data: widget.item,
            hapticFeedbackOnStart: true,
            feedback:
                _DragCard(item: widget.item, index: widget.index, color: color),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: _PinBubble(number: widget.index + 1, color: color),
            ),
            child: _PinBubble(
              number: widget.index + 1,
              color: color,
              label:
                  '${widget.item.price.toStringAsFixed(2)} ${widget.currency}',
            ),
          ),
        ),
      ),
    );
  }
}

// Ghost pin while the item form is open
class _GhostPin extends StatelessWidget {
  const _GhostPin({required this.position, required this.canvasSize});
  final Offset position;
  final Size canvasSize;

  static const _size = 36.0;

  @override
  Widget build(BuildContext context) {
    final x = position.dx * canvasSize.width - _size / 2;
    final y = position.dy * canvasSize.height - _size / 2;
    return Positioned(
      left: x.clamp(0, canvasSize.width - _size),
      top: y.clamp(0, canvasSize.height - _size),
      child: Opacity(
        opacity: 0.55,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _PinBubble extends StatelessWidget {
  const _PinBubble({required this.number, required this.color, this.label});
  final int number;
  final Color color;
  final String? label;

  static const _size = 36.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DragCard extends StatelessWidget {
  const _DragCard(
      {required this.item, required this.index, required this.color});
  final BillItem item;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(item.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Text(item.price.toStringAsFixed(2),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── No-image placeholder ──────────────────────────────────────────────────

class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder({
    required this.onPickImage,
    required this.onAddManual,
    required this.items,
    required this.currency,
    required this.onTapItem,
    required this.onDeleteItem,
  });
  final VoidCallback onPickImage;
  final VoidCallback onAddManual;
  final List<BillItem> items;
  final String currency;
  final ValueChanged<BillItem> onTapItem;
  final ValueChanged<String> onDeleteItem;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(Icons.add_photo_alternate_rounded,
                    color: AppColors.primary.withValues(alpha: 0.6), size: 36),
                const SizedBox(height: 8),
                Text(
                  l.addReceiptPhoto,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  l.tapReceiptToAssign,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              ...items.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ManualItemTile(
                      item: e.value,
                      index: e.key,
                      currency: currency,
                      onTap: () => onTapItem(e.value),
                      onDelete: () => onDeleteItem(e.value.id),
                    ),
                  )),
              GestureDetector(
                onTap: onAddManual,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(l.addItem,
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManualItemTile extends StatelessWidget {
  const _ManualItemTile({
    required this.item,
    required this.index,
    required this.currency,
    required this.onTap,
    required this.onDelete,
  });
  final BillItem item;
  final int index;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = item.isAssigned ? AppColors.primary : Colors.grey.shade500;
    return LongPressDraggable<BillItem>(
      data: item,
      hapticFeedbackOnStart: true,
      feedback: _DragCard(item: item, index: index, color: color),
      childWhenDragging: Opacity(opacity: 0.35, child: _tileBody(color)),
      child: GestureDetector(onTap: onTap, child: _tileBody(color)),
    );
  }

  Widget _tileBody(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isAssigned
              ? AppColors.primary.withValues(alpha: 0.35)
              : const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Text(
            '${item.price.toStringAsFixed(2)} $currency',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, color: color),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded,
                size: 16, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─── Unpinned items strip ──────────────────────────────────────────────────

class _UnpinnedStrip extends StatelessWidget {
  const _UnpinnedStrip(
      {required this.items, required this.currency, required this.onTap});
  final List<BillItem> items;
  final String currency;
  final ValueChanged<BillItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.asMap().entries.map((e) {
            final item = e.value;
            final index = e.key;
            final color =
                item.isAssigned ? AppColors.secondary : Colors.grey.shade400;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: LongPressDraggable<BillItem>(
                data: item,
                hapticFeedbackOnStart: true,
                feedback: _DragCard(item: item, index: index, color: color),
                childWhenDragging: Opacity(
                    opacity: 0.35, child: _chip(item, color)),
                child: GestureDetector(
                    onTap: () => onTap(item), child: _chip(item, color)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _chip(BillItem item, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          '${item.name}  ${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      );
}

// ─── Photo button ──────────────────────────────────────────────────────────

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.onPick, required this.onRemove});
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pill(
            icon: Icons.photo_camera_rounded,
            label: AppLocalizations.of(context).changePhoto,
            onTap: onPick),
        const SizedBox(width: 6),
        _pill(
            icon: Icons.close_rounded,
            label: AppLocalizations.of(context).removePhoto,
            onTap: onRemove,
            danger: true),
      ],
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: danger
                ? Colors.red.withValues(alpha: 0.8)
                : Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 13),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
}
