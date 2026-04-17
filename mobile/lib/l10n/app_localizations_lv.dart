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
  String get languageSpanish => 'Spāņu';

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
  String get notificationFriendInviteTitle => 'Drauga uzaicinājums';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name tev nosūtīja drauga uzaicinājumu.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Tu saņēmi drauga uzaicinājumu.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Uzaicinājums apstiprināts';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name apstiprināja tavu drauga uzaicinājumu.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Tavs drauga uzaicinājums tika apstiprināts.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Uzaicinājums noraidīts';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name noraidīja tavu drauga uzaicinājumu.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Tavs drauga uzaicinājums tika noraidīts.';

  @override
  String get notificationTripAddedTitle => 'Pievienots ceļojumam';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name tevi pievienoja ceļojumam \"$trip\".';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Tu tiki pievienots ceļojumam \"$trip\".';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Tu tiki pievienots ceļojumam.';

  @override
  String get notificationExpenseAddedTitle => 'Pievienots jauns izdevums';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name pievienoja izdevumu $amount ceļojumā \"$trip\".';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name pievienoja izdevumu $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Pievienots jauns izdevums.';

  @override
  String get notificationTripFinishedTitle => 'Ceļojums pabeigts';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name pabeidza \"$trip\". Norēķini ir gatavi.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name pabeidza \"$trip\". Ceļojums ir arhivēts.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '\"$trip\" ir pabeigts.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Ceļojuma statuss tika atjaunināts.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Dalībnieks atzīmēja gatavību';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name ir gatavs norēķināties ceļojumā \"$trip\".';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Kāds dalībnieks ir gatavs norēķināties ceļojumā \"$trip\".';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Kāds dalībnieks ir gatavs norēķināties.';

  @override
  String get notificationTripReadyToSettleTitle => 'Visi dalībnieki ir gatavi';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Visi dalībnieki atzīmēja gatavību ceļojumā \"$trip\". Vari sākt norēķinus.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Visi dalībnieki ir gatavi. Vari sākt norēķinus.';

  @override
  String get notificationSettlementReminderTitle => 'Atgādinājums par norēķinu';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor atgādināja $target atzīmēt $amount kā nosūtītu.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor atgādināja $target apstiprināt $amount saņemšanu.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Saņemts atgādinājums par norēķinu.';

  @override
  String get notificationPaymentReminderTitle => 'Maksājuma atgādinājums';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Atgādinājums: lūdzu atzīmē $amount kā nosūtītu lietotājam $target ceļojumā \"$trip\".';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Atgādinājums: lūdzu atzīmē maksājumu kā nosūtītu.';

  @override
  String get notificationConfirmationReminderTitle => 'Apstiprinājuma atgādinājums';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Atgādinājums: lūdzu apstiprini $amount saņemšanu no $payer ceļojumā \"$trip\".';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Atgādinājums: lūdzu apstiprini maksājuma saņemšanu.';

  @override
  String get notificationSettlementSentTitle => 'Pārskaitījums atzīmēts kā nosūtīts';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name atzīmēja $amount kā nosūtītu tev.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Pārskaitījums tika atzīmēts kā nosūtīts.';

  @override
  String get notificationSettlementConfirmedTitle => 'Pārskaitījums apstiprināts';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name apstiprināja, ka saņēma $amount no tevis.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Pārskaitījums tika apstiprināts.';

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

  @override
  String get authIntroSplitSmarter => 'Dali gudrāk.';

  @override
  String get authIntroTravelFree => 'Ceļo brīvāk.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Seko kopīgajiem izdevumiem dažādās valūtās un norēķinies uzreiz - bez neērtiem parādiem.';

  @override
  String get authIntroPlanTogether => 'Plāno kopā.';

  @override
  String get authIntroPayClearly => 'Maksā skaidri.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Izveido ceļojumu sekundēs, pievieno draugus un padari katru izdevumu caurspīdīgu visiem.';

  @override
  String get authIntroSettleFast => 'Norēķinies ātri.';

  @override
  String get authIntroStayFriends => 'Paliec draugos.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'No kopīgām vakariņām līdz pilniem ceļojumiem - Splyto palīdz saglabāt taisnīgus un vienkāršus norēķinus.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Apple pieslēgšanās neizdevās. Mēģini vēlreiz.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Google pieslēgšanās neizdevās. Mēģini vēlreiz.';

  @override
  String get authIntroCreateAccount => 'Izveido savu kontu.';

  @override
  String get authIntroChooseSign => 'Izvēlies, kā vēlies reģistrēties.';

  @override
  String get authIntroContinueGoogle => 'Turpināt ar Google';

  @override
  String get authIntroContinueApple => 'Turpināt ar Apple';

  @override
  String get authIntroBack => 'Atpakaļ';

  @override
  String get authIntroSplitSettled => 'Norēķins pabeigts';

  @override
  String get authIntroParis3Friends => 'Parīze · 3 draugi';

  @override
  String get authIntroGetStarted => 'Sākt';

  @override
  String get authIntroAlreadyHaveAccount => 'Jau ir konts? ';

  @override
  String get authIntroSignIn => 'Ienākt';

  @override
  String get authIntroSignUpWithEmail => 'Reģistrēties ar e-pastu';

  @override
  String get authIntroOr => 'VAI';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Google pieslēgšanās neatgrieza id token.';

  @override
  String get authAppleSignAvailableIosDevices => 'Apple pieslēgšanās ir pieejama iOS ierīcēs.';

  @override
  String get authAppleSignNotAvailableDevice => 'Apple pieslēgšanās šajā ierīcē nav pieejama.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Apple pieslēgšanās neatgrieza identitātes tokenu.';

  @override
  String get authAccountDeactivatedEnterEmailRequestReactivationLink => 'Konts ir deaktivēts. Ievadi e-pastu, lai pieprasītu reaktivācijas saiti.';

  @override
  String get authAccountDeactivated => 'Konts ir deaktivēts';

  @override
  String authSendReactivationLinkEmail(Object email) {
    return 'Nosūtīt reaktivācijas saiti uz $email?';
  }

  @override
  String get authCancel => 'Atcelt';

  @override
  String get authSendLink => 'Sūtīt saiti';

  @override
  String get authReactivationLinkSentCheckEmail => 'Reaktivācijas saite nosūtīta. Pārbaudi e-pastu.';

  @override
  String get authCouldNotSendReactivationLinkPleaseTryAgain => 'Neizdevās nosūtīt reaktivācijas saiti. Mēģini vēlreiz.';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'E-pasts nav verificēts. Ievadi e-pastu, lai pieprasītu verifikācijas saiti.';

  @override
  String get authEmailNotVerified => 'E-pasts nav verificēts';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Nosūtīt verifikācijas saiti uz $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Verifikācijas saite nosūtīta. Pārbaudi e-pastu.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Neizdevās nosūtīt verifikācijas saiti. Mēģini vēlreiz.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Verifikācijas e-pasts nosūtīts. Pirms ielogošanās verificē e-pastu.';

  @override
  String get authVerifyEmail => 'Verificē savu e-pastu';

  @override
  String get authEmailLabel => 'E-pasts:';

  @override
  String get authClose => 'Aizvērt';

  @override
  String get authResendLink => 'Sūtīt vēlreiz';

  @override
  String get profileAppSettingsSectionTitle => 'LIETOTNES IESTATĪJUMI';

  @override
  String get profileAppearance => 'Izskats';

  @override
  String get profileThemeDisplayMode => 'Tēma un attēlošanas režīms';

  @override
  String get profileLanguage => 'Valoda';

  @override
  String get profileDisplayLanguage => 'Lietotnes valoda';

  @override
  String get profileNotificationsSectionHeading => 'PAZIŅOJUMI';

  @override
  String get profileAppBanners => 'Baneri lietotnē';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Rādīt jaunus paziņojumu banerus lietotnē';

  @override
  String get profilePushNotificationsTitle => 'Push paziņojumi';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Paziņojumi telefonā par tēriņiem, draugiem, ceļojumiem un norēķiniem';

  @override
  String get profileSupportSectionHeading => 'ATBALSTS';

  @override
  String get profileContactUs => 'Sazināties ar mums';

  @override
  String get profileReportBugSuggestion => 'Ziņot par kļūdu / Ieteikums';

  @override
  String get profileRateSplyto => 'Novērtēt Splyto';

  @override
  String get profileLeaveStoreRating => 'Atstāt vērtējumu veikalā';

  @override
  String get profileSecuritySectionHeading => 'DROŠĪBA';

  @override
  String get profileChangePassword => 'Mainīt paroli';

  @override
  String get profileUpdateAccountPassword => 'Atjaunināt konta paroli';

  @override
  String get profileDangerZoneSectionHeading => 'BĪSTAMĀ ZONA';

  @override
  String get profileDeactivateAccount => 'Deaktivēt kontu';

  @override
  String get profileManageAccountAccess => 'Pārvaldīt konta piekļuvi';

  @override
  String get profileMadeWithLabel => 'Veidots ar';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Vērtēšanas darbība veikalā tiks pieslēgta nākamajā solī.';

  @override
  String get profileFailedSaveNotificationSettings => 'Neizdevās saglabāt paziņojumu iestatījumus.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH PAZIŅOJUMI';

  @override
  String get profileInAppBannersSectionTitle => 'BANERI LIETOTNĒ';

  @override
  String get profileExpenseUpdates => 'Tēriņu atjauninājumi';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Baneri lietotnē par pievienotiem tēriņiem';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Paziņojumi telefonā par pievienotiem tēriņiem';

  @override
  String get profileFriendInvites => 'Draugu uzaicinājumi';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Baneri lietotnē par draugu pieprasījumiem un atbildēm';

  @override
  String get profileFriendRequestResponseNotifications => 'Paziņojumi par draugu pieprasījumiem un atbildēm';

  @override
  String get profileTripUpdates => 'Ceļojumu atjauninājumi';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Baneri lietotnē par ceļojuma statusu un dalībnieku izmaiņām';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Ceļojuma statusa un dalībnieku izmaiņas';

  @override
  String get profileSettlementUpdates => 'Norēķinu atjauninājumi';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Baneri lietotnē par atzīmētiem un apstiprinātiem maksājumiem';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Atzīmēts kā nosūtīts un apstiprināts saņemts';

  @override
  String get profileScreenshotSizeMust8Mb => 'Ekrānattēla izmēram jābūt līdz 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Sūtīt atsauksmi';

  @override
  String get profileFeedbackTypeLabel => 'Tips';

  @override
  String get profileFeedbackTypeBug => 'Kļūda';

  @override
  String get profileFeedbackTypeSuggestion => 'Ieteikums';

  @override
  String get profileDescribeIssueSuggestion => 'Apraksti problēmu vai ieteikumu';

  @override
  String get profilePickingImage => 'Tiek izvēlēts attēls...';

  @override
  String get profileAttachScreenshot => 'Pievienot ekrānattēlu';

  @override
  String get profileChangeScreenshot => 'Mainīt ekrānattēlu';

  @override
  String get profileRemoveImage => 'Noņemt attēlu';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Ieteikums: pievieno ekrānattēlu ātrākai kļūdas analīzei';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Pirms sūtīšanas pievieno aprakstu vai ekrānattēlu';

  @override
  String get profileSendAction => 'Sūtīt';

  @override
  String get profileThanksFeedbackSent => 'Paldies! Atsauksme nosūtīta';

  @override
  String get profileFailedSendFeedback => 'Neizdevās nosūtīt atsauksmi';

  @override
  String get profileCouldNotOpenWebsite => 'Neizdevās atvērt mājaslapu.';

  @override
  String get profileOpenWebsiteQuestion => 'Atvērt mājaslapu?';

  @override
  String get profileOpenPortfolioAction => 'Atvērt portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Šis attēla formāts šajā ierīcē netiek atbalstīts. Lūdzu, izvēlies JPG vai PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Pirms paroles maiņas ievadi derīgu e-pastu sadaļā \"Edit profile\".';

  @override
  String get profileEditDeactivatedReactivationLinkEmailRestoreAccess => 'Konts deaktivēts. Lai atjaunotu piekļuvi, izmanto reaktivācijas saiti e-pastā.';

  @override
  String get profileEditCouldNotDeactivateTryAgain => 'Neizdevās deaktivēt kontu. Mēģini vēlreiz.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Dzēšanas saite nosūtīta uz tavu e-pastu.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Neizdevās nosūtīt dzēšanas saiti. Mēģini vēlreiz.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Lai mainītu e-pastu, ievadi pašreizējo paroli.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Verifikācijas saite nosūtīta uz jauno e-pastu. Drošības paziņojums nosūtīts uz pašreizējo e-pastu.';

  @override
  String get profileEditCouldNotStartEmailChangeRightNowTry => 'Neizdevās sākt e-pasta maiņu. Mēģini vēlreiz.';

  @override
  String get profileEditOverviewCurrency => 'Pārskata valūta';

  @override
  String get profileEditPaymentMethod => 'Maksājuma metode';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Bankas pārskaitījums, Revolut, PayPal.me';

  @override
  String get profileEditDeactivateAccessRequestEmailLinkPermanentlyDeletePassword => 'Vari deaktivēt konta piekļuvi vai pieprasīt e-pasta saiti neatgriezeniskai konta dzēšanai. Google/Apple kontiem parole nav obligāta.';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Ievadi paroli (Google/Apple nav obligāti)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Nosūtīt dzēšanas saiti uz e-pastu';

  @override
  String get profileEditBackProfile => 'Atpakaļ uz profilu';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Pirms paroles maiņas iestati derīgu e-pastu profilā.';

  @override
  String get profileEditPasswordUpdated => 'Parole atjaunināta.';

  @override
  String get profileEditFailedUpdatePassword => 'Neizdevās atjaunināt paroli.';

  @override
  String profileEditEmail(Object email) {
    return 'Konts: $email';
  }

  @override
  String get profileEditPrimary => 'Primārais';

  @override
  String get profileEditSearchCurrency => 'Meklēt valūtu';

  @override
  String get profileEditNoCurrenciesFound => 'Valūtas netika atrastas';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Pārskata summas tiks konvertētas uz šo valūtu.';

  @override
  String get profileEditPaymentInfoUpdated => 'Maksājumu info atjaunināta.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Neizdevās saglabāt maksājumu info. Mēģini vēlreiz.';

  @override
  String get profileEditCurrentPassword => 'Pašreizējā parole';

  @override
  String get profileEditBankTransferIbanSwift => 'Bankas pārskaitījums (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me saite';

  @override
  String get profileEditChoosePaymentMethod => 'Izvēlies maksājuma metodi';

  @override
  String get profileEditTapChange => 'Pieskaries, lai mainītu';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'UK pārskaitījumiem sort code jābūt 6 cipariem un account number 8 cipariem.';

  @override
  String get profileEditPaymentInfo => 'Maksājumu info';

  @override
  String get profileEditSaveDetails => 'Saglabāt datus';

  @override
  String get profileEditBankRegion => 'Bankas reģions';

  @override
  String get profileEditEurope => 'Eiropa';

  @override
  String get profileEditSortCode => 'Sort code';

  @override
  String get profileEditExample112233 => 'Piemērs: 112233';

  @override
  String get profileEditNumber => 'Konta numurs';

  @override
  String get profileEdit8Digits => '8 cipari';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'UK iekšzemes pārskaitījumiem izmanto sort code + account number.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Piemērs: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 vai 11 simboli';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Konta turētāja vārds tiek ņemts no profila pilnā vārda.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/lietotajs';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@lietotajs';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/lietotajs vai lietotajs';

  @override
  String get shellTripAlreadyInListOpened => 'Ceļojums jau ir tavā sarakstā. Atvēru to tev.';

  @override
  String get shellJoinedTripFromInviteLink => 'Veiksmīgi pievienojies ceļojumam no saites.';

  @override
  String get shellFailedToOpenInviteLink => 'Neizdevās atvērt ielūguma saiti.';

  @override
  String get shellTripInviteTitle => 'Ceļojuma ielūgums';

  @override
  String get shellNoAction => 'Nē';

  @override
  String get shellYesAction => 'Jā';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Šo ceļojumu drīkst dzēst tikai izveidotājs.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Dzēst var tikai aktīvus ceļojumus.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Dzēst \"$tripLabel\"? Tas ir atļauts tikai pirms ceļojumam pievienoti izdevumi.';
  }

  @override
  String get shellTripDeleted => 'Ceļojums izdzēsts.';

  @override
  String get shellFailedToDeleteTrip => 'Neizdevās izdzēst ceļojumu.';

  @override
  String get shellFailedToLoadNotifications => 'Neizdevās ielādēt paziņojumus.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Jauns paziņojums: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Neizdevās atjaunot paziņojumus.';

  @override
  String get shellMarkAllAsReadAction => 'Atzīmēt visu kā lasītu';

  @override
  String get shellNewSection => 'Jaunie';

  @override
  String get shellEarlierSection => 'Iepriekšējie';

  @override
  String get shellShowMoreEarlierAction => 'Rādīt vairāk iepriekšējos';

  @override
  String get shellLoadingMore => 'Ielādē vēl...';

  @override
  String get shellLoadMoreNotificationsAction => 'Ielādēt vēl paziņojumus';

  @override
  String get shellTripNoLongerAvailable => 'Šis ceļojums vairs nav pieejams.';

  @override
  String get shellFailedToOpenTrip => 'Neizdevās atvērt ceļojumu.';

  @override
  String get shellYesterday => 'Vakar';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Tu jau esi ceļojuma \"$tripName\" dalībnieks. Atvērt šo ceļojumu tagad?\n\nUzaicināja: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Vai tiešām pievienoties ceļojumam \"$tripName\"?\n\nUzaicināja: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Izvēlētais attēls: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Tripa attēls jau ir iestatīts.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Ceļojums izveidots, bet attēla augšupielāde neizdevās.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Ceļojums izveidots, bet attēla augšupielāde neizdevās: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Pievienoties ceļojumam ar ielūgumu';

  @override
  String get tripsTotalTrips => 'Ceļojumi kopā';

  @override
  String get tripsTotalSpent => 'Kopā iztērēts';

  @override
  String get tripsMixedCurrencies => 'Jauktas valūtas';

  @override
  String get tripsShowActive => 'Rādīt aktīvos';

  @override
  String get tripsSeeAll => 'Skatīt visus';

  @override
  String get tripsAddNewTrip => 'Pievienot ceļojumu';

  @override
  String get tripsLoadMore => 'Ielādēt vēl';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Dzēst \"$arg1\"? Tas ir atļauts tikai pirms ceļojumam pievienoti izdevumi.';
  }

  @override
  String get tripsTripDates => 'Ceļojuma datumi';

  @override
  String get tripsFrom => 'No';

  @override
  String get tripsSelectDate => 'Izvēlies datumu';

  @override
  String get tripsTo => 'Līdz';

  @override
  String get tripsMainCurrency => 'Galvenā valūta';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Lūdzu, izvēlies ceļojuma periodu (no un līdz).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Ceļojuma beigu datumam jābūt vienādam vai vēlākam par sākuma datumu.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Ceļojuma perioda formāts nav derīgs. Izvēlies datumus vēlreiz.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Tu jau esi šī ceļojuma dalībnieks.';

  @override
  String get tripsJoinedTripSuccessfully => 'Veiksmīgi pievienojies ceļojumam.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Neizdevās pievienoties ceļojumam no ielūguma.';

  @override
  String get tripsJoinTrip => 'Pievienoties ceļojumam';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Ielīmē ielūguma saiti vai ielūguma tokenu.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Ievadi derīgu ielūguma saiti vai tokenu.';

  @override
  String get tripsClipboardIsEmpty => 'Starpliktuve ir tukša.';

  @override
  String get tripsPaste => 'Ielīmēt';

  @override
  String get tripsJoin => 'Pievienoties';

  @override
  String get workspaceTripMembers => 'Trip dalībnieki';

  @override
  String get workspaceFailedToLoadFriends => 'Neizdevās ielādēt draugus.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Neizdevās izveidot ielūguma saiti.';

  @override
  String get workspaceInviteLink => 'Ielūguma saite';

  @override
  String get workspaceGeneratingInviteLink => 'Veido ielūguma saiti...';

  @override
  String get workspaceInviteLinkUnavailable => 'Ielūguma saite nav pieejama.';

  @override
  String get workspaceCopyInviteLink => 'Kopēt ielūguma saiti';

  @override
  String get workspaceInviteLinkCopied => 'Ielūguma saite nokopēta.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Derīga līdz: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Draugu saraksts ir tukšs. Vispirms pievieno draugus.';

  @override
  String get workspaceSettle => 'Norēķini';

  @override
  String get workspaceOwesToTheGroup => 'Parādā grupai';

  @override
  String get workspaceGetsBackFromGroup => 'Jāsaņem no grupas';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Parādīti 4 lielākie bilances ieraksti.';

  @override
  String get workspaceOpenFlow => 'Atvērt plūsmu';

  @override
  String get workspaceFriend => 'Draugs';

  @override
  String get workspaceSettlementTransfer => 'Norēķina pārskaitījums';

  @override
  String get workspaceCompleted => 'Pabeigts';

  @override
  String get workspaceWaitingForConfirmation => 'Gaida apstiprinājumu';

  @override
  String get workspaceWaitingForPayment => 'Gaida maksājumu';

  @override
  String get workspaceActionNeeded => 'Nepieciešama darbība';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return '$arg1 maksājums(-i) jāatzīmē kā nosūtīts, $arg2 jāapstiprina kā saņemts.';
  }

  @override
  String get workspaceReadyToSettle => 'Gatavi norēķiniem';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Visi dalībnieki gatavi. Var sākt norēķinus.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Gaidām, kamēr visi atzīmē gatavību.';

  @override
  String get workspaceIMReady => 'Esmu gatavs/-a';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Apstiprini, ka visi tavi izdevumi ir pievienoti.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Poga aktivizēsies, kad visi atzīmēs gatavību.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Jāsaņem no grupas';

  @override
  String get workspaceSettledWithTheGroup => 'Norēķināts ar grupu';

  @override
  String get workspaceTotalPaid => 'Kopā samaksāts';

  @override
  String get workspaceTotalOwes => 'Kopā parādā';

  @override
  String get workspaceTransactionHistory => 'Transakciju vēsture';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Šim dalībniekam vēl nav transakciju.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Norēķini: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Pirms norēķinu sākšanas visiem dalībniekiem jāatzīmē gatavība.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Tu atzīmēji sevi kā gatavu norēķiniem.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Gatavības atzīme noņemta.';

  @override
  String get workspaceReminderSent => 'Atgādinājums nosūtīts.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Ielūguma saite vai pievienošana no draugiem';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Šo ceļojumu drīkst labot tikai izveidotājs.';

  @override
  String get workspaceTripUpdated => 'Ceļojums atjaunināts.';

  @override
  String get workspaceFailedToUpdateTrip => 'Neizdevās atjaunināt ceļojumu.';

  @override
  String get workspaceNoMembersSelectedYet => 'Neviens dalībnieks vēl nav izvēlēts.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Nav interneta. Izdevums tiks saglabāts bez čeka attēla.';

  @override
  String get workspaceRandomPicker => 'Nejaušā izvēle';

  @override
  String get workspaceCurrency => 'Valūta';

  @override
  String get workspaceCategory => 'Kategorija';

  @override
  String get workspaceCustomCategory => 'Sava kategorija';

  @override
  String get workspaceCategoryName => 'Kategorijas nosaukums';

  @override
  String get workspaceApartmentRentParkingEtc => 'Dzīvokļa īre, stāvvieta u.c.';

  @override
  String get workspaceEnterACustomCategory => 'Ievadi savu kategoriju.';

  @override
  String get workspacePickAnExpenseCategory => 'Izvēlies izdevuma kategoriju.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Kategorijai jābūt vismaz 2 rakstzīmēm.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Kategorija var būt līdz 64 rakstzīmēm.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Procentu sadalei jāsummējas līdz 100%.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Daļām jābūt lielākām par 0 visiem dalībniekiem.';

  @override
  String get workspaceTotalAmount => 'Kopējā summa';

  @override
  String get workspaceOriginal => 'Sākotnēji';

  @override
  String get workspaceTotalCost => 'Kopējās izmaksas';

  @override
  String workspaceStarted(Object arg1) {
    return 'Sākts $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Noslēgts $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Arhivēts ceļojums';

  @override
  String get workspaceActiveTrip => 'Aktīvs ceļojums';

  @override
  String get workspaceMemberProfile => 'Dalībnieka profils';

  @override
  String get workspaceTripOwner => 'Trip īpašnieks';

  @override
  String get workspaceMember => 'Dalībnieks';

  @override
  String get workspaceReadyForSettlement => 'Gatavs norēķiniem';

  @override
  String get workspaceNotReadyForSettlement => 'Nav gatavs norēķiniem';

  @override
  String get workspaceBankDetails => 'Bankas dati';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN un izmaksu dati šeit tiks pievienoti nākamajā atjauninājumā.';

  @override
  String get workspacePaymentDetails => 'Maksājumu dati';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Šis dalībnieks vēl nav pievienojis izmaksu datus.';

  @override
  String get workspaceBankTransfer => 'Bankas pārskaitījums';

  @override
  String get workspaceHolder => 'Turētājs';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Neizdevās atvērt maksājuma saiti.';

  @override
  String get workspaceTripActivity => 'Trip aktivitāte';

  @override
  String get workspacePaidExpenses => 'Apmaksāti izdevumi';

  @override
  String get workspacePaidTotal => 'Apmaksāts kopā';

  @override
  String get workspaceInvolvedIn => 'Iesaistīts';

  @override
  String get workspaceCurrentTrip => 'Pašreizējais trips';

  @override
  String get workspaceCommonTrips => 'Kopīgie tripi';

  @override
  String get workspaceLoadingCommonTrips => 'Ielādē kopīgos tripus...';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Kopīgi tripi vēl nav atrasti.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Neizdevās ielādēt visus kopīgos tripus. Rādu pašreizējo.';

  @override
  String get workspaceMembers => 'dalībnieki';

  @override
  String get workspaceExpense => 'Izdevums';

  @override
  String get workspacePaid => 'apmaksāja';

  @override
  String get workspaceLoadingMoreExpenses => 'Ielādē vēl izdevumus...';

  @override
  String get workspaceScrollDownToLoadMore => 'Ritini uz leju, lai ielādētu vairāk';

  @override
  String get workspaceTripFinished => 'Trip pabeigts';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Norēķini šim tripam ir atvērti.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Pabeidz trip, lai sāktu norēķinus.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 atzīmēja pārskaitījumu kā nosūtītu.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Gaida, kad $arg1 atzīmēs kā apmaksātu.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 apstiprināja maksājuma saņemšanu.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Gaida, kad $arg1 apstiprinās.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Visi trip norēķini ir pilnībā pabeigti.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Gala stāvoklis, kad visi pārskaitījumi apstiprināti.';

  @override
  String get workspaceSettlementFlow => 'Norēķina plūsma';

  @override
  String get workspaceActions => 'Darbības';

  @override
  String get workspaceTransferIsConfirmed => 'Pārskaitījums ir apstiprināts.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Gaida, kad otrs dalībnieks pabeigs nākamo soli.';

  @override
  String get workspaceSendReminder => 'Nosūtīt atgādinājumu';

  @override
  String get workspaceInProgress => 'Procesā';

  @override
  String get workspaceTimeUnknown => 'Laiks nav zināms';

  @override
  String get workspaceRemind => 'Atgādināt';

  @override
  String get workspaceYourPosition => 'Tava pozīcija';

  @override
  String get workspaceRecentActivity => 'Pēdējās aktivitātes';

  @override
  String get workspaceNoRecentActivityYet => 'Pagaidām nav nesenu aktivitāšu.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Pievieno vismaz vienu dalībnieku, lai sāktu dalīt izdevumus.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Atzīmē sevi kā gatavu norēķiniem, kad esi pievienojis visus izdevumus.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return '$arg1 dalībnieks(-i) vēl nav atzīmējuši gatavību.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Visi dalībnieki ir gatavi. Vari pabeigt ceļojumu un sākt norēķinus.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Visi dalībnieki ir gatavi. Gaida, kad ceļojuma veidotājs sāks norēķinus.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Norēķini procesā: apstiprināti $arg1/$arg2.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Nav gaidošu darbību. Šis ceļojums ir noslēgts.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Pašlaik darbības nav nepieciešamas.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Tev jāsaņem $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Tev jāsamaksā $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Šobrīd šajā ceļojumā esi norēķinājies.';

  @override
  String get workspaceUnknownTime => 'Nezināms laiks';

  @override
  String get workspaceJustNow => 'Tikko';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'Pirms $arg1 min';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'Pirms $arg1 h';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'Pirms $arg1 d';
  }

  @override
  String get friendsRemoveFriend => 'Noņemt draugu';

  @override
  String get friendsRemoveThisFriend => 'Noņemt šo draugu?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 tiks noņemts no tavas draugu listes. Vēlāk varēsi viņu pievienot atkal.';
  }

  @override
  String get friendsContinue => 'Turpināt';

  @override
  String get friendsFriendRemoved => 'Draugs noņemts.';

  @override
  String get friendsCouldNotRemoveFriend => 'Neizdevās noņemt draugu.';

  @override
  String get friendsFriendProfile => 'Drauga profils';

  @override
  String get friendsMoreActions => 'Vairāk darbību';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Šis draugs vēl nav pievienojis izmaksu datus.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Šobrīd neizdevās ielādēt kopīgos tripus.';

  @override
  String get friendsFinished => 'Pabeigts';

  @override
  String friendsTrip(Object arg1) {
    return 'Trips #$arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return '$arg1 dalībnieki';
  }

  @override
  String get friendsNoDate => 'Nav datuma';

  @override
  String get friendsIncomingRequests => 'SAŅEMTIE PIEPRASĪJUMI';

  @override
  String get friendsSentInvites => 'NOSŪTĪTIE UZAICINĀJUMI';

  @override
  String get friendsMyFriends => 'MANI DRAUGI';

  @override
  String get friendsIncoming => 'Saņemtie';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Uzaicinājums nosūtīts lietotājam $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Nav saņemtu pieprasījumu';

  @override
  String get friendsDecline => 'Noraidīt';

  @override
  String get friendsAccept => 'Apstiprināt';

  @override
  String get friendsNoSentInvites => 'Nav nosūtītu uzaicinājumu';

  @override
  String get friendsNoFriendsYet => 'Draugu vēl nav';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Ritini uz leju, lai ielādētu vēl draugus.';

  @override
  String get friendsUser => 'Lietotājs';

  @override
  String get friendsSearchUsers => 'Meklēt lietotājus';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Meklē pēc vārda vai e-pasta un nosūti uzaicinājumu';

  @override
  String get friendsScanQr => 'Skenēt QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Noskenē cita lietotāja QR, lai pievienotu draugu';

  @override
  String get friendsMyQr => 'Mans QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Parādi vai nošēro savu QR kodu';

  @override
  String get friendsScanFriendQrTitle => 'Skenēt drauga QR';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Novieto drauga QR kodu rāmī';

  @override
  String get friendsMyFriendQrTitle => 'Mans drauga QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Atver Friends > Scan QR otrā telefonā un noskenē šo kodu.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Pievieno mani TripSplit draugos.';

  @override
  String get friendsTripSplitFriendCode => 'TripSplit drauga kods';

  @override
  String get shareAction => 'Kopīgot';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'QR kods nav derīgs drauga kods.';

  @override
  String get friendsYouCannotAddYourself => 'Tu nevari pievienot pats sevi.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Šis lietotājs jau ir tavā draugu sarakstā.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Uzaicinājums šim lietotājam jau ir nosūtīts.';

  @override
  String get friendsFriendRequestProcessed => 'Drauga pieprasījums apstrādāts.';

  @override
  String get friendsFailedToProcessFriendQr => 'Neizdevās apstrādāt drauga QR.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Neizdevās ielādēt tavu profilu.';

  @override
  String get friendsMyProfile => 'Mans profils';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Negaidīta kļūda ielādējot draugus.';

  @override
  String get friendsFriendAdded => 'Draugs pievienots.';

  @override
  String get friendsRequestDeclined => 'Pieprasījums noraidīts.';

  @override
  String get friendsFailedToUpdateRequest => 'Neizdevās atjaunināt pieprasījumu.';

  @override
  String get friendsCancelInvite => 'Atcelt uzaicinājumu';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Atcelt uzaicinājumu lietotājam $arg1?';
  }

  @override
  String get friendsKeep => 'Atstāt';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Uzaicinājums lietotājam $arg1 atcelts.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Neizdevās atcelt uzaicinājumu.';

  @override
  String get analyticsOther => 'Pārējās';

  @override
  String get analyticsSelectATripForAnalytics => 'Izvēlies ceļojumu analītikai';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • $arg2 dalībnieki • $arg3 • $arg4';
  }

  @override
  String get analyticsMyDaily => 'Mans dienas';

  @override
  String get analyticsGroupDaily => 'Grupas dienas';

  @override
  String get analyticsByMember => 'Pa dalībniekiem';

  @override
  String get analyticsShowLess => 'Rādīt mazāk';

  @override
  String get analyticsByCategory => 'Pa kategorijām';

  @override
  String get analyticsQuickInsights => 'Ātrie ieskati';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Lielākā kategorija: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Lielākais tērētājs: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Lielākais grupas tēriņš: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Nav datumu';

  @override
  String get friendsSearchFailedTryAgain => 'Meklēšana neizdevās. Mēģini vēlreiz.';

  @override
  String get friendsFailedToSendInvite => 'Neizdevās nosūtīt uzaicinājumu.';

  @override
  String get friendsAddFriend => 'Pievienot draugu';

  @override
  String get friendsSearchByNameOrEmail => 'Meklēt pēc vārda vai e-pasta';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Ievadi vismaz 2 simbolus, lai meklētu.';

  @override
  String get friendsNoUsersFound => 'Lietotāji nav atrasti';

  @override
  String get friendsInviteAction => 'Uzaicināt';

  @override
  String get workspacePaidForGroup => 'Apmaksāts grupai';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Apmaksāts grupai • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Dalība izdevumā';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Dalība izdevumā • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Turētāja vārds nokopēts.';

  @override
  String get paymentIbanCopied => 'IBAN nokopēts.';

  @override
  String get paymentSwiftCopied => 'SWIFT nokopēts.';

  @override
  String get paymentRevtagCopied => 'Revtag nokopēts.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Neizdevās nokopēt starpliktuvē.';

  @override
  String get paymentCopied => 'Nokopēts.';
}
