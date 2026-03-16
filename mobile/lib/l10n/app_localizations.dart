import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lv.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lv')
  ];

  /// No description provided for @accountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionTitle;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @activeTripPlural.
  ///
  /// In en, this message translates to:
  /// **'active trips'**
  String get activeTripPlural;

  /// No description provided for @activeTripSingle.
  ///
  /// In en, this message translates to:
  /// **'active trip'**
  String get activeTripSingle;

  /// No description provided for @activeTrips.
  ///
  /// In en, this message translates to:
  /// **'Active trips'**
  String get activeTrips;

  /// No description provided for @activitiesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Activities section coming soon.'**
  String get activitiesComingSoon;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTitle;

  /// No description provided for @addExpensesAction.
  ///
  /// In en, this message translates to:
  /// **'Add expenses'**
  String get addExpensesAction;

  /// No description provided for @addMembersAction.
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get addMembersAction;

  /// No description provided for @addTripMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add trip members'**
  String get addTripMembersTitle;

  /// No description provided for @addedMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} member added.} other{{count} members added.}}'**
  String addedMembersCount(num count);

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @allMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'All members'**
  String get allMembersLabel;

  /// No description provided for @allPaymentsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'All payments are confirmed.'**
  String get allPaymentsConfirmed;

  /// No description provided for @allTrips.
  ///
  /// In en, this message translates to:
  /// **'All trips'**
  String get allTrips;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'12.50'**
  String get amountHint;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0.'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @archivedStatus.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedStatus;

  /// No description provided for @authSubtitleLogin.
  ///
  /// In en, this message translates to:
  /// **'Split travel expenses with friends'**
  String get authSubtitleLogin;

  /// No description provided for @authSubtitleRegister.
  ///
  /// In en, this message translates to:
  /// **'Create account and start splitting trips'**
  String get authSubtitleRegister;

  /// No description provided for @breakdownConfirmedCount.
  ///
  /// In en, this message translates to:
  /// **'confirmed: {count}'**
  String breakdownConfirmedCount(Object count);

  /// No description provided for @breakdownPendingCount.
  ///
  /// In en, this message translates to:
  /// **'pending: {count}'**
  String breakdownPendingCount(Object count);

  /// No description provided for @breakdownSentCount.
  ///
  /// In en, this message translates to:
  /// **'sent: {count}'**
  String breakdownSentCount(Object count);

  /// No description provided for @breakdownSuggestedCount.
  ///
  /// In en, this message translates to:
  /// **'suggested: {count}'**
  String breakdownSuggestedCount(Object count);

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @changeEmailWithPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to change email.'**
  String get changeEmailWithPasswordHelper;

  /// No description provided for @chooseReceiptFile.
  ///
  /// In en, this message translates to:
  /// **'Choose receipt file'**
  String get chooseReceiptFile;

  /// No description provided for @completeAccountSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your email and password to complete your account.'**
  String get completeAccountSetupDescription;

  /// No description provided for @completeAccountSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete account setup'**
  String get completeAccountSetupTitle;

  /// No description provided for @confirmReceivedAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm received'**
  String get confirmReceivedAction;

  /// No description provided for @confirmedAllSettlementsArchived.
  ///
  /// In en, this message translates to:
  /// **'All settlements confirmed. Trip archived.'**
  String get confirmedAllSettlementsArchived;

  /// No description provided for @confirmedAsReceived.
  ///
  /// In en, this message translates to:
  /// **'Confirmed as received.'**
  String get confirmedAsReceived;

  /// No description provided for @confirmedLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmedLabel;

  /// No description provided for @couldNotOpenReceiptLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open receipt link.'**
  String get couldNotOpenReceiptLink;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @createFirstTripHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first trip to get started.'**
  String get createFirstTripHint;

  /// No description provided for @createNewTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Create new trip'**
  String get createNewTripTitle;

  /// No description provided for @createTripAction.
  ///
  /// In en, this message translates to:
  /// **'Create trip'**
  String get createTripAction;

  /// No description provided for @createTripFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a trip first.'**
  String get createTripFirst;

  /// No description provided for @createdByLine.
  ///
  /// In en, this message translates to:
  /// **'{date}  -  Created by {creator}'**
  String createdByLine(Object creator, Object date);

  /// No description provided for @creatorMustFinishTripFirst.
  ///
  /// In en, this message translates to:
  /// **'Trip creator must finish the trip to start settlement confirmation.'**
  String get creatorMustFinishTripFirst;

  /// No description provided for @currentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Current email: {email}'**
  String currentEmailLabel(Object email);

  /// No description provided for @currentReceiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Current receipt is attached.'**
  String get currentReceiptAttached;

  /// No description provided for @dateFormatHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get dateFormatHint;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @dateMustMatchFormat.
  ///
  /// In en, this message translates to:
  /// **'Date must match YYYY-MM-DD.'**
  String get dateMustMatchFormat;

  /// No description provided for @dateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Date unknown'**
  String get dateUnknown;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @deleteExpenseConfirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get deleteExpenseConfirmQuestion;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get deleteExpenseTitle;

  /// No description provided for @directlyExplainedByExpenses.
  ///
  /// In en, this message translates to:
  /// **'Directly explained by expenses: {amount}'**
  String directlyExplainedByExpenses(Object amount);

  /// No description provided for @doneStatus.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneStatus;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpenseTitle;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequired;

  /// No description provided for @enterValidExactAmounts.
  ///
  /// In en, this message translates to:
  /// **'Enter valid exact amounts for all participants.'**
  String get enterValidExactAmounts;

  /// No description provided for @enterValidPercentages.
  ///
  /// In en, this message translates to:
  /// **'Enter valid percentages for all participants.'**
  String get enterValidPercentages;

  /// No description provided for @equalSplitLabel.
  ///
  /// In en, this message translates to:
  /// **'Equal split'**
  String get equalSplitLabel;

  /// No description provided for @exactAmountWithValue.
  ///
  /// In en, this message translates to:
  /// **'Exact: {value}'**
  String exactAmountWithValue(Object value);

  /// No description provided for @exactAmountsLabel.
  ///
  /// In en, this message translates to:
  /// **'Exact amounts'**
  String get exactAmountsLabel;

  /// No description provided for @exactSplitMustMatchTotal.
  ///
  /// In en, this message translates to:
  /// **'Exact split must sum to {amount}.'**
  String exactSplitMustMatchTotal(Object amount);

  /// No description provided for @expenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added.'**
  String get expenseAdded;

  /// No description provided for @expenseBreakdownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How this member is affected by each expense.'**
  String get expenseBreakdownSubtitle;

  /// No description provided for @expenseBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense breakdown'**
  String get expenseBreakdownTitle;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted.'**
  String get expenseDeleted;

  /// No description provided for @expenseIdDate.
  ///
  /// In en, this message translates to:
  /// **'Expense #{id}  -  {date}'**
  String expenseIdDate(Object date, Object id);

  /// No description provided for @expenseImpactLine.
  ///
  /// In en, this message translates to:
  /// **'{date}  -  Paid {paid}  -  Owes {owes}'**
  String expenseImpactLine(Object date, Object owes, Object paid);

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated.'**
  String get expenseUpdated;

  /// No description provided for @expenseWithId.
  ///
  /// In en, this message translates to:
  /// **'Expense #{id}'**
  String expenseWithId(Object id);

  /// No description provided for @expensesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} expense} other{{count} expenses}}'**
  String expensesCount(num count);

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesLabel;

  /// No description provided for @failedToCreateTrip.
  ///
  /// In en, this message translates to:
  /// **'Failed to create trip.'**
  String get failedToCreateTrip;

  /// No description provided for @failedToLoadUsersDirectory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users directory.'**
  String get failedToLoadUsersDirectory;

  /// No description provided for @filterSettlementByMemberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter settlements by member'**
  String get filterSettlementByMemberSubtitle;

  /// No description provided for @finishTripAction.
  ///
  /// In en, this message translates to:
  /// **'Finish trip'**
  String get finishTripAction;

  /// No description provided for @finishTripConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Finish this trip and start settlements?'**
  String get finishTripConfirmationText;

  /// No description provided for @finishTripStartSettlementsAction.
  ///
  /// In en, this message translates to:
  /// **'Finish trip and start settlements'**
  String get finishTripStartSettlementsAction;

  /// No description provided for @finishTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish trip'**
  String get finishTripTitle;

  /// No description provided for @forParticipants.
  ///
  /// In en, this message translates to:
  /// **'For: {participants}'**
  String forParticipants(Object participants);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @friendsProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each member and their confirmation state.'**
  String get friendsProgressSubtitle;

  /// No description provided for @friendsProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends progress'**
  String get friendsProgressTitle;

  /// No description provided for @friendsSectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Friends section coming soon.'**
  String get friendsSectionComingSoon;

  /// No description provided for @fromDirection.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String fromDirection(Object name);

  /// No description provided for @fromToLine.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String fromToLine(Object from, Object to);

  /// No description provided for @generateTurnAction.
  ///
  /// In en, this message translates to:
  /// **'Generate turn'**
  String get generateTurnAction;

  /// No description provided for @hasAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccountQuestion;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String helloUser(Object name);

  /// No description provided for @iSentAction.
  ///
  /// In en, this message translates to:
  /// **'I sent'**
  String get iSentAction;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get invalidEmailFormat;

  /// No description provided for @languageAction.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageAction;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageLatvian.
  ///
  /// In en, this message translates to:
  /// **'Latviešu'**
  String get languageLatvian;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSystemSubtitle;

  /// No description provided for @leaveEmptyKeepPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep current password.'**
  String get leaveEmptyKeepPasswordHelper;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInButton;

  /// No description provided for @logOutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutButton;

  /// No description provided for @logoutFromDeviceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Log out from this device?'**
  String get logoutFromDeviceQuestion;

  /// No description provided for @markedAsSent.
  ///
  /// In en, this message translates to:
  /// **'Marked as sent.'**
  String get markedAsSent;

  /// No description provided for @memberSummariesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current balance state for both sides.'**
  String get memberSummariesSubtitle;

  /// No description provided for @memberSummariesTitle.
  ///
  /// In en, this message translates to:
  /// **'Member summaries'**
  String get memberSummariesTitle;

  /// No description provided for @memberToPaySummary.
  ///
  /// In en, this message translates to:
  /// **'To pay {total}  -  confirmed {confirmed}  -  waiting {waiting}'**
  String memberToPaySummary(Object confirmed, Object total, Object waiting);

  /// No description provided for @membersImpactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated payment impact per member.'**
  String get membersImpactSubtitle;

  /// No description provided for @membersImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'Members impact'**
  String get membersImpactTitle;

  /// No description provided for @membersIncludedInExpense.
  ///
  /// In en, this message translates to:
  /// **'Members included'**
  String get membersIncludedInExpense;

  /// No description provided for @membersLabel.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersLabel;

  /// No description provided for @moreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreCount(Object count);

  /// No description provided for @myFilter.
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get myFilter;

  /// No description provided for @myImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'My impact'**
  String get myImpactTitle;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get firstNameHint;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @firstNameLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'First name must be 2-64 characters.'**
  String get firstNameLengthValidation;

  /// No description provided for @fullNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use first and last name in one field.'**
  String get fullNameHelper;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Anna Ozolina'**
  String get fullNameHint;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter first and last name (at least 2 characters each).'**
  String get fullNameValidation;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your last name'**
  String get lastNameHint;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @lastNameLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Last name must be 2-64 characters.'**
  String get lastNameLengthValidation;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters.'**
  String get nameLengthValidation;

  /// No description provided for @navActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get navActivities;

  /// No description provided for @navAddTrip.
  ///
  /// In en, this message translates to:
  /// **'Add trip'**
  String get navAddTrip;

  /// No description provided for @navBalances.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get navBalances;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get navFriends;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get navRandom;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'How friends will see you'**
  String get nicknameHint;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @nicknameLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be at least 2 characters.'**
  String get nicknameLengthValidation;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get noAccountQuestion;

  /// No description provided for @noBalancesYet.
  ///
  /// In en, this message translates to:
  /// **'No balances yet.'**
  String get noBalancesYet;

  /// No description provided for @noChangesToSave.
  ///
  /// In en, this message translates to:
  /// **'No changes to save.'**
  String get noChangesToSave;

  /// No description provided for @noDirectExpenseLink.
  ///
  /// In en, this message translates to:
  /// **'No direct single-expense link found. This settlement is calculated from full trip balance.'**
  String get noDirectExpenseLink;

  /// No description provided for @noExpenseImpactForMember.
  ///
  /// In en, this message translates to:
  /// **'No expense impact for this member.'**
  String get noExpenseImpactForMember;

  /// No description provided for @noExpensesByUserYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses for {name} yet.'**
  String noExpensesByUserYet(Object name);

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet.'**
  String get noExpensesYet;

  /// No description provided for @noExtraUsersToAdd.
  ///
  /// In en, this message translates to:
  /// **'No extra users to add.'**
  String get noExtraUsersToAdd;

  /// No description provided for @noInternetDeleteQueued.
  ///
  /// In en, this message translates to:
  /// **'No internet. Delete queued.'**
  String get noInternetDeleteQueued;

  /// No description provided for @noInternetExpenseQueued.
  ///
  /// In en, this message translates to:
  /// **'No internet. Expense queued.'**
  String get noInternetExpenseQueued;

  /// No description provided for @noInternetUpdateQueued.
  ///
  /// In en, this message translates to:
  /// **'No internet. Update queued.'**
  String get noInternetUpdateQueued;

  /// No description provided for @noMatchingRows.
  ///
  /// In en, this message translates to:
  /// **'No matching rows.'**
  String get noMatchingRows;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get noMembersFound;

  /// No description provided for @noNewMembersAdded.
  ///
  /// In en, this message translates to:
  /// **'No new members were added.'**
  String get noNewMembersAdded;

  /// No description provided for @noNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get noNotePlaceholder;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @noParticipantData.
  ///
  /// In en, this message translates to:
  /// **'No participant data.'**
  String get noParticipantData;

  /// No description provided for @noParticipantsSelected.
  ///
  /// In en, this message translates to:
  /// **'No participants selected.'**
  String get noParticipantsSelected;

  /// No description provided for @noPaymentRowsInTrip.
  ///
  /// In en, this message translates to:
  /// **'No payment rows in this trip.'**
  String get noPaymentRowsInTrip;

  /// No description provided for @noPaymentsNeeded.
  ///
  /// In en, this message translates to:
  /// **'No payments needed.'**
  String get noPaymentsNeeded;

  /// No description provided for @noPicksYet.
  ///
  /// In en, this message translates to:
  /// **'No picks yet.'**
  String get noPicksYet;

  /// No description provided for @noSettlementActivityForMember.
  ///
  /// In en, this message translates to:
  /// **'No settlement activity for this member.'**
  String get noSettlementActivityForMember;

  /// No description provided for @noSettlementRowsYet.
  ///
  /// In en, this message translates to:
  /// **'No settlement rows yet.'**
  String get noSettlementRowsYet;

  /// No description provided for @noSettlements.
  ///
  /// In en, this message translates to:
  /// **'No settlements'**
  String get noSettlements;

  /// No description provided for @noTransferNeededForFilter.
  ///
  /// In en, this message translates to:
  /// **'No transfer needed for selected filter.'**
  String get noTransferNeededForFilter;

  /// No description provided for @noTransferRowsToShow.
  ///
  /// In en, this message translates to:
  /// **'No transfer rows to show.'**
  String get noTransferRowsToShow;

  /// No description provided for @noTripDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'No trip data loaded.'**
  String get noTripDataLoaded;

  /// No description provided for @noTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No trips yet.'**
  String get noTripsYet;

  /// No description provided for @noUsersFoundYet.
  ///
  /// In en, this message translates to:
  /// **'No users found yet.'**
  String get noUsersFoundYet;

  /// No description provided for @notSetValue.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetValue;

  /// No description provided for @notYetConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not yet confirmed'**
  String get notYetConfirmedTitle;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Dinner, taxi, tickets...'**
  String get noteHint;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @noteMustBeMaxChars.
  ///
  /// In en, this message translates to:
  /// **'Note must be at most {max} chars.'**
  String noteMustBeMaxChars(Object max);

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @offlineQueuePendingChanges.
  ///
  /// In en, this message translates to:
  /// **'Offline queue: {count, plural, one{{count} pending change} other{{count} pending changes}}'**
  String offlineQueuePendingChanges(num count);

  /// No description provided for @offlineQueueStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline queue'**
  String get offlineQueueStatus;

  /// No description provided for @offlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineStatus;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatus;

  /// No description provided for @onlyCreatorCanFinishTrip.
  ///
  /// In en, this message translates to:
  /// **'Only trip creator can finish the trip.'**
  String get onlyCreatorCanFinishTrip;

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLabel;

  /// No description provided for @openReceiptAction.
  ///
  /// In en, this message translates to:
  /// **'Open receipt'**
  String get openReceiptAction;

  /// No description provided for @openSettlements.
  ///
  /// In en, this message translates to:
  /// **'Open settlements'**
  String get openSettlements;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @owesLabel.
  ///
  /// In en, this message translates to:
  /// **'Owes'**
  String get owesLabel;

  /// No description provided for @paidByLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paidByLabel;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @paidOwesLine.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid}  -  Owes {owes}'**
  String paidOwesLine(Object owes, Object paid);

  /// No description provided for @participantsEmptyMeansAll.
  ///
  /// In en, this message translates to:
  /// **'Participants (empty = all members)'**
  String get participantsEmptyMeansAll;

  /// No description provided for @participantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participantsTitle;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordComplexityHelper.
  ///
  /// In en, this message translates to:
  /// **'Use at least 1 uppercase letter, 1 number and 1 symbol.'**
  String get passwordComplexityHelper;

  /// No description provided for @passwordComplexityValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must include 1 uppercase letter, 1 number and 1 symbol.'**
  String get passwordComplexityValidation;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMinLength;

  /// No description provided for @passwordMinLengthShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLengthShort;

  /// No description provided for @passwordResetComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password reset coming soon.'**
  String get passwordResetComingSoon;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @payerName.
  ///
  /// In en, this message translates to:
  /// **'{name} (payer)'**
  String payerName(Object name);

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @pendingPaymentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payments still waiting for full confirmation.'**
  String get pendingPaymentsSubtitle;

  /// No description provided for @percentLabel.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get percentLabel;

  /// No description provided for @percentSplitMustBe100.
  ///
  /// In en, this message translates to:
  /// **'Percent split must sum to exactly 100%.'**
  String get percentSplitMustBe100;

  /// No description provided for @percentWithValue.
  ///
  /// In en, this message translates to:
  /// **'{value}'**
  String percentWithValue(Object value);

  /// No description provided for @percentagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Percentages'**
  String get percentagesLabel;

  /// No description provided for @pickAtLeastOneParticipant.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one participant.'**
  String get pickAtLeastOneParticipant;

  /// No description provided for @pickMembersGenerateTurn.
  ///
  /// In en, this message translates to:
  /// **'Pick members and generate a turn.'**
  String get pickMembersGenerateTurn;

  /// No description provided for @pickedCycleCompleted.
  ///
  /// In en, this message translates to:
  /// **'{name} picked. Cycle completed.'**
  String pickedCycleCompleted(Object name);

  /// No description provided for @pickedUser.
  ///
  /// In en, this message translates to:
  /// **'{name} picked.'**
  String pickedUser(Object name);

  /// No description provided for @profileRefreshCachedData.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh profile. Showing cached data.'**
  String get profileRefreshCachedData;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @uploadAvatarAction.
  ///
  /// In en, this message translates to:
  /// **'Upload avatar'**
  String get uploadAvatarAction;

  /// No description provided for @removeAvatarAction.
  ///
  /// In en, this message translates to:
  /// **'Remove avatar'**
  String get removeAvatarAction;

  /// No description provided for @avatarUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated.'**
  String get avatarUpdatedMessage;

  /// No description provided for @avatarRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Avatar removed.'**
  String get avatarRemovedMessage;

  /// No description provided for @avatarFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Avatar file is too large (max 5 MB).'**
  String get avatarFileTooLarge;

  /// No description provided for @avatarPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load avatar image.'**
  String get avatarPickFailed;

  /// No description provided for @queueAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get queueAddExpense;

  /// No description provided for @queueAddExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Queued: add expense {amount}'**
  String queueAddExpenseAmount(Object amount);

  /// No description provided for @queueDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get queueDeleteExpense;

  /// No description provided for @queueDeleteExpenseWithId.
  ///
  /// In en, this message translates to:
  /// **'Queued: delete expense #{id}'**
  String queueDeleteExpenseWithId(Object id);

  /// No description provided for @queuePendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Queue pending'**
  String get queuePendingStatus;

  /// No description provided for @queueUpdateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update expense'**
  String get queueUpdateExpense;

  /// No description provided for @queueUpdateExpenseWithId.
  ///
  /// In en, this message translates to:
  /// **'Queued: update expense #{id}'**
  String queueUpdateExpenseWithId(Object id);

  /// No description provided for @queuedChange.
  ///
  /// In en, this message translates to:
  /// **'Queued change'**
  String get queuedChange;

  /// No description provided for @queuedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Queued changes ({count})'**
  String queuedChangesTitle(Object count);

  /// No description provided for @queuedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Queued ({count})'**
  String queuedCountLabel(Object count);

  /// No description provided for @randomCycleDrawLeft.
  ///
  /// In en, this message translates to:
  /// **'Cycle {cycleNo}, draw {drawNo} - {remaining} left'**
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining);

  /// No description provided for @receiptFallbackName.
  ///
  /// In en, this message translates to:
  /// **'receipt'**
  String get receiptFallbackName;

  /// No description provided for @receiptLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Receipt link is invalid.'**
  String get receiptLinkInvalid;

  /// No description provided for @receiptOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt (optional)'**
  String get receiptOptionalLabel;

  /// No description provided for @recentPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent picks'**
  String get recentPicksTitle;

  /// No description provided for @reloadProfile.
  ///
  /// In en, this message translates to:
  /// **'Reload profile'**
  String get reloadProfile;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @removeCurrentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Remove current receipt'**
  String get removeCurrentReceipt;

  /// No description provided for @repeatNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatNewPasswordLabel;

  /// No description provided for @repeatPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPasswordLabel;

  /// No description provided for @requestFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Request failed. Try again.'**
  String get requestFailedTryAgain;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @rowsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get rowsLabel;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @saveCredentialsButton.
  ///
  /// In en, this message translates to:
  /// **'Save credentials'**
  String get saveCredentialsButton;

  /// No description provided for @saveProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfileButton;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search people by name or email'**
  String get searchUsersHint;

  /// No description provided for @selectedPeopleLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected people'**
  String get selectedPeopleLabel;

  /// No description provided for @noSearchMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching users found.'**
  String get noSearchMatches;

  /// No description provided for @savingButton.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingButton;

  /// No description provided for @selectAtLeastTwoMembers.
  ///
  /// In en, this message translates to:
  /// **'Select at least two members.'**
  String get selectAtLeastTwoMembers;

  /// No description provided for @selectMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Select members'**
  String get selectMembersHint;

  /// No description provided for @selectedFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String selectedFileLabel(Object name);

  /// No description provided for @selectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedLabel;

  /// No description provided for @selectedUserFallback.
  ///
  /// In en, this message translates to:
  /// **'Selected user'**
  String get selectedUserFallback;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settleUpAction.
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get settleUpAction;

  /// No description provided for @settledLabel.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settledLabel;

  /// No description provided for @settledStatus.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settledStatus;

  /// No description provided for @settlementActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfers linked to this member.'**
  String get settlementActivitySubtitle;

  /// No description provided for @settlementActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement activity'**
  String get settlementActivityTitle;

  /// No description provided for @settlementCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement completed'**
  String get settlementCompletedTitle;

  /// No description provided for @settlementConfirmedProgress.
  ///
  /// In en, this message translates to:
  /// **'{confirmed}/{total} confirmed'**
  String settlementConfirmedProgress(Object confirmed, Object total);

  /// No description provided for @settlementCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} settlements'**
  String settlementCountLabel(Object count);

  /// No description provided for @settlementImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement impact'**
  String get settlementImpactTitle;

  /// No description provided for @settlementImpactWithFilter.
  ///
  /// In en, this message translates to:
  /// **'Settlement impact: {name}'**
  String settlementImpactWithFilter(Object name);

  /// No description provided for @settlementInProgress.
  ///
  /// In en, this message translates to:
  /// **'Settlement in progress'**
  String get settlementInProgress;

  /// No description provided for @settlementInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement in progress'**
  String get settlementInProgressTitle;

  /// No description provided for @settlementLabel.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get settlementLabel;

  /// No description provided for @settlementOverviewArchivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trip archived. All settlements completed.'**
  String get settlementOverviewArchivedSubtitle;

  /// No description provided for @settlementOverviewInProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track settlement confirmations.'**
  String get settlementOverviewInProgressSubtitle;

  /// No description provided for @settlementOverviewPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview transfers for when trip finishes.'**
  String get settlementOverviewPreviewSubtitle;

  /// No description provided for @settlementPreview.
  ///
  /// In en, this message translates to:
  /// **'Settlement preview'**
  String get settlementPreview;

  /// No description provided for @settlementPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement preview'**
  String get settlementPreviewTitle;

  /// No description provided for @settlementProgressTripArchived.
  ///
  /// In en, this message translates to:
  /// **'Trip archived'**
  String get settlementProgressTripArchived;

  /// No description provided for @settlementWithId.
  ///
  /// In en, this message translates to:
  /// **'Settlement #{id}'**
  String settlementWithId(Object id);

  /// No description provided for @settlements.
  ///
  /// In en, this message translates to:
  /// **'Settlements'**
  String get settlements;

  /// No description provided for @settlementsAlreadyCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Settlements already completed.'**
  String get settlementsAlreadyCompletedSubtitle;

  /// No description provided for @settlementsDone.
  ///
  /// In en, this message translates to:
  /// **'Settlements done'**
  String get settlementsDone;

  /// No description provided for @settlingStatus.
  ///
  /// In en, this message translates to:
  /// **'Settling'**
  String get settlingStatus;

  /// No description provided for @shareUnit.
  ///
  /// In en, this message translates to:
  /// **'share'**
  String get shareUnit;

  /// No description provided for @sharesLabel.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get sharesLabel;

  /// No description provided for @sharesMustBePositiveIntegers.
  ///
  /// In en, this message translates to:
  /// **'Shares must be positive whole numbers.'**
  String get sharesMustBePositiveIntegers;

  /// No description provided for @sharesWithValue.
  ///
  /// In en, this message translates to:
  /// **'Shares: {value}'**
  String sharesWithValue(Object value);

  /// No description provided for @showActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'Show active trips'**
  String get showActiveTrips;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpButton;

  /// No description provided for @splitBreakdownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How the expense is split'**
  String get splitBreakdownSubtitle;

  /// No description provided for @splitBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Split breakdown'**
  String get splitBreakdownTitle;

  /// No description provided for @splitHintEqual.
  ///
  /// In en, this message translates to:
  /// **'Split equally between selected participants.'**
  String get splitHintEqual;

  /// No description provided for @splitHintExact.
  ///
  /// In en, this message translates to:
  /// **'Enter exact amount for each participant. Sum must match total.'**
  String get splitHintExact;

  /// No description provided for @splitHintPercent.
  ///
  /// In en, this message translates to:
  /// **'Enter percentage for each participant. Sum must be 100%.'**
  String get splitHintPercent;

  /// No description provided for @splitHintShares.
  ///
  /// In en, this message translates to:
  /// **'Enter share units (1, 2, 3...). Cost is split proportionally.'**
  String get splitHintShares;

  /// No description provided for @splitLabel.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitLabel;

  /// No description provided for @splitLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Split: {value}'**
  String splitLabelValue(Object value);

  /// No description provided for @splitModeEqual.
  ///
  /// In en, this message translates to:
  /// **'Equal split ({target})'**
  String splitModeEqual(Object target);

  /// No description provided for @splitModeExact.
  ///
  /// In en, this message translates to:
  /// **'Exact amounts ({target})'**
  String splitModeExact(Object target);

  /// No description provided for @splitModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Split mode'**
  String get splitModeLabel;

  /// No description provided for @splitModePercent.
  ///
  /// In en, this message translates to:
  /// **'Percentages ({target})'**
  String splitModePercent(Object target);

  /// No description provided for @splitModeShares.
  ///
  /// In en, this message translates to:
  /// **'Shares ({target})'**
  String splitModeShares(Object target);

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get statusSuggested;

  /// No description provided for @statusWithValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusWithValue(Object status);

  /// No description provided for @suggestedTransferDirections.
  ///
  /// In en, this message translates to:
  /// **'Suggested transfer directions'**
  String get suggestedTransferDirections;

  /// No description provided for @suggestedTransferFromExpense.
  ///
  /// In en, this message translates to:
  /// **'Suggested transfer from expense'**
  String get suggestedTransferFromExpense;

  /// No description provided for @suggestedTransferRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} suggested transfer row} other{{count} suggested transfer rows}}'**
  String suggestedTransferRows(num count);

  /// No description provided for @suggestedTransfersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expected payer -> receiver rows.'**
  String get suggestedTransfersSubtitle;

  /// No description provided for @suggestedTransfersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested transfers'**
  String get suggestedTransfersTitle;

  /// No description provided for @summarySettledUp.
  ///
  /// In en, this message translates to:
  /// **'Settled up'**
  String get summarySettledUp;

  /// No description provided for @summaryYouAreOwed.
  ///
  /// In en, this message translates to:
  /// **'They owe you'**
  String get summaryYouAreOwed;

  /// No description provided for @summaryYouOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get summaryYouOwe;

  /// No description provided for @syncAction.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncAction;

  /// No description provided for @syncNowAction.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNowAction;

  /// No description provided for @syncingStatus.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncingStatus;

  /// No description provided for @tapToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get tapToViewDetails;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soft dark (not pure black)'**
  String get themeModeDarkSubtitle;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use device appearance'**
  String get themeModeSystemSubtitle;

  /// No description provided for @toDirection.
  ///
  /// In en, this message translates to:
  /// **'To {name}'**
  String toDirection(Object name);

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @travelerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get travelerFallbackName;

  /// No description provided for @tripAlreadyClosed.
  ///
  /// In en, this message translates to:
  /// **'Trip already closed.'**
  String get tripAlreadyClosed;

  /// No description provided for @tripArchivedReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Trip is archived. Read-only mode.'**
  String get tripArchivedReadOnly;

  /// No description provided for @tripClosedExpenseEditingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Trip is closed. Expense editing is disabled.'**
  String get tripClosedExpenseEditingDisabled;

  /// No description provided for @tripClosedExpensesReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Trip is closed. Expenses are read-only.'**
  String get tripClosedExpensesReadOnly;

  /// No description provided for @tripClosedRandomDisabled.
  ///
  /// In en, this message translates to:
  /// **'Trip is closed. Random draw is disabled.'**
  String get tripClosedRandomDisabled;

  /// No description provided for @tripCreated.
  ///
  /// In en, this message translates to:
  /// **'Trip \"{name}\" created.'**
  String tripCreated(Object name);

  /// No description provided for @tripFinished.
  ///
  /// In en, this message translates to:
  /// **'Trip finished.'**
  String get tripFinished;

  /// No description provided for @tripFinishedCompleteSettlements.
  ///
  /// In en, this message translates to:
  /// **'Trip is finished. Complete settlements.'**
  String get tripFinishedCompleteSettlements;

  /// No description provided for @tripFinishedSettlementStarted.
  ///
  /// In en, this message translates to:
  /// **'Trip finished. Settlement started.'**
  String get tripFinishedSettlementStarted;

  /// No description provided for @tripFullySettledArchived.
  ///
  /// In en, this message translates to:
  /// **'Trip fully settled and archived.'**
  String get tripFullySettledArchived;

  /// No description provided for @tripNameHint.
  ///
  /// In en, this message translates to:
  /// **'Austria ski trip'**
  String get tripNameHint;

  /// No description provided for @tripNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip name'**
  String get tripNameLabel;

  /// No description provided for @tripNameLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Trip name must be at least 2 characters.'**
  String get tripNameLengthValidation;

  /// No description provided for @tripSnapshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip snapshot'**
  String get tripSnapshotTitle;

  /// No description provided for @tripTitleShort.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get tripTitleShort;

  /// No description provided for @tripStatusWithValue.
  ///
  /// In en, this message translates to:
  /// **'Trip status: {status}'**
  String tripStatusWithValue(Object status);

  /// No description provided for @tripWithId.
  ///
  /// In en, this message translates to:
  /// **'Trip #{id}'**
  String tripWithId(Object id);

  /// No description provided for @unexpectedErrorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error loading profile'**
  String get unexpectedErrorLoadingProfile;

  /// No description provided for @unexpectedErrorLoadingTripData.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error loading trip data'**
  String get unexpectedErrorLoadingTripData;

  /// No description provided for @unexpectedErrorLoadingTrips.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error loading trips'**
  String get unexpectedErrorLoadingTrips;

  /// No description provided for @unexpectedErrorSavingChanges.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error saving changes'**
  String get unexpectedErrorSavingChanges;

  /// No description provided for @unexpectedErrorSavingCredentials.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error saving credentials'**
  String get unexpectedErrorSavingCredentials;

  /// No description provided for @unexpectedErrorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error updating profile'**
  String get unexpectedErrorUpdatingProfile;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @unknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLabel;

  /// No description provided for @unreadLabel.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unreadLabel;

  /// No description provided for @unreadUpdates.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} unread update} other{{count} unread updates}}'**
  String unreadUpdates(num count);

  /// No description provided for @missingTripRouteArgument.
  ///
  /// In en, this message translates to:
  /// **'Missing trip route argument.'**
  String get missingTripRouteArgument;

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID: {id}'**
  String userIdLabel(Object id);

  /// No description provided for @userPaidOwesNetLine.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid}  -  Owes {owes}  -  Net {net}'**
  String userPaidOwesNetLine(Object net, Object owes, Object paid);

  /// No description provided for @userWithId.
  ///
  /// In en, this message translates to:
  /// **'User {id}'**
  String userWithId(Object id);

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @viewAllTrips.
  ///
  /// In en, this message translates to:
  /// **'View all trips'**
  String get viewAllTrips;

  /// No description provided for @viewByPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'View by person'**
  String get viewByPersonTitle;

  /// No description provided for @whoOwesWhatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who paid and who owes.'**
  String get whoOwesWhatSubtitle;

  /// No description provided for @whoOwesWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'Who owes what'**
  String get whoOwesWhatTitle;

  /// No description provided for @whoOwesWhatWithFilter.
  ///
  /// In en, this message translates to:
  /// **'Who owes what: {name}'**
  String whoOwesWhatWithFilter(Object name);

  /// No description provided for @whyPaymentExistsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expense rows contributing to this transfer.'**
  String get whyPaymentExistsSubtitle;

  /// No description provided for @whyPaymentExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this payment exists'**
  String get whyPaymentExistsTitle;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @youSettledForExpense.
  ///
  /// In en, this message translates to:
  /// **'You settled for this expense.'**
  String get youSettledForExpense;

  /// No description provided for @youShouldPay.
  ///
  /// In en, this message translates to:
  /// **'You should pay {amount}'**
  String youShouldPay(Object amount);

  /// No description provided for @youShouldReceive.
  ///
  /// In en, this message translates to:
  /// **'You should receive {amount}'**
  String youShouldReceive(Object amount);

  /// No description provided for @yourShare.
  ///
  /// In en, this message translates to:
  /// **'Your share'**
  String get yourShare;

  /// No description provided for @yourTrips.
  ///
  /// In en, this message translates to:
  /// **'Your trips'**
  String get yourTrips;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'lv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'lv': return AppLocalizationsLv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
