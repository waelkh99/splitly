// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Splitli';

  @override
  String get splitBillsInSeconds => 'Split bills in seconds';

  @override
  String get newSplit => 'New Split';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get groups => 'Groups';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get share => 'Share';

  @override
  String get shareViaWhatsApp => 'Share via WhatsApp';

  @override
  String get startNewSplit => 'Start New Split';

  @override
  String get homeTagline => 'Split bills in seconds';

  @override
  String get noHistory => 'No splits yet';

  @override
  String get noHistoryDesc => 'Your completed splits will appear here.';

  @override
  String get noGroups => 'No groups yet';

  @override
  String get noGroupsDesc => 'Save a group to reuse it next time.';

  @override
  String get stepWhosIn => 'Who\'s in?';

  @override
  String get stepSplit => 'Split the bill';

  @override
  String get stepAdjustments => 'Adjustments';

  @override
  String get stepSummary => 'Summary';

  @override
  String get addPerson => 'Add person';

  @override
  String get pasteNames => 'Paste names';

  @override
  String get pasteNamesHint => 'Ahmed, Sara, Omar…';

  @override
  String get useLastGroup => 'Use last group';

  @override
  String get personName => 'Name';

  @override
  String get personNameHint => 'Enter name';

  @override
  String get atLeastTwoPeople => 'Add at least 2 people to continue';

  @override
  String get recent => 'Recent';

  @override
  String get morePeople => 'More people';

  @override
  String get typeNameToGetStarted => 'Type a name above to get started';

  @override
  String get noOneAddedYet => 'No one added yet - select below';

  @override
  String get added => 'Added';

  @override
  String get addAll => '+ All';

  @override
  String get addItem => 'Add item';

  @override
  String get newItem => 'New item';

  @override
  String get editItem => 'Edit item';

  @override
  String get itemName => 'Item name';

  @override
  String get itemNameHint => 'e.g. Pizza';

  @override
  String get price => 'Price';

  @override
  String get priceHint => '0.00';

  @override
  String unassignedItems(int count) {
    return '$count unassigned';
  }

  @override
  String get assignTo => 'Assign to…';

  @override
  String get receiptPhoto => 'Receipt photo';

  @override
  String get addReceiptPhoto => 'Add photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get tapOrDragToAssign => 'Tap or drag items to assign them';

  @override
  String get tapReceiptToAssign =>
      'Tap on the receipt to mark items, then drag to assign';

  @override
  String get camera => 'Camera';

  @override
  String get photoLibrary => 'Photo library';

  @override
  String get changePhoto => 'Change';

  @override
  String get adjustments => 'Adjustments';

  @override
  String get tax => 'Tax';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get discount => 'Discount';

  @override
  String get totalOverride => 'Total override';

  @override
  String get totalOverrideHint => 'Leave blank to use items total';

  @override
  String get replacesSum => 'Replaces sum';

  @override
  String get adjustmentsTotal => 'New total';

  @override
  String get skip => 'Skip';

  @override
  String get selectWhoOrderedThisItem => 'Select who ordered this item';

  @override
  String get yourPeopleWillAppearHere => 'Your people will appear here';

  @override
  String get billSummary => 'Bill Summary';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get payTo => 'Pay to';

  @override
  String get payToHint => 'CashApp / CliQ / Venmo handle';

  @override
  String splitSummary(String total, String lines) {
    return '🍽️ Splitli Bill Summary\nTotal: $total\n\n$lines\nSplit with Splitli ✨';
  }

  @override
  String shareableLinePerson(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'e.g. Office team';

  @override
  String get createGroup => 'Create group';

  @override
  String get saveAsGroup => 'Save as group';

  @override
  String get loadGroup => 'Load group';

  @override
  String get addAtLeastTwoMembers => 'Add at least 2 members';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get shareViaQr => 'Share via QR';

  @override
  String get scanGroupQr => 'Scan group QR';

  @override
  String get scanWithSplitli => 'Scan with Splitli on another phone';

  @override
  String get importFromQr => 'Import from QR';

  @override
  String get importGroup => 'Import group';

  @override
  String get groupImported => 'Group imported';

  @override
  String get notASplitliQr => 'Not a Splitli group QR';

  @override
  String get updateSplitliToImport => 'Update Splitli to import this group';

  @override
  String get groupQrMalformed => 'Couldn\'t read this group QR';

  @override
  String get groupQrTooLarge => 'This group is too large to share via QR';

  @override
  String nameAlreadyExists(String name) {
    return 'A group named \"$name\" already exists';
  }

  @override
  String get replace => 'Replace';

  @override
  String get rename => 'Rename';

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get currency => 'Currency symbol';

  @override
  String get currencyHint => 'e.g. JD';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get help => 'Help';

  @override
  String get howItWorks => 'How it works';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardCard1Title => 'Welcome to Splitli';

  @override
  String get onboardCard1Body =>
      'Split bills with friends in under a minute. No account, no signup.';

  @override
  String get onboardCard2Title => 'Who\'s in?';

  @override
  String get onboardCard2Body =>
      'Add people one by one or pick from saved groups — tap chips to select.';

  @override
  String get onboardCard3Title => 'Mark items on the receipt';

  @override
  String get onboardCard3Body =>
      'Snap a photo or skip it, tap to mark each item, then drag onto a person.';

  @override
  String get onboardCard4Title => 'Adjust & share';

  @override
  String get onboardCard4Body =>
      'Add tax, tip, or discount, then share a clean summary via WhatsApp or anywhere.';

  @override
  String get deleteConfirm => 'Delete?';

  @override
  String get deleteGroupConfirm => 'Delete this group?';

  @override
  String get deleteHistoryConfirm => 'Delete this split from history?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String splitOn(String date) {
    return 'Split on $date';
  }

  @override
  String peopleCount(int count) {
    return '$count people';
  }

  @override
  String splitWithApp(String appName) {
    return 'Split with $appName ✨';
  }
}
