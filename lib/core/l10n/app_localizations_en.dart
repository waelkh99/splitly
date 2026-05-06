// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Splitly';

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
  String splitSummary(String total, String lines) {
    return '🍽️ Splitly Bill Summary\nTotal: $total\n\n$lines\nSplit with Splitly ✨';
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
