import 'package:uuid/uuid.dart';
import 'person.dart';
import 'bill_item.dart';
import 'adjustment.dart';

class SplitSession {
  final String id;
  final List<Person> people;
  final List<BillItem> items;
  final Adjustment adjustment;
  final String? receiptImagePath;
  final DateTime createdAt;

  const SplitSession({
    required this.id,
    required this.people,
    required this.items,
    required this.adjustment,
    this.receiptImagePath,
    required this.createdAt,
  });

  factory SplitSession.empty() => SplitSession(
        id: const Uuid().v4(),
        people: const [],
        items: const [],
        adjustment: const Adjustment(),
        createdAt: DateTime.now(),
      );

  int get unassignedCount => items.where((i) => !i.isAssigned).length;

  SplitSession copyWith({
    List<Person>? people,
    List<BillItem>? items,
    Adjustment? adjustment,
    Object? receiptImagePath = _sentinel,
  }) =>
      SplitSession(
        id: id,
        people: people ?? this.people,
        items: items ?? this.items,
        adjustment: adjustment ?? this.adjustment,
        receiptImagePath: receiptImagePath == _sentinel
            ? this.receiptImagePath
            : receiptImagePath as String?,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'people': people.map((p) => p.toMap()).toList(),
        'items': items.map((i) => i.toMap()).toList(),
        'adjustment': adjustment.toMap(),
        'receiptImagePath': receiptImagePath,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory SplitSession.fromMap(Map<dynamic, dynamic> map) => SplitSession(
        id: map['id'] as String,
        people: (map['people'] as List)
            .map((e) => Person.fromMap(e as Map))
            .toList(),
        items: (map['items'] as List)
            .map((e) => BillItem.fromMap(e as Map))
            .toList(),
        adjustment: Adjustment.fromMap(map['adjustment'] as Map),
        receiptImagePath: map['receiptImagePath'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}

const _sentinel = Object();
