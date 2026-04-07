// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get accountSectionTitle => 'Konts';

  @override
  String get activeStatus => 'Aktīvs';

  @override
  String get activeTripPlural => 'aktīvi ceļojumi';

  @override
  String get activeTripSingle => 'aktīvs ceļojums';

  @override
  String get activeTrips => 'Aktīvie ceļojumi';

  @override
  String get activitiesComingSoon => 'Aktivitāšu sadaļa drīzumā.';

  @override
  String get addAction => 'Pievienot';

  @override
  String get addExpenseTitle => 'Pievienot izdevumu';

  @override
  String get addExpensesAction => 'Pievienot izdevumus';

  @override
  String get addMembersAction => 'Pievienot dalībniekus';

  @override
  String get addTripMembersTitle => 'Pievienot ceļojuma dalībniekus';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pievienoti $count dalībnieki.',
      one: 'Pievienots $count dalībnieks.',
    );
    return '$_temp0';
  }

  @override
  String get allCaughtUp => 'Viss nokārtots';

  @override
  String get allFilter => 'Visi';

  @override
  String get allMembersLabel => 'Visi dalībnieki';

  @override
  String get allPaymentsConfirmed => 'Visi maksājumi ir apstiprināti.';

  @override
  String get allTrips => 'Visi ceļojumi';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Summa';

  @override
  String get amountMustBeGreaterThanZero => 'Summai jābūt lielākai par 0.';

  @override
  String get appearance => 'Izskats';

  @override
  String get archivedStatus => 'Arhivēts';

  @override
  String get authSubtitleLogin => 'Daliet ceļojuma izdevumus ar draugiem';

  @override
  String get authSubtitleRegister => 'Izveido kontu un sāc dalīt ceļojuma izdevumus';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'apstiprināti: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'gaida: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'nosūtīti: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'ieteikti: $count';
  }

  @override
  String get cancelAction => 'Atcelt';

  @override
  String get changeEmailWithPasswordHelper => 'Lai mainītu e-pastu, ievadi paroli.';

  @override
  String get chooseReceiptFile => 'Izvēlēties čeka failu';

  @override
  String get completeAccountSetupDescription => 'Iestati e-pastu un paroli, lai pabeigtu konta iestatīšanu.';

  @override
  String get completeAccountSetupTitle => 'Pabeigt konta iestatīšanu';

  @override
  String get confirmReceivedAction => 'Apstiprināt saņemšanu';

  @override
  String get confirmedAllSettlementsArchived => 'Visi norēķini apstiprināti. Ceļojums arhivēts.';

  @override
  String get confirmedAsReceived => 'Apstiprināts kā saņemts.';

  @override
  String get confirmedLabel => 'Apstiprināts';

  @override
  String get couldNotOpenReceiptLink => 'Neizdevās atvērt čeka saiti.';

  @override
  String get createAction => 'Izveidot';

  @override
  String get createFirstTripHint => 'Izveido savu pirmo ceļojumu, lai sāktu.';

  @override
  String get createNewTripTitle => 'Izveidot jaunu ceļojumu';

  @override
  String get createTripAction => 'Izveidot ceļojumu';

  @override
  String get createTripFirst => 'Vispirms izveido ceļojumu.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date - Izveidoja $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Lai sāktu norēķinu apstiprināšanu, ceļojumu jāpabeidz izveidotājam.';

  @override
  String currentEmailLabel(Object email) {
    return 'Pašreizējais e-pasts: $email';
  }

  @override
  String get currentReceiptAttached => 'Esošais čeks ir pievienots.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Datums';

  @override
  String get dateMustMatchFormat => 'Datumam jāatbilst formātam GGGG-MM-DD.';

  @override
  String get dateUnknown => 'Datums nav zināms';

  @override
  String get deleteAction => 'Dzēst';

  @override
  String get deleteExpenseConfirmQuestion => 'Vai dzēst šo izdevumu?';

  @override
  String get deleteExpenseTitle => 'Dzēst izdevumu';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Tieši izskaidrots ar izdevumiem: $amount';
  }

  @override
  String get doneStatus => 'Pabeigts';

  @override
  String get editAction => 'Rediģēt';

  @override
  String get editExpenseTitle => 'Rediģēt izdevumu';

  @override
  String get emailAddressLabel => 'E-pasta adrese';

  @override
  String get emailHint => 'tu@example.com';

  @override
  String get emailLabel => 'E-pasts';

  @override
  String get emailRequired => 'E-pasts ir obligāts.';

  @override
  String get enterValidExactAmounts => 'Ievadi derīgas precīzās summas visiem dalībniekiem.';

  @override
  String get enterValidPercentages => 'Ievadi derīgus procentus visiem dalībniekiem.';

  @override
  String get equalSplitLabel => 'Vienāda sadale';

  @override
  String exactAmountWithValue(Object value) {
    return 'Precīzi: $value';
  }

  @override
  String get exactAmountsLabel => 'Precīzās summas';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Precīzajai sadalei jāsummējas līdz $amount.';
  }

  @override
  String get expenseAdded => 'Izdevums pievienots.';

  @override
  String get expenseBreakdownSubtitle => 'Kā šo dalībnieku ietekmē katrs izdevums.';

  @override
  String get expenseBreakdownTitle => 'Izdevumu sadalījums';

  @override
  String get expenseDeleted => 'Izdevums dzēsts.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Izdevums #$id - $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date - Samaksāts $paid - Jāmaksā $owes';
  }

  @override
  String get expenseUpdated => 'Izdevums atjaunināts.';

  @override
  String expenseWithId(Object id) {
    return 'Izdevums #$id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count izdevumi',
      one: '$count izdevums',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Izdevumi';

  @override
  String get failedToCreateTrip => 'Neizdevās izveidot ceļojumu.';

  @override
  String get failedToLoadUsersDirectory => 'Neizdevās ielādēt lietotāju sarakstu.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrēt norēķinus pēc dalībnieka';

  @override
  String get finishTripAction => 'Pabeigt ceļojumu';

  @override
  String get finishTripConfirmationText => 'Pabeigt šo ceļojumu un sākt norēķinus?';

  @override
  String get finishTripStartSettlementsAction => 'Pabeigt ceļojumu un sākt norēķinus';

  @override
  String get finishTripTitle => 'Pabeigt ceļojumu';

  @override
  String forParticipants(Object participants) {
    return 'Dalībniekiem: $participants';
  }

  @override
  String get forgotPassword => 'Aizmirsi paroli?';

  @override
  String get forgotPasswordSubtitle => 'Ievadi savu e-pastu, un mēs nosūtīsim paroles atiestatīšanas saiti.';

  @override
  String get forgotPasswordSuccessMessage => 'Ja konts ar šo e-pastu eksistē, paroles atiestatīšanas saite ir nosūtīta.';

  @override
  String get forgotPasswordTitle => 'Atiestatīt paroli';

  @override
  String get friendsProgressSubtitle => 'Katrs dalībnieks un viņa apstiprinājumu statuss.';

  @override
  String get friendsProgressTitle => 'Draugu progress';

  @override
  String get friendsSectionComingSoon => 'Draugu sadaļa drīzumā.';

  @override
  String fromDirection(Object name) {
    return 'No $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from -> $to';
  }

  @override
  String get generateTurnAction => 'Izlozēt kārtu';

  @override
  String get hasAccountQuestion => 'Jau ir konts?';

  @override
  String helloUser(Object name) {
    return 'Sveiki, $name!';
  }

  @override
  String get iSentAction => 'Es nosūtīju';

  @override
  String get invalidEmailFormat => 'Nederīgs e-pasta formāts.';

  @override
  String get languageAction => 'Valoda';

  @override
  String get languageEnglish => 'Angļu';

  @override
  String get languageLatvian => 'Latviešu';

  @override
  String get languageSystem => 'Sistēma';

  @override
  String get languageSystemSubtitle => 'Izmantot ierīces valodu';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Atstāj tukšu, lai parole paliktu nemainīta.';

  @override
  String get logInButton => 'Pieslēgties';

  @override
  String get logOutButton => 'Iziet';

  @override
  String get logoutFromDeviceQuestion => 'Iziet no šīs ierīces?';

  @override
  String get markedAsSent => 'Atzīmēts kā nosūtīts.';

  @override
  String get memberSummariesSubtitle => 'Pašreizējais bilances stāvoklis abām pusēm.';

  @override
  String get memberSummariesTitle => 'Dalībnieku kopsavilkumi';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Jāmaksā $total - apstiprināts $confirmed - gaida $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Aptuvenā maksājumu ietekme katram dalībniekam.';

  @override
  String get membersImpactTitle => 'Dalībnieku ietekme';

  @override
  String get membersIncludedInExpense => 'Izdevumā iekļautie dalībnieki';

  @override
  String get membersLabel => 'Dalībnieki';

  @override
  String moreCount(Object count) {
    return '+vēl $count';
  }

  @override
  String get myFilter => 'Mani';

  @override
  String get myImpactTitle => 'Mana ietekme';

  @override
  String get firstNameHint => 'Tavs vārds';

  @override
  String get firstNameLabel => 'Vārds';

  @override
  String get firstNameLengthValidation => 'Vārdam jābūt 2-64 rakstzīmes garam.';

  @override
  String get fullNameHelper => 'Ievadi vārdu un uzvārdu vienā laukā.';

  @override
  String get fullNameHint => 'piem. Anna Ozoliņa';

  @override
  String get fullNameLabel => 'Vārds un uzvārds';

  @override
  String get fullNameValidation => 'Ievadi vārdu un uzvārdu (katram vismaz 2 rakstzīmes).';

  @override
  String get lastNameHint => 'Tavs uzvārds';

  @override
  String get lastNameLabel => 'Uzvārds';

  @override
  String get lastNameLengthValidation => 'Uzvārdam jābūt 2-64 rakstzīmes garam.';

  @override
  String get nameHint => 'Tavs vārds';

  @override
  String get nameLabel => 'Vārds';

  @override
  String get nameLengthValidation => 'Vārdam jābūt vismaz 2 rakstzīmēm.';

  @override
  String get navActivities => 'Analītika';

  @override
  String get navAddTrip => 'Pievienot';

  @override
  String get navBalances => 'Bilances';

  @override
  String get navExpenses => 'Izdevumi';

  @override
  String get navFriends => 'Draugi';

  @override
  String get navHome => 'Sākums';

  @override
  String get navProfile => 'Profils';

  @override
  String get navRandom => 'Izloze';

  @override
  String get netLabel => 'Neto';

  @override
  String get newPasswordLabel => 'Jaunā parole';

  @override
  String get nicknameHint => 'Kā tevi redzēs draugi';

  @override
  String get nicknameLabel => 'Segvārds';

  @override
  String get nicknameLengthValidation => 'Segvārdam jābūt vismaz 2 rakstzīmēm.';

  @override
  String get noAccountQuestion => 'Nav konta?';

  @override
  String get noBalancesYet => 'Bilances vēl nav.';

  @override
  String get noChangesToSave => 'Nav izmaiņu, ko saglabāt.';

  @override
  String get noDirectExpenseLink => 'Nav tiešas saites ar vienu izdevumu. Šis norēķins ir aprēķināts no kopējās ceļojuma bilances.';

  @override
  String get noExpenseImpactForMember => 'Šim dalībniekam nav izdevumu ietekmes.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Lietotājam $name vēl nav izdevumu.';
  }

  @override
  String get noExpensesYet => 'Izdevumu vēl nav.';

  @override
  String get noExtraUsersToAdd => 'Nav papildu lietotāju, ko pievienot.';

  @override
  String get noInternetDeleteQueued => 'Nav interneta. Dzēšana ievietota rindā.';

  @override
  String get noInternetExpenseQueued => 'Nav interneta. Izdevums ievietots rindā.';

  @override
  String get noInternetUpdateQueued => 'Nav interneta. Atjauninājums ievietots rindā.';

  @override
  String get noMatchingRows => 'Nav atbilstošu rindu.';

  @override
  String get noMembersFound => 'Dalībnieki nav atrasti.';

  @override
  String get noNewMembersAdded => 'Netika pievienoti jauni dalībnieki.';

  @override
  String get noNotePlaceholder => 'Nav piezīmes';

  @override
  String get noNotificationsYet => 'Paziņojumu vēl nav.';

  @override
  String get noParticipantData => 'Nav dalībnieku datu.';

  @override
  String get noParticipantsSelected => 'Nav izvēlētu dalībnieku.';

  @override
  String get noPaymentRowsInTrip => 'Šajā ceļojumā nav maksājumu rindu.';

  @override
  String get noPaymentsNeeded => 'Maksājumi nav nepieciešami.';

  @override
  String get noPicksYet => 'Izložu vēl nav.';

  @override
  String get noSettlementActivityForMember => 'Šim dalībniekam nav norēķinu aktivitātes.';

  @override
  String get noSettlementRowsYet => 'Norēķinu rindu vēl nav.';

  @override
  String get noSettlements => 'Norēķinu nav';

  @override
  String get noTransferNeededForFilter => 'Izvēlētajam filtram pārskaitījumi nav nepieciešami.';

  @override
  String get noTransferRowsToShow => 'Nav pārskaitījumu rindu, ko rādīt.';

  @override
  String get noTripDataLoaded => 'Ceļojuma dati nav ielādēti.';

  @override
  String get noTripsYet => 'Ceļojumu vēl nav.';

  @override
  String get noUsersFoundYet => 'Lietotāji vēl nav atrasti.';

  @override
  String get notSetValue => 'Nav iestatīts';

  @override
  String get notYetConfirmedTitle => 'Vēl nav apstiprināts';

  @override
  String get noteHint => 'Vakariņas, taksis, biļetes...';

  @override
  String get noteLabel => 'Piezīme';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Piezīme nedrīkst pārsniegt $max rakstzīmes.';
  }

  @override
  String get notificationFallbackTitle => 'Paziņojums';

  @override
  String get notificationsTitle => 'Paziņojumi';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neapstrādātas izmaiņas',
      one: '$count neapstrādāta izmaiņa',
    );
    return 'Bezsaistes rinda: $_temp0';
  }

  @override
  String get offlineQueueStatus => 'Bezsaistes rinda';

  @override
  String get offlineStatus => 'Bezsaistē';

  @override
  String get onlineStatus => 'Tiešsaistē';

  @override
  String get onlyCreatorCanFinishTrip => 'Tikai ceļojuma izveidotājs var pabeigt ceļojumu.';

  @override
  String get openLabel => 'Atvērts';

  @override
  String get openReceiptAction => 'Atvērt čeku';

  @override
  String get openSettlements => 'Atvērt norēķinus';

  @override
  String get overviewTitle => 'Pārskats';

  @override
  String get owesLabel => 'Jāmaksā';

  @override
  String get paidByLabel => 'Samaksāja';

  @override
  String get paidLabel => 'Samaksāts';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Samaksāts $paid - Jāmaksā $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Dalībnieki (tukšs = visi dalībnieki)';

  @override
  String get participantsTitle => 'Dalībnieki';

  @override
  String get passwordLabel => 'Parole';

  @override
  String get passwordComplexityHelper => 'Izmanto vismaz 1 lielo burtu, 1 ciparu un 1 simbolu.';

  @override
  String get passwordComplexityValidation => 'Parolei jāietver 1 lielais burts, 1 cipars un 1 simbols.';

  @override
  String get passwordMinLength => 'Parolei jābūt vismaz 8 rakstzīmēm.';

  @override
  String get passwordMinLengthShort => 'Parolei jābūt vismaz 6 rakstzīmēm.';

  @override
  String get passwordResetComingSoon => 'Paroles atjaunošana drīzumā.';

  @override
  String get passwordsDoNotMatch => 'Paroles nesakrīt.';

  @override
  String payerName(Object name) {
    return '$name (maksātājs)';
  }

  @override
  String get pendingLabel => 'Gaida';

  @override
  String get pendingPaymentsSubtitle => 'Maksājumi vēl gaida pilnu apstiprinājumu.';

  @override
  String get percentLabel => 'Procenti';

  @override
  String get percentSplitMustBe100 => 'Procentu sadalei jābūt tieši 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Procenti';

  @override
  String get pickAtLeastOneParticipant => 'Izvēlies vismaz vienu dalībnieku.';

  @override
  String get pickMembersGenerateTurn => 'Izvēlies dalībniekus un izlozē kārtu.';

  @override
  String pickedCycleCompleted(Object name) {
    return 'Izlozēts $name. Cikls pabeigts.';
  }

  @override
  String pickedUser(Object name) {
    return 'Izlozēts $name.';
  }

  @override
  String get profileRefreshCachedData => 'Neizdevās atjaunot profilu. Tiek rādīti saglabātie dati.';

  @override
  String get profileTitle => 'Profils';

  @override
  String get profileUpdated => 'Profils atjaunināts.';

  @override
  String get uploadAvatarAction => 'Augšupielādēt avataru';

  @override
  String get takePhotoAction => 'Uzņemt bildi';

  @override
  String get chooseFromLibraryAction => 'Izvēlēties no galerijas';

  @override
  String get removeAvatarAction => 'Noņemt avataru';

  @override
  String get avatarUpdatedMessage => 'Avatars atjaunināts.';

  @override
  String get avatarRemovedMessage => 'Avatars noņemts.';

  @override
  String get avatarFileTooLarge => 'Avatar faila izmērs ir par lielu (maks. 5 MB).';

  @override
  String get avatarPickFailed => 'Neizdevās ielādēt avatar attēlu.';

  @override
  String get queueAddExpense => 'Pievienot izdevumu';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'Rindā: pievienot izdevumu $amount';
  }

  @override
  String get queueDeleteExpense => 'Dzēst izdevumu';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'Rindā: dzēst izdevumu #$id';
  }

  @override
  String get queuePendingStatus => 'Rindā gaida';

  @override
  String get queueUpdateExpense => 'Atjaunināt izdevumu';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'Rindā: atjaunināt izdevumu #$id';
  }

  @override
  String get queuedChange => 'Rindā esoša izmaiņa';

  @override
  String queuedChangesTitle(Object count) {
    return 'Rindā esošās izmaiņas ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'Rindā ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cikls $cycleNo, izloze $drawNo - atlikuši $remaining';
  }

  @override
  String get receiptFallbackName => 'ceks';

  @override
  String get receiptLinkInvalid => 'Čeka saite nav derīga.';

  @override
  String get receiptOptionalLabel => 'Čeks (neobligāti)';

  @override
  String get recentPicksTitle => 'Pēdējās izlozes';

  @override
  String get reloadProfile => 'Pārlādēt profilu';

  @override
  String get rememberMe => 'Atcerēties mani';

  @override
  String get removeCurrentReceipt => 'Noņemt esošo čeku';

  @override
  String get repeatNewPasswordLabel => 'Atkārtot jauno paroli';

  @override
  String get repeatPasswordLabel => 'Atkārtot paroli';

  @override
  String get requestFailedTryAgain => 'Pieprasījums neizdevās. Mēģini vēlreiz.';

  @override
  String get retryAction => 'Mēģināt vēlreiz';

  @override
  String get rowsLabel => 'Rindas';

  @override
  String get backToLoginAction => 'Atpakaļ uz pieslēgšanos';

  @override
  String get saveAction => 'Saglabāt';

  @override
  String get saveCredentialsButton => 'Saglabāt piekļuves datus';

  @override
  String get saveProfileButton => 'Saglabāt profilu';

  @override
  String get sendResetLinkButton => 'Nosūtīt atiestatīšanas saiti';

  @override
  String get searchUsersHint => 'Meklē cilvēkus pēc vārda vai e-pasta';

  @override
  String get selectedPeopleLabel => 'Izvēlētie cilvēki';

  @override
  String get noSearchMatches => 'Atbilstoši lietotāji nav atrasti.';

  @override
  String get savingButton => 'Saglabā...';

  @override
  String get selectAtLeastTwoMembers => 'Izvēlies vismaz divus dalībniekus.';

  @override
  String get selectMembersHint => 'Izvēlies dalībniekus';

  @override
  String selectedFileLabel(Object name) {
    return 'Izvēlēts: $name';
  }

  @override
  String get selectedLabel => 'Izvēlēts';

  @override
  String get selectedUserFallback => 'Izvēlētais lietotājs';

  @override
  String get settings => 'Iestatījumi';

  @override
  String get settleUpAction => 'Norēķināties';

  @override
  String get settledLabel => 'Norēķināts';

  @override
  String get settledStatus => 'Norēķināts';

  @override
  String get settlementActivitySubtitle => 'Pārskaitījumi, kas saistīti ar šo dalībnieku.';

  @override
  String get settlementActivityTitle => 'Norēķinu aktivitāte';

  @override
  String get settlementCompletedTitle => 'Norēķini pabeigti';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed/$total apstiprināti';
  }

  @override
  String settlementCountLabel(Object count) {
    return '$count norēķini';
  }

  @override
  String get settlementImpactTitle => 'Norēķinu ietekme';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Norēķinu ietekme: $name';
  }

  @override
  String get settlementInProgress => 'Norēķini procesā';

  @override
  String get settlementInProgressTitle => 'Norēķini procesā';

  @override
  String get settlementLabel => 'Norēķins';

  @override
  String get settlementOverviewArchivedSubtitle => 'Ceļojums arhivēts. Visi norēķini pabeigti.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Seko norēķinu apstiprinājumiem.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Pārskaitījumu priekšskatījums pēc ceļojuma beigām.';

  @override
  String get settlementPreview => 'Norēķinu priekšskatījums';

  @override
  String get settlementPreviewTitle => 'Norēķinu priekšskatījums';

  @override
  String get settlementProgressTripArchived => 'Ceļojums arhivēts';

  @override
  String settlementWithId(Object id) {
    return 'Norēķins #$id';
  }

  @override
  String get settlements => 'Norēķini';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Norēķini jau pabeigti.';

  @override
  String get settlementsDone => 'Norēķini pabeigti';

  @override
  String get settlingStatus => 'Norēķini';

  @override
  String get shareUnit => 'daļa';

  @override
  String get sharesLabel => 'Daļas';

  @override
  String get sharesMustBePositiveIntegers => 'Daļām jābūt pozitīviem veseliem skaitļiem.';

  @override
  String sharesWithValue(Object value) {
    return 'Daļas: $value';
  }

  @override
  String get showActiveTrips => 'Rādīt aktīvos ceļojumus';

  @override
  String get signUpButton => 'Reģistrēties';

  @override
  String get splitBreakdownSubtitle => 'Kā izdevums ir sadalīts';

  @override
  String get splitBreakdownTitle => 'Sadalījuma detalizācija';

  @override
  String get splitHintEqual => 'Vienādi sadalīt starp izvēlētajiem dalībniekiem.';

  @override
  String get splitHintExact => 'Ievadi precīzu summu katram dalībniekam. Summai jāatbilst kopējai summai.';

  @override
  String get splitHintPercent => 'Ievadi procentus katram dalībniekam. Summai jābūt 100%.';

  @override
  String get splitHintShares => 'Ievadi daļu vienības (1, 2, 3...). Izmaksas tiek sadalītas proporcionāli.';

  @override
  String get splitLabel => 'Sadalījums';

  @override
  String splitLabelValue(Object value) {
    return 'Sadalījums: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Vienāda sadale ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Precīzās summas ($target)';
  }

  @override
  String get splitModeLabel => 'Sadalīšanas režīms';

  @override
  String splitModePercent(Object target) {
    return 'Procenti ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Daļas ($target)';
  }

  @override
  String get statusConfirmed => 'Apstiprināts';

  @override
  String get statusPending => 'Gaida';

  @override
  String get statusSent => 'Nosūtīts';

  @override
  String get statusSuggested => 'Ieteikts';

  @override
  String statusWithValue(Object status) {
    return 'Statuss: $status';
  }

  @override
  String get suggestedTransferDirections => 'Ieteikto pārskaitījumu virzieni';

  @override
  String get suggestedTransferFromExpense => 'Ieteikts pārskaitījums no izdevuma';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ieteiktās pārskaitījuma rindas',
      one: '$count ieteiktā pārskaitījuma rinda',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Sagaidāmās maksātājs -> saņēmējs rindas.';

  @override
  String get suggestedTransfersTitle => 'Ieteiktie pārskaitījumi';

  @override
  String get summarySettledUp => 'Viss norēķināts';

  @override
  String get summaryYouAreOwed => 'Tev ir jāsaņem';

  @override
  String get summaryYouOwe => 'Tev jāmaksā';

  @override
  String get syncAction => 'Sinhronizēt';

  @override
  String get syncNowAction => 'Sinhronizēt tagad';

  @override
  String get syncingStatus => 'Sinhronizējas';

  @override
  String get tapToViewDetails => 'Pieskaries, lai skatītu detaļas';

  @override
  String get themeModeDark => 'Tumšs';

  @override
  String get themeModeDarkSubtitle => 'Maigi tumšs (ne pilnīgi melns)';

  @override
  String get themeModeLight => 'Gaišs';

  @override
  String get themeModeSystem => 'Sistēma';

  @override
  String get themeModeSystemSubtitle => 'Izmantot ierīces izskata režīmu';

  @override
  String toDirection(Object name) {
    return 'Uz $name';
  }

  @override
  String get totalLabel => 'Kopā';

  @override
  String get travelerFallbackName => 'Ceļotājs';

  @override
  String get tripAlreadyClosed => 'Ceļojums jau ir slēgts.';

  @override
  String get tripArchivedReadOnly => 'Ceļojums ir arhivēts. Tikai lasīšanas režīms.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Ceļojums ir slēgts. Izdevumu rediģēšana ir atslēgta.';

  @override
  String get tripClosedExpensesReadOnly => 'Ceļojums ir slēgts. Izdevumi ir tikai lasāmi.';

  @override
  String get tripClosedRandomDisabled => 'Ceļojums ir slēgts. Izloze ir atslēgta.';

  @override
  String tripCreated(Object name) {
    return 'Ceļojums \"$name\" izveidots.';
  }

  @override
  String get tripFinished => 'Ceļojums pabeigts.';

  @override
  String get tripFinishedCompleteSettlements => 'Ceļojums ir pabeigts. Pabeidz norēķinus.';

  @override
  String get tripFinishedSettlementStarted => 'Ceļojums pabeigts. Norēķini sākās.';

  @override
  String get tripFullySettledArchived => 'Ceļojums pilnībā norēķināts un arhivēts.';

  @override
  String get tripNameHint => 'Austrijas slēpošanas ceļojums';

  @override
  String get tripNameLabel => 'Ceļojuma nosaukums';

  @override
  String get tripNameLengthValidation => 'Ceļojuma nosaukumam jābūt vismaz 2 rakstzīmēm.';

  @override
  String get tripSnapshotTitle => 'Ceļojuma kopsavilkums';

  @override
  String get tripTitleShort => 'Ceļojums';

  @override
  String tripStatusWithValue(Object status) {
    return 'Ceļojuma statuss: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Ceļojums #$id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Neparedzēta kļūda, ielādējot profilu';

  @override
  String get unexpectedErrorLoadingTripData => 'Neparedzēta kļūda, ielādējot ceļojuma datus';

  @override
  String get unexpectedErrorLoadingTrips => 'Neparedzēta kļūda, ielādējot ceļojumus';

  @override
  String get unexpectedErrorSavingChanges => 'Neparedzēta kļūda, saglabājot izmaiņas';

  @override
  String get unexpectedErrorSavingCredentials => 'Neparedzēta kļūda, saglabājot piekļuves datus';

  @override
  String get unexpectedErrorUpdatingProfile => 'Neparedzēta kļūda, atjauninot profilu';

  @override
  String get unknownError => 'Nezināma kļūda';

  @override
  String get unknownLabel => 'Nezināms';

  @override
  String get unreadLabel => 'Nelasīts';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nelasīti atjauninājumi',
      one: '$count nelasīts atjauninājums',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Trūkst ceļojuma maršruta arguments.';

  @override
  String userIdLabel(Object id) {
    return 'Lietotāja ID: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Samaksāts $paid - Jāmaksā $owes - Neto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Lietotājs $id';
  }

  @override
  String get valueLabel => 'Vērtība';

  @override
  String get viewAllTrips => 'Skatīt visus ceļojumus';

  @override
  String get viewByPersonTitle => 'Skatīt pēc personas';

  @override
  String get whoOwesWhatSubtitle => 'Kas samaksāja un kam jāmaksā.';

  @override
  String get whoOwesWhatTitle => 'Kas kam ir parādā';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Kas kam ir parādā: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Izdevumu rindas, kas veido šo pārskaitījumu.';

  @override
  String get whyPaymentExistsTitle => 'Kāpēc šis maksājums pastāv';

  @override
  String get youLabel => 'Tu';

  @override
  String get youSettledForExpense => 'Tu šo izdevumu esi nokārtojis.';

  @override
  String youShouldPay(Object amount) {
    return 'Tev jāmaksā $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Tev jāsaņem $amount';
  }

  @override
  String get yourShare => 'Tava daļa';

  @override
  String get yourTrips => 'Tavi ceļojumi';
}
