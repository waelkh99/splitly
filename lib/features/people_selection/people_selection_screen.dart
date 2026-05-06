import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/people_provider.dart';
import '../../core/providers/groups_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/step_indicator.dart';
import '../../data/models/person.dart';
import '../../data/models/group.dart';

class PeopleSelectionScreen extends ConsumerStatefulWidget {
  const PeopleSelectionScreen({super.key});

  @override
  ConsumerState<PeopleSelectionScreen> createState() =>
      _PeopleSelectionScreenState();
}

class _PeopleSelectionScreenState
    extends ConsumerState<PeopleSelectionScreen> {
  final _addCtrl = TextEditingController();
  final Set<String> _expandedGroups = {};

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  void _addPerson(Person person) {
    ref.read(splitSessionProvider.notifier).addPerson(person);
    ref
        .read(recentPeopleProvider.notifier)
        .addOrUpdate(person.copyWith(lastUsed: DateTime.now()));
  }

  void _addByName() {
    final name = _addCtrl.text.trim();
    if (name.isEmpty) return;
    // Reuse existing person with same name if known
    final existing = ref
        .read(recentPeopleProvider)
        .where((p) => p.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    _addPerson(existing ?? Person.create(name));
    _addCtrl.clear();
  }

  void _removePerson(String id) =>
      ref.read(splitSessionProvider.notifier).removePerson(id);

  void _addGroup(Group group) {
    final selectedIds =
        ref.read(splitSessionProvider).people.map((p) => p.id).toSet();
    for (final m in group.members) {
      if (!selectedIds.contains(m.id)) _addPerson(m);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = ref.watch(splitSessionProvider).people;
    final selectedIds = selected.map((p) => p.id).toSet();
    final recent = ref.watch(recentPeopleProvider);
    final groups = ref.watch(groupsProvider);

    // People available to add = recent people not already selected
    final available =
        recent.where((p) => !selectedIds.contains(p.id)).toList();

    final canContinue = selected.length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.stepWhosIn),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepIndicator(current: 0),

          // ── Selected people row ────────────────────────────────────────────
          _SelectedRow(
            people: selected,
            onRemove: _removePerson,
          ),

          const Divider(height: 1),

          // ── Scrollable content ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inline add field
                  _AddField(
                    ctrl: _addCtrl,
                    onAdd: _addByName,
                    hint: l.personNameHint,
                    label: l.addPerson,
                  ),

                  // Groups section
                  if (groups.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionLabel(l.groups),
                    const SizedBox(height: 8),
                    ...groups.map((g) {
                      final expanded = _expandedGroups.contains(g.id);
                      final allAdded = g.members
                          .every((m) => selectedIds.contains(m.id));
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _GroupCard(
                          group: g,
                          selectedIds: selectedIds,
                          expanded: expanded,
                          allAdded: allAdded,
                          onToggle: () => setState(() {
                            if (expanded) {
                              _expandedGroups.remove(g.id);
                            } else {
                              _expandedGroups.add(g.id);
                            }
                          }),
                          onAddAll: allAdded ? null : () => _addGroup(g),
                          onAddMember: (p) => _addPerson(p),
                          onRemoveMember: (id) => _removePerson(id),
                        ),
                      );
                    }),
                  ],

                  // Available / recent people
                  if (available.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionLabel(
                      recent.length == available.length
                          ? l.recent
                          : l.morePeople,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: available.asMap().entries.map((e) {
                        final person = e.value;
                        final color = AppColors.avatarFor(
                            recent.indexOf(person));
                        return _PersonPill(
                          person: person,
                          color: color,
                          onTap: () => _addPerson(person),
                        );
                      }).toList(),
                    ),
                  ],

                  // Empty hint when nothing known yet
                  if (available.isEmpty && groups.isEmpty && selected.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.person_add_rounded,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              l.typeNameToGetStarted,
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        canContinue: canContinue,
        count: selected.length,
        onNext: canContinue
            ? () => Navigator.pushNamed(context, AppRoutes.split)
            : null,
        hint: l.atLeastTwoPeople,
      ),
    );
  }
}

// ─── Selected people row ───────────────────────────────────────────────────

class _SelectedRow extends StatelessWidget {
  const _SelectedRow({required this.people, required this.onRemove});
  final List<Person> people;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          AppLocalizations.of(context).noOneAddedYet,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: people.asMap().entries.map((e) {
          final person = e.value;
          final color = AppColors.avatarFor(e.key);
          return _SelectedChip(
            person: person,
            color: color,
            onRemove: () => onRemove(person.id),
          );
        }).toList(),
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({
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
      padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: color.withValues(alpha: 0.25),
            child: Text(
              person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            person.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inline add field ──────────────────────────────────────────────────────

class _AddField extends StatelessWidget {
  const _AddField({
    required this.ctrl,
    required this.onAdd,
    required this.hint,
    required this.label,
  });
  final TextEditingController ctrl;
  final VoidCallback onAdd;
  final String hint;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: hint,
              labelText: label,
              prefixIcon:
                  const Icon(Icons.person_outline_rounded, size: 20),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => onAdd(),
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(52, 50),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.add_rounded, size: 22),
          ),
        ),
      ],
    );
  }
}

// ─── Group card ────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.selectedIds,
    required this.expanded,
    required this.allAdded,
    required this.onToggle,
    required this.onAddAll,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  final Group group;
  final Set<String> selectedIds;
  final bool expanded;
  final bool allAdded;
  final VoidCallback onToggle;
  final VoidCallback? onAddAll;
  final ValueChanged<Person> onAddMember;
  final ValueChanged<String> onRemoveMember;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.group_rounded,
                        color: AppColors.secondary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(
                          group.members.map((m) => m.name).join(', '),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Add all button
                  TextButton(
                    onPressed: onAddAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: allAdded
                          ? Colors.grey.shade400
                          : AppColors.primary,
                    ),
                    child: Text(
                      allAdded
                          ? AppLocalizations.of(context).added
                          : AppLocalizations.of(context).addAll,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded member list
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: group.members.map((m) {
                  final inSession = selectedIds.contains(m.id);
                  final color = AppColors.avatarFor(
                      group.members.indexOf(m));
                  return _MemberToggle(
                    person: m,
                    color: color,
                    inSession: inSession,
                    onTap: () => inSession
                        ? onRemoveMember(m.id)
                        : onAddMember(m),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberToggle extends StatelessWidget {
  const _MemberToggle({
    required this.person,
    required this.color,
    required this.inSession,
    required this.onTap,
  });
  final Person person;
  final Color color;
  final bool inSession;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: inSession
              ? color.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: inSession
                ? color.withValues(alpha: 0.4)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (inSession)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.check_rounded, size: 12, color: color),
              ),
            Text(
              person.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: inSession ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Available / recent people pill ───────────────────────────────────────

class _PersonPill extends StatelessWidget {
  const _PersonPill({
    required this.person,
    required this.color,
    required this.onTap,
  });
  final Person person;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              person.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.add_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.6,
        ),
      );
}

// ─── Bottom bar ────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.canContinue,
    required this.count,
    required this.onNext,
    required this.hint,
  });
  final bool canContinue;
  final int count;
  final VoidCallback? onNext;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
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
          if (!canContinue)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                hint,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canContinue ? AppColors.primary : Colors.grey.shade300,
              foregroundColor: canContinue ? Colors.white : Colors.grey,
            ),
            child: Text(
              canContinue ? '${l.next}  ($count)' : l.next,
            ),
          ),
        ],
      ),
    );
  }
}
