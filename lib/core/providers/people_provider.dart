import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/person.dart';
import '../../data/repositories/people_repository.dart';

class PeopleNotifier extends StateNotifier<List<Person>> {
  final PeopleRepository _repo;

  PeopleNotifier(this._repo) : super([]) {
    state = _repo.getAll();
  }

  Future<void> addOrUpdate(Person person) async {
    await _repo.save(person);
    state = _repo.getAll();
  }

  Future<void> touchLastUsed(String id) async {
    await _repo.touchLastUsed(id);
    state = _repo.getAll();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = _repo.getAll();
  }
}

final peopleRepositoryProvider =
    Provider((_) => PeopleRepository());

final recentPeopleProvider =
    StateNotifierProvider<PeopleNotifier, List<Person>>((ref) {
  return PeopleNotifier(ref.read(peopleRepositoryProvider));
});
