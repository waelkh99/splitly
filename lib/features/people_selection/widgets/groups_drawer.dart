import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/group.dart';

class GroupsDrawer extends ConsumerWidget {
  const GroupsDrawer({super.key, required this.onGroupSelected});
  final void Function(Group) onGroupSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final groups = ref.watch(groupsProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                l.groups,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.noGroups,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(l.noGroupsDesc,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (ctx, i) {
                    final group = groups[i];
                    return ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.group_rounded,
                            color: AppColors.secondary, size: 20),
                      ),
                      title: Text(group.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        group.members.map((m) => m.name).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onGroupSelected(group);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
