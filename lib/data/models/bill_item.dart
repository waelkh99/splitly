import 'package:uuid/uuid.dart';

class BillItem {
  final String id;
  final String name;
  final double price;
  // personId → quantity ordered. Equal split when all quantities are 1.
  final Map<String, int> personQuantities;
  // Relative position on the receipt canvas (0.0–1.0). Null = manually added.
  final double? imageX;
  final double? imageY;

  const BillItem({
    required this.id,
    required this.name,
    required this.price,
    this.personQuantities = const {},
    this.imageX,
    this.imageY,
  });

  factory BillItem.create({
    required String name,
    required double price,
    double? imageX,
    double? imageY,
  }) =>
      BillItem(
        id: const Uuid().v4(),
        name: name,
        price: price,
        imageX: imageX,
        imageY: imageY,
      );

  List<String> get assignedPersonIds => personQuantities.keys.toList();
  bool get isAssigned => personQuantities.isNotEmpty;
  bool get isPinned => imageX != null && imageY != null;

  int get totalQuantity =>
      personQuantities.values.fold(0, (sum, q) => sum + q);

  double amountFor(String personId) {
    final qty = personQuantities[personId];
    if (qty == null || qty == 0) return 0;
    final total = totalQuantity;
    if (total == 0) return 0;
    return price * qty / total;
  }

  BillItem copyWith({
    String? name,
    double? price,
    Map<String, int>? personQuantities,
    Object? imageX = _sentinel,
    Object? imageY = _sentinel,
  }) =>
      BillItem(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        personQuantities: personQuantities ?? this.personQuantities,
        imageX: imageX == _sentinel ? this.imageX : imageX as double?,
        imageY: imageY == _sentinel ? this.imageY : imageY as double?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'personQuantities': personQuantities.map((k, v) => MapEntry(k, v)),
        // legacy field kept for forward-compat reads
        'assignedPersonIds': assignedPersonIds,
        'imageX': imageX,
        'imageY': imageY,
      };

  factory BillItem.fromMap(Map<dynamic, dynamic> map) {
    // Migrate legacy data: if personQuantities absent, build from assignedPersonIds
    Map<String, int> quantities;
    if (map['personQuantities'] != null) {
      quantities = (map['personQuantities'] as Map)
          .map((k, v) => MapEntry(k as String, (v as num).toInt()));
    } else {
      quantities = {
        for (final id in (map['assignedPersonIds'] as List).cast<String>())
          id: 1,
      };
    }
    return BillItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      personQuantities: quantities,
      imageX: (map['imageX'] as num?)?.toDouble(),
      imageY: (map['imageY'] as num?)?.toDouble(),
    );
  }
}

const _sentinel = Object();
