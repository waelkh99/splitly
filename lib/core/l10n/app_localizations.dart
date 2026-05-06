import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Splitly'**
  String get appName;

  /// No description provided for @splitBillsInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Split bills in seconds'**
  String get splitBillsInSeconds;

  /// No description provided for @newSplit.
  ///
  /// In en, this message translates to:
  /// **'New Split'**
  String get newSplit;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp'**
  String get shareViaWhatsApp;

  /// No description provided for @startNewSplit.
  ///
  /// In en, this message translates to:
  /// **'Start New Split'**
  String get startNewSplit;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Split bills in seconds'**
  String get homeTagline;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No splits yet'**
  String get noHistory;

  /// No description provided for @noHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Your completed splits will appear here.'**
  String get noHistoryDesc;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroups;

  /// No description provided for @noGroupsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save a group to reuse it next time.'**
  String get noGroupsDesc;

  /// No description provided for @stepWhosIn.
  ///
  /// In en, this message translates to:
  /// **'Who\'s in?'**
  String get stepWhosIn;

  /// No description provided for @stepSplit.
  ///
  /// In en, this message translates to:
  /// **'Split the bill'**
  String get stepSplit;

  /// No description provided for @stepAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Adjustments'**
  String get stepAdjustments;

  /// No description provided for @stepSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get stepSummary;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @pasteNames.
  ///
  /// In en, this message translates to:
  /// **'Paste names'**
  String get pasteNames;

  /// No description provided for @pasteNamesHint.
  ///
  /// In en, this message translates to:
  /// **'Ahmed, Sara, Omar…'**
  String get pasteNamesHint;

  /// No description provided for @useLastGroup.
  ///
  /// In en, this message translates to:
  /// **'Use last group'**
  String get useLastGroup;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get personName;

  /// No description provided for @personNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get personNameHint;

  /// No description provided for @atLeastTwoPeople.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 people to continue'**
  String get atLeastTwoPeople;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @morePeople.
  ///
  /// In en, this message translates to:
  /// **'More people'**
  String get morePeople;

  /// No description provided for @typeNameToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Type a name above to get started'**
  String get typeNameToGetStarted;

  /// No description provided for @noOneAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No one added yet - select below'**
  String get noOneAddedYet;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @addAll.
  ///
  /// In en, this message translates to:
  /// **'+ All'**
  String get addAll;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pizza'**
  String get itemNameHint;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get priceHint;

  /// No description provided for @unassignedItems.
  ///
  /// In en, this message translates to:
  /// **'{count} unassigned'**
  String unassignedItems(int count);

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign to…'**
  String get assignTo;

  /// No description provided for @receiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get receiptPhoto;

  /// No description provided for @addReceiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addReceiptPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @tapOrDragToAssign.
  ///
  /// In en, this message translates to:
  /// **'Tap or drag items to assign them'**
  String get tapOrDragToAssign;

  /// No description provided for @tapReceiptToAssign.
  ///
  /// In en, this message translates to:
  /// **'Tap on the receipt to mark items, then drag to assign'**
  String get tapReceiptToAssign;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get photoLibrary;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changePhoto;

  /// No description provided for @adjustments.
  ///
  /// In en, this message translates to:
  /// **'Adjustments'**
  String get adjustments;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @totalOverride.
  ///
  /// In en, this message translates to:
  /// **'Total override'**
  String get totalOverride;

  /// No description provided for @totalOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use items total'**
  String get totalOverrideHint;

  /// No description provided for @replacesSum.
  ///
  /// In en, this message translates to:
  /// **'Replaces sum'**
  String get replacesSum;

  /// No description provided for @adjustmentsTotal.
  ///
  /// In en, this message translates to:
  /// **'New total'**
  String get adjustmentsTotal;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @selectWhoOrderedThisItem.
  ///
  /// In en, this message translates to:
  /// **'Select who ordered this item'**
  String get selectWhoOrderedThisItem;

  /// No description provided for @yourPeopleWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your people will appear here'**
  String get yourPeopleWillAppearHere;

  /// No description provided for @billSummary.
  ///
  /// In en, this message translates to:
  /// **'Bill Summary'**
  String get billSummary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @splitSummary.
  ///
  /// In en, this message translates to:
  /// **'🍽️ Splitly Bill Summary\nTotal: {total}\n\n{lines}\nSplit with Splitly ✨'**
  String splitSummary(String total, String lines);

  /// No description provided for @shareableLinePerson.
  ///
  /// In en, this message translates to:
  /// **'{name}: {amount}'**
  String shareableLinePerson(String name, String amount);

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Office team'**
  String get groupNameHint;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @saveAsGroup.
  ///
  /// In en, this message translates to:
  /// **'Save as group'**
  String get saveAsGroup;

  /// No description provided for @loadGroup.
  ///
  /// In en, this message translates to:
  /// **'Load group'**
  String get loadGroup;

  /// No description provided for @addAtLeastTwoMembers.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 members'**
  String get addAtLeastTwoMembers;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency symbol'**
  String get currency;

  /// No description provided for @currencyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. JD'**
  String get currencyHint;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteConfirm;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this group?'**
  String get deleteGroupConfirm;

  /// No description provided for @deleteHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this split from history?'**
  String get deleteHistoryConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @splitOn.
  ///
  /// In en, this message translates to:
  /// **'Split on {date}'**
  String splitOn(String date);

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String peopleCount(int count);

  /// No description provided for @splitWithApp.
  ///
  /// In en, this message translates to:
  /// **'Split with {appName} ✨'**
  String splitWithApp(String appName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
