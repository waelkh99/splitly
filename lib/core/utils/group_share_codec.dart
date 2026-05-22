import 'dart:convert';

import '../../data/models/group.dart';
import '../../data/models/person.dart';

/// Versioned envelope identifying a shareable Splitli group payload.
const _appTag = 'splitli';
const _typeTag = 'group';
const _currentVersion = 1;

/// Maximum members allowed in a shared payload — keeps QR within scannable size.
const _maxMembers = 100;

class GroupPayload {
  const GroupPayload({required this.name, required this.memberNames});

  final String name;
  final List<String> memberNames;
}

enum GroupDecodeError {
  notSplitliPayload,
  unsupportedVersion,
  malformed,
  empty,
  tooLarge,
}

class GroupDecodeResult {
  const GroupDecodeResult.success(this.payload) : error = null;
  const GroupDecodeResult.failure(this.error) : payload = null;

  final GroupPayload? payload;
  final GroupDecodeError? error;

  bool get isSuccess => payload != null;
}

/// Encodes a [Group] into a JSON string suitable for embedding in a QR code.
/// Stripped of UUIDs — recipients always generate fresh ones on import.
String encodeGroup(Group group) {
  final payload = {
    'app': _appTag,
    'type': _typeTag,
    'v': _currentVersion,
    'name': group.name,
    'members': group.members.map((m) => {'name': m.name}).toList(),
  };
  return jsonEncode(payload);
}

/// Decodes a raw scanned string into a [GroupPayload] or a typed error.
GroupDecodeResult decodeGroup(String raw) {
  dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    return const GroupDecodeResult.failure(GroupDecodeError.notSplitliPayload);
  }
  if (decoded is! Map) {
    return const GroupDecodeResult.failure(GroupDecodeError.notSplitliPayload);
  }
  if (decoded['app'] != _appTag || decoded['type'] != _typeTag) {
    return const GroupDecodeResult.failure(GroupDecodeError.notSplitliPayload);
  }
  final version = decoded['v'];
  if (version is! int) {
    return const GroupDecodeResult.failure(GroupDecodeError.malformed);
  }
  if (version > _currentVersion) {
    return const GroupDecodeResult.failure(GroupDecodeError.unsupportedVersion);
  }

  final name = decoded['name'];
  final members = decoded['members'];
  if (name is! String || name.trim().isEmpty || members is! List) {
    return const GroupDecodeResult.failure(GroupDecodeError.malformed);
  }
  if (members.isEmpty) {
    return const GroupDecodeResult.failure(GroupDecodeError.empty);
  }
  if (members.length > _maxMembers) {
    return const GroupDecodeResult.failure(GroupDecodeError.tooLarge);
  }

  final names = <String>[];
  for (final m in members) {
    if (m is! Map) {
      return const GroupDecodeResult.failure(GroupDecodeError.malformed);
    }
    final n = m['name'];
    if (n is! String || n.trim().isEmpty) {
      return const GroupDecodeResult.failure(GroupDecodeError.malformed);
    }
    names.add(n.trim());
  }

  return GroupDecodeResult.success(
    GroupPayload(name: name.trim(), memberNames: names),
  );
}

/// Builds a fresh [Group] (new UUIDs for the group and every member) from a payload.
Group materializeGroup(GroupPayload payload, {String? overrideName}) {
  return Group.create(
    name: overrideName ?? payload.name,
    members: payload.memberNames.map((n) => Person.create(n)).toList(),
  );
}
