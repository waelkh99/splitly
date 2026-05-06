import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/person.dart';

class AddPersonBottomSheet extends StatefulWidget {
  const AddPersonBottomSheet({super.key, required this.onAdd});
  final void Function(List<Person>) onAdd;

  @override
  State<AddPersonBottomSheet> createState() => _AddPersonBottomSheetState();
}

class _AddPersonBottomSheetState extends State<AddPersonBottomSheet> {
  final _ctrl = TextEditingController();
  bool _pasteMode = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    List<Person> people;
    if (_pasteMode) {
      people = text
          .split(',')
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .map(Person.create)
          .toList();
    } else {
      people = [Person.create(text)];
    }

    widget.onAdd(people);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pasteMode ? l.pasteNames : l.addPerson,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _pasteMode = !_pasteMode),
                  child: Text(
                    _pasteMode ? l.addPerson : l.pasteNames,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: _pasteMode
                    ? l.pasteNamesHint
                    : l.personNameHint,
                labelText:
                    _pasteMode ? l.pasteNames : l.personName,
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(l.done),
            ),
          ],
        ),
      ),
    );
  }
}
