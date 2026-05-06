String formatAmount(double amount, String currency) {
  final formatted = amount.toStringAsFixed(2);
  return '$formatted $currency';
}
