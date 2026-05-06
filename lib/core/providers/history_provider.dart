import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/history_entry.dart';
import '../../data/repositories/history_repository.dart';

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  final HistoryRepository _repo;

  HistoryNotifier(this._repo) : super([]) {
    state = _repo.getAll();
  }

  Future<void> add(HistoryEntry entry) async {
    await _repo.save(entry);
    state = _repo.getAll();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = _repo.getAll();
  }
}

final historyRepositoryProvider = Provider((_) => HistoryRepository());

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  return HistoryNotifier(ref.read(historyRepositoryProvider));
});
