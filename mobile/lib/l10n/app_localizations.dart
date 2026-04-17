import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
    Locale('es'),
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
  /// **'Finish and start settlements'**
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

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a password reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'If an account with this email exists, we have sent a password reset link.'**
  String get forgotPasswordSuccessMessage;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

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

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

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
  /// **'Analytics'**
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

  /// No description provided for @notificationFriendInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend invite'**
  String get notificationFriendInviteTitle;

  /// No description provided for @notificationFriendInviteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a friend invite.'**
  String notificationFriendInviteBody(Object name);

  /// No description provided for @notificationFriendInviteBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'You received a friend invite.'**
  String get notificationFriendInviteBodyGeneric;

  /// No description provided for @notificationFriendInviteAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite accepted'**
  String get notificationFriendInviteAcceptedTitle;

  /// No description provided for @notificationFriendInviteAcceptedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} accepted your friend invite.'**
  String notificationFriendInviteAcceptedBody(Object name);

  /// No description provided for @notificationFriendInviteAcceptedBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Your friend invite was accepted.'**
  String get notificationFriendInviteAcceptedBodyGeneric;

  /// No description provided for @notificationFriendInviteRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite declined'**
  String get notificationFriendInviteRejectedTitle;

  /// No description provided for @notificationFriendInviteRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} declined your friend invite.'**
  String notificationFriendInviteRejectedBody(Object name);

  /// No description provided for @notificationFriendInviteRejectedBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Your friend invite was declined.'**
  String get notificationFriendInviteRejectedBodyGeneric;

  /// No description provided for @notificationTripAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Added to trip'**
  String get notificationTripAddedTitle;

  /// No description provided for @notificationTripAddedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} added you to trip \"{trip}\".'**
  String notificationTripAddedBody(Object name, Object trip);

  /// No description provided for @notificationTripAddedBodyNoActor.
  ///
  /// In en, this message translates to:
  /// **'You were added to trip \"{trip}\".'**
  String notificationTripAddedBodyNoActor(Object trip);

  /// No description provided for @notificationTripAddedBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'You were added to a trip.'**
  String get notificationTripAddedBodyGeneric;

  /// No description provided for @notificationExpenseAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense added'**
  String get notificationExpenseAddedTitle;

  /// No description provided for @notificationExpenseAddedBodyWithTrip.
  ///
  /// In en, this message translates to:
  /// **'{name} added an expense of {amount} in \"{trip}\".'**
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip);

  /// No description provided for @notificationExpenseAddedBodyWithNote.
  ///
  /// In en, this message translates to:
  /// **'{name} added an expense of {amount}: {note}'**
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note);

  /// No description provided for @notificationExpenseAddedBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'A new expense was added.'**
  String get notificationExpenseAddedBodyGeneric;

  /// No description provided for @notificationTripFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip finished'**
  String get notificationTripFinishedTitle;

  /// No description provided for @notificationTripFinishedBodySettlementsReady.
  ///
  /// In en, this message translates to:
  /// **'{name} finished \"{trip}\". Settlements are ready.'**
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip);

  /// No description provided for @notificationTripFinishedBodyArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} finished \"{trip}\". Trip is archived.'**
  String notificationTripFinishedBodyArchived(Object name, Object trip);

  /// No description provided for @notificationTripFinishedBodyNoActor.
  ///
  /// In en, this message translates to:
  /// **'\"{trip}\" was finished.'**
  String notificationTripFinishedBodyNoActor(Object trip);

  /// No description provided for @notificationTripFinishedBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Trip status was updated.'**
  String get notificationTripFinishedBodyGeneric;

  /// No description provided for @notificationMemberReadyToSettleTitle.
  ///
  /// In en, this message translates to:
  /// **'Member marked ready'**
  String get notificationMemberReadyToSettleTitle;

  /// No description provided for @notificationMemberReadyToSettleBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is ready to settle in \"{trip}\".'**
  String notificationMemberReadyToSettleBody(Object name, Object trip);

  /// No description provided for @notificationMemberReadyToSettleBodyNoActor.
  ///
  /// In en, this message translates to:
  /// **'A member is ready to settle in \"{trip}\".'**
  String notificationMemberReadyToSettleBodyNoActor(Object trip);

  /// No description provided for @notificationMemberReadyToSettleBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'A member is ready to settle.'**
  String get notificationMemberReadyToSettleBodyGeneric;

  /// No description provided for @notificationTripReadyToSettleTitle.
  ///
  /// In en, this message translates to:
  /// **'All members are ready'**
  String get notificationTripReadyToSettleTitle;

  /// No description provided for @notificationTripReadyToSettleBody.
  ///
  /// In en, this message translates to:
  /// **'All members marked ready in \"{trip}\". You can start settlements.'**
  String notificationTripReadyToSettleBody(Object trip);

  /// No description provided for @notificationTripReadyToSettleBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'All members are ready. You can start settlements.'**
  String get notificationTripReadyToSettleBodyGeneric;

  /// No description provided for @notificationSettlementReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Settlement reminder'**
  String get notificationSettlementReminderTitle;

  /// No description provided for @notificationSettlementReminderBodyMarkSent.
  ///
  /// In en, this message translates to:
  /// **'{actor} reminded {target} to mark {amount} as sent.'**
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target);

  /// No description provided for @notificationSettlementReminderBodyConfirm.
  ///
  /// In en, this message translates to:
  /// **'{actor} reminded {target} to confirm receiving {amount}.'**
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target);

  /// No description provided for @notificationSettlementReminderBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'You received a settlement reminder.'**
  String get notificationSettlementReminderBodyGeneric;

  /// No description provided for @notificationPaymentReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment reminder'**
  String get notificationPaymentReminderTitle;

  /// No description provided for @notificationPaymentReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder: please mark {amount} as sent to {target} in \"{trip}\".'**
  String notificationPaymentReminderBody(Object amount, Object target, Object trip);

  /// No description provided for @notificationPaymentReminderBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Reminder: please mark the payment as sent.'**
  String get notificationPaymentReminderBodyGeneric;

  /// No description provided for @notificationConfirmationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation reminder'**
  String get notificationConfirmationReminderTitle;

  /// No description provided for @notificationConfirmationReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder: please confirm receiving {amount} from {payer} in \"{trip}\".'**
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip);

  /// No description provided for @notificationConfirmationReminderBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Reminder: please confirm receiving the payment.'**
  String get notificationConfirmationReminderBodyGeneric;

  /// No description provided for @notificationSettlementSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer marked as sent'**
  String get notificationSettlementSentTitle;

  /// No description provided for @notificationSettlementSentBody.
  ///
  /// In en, this message translates to:
  /// **'{name} marked {amount} as sent to you.'**
  String notificationSettlementSentBody(Object amount, Object name);

  /// No description provided for @notificationSettlementSentBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'A transfer was marked as sent.'**
  String get notificationSettlementSentBodyGeneric;

  /// No description provided for @notificationSettlementConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer confirmed'**
  String get notificationSettlementConfirmedTitle;

  /// No description provided for @notificationSettlementConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} confirmed receiving {amount} from you.'**
  String notificationSettlementConfirmedBody(Object amount, Object name);

  /// No description provided for @notificationSettlementConfirmedBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'A transfer was confirmed.'**
  String get notificationSettlementConfirmedBodyGeneric;

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

  /// No description provided for @takePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takePhotoAction;

  /// No description provided for @chooseFromLibraryAction.
  ///
  /// In en, this message translates to:
  /// **'Choose from Library'**
  String get chooseFromLibraryAction;

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

  /// No description provided for @backToLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLoginAction;

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

  /// No description provided for @sendResetLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLinkButton;

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

  /// No description provided for @authIntroSplitSmarter.
  ///
  /// In en, this message translates to:
  /// **'Split smarter.'**
  String get authIntroSplitSmarter;

  /// No description provided for @authIntroTravelFree.
  ///
  /// In en, this message translates to:
  /// **'Travel free.'**
  String get authIntroTravelFree;

  /// No description provided for @authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo.
  ///
  /// In en, this message translates to:
  /// **'Track shared costs across currencies and settle up instantly - no awkward IOUs.'**
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo;

  /// No description provided for @authIntroPlanTogether.
  ///
  /// In en, this message translates to:
  /// **'Plan together.'**
  String get authIntroPlanTogether;

  /// No description provided for @authIntroPayClearly.
  ///
  /// In en, this message translates to:
  /// **'Pay clearly.'**
  String get authIntroPayClearly;

  /// No description provided for @authIntroCreateTripsSecondsAddFriendsKeepEveryExpense.
  ///
  /// In en, this message translates to:
  /// **'Create trips in seconds, add friends, and keep every expense transparent for everyone.'**
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense;

  /// No description provided for @authIntroSettleFast.
  ///
  /// In en, this message translates to:
  /// **'Settle fast.'**
  String get authIntroSettleFast;

  /// No description provided for @authIntroStayFriends.
  ///
  /// In en, this message translates to:
  /// **'Stay friends.'**
  String get authIntroStayFriends;

  /// No description provided for @authIntroFromSharedDinnersFullTripsSplytoKeepsBalances.
  ///
  /// In en, this message translates to:
  /// **'From shared dinners to full trips, Splyto keeps balances fair and stress-free.'**
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances;

  /// No description provided for @authIntroAppleSignFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again.'**
  String get authIntroAppleSignFailedPleaseTryAgain;

  /// No description provided for @authIntroGoogleSignFailedPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authIntroGoogleSignFailedPleaseTryAgain;

  /// No description provided for @authIntroCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account.'**
  String get authIntroCreateAccount;

  /// No description provided for @authIntroChooseSign.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to sign up.'**
  String get authIntroChooseSign;

  /// No description provided for @authIntroContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authIntroContinueGoogle;

  /// No description provided for @authIntroContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authIntroContinueApple;

  /// No description provided for @authIntroBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authIntroBack;

  /// No description provided for @authIntroSplitSettled.
  ///
  /// In en, this message translates to:
  /// **'Split settled'**
  String get authIntroSplitSettled;

  /// No description provided for @authIntroParis3Friends.
  ///
  /// In en, this message translates to:
  /// **'Paris · 3 friends'**
  String get authIntroParis3Friends;

  /// No description provided for @authIntroGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get authIntroGetStarted;

  /// No description provided for @authIntroAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authIntroAlreadyHaveAccount;

  /// No description provided for @authIntroSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authIntroSignIn;

  /// No description provided for @authIntroSignUpWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign up with email'**
  String get authIntroSignUpWithEmail;

  /// No description provided for @authIntroOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authIntroOr;

  /// No description provided for @authGoogleSignDidNotReturnIdToken.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in did not return an id token.'**
  String get authGoogleSignDidNotReturnIdToken;

  /// No description provided for @authAppleSignAvailableIosDevices.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in is available on iOS devices.'**
  String get authAppleSignAvailableIosDevices;

  /// No description provided for @authAppleSignNotAvailableDevice.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in is not available on this device.'**
  String get authAppleSignNotAvailableDevice;

  /// No description provided for @authAppleSignDidNotReturnIdentityToken.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in did not return an identity token.'**
  String get authAppleSignDidNotReturnIdentityToken;

  /// No description provided for @authAccountDeactivatedEnterEmailRequestReactivationLink.
  ///
  /// In en, this message translates to:
  /// **'Account is deactivated. Enter your email to request a reactivation link.'**
  String get authAccountDeactivatedEnterEmailRequestReactivationLink;

  /// No description provided for @authAccountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Account is deactivated'**
  String get authAccountDeactivated;

  /// No description provided for @authSendReactivationLinkEmail.
  ///
  /// In en, this message translates to:
  /// **'Send a reactivation link to {email}?'**
  String authSendReactivationLinkEmail(Object email);

  /// No description provided for @authCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authCancel;

  /// No description provided for @authSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get authSendLink;

  /// No description provided for @authReactivationLinkSentCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Reactivation link sent. Check your email.'**
  String get authReactivationLinkSentCheckEmail;

  /// No description provided for @authCouldNotSendReactivationLinkPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not send reactivation link. Please try again.'**
  String get authCouldNotSendReactivationLinkPleaseTryAgain;

  /// No description provided for @authEmailNotVerifiedEnterEmailRequestVerificationLink.
  ///
  /// In en, this message translates to:
  /// **'Email is not verified. Enter your email to request verification link.'**
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink;

  /// No description provided for @authEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get authEmailNotVerified;

  /// No description provided for @authSendVerificationLinkEmail.
  ///
  /// In en, this message translates to:
  /// **'Send verification link to {email}?'**
  String authSendVerificationLinkEmail(Object email);

  /// No description provided for @authVerificationLinkSentCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Verification link sent. Check your email.'**
  String get authVerificationLinkSentCheckEmail;

  /// No description provided for @authCouldNotSendVerificationLinkPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not send verification link. Please try again.'**
  String get authCouldNotSendVerificationLinkPleaseTryAgain;

  /// No description provided for @authVerificationEmailSentPleaseVerifyEmailBeforeLogging.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Please verify your email before logging in.'**
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging;

  /// No description provided for @authVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyEmail;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get authEmailLabel;

  /// No description provided for @authClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get authClose;

  /// No description provided for @authResendLink.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get authResendLink;

  /// No description provided for @profileAppSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'APP SETTINGS'**
  String get profileAppSettingsSectionTitle;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileThemeDisplayMode.
  ///
  /// In en, this message translates to:
  /// **'Theme & display mode'**
  String get profileThemeDisplayMode;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileDisplayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display language'**
  String get profileDisplayLanguage;

  /// No description provided for @profileNotificationsSectionHeading.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get profileNotificationsSectionHeading;

  /// No description provided for @profileAppBanners.
  ///
  /// In en, this message translates to:
  /// **'In-app banners'**
  String get profileAppBanners;

  /// No description provided for @profileShowNewNotificationBannersInsideApp.
  ///
  /// In en, this message translates to:
  /// **'Show new notification banners inside app'**
  String get profileShowNewNotificationBannersInsideApp;

  /// No description provided for @profilePushNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get profilePushNotificationsTitle;

  /// No description provided for @profilePhoneNotificationsExpensesFriendsTripsSettlements.
  ///
  /// In en, this message translates to:
  /// **'Phone notifications for expenses, friends, trips and settlements'**
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements;

  /// No description provided for @profileSupportSectionHeading.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get profileSupportSectionHeading;

  /// No description provided for @profileContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get profileContactUs;

  /// No description provided for @profileReportBugSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Report bug / Suggestion'**
  String get profileReportBugSuggestion;

  /// No description provided for @profileRateSplyto.
  ///
  /// In en, this message translates to:
  /// **'Rate Splyto'**
  String get profileRateSplyto;

  /// No description provided for @profileLeaveStoreRating.
  ///
  /// In en, this message translates to:
  /// **'Leave a store rating'**
  String get profileLeaveStoreRating;

  /// No description provided for @profileSecuritySectionHeading.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get profileSecuritySectionHeading;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileUpdateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update account password'**
  String get profileUpdateAccountPassword;

  /// No description provided for @profileDangerZoneSectionHeading.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get profileDangerZoneSectionHeading;

  /// No description provided for @profileDeactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate account'**
  String get profileDeactivateAccount;

  /// No description provided for @profileManageAccountAccess.
  ///
  /// In en, this message translates to:
  /// **'Manage account access'**
  String get profileManageAccountAccess;

  /// No description provided for @profileMadeWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Made with'**
  String get profileMadeWithLabel;

  /// No description provided for @profileStoreRatingActionWillConnectedNextStep.
  ///
  /// In en, this message translates to:
  /// **'Store rating action will be connected in the next step.'**
  String get profileStoreRatingActionWillConnectedNextStep;

  /// No description provided for @profileFailedSaveNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to save notification settings.'**
  String get profileFailedSaveNotificationSettings;

  /// No description provided for @profilePushNotificationsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'PUSH NOTIFICATIONS'**
  String get profilePushNotificationsSectionTitle;

  /// No description provided for @profileExpenseUpdates.
  ///
  /// In en, this message translates to:
  /// **'Expense updates'**
  String get profileExpenseUpdates;

  /// No description provided for @profileExpenseAddedNotificationsPhone.
  ///
  /// In en, this message translates to:
  /// **'Expense added notifications to phone'**
  String get profileExpenseAddedNotificationsPhone;

  /// No description provided for @profileFriendInvites.
  ///
  /// In en, this message translates to:
  /// **'Friend invites'**
  String get profileFriendInvites;

  /// No description provided for @profileFriendRequestResponseNotifications.
  ///
  /// In en, this message translates to:
  /// **'Friend request and response notifications'**
  String get profileFriendRequestResponseNotifications;

  /// No description provided for @profileTripUpdates.
  ///
  /// In en, this message translates to:
  /// **'Trip updates'**
  String get profileTripUpdates;

  /// No description provided for @profileTripLifecycleMemberStatusChanges.
  ///
  /// In en, this message translates to:
  /// **'Trip lifecycle and member status changes'**
  String get profileTripLifecycleMemberStatusChanges;

  /// No description provided for @profileSettlementUpdates.
  ///
  /// In en, this message translates to:
  /// **'Settlement updates'**
  String get profileSettlementUpdates;

  /// No description provided for @profileMarkedSentConfirmedPaymentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Marked sent and confirmed payment updates'**
  String get profileMarkedSentConfirmedPaymentUpdates;

  /// No description provided for @profileScreenshotSizeMust8Mb.
  ///
  /// In en, this message translates to:
  /// **'Screenshot size must be up to 8 MB'**
  String get profileScreenshotSizeMust8Mb;

  /// No description provided for @profileFeedbackSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get profileFeedbackSendTitle;

  /// No description provided for @profileFeedbackTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get profileFeedbackTypeLabel;

  /// No description provided for @profileFeedbackTypeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get profileFeedbackTypeBug;

  /// No description provided for @profileFeedbackTypeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get profileFeedbackTypeSuggestion;

  /// No description provided for @profileDescribeIssueSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Describe issue or suggestion'**
  String get profileDescribeIssueSuggestion;

  /// No description provided for @profilePickingImage.
  ///
  /// In en, this message translates to:
  /// **'Picking image...'**
  String get profilePickingImage;

  /// No description provided for @profileAttachScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Attach screenshot'**
  String get profileAttachScreenshot;

  /// No description provided for @profileChangeScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Change screenshot'**
  String get profileChangeScreenshot;

  /// No description provided for @profileRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get profileRemoveImage;

  /// No description provided for @profileTipAttachScreenshotFasterBugTriage.
  ///
  /// In en, this message translates to:
  /// **'Tip: attach screenshot for faster bug triage'**
  String get profileTipAttachScreenshotFasterBugTriage;

  /// No description provided for @profileAddDetailsAttachScreenshotBeforeSending.
  ///
  /// In en, this message translates to:
  /// **'Add details or attach screenshot before sending'**
  String get profileAddDetailsAttachScreenshotBeforeSending;

  /// No description provided for @profileSendAction.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get profileSendAction;

  /// No description provided for @profileThanksFeedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Feedback sent'**
  String get profileThanksFeedbackSent;

  /// No description provided for @profileFailedSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Failed to send feedback'**
  String get profileFailedSendFeedback;

  /// No description provided for @profileCouldNotOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Could not open website.'**
  String get profileCouldNotOpenWebsite;

  /// No description provided for @profileOpenWebsiteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Open website?'**
  String get profileOpenWebsiteQuestion;

  /// No description provided for @profileOpenPortfolioAction.
  ///
  /// In en, this message translates to:
  /// **'Open portfolio.egm.lv'**
  String get profileOpenPortfolioAction;

  /// No description provided for @profileImageFormatNotSupportedDevicePleaseChooseJpg.
  ///
  /// In en, this message translates to:
  /// **'This image format is not supported on this device. Please choose JPG or PNG.'**
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg;

  /// No description provided for @profileEditSetValidEmailEditProfileChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a valid email in Edit profile before changing password.'**
  String get profileEditSetValidEmailEditProfileChangingPassword;

  /// No description provided for @profileEditDeactivatedReactivationLinkEmailRestoreAccess.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated. Use reactivation link from email to restore access.'**
  String get profileEditDeactivatedReactivationLinkEmailRestoreAccess;

  /// No description provided for @profileEditCouldNotDeactivateTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not deactivate account. Please try again.'**
  String get profileEditCouldNotDeactivateTryAgain;

  /// No description provided for @profileEditDeletionLinkSentEmail.
  ///
  /// In en, this message translates to:
  /// **'Deletion link sent to your email.'**
  String get profileEditDeletionLinkSentEmail;

  /// No description provided for @profileEditCouldNotSendDeletionLinkTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not send deletion link. Please try again.'**
  String get profileEditCouldNotSendDeletionLinkTryAgain;

  /// No description provided for @profileEditEnterCurrentPasswordChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter current password to change email.'**
  String get profileEditEnterCurrentPasswordChangeEmail;

  /// No description provided for @profileEditVerificationWasSentNewEmailSecurityNoticeWas.
  ///
  /// In en, this message translates to:
  /// **'Verification was sent to the new email. Security notice was sent to your current email.'**
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas;

  /// No description provided for @profileEditCouldNotStartEmailChangeRightNowTry.
  ///
  /// In en, this message translates to:
  /// **'Could not start email change right now. Please try again.'**
  String get profileEditCouldNotStartEmailChangeRightNowTry;

  /// No description provided for @profileEditOverviewCurrency.
  ///
  /// In en, this message translates to:
  /// **'Overview currency'**
  String get profileEditOverviewCurrency;

  /// No description provided for @profileEditPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get profileEditPaymentMethod;

  /// No description provided for @profileEditBankTransferRevolutPaypalMe.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer, Revolut, PayPal.me'**
  String get profileEditBankTransferRevolutPaypalMe;

  /// No description provided for @profileEditDeactivateAccessRequestEmailLinkPermanentlyDeletePassword.
  ///
  /// In en, this message translates to:
  /// **'You can deactivate account access or request an email link to permanently delete the account. Password is optional for Google/Apple accounts.'**
  String get profileEditDeactivateAccessRequestEmailLinkPermanentlyDeletePassword;

  /// No description provided for @profileEditEnterPasswordOptionalGoogleApple.
  ///
  /// In en, this message translates to:
  /// **'Enter your password (optional for Google/Apple)'**
  String get profileEditEnterPasswordOptionalGoogleApple;

  /// No description provided for @profileEditSendDeletionLinkEmail.
  ///
  /// In en, this message translates to:
  /// **'Send deletion link to email'**
  String get profileEditSendDeletionLinkEmail;

  /// No description provided for @profileEditBackProfile.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get profileEditBackProfile;

  /// No description provided for @profileEditSetValidEmailProfileChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a valid email in profile before changing password.'**
  String get profileEditSetValidEmailProfileChangingPassword;

  /// No description provided for @profileEditPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get profileEditPasswordUpdated;

  /// No description provided for @profileEditFailedUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password.'**
  String get profileEditFailedUpdatePassword;

  /// No description provided for @profileEditEmail.
  ///
  /// In en, this message translates to:
  /// **'Account: {email}'**
  String profileEditEmail(Object email);

  /// No description provided for @profileEditPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get profileEditPrimary;

  /// No description provided for @profileEditSearchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get profileEditSearchCurrency;

  /// No description provided for @profileEditNoCurrenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get profileEditNoCurrenciesFound;

  /// No description provided for @profileEditOverviewTotalsConvertedCurrency.
  ///
  /// In en, this message translates to:
  /// **'Overview totals are converted to this currency.'**
  String get profileEditOverviewTotalsConvertedCurrency;

  /// No description provided for @profileEditPaymentInfoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment info updated.'**
  String get profileEditPaymentInfoUpdated;

  /// No description provided for @profileEditCouldNotSavePaymentInfoTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not save payment info. Please try again.'**
  String get profileEditCouldNotSavePaymentInfoTryAgain;

  /// No description provided for @profileEditCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileEditCurrentPassword;

  /// No description provided for @profileEditBankTransferIbanSwift.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer (IBAN / SWIFT)'**
  String get profileEditBankTransferIbanSwift;

  /// No description provided for @profileEditIbanSwift.
  ///
  /// In en, this message translates to:
  /// **'IBAN + SWIFT'**
  String get profileEditIbanSwift;

  /// No description provided for @profileEditRevtagRevolutMe.
  ///
  /// In en, this message translates to:
  /// **'Revtag / revolut.me'**
  String get profileEditRevtagRevolutMe;

  /// No description provided for @profileEditPaypalMeLink.
  ///
  /// In en, this message translates to:
  /// **'paypal.me link'**
  String get profileEditPaypalMeLink;

  /// No description provided for @profileEditChoosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get profileEditChoosePaymentMethod;

  /// No description provided for @profileEditTapChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get profileEditTapChange;

  /// No description provided for @profileEditUkTransfersSortCode6DigitsNumber8.
  ///
  /// In en, this message translates to:
  /// **'For UK transfers, sort code must be 6 digits and account number 8 digits.'**
  String get profileEditUkTransfersSortCode6DigitsNumber8;

  /// No description provided for @profileEditPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment info'**
  String get profileEditPaymentInfo;

  /// No description provided for @profileEditSaveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save details'**
  String get profileEditSaveDetails;

  /// No description provided for @profileEditBankRegion.
  ///
  /// In en, this message translates to:
  /// **'Bank region'**
  String get profileEditBankRegion;

  /// No description provided for @profileEditEurope.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get profileEditEurope;

  /// No description provided for @profileEditSortCode.
  ///
  /// In en, this message translates to:
  /// **'Sort code'**
  String get profileEditSortCode;

  /// No description provided for @profileEditExample112233.
  ///
  /// In en, this message translates to:
  /// **'Example: 112233'**
  String get profileEditExample112233;

  /// No description provided for @profileEditNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get profileEditNumber;

  /// No description provided for @profileEdit8Digits.
  ///
  /// In en, this message translates to:
  /// **'8 digits'**
  String get profileEdit8Digits;

  /// No description provided for @profileEditUkDomesticTransfersSortCodeNumber.
  ///
  /// In en, this message translates to:
  /// **'For UK domestic transfers use sort code + account number.'**
  String get profileEditUkDomesticTransfersSortCodeNumber;

  /// No description provided for @profileEditExampleLv80bank0000435195001.
  ///
  /// In en, this message translates to:
  /// **'Example: LV80BANK0000435195001'**
  String get profileEditExampleLv80bank0000435195001;

  /// No description provided for @profileEdit811Chars.
  ///
  /// In en, this message translates to:
  /// **'8 or 11 chars'**
  String get profileEdit811Chars;

  /// No description provided for @profileEditHolderNameTakenProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'Account holder name is taken from profile full name.'**
  String get profileEditHolderNameTakenProfileFullName;

  /// No description provided for @profileEditRevolutMeUsername.
  ///
  /// In en, this message translates to:
  /// **'revolut.me/username'**
  String get profileEditRevolutMeUsername;

  /// No description provided for @profileEditRevtag.
  ///
  /// In en, this message translates to:
  /// **'Revtag'**
  String get profileEditRevtag;

  /// No description provided for @profileEditUsername.
  ///
  /// In en, this message translates to:
  /// **'@username'**
  String get profileEditUsername;

  /// No description provided for @profileEditPaypalMeUsernameUsername.
  ///
  /// In en, this message translates to:
  /// **'paypal.me/username or username'**
  String get profileEditPaypalMeUsernameUsername;

  /// No description provided for @shellTripAlreadyInListOpened.
  ///
  /// In en, this message translates to:
  /// **'Trip already in your list. Opened it for you.'**
  String get shellTripAlreadyInListOpened;

  /// No description provided for @shellJoinedTripFromInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Joined trip from invite link.'**
  String get shellJoinedTripFromInviteLink;

  /// No description provided for @shellFailedToOpenInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to open invite link.'**
  String get shellFailedToOpenInviteLink;

  /// No description provided for @shellTripInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip invite'**
  String get shellTripInviteTitle;

  /// No description provided for @shellNoAction.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get shellNoAction;

  /// No description provided for @shellYesAction.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get shellYesAction;

  /// No description provided for @shellOnlyTripCreatorCanDelete.
  ///
  /// In en, this message translates to:
  /// **'Only trip creator can delete this trip.'**
  String get shellOnlyTripCreatorCanDelete;

  /// No description provided for @shellOnlyActiveTripsCanDelete.
  ///
  /// In en, this message translates to:
  /// **'Only active trips can be deleted.'**
  String get shellOnlyActiveTripsCanDelete;

  /// No description provided for @shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{tripLabel}\"? This is allowed only before any expenses are added.'**
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel);

  /// No description provided for @shellTripDeleted.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted.'**
  String get shellTripDeleted;

  /// No description provided for @shellFailedToDeleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete trip.'**
  String get shellFailedToDeleteTrip;

  /// No description provided for @shellFailedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications.'**
  String get shellFailedToLoadNotifications;

  /// No description provided for @shellNewNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'New notification: {title}'**
  String shellNewNotificationTitle(Object title);

  /// No description provided for @shellFailedToUpdateNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to update notifications.'**
  String get shellFailedToUpdateNotifications;

  /// No description provided for @shellMarkAllAsReadAction.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get shellMarkAllAsReadAction;

  /// No description provided for @shellNewSection.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get shellNewSection;

  /// No description provided for @shellEarlierSection.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get shellEarlierSection;

  /// No description provided for @shellShowMoreEarlierAction.
  ///
  /// In en, this message translates to:
  /// **'Show more earlier'**
  String get shellShowMoreEarlierAction;

  /// No description provided for @shellLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get shellLoadingMore;

  /// No description provided for @shellLoadMoreNotificationsAction.
  ///
  /// In en, this message translates to:
  /// **'Load more notifications'**
  String get shellLoadMoreNotificationsAction;

  /// No description provided for @shellTripNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This trip is no longer available.'**
  String get shellTripNoLongerAvailable;

  /// No description provided for @shellFailedToOpenTrip.
  ///
  /// In en, this message translates to:
  /// **'Failed to open trip.'**
  String get shellFailedToOpenTrip;

  /// No description provided for @shellYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get shellYesterday;

  /// No description provided for @shellInviteAlreadyMemberOpenTripNow.
  ///
  /// In en, this message translates to:
  /// **'You are already a member of \"{tripName}\". Open this trip now?\n\nInvited by: {inviterName}'**
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName);

  /// No description provided for @shellInviteJoinTripQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to join trip \"{tripName}\"?\n\nInvited by: {inviterName}'**
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName);

  /// No description provided for @tripsSelectedImage.
  ///
  /// In en, this message translates to:
  /// **'Selected image: {arg1}'**
  String tripsSelectedImage(Object arg1);

  /// No description provided for @tripsTripImageAlreadySet.
  ///
  /// In en, this message translates to:
  /// **'Trip image already set.'**
  String get tripsTripImageAlreadySet;

  /// No description provided for @tripsTripCreatedButImageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Trip created, but image upload failed.'**
  String get tripsTripCreatedButImageUploadFailed;

  /// No description provided for @tripsTripCreatedButImageUploadFailedWithReason.
  ///
  /// In en, this message translates to:
  /// **'Trip created, but image upload failed: {arg1}'**
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1);

  /// No description provided for @tripsJoinTripViaInvite.
  ///
  /// In en, this message translates to:
  /// **'Join trip via invite'**
  String get tripsJoinTripViaInvite;

  /// No description provided for @tripsTotalTrips.
  ///
  /// In en, this message translates to:
  /// **'Total trips'**
  String get tripsTotalTrips;

  /// No description provided for @tripsTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get tripsTotalSpent;

  /// No description provided for @tripsMixedCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Mixed currencies'**
  String get tripsMixedCurrencies;

  /// No description provided for @tripsShowActive.
  ///
  /// In en, this message translates to:
  /// **'Show active'**
  String get tripsShowActive;

  /// No description provided for @tripsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get tripsSeeAll;

  /// No description provided for @tripsAddNewTrip.
  ///
  /// In en, this message translates to:
  /// **'Add new trip'**
  String get tripsAddNewTrip;

  /// No description provided for @tripsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get tripsLoadMore;

  /// No description provided for @tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{arg1}\"? This is allowed only before any expenses are added.'**
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1);

  /// No description provided for @tripsTripDates.
  ///
  /// In en, this message translates to:
  /// **'Trip dates'**
  String get tripsTripDates;

  /// No description provided for @tripsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get tripsFrom;

  /// No description provided for @tripsSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get tripsSelectDate;

  /// No description provided for @tripsTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get tripsTo;

  /// No description provided for @tripsMainCurrency.
  ///
  /// In en, this message translates to:
  /// **'Main currency'**
  String get tripsMainCurrency;

  /// No description provided for @tripsPleaseSelectTripPeriodFromAndToDates.
  ///
  /// In en, this message translates to:
  /// **'Please select trip period (from and to dates).'**
  String get tripsPleaseSelectTripPeriodFromAndToDates;

  /// No description provided for @tripsTripEndDateMustBeOnOrAfterStartDate.
  ///
  /// In en, this message translates to:
  /// **'Trip end date must be on or after start date.'**
  String get tripsTripEndDateMustBeOnOrAfterStartDate;

  /// No description provided for @tripsTripPeriodFormatIsInvalidPleasePickDatesAgain.
  ///
  /// In en, this message translates to:
  /// **'Trip period format is invalid. Please pick dates again.'**
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain;

  /// No description provided for @tripsYouAreAlreadyAMemberOfThisTrip.
  ///
  /// In en, this message translates to:
  /// **'You are already a member of this trip.'**
  String get tripsYouAreAlreadyAMemberOfThisTrip;

  /// No description provided for @tripsJoinedTripSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Joined trip successfully.'**
  String get tripsJoinedTripSuccessfully;

  /// No description provided for @tripsFailedToJoinTripFromInvite.
  ///
  /// In en, this message translates to:
  /// **'Failed to join trip from invite.'**
  String get tripsFailedToJoinTripFromInvite;

  /// No description provided for @tripsJoinTrip.
  ///
  /// In en, this message translates to:
  /// **'Join trip'**
  String get tripsJoinTrip;

  /// No description provided for @tripsPasteInviteLinkOrInviteToken.
  ///
  /// In en, this message translates to:
  /// **'Paste invite link or invite token.'**
  String get tripsPasteInviteLinkOrInviteToken;

  /// No description provided for @tripsHttpsInviteNorthSeaAbc123def4.
  ///
  /// In en, this message translates to:
  /// **'https://.../?invite=north-sea-abc123def4'**
  String get tripsHttpsInviteNorthSeaAbc123def4;

  /// No description provided for @tripsEnterAValidInviteLinkOrToken.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid invite link or token.'**
  String get tripsEnterAValidInviteLinkOrToken;

  /// No description provided for @tripsClipboardIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty.'**
  String get tripsClipboardIsEmpty;

  /// No description provided for @tripsPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get tripsPaste;

  /// No description provided for @tripsJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get tripsJoin;

  /// No description provided for @workspaceTripMembers.
  ///
  /// In en, this message translates to:
  /// **'Trip members'**
  String get workspaceTripMembers;

  /// No description provided for @workspaceFailedToLoadFriends.
  ///
  /// In en, this message translates to:
  /// **'Failed to load friends.'**
  String get workspaceFailedToLoadFriends;

  /// No description provided for @workspaceFailedToGenerateInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate invite link.'**
  String get workspaceFailedToGenerateInviteLink;

  /// No description provided for @workspaceInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite link'**
  String get workspaceInviteLink;

  /// No description provided for @workspaceGeneratingInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Generating invite link...'**
  String get workspaceGeneratingInviteLink;

  /// No description provided for @workspaceInviteLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Invite link unavailable.'**
  String get workspaceInviteLinkUnavailable;

  /// No description provided for @workspaceCopyInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Copy invite link'**
  String get workspaceCopyInviteLink;

  /// No description provided for @workspaceInviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied.'**
  String get workspaceInviteLinkCopied;

  /// No description provided for @workspaceExpiresUtc.
  ///
  /// In en, this message translates to:
  /// **'Expires: {arg1} UTC'**
  String workspaceExpiresUtc(Object arg1);

  /// No description provided for @workspaceNoFriendsAvailableAddFriendsFirst.
  ///
  /// In en, this message translates to:
  /// **'No friends available. Add friends first.'**
  String get workspaceNoFriendsAvailableAddFriendsFirst;

  /// No description provided for @workspaceSettle.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get workspaceSettle;

  /// No description provided for @workspaceOwesToTheGroup.
  ///
  /// In en, this message translates to:
  /// **'Owes to the group'**
  String get workspaceOwesToTheGroup;

  /// No description provided for @workspaceGetsBackFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Gets back from group'**
  String get workspaceGetsBackFromGroup;

  /// No description provided for @workspaceShowingTop4ByBalanceDifference.
  ///
  /// In en, this message translates to:
  /// **'Showing top 4 by balance difference.'**
  String get workspaceShowingTop4ByBalanceDifference;

  /// No description provided for @workspaceOpenFlow.
  ///
  /// In en, this message translates to:
  /// **'Open flow'**
  String get workspaceOpenFlow;

  /// No description provided for @workspaceFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get workspaceFriend;

  /// No description provided for @workspaceSettlementTransfer.
  ///
  /// In en, this message translates to:
  /// **'Settlement transfer'**
  String get workspaceSettlementTransfer;

  /// No description provided for @workspaceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workspaceCompleted;

  /// No description provided for @workspaceWaitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation'**
  String get workspaceWaitingForConfirmation;

  /// No description provided for @workspaceWaitingForPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get workspaceWaitingForPayment;

  /// No description provided for @workspaceActionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get workspaceActionNeeded;

  /// No description provided for @workspacePaymentSToMarkAsSentToConfirmAsReceived.
  ///
  /// In en, this message translates to:
  /// **'{arg1} payment(s) to mark as sent, {arg2} to confirm as received.'**
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2);

  /// No description provided for @workspaceReadyToSettle.
  ///
  /// In en, this message translates to:
  /// **'Ready to settle'**
  String get workspaceReadyToSettle;

  /// No description provided for @workspaceAllMembersAreReadyYouCanStartSettlements.
  ///
  /// In en, this message translates to:
  /// **'All members are ready. You can start settlements.'**
  String get workspaceAllMembersAreReadyYouCanStartSettlements;

  /// No description provided for @workspaceWaitingForEveryoneToMarkReady.
  ///
  /// In en, this message translates to:
  /// **'Waiting for everyone to mark ready.'**
  String get workspaceWaitingForEveryoneToMarkReady;

  /// No description provided for @workspaceIMReady.
  ///
  /// In en, this message translates to:
  /// **'I\'m ready'**
  String get workspaceIMReady;

  /// No description provided for @workspaceConfirmThatYouAddedAllYourExpenses.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you added all your expenses.'**
  String get workspaceConfirmThatYouAddedAllYourExpenses;

  /// No description provided for @workspaceFinishButtonUnlocksOnceEveryoneMarksReady.
  ///
  /// In en, this message translates to:
  /// **'Finish button unlocks once everyone marks ready.'**
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady;

  /// No description provided for @workspaceGetsBackFromTheGroup.
  ///
  /// In en, this message translates to:
  /// **'Gets back from the group'**
  String get workspaceGetsBackFromTheGroup;

  /// No description provided for @workspaceSettledWithTheGroup.
  ///
  /// In en, this message translates to:
  /// **'Settled with the group'**
  String get workspaceSettledWithTheGroup;

  /// No description provided for @workspaceTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get workspaceTotalPaid;

  /// No description provided for @workspaceTotalOwes.
  ///
  /// In en, this message translates to:
  /// **'Total Owes'**
  String get workspaceTotalOwes;

  /// No description provided for @workspaceTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get workspaceTransactionHistory;

  /// No description provided for @workspaceNoTransactionsYetForThisMember.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet for this member.'**
  String get workspaceNoTransactionsYetForThisMember;

  /// No description provided for @workspaceSettlements.
  ///
  /// In en, this message translates to:
  /// **'Settlements: {arg1}'**
  String workspaceSettlements(Object arg1);

  /// No description provided for @workspaceAllMembersMustMarkReadyBeforeStartingSettlements.
  ///
  /// In en, this message translates to:
  /// **'All members must mark ready before starting settlements.'**
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements;

  /// No description provided for @workspaceYouMarkedYourselfReadyToSettle.
  ///
  /// In en, this message translates to:
  /// **'You marked yourself ready to settle.'**
  String get workspaceYouMarkedYourselfReadyToSettle;

  /// No description provided for @workspaceReadyToSettleMarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Ready-to-settle mark removed.'**
  String get workspaceReadyToSettleMarkRemoved;

  /// No description provided for @workspaceReminderSent.
  ///
  /// In en, this message translates to:
  /// **'Reminder sent.'**
  String get workspaceReminderSent;

  /// No description provided for @workspaceInviteLinkOrAddFromFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite link or add from friends'**
  String get workspaceInviteLinkOrAddFromFriends;

  /// No description provided for @workspaceOnlyTripCreatorCanEditThisTrip.
  ///
  /// In en, this message translates to:
  /// **'Only trip creator can edit this trip.'**
  String get workspaceOnlyTripCreatorCanEditThisTrip;

  /// No description provided for @workspaceTripUpdated.
  ///
  /// In en, this message translates to:
  /// **'Trip updated.'**
  String get workspaceTripUpdated;

  /// No description provided for @workspaceFailedToUpdateTrip.
  ///
  /// In en, this message translates to:
  /// **'Failed to update trip.'**
  String get workspaceFailedToUpdateTrip;

  /// No description provided for @workspaceNoMembersSelectedYet.
  ///
  /// In en, this message translates to:
  /// **'No members selected yet.'**
  String get workspaceNoMembersSelectedYet;

  /// No description provided for @workspaceNoInternetExpenseSavedWithoutReceiptImage.
  ///
  /// In en, this message translates to:
  /// **'No internet. Expense will be saved without receipt image.'**
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage;

  /// No description provided for @workspaceRandomPicker.
  ///
  /// In en, this message translates to:
  /// **'Random picker'**
  String get workspaceRandomPicker;

  /// No description provided for @workspaceCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get workspaceCurrency;

  /// No description provided for @workspaceCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get workspaceCategory;

  /// No description provided for @workspaceCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom category'**
  String get workspaceCustomCategory;

  /// No description provided for @workspaceCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get workspaceCategoryName;

  /// No description provided for @workspaceApartmentRentParkingEtc.
  ///
  /// In en, this message translates to:
  /// **'Apartment rent, parking, etc.'**
  String get workspaceApartmentRentParkingEtc;

  /// No description provided for @workspaceEnterACustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom category.'**
  String get workspaceEnterACustomCategory;

  /// No description provided for @workspacePickAnExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick an expense category.'**
  String get workspacePickAnExpenseCategory;

  /// No description provided for @workspaceCategoryMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Category must be at least 2 characters.'**
  String get workspaceCategoryMustBeAtLeast2Characters;

  /// No description provided for @workspaceCategoryMustBeUpTo64Characters.
  ///
  /// In en, this message translates to:
  /// **'Category must be up to 64 characters.'**
  String get workspaceCategoryMustBeUpTo64Characters;

  /// No description provided for @workspacePercentageSplitMustTotal100.
  ///
  /// In en, this message translates to:
  /// **'Percentage split must total 100%.'**
  String get workspacePercentageSplitMustTotal100;

  /// No description provided for @workspaceSharesMustBeGreaterThan0ForAllParticipants.
  ///
  /// In en, this message translates to:
  /// **'Shares must be greater than 0 for all participants.'**
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants;

  /// No description provided for @workspaceTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get workspaceTotalAmount;

  /// No description provided for @workspaceOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get workspaceOriginal;

  /// No description provided for @workspaceTotalCost.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get workspaceTotalCost;

  /// No description provided for @workspaceStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {arg1}'**
  String workspaceStarted(Object arg1);

  /// No description provided for @workspaceEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended {arg1}'**
  String workspaceEnded(Object arg1);

  /// No description provided for @workspaceArchivedTrip.
  ///
  /// In en, this message translates to:
  /// **'Archived trip'**
  String get workspaceArchivedTrip;

  /// No description provided for @workspaceActiveTrip.
  ///
  /// In en, this message translates to:
  /// **'Active trip'**
  String get workspaceActiveTrip;

  /// No description provided for @workspaceMemberProfile.
  ///
  /// In en, this message translates to:
  /// **'Member profile'**
  String get workspaceMemberProfile;

  /// No description provided for @workspaceTripOwner.
  ///
  /// In en, this message translates to:
  /// **'Trip owner'**
  String get workspaceTripOwner;

  /// No description provided for @workspaceMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get workspaceMember;

  /// No description provided for @workspaceReadyForSettlement.
  ///
  /// In en, this message translates to:
  /// **'Ready for settlement'**
  String get workspaceReadyForSettlement;

  /// No description provided for @workspaceNotReadyForSettlement.
  ///
  /// In en, this message translates to:
  /// **'Not ready for settlement'**
  String get workspaceNotReadyForSettlement;

  /// No description provided for @workspaceBankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank details'**
  String get workspaceBankDetails;

  /// No description provided for @workspaceIbanAndPayoutDetailsWillBeAddedHereInA.
  ///
  /// In en, this message translates to:
  /// **'IBAN and payout details will be added here in a next update.'**
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA;

  /// No description provided for @workspacePaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get workspacePaymentDetails;

  /// No description provided for @workspaceThisMemberHasNotAddedPayoutDetailsYet.
  ///
  /// In en, this message translates to:
  /// **'This member has not added payout details yet.'**
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet;

  /// No description provided for @workspaceBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get workspaceBankTransfer;

  /// No description provided for @workspaceHolder.
  ///
  /// In en, this message translates to:
  /// **'Holder'**
  String get workspaceHolder;

  /// No description provided for @workspaceCouldNotOpenPaymentLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open payment link.'**
  String get workspaceCouldNotOpenPaymentLink;

  /// No description provided for @workspaceTripActivity.
  ///
  /// In en, this message translates to:
  /// **'Trip activity'**
  String get workspaceTripActivity;

  /// No description provided for @workspacePaidExpenses.
  ///
  /// In en, this message translates to:
  /// **'Paid expenses'**
  String get workspacePaidExpenses;

  /// No description provided for @workspacePaidTotal.
  ///
  /// In en, this message translates to:
  /// **'Paid total'**
  String get workspacePaidTotal;

  /// No description provided for @workspaceInvolvedIn.
  ///
  /// In en, this message translates to:
  /// **'Involved in'**
  String get workspaceInvolvedIn;

  /// No description provided for @workspaceCurrentTrip.
  ///
  /// In en, this message translates to:
  /// **'Current trip'**
  String get workspaceCurrentTrip;

  /// No description provided for @workspaceCommonTrips.
  ///
  /// In en, this message translates to:
  /// **'Common trips'**
  String get workspaceCommonTrips;

  /// No description provided for @workspaceLoadingCommonTrips.
  ///
  /// In en, this message translates to:
  /// **'Loading common trips...'**
  String get workspaceLoadingCommonTrips;

  /// No description provided for @workspaceNoCommonTripsFoundYet.
  ///
  /// In en, this message translates to:
  /// **'No common trips found yet.'**
  String get workspaceNoCommonTripsFoundYet;

  /// No description provided for @workspaceCouldNotLoadAllCommonTripsShowingCurrentOne.
  ///
  /// In en, this message translates to:
  /// **'Could not load all common trips. Showing current one.'**
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne;

  /// No description provided for @workspaceMembers.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get workspaceMembers;

  /// No description provided for @workspaceExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get workspaceExpense;

  /// No description provided for @workspacePaid.
  ///
  /// In en, this message translates to:
  /// **'paid'**
  String get workspacePaid;

  /// No description provided for @workspaceLoadingMoreExpenses.
  ///
  /// In en, this message translates to:
  /// **'Loading more expenses...'**
  String get workspaceLoadingMoreExpenses;

  /// No description provided for @workspaceScrollDownToLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll down to load more'**
  String get workspaceScrollDownToLoadMore;

  /// No description provided for @workspaceTripFinished.
  ///
  /// In en, this message translates to:
  /// **'Trip finished'**
  String get workspaceTripFinished;

  /// No description provided for @workspaceSettlementsAreUnlockedForThisTrip.
  ///
  /// In en, this message translates to:
  /// **'Settlements are unlocked for this trip.'**
  String get workspaceSettlementsAreUnlockedForThisTrip;

  /// No description provided for @workspaceFinishTripToStartSettlements.
  ///
  /// In en, this message translates to:
  /// **'Finish trip to start settlements.'**
  String get workspaceFinishTripToStartSettlements;

  /// No description provided for @workspaceMarkedTransferAsSent.
  ///
  /// In en, this message translates to:
  /// **'{arg1} marked transfer as sent.'**
  String workspaceMarkedTransferAsSent(Object arg1);

  /// No description provided for @workspaceWaitingForToMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {arg1} to mark as paid.'**
  String workspaceWaitingForToMarkAsPaid(Object arg1);

  /// No description provided for @workspaceConfirmedReceivingThePayment.
  ///
  /// In en, this message translates to:
  /// **'{arg1} confirmed receiving the payment.'**
  String workspaceConfirmedReceivingThePayment(Object arg1);

  /// No description provided for @workspaceWaitingForToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {arg1} to confirm.'**
  String workspaceWaitingForToConfirm(Object arg1);

  /// No description provided for @workspaceAllTripSettlementsAreFullyCompleted.
  ///
  /// In en, this message translates to:
  /// **'All trip settlements are fully completed.'**
  String get workspaceAllTripSettlementsAreFullyCompleted;

  /// No description provided for @workspaceFinalStateAfterAllTransfersAreConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Final state after all transfers are confirmed.'**
  String get workspaceFinalStateAfterAllTransfersAreConfirmed;

  /// No description provided for @workspaceSettlementFlow.
  ///
  /// In en, this message translates to:
  /// **'Settlement flow'**
  String get workspaceSettlementFlow;

  /// No description provided for @workspaceActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get workspaceActions;

  /// No description provided for @workspaceTransferIsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Transfer is confirmed.'**
  String get workspaceTransferIsConfirmed;

  /// No description provided for @workspaceWaitingForTheOtherMemberToCompleteTheNextStep.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other member to complete the next step.'**
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep;

  /// No description provided for @workspaceSendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get workspaceSendReminder;

  /// No description provided for @workspaceInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get workspaceInProgress;

  /// No description provided for @workspaceTimeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Time unknown'**
  String get workspaceTimeUnknown;

  /// No description provided for @workspaceRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get workspaceRemind;

  /// No description provided for @workspaceYourPosition.
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get workspaceYourPosition;

  /// No description provided for @workspaceRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get workspaceRecentActivity;

  /// No description provided for @workspaceNoRecentActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet.'**
  String get workspaceNoRecentActivityYet;

  /// No description provided for @workspaceAddAtLeastOneMemberToStartSplittingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Add at least one member to start splitting expenses.'**
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses;

  /// No description provided for @workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses.
  ///
  /// In en, this message translates to:
  /// **'Mark yourself ready to settle after adding all your expenses.'**
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses;

  /// No description provided for @workspaceWaitingForMemberSToMarkReady.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {arg1} member(s) to mark ready.'**
  String workspaceWaitingForMemberSToMarkReady(Object arg1);

  /// No description provided for @workspaceAllMembersAreReadyYouCanFinishTheTripAnd.
  ///
  /// In en, this message translates to:
  /// **'All members are ready. You can finish the trip and start settlements.'**
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd;

  /// No description provided for @workspaceAllMembersAreReadyWaitingForTheTripOwnerTo.
  ///
  /// In en, this message translates to:
  /// **'All members are ready. Waiting for the trip owner to start settlements.'**
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo;

  /// No description provided for @workspaceSettlementInProgressConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Settlement in progress: {arg1}/{arg2} confirmed.'**
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2);

  /// No description provided for @workspaceNoActionsPendingThisTripIsSettled.
  ///
  /// In en, this message translates to:
  /// **'No actions pending. This trip is settled.'**
  String get workspaceNoActionsPendingThisTripIsSettled;

  /// No description provided for @workspaceNoActionsNeededRightNow.
  ///
  /// In en, this message translates to:
  /// **'No actions needed right now.'**
  String get workspaceNoActionsNeededRightNow;

  /// No description provided for @workspaceYouShouldReceive.
  ///
  /// In en, this message translates to:
  /// **'You should receive {arg1}.'**
  String workspaceYouShouldReceive(Object arg1);

  /// No description provided for @workspaceYouShouldPay.
  ///
  /// In en, this message translates to:
  /// **'You should pay {arg1}.'**
  String workspaceYouShouldPay(Object arg1);

  /// No description provided for @workspaceYouAreCurrentlySettledInThisTrip.
  ///
  /// In en, this message translates to:
  /// **'You are currently settled in this trip.'**
  String get workspaceYouAreCurrentlySettledInThisTrip;

  /// No description provided for @workspaceUnknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown time'**
  String get workspaceUnknownTime;

  /// No description provided for @workspaceJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get workspaceJustNow;

  /// No description provided for @workspaceMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{arg1} min ago'**
  String workspaceMinAgo(Object arg1);

  /// No description provided for @workspaceHAgo.
  ///
  /// In en, this message translates to:
  /// **'{arg1} h ago'**
  String workspaceHAgo(Object arg1);

  /// No description provided for @workspaceDAgo.
  ///
  /// In en, this message translates to:
  /// **'{arg1} d ago'**
  String workspaceDAgo(Object arg1);

  /// No description provided for @friendsRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get friendsRemoveFriend;

  /// No description provided for @friendsRemoveThisFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove this friend?'**
  String get friendsRemoveThisFriend;

  /// No description provided for @friendsWillBeRemovedFromYourFriendsListYouCanAdd.
  ///
  /// In en, this message translates to:
  /// **'{arg1} will be removed from your friends list. You can add them again later.'**
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1);

  /// No description provided for @friendsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get friendsContinue;

  /// No description provided for @friendsFriendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed.'**
  String get friendsFriendRemoved;

  /// No description provided for @friendsCouldNotRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Could not remove friend.'**
  String get friendsCouldNotRemoveFriend;

  /// No description provided for @friendsFriendProfile.
  ///
  /// In en, this message translates to:
  /// **'Friend profile'**
  String get friendsFriendProfile;

  /// No description provided for @friendsMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get friendsMoreActions;

  /// No description provided for @friendsThisFriendHasNotAddedPayoutDetailsYet.
  ///
  /// In en, this message translates to:
  /// **'This friend has not added payout details yet.'**
  String get friendsThisFriendHasNotAddedPayoutDetailsYet;

  /// No description provided for @friendsCouldNotLoadCommonTripsRightNow.
  ///
  /// In en, this message translates to:
  /// **'Could not load common trips right now.'**
  String get friendsCouldNotLoadCommonTripsRightNow;

  /// No description provided for @friendsFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get friendsFinished;

  /// No description provided for @friendsTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip #{arg1}'**
  String friendsTrip(Object arg1);

  /// No description provided for @friendsMembers.
  ///
  /// In en, this message translates to:
  /// **'{arg1} members'**
  String friendsMembers(Object arg1);

  /// No description provided for @friendsNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get friendsNoDate;

  /// No description provided for @friendsIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'INCOMING REQUESTS'**
  String get friendsIncomingRequests;

  /// No description provided for @friendsSentInvites.
  ///
  /// In en, this message translates to:
  /// **'SENT INVITES'**
  String get friendsSentInvites;

  /// No description provided for @friendsMyFriends.
  ///
  /// In en, this message translates to:
  /// **'MY FRIENDS'**
  String get friendsMyFriends;

  /// No description provided for @friendsIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get friendsIncoming;

  /// No description provided for @friendsInviteSentTo.
  ///
  /// In en, this message translates to:
  /// **'Invite sent to {arg1}.'**
  String friendsInviteSentTo(Object arg1);

  /// No description provided for @friendsNoIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests'**
  String get friendsNoIncomingRequests;

  /// No description provided for @friendsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get friendsDecline;

  /// No description provided for @friendsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendsAccept;

  /// No description provided for @friendsNoSentInvites.
  ///
  /// In en, this message translates to:
  /// **'No sent invites'**
  String get friendsNoSentInvites;

  /// No description provided for @friendsNoFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get friendsNoFriendsYet;

  /// No description provided for @friendsScrollDownToLoadMoreFriends.
  ///
  /// In en, this message translates to:
  /// **'Scroll down to load more friends.'**
  String get friendsScrollDownToLoadMoreFriends;

  /// No description provided for @friendsUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get friendsUser;

  /// No description provided for @friendsSearchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get friendsSearchUsers;

  /// No description provided for @friendsFindByNameOrEmailAndSendInvite.
  ///
  /// In en, this message translates to:
  /// **'Find by name or email and send invite'**
  String get friendsFindByNameOrEmailAndSendInvite;

  /// No description provided for @friendsScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get friendsScanQr;

  /// No description provided for @friendsScanAnotherUserToAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Scan another user to add friend'**
  String get friendsScanAnotherUserToAddFriend;

  /// No description provided for @friendsMyQr.
  ///
  /// In en, this message translates to:
  /// **'My QR'**
  String get friendsMyQr;

  /// No description provided for @friendsShowOrShareYourQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show or share your QR code'**
  String get friendsShowOrShareYourQrCode;

  /// No description provided for @friendsScanFriendQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Friend QR'**
  String get friendsScanFriendQrTitle;

  /// No description provided for @friendsPlaceFriendQrInsideFrame.
  ///
  /// In en, this message translates to:
  /// **'Place friend QR code inside the frame'**
  String get friendsPlaceFriendQrInsideFrame;

  /// No description provided for @friendsMyFriendQrTitle.
  ///
  /// In en, this message translates to:
  /// **'My Friend QR'**
  String get friendsMyFriendQrTitle;

  /// No description provided for @friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode.
  ///
  /// In en, this message translates to:
  /// **'Open Friends > Scan QR on another phone and scan this code.'**
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode;

  /// No description provided for @friendsAddMeOnTripSplitFriends.
  ///
  /// In en, this message translates to:
  /// **'Add me on TripSplit friends.'**
  String get friendsAddMeOnTripSplitFriends;

  /// No description provided for @friendsTripSplitFriendCode.
  ///
  /// In en, this message translates to:
  /// **'TripSplit friend code'**
  String get friendsTripSplitFriendCode;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @friendsQrCodeIsNotAValidFriendCode.
  ///
  /// In en, this message translates to:
  /// **'QR code is not a valid friend code.'**
  String get friendsQrCodeIsNotAValidFriendCode;

  /// No description provided for @friendsYouCannotAddYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot add yourself.'**
  String get friendsYouCannotAddYourself;

  /// No description provided for @friendsThisUserIsAlreadyInYourFriendsList.
  ///
  /// In en, this message translates to:
  /// **'This user is already in your friends list.'**
  String get friendsThisUserIsAlreadyInYourFriendsList;

  /// No description provided for @friendsInviteToThisUserIsAlreadySent.
  ///
  /// In en, this message translates to:
  /// **'Invite to this user is already sent.'**
  String get friendsInviteToThisUserIsAlreadySent;

  /// No description provided for @friendsFriendRequestProcessed.
  ///
  /// In en, this message translates to:
  /// **'Friend request processed.'**
  String get friendsFriendRequestProcessed;

  /// No description provided for @friendsFailedToProcessFriendQr.
  ///
  /// In en, this message translates to:
  /// **'Failed to process friend QR.'**
  String get friendsFailedToProcessFriendQr;

  /// No description provided for @friendsCouldNotLoadYourUserProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your user profile.'**
  String get friendsCouldNotLoadYourUserProfile;

  /// No description provided for @friendsMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get friendsMyProfile;

  /// No description provided for @friendsUnexpectedErrorLoadingFriends.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error loading friends.'**
  String get friendsUnexpectedErrorLoadingFriends;

  /// No description provided for @friendsFriendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added.'**
  String get friendsFriendAdded;

  /// No description provided for @friendsRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined.'**
  String get friendsRequestDeclined;

  /// No description provided for @friendsFailedToUpdateRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to update request.'**
  String get friendsFailedToUpdateRequest;

  /// No description provided for @friendsCancelInvite.
  ///
  /// In en, this message translates to:
  /// **'Cancel invite'**
  String get friendsCancelInvite;

  /// No description provided for @friendsCancelInviteTo.
  ///
  /// In en, this message translates to:
  /// **'Cancel invite to {arg1}?'**
  String friendsCancelInviteTo(Object arg1);

  /// No description provided for @friendsKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get friendsKeep;

  /// No description provided for @friendsInviteToCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invite to {arg1} cancelled.'**
  String friendsInviteToCancelled(Object arg1);

  /// No description provided for @friendsFailedToCancelInvite.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel invite.'**
  String get friendsFailedToCancelInvite;

  /// No description provided for @analyticsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get analyticsOther;

  /// No description provided for @analyticsSelectATripForAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Select a trip for analytics'**
  String get analyticsSelectATripForAnalytics;

  /// No description provided for @analyticsMembers.
  ///
  /// In en, this message translates to:
  /// **'{arg1} • {arg2} members • {arg3} • {arg4}'**
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4);

  /// No description provided for @analyticsMyDaily.
  ///
  /// In en, this message translates to:
  /// **'My daily'**
  String get analyticsMyDaily;

  /// No description provided for @analyticsGroupDaily.
  ///
  /// In en, this message translates to:
  /// **'Group daily'**
  String get analyticsGroupDaily;

  /// No description provided for @analyticsByMember.
  ///
  /// In en, this message translates to:
  /// **'By Member'**
  String get analyticsByMember;

  /// No description provided for @analyticsShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get analyticsShowLess;

  /// No description provided for @analyticsByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get analyticsByCategory;

  /// No description provided for @analyticsQuickInsights.
  ///
  /// In en, this message translates to:
  /// **'Quick insights'**
  String get analyticsQuickInsights;

  /// No description provided for @analyticsBiggestExpense.
  ///
  /// In en, this message translates to:
  /// **'Biggest expense: {arg1} ({arg2})'**
  String analyticsBiggestExpense(Object arg1, Object arg2);

  /// No description provided for @analyticsTopSpender.
  ///
  /// In en, this message translates to:
  /// **'Top spender: {arg1} ({arg2})'**
  String analyticsTopSpender(Object arg1, Object arg2);

  /// No description provided for @analyticsHighestGroupDay.
  ///
  /// In en, this message translates to:
  /// **'Highest group day: {arg1} ({arg2})'**
  String analyticsHighestGroupDay(Object arg1, Object arg2);

  /// No description provided for @analyticsNoDates.
  ///
  /// In en, this message translates to:
  /// **'No dates'**
  String get analyticsNoDates;

  /// No description provided for @friendsSearchFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Try again.'**
  String get friendsSearchFailedTryAgain;

  /// No description provided for @friendsFailedToSendInvite.
  ///
  /// In en, this message translates to:
  /// **'Failed to send invite.'**
  String get friendsFailedToSendInvite;

  /// No description provided for @friendsAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get friendsAddFriend;

  /// No description provided for @friendsSearchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get friendsSearchByNameOrEmail;

  /// No description provided for @friendsTypeAtLeast2CharactersToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search.'**
  String get friendsTypeAtLeast2CharactersToSearch;

  /// No description provided for @friendsNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get friendsNoUsersFound;

  /// No description provided for @friendsInviteAction.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get friendsInviteAction;

  /// No description provided for @workspacePaidForGroup.
  ///
  /// In en, this message translates to:
  /// **'Paid for group'**
  String get workspacePaidForGroup;

  /// No description provided for @workspacePaidForGroupDate.
  ///
  /// In en, this message translates to:
  /// **'Paid for group • {arg1}'**
  String workspacePaidForGroupDate(Object arg1);

  /// No description provided for @workspaceShareOfExpense.
  ///
  /// In en, this message translates to:
  /// **'Share of expense'**
  String get workspaceShareOfExpense;

  /// No description provided for @workspaceShareOfExpenseDate.
  ///
  /// In en, this message translates to:
  /// **'Share of expense • {arg1}'**
  String workspaceShareOfExpenseDate(Object arg1);

  /// No description provided for @paymentHolderNameCopied.
  ///
  /// In en, this message translates to:
  /// **'Holder name copied.'**
  String get paymentHolderNameCopied;

  /// No description provided for @paymentIbanCopied.
  ///
  /// In en, this message translates to:
  /// **'IBAN copied.'**
  String get paymentIbanCopied;

  /// No description provided for @paymentSwiftCopied.
  ///
  /// In en, this message translates to:
  /// **'SWIFT copied.'**
  String get paymentSwiftCopied;

  /// No description provided for @paymentRevtagCopied.
  ///
  /// In en, this message translates to:
  /// **'Revtag copied.'**
  String get paymentRevtagCopied;

  /// No description provided for @paymentCouldNotCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Could not copy to clipboard.'**
  String get paymentCouldNotCopyToClipboard;

  /// No description provided for @paymentCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get paymentCopied;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'lv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'lv': return AppLocalizationsLv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
