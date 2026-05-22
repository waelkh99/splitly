class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.symbolPrefix,
  });

  final String code;
  final String symbol;
  final String name;
  final bool symbolPrefix;
}

/// Curated set of currencies offered in Settings. Codes match ISO-4217 except
/// 'JD', which is the colloquial form used in Jordan for JOD and was the app's
/// original default — keeping it avoids a migration of existing user data.
const supportedCurrencies = <CurrencyInfo>[
  CurrencyInfo(
      code: 'USD', symbol: r'$', name: 'US Dollar', symbolPrefix: true),
  CurrencyInfo(
      code: 'GBP', symbol: '£', name: 'British Pound', symbolPrefix: true),
  CurrencyInfo(
      code: 'EUR', symbol: '€', name: 'Euro', symbolPrefix: true),
  CurrencyInfo(
      code: 'JD', symbol: 'JD', name: 'Jordanian Dinar', symbolPrefix: false),
  CurrencyInfo(
      code: 'SAR', symbol: 'SAR', name: 'Saudi Riyal', symbolPrefix: false),
  CurrencyInfo(
      code: 'AED', symbol: 'AED', name: 'UAE Dirham', symbolPrefix: false),
];

CurrencyInfo? _lookup(String code) {
  for (final c in supportedCurrencies) {
    if (c.code == code) return c;
  }
  return null;
}

String formatAmount(double amount, String currency) {
  final formatted = amount.toStringAsFixed(2);
  final info = _lookup(currency);
  if (info == null) {
    // Fallback for legacy or custom codes: append the raw string as a suffix.
    return '$formatted $currency';
  }
  return info.symbolPrefix
      ? '${info.symbol}$formatted'
      : '$formatted ${info.symbol}';
}
