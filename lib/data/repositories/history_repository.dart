import '../../core/storage/hive_service.dart';
import '../models/history_entry.dart';

class HistoryRepository {
  static const _maxEntries = 10;

  List<HistoryEntry> getAll() {
    return HiveService.historyBox.values
        .map((m) => HistoryEntry.fromMap(m))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> save(HistoryEntry entry) async {
    final box = HiveService.historyBox;
    await box.put(entry.id, entry.toMap() as Map);
    await _prune();
  }

  Future<void> delete(String id) async {
    await HiveService.historyBox.delete(id);
  }

  Future<void> _prune() async {
    final box = HiveService.historyBox;
    if (box.length <= _maxEntries) return;
    final sorted = getAll(); // already sorted newest-first
    final toDelete = sorted.skip(_maxEntries).map((e) => e.id).toList();
    await box.deleteAll(toDelete);
  }
}
