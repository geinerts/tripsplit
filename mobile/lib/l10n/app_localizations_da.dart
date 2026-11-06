// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get homeFirstTrip => 'Din første tur';

  @override
  String get homeYourShareAllTrips => 'Din andel af alle rejser';

  @override
  String get homeAllTime => 'Hele perioden';

  @override
  String get homeSolo => 'Solo';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personer',
      one: '$count person',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Rejsehandlinger: $name';
  }

  @override
  String get homeNoActiveTrips => 'Ingen aktive rejser';

  @override
  String get homeNoArchivedTrips => 'Ingen arkiverede rejser';

  @override
  String get homeLoadingTrips => 'Indlæsning af dine ture';

  @override
  String get homeLoadErrorTitle => 'Det var ikke muligt at indlæse dine ture';

  @override
  String get homeLoadErrorBody => 'Prøv venligst igen om et øjeblik.';

  @override
  String get homeOfflineTitle => 'Du er offline';

  @override
  String get homeOfflineNoData => 'Dine ture er endnu ikke tilgængelige på denne enhed.';

  @override
  String get homeOfflineCached => 'Offline. Visning af gemte ture.';

  @override
  String get homeRefreshError => 'Kunne ikke opdatere. Viser tidligere indlæste ture.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Del mine gemte betalingsoplysninger med $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Kun mens denne anmodning afventer betaling. Annullering af anmodningen afslutter adgangen.';

  @override
  String get paymentDetailsUnavailable => 'Betalingsoplysninger er ikke tilgængelige. Opret forbindelse til internettet, og kontroller, at anmodningen stadig er åben.';

  @override
  String get paymentDetailsRetry => 'Prøv igen';

  @override
  String get tripModeSolo => 'Kun mig';

  @override
  String get tripModeGroup => 'Med andre';

  @override
  String get premiumFree => 'Gratis';

  @override
  String get premiumStatusUnavailable => 'Planstatus utilgængelig';

  @override
  String premiumGrantedUntil(String date) {
    return 'Premium-adgang gælder indtil $date';
  }

  @override
  String get premiumBillingNotActive => 'Intet aktivt abonnement';

  @override
  String get premiumRefreshStatus => 'Opdater planstatus';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String get activeStatus => 'Aktiv';

  @override
  String get activeTripPlural => 'aktive ture';

  @override
  String get activeTripSingle => 'aktiv tur';

  @override
  String get activeTrips => 'Aktive ture';

  @override
  String get activitiesComingSoon => 'Afsnittet om aktiviteter kommer snart.';

  @override
  String get addAction => 'Tilføj';

  @override
  String get addExpenseTitle => 'Tilføj udgift';

  @override
  String get addExpensesAction => 'Tilføj udgifter';

  @override
  String get addMembersAction => 'Tilføj medlemmer';

  @override
  String get addTripMembersTitle => 'Inviter rejsedeltagere';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitationer sendt',
      one: '$count invitation sendt',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Rejseinvitation afvist.';

  @override
  String get tripInviteAction => 'Inviter';

  @override
  String get tripInvitationsPending => 'Afventer svar';

  @override
  String get tripInvitationsRetry => 'Invitationer er ikke tilgængelige. Prøv igen';

  @override
  String get tripInvitationRevoke => 'Annuller invitation';

  @override
  String get tripInvitationRevokeFailed => 'Det var ikke muligt at annullere invitationen. Prøv igen.';

  @override
  String get tripInvitationBody => 'Du er blevet inviteret til en tur. Åbn invitationen for at svare.';

  @override
  String get allCaughtUp => 'Alt er opdateret';

  @override
  String get allFilter => 'Alle';

  @override
  String get allMembersLabel => 'Alle medlemmer';

  @override
  String get allPaymentsConfirmed => 'Alle betalinger bekræftes.';

  @override
  String get allTrips => 'Alle ture';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Beløb';

  @override
  String get amountMustBeGreaterThanZero => 'Beløbet skal være større end 0.';

  @override
  String get appearance => 'Udseende';

  @override
  String get archivedStatus => 'Arkiveret';

  @override
  String get authSubtitleLogin => 'Del rejseudgifter med venner';

  @override
  String get authSubtitleRegister => 'Opret en konto, og begynd at dele rejseomkostninger';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'bekræftet: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'afventer: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'sendt: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'foreslået: $count';
  }

  @override
  String get cancelAction => 'Annuller';

  @override
  String get changeEmailWithPasswordHelper => 'Indtast din adgangskode for at ændre e-mail-adresse.';

  @override
  String get chooseReceiptFile => 'Vælg kvitteringsfil';

  @override
  String get completeAccountSetupDescription => 'Indtast din e-mailadresse og adgangskode for at færdiggøre din konto.';

  @override
  String get completeAccountSetupTitle => 'Fuldfør kontoopsætningen';

  @override
  String get confirmReceivedAction => 'Bekræft modtagelse';

  @override
  String get confirmedAllSettlementsArchived => 'Alle afregninger er bekræftet. Turen er arkiveret.';

  @override
  String get confirmedAsReceived => 'Modtaget bekræftet.';

  @override
  String get confirmedLabel => 'Bekræftet';

  @override
  String get couldNotOpenReceiptLink => 'Det var ikke muligt at åbne linket til kvitteringen.';

  @override
  String get createAction => 'Opret';

  @override
  String get createFirstTripHint => 'Opret din første tur for at komme i gang.';

  @override
  String get createNewTripTitle => 'Opret ny tur';

  @override
  String get createTripAction => 'Opret tur';

  @override
  String get createTripFirst => 'Opret først en tur.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Oprettet af $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Rejsens opretter skal afslutte rejsen for at starte bekræftelsen af afregningen.';

  @override
  String currentEmailLabel(Object email) {
    return 'Aktuel e-mail: $email';
  }

  @override
  String get currentReceiptAttached => 'Den aktuelle kvittering er vedhæftet.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Dato';

  @override
  String get dateMustMatchFormat => 'Datoen skal være i formatet YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Dato ukendt';

  @override
  String get deleteAction => 'Slet';

  @override
  String get deleteExpenseConfirmQuestion => 'Skal denne udgift slettes?';

  @override
  String get deleteExpenseTitle => 'Slet udgift';

  @override
  String get editExpenseConfirmTitle => 'Skal ændringer i udgifterne gemmes?';

  @override
  String get editExpenseConfirmText => 'Dette vil opdatere saldoerne for alle på rejsen.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Forklaret direkte ved udgifter: $amount';
  }

  @override
  String get doneStatus => 'Færdig';

  @override
  String get editAction => 'Rediger';

  @override
  String get editExpenseTitle => 'Rediger udgift';

  @override
  String get emailAddressLabel => 'E-mail-adresse';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E- mail';

  @override
  String get emailRequired => 'E-mail er påkrævet.';

  @override
  String get enterValidExactAmounts => 'Indtast gyldige, nøjagtige beløb for alle deltagere.';

  @override
  String get enterValidPercentages => 'Indtast gyldige procenttal for alle deltagere.';

  @override
  String get equalSplitLabel => 'Del ligeligt';

  @override
  String exactAmountWithValue(Object value) {
    return 'Præcist: $value';
  }

  @override
  String get exactAmountsLabel => 'Præcise beløb';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Den nøjagtige fordeling skal i alt udgøre $amount.';
  }

  @override
  String get expenseAdded => 'Udgift tilføjet.';

  @override
  String get expenseBreakdownSubtitle => 'Hvordan dette medlem påvirkes af hver udgift.';

  @override
  String get expenseBreakdownTitle => 'Oversigt over udgifter';

  @override
  String get expenseDeleted => 'Udgiften er slettet.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Udgift nr. $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Betalt $paid  -  Skylder $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reaktioner';

  @override
  String get expenseCommentsTitle => 'Kommentarer';

  @override
  String get expenseNoComments => 'Ingen kommentarer endnu.';

  @override
  String get expenseAddCommentHint => 'Tilføj en kommentar...';

  @override
  String get expenseCommentSend => 'Send';

  @override
  String get expenseMentionNoMatches => 'Ingen matchende medlemmer';

  @override
  String get expenseMentionMembersLabel => 'Turmedlemmer, du kan nævne';

  @override
  String get expenseDeleteCommentTitle => 'Slette kommentar?';

  @override
  String get expenseUpdated => 'Udgiftsoplysningerne er opdateret.';

  @override
  String expenseWithId(Object id) {
    return 'Udgift nr. $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count udgifter',
      one: '$count udgift',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Udgifter';

  @override
  String get failedToCreateTrip => 'Det lykkedes ikke at oprette rejsen.';

  @override
  String get failedToLoadUsersDirectory => 'Det lykkedes ikke at indlæse brugeroversigten.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrer afregninger efter medlem';

  @override
  String get finishSoloTripConfirmationText => 'Vil du afslutte denne rejse og flytte den til dit arkiv? Dine udgifter vil fortsat være tilgængelige.';

  @override
  String get soloTripArchived => 'Turen er afsluttet og arkiveret.';

  @override
  String get finishTripSyncPending => 'Synkroniser dine ventende ændringer, før du afslutter denne tur.';

  @override
  String get finishTripAction => 'Afslut turen';

  @override
  String get finishTripConfirmationText => 'Afslutte denne tur og påbegynde afregningen?';

  @override
  String get finishTripStartSettlementsAction => 'Afslut og start afregninger';

  @override
  String get finishTripTitle => 'Afslut turen';

  @override
  String forParticipants(Object participants) {
    return 'Til: $participants';
  }

  @override
  String get forgotPassword => 'Glemt adgangskode?';

  @override
  String get profileSetPassword => 'Opret adgangskode';

  @override
  String get profileManagePassword => 'Opret eller skift adgangskode';

  @override
  String get profilePasswordByEmail => 'Indstil adgangskode via e-mail';

  @override
  String get passwordEmailBackToProfile => 'Tilbage til profil';

  @override
  String get forgotPasswordSubtitle => 'Indtast din e-mailadresse, så sender vi et link til nulstilling af adgangskode.';

  @override
  String get forgotPasswordSuccessMessage => 'Hvis der findes en konto med denne e-mailadresse, har vi sendt et link til nulstilling af adgangskode.';

  @override
  String get passwordResetSentTitle => 'Tjek din indbakke';

  @override
  String get passwordResetSentHint => 'Linket er gyldigt i 1 time. Kan du ikke finde e-mailen, så tjek din spam-mappe.';

  @override
  String get forgotPasswordTitle => 'Nulstil adgangskode';

  @override
  String get friendsProgressSubtitle => 'Hvert medlem og dets bekræftelsesstatus.';

  @override
  String get friendsProgressTitle => 'Venernes fremskridt';

  @override
  String get friendsSectionComingSoon => 'Afsnittet »Venner« kommer snart.';

  @override
  String fromDirection(Object name) {
    return 'Fra $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from til $to';
  }

  @override
  String get generateTurnAction => 'Træk næste person';

  @override
  String get hasAccountQuestion => 'Har du allerede en konto?';

  @override
  String helloUser(Object name) {
    return 'Hej, $name!';
  }

  @override
  String get iSentAction => 'Jeg sendte';

  @override
  String get invalidEmailFormat => 'Ugyldigt e-mail-format.';

  @override
  String get languageAction => 'Sprog';

  @override
  String get languageEnglish => 'Engelsk';

  @override
  String get languageLatvian => 'Lettisk';

  @override
  String get languageSpanish => 'Spansk';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemSubtitle => 'Brug enhedens sprog';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Lad feltet være tomt for at beholde den nuværende adgangskode.';

  @override
  String get logInButton => 'Log ind';

  @override
  String get logOutButton => 'Log ud';

  @override
  String get logoutFromDeviceQuestion => 'Vil du logge ud fra denne enhed?';

  @override
  String get logoutRevocationUnconfirmed => 'Du er logget ud på denne enhed. Tilbagekaldelse af serversessionen kunne ikke bekræftes.';

  @override
  String get markedAsSent => 'Markeret som sendt.';

  @override
  String get markSettlementSentConfirmTitle => 'Markere overførsel som sendt?';

  @override
  String get markSettlementSentConfirmText => 'Brug dette først, når du rent faktisk har afsendt betalingen. Modtageren vil blive bedt om at bekræfte.';

  @override
  String get settlementCancelSentAction => 'Marker som ikke sendt';

  @override
  String get settlementCancelSentConfirmTitle => 'Annullere status som sendt?';

  @override
  String get settlementCancelSentConfirmText => 'Dette vil flytte overførslen tilbage til status »afventende« og underrette modtageren.';

  @override
  String get settlementSentCancelled => 'Overførslen er flyttet tilbage til status »afventende«.';

  @override
  String get settlementNotReceivedAction => 'Jeg har ikke modtaget dette';

  @override
  String get settlementNotReceivedConfirmTitle => 'Meld manglende betaling?';

  @override
  String get settlementNotReceivedConfirmText => 'Dette vil flytte overførslen tilbage til status »afventende« og underrette betaleren.';

  @override
  String get settlementMarkedNotReceived => 'Markeret som ikke modtaget.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Er du sikker på, at du har modtaget det?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Bekræft først, når pengene er synlige på din konto. Denne handling kan afslutte afregningen.';

  @override
  String get memberSummariesSubtitle => 'Aktuel saldo for begge parter.';

  @override
  String get memberSummariesTitle => 'Medlemsoversigter';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'For at betale $total  -  bekræftet $confirmed  -  afventer $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Anslået indvirkning på betalingen pr. medlem.';

  @override
  String get membersImpactTitle => 'Medlemmernes indflydelse';

  @override
  String get membersIncludedInExpense => 'Medlemmer inkluderet';

  @override
  String get membersLabel => 'Medlemmer';

  @override
  String moreCount(Object count) {
    return '+ $count flere';
  }

  @override
  String get myFilter => 'Min';

  @override
  String get myImpactTitle => 'Min indflydelse';

  @override
  String get firstNameHint => 'Dit fornavn';

  @override
  String get firstNameLabel => 'Fornavn';

  @override
  String get firstNameLengthValidation => 'Fornavnet skal bestå af 2-64 tegn.';

  @override
  String get fullNameHelper => 'Brug fornavn og efternavn i ét felt.';

  @override
  String get fullNameHint => 'f.eks. Anna Ozolina';

  @override
  String get fullNameLabel => 'Fulde navn';

  @override
  String get fullNameValidation => 'Indtast fornavn og efternavn (mindst 2 tegn hver).';

  @override
  String get lastNameHint => 'Dit efternavn';

  @override
  String get lastNameLabel => 'Efternavn';

  @override
  String get lastNameLengthValidation => 'Efternavnet skal bestå af 2-64 tegn.';

  @override
  String get nameHint => 'Dit navn';

  @override
  String get nameLabel => 'Navn';

  @override
  String get nameLengthValidation => 'Navnet skal bestå af mindst 2 tegn.';

  @override
  String get navActivities => 'Statistik';

  @override
  String get navAddTrip => 'Tilføj tur';

  @override
  String get navBalances => 'Saldi';

  @override
  String get navExpenses => 'Udgifter';

  @override
  String get navFriends => 'Venner';

  @override
  String get navHome => 'Hjem';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRandom => 'Tilfældig';

  @override
  String get netLabel => 'Nettosaldo';

  @override
  String get newPasswordLabel => 'Ny adgangskode';

  @override
  String get nicknameHint => 'Sådan vil dine venner se dig';

  @override
  String get nicknameLabel => 'Kælenavn';

  @override
  String get nicknameLengthValidation => 'Kælenavnet skal bestå af mindst 2 tegn.';

  @override
  String get noAccountQuestion => 'Har du ikke en konto endnu?';

  @override
  String get noBalancesYet => 'Der er endnu ingen saldi.';

  @override
  String get noChangesToSave => 'Ingen ændringer at gemme.';

  @override
  String get noDirectExpenseLink => 'Der blev ikke fundet et direkte link til en enkelt udgift. Dette afregningsbeløb beregnes ud fra den samlede rejsebalance.';

  @override
  String get noExpenseImpactForMember => 'Ingen udgiftsmæssige konsekvenser for dette medlem.';

  @override
  String noExpensesByUserYet(Object name) {
    return '$name har endnu ingen udgifter.';
  }

  @override
  String get noExpensesYet => 'Ingen udgifter endnu.';

  @override
  String get noExtraUsersToAdd => 'Der skal ikke tilføjes yderligere brugere.';

  @override
  String get noInternetDeleteQueued => 'Intet internet. Slet i kø.';

  @override
  String get noInternetExpenseQueued => 'Intet internet. Udgift i kø.';

  @override
  String get noInternetUpdateQueued => 'Intet internet. Opdatering i kø.';

  @override
  String get noMatchingRows => 'Ingen matchende rækker.';

  @override
  String get noMembersFound => 'Der blev ikke fundet nogen medlemmer.';

  @override
  String get noNewMembersAdded => 'Disse personer er allerede medlemmer eller har udestående invitationer.';

  @override
  String get noNotePlaceholder => 'Ingen bemærkning';

  @override
  String get notificationsToday => 'I dag';

  @override
  String get notificationsEmptyBody => 'Opdateringer om ture, udgifter og venner vises her.';

  @override
  String get notificationsCached => 'Offline — viser gemte notifikationer.';

  @override
  String get notificationsRefreshFailed => 'Kunne ikke opdateres. Tidligere indlæste meddelelser vises.';

  @override
  String get notificationsJustNow => 'Lige nu';

  @override
  String notificationsMinutesAgo(int count) {
    return 'For $count min. siden';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'For $count t. siden';
  }

  @override
  String get notificationsUnread => 'Ulæst';

  @override
  String get noNotificationsYet => 'Ingen meddelelser endnu.';

  @override
  String get noParticipantData => 'Ingen deltagerdata.';

  @override
  String get noParticipantsSelected => 'Der er ikke valgt nogen deltagere.';

  @override
  String get noPaymentRowsInTrip => 'Der er ingen betalingsposter i denne tur.';

  @override
  String get noPaymentsNeeded => 'Der kræves ingen betalinger.';

  @override
  String get noPicksYet => 'Ingen valg endnu.';

  @override
  String get noSettlementActivityForMember => 'Ingen afregningsaktivitet for dette medlem.';

  @override
  String get noSettlementRowsYet => 'Der er endnu ingen afregningslinjer.';

  @override
  String get noSettlements => 'Ingen afregninger';

  @override
  String get noTransferNeededForFilter => 'Der kræves ingen overførsel for det valgte filter.';

  @override
  String get noTransferRowsToShow => 'Der er ingen overførselslinjer at vise.';

  @override
  String get noTripDataLoaded => 'Der er ikke indlæst nogen rejseoplysninger.';

  @override
  String get noTripsYet => 'Ingen ture endnu.';

  @override
  String get noUsersFoundYet => 'Der er endnu ikke fundet nogen brugere.';

  @override
  String get notSetValue => 'Ikke angivet';

  @override
  String get notYetConfirmedTitle => 'Endnu ikke bekræftet';

  @override
  String get noteHint => 'Middag, taxa, billetter...';

  @override
  String get noteLabel => 'Bemærk';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Noten må højst bestå af $max tegn.';
  }

  @override
  String get notificationFallbackTitle => 'Meddelelse';

  @override
  String get notificationsTitle => 'Meddelelser';

  @override
  String get notificationFriendInviteTitle => 'Venneanmodning';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name har sendt dig en venneanmodning.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Du har modtaget en venneinvitation.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Invitation accepteret';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name har accepteret din venneinvitation.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Din invitation til vennen blev accepteret.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Invitation afvist';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name har afvist din venneanmodning.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Din invitation til en ven blev afvist.';

  @override
  String get notificationTripAddedTitle => 'Føjet til turen';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name har tilføjet dig til turen \"$trip\".';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Du er blevet tilføjet til turen »$trip«.';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Du er blevet tilføjet til en tur.';

  @override
  String get notificationExpenseAddedTitle => 'Ny udgift tilføjet';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name har tilføjet en udgift på $amount i \"$trip\".';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name har tilføjet en udgift på $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Der er tilføjet en ny udgift.';

  @override
  String get notificationCommentMentionTitle => 'Du blev nævnt i en kommentar';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name nævnte dig i en kommentar til \"$note\".';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name nævnte dig i en kommentar.';
  }

  @override
  String get notificationTripFinishedTitle => 'Turen er afsluttet';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name har afsluttet \"$trip\". Afregningerne er klar.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name har afsluttet \"$trip\". Turen er arkiveret.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '»$trip« er afsluttet.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Rejsestatus er blevet opdateret.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Medlem markeret som klar';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name er klar til at deltage i \"$trip\".';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Et medlem er klar til at deltage i \"$trip\".';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Et medlem er klar til at afregne.';

  @override
  String get notificationTripReadyToSettleTitle => 'Alle medlemmer er klar';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Alle medlemmer er markeret som klar i »$trip«. Du kan nu påbegynde afregningerne.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Alle medlemmer er klar. Du kan påbegynde afregningerne.';

  @override
  String get notificationSettlementReminderTitle => 'Påmindelse om afregning';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor mindede $target om at markere $amount som sendt.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor mindede $target om at bekræfte modtagelsen af $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Du har modtaget en påmindelse om afregning.';

  @override
  String get notificationPaymentReminderTitle => 'Betalingspåmindelse';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Påmindelse: Markér venligst $amount som sendt til $target i \"$trip\".';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Påmindelse: Husk at markere betalingen som afsendt.';

  @override
  String get notificationConfirmationReminderTitle => 'Påmindelse om bekræftelse';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Påmindelse: Bekræft venligst modtagelsen af $amount fra $payer i \"$trip\".';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Påmindelse: Bekræft venligst modtagelsen af betalingen.';

  @override
  String get notificationSettlementSentTitle => 'Overførsel markeret som sendt';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name har markeret $amount som sendt til dig.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'En overførsel blev markeret som sendt.';

  @override
  String get notificationSettlementConfirmedTitle => 'Overførsel bekræftet';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name har bekræftet modtagelsen af $amount fra dig.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'En overførsel er bekræftet.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count afventende ændringer',
      one: '$count afventende ændring',
    );
    return 'Offlinekø: $_temp0';
  }

  @override
  String get syncAllSynced => 'Alt synkroniseret';

  @override
  String syncChangesWaiting(Object count) {
    return '$count venter på synkronisering';
  }

  @override
  String get syncFailedTapToRetry => 'Synkroniseringen mislykkedes. Tryk for at prøve igen';

  @override
  String get offlineQueueStatus => 'Offline-kø';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Kun turarrangøren kan afslutte turen.';

  @override
  String get openLabel => 'Åben';

  @override
  String get openReceiptAction => 'Åbn kvittering';

  @override
  String get openSettlements => 'Åbn afregninger';

  @override
  String get overviewTitle => 'Oversigt';

  @override
  String get owesLabel => 'Skylder';

  @override
  String get paidByLabel => 'Betalt af';

  @override
  String get paidLabel => 'Betalt';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Betalt $paid -  Skylder $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Deltagere (tom = alle medlemmer)';

  @override
  String get participantsTitle => 'Deltagere';

  @override
  String get passwordLabel => 'Adgangskode';

  @override
  String get passwordComplexityHelper => 'Brug mindst 1 stort bogstav, 1 tal og 1 symbol.';

  @override
  String get passwordComplexityValidation => 'Adgangskoden skal indeholde 1 stort bogstav, 1 tal og 1 symbol.';

  @override
  String get passwordMinLength => 'Adgangskoden skal bestå af mindst 8 tegn.';

  @override
  String get passwordMinLengthShort => 'Adgangskoden skal bestå af mindst 6 tegn.';

  @override
  String get passwordResetComingSoon => 'Nulstilling af adgangskode kommer snart.';

  @override
  String get passwordsDoNotMatch => 'Adgangskoderne stemmer ikke overens.';

  @override
  String payerName(Object name) {
    return '$name (betaler)';
  }

  @override
  String get pendingLabel => 'Afventer';

  @override
  String get pendingPaymentsSubtitle => 'Betalinger afventer stadig fuld bekræftelse.';

  @override
  String get percentLabel => 'Procent';

  @override
  String get percentSplitMustBe100 => 'Procentfordelingen skal i alt udgøre nøjagtigt 100 %.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Procenter';

  @override
  String get pickAtLeastOneParticipant => 'Vælg mindst én deltager.';

  @override
  String get pickMembersGenerateTurn => 'Vælg deltagere, og træk den næste person.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name valgt. Cyklus afsluttet.';
  }

  @override
  String pickedUser(Object name) {
    return '$name valgt.';
  }

  @override
  String get profileRefreshCachedData => 'Det var ikke muligt at opdatere profilen. Der vises data fra cachen.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpdated => 'Profil opdateret.';

  @override
  String get uploadAvatarAction => 'Upload avatar';

  @override
  String get takePhotoAction => 'Tag et billede';

  @override
  String get chooseFromLibraryAction => 'Vælg fra biblioteket';

  @override
  String get removeAvatarAction => 'Fjern avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar opdateret.';

  @override
  String get avatarRemovedMessage => 'Avatar fjernet.';

  @override
  String get avatarFileTooLarge => 'Avatarfilen er for stor (maks. 5 MB).';

  @override
  String get avatarPickFailed => 'Det var ikke muligt at indlæse avatar-billedet.';

  @override
  String get queueAddExpense => 'Tilføj udgift';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'I kø: tilføj udgift $amount';
  }

  @override
  String get queueDeleteExpense => 'Slet udgift';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'I kø: slet udgift nr. $id';
  }

  @override
  String get queuePendingStatus => 'Kø af ventende anmodninger';

  @override
  String get queueUpdateExpense => 'Opdater udgifter';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'I kø: opdater udgift nr. $id';
  }

  @override
  String get queuedChange => 'Ændringer i køen';

  @override
  String queuedChangesTitle(Object count) {
    return 'Ændringer i køen ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'I kø ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cyklus $cycleNo, træk $drawNo – $remaining tilbage';
  }

  @override
  String get receiptFallbackName => 'kvittering';

  @override
  String get receiptLinkInvalid => 'Kvitteringslinket er ugyldigt.';

  @override
  String get receiptOptionalLabel => 'Kvittering (valgfri)';

  @override
  String get recentPicksTitle => 'Seneste lodtrækninger';

  @override
  String get reloadProfile => 'Opdater profil';

  @override
  String get rememberMe => 'Husk mig';

  @override
  String get removeCurrentReceipt => 'Fjern den nuværende kvittering';

  @override
  String get repeatNewPasswordLabel => 'Gentag den nye adgangskode';

  @override
  String get repeatPasswordLabel => 'Gentag adgangskode';

  @override
  String get requestFailedTryAgain => 'Anmodningen mislykkedes. Prøv igen.';

  @override
  String get retryAction => 'Prøv igen';

  @override
  String get rowsLabel => 'Rækker';

  @override
  String get backToLoginAction => 'Tilbage til login';

  @override
  String get saveAction => 'Gem';

  @override
  String get saveCredentialsButton => 'Gem loginoplysninger';

  @override
  String get saveProfileButton => 'Gem profil';

  @override
  String get sendResetLinkButton => 'Send link til nulstilling';

  @override
  String get searchUsersHint => 'Søg efter personer ved navn eller e-mail';

  @override
  String get selectedPeopleLabel => 'Udvalgte personer';

  @override
  String get noSearchMatches => 'Der blev ikke fundet nogen matchende brugere.';

  @override
  String get savingButton => 'Gemmer...';

  @override
  String get selectAtLeastTwoMembers => 'Vælg mindst to deltagere.';

  @override
  String get selectMembersHint => 'Vælg medlemmer';

  @override
  String selectedFileLabel(Object name) {
    return 'Udvalgt: $name';
  }

  @override
  String get selectedLabel => 'Udvalgte';

  @override
  String get selectedUserFallback => 'Udvalgt bruger';

  @override
  String get settings => 'Indstillinger';

  @override
  String get settleUpAction => 'Afregn';

  @override
  String get settledLabel => 'Afregnet';

  @override
  String get settledStatus => 'Afregnet';

  @override
  String get settlementActivitySubtitle => 'Overførsler knyttet til dette medlem.';

  @override
  String get settlementActivityTitle => 'Afregningsaktivitet';

  @override
  String get settlementCompletedTitle => 'Afregning afsluttet';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total bekræftet';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Afregninger: $count';
  }

  @override
  String get settlementImpactTitle => 'Indvirkning på afregningen';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Indvirkning på afregningen: $name';
  }

  @override
  String get settlementInProgress => 'Afregning i gang';

  @override
  String get settlementInProgressTitle => 'Afregning i gang';

  @override
  String get settlementLabel => 'Afregning';

  @override
  String get settlementOverviewArchivedSubtitle => 'Turen er arkiveret. Alle afregninger er afsluttet.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Hold styr på bekræftelser af afregninger.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Vis en forhåndsvisning af overførslerne, når turen er afsluttet.';

  @override
  String get settlementPreview => 'Forhåndsvisning af afregning';

  @override
  String get settlementPreviewTitle => 'Forhåndsvisning af afregning';

  @override
  String get settlementProgressTripArchived => 'Turen er arkiveret';

  @override
  String settlementWithId(Object id) {
    return 'Afregning nr. $id';
  }

  @override
  String get settlements => 'Afregninger';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Afregningerne er allerede afsluttet.';

  @override
  String get settlementsDone => 'Afregninger foretaget';

  @override
  String get settlingStatus => 'Afregning';

  @override
  String get shareUnit => 'andel';

  @override
  String get sharesLabel => 'Andele';

  @override
  String get sharesMustBePositiveIntegers => 'Antallet af andele skal være et positivt heltal.';

  @override
  String sharesWithValue(Object value) {
    return 'Andele: $value';
  }

  @override
  String get showActiveTrips => 'Vis aktive ture';

  @override
  String get signUpButton => 'Opret konto';

  @override
  String get splitBreakdownSubtitle => 'Sådan fordeles udgiften';

  @override
  String get splitBreakdownTitle => 'Oversigt over fordeling';

  @override
  String get splitHintEqual => 'Fordel beløbet ligeligt mellem de udvalgte deltagere.';

  @override
  String get splitHintExact => 'Indtast det nøjagtige beløb for hver deltager. Summen skal stemme overens med det samlede beløb.';

  @override
  String get splitHintPercent => 'Indtast en procentdel for hver deltager. Summen skal være 100 %.';

  @override
  String get splitHintShares => 'Indtast delingsenheder (1, 2, 3...). Omkostningerne fordeles proportionalt.';

  @override
  String get splitLabel => 'Split';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Lige fordeling ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Præcise beløb ($target)';
  }

  @override
  String get splitModeLabel => 'Deltilstand';

  @override
  String splitModePercent(Object target) {
    return 'Procenttal ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Andele ($target)';
  }

  @override
  String get statusConfirmed => 'Bekræftet';

  @override
  String get statusPending => 'Afventer';

  @override
  String get statusSent => 'Sendt';

  @override
  String get statusSuggested => 'Foreslåede';

  @override
  String statusWithValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get suggestedTransferDirections => 'Foreslåede betalingsretninger';

  @override
  String get suggestedTransferFromExpense => 'Foreslået overførsel fra udgifter';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foreslåede overførsler',
      one: '$count foreslået overførsel',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Forventede rækker for betaler -> modtager.';

  @override
  String get suggestedTransfersTitle => 'Foreslåede overførsler';

  @override
  String get summarySettledUp => 'Afregnet';

  @override
  String get summaryYouAreOwed => 'Andre skylder dig';

  @override
  String get summaryYouOwe => 'Du skylder';

  @override
  String get syncAction => 'Synkronisering';

  @override
  String get syncNowAction => 'Synkroniser nu';

  @override
  String get syncingStatus => 'Synkronisering';

  @override
  String get tapToViewDetails => 'Tryk for at se detaljer';

  @override
  String get themeModeDark => 'Mørk';

  @override
  String get themeModeDarkSubtitle => 'Blød mørk farve (ikke ren sort)';

  @override
  String get themeModeLight => 'Lys';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeSystemSubtitle => 'Brug enhedens udseende';

  @override
  String toDirection(Object name) {
    return 'Til $name';
  }

  @override
  String get totalLabel => 'I alt';

  @override
  String get travelerFallbackName => 'Rejsende';

  @override
  String get tripAlreadyClosed => 'Turen er allerede afsluttet.';

  @override
  String get tripArchivedReadOnly => 'Turen er arkiveret. Skrivebeskyttet tilstand.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Turen er afsluttet. Redigering af udgifter er deaktiveret.';

  @override
  String get tripClosedExpensesReadOnly => 'Turen er afsluttet. Udgifterne er skrivebeskyttede.';

  @override
  String get tripClosedRandomDisabled => 'Turen er afsluttet. Tilfældig lodtrækning er deaktiveret.';

  @override
  String tripCreated(Object name) {
    return 'Turen »$name« er oprettet.';
  }

  @override
  String get tripFinished => 'Turen er afsluttet.';

  @override
  String get tripFinishedCompleteSettlements => 'Turen er afsluttet. Afslut afregningerne.';

  @override
  String get tripFinishedSettlementStarted => 'Turen er afsluttet. Afregningen er påbegyndt.';

  @override
  String get tripFullySettledArchived => 'Turen er fuldt afregnet og arkiveret.';

  @override
  String get tripNameHint => 'Skitur til Østrig';

  @override
  String get tripNameLabel => 'Rejsens navn';

  @override
  String get tripNameLengthValidation => 'Rejsens navn skal bestå af mindst 2 tegn.';

  @override
  String get tripSnapshotTitle => 'Rejseoversigt';

  @override
  String get tripTitleShort => 'Rejse';

  @override
  String tripStatusWithValue(Object status) {
    return 'Rejsestatus: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Turen nr. $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Uventet fejl ved indlæsning af profil';

  @override
  String get unexpectedErrorLoadingTripData => 'Uventet fejl ved indlæsning af rejseoplysninger';

  @override
  String get unexpectedErrorLoadingTrips => 'Uventet fejl ved indlæsning af ture';

  @override
  String get unexpectedErrorSavingChanges => 'Uventet fejl ved gemning af ændringer';

  @override
  String get unexpectedErrorSavingCredentials => 'Uventet fejl ved gemning af loginoplysninger';

  @override
  String get unexpectedErrorUpdatingProfile => 'Uventet fejl ved opdatering af profil';

  @override
  String get unknownError => 'Ukendt fejl';

  @override
  String get unknownLabel => 'Ukendt';

  @override
  String get unreadLabel => 'Ulæst';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ulæste opdateringer',
      one: '$count ulæst opdatering',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Manglende argument for rejserute.';

  @override
  String userIdLabel(Object id) {
    return 'Bruger-ID: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Betalt $paid  -  Skylder $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Bruger $id';
  }

  @override
  String get valueLabel => 'Værdi';

  @override
  String get viewAllTrips => 'Se alle ture';

  @override
  String get viewByPersonTitle => 'Visning pr. person';

  @override
  String get whoOwesWhatSubtitle => 'Hvem har betalt, og hvem skylder penge.';

  @override
  String get whoOwesWhatTitle => 'Hvem skylder hvad';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Hvem skylder hvad: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Udgiftsposter, der indgår i denne overførsel.';

  @override
  String get whyPaymentExistsTitle => 'Hvorfor denne betaling findes';

  @override
  String get youLabel => 'Du';

  @override
  String get youSettledForExpense => 'Du har afregnet din del af denne udgift.';

  @override
  String youShouldPay(Object amount) {
    return 'Du skal betale. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Du bør modtage: $amount';
  }

  @override
  String get yourShare => 'Din andel';

  @override
  String get yourTrips => 'Dine ture';

  @override
  String get authIntroSplitSmarter => 'Del smartere.';

  @override
  String get authIntroTravelFree => 'Rejs frit.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Hold styr på delte udgifter på tværs af valutaer, og afregn med det samme – ingen akavede gældsbeviser.';

  @override
  String get authIntroPlanTogether => 'Planlæg sammen.';

  @override
  String get authIntroPayClearly => 'Betal klart.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Opret ture på få sekunder, tilføj venner, og sørg for, at alle udgifter er gennemsigtige for alle.';

  @override
  String get authIntroSettleFast => 'Afslut hurtigt.';

  @override
  String get authIntroStayFriends => 'Lad os forblive venner.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Fra fælles middage til hele rejser sørger Splyto for, at regnskabet er retfærdigt og stressfrit.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Apple-login mislykkedes. Prøv igen.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Google-login mislykkedes. Prøv igen.';

  @override
  String get authIntroCreateAccount => 'Opret din konto.';

  @override
  String get authIntroChooseSign => 'Vælg, hvordan du vil tilmelde dig.';

  @override
  String get authIntroContinueGoogle => 'Fortsæt med Google';

  @override
  String get authIntroContinueApple => 'Fortsæt med Apple';

  @override
  String get authIntroBack => 'Tilbage';

  @override
  String get authIntroSplitSettled => 'Opdelingen er afsluttet';

  @override
  String get authIntroParis3Friends => 'Paris · 3 venner';

  @override
  String get authIntroGetStarted => 'Kom i gang';

  @override
  String get authIntroAlreadyHaveAccount => 'Har du allerede en konto? ';

  @override
  String get authIntroSignIn => 'Log ind';

  @override
  String get authIntroSignUpWithEmail => 'Tilmeld dig med e-mail';

  @override
  String get authIntroOr => 'ELLER';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Google-login returnerede ikke et id-token.';

  @override
  String get authAppleSignAvailableIosDevices => 'Apple-login er tilgængeligt på iOS-enheder.';

  @override
  String get authAppleSignNotAvailableDevice => 'Apple-login er ikke tilgængeligt på denne enhed.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Apple-login returnerede ikke et identitetstoken.';

  @override
  String get authCancel => 'Annuller';

  @override
  String get authSendLink => 'Send link';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'E-mailadressen er ikke bekræftet. Indtast din e-mailadresse for at anmode om et bekræftelseslink.';

  @override
  String get authEmailNotVerified => 'E-mail ikke bekræftet';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Skal der sendes et bekræftelseslink til $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Bekræftelseslink sendt. Tjek din e-mail.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Det var ikke muligt at sende bekræftelseslinket. Prøv venligst igen.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Bekræftelses-e-mail sendt. Bekræft venligst din e-mail, før du logger ind.';

  @override
  String get authVerifyEmail => 'Bekræft din e-mail';

  @override
  String get authEmailLabel => 'E-mail:';

  @override
  String get authClose => 'Luk';

  @override
  String get authResendLink => 'Send linket igen';

  @override
  String get profileAppSettingsSectionTitle => 'APP-INDSTILLINGER';

  @override
  String get profileEmailVerified => 'Bekræftet';

  @override
  String get profileEmailNotVerified => 'Ikke bekræftet';

  @override
  String get profileEmailSendVerification => 'Send link';

  @override
  String get profileEmailVerificationSent => 'Bekræftelsesmail sendt. Tjek din indbakke.';

  @override
  String get profileAccountSectionTitle => 'KONTO';

  @override
  String get profileAccountSettings => 'Kontoindstillinger';

  @override
  String get profileChangePhoto => 'Skift profilbillede';

  @override
  String get profileAppearance => 'Udseende';

  @override
  String get profileThemeDisplayMode => 'Tema og visningsmodus';

  @override
  String get profileLanguage => 'Sprog';

  @override
  String get profileDisplayLanguage => 'Visningssprog';

  @override
  String get profileNotificationsSectionHeading => 'MEDDELELSER';

  @override
  String get profileAppBanners => 'Bannere i appen';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Vis nye notifikationsbannere inde i appen';

  @override
  String get profilePushNotificationsTitle => 'Push-meddelelser';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Telefonbeskeder om udgifter, venner, ture og afregninger';

  @override
  String get profileSupportSectionHeading => 'SUPPORT';

  @override
  String get profileContactUs => 'Kontakt os';

  @override
  String get profileReportBugSuggestion => 'Rapporter fejl / Forslag';

  @override
  String get profileRateSplyto => 'Bedøm Splyto';

  @override
  String get profileLeaveStoreRating => 'Giv en bedømmelse af butikken';

  @override
  String get profileSecuritySectionHeading => 'SIKKERHED';

  @override
  String get profileAccountAndSecurity => 'Konto og sikkerhed';

  @override
  String get profileHelpTitle => 'Hjælp';

  @override
  String get profileChangePassword => 'Skift adgangskode';

  @override
  String get profileUpdateAccountPassword => 'Opdater kontoadgangskode';

  @override
  String get profileDangerZoneSectionHeading => 'FAREZONE';

  @override
  String get profileManageAccountAccess => 'Administrer kontoadgang';

  @override
  String get profileMadeWithLabel => 'Lavet med';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Handlingen »Gem bedømmelse« vil blive tilknyttet i næste trin.';

  @override
  String get profileFailedSaveNotificationSettings => 'Det lykkedes ikke at gemme notifikationsindstillingerne.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH-MEDDELELSER';

  @override
  String get profileInAppBannersSectionTitle => 'BANNERE I APPEN';

  @override
  String get profileInAppTripMemberAddedTitle => 'Medlem tilføjet til turen';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatisk påmindelse om afregning';

  @override
  String get profileExpenseUpdates => 'Opdateringer af udgifter';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Bannere om tilføjede udgifter i appen';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Meddelelser om tilføjede udgifter til telefonen';

  @override
  String get profileFriendInvites => 'Ven inviterer';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Bannere for venneanmodninger og svar i appen';

  @override
  String get profileFriendRequestResponseNotifications => 'Notifikationer om venneanmodninger og svar';

  @override
  String get profileTripUpdates => 'Rejseopdateringer';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Bannere om turens forløb og medlemsstatus i appen';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Rejsens livscyklus og ændringer i medlemsstatus';

  @override
  String get profileSettlementUpdates => 'Opdateringer vedrørende afregning';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Markerede bannere for »sendt« og »bekræftet betaling« i appen';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Markeret som sendt og bekræftede betalingsopdateringer';

  @override
  String get profileScreenshotSizeMust8Mb => 'Skærmbilleder må højst være 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Send feedback';

  @override
  String get profileFeedbackTypeLabel => 'Type';

  @override
  String get profileFeedbackTypeBug => 'Fejl';

  @override
  String get profileFeedbackTypeSuggestion => 'Forslag';

  @override
  String get profileDescribeIssueSuggestion => 'Beskriv problem eller forslag';

  @override
  String get profilePickingImage => 'Vælger billede...';

  @override
  String get profileAttachScreenshot => 'Vedhæft skærmbillede';

  @override
  String get profileChangeScreenshot => 'Skift skærmbillede';

  @override
  String get profileRemoveImage => 'Fjern billede';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Tip: Vedhæft et skærmbillede for hurtigere fejlklassificering';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Tilføj detaljer eller vedhæft et skærmbillede, inden du sender';

  @override
  String get profileSendAction => 'Send';

  @override
  String get profileThanksFeedbackSent => 'Tak! Feedback sendt';

  @override
  String get profileFailedSendFeedback => 'Det lykkedes ikke at sende feedback';

  @override
  String get profileCouldNotOpenWebsite => 'Det var ikke muligt at åbne hjemmesiden.';

  @override
  String get profileOpenWebsiteQuestion => 'Åbn hjemmeside?';

  @override
  String get profileOpenPortfolioAction => 'Åbn portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Dette billedformat understøttes ikke på denne enhed. Vælg venligst JPG eller PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Der kræves en gyldig e-mailadresse til din konto for at ændre din adgangskode. Kontakt support, hvis din e-mailadresse mangler eller er forkert.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Et link til sletning er sendt til din e-mail.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Det var ikke muligt at sende sletningslinket. Prøv venligst igen.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Indtast den nuværende adgangskode for at ændre e-mail-adresse.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Der er sendt en bekræftelse til den nye e-mailadresse. Der er sendt en sikkerhedsmeddelelse til din nuværende e-mailadresse.';

  @override
  String get profileEditOverviewCurrency => 'Oversigt over valuta';

  @override
  String get profileEditPaymentMethod => 'Betalingsmetode';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Bankoverførsel, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Indtast din adgangskode (valgfrit for Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Send sletningslink til e-mail';

  @override
  String get profileEditBackProfile => 'Tilbage til profil';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Indtast en gyldig e-mailadresse i profilen, før du ændrer adgangskoden.';

  @override
  String get profileEditPasswordUpdated => 'Adgangskode opdateret.';

  @override
  String get profileEditFailedUpdatePassword => 'Det lykkedes ikke at opdatere adgangskoden.';

  @override
  String profileEditEmail(Object email) {
    return 'Konto: $email';
  }

  @override
  String get profileEditPrimary => 'Primær';

  @override
  String get profileEditSearchCurrency => 'Søg efter valuta';

  @override
  String get profileEditNoCurrenciesFound => 'Ingen valutaer fundet';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Oversigtsbeløbene omregnes til denne valuta.';

  @override
  String get profileEditPaymentInfoUpdated => 'Betalingsoplysninger opdateret.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Det var ikke muligt at gemme betalingsoplysningerne. Prøv igen.';

  @override
  String get profileEditCurrentPassword => 'Nuværende adgangskode';

  @override
  String get profileEditBankTransferIbanSwift => 'Bankoverførsel (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me-link';

  @override
  String get profileEditChoosePaymentMethod => 'Vælg betalingsmetode';

  @override
  String get profileEditTapChange => 'Tryk for at ændre';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Ved overførsler i Storbritannien skal bankkoden bestå af 6 cifre og kontonummeret af 8 cifre.';

  @override
  String get profileEditPaymentInfo => 'Betalingsoplysninger';

  @override
  String get profileEditSaveDetails => 'Gem oplysninger';

  @override
  String get profileEditBankRegion => 'Bankregion';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'Bankkode';

  @override
  String get profileEditExample112233 => 'Eksempel: 112233';

  @override
  String get profileEditNumber => 'Kontonummer';

  @override
  String get profileEdit8Digits => '8 cifre';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Ved indenlandske overførsler i Storbritannien skal du bruge sort code + kontonummer.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Eksempel: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 eller 11 tegn';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Kontoindehaverens navn hentes fra det fulde navn i profilen.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username eller brugernavn';

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
  String get imageCropperAdjustAvatar => 'Juster avatar';

  @override
  String get imageCropperAdjustTripImage => 'Juster rejsebilledet';

  @override
  String get imageCropEditAction => 'Rediger beskæring';

  @override
  String get imageCropZoomIn => 'Zoom ind';

  @override
  String get imageCropZoomOut => 'Zoom ud';

  @override
  String get imageCropZoomOnly => 'Kun den beskårne version af billedet blev gemt, så du kan kun zoome ind.';

  @override
  String get imageCropLoadFailed => 'Billedet kunne ikke åbnes.';

  @override
  String get imageCropSaveFailed => 'Den nye beskæring kunne ikke gemmes. Prøv igen.';

  @override
  String get imageCropChanged => 'Billedet er blevet ændret i mellemtiden. Luk skærmen, og åbn den igen.';

  @override
  String get copyAction => 'Kopiér';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Britisk pund';

  @override
  String get currencyNameChf => 'Schweizisk franc';

  @override
  String get currencyNameNok => 'Norske kroner';

  @override
  String get currencyNameSek => 'Svenske kroner';

  @override
  String get currencyNameDkk => 'Dansk krone';

  @override
  String get currencyNamePln => 'Polsk zloty';

  @override
  String get currencyNameCzk => 'Tjekkisk koruna';

  @override
  String get currencyNameHuf => 'Ungarsk forint';

  @override
  String get currencyNameRon => 'Rumænsk leu';

  @override
  String get currencyNameBgn => 'Bulgarisk lev';

  @override
  String get currencyNameIsk => 'Islandsk krone';

  @override
  String get currencyNameAll => 'Albansk lek';

  @override
  String get currencyNameBam => 'Bosnien-Hercegovina Mark';

  @override
  String get currencyNameByn => 'Hviderussisk rubel';

  @override
  String get currencyNameMdl => 'Moldovisk leu';

  @override
  String get currencyNameMkd => 'Makedonsk denar';

  @override
  String get currencyNameRsd => 'Serbisk dinar';

  @override
  String get currencyNameUah => 'Ukrainsk hryvnia';

  @override
  String get currencyNameGel => 'Georgisk lari';

  @override
  String get currencyNameTry => 'Tyrkisk lira';

  @override
  String get currencyNameUsd => 'Amerikanske dollar';

  @override
  String get currencyNameJpy => 'Japanske yen';

  @override
  String get currencyNameCny => 'Kinesisk yuan';

  @override
  String get currencyNameCad => 'Canadiske dollar';

  @override
  String get currencyNameAud => 'Australske dollar';

  @override
  String get expenseCategoryFood => 'Mad';

  @override
  String get expenseCategoryGroceries => 'Dagligvarer';

  @override
  String get expenseCategoryFuel => 'Brændstof';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryAccommodation => 'Overnatning';

  @override
  String get expenseCategoryActivities => 'Aktiviteter';

  @override
  String get expenseCategoryTickets => 'Billetter';

  @override
  String get expenseCategoryShopping => 'Shopping';

  @override
  String get expenseCategoryParty => 'Fest';

  @override
  String get expenseCategoryParking => 'Parkering';

  @override
  String get expenseCategoryOther => 'Andet';

  @override
  String get shellTripAlreadyInListOpened => 'Turen er allerede på din liste. Vi har åbnet den for dig.';

  @override
  String get shellJoinedTripFromInviteLink => 'Tilmeldt tur via invitationslink.';

  @override
  String get shellFailedToOpenInviteLink => 'Det lykkedes ikke at åbne invitationslinket.';

  @override
  String get shellFailedToOpenFriendLink => 'Det lykkedes ikke at åbne venlinket.';

  @override
  String get shellTripInviteTitle => 'Rejseinvitation';

  @override
  String get shellNoAction => 'Nej';

  @override
  String get shellYesAction => 'Ja';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Kun turarrangøren kan slette denne tur.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Kun aktive ture kan slettes.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Slette »$tripLabel«? Dette er kun tilladt, før der tilføjes udgifter.';
  }

  @override
  String get shellTripDeleted => 'Turen er slettet.';

  @override
  String get shellFailedToDeleteTrip => 'Det lykkedes ikke at slette rejsen.';

  @override
  String get shellFailedToLoadNotifications => 'Det lykkedes ikke at indlæse meddelelser.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Ny meddelelse: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Det lykkedes ikke at opdatere notifikationerne.';

  @override
  String get shellMarkAllAsReadAction => 'Marker alle som læst';

  @override
  String get shellNewSection => 'Ny';

  @override
  String get shellEarlierSection => 'Tidligere';

  @override
  String get shellShowMoreEarlierAction => 'Vis flere tidligere';

  @override
  String get shellLoadingMore => 'Indlæser mere...';

  @override
  String get shellLoadMoreNotificationsAction => 'Vis flere meddelelser';

  @override
  String get shellTripNoLongerAvailable => 'Denne tur er ikke længere tilgængelig.';

  @override
  String get shellFailedToOpenTrip => 'Det lykkedes ikke at åbne rejsen.';

  @override
  String get shellYesterday => 'I går';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Du er allerede medlem af \"$tripName\". Vil du åbne denne tur nu?\n\nInviteret af: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Vil du deltage i turen »$tripName«?\n\nInviteret af: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Valgt billede: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Rejsebillede er allerede indstillet.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Turen er oprettet, men billedoverførslen mislykkedes.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Turen er oprettet, men billedoverførslen mislykkedes: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Deltag i turen via invitation';

  @override
  String get tripsTotalTrips => 'Samlet antal ture';

  @override
  String get tripsTotalSpent => 'Samlet forbrug';

  @override
  String get tripsMixedCurrencies => 'Blandede valutaer';

  @override
  String get tripsShowActive => 'Vis aktiv';

  @override
  String get tripsSeeAll => 'Se alle';

  @override
  String get tripsGridView => 'Gittervisning';

  @override
  String get tripsListView => 'Listevisning';

  @override
  String get tripsAddNewTrip => 'Opret ny tur';

  @override
  String get tripsLoadMore => 'Vis mere';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Slette »$arg1«? Dette er kun tilladt, før der tilføjes udgifter.';
  }

  @override
  String get tripsTripDates => 'Rejsedatoer';

  @override
  String get tripsFrom => 'Fra';

  @override
  String get tripsSelectDate => 'Vælg dato';

  @override
  String get tripsTo => 'Til';

  @override
  String get tripsMainCurrency => 'Hovedvaluta';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Vælg venligst rejseperioden (start- og slutdato).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Rejsens slutdato skal være på eller efter startdatoen.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Formatet for rejseperioden er ugyldigt. Vælg venligst datoer igen.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Du er allerede medlem af denne tur.';

  @override
  String get tripsJoinedTripSuccessfully => 'Du er nu tilmeldt turen.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Det lykkedes ikke at tilmelde sig turen via invitationen.';

  @override
  String get tripsJoinTrip => 'Deltag i turen';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Indsæt invitationslink eller invitationstoken.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Indtast et gyldigt invitationslink eller -token.';

  @override
  String get tripsClipboardIsEmpty => 'Udklipsholderen er tom.';

  @override
  String get tripsPaste => 'Indsæt';

  @override
  String get tripsJoin => 'Tilmeld dig';

  @override
  String get workspaceTripMembers => 'Rejsedeltagere';

  @override
  String get workspaceFailedToLoadFriends => 'Det lykkedes ikke at indlæse venner.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Det lykkedes ikke at generere et invitationslink.';

  @override
  String get workspaceInviteLink => 'Inviteringslink';

  @override
  String get workspaceGeneratingInviteLink => 'Opretter invitationslink...';

  @override
  String get workspaceInviteLinkUnavailable => 'Inviteringslinket er ikke tilgængeligt.';

  @override
  String get workspaceCopyInviteLink => 'Kopier invitationslink';

  @override
  String get workspaceInviteLinkCopied => 'Inviteringslink kopieret.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Udløber: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Der er ingen venner tilgængelige. Tilføj venner først.';

  @override
  String get workspaceSettle => 'Afregning';

  @override
  String get workspaceOwesToTheGroup => 'Skylder gruppen';

  @override
  String get workspaceGetsBackFromGroup => 'Skal modtage penge fra gruppen';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Viser de 4 øverste efter saldoforskel.';

  @override
  String get workspaceOpenFlow => 'Detaljer';

  @override
  String get workspaceFriend => 'Ven';

  @override
  String get workspaceSettlementTransfer => 'Overførsel af afregning';

  @override
  String get workspaceCompleted => 'Afsluttet';

  @override
  String get workspaceWaitingForConfirmation => 'Afventer bekræftelse';

  @override
  String get workspaceWaitingForPayment => 'Venter på betaling';

  @override
  String get workspaceActionNeeded => 'Nødvendig handling';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Betalinger, der skal markeres som sendt: $arg1; bekræftes som modtaget: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Klar til afregning';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Alle medlemmer er klar. Du kan påbegynde afregningerne.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Venter på, at alle markerer sig som klar.';

  @override
  String get workspaceIMReady => 'Jeg er klar';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Bekræft, at du har tilføjet alle dine udgifter.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Knappen »Afslut« låses op, når alle har markeret, at de er klar.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Skal modtage penge fra gruppen';

  @override
  String get workspaceSettledWithTheGroup => 'Aftalt med gruppen';

  @override
  String get workspaceTotalPaid => 'Samlet betalt';

  @override
  String get workspaceTotalOwes => 'Samlet skyldigt beløb';

  @override
  String get workspaceTransactionHistory => 'Transaktionshistorik';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Der er endnu ingen transaktioner for dette medlem.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Afregninger: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Alle deltagere skal markere sig som klar, før afregningen påbegyndes.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Du har markeret dig selv som klar til at afregne.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Mærket »Klar til afregning« er fjernet.';

  @override
  String get workspaceReminderSent => 'Påmindelse sendt.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Inviter via link eller tilføj fra venner';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Kun turarrangøren kan redigere denne tur.';

  @override
  String get workspaceTripUpdated => 'Turen er opdateret.';

  @override
  String get workspaceFailedToUpdateTrip => 'Det lykkedes ikke at opdatere rejsen.';

  @override
  String get workspaceNoMembersSelectedYet => 'Der er endnu ikke valgt nogen medlemmer.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Intet internet. Udgiften gemmes uden kvitteringsbillede.';

  @override
  String get workspaceRandomPicker => 'Lodtrækning';

  @override
  String get workspaceCurrency => 'Valuta';

  @override
  String get workspaceCategory => 'Kategori';

  @override
  String get workspaceCustomCategory => 'Brugerdefineret kategori';

  @override
  String get workspaceCategoryName => 'Kategorinavn';

  @override
  String get workspaceApartmentRentParkingEtc => 'Leje af lejlighed, parkering osv.';

  @override
  String get workspaceEnterACustomCategory => 'Indtast en brugerdefineret kategori.';

  @override
  String get workspacePickAnExpenseCategory => 'Vælg en udgiftskategori.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Kategorien skal bestå af mindst 2 tegn.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Kategorien må højst bestå af 64 tegn.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Procentfordelingen skal i alt udgøre 100 %.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Antallet af andele skal være større end 0 for alle deltagere.';

  @override
  String get workspaceTotalAmount => 'Samlet beløb';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Samlede omkostninger';

  @override
  String workspaceStarted(Object arg1) {
    return 'Startet $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Afsluttet $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Arkiveret tur';

  @override
  String get workspaceActiveTrip => 'Aktiv tur';

  @override
  String get workspaceMemberProfile => 'Medlemsprofil';

  @override
  String get workspaceTripOwner => 'Rejsearrangør';

  @override
  String get workspaceMember => 'Medlem';

  @override
  String get workspaceReadyForSettlement => 'Klar til afregning';

  @override
  String get workspaceNotReadyForSettlement => 'Ikke klar til afregning';

  @override
  String get workspaceBankDetails => 'Bankoplysninger';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN- og udbetalingsoplysninger vil blive tilføjet her i en kommende opdatering.';

  @override
  String get workspacePaymentDetails => 'Betalingsoplysninger';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Dette medlem har endnu ikke tilføjet udbetalingsoplysninger.';

  @override
  String get workspaceBankTransfer => 'Bankoverførsel';

  @override
  String get workspaceHolder => 'Indehaver';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Det var ikke muligt at åbne betalingslinket.';

  @override
  String get workspaceTripActivity => 'Rejseaktivitet';

  @override
  String get workspacePaidExpenses => 'Betalte udgifter';

  @override
  String get workspacePaidTotal => 'Betalt beløb i alt';

  @override
  String get workspaceInvolvedIn => 'Involveret i';

  @override
  String get workspaceCurrentTrip => 'Aktuel tur';

  @override
  String get workspaceCommonTrips => 'Fælles rejser';

  @override
  String get workspaceLoadingCommonTrips => 'Indlæser fælles rejser…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Ingen fælles rejser fundet endnu.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Alle fælles rejser kunne ikke indlæses. Den aktuelle rejse vises.';

  @override
  String get workspaceMembers => 'medlemmer';

  @override
  String get workspaceExpense => 'Udgifter';

  @override
  String get workspacePaid => 'betalt';

  @override
  String get workspaceLoadingMoreExpenses => 'Indlæser flere udgifter...';

  @override
  String get workspaceScrollDownToLoadMore => 'Rul ned for at indlæse mere';

  @override
  String get workspaceTripFinished => 'Turen er afsluttet';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Afregninger er aktiveret for denne tur.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Afslut turen for at påbegynde afregningen.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 har markeret overførslen som sendt.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Venter på, at $arg1 markerer som betalt.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 har bekræftet modtagelsen af betalingen.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Venter på, at $arg1 bekræfter.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Alle rejseafregninger er fuldt afsluttet.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Endelig status, når alle overførsler er bekræftet.';

  @override
  String get workspaceSettlementFlow => 'Afregningsforløb';

  @override
  String get workspaceActions => 'Handlinger';

  @override
  String get workspaceQuickPay => 'Hurtig betaling';

  @override
  String get workspacePayWithRevolut => 'Betal med Revolut';

  @override
  String get workspacePayWithPaypal => 'Betal med PayPal';

  @override
  String get workspacePayWithWise => 'Betal med Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Overførslen er bekræftet.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Venter på, at det andet medlem gennemfører det næste trin.';

  @override
  String get workspaceSendReminder => 'Send påmindelse';

  @override
  String get workspaceInProgress => 'I gang';

  @override
  String get workspaceTimeUnknown => 'Tid ukendt';

  @override
  String get workspaceRemind => 'Påmind';

  @override
  String get workspaceYourPosition => 'Din holdning';

  @override
  String get workspaceRecentActivity => 'Seneste aktivitet';

  @override
  String get workspaceNoRecentActivityYet => 'Ingen nylige aktiviteter endnu.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Tilføj mindst ét medlem for at begynde at dele udgifterne.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Markér dig selv som klar til afregning, når du har tilføjet alle dine udgifter.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Deltagere, som endnu ikke er klar: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Alle medlemmer er klar. Du kan afslutte turen og påbegynde afregningen.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Alle deltagere er klar. Vi venter på, at turarrangøren starter afregningen.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Afregning i gang: $arg1/$arg2 bekræftet.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Ingen ventende handlinger. Denne tur er afsluttet.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Der kræves ingen handling lige nu.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Du bør modtage $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Du skal betale $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Du er i øjeblikket tilmeldt denne tur.';

  @override
  String get workspaceUnknownTime => 'Ukendt tidspunkt';

  @override
  String get workspaceJustNow => 'Lige nu';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'For $arg1 min. siden';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'For $arg1 t. siden';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'For $arg1 d. siden';
  }

  @override
  String get friendsRemoveFriend => 'Fjern ven';

  @override
  String get friendsRemoveThisFriend => 'Skal denne ven fjernes?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 vil blive fjernet fra din venneliste. Du kan tilføje dem igen senere.';
  }

  @override
  String get friendsContinue => 'Fortsæt';

  @override
  String get friendsFriendRemoved => 'Ven fjernet.';

  @override
  String get friendsCouldNotRemoveFriend => 'Det var ikke muligt at fjerne vennen.';

  @override
  String get friendsFriendProfile => 'Venprofil';

  @override
  String get friendsMoreActions => 'Flere handlinger';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Denne ven har endnu ikke tilføjet udbetalingsoplysninger.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Kunne ikke indlæse fælles rejser lige nu.';

  @override
  String get friendsFinished => 'Færdig';

  @override
  String friendsTrip(Object arg1) {
    return 'Ture nr. $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Medlemmer: $arg1';
  }

  @override
  String get friendsNoDate => 'Ingen dato';

  @override
  String get friendsIncomingRequests => 'INDKOMMENDE ANMODNINGER';

  @override
  String get friendsSentInvites => 'SENDTE INVITATIONER';

  @override
  String get friendsMyFriends => 'MINE VENNER';

  @override
  String get friendsRequests => 'Anmodninger';

  @override
  String get friendsIncoming => 'Indgående';

  @override
  String get friendsIncomingRequestSubtitle => 'vil gerne være venner';

  @override
  String get friendsOutgoingInviteSubtitle => 'Invitation sendt';

  @override
  String get friendsNoPendingActivity => 'Ingen venneanmodninger';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Invitation sendt til $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Ingen indgående anmodninger';

  @override
  String get friendsDecline => 'Afvis';

  @override
  String get friendsAccept => 'Accepter';

  @override
  String get friendsNoSentInvites => 'Ingen sendte invitationer';

  @override
  String get friendsNoFriendsYet => 'Ingen venner endnu';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Rul ned for at hente flere venner.';

  @override
  String get friendsUser => 'Bruger';

  @override
  String get friendsSearchUsers => 'Søg efter brugere';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Søg efter navn eller e-mail, og send en invitation';

  @override
  String get friendsScanQr => 'Scan QR-koden';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Scan en anden bruger for at tilføje en ven';

  @override
  String get friendsMyQr => 'Min QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Vis eller del din QR-kode';

  @override
  String get friendsScanFriendQrTitle => 'Scan vennens QR-kode';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Placer vennens QR-kode inden for rammen';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Hold QR-koden inden for rammen';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Vil du tilføje $arg1 som ven?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 vil modtage din venneanmodning.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Skal ${arg1}s venneanmodning accepteres?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Scan denne QR-kode eller del linket for at tilføje mig på Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Føj mig på Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Splyto-vennelink';

  @override
  String get shareAction => 'Del';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'En QR-kode er ikke en gyldig vennekode.';

  @override
  String get friendsYouCannotAddYourself => 'Du kan ikke tilføje dig selv.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Denne bruger er allerede på din venneliste.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'En invitation til denne bruger er allerede sendt.';

  @override
  String get friendsFriendRequestProcessed => 'Venanmodning behandlet.';

  @override
  String get friendsFailedToProcessFriendQr => 'Det lykkedes ikke at behandle vennens QR-kode.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Det var ikke muligt at indlæse din brugerprofil.';

  @override
  String get friendsMyProfile => 'Min profil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Uventet fejl ved indlæsning af venner.';

  @override
  String get friendsFriendAdded => 'Ven tilføjet.';

  @override
  String get friendsRequestDeclined => 'Anmodning afvist.';

  @override
  String get friendsFailedToUpdateRequest => 'Det lykkedes ikke at opdatere anmodningen.';

  @override
  String get friendsCancelInvite => 'Annuller invitation';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Vil du annullere invitationen til $arg1?';
  }

  @override
  String get friendsKeep => 'Behold';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Invitation til $arg1 er annulleret.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Det lykkedes ikke at annullere invitationen.';

  @override
  String get analyticsOther => 'Andet';

  @override
  String get analyticsSelectATripForAnalytics => 'Vælg en tur til analyse';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Medlemmer: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Daglige udgifter';

  @override
  String get analyticsMyDaily => 'Mine daglige udgifter';

  @override
  String get analyticsGroupDaily => 'Gruppens daglige udgifter';

  @override
  String get analyticsByMember => 'Pr. deltager';

  @override
  String get analyticsShowLess => 'Vis mindre';

  @override
  String get analyticsByCategory => 'Efter kategori';

  @override
  String get analyticsQuickInsights => 'Hurtige indblik';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Største udgift: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Største forbruger: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Gruppens højeste dag: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Ingen datoer';

  @override
  String get friendsSearchFailedTryAgain => 'Søgningen mislykkedes. Prøv igen.';

  @override
  String get friendsFailedToSendInvite => 'Det lykkedes ikke at sende invitationen.';

  @override
  String get friendsAddFriend => 'Tilføj ven';

  @override
  String get friendsSearchByNameOrEmail => 'Søg efter navn eller e-mail';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Indtast mindst 2 tegn for at søge.';

  @override
  String get friendsNoUsersFound => 'Ingen brugere fundet';

  @override
  String get friendsInviteAction => 'Inviter';

  @override
  String get workspacePaidForGroup => 'Betalt for gruppen';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Betalt for gruppen • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Deling af udgifter';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Deling af udgifter • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Indehaverens navn er kopieret.';

  @override
  String get paymentIbanCopied => 'IBAN kopieret.';

  @override
  String get paymentSwiftCopied => 'SWIFT kopieret.';

  @override
  String get paymentRevtagCopied => 'Revtag kopieret.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Kunne ikke kopieres til udklipsholderen.';

  @override
  String get paymentCopied => 'Kopieret.';

  @override
  String get paymentRequestAction => 'Anmod om betaling';

  @override
  String get paymentRecordAction => 'Registrer betaling';

  @override
  String get paymentRequestSheetTitle => 'Anmod om betaling';

  @override
  String get paymentRecordSheetTitle => 'Registrer betaling';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Bed $arg1 om at betale et beløb, som vedkommende i øjeblikket skylder dig.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Brug dette, når du har betalt $arg1 uden for Splyto. De vil bekræfte modtagelsen.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Maksimum $arg1';
  }

  @override
  String get paymentNoteHint => 'Bankoverførsel, Revolut, kontanter...';

  @override
  String get paymentAmountPositiveError => 'Beløbet skal være større end nul.';

  @override
  String get paymentAmountTooHighError => 'Beløbet kan ikke være højere end den udestående saldo.';

  @override
  String get paymentRequestCreated => 'Betalingsanmodning sendt.';

  @override
  String get paymentRecordedWaiting => 'Betaling registreret. Afventer bekræftelse.';

  @override
  String get paymentConfirmTitle => 'Bekræft betaling';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Bekræft, at du har modtaget $arg1 fra $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Betaling bekræftet.';

  @override
  String get paymentCancelRecordTitle => 'Annuller betalingsregistrering';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Annuller registreringen af din betaling på $arg1 til $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Betalingsregistrering annulleret.';

  @override
  String get paymentNotReceivedTitle => 'Betaling ikke modtaget';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Vil du markere betalingen på $arg1 fra $arg2 som ikke modtaget?';
  }

  @override
  String get paymentMarkedNotReceived => 'Betaling markeret som ikke modtaget.';

  @override
  String get paymentActivityTitle => 'Betalingsaktivitet';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Åbne betalingsanmodninger: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Betalinger, der afventer bekræftelse: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Registrerede betalinger';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 har anmodet om betaling fra $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 har betalt $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Anmodning om betaling';

  @override
  String get paymentAwaitingConfirmationStatus => 'Afventer bekræftelse';

  @override
  String get paymentReviewRequestAction => 'Anmodning om gennemgang';

  @override
  String get paymentViewDetailsAction => 'Betalingsoplysninger';

  @override
  String get paymentMarkPaidAction => 'Jeg har betalt';

  @override
  String get paymentDeclineAction => 'Afvis';

  @override
  String get paymentRequestReviewTitle => 'Betalingsanmodning';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 har anmodet dig om $arg2. Betal uden for Splyto, og markér derefter betalingen som gennemført.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Markere anmodning som betalt?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Bekræft først, når du har betalt $arg1 til $arg2 uden for Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Markeret som betalt. Afventer bekræftelse.';

  @override
  String get paymentRequestCancelTitle => 'Annullere betalingsanmodning?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Vil du annullere din $arg1-anmodning til $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Betalingsanmodning annulleret.';

  @override
  String get paymentRequestDeclineTitle => 'Afvise betalingsanmodning?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Afvis betalingsanmodningen på $arg1 fra $arg2? Personen får besked.';
  }

  @override
  String get paymentRequestDeclined => 'Betalingsanmodning afvist.';

  @override
  String get paymentPendingBeforeFinish => 'Afklar åbne betalingsanmodninger og ubekræftede betalinger inden den endelige afregning.';

  @override
  String get paymentFinishBlockedByPending => 'Afslutningen låses op, når betalingsanmodninger og ubekræftede betalinger er afklaret.';

  @override
  String get notificationPaymentRequestedTitle => 'Anmodning om betaling';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 har anmodet dig om $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Du har modtaget en betalingsanmodning.';

  @override
  String get notificationPaymentRequestSentTitle => 'Anmodet betaling sendt';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 har markeret din $arg2-betalingsanmodning som betalt.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Din betalingsanmodning er markeret som betalt.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Betalingsanmodning annulleret';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 har annulleret betalingsanmodningen $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'En betalingsanmodning blev annulleret.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Betalingsanmodning afvist';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 har afvist din $arg2-betalingsanmodning.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Din betalingsanmodning blev afvist.';

  @override
  String get notificationPaymentSentTitle => 'Betaling markeret som sendt';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 har markeret $arg2 som betalt til dig.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'En betaling er markeret som sendt til dig.';

  @override
  String get notificationPaymentConfirmedTitle => 'Betaling bekræftet';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 har bekræftet modtagelsen af $arg2 fra dig.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Din betaling er bekræftet.';

  @override
  String get notificationPaymentCancelledTitle => 'Betaling annulleret';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 har annulleret $arg2-betalingsmærket.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'En betalingsmarkering blev annulleret.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Betaling ikke modtaget';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 har markeret $arg2-betalingen som ikke modtaget.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'En betaling blev markeret som ikke modtaget.';

  @override
  String get quickStartTitle => 'Hurtigstart';

  @override
  String get quickStartCreateTitle => 'Alene eller med venner';

  @override
  String get quickStartCreateBody => 'Opret en tur til dig selv eller en gruppe. Tilføj venner med link eller QR-kode, og inviter dem.';

  @override
  String get quickStartInviteTitle => 'Rejs sammen eller alene';

  @override
  String get quickStartInviteBody => 'Inviter venner til at deltage i din rejse, eller start en personlig rejse på egen hånd.';

  @override
  String get quickStartExpenseTitle => 'Udgifter i mange valutaer';

  @override
  String get quickStartExpenseBody => 'Vælg, hvem der betalte, og hvordan det deles. Andre valutaer omregnes til kursen på købsdatoen, også hvis du tilføjer dem senere.';

  @override
  String get quickStartSettleTitle => 'Afregn nemt';

  @override
  String get quickStartSettleBody => 'Se, hvem der skylder hvem, betal, som du vil, og bekræft det i appen.';

  @override
  String get quickStartAnalyticsTitle => 'Budget og udgifter';

  @override
  String get quickStartAnalyticsBody => 'Sæt et budget for turen eller gruppen, og se udgifter pr. kategori, tur og dag.';

  @override
  String get quickStartMapTitle => 'Gem dine steder';

  @override
  String get quickStartMapBody => 'Føj de byer, du har besøgt, til dit private rejsekort. Kun du kan se det.';

  @override
  String get quickStartLiveTitle => 'Find hinanden';

  @override
  String get quickStartLiveBody => 'På gruppeture deler du din live-placering i den tid, du vælger. Turens medlemmer kan se den, og du kan stoppe når som helst.';

  @override
  String get quickStartNext => 'Næste';

  @override
  String get quickStartBack => 'Tilbage';

  @override
  String get quickStartSkip => 'Spring over';

  @override
  String get quickStartCreateAction => 'Opret tur';

  @override
  String get quickStartClose => 'Luk hurtigstart';

  @override
  String get quickStartSubtitle => 'Se, hvordan ture og udgifter fungerer';

  @override
  String quickStartStep(int step, int total) {
    return 'Trin $step af $total';
  }

  @override
  String get workspaceTripTotal => 'Rejsens samlede beløb';

  @override
  String get workspacePersonalTotal => 'Samlet forbrug';

  @override
  String get workspaceBalanceEven => 'Din saldo er udlignet';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Du skylder $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Du får $amount tilbage';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Medlemmer: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Søg efter udgifter';

  @override
  String get workspaceClearSearch => 'Tydelig søgning';

  @override
  String get workspaceSearchLoadedHint => 'Søgningen omfatter indlæste udgifter. Indlæs flere for at medtage ældre udgifter.';

  @override
  String get workspaceNoExpenseMatches => 'Ingen matchende udgifter';

  @override
  String get workspaceNoExpenseMatchesBody => 'Prøv en anden søgning, eller ryd søgningen for at se alle indlæste udgifter.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Tilføj din første udgift for at begynde at holde styr på dine udgifter.';

  @override
  String get workspaceEmptyGroupExpenses => 'Tilføj din første delte udgift for at se alles andel.';

  @override
  String get workspaceLoadMoreExpenses => 'Indlæs flere udgifter';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Oprindeligt beløb: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Kommentarer: $count';
  }

  @override
  String get workspaceExpenseActions => 'Udgiftshandlinger';

  @override
  String get workspaceLoadErrorTitle => 'Kunne ikke indlæse denne tur';

  @override
  String get workspaceCachedWarning => 'Visning af gemte data. Disse kan være forældede.';

  @override
  String get workspaceActivityTab => 'Aktivitet';

  @override
  String get workspaceLoadingTrip => 'Indlæser tur';

  @override
  String get workspaceRefreshFailed => 'Opdatering mislykkedes';

  @override
  String get expenseDetailsTitle => 'Udgiftsoplysninger';

  @override
  String get expenseQuickCategories => 'Hurtige kategorier';

  @override
  String get expenseReceiptRead => 'Kvittering læst og formular opdateret.';

  @override
  String get expenseReceiptNoData => 'Kvittering vedhæftet. Der er ikke angivet noget klart beløb, dato eller forhandler.';

  @override
  String get expenseReceiptScanFailed => 'Kvittering valgt. Automatisk indlæsning mislykkedes; kontroller felterne manuelt.';

  @override
  String get expenseReceiptOffline => 'Kvitteringen uploades, når du gemmer. Automatisk aflæsning kræver en internetforbindelse.';

  @override
  String get expenseReadingReceipt => 'Læser kvitteringen…';

  @override
  String get expenseCommentsLoadFailed => 'Det var ikke muligt at indlæse kommentarer. Prøv igen.';

  @override
  String get expenseReplyAction => 'Svar';

  @override
  String get expenseReplyHint => 'Skriv et svar…';

  @override
  String expenseReplyTo(String name) {
    return 'Svar til $name';
  }

  @override
  String get balanceEmptyBody => 'Saldoen vises, når udgifterne er tilføjet.';

  @override
  String get balanceAfterPayments => 'Saldoen omfatter bekræftede betalinger.';

  @override
  String get balanceExpenseShare => 'Udgiftsdeling';

  @override
  String get balanceHistoryScope => 'Indlæste udgifter og bekræftede betalinger. Denne liste omfatter muligvis ikke hele rejsehistorikken.';

  @override
  String balancePaymentTo(String name) {
    return 'Betaling til $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Betaling fra $name';
  }

  @override
  String get settlementEmptyActive => 'Markér alle som klar, inden du påbegynder den endelige afregning.';

  @override
  String get settlementEmptyClosed => 'Der er ingen overførsler angivet for denne tur.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count af $total overførsler bekræftet';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count af $total medlemmer er klar';
  }

  @override
  String get settlementMemberReady => 'Klar';

  @override
  String get settlementMemberNotReady => 'Ikke klar';

  @override
  String get settlementSuggested => 'Foreslået overførsel';

  @override
  String get activityLoadFailed => 'Det var ikke muligt at opdatere aktiviteten. Eventuelle synlige poster kan være forældede.';

  @override
  String get activityMember => 'Rejsedeltager';

  @override
  String get friendsEmptyBody => 'Find en ven ved navn eller e-mail, eller brug en QR-kode.';

  @override
  String get friendsDeclineAction => 'Afvis';

  @override
  String get friendsLoading => 'Indlæser venner';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Delte ture: $count';
  }

  @override
  String get memberActivityScope => 'Baseret på indtastede udgifter; dette dækker muligvis ikke hele rejsen.';

  @override
  String get sharedTripsLoadedLimit => 'Viser op til 20 delte ture.';

  @override
  String get memberRemoveTitle => 'Fjerne medlem?';

  @override
  String memberRemoveBody(String name) {
    return 'Skal $name fjernes fra denne tur? Dette er kun muligt, hvis vedkommende ikke har udgifter, afregninger eller saldo.';
  }

  @override
  String get memberRemoveAction => 'Fjern fra turen';

  @override
  String memberRemoved(String name) {
    return '$name er fjernet fra turen.';
  }

  @override
  String get profilePaymentNotAdded => 'Ikke tilføjet endnu';

  @override
  String get friendRelationshipLabel => 'Ven';

  @override
  String get sharedTripsEmptyBody => 'Ture, som I begge deltager i, vises her.';

  @override
  String get analyticsAllTrips => 'Alle ture';

  @override
  String get analyticsByTrip => 'Efter tur';

  @override
  String get analyticsYourSpending => 'Dine udgifter';

  @override
  String get analyticsActiveArchived => 'Aktive og arkiverede ture';

  @override
  String get analyticsTrips => 'Ture';

  @override
  String get analyticsAveragePerTrip => 'Gennemsnit pr. tur';

  @override
  String get analyticsPaidByMember => 'Betalt af medlemmet';

  @override
  String get analyticsYouPaid => 'Du betalte.';

  @override
  String get analyticsYouGetBack => 'Du får tilbage';

  @override
  String get analyticsYouOwe => 'Du skylder';

  @override
  String get analyticsParticipants => 'Deltagere';

  @override
  String get analyticsYourCategories => 'Dine udgifter efter kategori';

  @override
  String get analyticsLargestShares => 'Mine største udgiftsandele';

  @override
  String get analyticsLargestExpenses => 'Største udgifter';

  @override
  String get analyticsSpendingByTrip => 'Dine udgifter pr. tur';

  @override
  String get analyticsEmptyTitle => 'Ingen udgifter endnu';

  @override
  String get analyticsEmptyBody => 'Dine udgifter vises her, når du tilføjer udgifter til en rejse.';

  @override
  String get analyticsPeriodEmptyBody => 'Der er ingen omkostninger forbundet med denne visning. Prøv en anden tur eller periode.';

  @override
  String get analyticsLoadFailed => 'Det var ikke muligt at indlæse den fulde udgiftsrapport. Prøv igen.';

  @override
  String get analyticsLastLoaded => 'Visning af den seneste rapport, der er indlæst uden problemer.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count udgifter',
      one: '$count udgift',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Rejseindstillinger';

  @override
  String get editTripAction => 'Rediger tur';

  @override
  String get deleteTripAction => 'Slet tur';

  @override
  String get inviteTripMembersAction => 'Inviter medlemmer';

  @override
  String get tripCoverPhoto => 'Forsidebillede';

  @override
  String get tripInviteLaterHint => 'Du kan invitere personer, efter at du har oprettet rejsen.';

  @override
  String get inviteClipboardFailed => 'Kunne ikke få adgang til udklipsholderen. Prøv igen.';

  @override
  String get friendInviteToTrip => 'Inviter til tur';

  @override
  String get friendChooseTrip => 'Vælg en tur';

  @override
  String get friendNoInvitableTrips => 'Der er ingen tilgængelige ture. Du kan invitere venner til aktive gruppeture, som du administrerer, medmindre de allerede er medlemmer eller har en ventende invitation.';

  @override
  String get friendTripInviteSent => 'Invitation sendt.';

  @override
  String get friendTripUnavailable => 'Denne tur er ikke længere tilgængelig for denne handling. Opdater og prøv igen.';

  @override
  String get friendTripActionFailed => 'Det var ikke muligt at gennemføre denne handling. Prøv igen.';

  @override
  String get profileContactDescription => 'Har du et problem, et forslag eller et spørgsmål om Splyto? Send os en e-mail – vi hjælper gerne.';

  @override
  String get profileContactEmailAction => 'Skriv en e-mail';

  @override
  String get profileContactEmailUnavailable => 'Det var ikke muligt at åbne en e-mail-app. Kopier adressen, og skriv til os fra din e-mail-app.';

  @override
  String get profilePrivacyPolicy => 'Privatlivspolitik';

  @override
  String get privacyLoadFailed => 'Det var ikke muligt at indlæse privatlivspolitikken. Prøv igen.';

  @override
  String get addReceiptAction => 'Tilføj kvittering';

  @override
  String get receiptPickFailed => 'Det var ikke muligt at indlæse kvitteringen. Prøv igen.';

  @override
  String get receiptPhotoAccessDenied => 'Giv Splyto adgang til kameraet eller fotobiblioteket under Indstillinger, og prøv derefter igen.';

  @override
  String get receiptPhotoLabel => 'Foto af kvittering';

  @override
  String get replaceReceiptAction => 'Erstat kvittering';

  @override
  String get removeReceiptAction => 'Fjern kvittering';

  @override
  String get restoreReceiptAction => 'Gendan tidligere kvittering';

  @override
  String get expenseSplitBetween => 'Opdel mellem';

  @override
  String get expenseEditParticipants => 'Vælg deltagere';

  @override
  String get expenseCustomSplit => 'Brugerdefineret fordeling';

  @override
  String expenseSplitAllocated(String amount) {
    return 'Hele $amount fordelt';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return '$amount tilbage at dele';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount over totalbeløbet';
  }

  @override
  String get profilePaymentSharingTitle => 'Del betalingsmetoder med mine ture';

  @override
  String get profilePaymentSharingDescription => 'Tillad godkendte deltagere i rejser, som jeg opretter eller tilmelder mig, at se mine betalingsmetoder. Dette gælder både nuværende og fremtidige rejser. Du kan til enhver tid slå delingen fra for at forhindre yderligere adgang.';

  @override
  String get memberPaymentDetailsNotShared => 'Betalingsmetoder deles ikke eller er i øjeblikket ikke tilgængelige.';

  @override
  String get homeTripInvitations => 'Rejseinvitationer';

  @override
  String get homeNoTripInvitations => 'Ingen ventende rejseinvitationer';

  @override
  String get homeInvitationsLoadFailed => 'Det var ikke muligt at indlæse invitationer. Prøv igen.';

  @override
  String get homeInvitationResponseFailed => 'Det var ikke muligt at svare på invitationen. Prøv venligst igen.';

  @override
  String get homeTripShareFailed => 'Det var ikke muligt at dele rejsen. Prøv igen.';

  @override
  String get settleStillToReceive => 'Mangler at modtage';

  @override
  String get settleStillToPay => 'Skal stadig betales';

  @override
  String get settleEstimateCaption => 'Estimat baseret på aktuelle udgifter. Beløbene kan ændre sig, indtil rejsen slutter.';

  @override
  String get settleOutstandingCaption => 'Afventer betaling eller bekræftelse.';

  @override
  String get settleWaitingForYou => 'Vi venter på, at du markerer dig som klar.';

  @override
  String get settleWhoPaysWhom => 'Hvem betaler hvem?';

  @override
  String get settlePreviewCaption => 'Forhåndsvisning · færdiggjort, når turen slutter';

  @override
  String get settleOpenPaymentCaption => 'Åbn en betaling for at se detaljer og tilgængelige handlinger.';

  @override
  String get tripBudgetEnable => 'Fastlæg et budget';

  @override
  String get tripBudgetSoloHint => 'Valgfrit udgiftsmål for denne tur.';

  @override
  String get tripBudgetGroupHint => 'Ét fælles budget for hele gruppen.';

  @override
  String get tripBudgetAmount => 'Budgetbeløb';

  @override
  String get tripBudgetInvalid => 'Indtast et beløb fra 0,01 til 999999999,99 med op til to decimaler.';

  @override
  String get tripBudgetTitle => 'Rejsebudget';

  @override
  String get tripBudgetGroupTitle => 'Gruppebudget';

  @override
  String get tripBudgetRemaining => 'Resterende';

  @override
  String get tripBudgetOver => 'Over budget';

  @override
  String get tripBudgetSpent => 'Brugt';

  @override
  String get tripBudgetLimit => 'Budget';

  @override
  String get travelMapTitle => 'Mit rejsekort';

  @override
  String get travelMapSubtitle => 'Steder, du har besøgt – kun til dig.';

  @override
  String get travelMapHere => 'Jeg har været her';

  @override
  String get travelMapAdd => 'Tilføj sted';

  @override
  String get travelMapSearch => 'Søg efter by og land';

  @override
  String get travelMapSearchAction => 'Søg';

  @override
  String get travelMapSearchHint => 'For eksempel Lissabon, Portugal';

  @override
  String get travelMapEmpty => 'Dit næste minde starter her';

  @override
  String get travelMapEmptyBody => 'Tilføj en by, du har besøgt, eller tjek ind der, hvor du er nu.';

  @override
  String get travelMapConfirm => 'Vil du gemme dette besøg?';

  @override
  String get travelMapConfirmBody => 'Tjek byen og datoen, før du gemmer den på dit private kort.';

  @override
  String get travelMapDate => 'Besøgsdato';

  @override
  String get travelMapSave => 'Gem på mit kort';

  @override
  String get travelMapCancel => 'Annuller';

  @override
  String get travelMapClose => 'Luk';

  @override
  String get travelMapNoResults => 'Der blev ikke fundet nogen by. Prøv at tilføje landet til din søgning.';

  @override
  String get travelMapLookupError => 'Kunne ikke finde byen. Tjek din internetforbindelse, eller tilføj et sted manuelt.';

  @override
  String get travelMapDenied => 'Adgang til placering er slået fra. Du kan stadig tilføje en by manuelt.';

  @override
  String get travelMapDisabled => 'Aktivér lokaliseringstjenester, eller tilføj en by manuelt.';

  @override
  String get travelMapError => 'Det var ikke muligt at indlæse dit rejsekort. Prøv igen.';

  @override
  String get travelMapSaveError => 'Det var ikke muligt at gemme besøget. Prøv igen.';

  @override
  String get travelMapUnavailable => 'Rejsekortet kræver en serveropdatering.';

  @override
  String get travelMapOffline => 'Offline · viser gemte steder';

  @override
  String get travelMapRetry => 'Prøv igen';

  @override
  String get travelMapDelete => 'Fjern besøg';

  @override
  String get travelMapDeleteConfirm => 'Vil du fjerne dette besøg fra dit private kort?';

  @override
  String get travelMapFit => 'Vis alle steder';

  @override
  String get travelMapSaved => 'Besøg gemt';

  @override
  String get travelMapVisited => 'Besøgt';

  @override
  String get travelMapLimit => 'Dit kort har nået 1.000 besøg. Fjern et gammelt besøg, før du tilføjer et nyt.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries lande',
      one: '$countries land',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities byer',
      one: '$cities by',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count besøg',
      one: '$count besøg',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Rejsemål (valgfrit)';

  @override
  String get travelAddDestination => 'Tilføj destination';

  @override
  String get travelRemoveDestination => 'Fjern destination';

  @override
  String get travelFromTrip => 'Fra en tur';

  @override
  String get travelChooseTrip => 'Vælg en tur';

  @override
  String get travelNoTrips => 'Der er endnu ingen ture tilgængelige. Du kan tilføje et sted manuelt.';

  @override
  String get travelAddToMap => 'Føj til mit kort';

  @override
  String get travelTripConfirm => 'Gem kun steder, du rent faktisk har besøgt. Dette tilføjer et privat minde til dit kort.';

  @override
  String get travelVisitTitle => 'Titel (valgfri)';

  @override
  String get travelAddPhoto => 'Tilføj et foto';

  @override
  String get travelChangePhoto => 'Skift foto';

  @override
  String get travelRemovePhoto => 'Fjern foto';

  @override
  String get travelPhotoError => 'Dette foto kunne ikke forberedes. Vælg venligst et andet.';

  @override
  String get travelEditVisit => 'Rediger besøg';

  @override
  String get travelOpenTrip => 'Åben tur';

  @override
  String get travelPreviousVisit => 'Tidligere besøg';

  @override
  String get travelNextVisit => 'Næste besøg';

  @override
  String get travelDuplicate => 'Dette besøg er allerede på dit kort.';

  @override
  String get liveMapTitle => 'Live-kort';

  @override
  String get liveShareTitle => 'Del min position';

  @override
  String get liveConsent => 'Del kun din præcise placering med godkendte deltagere i denne rejse i det tidsrum, du vælger. Delingen fortsætter i baggrunden, og du kan stoppe den når som helst.';

  @override
  String get liveBackgroundNote => 'Opdateringer kan sættes på pause uden internetforbindelse eller hvis du tvinger appen til at lukke. Kun den seneste position gemmes; der registreres ingen rutehistorik.';

  @override
  String get liveStart => 'Start deling';

  @override
  String get liveStop => 'Stop deling';

  @override
  String get liveNotification => 'Din position deles med din rejse. Åbn Splyto for at stoppe delingen.';

  @override
  String get livePermissionError => 'Tillad adgang til placering i telefonens indstillinger for at dele din placering.';

  @override
  String get liveStartError => 'Det var ikke muligt at starte delingen. Kontroller adgangen til placering, internetforbindelsen samt dato og klokkeslæt på din telefon.';

  @override
  String get liveStopPending => 'Opdateringer er stoppet. Venter på internetforbindelse for at slette din sidste position; den forsvinder fra kortet inden for 2 minutter uden opdateringer.';

  @override
  String get liveSharing => 'deler placering';

  @override
  String get liveUnavailable => 'Dette livekort er ikke tilgængeligt. Gå tilbage til rejsen og opdater.';

  @override
  String get liveMapLoadError => 'Kortet kunne ikke indlæses. Tjek din internetforbindelse, og åbn kortet igen.';

  @override
  String get liveLoadError => 'Det var ikke muligt at opdatere placeringer. Kun de seneste opdateringer vises.';

  @override
  String get liveFit => 'Vis alle på kortet';

  @override
  String get liveEmpty => 'Ingen deler endnu en aktuel position.';

  @override
  String get liveRecent => 'Netop opdateret';

  @override
  String get liveLastKnown => 'Senest opdateret';

  @override
  String get liveAccuracy => 'Nøjagtighed';

  @override
  String get liveUntil => 'Deling indtil';

  @override
  String get liveOtherSession => 'Startet i en anden session. Du kan stoppe den her.';

  @override
  String get liveUpdatesPaused => 'Opdateringer er sat på pause. Tjek adgang til placering og internet.';

  @override
  String get livePrivateUntilShared => 'Din position forbliver privat, indtil du vælger at dele den.';

  @override
  String get activityEventExpenseCreated => 'tilføjede en udgift';

  @override
  String get activityEventExpenseUpdated => 'opdaterede en udgift';

  @override
  String get activityEventExpenseDeleted => 'slettede en udgift';

  @override
  String get activityEventExpenseCommentAdded => 'kommenterede en udgift';

  @override
  String get activityEventTripCreated => 'oprettede turen';

  @override
  String get activityEventTripUpdated => 'opdaterede turens oplysninger';

  @override
  String get activityEventTripRenamed => 'omdøbte turen';

  @override
  String get activityEventTripCurrencyChanged => 'ændrede turens valuta';

  @override
  String get activityEventTripPhotoChanged => 'ændrede turens billede';

  @override
  String get activityEventTripBudgetChanged => 'ændrede turens budget';

  @override
  String get activityEventTripDestinationsChanged => 'ændrede turens destinationer';

  @override
  String get activityEventTripMembersAdded => 'tilføjede medlemmer';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'sendte invitationer: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'tilsluttede sig turen';

  @override
  String get activityEventTripInvitationDeclined => 'afviste turinvitationen';

  @override
  String get activityEventTripInvitationRevoked => 'annullerede en turinvitation';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'fjernede $name fra turen';
  }

  @override
  String get activityEventTripMemberLeft => 'forlod turen';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'ændrede rollen for $name til $role';
  }

  @override
  String get activityEventTripMemberReady => 'markerede sig som klar til afregning';

  @override
  String get activityEventTripMemberNotReady => 'markerede sig som ikke klar';

  @override
  String get activityEventTripAllMembersReady => 'Alle medlemmer er klar til at afregne';

  @override
  String get activityEventTripFinished => 'afsluttede turen';

  @override
  String get activityEventTripSettled => 'Alle overførsler er bekræftet, turen er afregnet';

  @override
  String get activityEventSettlementMarkedSent => 'markerede en overførsel som sendt';

  @override
  String get activityEventSettlementConfirmed => 'bekræftede en overførsel';

  @override
  String get activityEventSettlementSentCancelled => 'annullerede status »sendt«';

  @override
  String get activityEventSettlementNotReceived => 'markerede en overførsel som ikke modtaget';

  @override
  String get activityEventSettlementReminderSent => 'sendte en påmindelse om afregning';

  @override
  String get activityEventPaymentMarkedSent => 'registrerede en betaling';

  @override
  String get activityEventPaymentRequested => 'anmodede om en betaling';

  @override
  String get activityEventPaymentRequestMarkedSent => 'markerede en anmodet betaling som sendt';

  @override
  String get activityEventPaymentRequestCancelled => 'annullerede en betalingsanmodning';

  @override
  String get activityEventPaymentRequestDeclined => 'afviste en betalingsanmodning';

  @override
  String get activityEventPaymentConfirmed => 'bekræftede en betaling';

  @override
  String get activityEventPaymentCancelled => 'annullerede en betalingspost';

  @override
  String get activityEventPaymentNotReceived => 'markerede en betaling som ikke modtaget';

  @override
  String get activityEventUnknown => 'foretog en ændring';

  @override
  String get privacyEnglishFallback => 'Privatlivspolitikken er i øjeblikket tilgængelig på engelsk.';

  @override
  String get activityRoleAdmin => 'Admin';

  @override
  String get accountDeleteTitle => 'Slet konto';

  @override
  String get accountDeleteIntro => 'Bekræft sletningen via e-mail. Efter bekræftelsen kan den ikke fortrydes.';

  @override
  String get accountDeleteConsequences => 'Sletning er permanent. Din profil anonymiseres, og adgangen til din konto fjernes. Delte rejse- og udgiftsoptegnelser opbevares for andre medlemmer.';

  @override
  String get accountDeleteReasonsTitle => 'Hvad kunne vi have gjort bedre?';

  @override
  String get accountDeleteReasonsHint => 'Årsag (valgfrit)';

  @override
  String get accountDeleteReasonNotUsing => 'Jeg har ikke længere brug for Splyto til mine ture';

  @override
  String get accountDeleteReasonAnotherWay => 'Jeg administrerer delte udgifter på en anden måde';

  @override
  String get accountDeleteReasonComplicated => 'Det kræver for meget arbejde at få tingene gjort';

  @override
  String get accountDeleteReasonTechnical => 'Jeg er stødt på fejl eller tekniske problemer';

  @override
  String get accountDeleteReasonPrivacy => 'Jeg vil helst slette mine kontooplysninger';

  @override
  String get accountDeleteReasonOther => 'Jeg vil slette min konto af en anden grund';

  @override
  String get accountDeleteEmailStep => 'Det næste trin er bekræftelse via e-mail.';

  @override
  String get accountDeletePasswordHint => 'Indtast din nuværende Splyto-adgangskode for at anmode om bekræftelses-e-mailen. Din konto er stadig aktiv.';

  @override
  String get accountDeleteInboxTitle => 'Et sidste trin i din indbakke';

  @override
  String accountDeleteSentBody(String email) {
    return 'Bekræftelseslink sendt til $email.';
  }

  @override
  String get accountDeleteSentHint => 'Din konto forbliver aktiv, indtil du bekræfter sletningen.';

  @override
  String get accountDeleteSending => 'Afsendelse af bekræftelses-e-mail';

  @override
  String get friendsShowMore => 'Vis flere';
}
