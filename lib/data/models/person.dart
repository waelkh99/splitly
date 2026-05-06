import 'package:uuid/uuid.dart';

class Person {
  final String id;
  final String name;
  final DateTime lastUsed;

  const Person({
    required this.id,
    required this.name,
    required this.lastUsed,
  });

  factory Person.create(String name) => Person(
        id: const Uuid().v4(),
        name: name,
        lastUsed: DateTime.now(),
      );

  Person copyWith({String? name, DateTime? lastUsed}) => Person(
        id: id,
        name: name ?? this.name,
        lastUsed: lastUsed ?? this.lastUsed,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'lastUsed': lastUsed.millisecondsSinceEpoch,
      };

  factory Person.fromMap(Map<dynamic, dynamic> map) => Person(
        id: map['id'] as String,
        name: map['name'] as String,
        lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastUsed'] as int),
      );

  @override
  bool operator ==(Object other) => other is Person && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
