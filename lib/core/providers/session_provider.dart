import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/split_session.dart';
import '../../data/models/split_result.dart';
import '../../data/models/person.dart';
import '../../data/models/bill_item.dart';
import '../../data/models/adjustment.dart';

class SessionNotifier extends StateNotifier<SplitSession> {
  SessionNotifier() : super(SplitSession.empty());

  void reset() => state = SplitSession.empty();

  // People
  void addPerson(Person person) {
    if (state.people.any((p) => p.id == person.id)) return;
    state = state.copyWith(people: [...state.people, person]);
  }

  void removePerson(String personId) {
    final updatedPeople = state.people.where((p) => p.id != personId).toList();
    // Unassign the person from items
    final updatedItems = state.items.map((item) {
      final ids = item.assignedPersonIds.where((id) => id != personId).toList();
      return item.copyWith(assignedPersonIds: ids);
    }).toList();
    state = state.copyWith(people: updatedPeople, items: updatedItems);
  }

  void setPeople(List<Person> people) {
    state = state.copyWith(people: people);
  }

  // Items
  void addItem(BillItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateItem(BillItem item) {
    state = state.copyWith(
      items: state.items.map((i) => i.id == item.id ? item : i).toList(),
    );
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != itemId).toList(),
    );
  }

  void assignItem(String itemId, List<String> personIds) {
    updateItem(
      state.items.firstWhere((i) => i.id == itemId).copyWith(
            assignedPersonIds: personIds,
          ),
    );
  }

  void togglePersonOnItem(String itemId, String personId) {
    final item = state.items.firstWhere((i) => i.id == itemId);
    final ids = List<String>.from(item.assignedPersonIds);
    if (ids.contains(personId)) {
      ids.remove(personId);
    } else {
      ids.add(personId);
    }
    updateItem(item.copyWith(assignedPersonIds: ids));
  }

  // Receipt image
  void setReceiptImage(String? path) {
    state = state.copyWith(receiptImagePath: path);
  }

  // Adjustments
  void setAdjustment(Adjustment adjustment) {
    state = state.copyWith(adjustment: adjustment);
  }
}

final splitSessionProvider =
    StateNotifierProvider<SessionNotifier, SplitSession>(
  (_) => SessionNotifier(),
);

final splitResultProvider = Provider<SplitResult>((ref) {
  final session = ref.watch(splitSessionProvider);
  return SplitResult.fromSession(session);
});
