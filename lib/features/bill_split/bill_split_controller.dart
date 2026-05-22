import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/session_provider.dart';
import '../../data/models/bill_item.dart';
import '../../data/models/person.dart';

class BillSplitController {
  const BillSplitController(this.ref);
  final WidgetRef ref;

  SessionNotifier get _notifier => ref.read(splitSessionProvider.notifier);

  void addItem(BillItem item) => _notifier.addItem(item);

  void updateItem(BillItem item) => _notifier.updateItem(item);

  void deleteItem(String itemId) => _notifier.removeItem(itemId);

  void setReceiptImage(String? path) => _notifier.setReceiptImage(path);

  /// Assigns or unassigns a person from an item.
  /// When dropped via drag: toggles the person in (adds if not present).
  void dropItemOnPerson(String personId, BillItem item) {
    final quantities = Map<String, int>.from(item.personQuantities);
    if (quantities.containsKey(personId)) {
      quantities.remove(personId);
    } else {
      quantities[personId] = 1;
    }
    _notifier.assignItem(item.id, quantities);
  }

  void applyAssignment(String itemId, Map<String, int> personQuantities) {
    _notifier.assignItem(itemId, personQuantities);
  }
}

/// Shows an assignment bottom sheet for an item. Returns selected person IDs.
Future<List<String>?> showAssignmentSheet(
  BuildContext context,
  BillItem item,
  List<Person> people,
) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AssignmentSheet(item: item, people: people),
  );
}

class _AssignmentSheet extends StatefulWidget {
  const _AssignmentSheet({required this.item, required this.people});
  final BillItem item;
  final List<Person> people;

  @override
  State<_AssignmentSheet> createState() => _AssignmentSheetState();
}

class _AssignmentSheetState extends State<_AssignmentSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.item.assignedPersonIds);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 20),
          Text(
            '${widget.item.name}  ·  ${widget.item.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l.selectWhoOrderedThisItem,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...widget.people.map((p) => CheckboxListTile(
                value: _selected.contains(p.id),
                title: Text(p.name),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selected.add(p.id);
                  } else {
                    _selected.remove(p.id);
                  }
                }),
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _selected.toList()),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }
}
