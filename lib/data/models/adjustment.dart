class Adjustment {
  final double tax;
  final double deliveryFee;
  final double discount;
  final double? totalOverride;

  const Adjustment({
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.totalOverride,
  });

  double get additions => tax + deliveryFee;
  double get deductions => discount;
  double get net => additions - deductions;

  bool get hasAny =>
      tax > 0 || deliveryFee > 0 || discount > 0 || totalOverride != null;

  Adjustment copyWith({
    double? tax,
    double? deliveryFee,
    double? discount,
    Object? totalOverride = _sentinel,
  }) =>
      Adjustment(
        tax: tax ?? this.tax,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        discount: discount ?? this.discount,
        totalOverride: totalOverride == _sentinel
            ? this.totalOverride
            : totalOverride as double?,
      );

  Map<String, dynamic> toMap() => {
        'tax': tax,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'totalOverride': totalOverride,
      };

  factory Adjustment.fromMap(Map<dynamic, dynamic> map) => Adjustment(
        tax: (map['tax'] as num?)?.toDouble() ?? 0,
        deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
        discount: (map['discount'] as num?)?.toDouble() ?? 0,
        totalOverride: (map['totalOverride'] as num?)?.toDouble(),
      );
}

const _sentinel = Object();
