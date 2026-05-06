import 'person.dart';
import 'split_session.dart';

class SplitResult {
  final double total;
  final Map<String, double> amountPerPerson;

  const SplitResult({
    required this.total,
    required this.amountPerPerson,
  });

  factory SplitResult.fromSession(SplitSession session) {
    final people = session.people;
    final items = session.items;
    final adj = session.adjustment;

    if (people.isEmpty) return const SplitResult(total: 0, amountPerPerson: {});

    // Base from items (or override)
    final itemsTotal = adj.totalOverride ??
        items.fold<double>(0, (sum, item) => sum + item.price);

    final grandTotal = itemsTotal + adj.tax + adj.deliveryFee - adj.discount;

    final Map<String, double> amounts = {
      for (final p in people) p.id: 0.0,
    };

    if (adj.totalOverride != null) {
      // Split total override equally
      final share = grandTotal / people.length;
      for (final p in people) {
        amounts[p.id] = share;
      }
    } else {
      // Per-item assignment
      for (final item in items) {
        if (item.assignedPersonIds.isEmpty) {
          // Unassigned items split equally
          final share = item.price / people.length;
          for (final p in people) {
            amounts[p.id] = (amounts[p.id] ?? 0) + share;
          }
        } else {
          final share = item.price / item.assignedPersonIds.length;
          for (final pid in item.assignedPersonIds) {
            amounts[pid] = (amounts[pid] ?? 0) + share;
          }
        }
      }

      // Adjustments split equally
      final adjPerPerson = adj.net / people.length;
      for (final p in people) {
        amounts[p.id] = (amounts[p.id] ?? 0) + adjPerPerson;
      }
    }

    // Clamp negatives to 0
    for (final key in amounts.keys.toList()) {
      if ((amounts[key] ?? 0) < 0) amounts[key] = 0;
    }

    return SplitResult(total: grandTotal < 0 ? 0 : grandTotal, amountPerPerson: amounts);
  }

  double amountFor(Person person) => amountPerPerson[person.id] ?? 0;
}
