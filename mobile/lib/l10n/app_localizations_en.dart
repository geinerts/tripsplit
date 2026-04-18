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
  String get expenseReactionsTitle => 'Reactions';

  @override
  String get expenseCommentsTitle => 'Comments';

  @override
  String get expenseNoComments => 'No comments yet.';

  @override
  String get expenseAddCommentHint => 'Add a comment...';

  @override
  String get expenseCommentSend => 'Send';

  @override
  String get expenseDeleteCommentTitle => 'Delete comment?';

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
  String get forgotPasswordSubtitle => 'Enter your email and we will send a password reset link.';

  @override
  String get forgotPasswordSuccessMessage => 'If an account with this email exists, we have sent a password reset link.';

  @override
  String get forgotPasswordTitle => 'Reset password';

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
  String get languageSpanish => 'Spanish';

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
  String get notificationFriendInviteTitle => 'Friend invite';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name sent you a friend invite.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'You received a friend invite.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Invite accepted';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name accepted your friend invite.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Your friend invite was accepted.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Invite declined';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name declined your friend invite.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Your friend invite was declined.';

  @override
  String get notificationTripAddedTitle => 'Added to trip';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name added you to trip \"$trip\".';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'You were added to trip \"$trip\".';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'You were added to a trip.';

  @override
  String get notificationExpenseAddedTitle => 'New expense added';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name added an expense of $amount in \"$trip\".';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name added an expense of $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'A new expense was added.';

  @override
  String get notificationTripFinishedTitle => 'Trip finished';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name finished \"$trip\". Settlements are ready.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name finished \"$trip\". Trip is archived.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '\"$trip\" was finished.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Trip status was updated.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Member marked ready';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name is ready to settle in \"$trip\".';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'A member is ready to settle in \"$trip\".';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'A member is ready to settle.';

  @override
  String get notificationTripReadyToSettleTitle => 'All members are ready';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'All members marked ready in \"$trip\". You can start settlements.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'All members are ready. You can start settlements.';

  @override
  String get notificationSettlementReminderTitle => 'Settlement reminder';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor reminded $target to mark $amount as sent.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor reminded $target to confirm receiving $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'You received a settlement reminder.';

  @override
  String get notificationPaymentReminderTitle => 'Payment reminder';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Reminder: please mark $amount as sent to $target in \"$trip\".';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Reminder: please mark the payment as sent.';

  @override
  String get notificationConfirmationReminderTitle => 'Confirmation reminder';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Reminder: please confirm receiving $amount from $payer in \"$trip\".';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Reminder: please confirm receiving the payment.';

  @override
  String get notificationSettlementSentTitle => 'Transfer marked as sent';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name marked $amount as sent to you.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'A transfer was marked as sent.';

  @override
  String get notificationSettlementConfirmedTitle => 'Transfer confirmed';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name confirmed receiving $amount from you.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'A transfer was confirmed.';

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
  String get takePhotoAction => 'Take a picture';

  @override
  String get chooseFromLibraryAction => 'Choose from Library';

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
  String get backToLoginAction => 'Back to login';

  @override
  String get saveAction => 'Save';

  @override
  String get saveCredentialsButton => 'Save credentials';

  @override
  String get saveProfileButton => 'Save profile';

  @override
  String get sendResetLinkButton => 'Send reset link';

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

  @override
  String get authIntroSplitSmarter => 'Split smarter.';

  @override
  String get authIntroTravelFree => 'Travel free.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Track shared costs across currencies and settle up instantly - no awkward IOUs.';

  @override
  String get authIntroPlanTogether => 'Plan together.';

  @override
  String get authIntroPayClearly => 'Pay clearly.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Create trips in seconds, add friends, and keep every expense transparent for everyone.';

  @override
  String get authIntroSettleFast => 'Settle fast.';

  @override
  String get authIntroStayFriends => 'Stay friends.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'From shared dinners to full trips, Splyto keeps balances fair and stress-free.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Apple sign-in failed. Please try again.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Google sign-in failed. Please try again.';

  @override
  String get authIntroCreateAccount => 'Create your account.';

  @override
  String get authIntroChooseSign => 'Choose how you want to sign up.';

  @override
  String get authIntroContinueGoogle => 'Continue with Google';

  @override
  String get authIntroContinueApple => 'Continue with Apple';

  @override
  String get authIntroBack => 'Back';

  @override
  String get authIntroSplitSettled => 'Split settled';

  @override
  String get authIntroParis3Friends => 'Paris · 3 friends';

  @override
  String get authIntroGetStarted => 'Get started';

  @override
  String get authIntroAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get authIntroSignIn => 'Sign in';

  @override
  String get authIntroSignUpWithEmail => 'Sign up with email';

  @override
  String get authIntroOr => 'OR';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Google sign-in did not return an id token.';

  @override
  String get authAppleSignAvailableIosDevices => 'Apple sign-in is available on iOS devices.';

  @override
  String get authAppleSignNotAvailableDevice => 'Apple sign-in is not available on this device.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Apple sign-in did not return an identity token.';

  @override
  String get authAccountDeactivatedEnterEmailRequestReactivationLink => 'Account is deactivated. Enter your email to request a reactivation link.';

  @override
  String get authAccountDeactivated => 'Account is deactivated';

  @override
  String authSendReactivationLinkEmail(Object email) {
    return 'Send a reactivation link to $email?';
  }

  @override
  String get authCancel => 'Cancel';

  @override
  String get authSendLink => 'Send link';

  @override
  String get authReactivationLinkSentCheckEmail => 'Reactivation link sent. Check your email.';

  @override
  String get authCouldNotSendReactivationLinkPleaseTryAgain => 'Could not send reactivation link. Please try again.';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'Email is not verified. Enter your email to request verification link.';

  @override
  String get authEmailNotVerified => 'Email not verified';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Send verification link to $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Verification link sent. Check your email.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Could not send verification link. Please try again.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Verification email sent. Please verify your email before logging in.';

  @override
  String get authVerifyEmail => 'Verify your email';

  @override
  String get authEmailLabel => 'Email:';

  @override
  String get authClose => 'Close';

  @override
  String get authResendLink => 'Resend link';

  @override
  String get profileAppSettingsSectionTitle => 'APP SETTINGS';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileThemeDisplayMode => 'Theme & display mode';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileDisplayLanguage => 'Display language';

  @override
  String get profileNotificationsSectionHeading => 'NOTIFICATIONS';

  @override
  String get profileAppBanners => 'In-app banners';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Show new notification banners inside app';

  @override
  String get profilePushNotificationsTitle => 'Push notifications';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Phone notifications for expenses, friends, trips and settlements';

  @override
  String get profileSupportSectionHeading => 'SUPPORT';

  @override
  String get profileContactUs => 'Contact us';

  @override
  String get profileReportBugSuggestion => 'Report bug / Suggestion';

  @override
  String get profileRateSplyto => 'Rate Splyto';

  @override
  String get profileLeaveStoreRating => 'Leave a store rating';

  @override
  String get profileSecuritySectionHeading => 'SECURITY';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileUpdateAccountPassword => 'Update account password';

  @override
  String get profileDangerZoneSectionHeading => 'DANGER ZONE';

  @override
  String get profileDeactivateAccount => 'Deactivate account';

  @override
  String get profileManageAccountAccess => 'Manage account access';

  @override
  String get profileMadeWithLabel => 'Made with';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Store rating action will be connected in the next step.';

  @override
  String get profileFailedSaveNotificationSettings => 'Failed to save notification settings.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH NOTIFICATIONS';

  @override
  String get profileInAppBannersSectionTitle => 'IN-APP BANNERS';

  @override
  String get profileInAppTripMemberAddedTitle => 'Member added to trip';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatic settlement reminder';

  @override
  String get profileExpenseUpdates => 'Expense updates';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Expense added banners inside app';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Expense added notifications to phone';

  @override
  String get profileFriendInvites => 'Friend invites';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Friend request and response banners inside app';

  @override
  String get profileFriendRequestResponseNotifications => 'Friend request and response notifications';

  @override
  String get profileTripUpdates => 'Trip updates';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Trip lifecycle and member status banners inside app';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Trip lifecycle and member status changes';

  @override
  String get profileSettlementUpdates => 'Settlement updates';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Marked sent and confirmed payment banners inside app';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Marked sent and confirmed payment updates';

  @override
  String get profileScreenshotSizeMust8Mb => 'Screenshot size must be up to 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Send feedback';

  @override
  String get profileFeedbackTypeLabel => 'Type';

  @override
  String get profileFeedbackTypeBug => 'Bug';

  @override
  String get profileFeedbackTypeSuggestion => 'Suggestion';

  @override
  String get profileDescribeIssueSuggestion => 'Describe issue or suggestion';

  @override
  String get profilePickingImage => 'Picking image...';

  @override
  String get profileAttachScreenshot => 'Attach screenshot';

  @override
  String get profileChangeScreenshot => 'Change screenshot';

  @override
  String get profileRemoveImage => 'Remove image';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Tip: attach screenshot for faster bug triage';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Add details or attach screenshot before sending';

  @override
  String get profileSendAction => 'Send';

  @override
  String get profileThanksFeedbackSent => 'Thanks! Feedback sent';

  @override
  String get profileFailedSendFeedback => 'Failed to send feedback';

  @override
  String get profileCouldNotOpenWebsite => 'Could not open website.';

  @override
  String get profileOpenWebsiteQuestion => 'Open website?';

  @override
  String get profileOpenPortfolioAction => 'Open portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'This image format is not supported on this device. Please choose JPG or PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Set a valid email in Edit profile before changing password.';

  @override
  String get profileEditDeactivatedReactivationLinkEmailRestoreAccess => 'Account deactivated. Use reactivation link from email to restore access.';

  @override
  String get profileEditCouldNotDeactivateTryAgain => 'Could not deactivate account. Please try again.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Deletion link sent to your email.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Could not send deletion link. Please try again.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Enter current password to change email.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Verification was sent to the new email. Security notice was sent to your current email.';

  @override
  String get profileEditCouldNotStartEmailChangeRightNowTry => 'Could not start email change right now. Please try again.';

  @override
  String get profileEditOverviewCurrency => 'Overview currency';

  @override
  String get profileEditPaymentMethod => 'Payment method';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Bank transfer, Revolut, PayPal.me';

  @override
  String get profileEditDeactivateAccessRequestEmailLinkPermanentlyDeletePassword => 'You can deactivate account access or request an email link to permanently delete the account. Password is optional for Google/Apple accounts.';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Enter your password (optional for Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Send deletion link to email';

  @override
  String get profileEditBackProfile => 'Back to profile';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Set a valid email in profile before changing password.';

  @override
  String get profileEditPasswordUpdated => 'Password updated.';

  @override
  String get profileEditFailedUpdatePassword => 'Failed to update password.';

  @override
  String profileEditEmail(Object email) {
    return 'Account: $email';
  }

  @override
  String get profileEditPrimary => 'Primary';

  @override
  String get profileEditSearchCurrency => 'Search currency';

  @override
  String get profileEditNoCurrenciesFound => 'No currencies found';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Overview totals are converted to this currency.';

  @override
  String get profileEditPaymentInfoUpdated => 'Payment info updated.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Could not save payment info. Please try again.';

  @override
  String get profileEditCurrentPassword => 'Current password';

  @override
  String get profileEditBankTransferIbanSwift => 'Bank transfer (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me link';

  @override
  String get profileEditChoosePaymentMethod => 'Choose payment method';

  @override
  String get profileEditTapChange => 'Tap to change';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'For UK transfers, sort code must be 6 digits and account number 8 digits.';

  @override
  String get profileEditPaymentInfo => 'Payment info';

  @override
  String get profileEditSaveDetails => 'Save details';

  @override
  String get profileEditBankRegion => 'Bank region';

  @override
  String get profileEditEurope => 'Europe';

  @override
  String get profileEditSortCode => 'Sort code';

  @override
  String get profileEditExample112233 => 'Example: 112233';

  @override
  String get profileEditNumber => 'Account number';

  @override
  String get profileEdit8Digits => '8 digits';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'For UK domestic transfers use sort code + account number.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Example: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 or 11 chars';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Account holder name is taken from profile full name.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username or username';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'UK';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Adjust avatar';

  @override
  String get imageCropperAdjustTripImage => 'Adjust trip image';

  @override
  String get copyAction => 'Copy';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'British Pound';

  @override
  String get currencyNameChf => 'Swiss Franc';

  @override
  String get currencyNameNok => 'Norwegian Krone';

  @override
  String get currencyNameSek => 'Swedish Krona';

  @override
  String get currencyNameDkk => 'Danish Krone';

  @override
  String get currencyNamePln => 'Polish Zloty';

  @override
  String get currencyNameCzk => 'Czech Koruna';

  @override
  String get currencyNameHuf => 'Hungarian Forint';

  @override
  String get currencyNameRon => 'Romanian Leu';

  @override
  String get currencyNameBgn => 'Bulgarian Lev';

  @override
  String get currencyNameIsk => 'Icelandic Krona';

  @override
  String get currencyNameAll => 'Albanian Lek';

  @override
  String get currencyNameBam => 'Bosnia and Herzegovina Mark';

  @override
  String get currencyNameByn => 'Belarusian Ruble';

  @override
  String get currencyNameMdl => 'Moldovan Leu';

  @override
  String get currencyNameMkd => 'Macedonian Denar';

  @override
  String get currencyNameRsd => 'Serbian Dinar';

  @override
  String get currencyNameUah => 'Ukrainian Hryvnia';

  @override
  String get currencyNameGel => 'Georgian Lari';

  @override
  String get currencyNameTry => 'Turkish Lira';

  @override
  String get currencyNameUsd => 'US Dollar';

  @override
  String get currencyNameJpy => 'Japanese Yen';

  @override
  String get currencyNameCny => 'Chinese Yuan';

  @override
  String get currencyNameCad => 'Canadian Dollar';

  @override
  String get currencyNameAud => 'Australian Dollar';

  @override
  String get expenseCategoryFood => 'Food';

  @override
  String get expenseCategoryGroceries => 'Groceries';

  @override
  String get expenseCategoryFuel => 'Fuel';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryAccommodation => 'Accommodation';

  @override
  String get expenseCategoryActivities => 'Activities';

  @override
  String get expenseCategoryTickets => 'Tickets';

  @override
  String get expenseCategoryShopping => 'Shopping';

  @override
  String get expenseCategoryParty => 'Party';

  @override
  String get expenseCategoryParking => 'Parking';

  @override
  String get expenseCategoryOther => 'Other';

  @override
  String get shellTripAlreadyInListOpened => 'Trip already in your list. Opened it for you.';

  @override
  String get shellJoinedTripFromInviteLink => 'Joined trip from invite link.';

  @override
  String get shellFailedToOpenInviteLink => 'Failed to open invite link.';

  @override
  String get shellTripInviteTitle => 'Trip invite';

  @override
  String get shellNoAction => 'No';

  @override
  String get shellYesAction => 'Yes';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Only trip creator can delete this trip.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Only active trips can be deleted.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Delete \"$tripLabel\"? This is allowed only before any expenses are added.';
  }

  @override
  String get shellTripDeleted => 'Trip deleted.';

  @override
  String get shellFailedToDeleteTrip => 'Failed to delete trip.';

  @override
  String get shellFailedToLoadNotifications => 'Failed to load notifications.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'New notification: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Failed to update notifications.';

  @override
  String get shellMarkAllAsReadAction => 'Mark all as read';

  @override
  String get shellNewSection => 'New';

  @override
  String get shellEarlierSection => 'Earlier';

  @override
  String get shellShowMoreEarlierAction => 'Show more earlier';

  @override
  String get shellLoadingMore => 'Loading more...';

  @override
  String get shellLoadMoreNotificationsAction => 'Load more notifications';

  @override
  String get shellTripNoLongerAvailable => 'This trip is no longer available.';

  @override
  String get shellFailedToOpenTrip => 'Failed to open trip.';

  @override
  String get shellYesterday => 'Yesterday';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'You are already a member of \"$tripName\". Open this trip now?\n\nInvited by: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Do you want to join trip \"$tripName\"?\n\nInvited by: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Selected image: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Trip image already set.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Trip created, but image upload failed.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Trip created, but image upload failed: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Join trip via invite';

  @override
  String get tripsTotalTrips => 'Total trips';

  @override
  String get tripsTotalSpent => 'Total spent';

  @override
  String get tripsMixedCurrencies => 'Mixed currencies';

  @override
  String get tripsShowActive => 'Show active';

  @override
  String get tripsSeeAll => 'See all';

  @override
  String get tripsAddNewTrip => 'Add new trip';

  @override
  String get tripsLoadMore => 'Load more';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Delete \"$arg1\"? This is allowed only before any expenses are added.';
  }

  @override
  String get tripsTripDates => 'Trip dates';

  @override
  String get tripsFrom => 'From';

  @override
  String get tripsSelectDate => 'Select date';

  @override
  String get tripsTo => 'To';

  @override
  String get tripsMainCurrency => 'Main currency';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Please select trip period (from and to dates).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Trip end date must be on or after start date.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Trip period format is invalid. Please pick dates again.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'You are already a member of this trip.';

  @override
  String get tripsJoinedTripSuccessfully => 'Joined trip successfully.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Failed to join trip from invite.';

  @override
  String get tripsJoinTrip => 'Join trip';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Paste invite link or invite token.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Enter a valid invite link or token.';

  @override
  String get tripsClipboardIsEmpty => 'Clipboard is empty.';

  @override
  String get tripsPaste => 'Paste';

  @override
  String get tripsJoin => 'Join';

  @override
  String get workspaceTripMembers => 'Trip members';

  @override
  String get workspaceFailedToLoadFriends => 'Failed to load friends.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Failed to generate invite link.';

  @override
  String get workspaceInviteLink => 'Invite link';

  @override
  String get workspaceGeneratingInviteLink => 'Generating invite link...';

  @override
  String get workspaceInviteLinkUnavailable => 'Invite link unavailable.';

  @override
  String get workspaceCopyInviteLink => 'Copy invite link';

  @override
  String get workspaceInviteLinkCopied => 'Invite link copied.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Expires: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'No friends available. Add friends first.';

  @override
  String get workspaceSettle => 'Settle';

  @override
  String get workspaceOwesToTheGroup => 'Owes to the group';

  @override
  String get workspaceGetsBackFromGroup => 'Gets back from group';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Showing top 4 by balance difference.';

  @override
  String get workspaceOpenFlow => 'Open flow';

  @override
  String get workspaceFriend => 'Friend';

  @override
  String get workspaceSettlementTransfer => 'Settlement transfer';

  @override
  String get workspaceCompleted => 'Completed';

  @override
  String get workspaceWaitingForConfirmation => 'Waiting for confirmation';

  @override
  String get workspaceWaitingForPayment => 'Waiting for payment';

  @override
  String get workspaceActionNeeded => 'Action needed';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return '$arg1 payment(s) to mark as sent, $arg2 to confirm as received.';
  }

  @override
  String get workspaceReadyToSettle => 'Ready to settle';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'All members are ready. You can start settlements.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Waiting for everyone to mark ready.';

  @override
  String get workspaceIMReady => 'I\'m ready';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Confirm that you added all your expenses.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Finish button unlocks once everyone marks ready.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Gets back from the group';

  @override
  String get workspaceSettledWithTheGroup => 'Settled with the group';

  @override
  String get workspaceTotalPaid => 'Total Paid';

  @override
  String get workspaceTotalOwes => 'Total Owes';

  @override
  String get workspaceTransactionHistory => 'Transaction history';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'No transactions yet for this member.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Settlements: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'All members must mark ready before starting settlements.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'You marked yourself ready to settle.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Ready-to-settle mark removed.';

  @override
  String get workspaceReminderSent => 'Reminder sent.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Invite link or add from friends';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Only trip creator can edit this trip.';

  @override
  String get workspaceTripUpdated => 'Trip updated.';

  @override
  String get workspaceFailedToUpdateTrip => 'Failed to update trip.';

  @override
  String get workspaceNoMembersSelectedYet => 'No members selected yet.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'No internet. Expense will be saved without receipt image.';

  @override
  String get workspaceRandomPicker => 'Random picker';

  @override
  String get workspaceCurrency => 'Currency';

  @override
  String get workspaceCategory => 'Category';

  @override
  String get workspaceCustomCategory => 'Custom category';

  @override
  String get workspaceCategoryName => 'Category name';

  @override
  String get workspaceApartmentRentParkingEtc => 'Apartment rent, parking, etc.';

  @override
  String get workspaceEnterACustomCategory => 'Enter a custom category.';

  @override
  String get workspacePickAnExpenseCategory => 'Pick an expense category.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Category must be at least 2 characters.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Category must be up to 64 characters.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Percentage split must total 100%.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Shares must be greater than 0 for all participants.';

  @override
  String get workspaceTotalAmount => 'Total amount';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Total cost';

  @override
  String workspaceStarted(Object arg1) {
    return 'Started $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Ended $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Archived trip';

  @override
  String get workspaceActiveTrip => 'Active trip';

  @override
  String get workspaceMemberProfile => 'Member profile';

  @override
  String get workspaceTripOwner => 'Trip owner';

  @override
  String get workspaceMember => 'Member';

  @override
  String get workspaceReadyForSettlement => 'Ready for settlement';

  @override
  String get workspaceNotReadyForSettlement => 'Not ready for settlement';

  @override
  String get workspaceBankDetails => 'Bank details';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN and payout details will be added here in a next update.';

  @override
  String get workspacePaymentDetails => 'Payment details';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'This member has not added payout details yet.';

  @override
  String get workspaceBankTransfer => 'Bank transfer';

  @override
  String get workspaceHolder => 'Holder';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Could not open payment link.';

  @override
  String get workspaceTripActivity => 'Trip activity';

  @override
  String get workspacePaidExpenses => 'Paid expenses';

  @override
  String get workspacePaidTotal => 'Paid total';

  @override
  String get workspaceInvolvedIn => 'Involved in';

  @override
  String get workspaceCurrentTrip => 'Current trip';

  @override
  String get workspaceCommonTrips => 'Common trips';

  @override
  String get workspaceLoadingCommonTrips => 'Loading common trips...';

  @override
  String get workspaceNoCommonTripsFoundYet => 'No common trips found yet.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Could not load all common trips. Showing current one.';

  @override
  String get workspaceMembers => 'members';

  @override
  String get workspaceExpense => 'Expense';

  @override
  String get workspacePaid => 'paid';

  @override
  String get workspaceLoadingMoreExpenses => 'Loading more expenses...';

  @override
  String get workspaceScrollDownToLoadMore => 'Scroll down to load more';

  @override
  String get workspaceTripFinished => 'Trip finished';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Settlements are unlocked for this trip.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Finish trip to start settlements.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 marked transfer as sent.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Waiting for $arg1 to mark as paid.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 confirmed receiving the payment.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Waiting for $arg1 to confirm.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'All trip settlements are fully completed.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Final state after all transfers are confirmed.';

  @override
  String get workspaceSettlementFlow => 'Settlement flow';

  @override
  String get workspaceActions => 'Actions';

  @override
  String get workspaceQuickPay => 'Quick pay';

  @override
  String get workspacePayWithRevolut => 'Pay with Revolut';

  @override
  String get workspacePayWithPaypal => 'Pay with PayPal';

  @override
  String get workspacePayWithWise => 'Pay with Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Transfer is confirmed.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Waiting for the other member to complete the next step.';

  @override
  String get workspaceSendReminder => 'Send reminder';

  @override
  String get workspaceInProgress => 'In progress';

  @override
  String get workspaceTimeUnknown => 'Time unknown';

  @override
  String get workspaceRemind => 'Remind';

  @override
  String get workspaceYourPosition => 'Your position';

  @override
  String get workspaceRecentActivity => 'Recent activity';

  @override
  String get workspaceNoRecentActivityYet => 'No recent activity yet.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Add at least one member to start splitting expenses.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Mark yourself ready to settle after adding all your expenses.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Waiting for $arg1 member(s) to mark ready.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'All members are ready. You can finish the trip and start settlements.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'All members are ready. Waiting for the trip owner to start settlements.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Settlement in progress: $arg1/$arg2 confirmed.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'No actions pending. This trip is settled.';

  @override
  String get workspaceNoActionsNeededRightNow => 'No actions needed right now.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'You should receive $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'You should pay $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'You are currently settled in this trip.';

  @override
  String get workspaceUnknownTime => 'Unknown time';

  @override
  String get workspaceJustNow => 'Just now';

  @override
  String workspaceMinAgo(Object arg1) {
    return '$arg1 min ago';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return '$arg1 h ago';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return '$arg1 d ago';
  }

  @override
  String get friendsRemoveFriend => 'Remove friend';

  @override
  String get friendsRemoveThisFriend => 'Remove this friend?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 will be removed from your friends list. You can add them again later.';
  }

  @override
  String get friendsContinue => 'Continue';

  @override
  String get friendsFriendRemoved => 'Friend removed.';

  @override
  String get friendsCouldNotRemoveFriend => 'Could not remove friend.';

  @override
  String get friendsFriendProfile => 'Friend profile';

  @override
  String get friendsMoreActions => 'More actions';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'This friend has not added payout details yet.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Could not load common trips right now.';

  @override
  String get friendsFinished => 'Finished';

  @override
  String friendsTrip(Object arg1) {
    return 'Trip #$arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return '$arg1 members';
  }

  @override
  String get friendsNoDate => 'No date';

  @override
  String get friendsIncomingRequests => 'INCOMING REQUESTS';

  @override
  String get friendsSentInvites => 'SENT INVITES';

  @override
  String get friendsMyFriends => 'MY FRIENDS';

  @override
  String get friendsIncoming => 'Incoming';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Invite sent to $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'No incoming requests';

  @override
  String get friendsDecline => 'Decline';

  @override
  String get friendsAccept => 'Accept';

  @override
  String get friendsNoSentInvites => 'No sent invites';

  @override
  String get friendsNoFriendsYet => 'No friends yet';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Scroll down to load more friends.';

  @override
  String get friendsUser => 'User';

  @override
  String get friendsSearchUsers => 'Search users';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Find by name or email and send invite';

  @override
  String get friendsScanQr => 'Scan QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Scan another user to add friend';

  @override
  String get friendsMyQr => 'My QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Show or share your QR code';

  @override
  String get friendsScanFriendQrTitle => 'Scan Friend QR';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Place friend QR code inside the frame';

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Open Friends > Scan QR on another phone and scan this code.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Add me on TripSplit friends.';

  @override
  String get friendsTripSplitFriendCode => 'TripSplit friend code';

  @override
  String get shareAction => 'Share';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'QR code is not a valid friend code.';

  @override
  String get friendsYouCannotAddYourself => 'You cannot add yourself.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'This user is already in your friends list.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Invite to this user is already sent.';

  @override
  String get friendsFriendRequestProcessed => 'Friend request processed.';

  @override
  String get friendsFailedToProcessFriendQr => 'Failed to process friend QR.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Could not load your user profile.';

  @override
  String get friendsMyProfile => 'My profile';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Unexpected error loading friends.';

  @override
  String get friendsFriendAdded => 'Friend added.';

  @override
  String get friendsRequestDeclined => 'Request declined.';

  @override
  String get friendsFailedToUpdateRequest => 'Failed to update request.';

  @override
  String get friendsCancelInvite => 'Cancel invite';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Cancel invite to $arg1?';
  }

  @override
  String get friendsKeep => 'Keep';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Invite to $arg1 cancelled.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Failed to cancel invite.';

  @override
  String get analyticsOther => 'Other';

  @override
  String get analyticsSelectATripForAnalytics => 'Select a trip for analytics';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • $arg2 members • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Daily spending';

  @override
  String get analyticsMyDaily => 'My daily';

  @override
  String get analyticsGroupDaily => 'Group daily';

  @override
  String get analyticsByMember => 'By Member';

  @override
  String get analyticsShowLess => 'Show less';

  @override
  String get analyticsByCategory => 'By Category';

  @override
  String get analyticsQuickInsights => 'Quick insights';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Biggest expense: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Top spender: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Highest group day: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'No dates';

  @override
  String get friendsSearchFailedTryAgain => 'Search failed. Try again.';

  @override
  String get friendsFailedToSendInvite => 'Failed to send invite.';

  @override
  String get friendsAddFriend => 'Add friend';

  @override
  String get friendsSearchByNameOrEmail => 'Search by name or email';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Type at least 2 characters to search.';

  @override
  String get friendsNoUsersFound => 'No users found';

  @override
  String get friendsInviteAction => 'Invite';

  @override
  String get workspacePaidForGroup => 'Paid for group';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Paid for group • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Share of expense';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Share of expense • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Holder name copied.';

  @override
  String get paymentIbanCopied => 'IBAN copied.';

  @override
  String get paymentSwiftCopied => 'SWIFT copied.';

  @override
  String get paymentRevtagCopied => 'Revtag copied.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Could not copy to clipboard.';

  @override
  String get paymentCopied => 'Copied.';
}
