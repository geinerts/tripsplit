// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get activeStatus => 'Active';

  @override
  String get activeTripPlural => 'active trips';

  @override
  String get activeTripSingle => 'active trip';

  @override
  String get activeTrips => 'Active trips';

  @override
  String get activitiesComingSoon => 'Activities section coming soon.';

  @override
  String get addAction => 'Add';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get addExpensesAction => 'Add expenses';

  @override
  String get addMembersAction => 'Add members';

  @override
  String get addTripMembersTitle => 'Add trip members';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members added.',
      one: '$count member added.',
    );
    return '$_temp0';
  }

  @override
  String get allCaughtUp => 'All caught up';

  @override
  String get allFilter => 'All';

  @override
  String get allMembersLabel => 'All members';

  @override
  String get allPaymentsConfirmed => 'All payments are confirmed.';

  @override
  String get allTrips => 'All trips';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0.';

  @override
  String get appearance => 'Appearance';

  @override
  String get archivedStatus => 'Archived';

  @override
  String get authSubtitleLogin => 'Split travel expenses with friends';

  @override
  String get authSubtitleRegister => 'Create account and start splitting trips';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'confirmed: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'pending: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'sent: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'suggested: $count';
  }

  @override
  String get cancelAction => 'Cancel';

  @override
  String get changeEmailWithPasswordHelper => 'Enter your password to change email.';

  @override
  String get chooseReceiptFile => 'Choose receipt file';

  @override
  String get completeAccountSetupDescription => 'Set your email and password to complete your account.';

  @override
  String get completeAccountSetupTitle => 'Complete account setup';

  @override
  String get confirmReceivedAction => 'Confirm received';

  @override
  String get confirmedAllSettlementsArchived => 'All settlements confirmed. Trip archived.';

  @override
  String get confirmedAsReceived => 'Confirmed as received.';

  @override
  String get confirmedLabel => 'Confirmed';

  @override
  String get couldNotOpenReceiptLink => 'Could not open receipt link.';

  @override
  String get createAction => 'Create';

  @override
  String get createFirstTripHint => 'Create your first trip to get started.';

  @override
  String get createNewTripTitle => 'Create new trip';

  @override
  String get createTripAction => 'Create trip';

  @override
  String get createTripFirst => 'Create a trip first.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date  -  Created by $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Trip creator must finish the trip to start settlement confirmation.';

  @override
  String currentEmailLabel(Object email) {
    return 'Current email: $email';
  }

  @override
  String get currentReceiptAttached => 'Current receipt is attached.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Date';

  @override
  String get dateMustMatchFormat => 'Date must match YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Date unknown';

  @override
  String get deleteAction => 'Delete';

  @override
  String get deleteExpenseConfirmQuestion => 'Delete this expense?';

  @override
  String get deleteExpenseTitle => 'Delete expense';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Directly explained by expenses: $amount';
  }

  @override
  String get doneStatus => 'Done';

  @override
  String get editAction => 'Edit';

  @override
  String get editExpenseTitle => 'Edit expense';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get enterValidExactAmounts => 'Enter valid exact amounts for all participants.';

  @override
  String get enterValidPercentages => 'Enter valid percentages for all participants.';

  @override
  String get equalSplitLabel => 'Equal split';

  @override
  String exactAmountWithValue(Object value) {
    return 'Exact: $value';
  }

  @override
  String get exactAmountsLabel => 'Exact amounts';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Exact split must sum to $amount.';
  }

  @override
  String get expenseAdded => 'Expense added.';

  @override
  String get expenseBreakdownSubtitle => 'How this member is affected by each expense.';

  @override
  String get expenseBreakdownTitle => 'Expense breakdown';

  @override
  String get expenseDeleted => 'Expense deleted.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Expense #$id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Paid $paid  -  Owes $owes';
  }

  @override
  String get expenseUpdated => 'Expense updated.';

  @override
  String expenseWithId(Object id) {
    return 'Expense #$id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '$count expense',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Expenses';

  @override
  String get failedToCreateTrip => 'Failed to create trip.';

  @override
  String get failedToLoadUsersDirectory => 'Failed to load users directory.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filter settlements by member';

  @override
  String get finishTripAction => 'Finish trip';

  @override
  String get finishTripConfirmationText => 'Finish this trip and start settlements?';

  @override
  String get finishTripStartSettlementsAction => 'Finish and start settlements';

  @override
  String get finishTripTitle => 'Finish trip';

  @override
  String forParticipants(Object participants) {
    return 'For: $participants';
  }

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get friendsProgressSubtitle => 'Each member and their confirmation state.';

  @override
  String get friendsProgressTitle => 'Friends progress';

  @override
  String get friendsSectionComingSoon => 'Friends section coming soon.';

  @override
  String fromDirection(Object name) {
    return 'From $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from to $to';
  }

  @override
  String get generateTurnAction => 'Generate turn';

  @override
  String get hasAccountQuestion => 'Already have an account?';

  @override
  String helloUser(Object name) {
    return 'Hi, $name!';
  }

  @override
  String get iSentAction => 'I sent';

  @override
  String get invalidEmailFormat => 'Invalid email format.';

  @override
  String get languageAction => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageLatvian => 'Latviešu';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemSubtitle => 'Use device language';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Leave empty to keep current password.';

  @override
  String get logInButton => 'Log in';

  @override
  String get logOutButton => 'Log out';

  @override
  String get logoutFromDeviceQuestion => 'Log out from this device?';

  @override
  String get markedAsSent => 'Marked as sent.';

  @override
  String get memberSummariesSubtitle => 'Current balance state for both sides.';

  @override
  String get memberSummariesTitle => 'Member summaries';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'To pay $total  -  confirmed $confirmed  -  waiting $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Estimated payment impact per member.';

  @override
  String get membersImpactTitle => 'Members impact';

  @override
  String get membersIncludedInExpense => 'Members included';

  @override
  String get membersLabel => 'Members';

  @override
  String moreCount(Object count) {
    return '+$count more';
  }

  @override
  String get myFilter => 'My';

  @override
  String get myImpactTitle => 'My impact';

  @override
  String get firstNameHint => 'Your first name';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get firstNameLengthValidation => 'First name must be 2-64 characters.';

  @override
  String get fullNameHelper => 'Use first and last name in one field.';

  @override
  String get fullNameHint => 'e.g. Anna Ozolina';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameValidation => 'Enter first and last name (at least 2 characters each).';

  @override
  String get lastNameHint => 'Your last name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get lastNameLengthValidation => 'Last name must be 2-64 characters.';

  @override
  String get nameHint => 'Your name';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameLengthValidation => 'Name must be at least 2 characters.';

  @override
  String get navActivities => 'Analytics';

  @override
  String get navAddTrip => 'Add trip';

  @override
  String get navBalances => 'Balances';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navFriends => 'Friends';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get navRandom => 'Random';

  @override
  String get netLabel => 'Net';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get nicknameHint => 'How friends will see you';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameLengthValidation => 'Nickname must be at least 2 characters.';

  @override
  String get noAccountQuestion => 'No account yet?';

  @override
  String get noBalancesYet => 'No balances yet.';

  @override
  String get noChangesToSave => 'No changes to save.';

  @override
  String get noDirectExpenseLink => 'No direct single-expense link found. This settlement is calculated from full trip balance.';

  @override
  String get noExpenseImpactForMember => 'No expense impact for this member.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'No expenses for $name yet.';
  }

  @override
  String get noExpensesYet => 'No expenses yet.';

  @override
  String get noExtraUsersToAdd => 'No extra users to add.';

  @override
  String get noInternetDeleteQueued => 'No internet. Delete queued.';

  @override
  String get noInternetExpenseQueued => 'No internet. Expense queued.';

  @override
  String get noInternetUpdateQueued => 'No internet. Update queued.';

  @override
  String get noMatchingRows => 'No matching rows.';

  @override
  String get noMembersFound => 'No members found.';

  @override
  String get noNewMembersAdded => 'No new members were added.';

  @override
  String get noNotePlaceholder => 'No note';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get noParticipantData => 'No participant data.';

  @override
  String get noParticipantsSelected => 'No participants selected.';

  @override
  String get noPaymentRowsInTrip => 'No payment rows in this trip.';

  @override
  String get noPaymentsNeeded => 'No payments needed.';

  @override
  String get noPicksYet => 'No picks yet.';

  @override
  String get noSettlementActivityForMember => 'No settlement activity for this member.';

  @override
  String get noSettlementRowsYet => 'No settlement rows yet.';

  @override
  String get noSettlements => 'No settlements';

  @override
  String get noTransferNeededForFilter => 'No transfer needed for selected filter.';

  @override
  String get noTransferRowsToShow => 'No transfer rows to show.';

  @override
  String get noTripDataLoaded => 'No trip data loaded.';

  @override
  String get noTripsYet => 'No trips yet.';

  @override
  String get noUsersFoundYet => 'No users found yet.';

  @override
  String get notSetValue => 'Not set';

  @override
  String get notYetConfirmedTitle => 'Not yet confirmed';

  @override
  String get noteHint => 'Dinner, taxi, tickets...';

  @override
  String get noteLabel => 'Note';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Note must be at most $max chars.';
  }

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending changes',
      one: '$count pending change',
    );
    return 'Offline queue: $_temp0';
  }

  @override
  String get offlineQueueStatus => 'Offline queue';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Only trip creator can finish the trip.';

  @override
  String get openLabel => 'Open';

  @override
  String get openReceiptAction => 'Open receipt';

  @override
  String get openSettlements => 'Open settlements';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get owesLabel => 'Owes';

  @override
  String get paidByLabel => 'Paid by';

  @override
  String get paidLabel => 'Paid';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Paid $paid  -  Owes $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Participants (empty = all members)';

  @override
  String get participantsTitle => 'Participants';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordComplexityHelper => 'Use at least 1 uppercase letter, 1 number and 1 symbol.';

  @override
  String get passwordComplexityValidation => 'Password must include 1 uppercase letter, 1 number and 1 symbol.';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters.';

  @override
  String get passwordMinLengthShort => 'Password must be at least 6 characters.';

  @override
  String get passwordResetComingSoon => 'Password reset coming soon.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String payerName(Object name) {
    return '$name (payer)';
  }

  @override
  String get pendingLabel => 'Pending';

  @override
  String get pendingPaymentsSubtitle => 'Payments still waiting for full confirmation.';

  @override
  String get percentLabel => 'Percent';

  @override
  String get percentSplitMustBe100 => 'Percent split must sum to exactly 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Percentages';

  @override
  String get pickAtLeastOneParticipant => 'Pick at least one participant.';

  @override
  String get pickMembersGenerateTurn => 'Pick members and generate a turn.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name picked. Cycle completed.';
  }

  @override
  String pickedUser(Object name) {
    return '$name picked.';
  }

  @override
  String get profileRefreshCachedData => 'Could not refresh profile. Showing cached data.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get uploadAvatarAction => 'Upload avatar';

  @override
  String get removeAvatarAction => 'Remove avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar updated.';

  @override
  String get avatarRemovedMessage => 'Avatar removed.';

  @override
  String get avatarFileTooLarge => 'Avatar file is too large (max 5 MB).';

  @override
  String get avatarPickFailed => 'Could not load avatar image.';

  @override
  String get queueAddExpense => 'Add expense';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'Queued: add expense $amount';
  }

  @override
  String get queueDeleteExpense => 'Delete expense';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'Queued: delete expense #$id';
  }

  @override
  String get queuePendingStatus => 'Queue pending';

  @override
  String get queueUpdateExpense => 'Update expense';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'Queued: update expense #$id';
  }

  @override
  String get queuedChange => 'Queued change';

  @override
  String queuedChangesTitle(Object count) {
    return 'Queued changes ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'Queued ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cycle $cycleNo, draw $drawNo - $remaining left';
  }

  @override
  String get receiptFallbackName => 'receipt';

  @override
  String get receiptLinkInvalid => 'Receipt link is invalid.';

  @override
  String get receiptOptionalLabel => 'Receipt (optional)';

  @override
  String get recentPicksTitle => 'Recent picks';

  @override
  String get reloadProfile => 'Reload profile';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get removeCurrentReceipt => 'Remove current receipt';

  @override
  String get repeatNewPasswordLabel => 'Repeat new password';

  @override
  String get repeatPasswordLabel => 'Repeat password';

  @override
  String get requestFailedTryAgain => 'Request failed. Try again.';

  @override
  String get retryAction => 'Retry';

  @override
  String get rowsLabel => 'Rows';

  @override
  String get saveAction => 'Save';

  @override
  String get saveCredentialsButton => 'Save credentials';

  @override
  String get saveProfileButton => 'Save profile';

  @override
  String get searchUsersHint => 'Search people by name or email';

  @override
  String get selectedPeopleLabel => 'Selected people';

  @override
  String get noSearchMatches => 'No matching users found.';

  @override
  String get savingButton => 'Saving...';

  @override
  String get selectAtLeastTwoMembers => 'Select at least two members.';

  @override
  String get selectMembersHint => 'Select members';

  @override
  String selectedFileLabel(Object name) {
    return 'Selected: $name';
  }

  @override
  String get selectedLabel => 'Selected';

  @override
  String get selectedUserFallback => 'Selected user';

  @override
  String get settings => 'Settings';

  @override
  String get settleUpAction => 'Settle up';

  @override
  String get settledLabel => 'Settled';

  @override
  String get settledStatus => 'Settled';

  @override
  String get settlementActivitySubtitle => 'Transfers linked to this member.';

  @override
  String get settlementActivityTitle => 'Settlement activity';

  @override
  String get settlementCompletedTitle => 'Settlement completed';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed/$total confirmed';
  }

  @override
  String settlementCountLabel(Object count) {
    return '$count settlements';
  }

  @override
  String get settlementImpactTitle => 'Settlement impact';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Settlement impact: $name';
  }

  @override
  String get settlementInProgress => 'Settlement in progress';

  @override
  String get settlementInProgressTitle => 'Settlement in progress';

  @override
  String get settlementLabel => 'Settlement';

  @override
  String get settlementOverviewArchivedSubtitle => 'Trip archived. All settlements completed.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Track settlement confirmations.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Preview transfers for when trip finishes.';

  @override
  String get settlementPreview => 'Settlement preview';

  @override
  String get settlementPreviewTitle => 'Settlement preview';

  @override
  String get settlementProgressTripArchived => 'Trip archived';

  @override
  String settlementWithId(Object id) {
    return 'Settlement #$id';
  }

  @override
  String get settlements => 'Settlements';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Settlements already completed.';

  @override
  String get settlementsDone => 'Settlements done';

  @override
  String get settlingStatus => 'Settling';

  @override
  String get shareUnit => 'share';

  @override
  String get sharesLabel => 'Shares';

  @override
  String get sharesMustBePositiveIntegers => 'Shares must be positive whole numbers.';

  @override
  String sharesWithValue(Object value) {
    return 'Shares: $value';
  }

  @override
  String get showActiveTrips => 'Show active trips';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get splitBreakdownSubtitle => 'How the expense is split';

  @override
  String get splitBreakdownTitle => 'Split breakdown';

  @override
  String get splitHintEqual => 'Split equally between selected participants.';

  @override
  String get splitHintExact => 'Enter exact amount for each participant. Sum must match total.';

  @override
  String get splitHintPercent => 'Enter percentage for each participant. Sum must be 100%.';

  @override
  String get splitHintShares => 'Enter share units (1, 2, 3...). Cost is split proportionally.';

  @override
  String get splitLabel => 'Split';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Equal split ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Exact amounts ($target)';
  }

  @override
  String get splitModeLabel => 'Split mode';

  @override
  String splitModePercent(Object target) {
    return 'Percentages ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Shares ($target)';
  }

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusSuggested => 'Suggested';

  @override
  String statusWithValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get suggestedTransferDirections => 'Suggested transfer directions';

  @override
  String get suggestedTransferFromExpense => 'Suggested transfer from expense';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggested transfer rows',
      one: '$count suggested transfer row',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Expected payer -> receiver rows.';

  @override
  String get suggestedTransfersTitle => 'Suggested transfers';

  @override
  String get summarySettledUp => 'Settled up';

  @override
  String get summaryYouAreOwed => 'They owe you';

  @override
  String get summaryYouOwe => 'You owe';

  @override
  String get syncAction => 'Sync';

  @override
  String get syncNowAction => 'Sync now';

  @override
  String get syncingStatus => 'Syncing';

  @override
  String get tapToViewDetails => 'Tap to view details';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeDarkSubtitle => 'Soft dark (not pure black)';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeSystemSubtitle => 'Use device appearance';

  @override
  String toDirection(Object name) {
    return 'To $name';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get travelerFallbackName => 'Traveler';

  @override
  String get tripAlreadyClosed => 'Trip already closed.';

  @override
  String get tripArchivedReadOnly => 'Trip is archived. Read-only mode.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Trip is closed. Expense editing is disabled.';

  @override
  String get tripClosedExpensesReadOnly => 'Trip is closed. Expenses are read-only.';

  @override
  String get tripClosedRandomDisabled => 'Trip is closed. Random draw is disabled.';

  @override
  String tripCreated(Object name) {
    return 'Trip \"$name\" created.';
  }

  @override
  String get tripFinished => 'Trip finished.';

  @override
  String get tripFinishedCompleteSettlements => 'Trip is finished. Complete settlements.';

  @override
  String get tripFinishedSettlementStarted => 'Trip finished. Settlement started.';

  @override
  String get tripFullySettledArchived => 'Trip fully settled and archived.';

  @override
  String get tripNameHint => 'Austria ski trip';

  @override
  String get tripNameLabel => 'Trip name';

  @override
  String get tripNameLengthValidation => 'Trip name must be at least 2 characters.';

  @override
  String get tripSnapshotTitle => 'Trip snapshot';

  @override
  String get tripTitleShort => 'Trip';

  @override
  String tripStatusWithValue(Object status) {
    return 'Trip status: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Trip #$id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Unexpected error loading profile';

  @override
  String get unexpectedErrorLoadingTripData => 'Unexpected error loading trip data';

  @override
  String get unexpectedErrorLoadingTrips => 'Unexpected error loading trips';

  @override
  String get unexpectedErrorSavingChanges => 'Unexpected error saving changes';

  @override
  String get unexpectedErrorSavingCredentials => 'Unexpected error saving credentials';

  @override
  String get unexpectedErrorUpdatingProfile => 'Unexpected error updating profile';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get unknownLabel => 'Unknown';

  @override
  String get unreadLabel => 'Unread';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread updates',
      one: '$count unread update',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Missing trip route argument.';

  @override
  String userIdLabel(Object id) {
    return 'User ID: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Paid $paid  -  Owes $owes  -  Net $net';
  }

  @override
  String userWithId(Object id) {
    return 'User $id';
  }

  @override
  String get valueLabel => 'Value';

  @override
  String get viewAllTrips => 'View all trips';

  @override
  String get viewByPersonTitle => 'View by person';

  @override
  String get whoOwesWhatSubtitle => 'Who paid and who owes.';

  @override
  String get whoOwesWhatTitle => 'Who owes what';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Who owes what: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Expense rows contributing to this transfer.';

  @override
  String get whyPaymentExistsTitle => 'Why this payment exists';

  @override
  String get youLabel => 'You';

  @override
  String get youSettledForExpense => 'You settled for this expense.';

  @override
  String youShouldPay(Object amount) {
    return 'You should pay $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'You should receive $amount';
  }

  @override
  String get yourShare => 'Your share';

  @override
  String get yourTrips => 'Your trips';
}
