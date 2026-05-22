import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/groups_provider.dart';
import '../../core/providers/people_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/group_share_codec.dart';
import '../../data/models/group.dart';
import '../../data/models/person.dart';
import 'group_import_preview_sheet.dart';
import 'group_qr_scanner_screen.dart';
import 'group_qr_screen.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.groups),
        actions: [
          IconButton(
            onPressed: () => _openScanner(context),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: l.scanGroupQr,
          ),
        ],
      ),
      body: groups.isEmpty
          ? _EmptyState(l: l)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _GroupTile(group: groups[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(context, null),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  static Future<void> _openScanner(BuildContext context) async {
    final payload = await Navigator.push<GroupPayload?>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const GroupQrScannerScreen(),
      ),
    );
    if (payload == null || !context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => GroupImportPreviewSheet(payload: payload),
    );
  }

  static void _openSheet(BuildContext context, Group? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _GroupSheet(existing: existing),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(l.noGroups,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l.noGroupsDesc,
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
}

// ─── Group tile ────────────────────────────────────────────────────────────

class _GroupTile extends ConsumerWidget {
  const _GroupTile({required this.group});
  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final memberPreview = group.members.map((m) => m.name).join(', ');

    return Dismissible(
      key: Key(group.id),
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
      confirmDismiss: (_) => _confirmDelete(context, l),
      onDismissed: (_) => ref.read(groupsProvider.notifier).delete(group.id),
      child: GestureDetector(
        onTap: () => GroupsScreen._openSheet(context, group),
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
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group_rounded,
                    color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(
                      memberPreview,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l.membersCount(group.members.length),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, AppLocalizations l) =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l.deleteConfirm),
          content: Text(l.deleteGroupConfirm),
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

// ─── Create / Edit sheet ───────────────────────────────────────────────────

class _GroupSheet extends ConsumerStatefulWidget {
  const _GroupSheet({this.existing});
  final Group? existing;

  @override
  ConsumerState<_GroupSheet> createState() => _GroupSheetState();
}

class _GroupSheetState extends ConsumerState<_GroupSheet> {
  late final TextEditingController _nameCtrl;
  final TextEditingController _memberCtrl = TextEditingController();

  // Members being built in this sheet
  late final List<Person> _members;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _members = List.from(widget.existing?.members ?? []);
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty && _members.length >= 2;

  void _addMember() {
    final name = _memberCtrl.text.trim();
    if (name.isEmpty) return;
    // Avoid duplicate names
    if (_members.any((m) => m.name.toLowerCase() == name.toLowerCase())) {
      _memberCtrl.clear();
      return;
    }
    setState(() {
      _members.add(Person.create(name));
      _memberCtrl.clear();
    });
  }

  void _removeMember(Person person) =>
      setState(() => _members.remove(person));

  void _save(BuildContext context) {
    final notifier = ref.read(groupsProvider.notifier);
    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        members: List.from(_members),
      );
      notifier.save(updated);
    } else {
      notifier.save(Group.create(
        name: _nameCtrl.text.trim(),
        members: List.from(_members),
      ));
    }
    Navigator.pop(context);
  }

  void _showQr(BuildContext context) {
    // Reflect any in-flight edits in the QR rather than just the saved state.
    final live = widget.existing!.copyWith(
      name: _nameCtrl.text.trim(),
      members: List.from(_members),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GroupQrScreen(group: live),
      ),
    );
  }

  void _delete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteConfirm),
        content: Text(l.deleteGroupConfirm),
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
    if (confirm == true && context.mounted) {
      ref.read(groupsProvider.notifier).delete(widget.existing!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final recentPeople = ref.watch(recentPeopleProvider);
    final allGroups = ref.watch(groupsProvider);

    // Merge recent people + members from other groups, deduped by name
    final knownByName = <String, Person>{};
    for (final p in recentPeople) {
      knownByName[p.name.toLowerCase()] = p;
    }
    for (final g in allGroups) {
      if (g.id == widget.existing?.id) continue;
      for (final m in g.members) {
        knownByName.putIfAbsent(m.name.toLowerCase(), () => m);
      }
    }

    final suggestions = knownByName.values
        .where((p) => !_members.any(
            (m) => m.name.toLowerCase() == p.name.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEdit ? l.edit : l.createGroup,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                if (_isEdit) ...[
                  IconButton(
                    onPressed: () => _showQr(context),
                    icon: const Icon(Icons.qr_code_rounded),
                    color: AppColors.primary,
                    tooltip: l.shareViaQr,
                  ),
                  IconButton(
                    onPressed: () => _delete(context),
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.error,
                    tooltip: l.delete,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Group name
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l.groupName,
                hintText: l.groupNameHint,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // Members section header
            Text(l.stepWhosIn,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            // Type-to-add member row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberCtrl,
                    decoration: InputDecoration(
                      hintText: l.personNameHint,
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addMember(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _addMember,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(52, 44),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                ),
              ],
            ),

            // Current members as deletable chips
            if (_members.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _members.asMap().entries.map((e) {
                  final person = e.value;
                  final color = AppColors.avatarFor(e.key);
                  return _MemberChip(
                    person: person,
                    color: color,
                    onRemove: () => _removeMember(person),
                  );
                }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Text(
                l.addAtLeastTwoMembers,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],

            // Recent people suggestions
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l.suggestions,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((p) => ActionChip(
                  avatar: CircleAvatar(
                    radius: 10,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  label: Text(
                    p.name,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
                  ),
                  onPressed: () => setState(() => _members.add(p)),
                )).toList(),
              ),
            ],

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _canSave ? () => _save(context) : null,
              child: Text(_isEdit ? l.save : l.createGroup),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Member chip ───────────────────────────────────────────────────────────

class _MemberChip extends StatelessWidget {
  const _MemberChip({
    required this.person,
    required this.color,
    required this.onRemove,
  });
  final Person person;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
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
              person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
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
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: color),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}
