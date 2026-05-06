import '../../data/models/person.dart';
import '../../data/models/split_result.dart';
import 'currency_formatter.dart';

String buildShareText({
  required List<Person> people,
  required SplitResult result,
  required String currency,
}) {
  final lines = people
      .map((p) =>
          '${p.name}: ${formatAmount(result.amountFor(p), currency)}')
      .join('\n');

  final total = formatAmount(result.total, currency);
  return 'Splitly Bill Summary\nTotal: $total\n\n$lines\n\nSplit with Splitly ✨';
}
