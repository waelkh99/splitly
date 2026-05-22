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
    final updatedItems = state.items.map((item) {
      final quantities = Map<String, int>.from(item.personQuantities)
        ..remove(personId);
      return item.copyWith(personQuantities: quantities);
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

  void assignItem(String itemId, Map<String, int> personQuantities) {
    updateItem(
      state.items
          .firstWhere((i) => i.id == itemId)
          .copyWith(personQuantities: personQuantities),
    );
  }

  void togglePersonOnItem(String itemId, String personId) {
    final item = state.items.firstWhere((i) => i.id == itemId);
    final quantities = Map<String, int>.from(item.personQuantities);
    if (quantities.containsKey(personId)) {
      quantities.remove(personId);
    } else {
      quantities[personId] = 1;
    }
    updateItem(item.copyWith(personQuantities: quantities));
  }

  void setPersonQuantity(String itemId, String personId, int quantity) {
    final item = state.items.firstWhere((i) => i.id == itemId);
    final quantities = Map<String, int>.from(item.personQuantities);
    if (quantity <= 0) {
      quantities.remove(personId);
    } else {
      quantities[personId] = quantity;
    }
    updateItem(item.copyWith(personQuantities: quantities));
  }

  // Receipt image
  void setReceiptImage(String? path) {
    state = state.copyWith(receiptImagePath: path);
  }

  // Payment alias (CashApp, CliQ, etc.) shown on the share card.
  void setPayTo(String? value) {
    final trimmed = value?.trim();
    state = state.copyWith(payTo: (trimmed?.isEmpty ?? true) ? null : trimmed);
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
