import 'package:uuid/uuid.dart';

class BillItem {
  final String id;
  final String name;
  final double price;
  final List<String> assignedPersonIds;
  // Relative position on the receipt canvas (0.0–1.0). Null = manually added.
  final double? imageX;
  final double? imageY;

  const BillItem({
    required this.id,
    required this.name,
    required this.price,
    this.assignedPersonIds = const [],
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

  bool get isAssigned => assignedPersonIds.isNotEmpty;
  bool get isPinned => imageX != null && imageY != null;

  double get pricePerPerson =>
      assignedPersonIds.isEmpty ? 0 : price / assignedPersonIds.length;

  BillItem copyWith({
    String? name,
    double? price,
    List<String>? assignedPersonIds,
    Object? imageX = _sentinel,
    Object? imageY = _sentinel,
  }) =>
      BillItem(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        assignedPersonIds: assignedPersonIds ?? this.assignedPersonIds,
        imageX: imageX == _sentinel ? this.imageX : imageX as double?,
        imageY: imageY == _sentinel ? this.imageY : imageY as double?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'assignedPersonIds': assignedPersonIds,
        'imageX': imageX,
        'imageY': imageY,
      };

  factory BillItem.fromMap(Map<dynamic, dynamic> map) => BillItem(
        id: map['id'] as String,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        assignedPersonIds: (map['assignedPersonIds'] as List).cast<String>(),
        imageX: (map['imageX'] as num?)?.toDouble(),
        imageY: (map['imageY'] as num?)?.toDouble(),
      );
}

const _sentinel = Object();
