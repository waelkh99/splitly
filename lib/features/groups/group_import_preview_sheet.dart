import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/groups_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/group_share_codec.dart';
import '../../data/models/group.dart';
import '../../data/models/person.dart';

/// Bottom sheet shown after a successful QR scan.
/// Lets the user rename before importing and resolves name collisions.
class GroupImportPreviewSheet extends ConsumerStatefulWidget {
  const GroupImportPreviewSheet({super.key, required this.payload});

  final GroupPayload payload;

  @override
  ConsumerState<GroupImportPreviewSheet> createState() =>
      _GroupImportPreviewSheetState();
}

class _GroupImportPreviewSheetState
    extends ConsumerState<GroupImportPreviewSheet> {
  late final TextEditingController _nameCtrl;
  final _nameFocus = FocusNode();
  late final List<Person> _members;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.payload.name);
    // Always create new Person records on import (no dedup by name).
    _members =
        widget.payload.memberNames.map((n) => Person.create(n)).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Group? _existingWithName(String name) {
    final lower = name.toLowerCase();
    final groups = ref.read(groupsProvider);
    for (final g in groups) {
      if (g.name.toLowerCase() == lower) return g;
    }
    return null;
  }

  Future<void> _import() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _members.isEmpty) return;

    final l = AppLocalizations.of(context);
    final notifier = ref.read(groupsProvider.notifier);
    final existing = _existingWithName(name);

    if (existing != null) {
      final choice = await showDialog<_ConflictChoice>(
        context: context,
        builder: (_) => _ConflictDialog(l: l, name: name),
      );
      if (!mounted || choice == null || choice == _ConflictChoice.cancel) return;
      if (choice == _ConflictChoice.rename) {
        _nameFocus.requestFocus();
        return;
      }
      // Replace: overwrite the existing group, preserving its id.
      await notifier.save(existing.copyWith(
        name: name,
        members: List.from(_members),
      ));
    } else {
      await notifier.save(Group.create(
        name: name,
        members: List.from(_members),
      ));
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.groupImported),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.importGroup,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameCtrl,
              focusNode: _nameFocus,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l.groupName,
                hintText: l.groupNameHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.membersCount(_members.length),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _members.asMap().entries.map((e) {
                final color = AppColors.avatarFor(e.key);
                final person = e.value;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: color.withValues(alpha: 0.25),
                        child: Text(
                          person.name.isNotEmpty
                              ? person.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        person.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _import,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l.importGroup),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _ConflictChoice { replace, rename, cancel }

class _ConflictDialog extends StatelessWidget {
  const _ConflictDialog({required this.l, required this.name});
  final AppLocalizations l;
  final String name;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l.nameAlreadyExists(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _ConflictChoice.cancel),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ConflictChoice.rename),
          child: Text(l.rename),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ConflictChoice.replace),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l.replace),
        ),
      ],
    );
  }
}
