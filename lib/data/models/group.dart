import 'package:uuid/uuid.dart';
import 'person.dart';

class Group {
  final String id;
  final String name;
  final List<Person> members;

  const Group({
    required this.id,
    required this.name,
    required this.members,
  });

  factory Group.create({required String name, required List<Person> members}) =>
      Group(
        id: const Uuid().v4(),
        name: name,
        members: members,
      );

  Group copyWith({String? name, List<Person>? members}) => Group(
        id: id,
        name: name ?? this.name,
        members: members ?? this.members,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'members': members.map((p) => p.toMap()).toList(),
      };

  factory Group.fromMap(Map<dynamic, dynamic> map) => Group(
        id: map['id'] as String,
        name: map['name'] as String,
        members: (map['members'] as List)
            .map((e) => Person.fromMap(e as Map))
            .toList(),
      );
}
