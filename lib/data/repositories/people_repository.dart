import '../../core/storage/hive_service.dart';
import '../models/person.dart';

class PeopleRepository {
  List<Person> getAll() {
    final box = HiveService.peopleBox;
    return box.values
        .map((m) => Person.fromMap(m))
        .toList()
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
  }

  Future<void> save(Person person) async {
    await HiveService.peopleBox.put(person.id, person.toMap() as Map);
  }

  Future<void> delete(String id) async {
    await HiveService.peopleBox.delete(id);
  }

  Future<void> touchLastUsed(String id) async {
    final box = HiveService.peopleBox;
    final existing = box.get(id);
    if (existing != null) {
      final updated = Person.fromMap(existing)
          .copyWith(lastUsed: DateTime.now());
      await box.put(id, updated.toMap() as Map);
    }
  }
}
