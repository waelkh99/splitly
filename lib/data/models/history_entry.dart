import 'package:uuid/uuid.dart';
import 'split_session.dart';
import 'split_result.dart';

class HistoryEntry {
  final String id;
  final DateTime date;
  final SplitSession session;
  final SplitResult result;

  const HistoryEntry({
    required this.id,
    required this.date,
    required this.session,
    required this.result,
  });

  factory HistoryEntry.create({
    required SplitSession session,
    required SplitResult result,
  }) =>
      HistoryEntry(
        id: const Uuid().v4(),
        date: DateTime.now(),
        session: session,
        result: result,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'session': session.toMap(),
        'result': {
          'total': result.total,
          'amountPerPerson': result.amountPerPerson,
        },
      };

  factory HistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    final session = SplitSession.fromMap(map['session'] as Map);
    final resultMap = map['result'] as Map;
    final rawAmounts = resultMap['amountPerPerson'] as Map;
    final amounts = rawAmounts.map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    );
    return HistoryEntry(
      id: map['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      session: session,
      result: SplitResult(
        total: (resultMap['total'] as num).toDouble(),
        amountPerPerson: amounts,
      ),
    );
  }
}
