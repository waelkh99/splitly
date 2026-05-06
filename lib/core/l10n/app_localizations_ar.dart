// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سبلتلي';

  @override
  String get splitBillsInSeconds => 'قسّم الفاتورة في ثوانٍ';

  @override
  String get newSplit => 'تقسيم جديد';

  @override
  String get history => 'السجل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get groups => 'المجموعات';

  @override
  String get done => 'تم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get share => 'مشاركة';

  @override
  String get shareViaWhatsApp => 'مشاركة عبر واتساب';

  @override
  String get startNewSplit => 'بدء تقسيم جديد';

  @override
  String get homeTagline => 'قسّم الفاتورة خلال ثوانٍ';

  @override
  String get noHistory => 'لا يوجد سجل بعد';

  @override
  String get noHistoryDesc => 'ستظهر هنا عمليات التقسيم المكتملة.';

  @override
  String get noGroups => 'لا توجد مجموعات بعد';

  @override
  String get noGroupsDesc => 'احفظ مجموعة لاستخدامها مرة أخرى.';

  @override
  String get stepWhosIn => 'من سيشارك؟';

  @override
  String get stepSplit => 'تقسيم الفاتورة';

  @override
  String get stepAdjustments => 'التعديلات';

  @override
  String get stepSummary => 'الملخص';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get pasteNames => 'لصق الأسماء';

  @override
  String get pasteNamesHint => 'أحمد، سارة، عمر…';

  @override
  String get useLastGroup => 'استخدام آخر مجموعة';

  @override
  String get personName => 'الاسم';

  @override
  String get personNameHint => 'أدخل الاسم';

  @override
  String get atLeastTwoPeople => 'أضف شخصين على الأقل للمتابعة';

  @override
  String get recent => 'الأخيرة';

  @override
  String get morePeople => 'أشخاص إضافيون';

  @override
  String get typeNameToGetStarted => 'اكتب اسماً بالأعلى للبدء';

  @override
  String get noOneAddedYet => 'لم يتم إضافة أحد بعد - اختر من الأسفل';

  @override
  String get added => 'تمت الإضافة';

  @override
  String get addAll => '+ الكل';

  @override
  String get addItem => 'إضافة صنف';

  @override
  String get newItem => 'صنف جديد';

  @override
  String get editItem => 'تعديل الصنف';

  @override
  String get itemName => 'اسم الصنف';

  @override
  String get itemNameHint => 'مثال: بيتزا';

  @override
  String get price => 'السعر';

  @override
  String get priceHint => '0.00';

  @override
  String unassignedItems(int count) {
    return '$count غير مخصصة';
  }

  @override
  String get assignTo => 'تخصيص لـ…';

  @override
  String get receiptPhoto => 'صورة الفاتورة';

  @override
  String get addReceiptPhoto => 'إضافة صورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get tapOrDragToAssign => 'اضغط أو اسحب لتخصيص الأصناف';

  @override
  String get tapReceiptToAssign =>
      'اضغط على الفاتورة لوضع الأصناف ثم اسحب للتخصيص';

  @override
  String get camera => 'الكاميرا';

  @override
  String get photoLibrary => 'مكتبة الصور';

  @override
  String get changePhoto => 'تغيير';

  @override
  String get adjustments => 'التعديلات';

  @override
  String get tax => 'الضريبة';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get discount => 'الخصم';

  @override
  String get totalOverride => 'تجاوز الإجمالي';

  @override
  String get totalOverrideHint => 'اتركه فارغاً لاستخدام مجموع الأصناف';

  @override
  String get replacesSum => 'يستبدل المجموع';

  @override
  String get adjustmentsTotal => 'الإجمالي الجديد';

  @override
  String get skip => 'تخطي';

  @override
  String get selectWhoOrderedThisItem => 'حدد من طلب هذا الصنف';

  @override
  String get yourPeopleWillAppearHere => 'سيظهر الأشخاص هنا';

  @override
  String get billSummary => 'ملخص الفاتورة';

  @override
  String get total => 'الإجمالي';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String splitSummary(String total, String lines) {
    return '🍽️ ملخص فاتورة سبلتلي\nالإجمالي: $total\n\n$lines\nتم التقسيم عبر سبلتلي ✨';
  }

  @override
  String shareableLinePerson(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get groupNameHint => 'مثال: فريق المكتب';

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get saveAsGroup => 'حفظ كمجموعة';

  @override
  String get loadGroup => 'تحميل مجموعة';

  @override
  String get addAtLeastTwoMembers => 'أضف عضوين على الأقل';

  @override
  String get suggestions => 'اقتراحات';

  @override
  String membersCount(int count) {
    return '$count أعضاء';
  }

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get currency => 'رمز العملة';

  @override
  String get currencyHint => 'مثال: د.أ';

  @override
  String get about => 'حول التطبيق';

  @override
  String get version => 'الإصدار';

  @override
  String get deleteConfirm => 'حذف؟';

  @override
  String get deleteGroupConfirm => 'حذف هذه المجموعة؟';

  @override
  String get deleteHistoryConfirm => 'حذف هذا التقسيم من السجل؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String splitOn(String date) {
    return 'تقسيم بتاريخ $date';
  }

  @override
  String peopleCount(int count) {
    return '$count أشخاص';
  }

  @override
  String splitWithApp(String appName) {
    return 'تم التقسيم عبر $appName ✨';
  }
}
