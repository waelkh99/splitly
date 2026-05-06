import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/group.dart';
import '../../data/repositories/groups_repository.dart';

class GroupsNotifier extends StateNotifier<List<Group>> {
  final GroupsRepository _repo;

  GroupsNotifier(this._repo) : super([]) {
    state = _repo.getAll();
  }

  Future<void> save(Group group) async {
    await _repo.save(group);
    state = _repo.getAll();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = _repo.getAll();
  }
}

final groupsRepositoryProvider = Provider((_) => GroupsRepository());

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, List<Group>>((ref) {
  return GroupsNotifier(ref.read(groupsRepositoryProvider));
});
