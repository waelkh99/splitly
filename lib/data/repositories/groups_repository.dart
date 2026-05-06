import '../../core/storage/hive_service.dart';
import '../models/group.dart';

class GroupsRepository {
  List<Group> getAll() {
    return HiveService.groupsBox.values
        .map((m) => Group.fromMap(m))
        .toList();
  }

  Future<void> save(Group group) async {
    await HiveService.groupsBox.put(group.id, group.toMap() as Map);
  }

  Future<void> delete(String id) async {
    await HiveService.groupsBox.delete(id);
  }
}
