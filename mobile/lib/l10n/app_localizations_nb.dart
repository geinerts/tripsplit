// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get homeFirstTrip => 'Din første tur';

  @override
  String get homeYourShareAllTrips => 'Din andel av alle reiser';

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
    return 'Reisehandlinger: $name';
  }

  @override
  String get homeNoActiveTrips => 'Ingen aktive reiser';

  @override
  String get homeNoArchivedTrips => 'Ingen arkiverte reiser';

  @override
  String get homeLoadingTrips => 'Laster inn turene dine';

  @override
  String get homeLoadErrorTitle => 'Kunne ikke laste inn turene dine';

  @override
  String get homeLoadErrorBody => 'Prøv igjen om et øyeblikk.';

  @override
  String get homeOfflineTitle => 'Du er frakoblet';

  @override
  String get homeOfflineNoData => 'Turene dine er ikke tilgjengelige på denne enheten ennå.';

  @override
  String get homeOfflineCached => 'Offline. Viser lagrede turer.';

  @override
  String get homeRefreshError => 'Kunne ikke oppdatere. Viser tidligere lastede turer.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Del mine lagrede betalingsopplysninger med $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Kun mens denne forespørselen venter på betaling. Å avbryte forespørselen avslutter tilgangen.';

  @override
  String get paymentDetailsUnavailable => 'Betalingsopplysningene er ikke tilgjengelige. Koble deg til internett og sjekk om forespørselen fortsatt er åpen.';

  @override
  String get paymentDetailsRetry => 'Prøv på nytt';

  @override
  String get tripModeSolo => 'Bare meg';

  @override
  String get tripModeGroup => 'Med andre';

  @override
  String get premiumFree => 'Gratis';

  @override
  String get premiumStatusUnavailable => 'Planstatus utilgjengelig';

  @override
  String premiumGrantedUntil(String date) {
    return 'Premium-tilgang gitt frem til $date';
  }

  @override
  String get premiumBillingNotActive => 'Ingen aktivt abonnement';

  @override
  String get premiumRefreshStatus => 'Oppdater planstatus';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String get activeStatus => 'Aktiv';

  @override
  String get activeTripPlural => 'aktive turer';

  @override
  String get activeTripSingle => 'aktiv tur';

  @override
  String get activeTrips => 'Aktive turer';

  @override
  String get activitiesComingSoon => 'Aktivitetsdelen kommer snart.';

  @override
  String get addAction => 'Legg til';

  @override
  String get addExpenseTitle => 'Legg til utgift';

  @override
  String get addExpensesAction => 'Legg til utgifter';

  @override
  String get addMembersAction => 'Legg til medlemmer';

  @override
  String get addTripMembersTitle => 'Inviter reisedeltakere';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitasjoner sendt',
      one: '$count invitasjon sendt',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Reiseinvitasjon avvist.';

  @override
  String get tripInviteAction => 'Inviter';

  @override
  String get tripInvitationsPending => 'Venter på svar';

  @override
  String get tripInvitationsRetry => 'Invitasjoner er ikke tilgjengelige. Prøv på nytt';

  @override
  String get tripInvitationRevoke => 'Avbryt invitasjon';

  @override
  String get tripInvitationRevokeFailed => 'Kunne ikke avbryte invitasjonen. Prøv på nytt.';

  @override
  String get tripInvitationBody => 'Du har blitt invitert til en tur. Åpne invitasjonen for å svare.';

  @override
  String get allCaughtUp => 'Alt er oppdatert';

  @override
  String get allFilter => 'Alle';

  @override
  String get allMembersLabel => 'Alle medlemmer';

  @override
  String get allPaymentsConfirmed => 'Alle betalinger blir bekreftet.';

  @override
  String get allTrips => 'Alle turer';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Beløp';

  @override
  String get amountMustBeGreaterThanZero => 'Beløpet må være større enn 0.';

  @override
  String get appearance => 'Utseende';

  @override
  String get archivedStatus => 'Arkivert';

  @override
  String get authSubtitleLogin => 'Del reisekostnader med venner';

  @override
  String get authSubtitleRegister => 'Opprett konto og begynn å dele reisekostnader';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'bekreftet: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'ventende: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'sendt: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'foreslått: $count';
  }

  @override
  String get cancelAction => 'Avbryt';

  @override
  String get changeEmailWithPasswordHelper => 'Skriv inn passordet ditt for å endre e-postadresse.';

  @override
  String get chooseReceiptFile => 'Velg kvitteringsfil';

  @override
  String get completeAccountSetupDescription => 'Angi e-postadresse og passord for å fullføre kontoen din.';

  @override
  String get completeAccountSetupTitle => 'Fullfør kontooppsettet';

  @override
  String get confirmReceivedAction => 'Bekreft mottak';

  @override
  String get confirmedAllSettlementsArchived => 'Alle oppgjør bekreftet. Turen arkivert.';

  @override
  String get confirmedAsReceived => 'Bekreftet mottatt.';

  @override
  String get confirmedLabel => 'Bekreftet';

  @override
  String get couldNotOpenReceiptLink => 'Kunne ikke åpne kvitteringslenken.';

  @override
  String get createAction => 'Opprett';

  @override
  String get createFirstTripHint => 'Opprett din første tur for å komme i gang.';

  @override
  String get createNewTripTitle => 'Opprett ny tur';

  @override
  String get createTripAction => 'Opprett tur';

  @override
  String get createTripFirst => 'Opprett en tur først.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date - Opprettet av $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Reiseoppretteren må fullføre reisen for å starte bekreftelsen av oppgjøret.';

  @override
  String currentEmailLabel(Object email) {
    return 'Gjeldende e-postadresse: $email';
  }

  @override
  String get currentReceiptAttached => 'Gjeldende kvittering er vedlagt.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Dato';

  @override
  String get dateMustMatchFormat => 'Datoen må være i formatet YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Dato ukjent';

  @override
  String get deleteAction => 'Slett';

  @override
  String get deleteExpenseConfirmQuestion => 'Slette denne utgiften?';

  @override
  String get deleteExpenseTitle => 'Slett utgift';

  @override
  String get editExpenseConfirmTitle => 'Lagre endringer i utgiftene?';

  @override
  String get editExpenseConfirmText => 'Dette vil oppdatere saldoene for alle på turen.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Forklart direkte ved utgifter: $amount';
  }

  @override
  String get doneStatus => 'Ferdig';

  @override
  String get editAction => 'Rediger';

  @override
  String get editExpenseTitle => 'Rediger utgift';

  @override
  String get emailAddressLabel => 'E-postadresse';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E-post';

  @override
  String get emailRequired => 'E-postadresse er påkrevd.';

  @override
  String get enterValidExactAmounts => 'Angi gyldige, nøyaktige beløp for alle deltakere.';

  @override
  String get enterValidPercentages => 'Angi gyldige prosentandeler for alle deltakere.';

  @override
  String get equalSplitLabel => 'Del likt';

  @override
  String exactAmountWithValue(Object value) {
    return 'Nøyaktig: $value';
  }

  @override
  String get exactAmountsLabel => 'Nøyaktige beløp';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Den nøyaktige fordelingen må til sammen utgjøre $amount.';
  }

  @override
  String get expenseAdded => 'Utgift lagt til.';

  @override
  String get expenseBreakdownSubtitle => 'Hvordan dette medlemmet påvirkes av hver utgift.';

  @override
  String get expenseBreakdownTitle => 'Utgiftsoversikt';

  @override
  String get expenseDeleted => 'Utgiften er slettet.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Utgift nr. $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Betalt $paid  -  Skylder $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reaksjoner';

  @override
  String get expenseCommentsTitle => 'Kommentarer';

  @override
  String get expenseNoComments => 'Ingen kommentarer ennå.';

  @override
  String get expenseAddCommentHint => 'Legg til en kommentar...';

  @override
  String get expenseCommentSend => 'Send';

  @override
  String get expenseDeleteCommentTitle => 'Slette kommentar?';

  @override
  String get expenseUpdated => 'Utgiftsopplysningene er oppdatert.';

  @override
  String expenseWithId(Object id) {
    return 'Utgift nr. $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utgifter',
      one: '$count utgift',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Utgifter';

  @override
  String get failedToCreateTrip => 'Det lyktes ikke å opprette turen.';

  @override
  String get failedToLoadUsersDirectory => 'Kunne ikke laste inn brukerkatalogen.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrer oppgjør etter medlem';

  @override
  String get finishSoloTripConfirmationText => 'Vil du avslutte denne turen og flytte den til arkivet ditt? Utgiftene dine vil fortsatt være tilgjengelige for visning.';

  @override
  String get soloTripArchived => 'Turen er fullført og arkivert.';

  @override
  String get finishTripSyncPending => 'Synkroniser de ventende endringene dine før du avslutter denne turen.';

  @override
  String get finishTripAction => 'Avslutt tur';

  @override
  String get finishTripConfirmationText => 'Fullføre denne turen og starte oppgjør?';

  @override
  String get finishTripStartSettlementsAction => 'Fullfør og start oppgjør';

  @override
  String get finishTripTitle => 'Avslutt tur';

  @override
  String forParticipants(Object participants) {
    return 'For: $participants';
  }

  @override
  String get forgotPassword => 'Glemt passord?';

  @override
  String get profileSetPassword => 'Angi passord';

  @override
  String get profileManagePassword => 'Angi eller endre passord';

  @override
  String get profilePasswordByEmail => 'Angi passord via e-post';

  @override
  String get passwordEmailBackToProfile => 'Tilbake til profilen';

  @override
  String get forgotPasswordSubtitle => 'Skriv inn e-postadressen din, så sender vi deg en lenke for å tilbakestille passordet.';

  @override
  String get forgotPasswordSuccessMessage => 'Hvis det finnes en konto med denne e-postadressen, har vi sendt en lenke for å tilbakestille passordet.';

  @override
  String get passwordResetSentTitle => 'Sjekk innboksen din';

  @override
  String get passwordResetSentHint => 'Lenken er gyldig i 1 time. Hvis du ikke ser e-posten, sjekk søppelpostmappen.';

  @override
  String get forgotPasswordTitle => 'Tilbakestill passord';

  @override
  String get friendsProgressSubtitle => 'Hvert medlem og dets bekreftelsesstatus.';

  @override
  String get friendsProgressTitle => 'Venners fremgang';

  @override
  String get friendsSectionComingSoon => '«Venner»-delen kommer snart.';

  @override
  String fromDirection(Object name) {
    return 'Fra $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from til $to';
  }

  @override
  String get generateTurnAction => 'Trekk neste person';

  @override
  String get hasAccountQuestion => 'Har du allerede en konto?';

  @override
  String helloUser(Object name) {
    return 'Hei, $name!';
  }

  @override
  String get iSentAction => 'Jeg sendte';

  @override
  String get invalidEmailFormat => 'Ugyldig e-postformat.';

  @override
  String get languageAction => 'Språk';

  @override
  String get languageEnglish => 'Engelsk';

  @override
  String get languageLatvian => 'Lettisk';

  @override
  String get languageSpanish => 'Spansk';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemSubtitle => 'Bruk enhetens språk';

  @override
  String get leaveEmptyKeepPasswordHelper => 'La feltet stå tomt for å beholde gjeldende passord.';

  @override
  String get logInButton => 'Logg inn';

  @override
  String get logOutButton => 'Logg ut';

  @override
  String get logoutFromDeviceQuestion => 'Logg av fra denne enheten?';

  @override
  String get logoutRevocationUnconfirmed => 'Logget ut på denne enheten. Det var ikke mulig å bekrefte opphevelsen av serversesjonen.';

  @override
  String get markedAsSent => 'Merkes som sendt.';

  @override
  String get markSettlementSentConfirmTitle => 'Merk overføringen som sendt?';

  @override
  String get markSettlementSentConfirmText => 'Bruk dette først etter at du faktisk har sendt betalingen. Mottakeren vil bli bedt om å bekrefte.';

  @override
  String get settlementCancelSentAction => 'Merk som ikke sendt';

  @override
  String get settlementCancelSentConfirmTitle => 'Avbryte «sendt»-status?';

  @override
  String get settlementCancelSentConfirmText => 'Dette vil føre til at overføringen igjen blir satt til «ventende» og at mottakeren blir varslet.';

  @override
  String get settlementSentCancelled => 'Overføringen er flyttet tilbake til «ventende».';

  @override
  String get settlementNotReceivedAction => 'Jeg har ikke mottatt dette';

  @override
  String get settlementNotReceivedConfirmTitle => 'Melde fra om at betalingen ikke er mottatt?';

  @override
  String get settlementNotReceivedConfirmText => 'Dette vil flytte overføringen tilbake til «ventende» og varsle betaleren.';

  @override
  String get settlementMarkedNotReceived => 'Merkes som ikke mottatt.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Bekreftet mottatt?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Bekreft først etter at pengene er synlige på kontoen din. Denne handlingen kan fullføre oppgjøret.';

  @override
  String get memberSummariesSubtitle => 'Gjeldende saldostatus for begge parter.';

  @override
  String get memberSummariesTitle => 'Medlemsoversikter';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'For å betale $total  -  bekreftet $confirmed  -  venter $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Anslått betalingspåvirkning per medlem.';

  @override
  String get membersImpactTitle => 'Medlemmers innflytelse';

  @override
  String get membersIncludedInExpense => 'Medlemmer inkludert';

  @override
  String get membersLabel => 'Medlemmer';

  @override
  String moreCount(Object count) {
    return '+ $count flere';
  }

  @override
  String get myFilter => 'Min';

  @override
  String get myImpactTitle => 'Min innvirkning';

  @override
  String get firstNameHint => 'Fornavnet ditt';

  @override
  String get firstNameLabel => 'Fornavn';

  @override
  String get firstNameLengthValidation => 'Fornavnet må bestå av 2–64 tegn.';

  @override
  String get fullNameHelper => 'Bruk for- og etternavn i ett felt.';

  @override
  String get fullNameHint => 'f.eks. Anna Ozolina';

  @override
  String get fullNameLabel => 'Fullt navn';

  @override
  String get fullNameValidation => 'Skriv inn for- og etternavn (minst 2 tegn hver).';

  @override
  String get lastNameHint => 'Etternavnet ditt';

  @override
  String get lastNameLabel => 'Etternavn';

  @override
  String get lastNameLengthValidation => 'Etternavnet må bestå av 2–64 tegn.';

  @override
  String get nameHint => 'Ditt navn';

  @override
  String get nameLabel => 'Navn';

  @override
  String get nameLengthValidation => 'Navnet må bestå av minst 2 tegn.';

  @override
  String get navActivities => 'Statistikk';

  @override
  String get navAddTrip => 'Legg til tur';

  @override
  String get navBalances => 'Saldoer';

  @override
  String get navExpenses => 'Utgifter';

  @override
  String get navFriends => 'Venner';

  @override
  String get navHome => 'Hjem';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRandom => 'Tilfeldig';

  @override
  String get netLabel => 'Nettosaldo';

  @override
  String get newPasswordLabel => 'Nytt passord';

  @override
  String get nicknameHint => 'Slik vil vennene dine se deg';

  @override
  String get nicknameLabel => 'Kallenavn';

  @override
  String get nicknameLengthValidation => 'Kallenavnet må bestå av minst 2 tegn.';

  @override
  String get noAccountQuestion => 'Har du ikke konto ennå?';

  @override
  String get noBalancesYet => 'Ingen saldoer ennå.';

  @override
  String get noChangesToSave => 'Ingen endringer å lagre.';

  @override
  String get noDirectExpenseLink => 'Det ble ikke funnet noen direkte lenke for enkeltutgifter. Dette oppgjøret beregnes ut fra den totale reisebalansen.';

  @override
  String get noExpenseImpactForMember => 'Ingen kostnadsmessige konsekvenser for dette medlemmet.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Ingen utgifter for $name ennå.';
  }

  @override
  String get noExpensesYet => 'Ingen utgifter ennå.';

  @override
  String get noExtraUsersToAdd => 'Ingen ekstra brukere å legge til.';

  @override
  String get noInternetDeleteQueued => 'Ingen internettforbindelse. Slett i kø.';

  @override
  String get noInternetExpenseQueued => 'Ingen internettforbindelse. Utgiften står i kø.';

  @override
  String get noInternetUpdateQueued => 'Ingen internettforbindelse. Oppdatering i kø.';

  @override
  String get noMatchingRows => 'Ingen samsvarende rader.';

  @override
  String get noMembersFound => 'Ingen medlemmer funnet.';

  @override
  String get noNewMembersAdded => 'Disse personene er allerede medlemmer eller har invitasjoner som venter på svar.';

  @override
  String get noNotePlaceholder => 'Ingen merknad';

  @override
  String get notificationsToday => 'I dag';

  @override
  String get notificationsEmptyBody => 'Oppdateringer om turer, utgifter og venner vil vises her.';

  @override
  String get notificationsCached => 'Offline – viser lagrede varsler.';

  @override
  String get notificationsRefreshFailed => 'Kunne ikke oppdatere. Tidligere lastede varsler vises.';

  @override
  String get notificationsJustNow => 'Akkurat nå';

  @override
  String notificationsMinutesAgo(int count) {
    return 'For $count min siden';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'For $count t siden';
  }

  @override
  String get notificationsUnread => 'Ulest';

  @override
  String get noNotificationsYet => 'Ingen varsler ennå.';

  @override
  String get noParticipantData => 'Ingen deltakerdata.';

  @override
  String get noParticipantsSelected => 'Ingen deltakere valgt.';

  @override
  String get noPaymentRowsInTrip => 'Ingen betalingslinjer i denne turen.';

  @override
  String get noPaymentsNeeded => 'Ingen betalinger nødvendig.';

  @override
  String get noPicksYet => 'Ingen valg ennå.';

  @override
  String get noSettlementActivityForMember => 'Ingen avregningsaktivitet for dette medlemmet.';

  @override
  String get noSettlementRowsYet => 'Ingen avregningslinjer ennå.';

  @override
  String get noSettlements => 'Ingen oppgjør';

  @override
  String get noTransferNeededForFilter => 'Ingen overføring nødvendig for det valgte filteret.';

  @override
  String get noTransferRowsToShow => 'Ingen overføringslinjer å vise.';

  @override
  String get noTripDataLoaded => 'Ingen reisedata lastet inn.';

  @override
  String get noTripsYet => 'Ingen turer ennå.';

  @override
  String get noUsersFoundYet => 'Ingen brukere funnet ennå.';

  @override
  String get notSetValue => 'Ikke angitt';

  @override
  String get notYetConfirmedTitle => 'Ikke bekreftet ennå';

  @override
  String get noteHint => 'Middag, taxi, billetter...';

  @override
  String get noteLabel => 'Merknad';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Merknaden må være på maksimalt $max tegn.';
  }

  @override
  String get notificationFallbackTitle => 'Varsel';

  @override
  String get notificationsTitle => 'Varsler';

  @override
  String get notificationFriendInviteTitle => 'Venneforespørsel';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name har sendt deg en venninvitasjon.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Du har mottatt en venninvitasjon.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Invitasjon godtatt';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name har akseptert venninvitasjonen din.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Invitasjonen din til vennen din ble akseptert.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Invitasjon avslått';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name har avvist vennskapsinvitasjonen din.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Invitasjonen din til vennen din ble avvist.';

  @override
  String get notificationTripAddedTitle => 'Lagt til i turen';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name har lagt deg til i turen «$trip».';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Du ble lagt til i turen «$trip».';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Du ble lagt til i en tur.';

  @override
  String get notificationExpenseAddedTitle => 'Ny utgift lagt til';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name har lagt til en utgift på $amount i «$trip».';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name har lagt til en utgift på $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'En ny utgift ble lagt til.';

  @override
  String get notificationTripFinishedTitle => 'Turen er avsluttet';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name har fullført «$trip». Oppgjørene er klare.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name har fullført «$trip». Turen er arkivert.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '«$trip» ble fullført.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Reisestatusen ble oppdatert.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Medlem merket som klar';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name er klar til å delta i «$trip».';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Et medlem er klar til å delta i «$trip».';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Et medlem er klar til å betale.';

  @override
  String get notificationTripReadyToSettleTitle => 'Alle medlemmer er klare';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Alle medlemmer er merket som klare i «$trip». Du kan starte oppgjørene.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Alle medlemmer er klare. Du kan starte oppgjørene.';

  @override
  String get notificationSettlementReminderTitle => 'Påminnelse om oppgjør';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor minnet $target om å merke $amount som sendt.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor minnet $target om å bekrefte mottak av $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Du har mottatt en påminnelse om oppgjør.';

  @override
  String get notificationPaymentReminderTitle => 'Betalingspåminnelse';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Påminnelse: Merk $amount som sendt til $target i «$trip».';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Påminnelse: Merk betalingen som sendt.';

  @override
  String get notificationConfirmationReminderTitle => 'Påminnelse om bekreftelse';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Påminnelse: Vennligst bekreft mottak av $amount fra $payer i «$trip».';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Påminnelse: Vennligst bekreft mottak av betalingen.';

  @override
  String get notificationSettlementSentTitle => 'Overføring merket som sendt';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name har merket $amount som sendt til deg.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'En overføring ble merket som sendt.';

  @override
  String get notificationSettlementConfirmedTitle => 'Overføring bekreftet';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name har bekreftet mottak av $amount fra deg.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'En overføring ble bekreftet.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventende endringer',
      one: '$count ventende endring',
    );
    return 'Frakoblet kø: $_temp0';
  }

  @override
  String get syncAllSynced => 'Alt synkronisert';

  @override
  String syncChangesWaiting(Object count) {
    return '$count venter på synkronisering';
  }

  @override
  String get syncFailedTapToRetry => 'Synkroniseringen mislyktes, trykk for å prøve på nytt';

  @override
  String get offlineQueueStatus => 'Offline kø';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Kun turarrangøren kan avslutte turen.';

  @override
  String get openLabel => 'Åpne';

  @override
  String get openReceiptAction => 'Åpne kvittering';

  @override
  String get openSettlements => 'Åpne oppgjør';

  @override
  String get overviewTitle => 'Oversikt';

  @override
  String get owesLabel => 'Skylder';

  @override
  String get paidByLabel => 'Betalt av';

  @override
  String get paidLabel => 'Betalt';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Betalt $paid  -  Skylder $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Deltakere (tomt felt = alle medlemmer)';

  @override
  String get participantsTitle => 'Deltakere';

  @override
  String get passwordLabel => 'Passord';

  @override
  String get passwordComplexityHelper => 'Bruk minst 1 stor bokstav, 1 tall og 1 symbol.';

  @override
  String get passwordComplexityValidation => 'Passordet må inneholde 1 stor bokstav, 1 tall og 1 symbol.';

  @override
  String get passwordMinLength => 'Passordet må bestå av minst 8 tegn.';

  @override
  String get passwordMinLengthShort => 'Passordet må bestå av minst 6 tegn.';

  @override
  String get passwordResetComingSoon => 'Tilbakestilling av passord kommer snart.';

  @override
  String get passwordsDoNotMatch => 'Passordene stemmer ikke overens.';

  @override
  String payerName(Object name) {
    return '$name (betaler)';
  }

  @override
  String get pendingLabel => 'Venter';

  @override
  String get pendingPaymentsSubtitle => 'Betalinger som fortsatt venter på full bekreftelse.';

  @override
  String get percentLabel => 'Prosent';

  @override
  String get percentSplitMustBe100 => 'Prosentfordelingen må til sammen utgjøre nøyaktig 100 %.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Prosentandeler';

  @override
  String get pickAtLeastOneParticipant => 'Velg minst én deltaker.';

  @override
  String get pickMembersGenerateTurn => 'Velg deltakere og trekk neste person.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name valgt. Syklus fullført.';
  }

  @override
  String pickedUser(Object name) {
    return '$name valgt.';
  }

  @override
  String get profileRefreshCachedData => 'Kunne ikke oppdatere profilen. Viser data fra hurtigbufferen.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpdated => 'Profilen er oppdatert.';

  @override
  String get uploadAvatarAction => 'Last opp avatar';

  @override
  String get takePhotoAction => 'Ta et bilde';

  @override
  String get chooseFromLibraryAction => 'Velg fra biblioteket';

  @override
  String get removeAvatarAction => 'Fjern avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar oppdatert.';

  @override
  String get avatarRemovedMessage => 'Avatar fjernet.';

  @override
  String get avatarFileTooLarge => 'Avatarfilen er for stor (maks. 5 MB).';

  @override
  String get avatarPickFailed => 'Kunne ikke laste inn avatarbildet.';

  @override
  String get queueAddExpense => 'Legg til utgift';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'I kø: legg til utgift $amount';
  }

  @override
  String get queueDeleteExpense => 'Slett utgift';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'I kø: slett utgift nr. $id';
  }

  @override
  String get queuePendingStatus => 'Kø med ventende oppgaver';

  @override
  String get queueUpdateExpense => 'Oppdater utgifter';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'I kø: oppdater utgift nr. $id';
  }

  @override
  String get queuedChange => 'Endring i kø';

  @override
  String queuedChangesTitle(Object count) {
    return 'Endringer i køen ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'I kø ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Syklus $cycleNo, trekk $drawNo – $remaining igjen';
  }

  @override
  String get receiptFallbackName => 'kvittering';

  @override
  String get receiptLinkInvalid => 'Kvitteringslenken er ugyldig.';

  @override
  String get receiptOptionalLabel => 'Kvittering (valgfritt)';

  @override
  String get recentPicksTitle => 'Siste trekninger';

  @override
  String get reloadProfile => 'Oppdater profil';

  @override
  String get rememberMe => 'Husk meg';

  @override
  String get removeCurrentReceipt => 'Fjern gjeldende kvittering';

  @override
  String get repeatNewPasswordLabel => 'Gjenta nytt passord';

  @override
  String get repeatPasswordLabel => 'Gjenta passord';

  @override
  String get requestFailedTryAgain => 'Forespørselen mislyktes. Prøv på nytt.';

  @override
  String get retryAction => 'Prøv på nytt';

  @override
  String get rowsLabel => 'Rader';

  @override
  String get backToLoginAction => 'Tilbake til pålogging';

  @override
  String get saveAction => 'Lagre';

  @override
  String get saveCredentialsButton => 'Lagre påloggingsopplysninger';

  @override
  String get saveProfileButton => 'Lagre profil';

  @override
  String get sendResetLinkButton => 'Send tilbakestillingslenke';

  @override
  String get searchUsersHint => 'Søk etter personer etter navn eller e-postadresse';

  @override
  String get selectedPeopleLabel => 'Utvalgte personer';

  @override
  String get noSearchMatches => 'Ingen matchende brukere funnet.';

  @override
  String get savingButton => 'Lagrer...';

  @override
  String get selectAtLeastTwoMembers => 'Velg minst to medlemmer.';

  @override
  String get selectMembersHint => 'Velg medlemmer';

  @override
  String selectedFileLabel(Object name) {
    return 'Valgt: $name';
  }

  @override
  String get selectedLabel => 'Valgt';

  @override
  String get selectedUserFallback => 'Valgt bruker';

  @override
  String get settings => 'Innstillinger';

  @override
  String get settleUpAction => 'Gjør opp';

  @override
  String get settledLabel => 'Gjort opp';

  @override
  String get settledStatus => 'Gjort opp';

  @override
  String get settlementActivitySubtitle => 'Overføringer knyttet til dette medlemmet.';

  @override
  String get settlementActivityTitle => 'Oppgjørsaktivitet';

  @override
  String get settlementCompletedTitle => 'Oppgjøret er fullført';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total bekreftet';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Oppgjør: $count';
  }

  @override
  String get settlementImpactTitle => 'Konsekvenser for oppgjør';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Konsekvenser for avregning: $name';
  }

  @override
  String get settlementInProgress => 'Oppgjør pågår';

  @override
  String get settlementInProgressTitle => 'Oppgjør pågår';

  @override
  String get settlementLabel => 'Oppgjør';

  @override
  String get settlementOverviewArchivedSubtitle => 'Turen er arkivert. Alle oppgjør er fullført.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Spor bekreftelser på oppgjør.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Forhåndsvisning av overføringer når turen er ferdig.';

  @override
  String get settlementPreview => 'Forhåndsvisning av oppgjør';

  @override
  String get settlementPreviewTitle => 'Forhåndsvisning av oppgjør';

  @override
  String get settlementProgressTripArchived => 'Turen er arkivert';

  @override
  String settlementWithId(Object id) {
    return 'Oppgjør nr. $id';
  }

  @override
  String get settlements => 'Oppgjør';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Oppgjørene er allerede fullført.';

  @override
  String get settlementsDone => 'Oppgjør utført';

  @override
  String get settlingStatus => 'Oppgjør';

  @override
  String get shareUnit => 'andel';

  @override
  String get sharesLabel => 'Andeler';

  @override
  String get sharesMustBePositiveIntegers => 'Antall andeler må være et positivt heltall.';

  @override
  String sharesWithValue(Object value) {
    return 'Andeler: $value';
  }

  @override
  String get showActiveTrips => 'Vis aktive turer';

  @override
  String get signUpButton => 'Registrer deg';

  @override
  String get splitBreakdownSubtitle => 'Hvordan utgiften fordeles';

  @override
  String get splitBreakdownTitle => 'Fordeling av kostnader';

  @override
  String get splitHintEqual => 'Del likt mellom de valgte deltakerne.';

  @override
  String get splitHintExact => 'Angi nøyaktig beløp for hver deltaker. Summen må stemme overens med totalbeløpet.';

  @override
  String get splitHintPercent => 'Angi prosentandel for hver deltaker. Summen må være 100 %.';

  @override
  String get splitHintShares => 'Angi delingsenheter (1, 2, 3...). Kostnaden deles proporsjonalt.';

  @override
  String get splitLabel => 'Split';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Lik fordeling ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Eksakte beløp ($target)';
  }

  @override
  String get splitModeLabel => 'Delt modus';

  @override
  String splitModePercent(Object target) {
    return 'Prosentandeler ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Andeler ($target)';
  }

  @override
  String get statusConfirmed => 'Bekreftet';

  @override
  String get statusPending => 'Venter';

  @override
  String get statusSent => 'Sendt';

  @override
  String get statusSuggested => 'Foreslått';

  @override
  String statusWithValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get suggestedTransferDirections => 'Foreslåtte betalingsretninger';

  @override
  String get suggestedTransferFromExpense => 'Foreslått overføring fra utgifter';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foreslåtte overføringer',
      one: '$count foreslått overføring',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Forventede rader for betaler -> mottaker.';

  @override
  String get suggestedTransfersTitle => 'Foreslåtte overføringer';

  @override
  String get summarySettledUp => 'Gjort opp';

  @override
  String get summaryYouAreOwed => 'Andre skylder deg';

  @override
  String get summaryYouOwe => 'Du skylder';

  @override
  String get syncAction => 'Synkronisering';

  @override
  String get syncNowAction => 'Synkroniser nå';

  @override
  String get syncingStatus => 'Synkronisering';

  @override
  String get tapToViewDetails => 'Trykk for å se detaljer';

  @override
  String get themeModeDark => 'Mørk';

  @override
  String get themeModeDarkSubtitle => 'Myk mørk farge (ikke ren svart)';

  @override
  String get themeModeLight => 'Lys';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeSystemSubtitle => 'Bruk utseendet på enheten';

  @override
  String toDirection(Object name) {
    return 'Til $name';
  }

  @override
  String get totalLabel => 'Totalt';

  @override
  String get travelerFallbackName => 'Reisende';

  @override
  String get tripAlreadyClosed => 'Turen er allerede avsluttet.';

  @override
  String get tripArchivedReadOnly => 'Turen er arkivert. Skrivebeskyttet modus.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Turen er avsluttet. Redigering av utgifter er deaktivert.';

  @override
  String get tripClosedExpensesReadOnly => 'Turen er avsluttet. Utgiftene er skrivebeskyttet.';

  @override
  String get tripClosedRandomDisabled => 'Turen er avsluttet. Tilfeldig trekning er deaktivert.';

  @override
  String tripCreated(Object name) {
    return 'Turen «$name» er opprettet.';
  }

  @override
  String get tripFinished => 'Turen er avsluttet.';

  @override
  String get tripFinishedCompleteSettlements => 'Turen er avsluttet. Fullfør oppgjørene.';

  @override
  String get tripFinishedSettlementStarted => 'Turen er avsluttet. Oppgjøret er startet.';

  @override
  String get tripFullySettledArchived => 'Turen er fullstendig avregnet og arkivert.';

  @override
  String get tripNameHint => 'Skitur til Østerrike';

  @override
  String get tripNameLabel => 'Turenavn';

  @override
  String get tripNameLengthValidation => 'Turenavnet må bestå av minst 2 tegn.';

  @override
  String get tripSnapshotTitle => 'Reiseoversikt';

  @override
  String get tripTitleShort => 'Reise';

  @override
  String tripStatusWithValue(Object status) {
    return 'Reisestatus: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Tur nr. $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Uventet feil ved innlasting av profil';

  @override
  String get unexpectedErrorLoadingTripData => 'Uventet feil ved innlasting av reisedata';

  @override
  String get unexpectedErrorLoadingTrips => 'Uventet feil ved innlasting av turer';

  @override
  String get unexpectedErrorSavingChanges => 'Uventet feil ved lagring av endringer';

  @override
  String get unexpectedErrorSavingCredentials => 'Uventet feil ved lagring av påloggingsopplysninger';

  @override
  String get unexpectedErrorUpdatingProfile => 'Uventet feil ved oppdatering av profil';

  @override
  String get unknownError => 'Ukjent feil';

  @override
  String get unknownLabel => 'Ukjent';

  @override
  String get unreadLabel => 'Ulest';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uleste oppdateringer',
      one: '$count ulest oppdatering',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Manglende argument for reiserute.';

  @override
  String userIdLabel(Object id) {
    return 'Bruker-ID: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Betalt $paid  -  Skylder $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Bruker $id';
  }

  @override
  String get valueLabel => 'Verdi';

  @override
  String get viewAllTrips => 'Vis alle turer';

  @override
  String get viewByPersonTitle => 'Visning per person';

  @override
  String get whoOwesWhatSubtitle => 'Hvem har betalt, og hvem skylder penger.';

  @override
  String get whoOwesWhatTitle => 'Hvem skylder hva';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Hvem skylder hva: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Utgiftslinjer som inngår i denne overføringen.';

  @override
  String get whyPaymentExistsTitle => 'Hvorfor denne betalingen finnes';

  @override
  String get youLabel => 'Du';

  @override
  String get youSettledForExpense => 'Du har gjort opp din del av denne utgiften.';

  @override
  String youShouldPay(Object amount) {
    return 'Du bør betale $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Du bør motta $amount';
  }

  @override
  String get yourShare => 'Din andel';

  @override
  String get yourTrips => 'Turene dine';

  @override
  String get authIntroSplitSmarter => 'Del smartere.';

  @override
  String get authIntroTravelFree => 'Reis fritt.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Spor delte kostnader på tvers av valutaer og gjør opp regningen umiddelbart – uten pinlige gjeldsbrev.';

  @override
  String get authIntroPlanTogether => 'Planlegg sammen.';

  @override
  String get authIntroPayClearly => 'Betal tydelig.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Opprett turer på få sekunder, legg til venner og sørg for at alle utgifter er gjennomsiktige for alle.';

  @override
  String get authIntroSettleFast => 'Avslutt raskt.';

  @override
  String get authIntroStayFriends => 'La oss forbli venner.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Fra felles middager til hele turer sørger Splyto for at regnskapet blir rettferdig og stressfritt.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Apple-pålogging mislyktes. Prøv på nytt.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Google-pålogging mislyktes. Prøv på nytt.';

  @override
  String get authIntroCreateAccount => 'Opprett din konto.';

  @override
  String get authIntroChooseSign => 'Velg hvordan du ønsker å registrere deg.';

  @override
  String get authIntroContinueGoogle => 'Fortsett med Google';

  @override
  String get authIntroContinueApple => 'Fortsett med Apple';

  @override
  String get authIntroBack => 'Tilbake';

  @override
  String get authIntroSplitSettled => 'Deling avregnet';

  @override
  String get authIntroParis3Friends => 'Paris · 3 venner';

  @override
  String get authIntroGetStarted => 'Kom i gang';

  @override
  String get authIntroAlreadyHaveAccount => 'Har du allerede en konto? ';

  @override
  String get authIntroSignIn => 'Logg inn';

  @override
  String get authIntroSignUpWithEmail => 'Registrer deg med e-post';

  @override
  String get authIntroOr => 'ELLER';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Google-påloggingen returnerte ikke et ID-token.';

  @override
  String get authAppleSignAvailableIosDevices => 'Apple-pålogging er tilgjengelig på iOS-enheter.';

  @override
  String get authAppleSignNotAvailableDevice => 'Apple-pålogging er ikke tilgjengelig på denne enheten.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Apple-påloggingen returnerte ikke et identitetstoken.';

  @override
  String get authCancel => 'Avbryt';

  @override
  String get authSendLink => 'Send lenke';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'E-postadressen er ikke bekreftet. Skriv inn e-postadressen din for å be om en bekreftelseslenke.';

  @override
  String get authEmailNotVerified => 'E-postadresse ikke bekreftet';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Sende bekreftelseslenke til $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Bekreftelseskobling sendt. Sjekk e-posten din.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Det var ikke mulig å sende bekreftelseslenken. Prøv på nytt.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Bekreftelses-e-post sendt. Vennligst bekreft e-postadressen din før du logger inn.';

  @override
  String get authVerifyEmail => 'Bekreft e-postadressen din';

  @override
  String get authEmailLabel => 'E-post:';

  @override
  String get authClose => 'Lukk';

  @override
  String get authResendLink => 'Send lenken på nytt';

  @override
  String get profileAppSettingsSectionTitle => 'APP-INNSTILLINGER';

  @override
  String get profileAccountSettings => 'Kontoinnstillinger';

  @override
  String get profileChangePhoto => 'Endre profilbilde';

  @override
  String get profileAppearance => 'Utseende';

  @override
  String get profileThemeDisplayMode => 'Tema og visningsmodus';

  @override
  String get profileLanguage => 'Språk';

  @override
  String get profileDisplayLanguage => 'Visningsspråk';

  @override
  String get profileNotificationsSectionHeading => 'VARSELER';

  @override
  String get profileAppBanners => 'Bannere i appen';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Vis nye varselbannere inne i appen';

  @override
  String get profilePushNotificationsTitle => 'Push-varsler';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Telefonvarsler for utgifter, venner, turer og oppgjør';

  @override
  String get profileSupportSectionHeading => 'STØTTE';

  @override
  String get profileContactUs => 'Kontakt oss';

  @override
  String get profileReportBugSuggestion => 'Rapporter feil / Forslag';

  @override
  String get profileRateSplyto => 'Vurder Splyto';

  @override
  String get profileLeaveStoreRating => 'Gi en vurdering av butikken';

  @override
  String get profileSecuritySectionHeading => 'SIKKERHET';

  @override
  String get profileChangePassword => 'Endre passord';

  @override
  String get profileUpdateAccountPassword => 'Oppdater kontopassordet';

  @override
  String get profileDangerZoneSectionHeading => 'FAREZONE';

  @override
  String get profileManageAccountAccess => 'Administrer tilgang til kontoen';

  @override
  String get profileMadeWithLabel => 'Laget med';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Handlingen «Lagre vurdering» vil bli koblet til i neste trinn.';

  @override
  String get profileFailedSaveNotificationSettings => 'Det gikk ikke an å lagre varslingsinnstillingene.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH-VARSELER';

  @override
  String get profileInAppBannersSectionTitle => 'BANNERE I APPEN';

  @override
  String get profileInAppTripMemberAddedTitle => 'Medlem lagt til i turen';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatisk påminnelse om oppgjør';

  @override
  String get profileExpenseUpdates => 'Oppdateringer av utgifter';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Bannere for lagt til utgifter inne i appen';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Varsler om lagt til utgifter på telefonen';

  @override
  String get profileFriendInvites => 'Venn inviterer';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Bannere for venneforespørsler og svar inne i appen';

  @override
  String get profileFriendRequestResponseNotifications => 'Varsler om venneforespørsler og svar';

  @override
  String get profileTripUpdates => 'Reiseoppdateringer';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Bannere for turens livssyklus og medlemsstatus inne i appen';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Reisens livssyklus og endringer i medlemsstatus';

  @override
  String get profileSettlementUpdates => 'Oppdateringer om oppgjør';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Merkede bannere for «sendt» og «bekreftet betaling» inne i appen';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Merkede sendte og bekreftede betalingsoppdateringer';

  @override
  String get profileScreenshotSizeMust8Mb => 'Skjermbildet må være på maksimalt 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Send tilbakemelding';

  @override
  String get profileFeedbackTypeLabel => 'Type';

  @override
  String get profileFeedbackTypeBug => 'Feil';

  @override
  String get profileFeedbackTypeSuggestion => 'Forslag';

  @override
  String get profileDescribeIssueSuggestion => 'Beskriv problem eller forslag';

  @override
  String get profilePickingImage => 'Henter bilde...';

  @override
  String get profileAttachScreenshot => 'Legg ved skjermbilde';

  @override
  String get profileChangeScreenshot => 'Endre skjermbilde';

  @override
  String get profileRemoveImage => 'Fjern bilde';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Tips: legg ved skjermbilde for raskere feilsøking';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Legg til detaljer eller legg ved skjermbilde før du sender';

  @override
  String get profileSendAction => 'Send';

  @override
  String get profileThanksFeedbackSent => 'Takk! Tilbakemelding sendt';

  @override
  String get profileFailedSendFeedback => 'Kunne ikke sende tilbakemelding';

  @override
  String get profileCouldNotOpenWebsite => 'Kunne ikke åpne nettstedet.';

  @override
  String get profileOpenWebsiteQuestion => 'Åpne nettstedet?';

  @override
  String get profileOpenPortfolioAction => 'Åpne portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Dette bildeformatet støttes ikke på denne enheten. Velg JPG eller PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'En gyldig e-postadresse for kontoen er nødvendig for å endre passordet ditt. Kontakt kundestøtte hvis e-postadressen din mangler eller er feil.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Slettingslenke sendt til e-postadressen din.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Det var ikke mulig å sende slettingslenken. Prøv på nytt.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Skriv inn gjeldende passord for å endre e-postadresse.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Bekreftelsen ble sendt til den nye e-postadressen. Sikkerhetsmeldingen ble sendt til din nåværende e-postadresse.';

  @override
  String get profileEditOverviewCurrency => 'Oversikt over valuta';

  @override
  String get profileEditPaymentMethod => 'Betalingsmåte';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Bankoverføring, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Skriv inn passordet ditt (valgfritt for Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Send slettingslenke til e-post';

  @override
  String get profileEditBackProfile => 'Tilbake til profilen';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Angi en gyldig e-postadresse i profilen før du endrer passord.';

  @override
  String get profileEditPasswordUpdated => 'Passord oppdatert.';

  @override
  String get profileEditFailedUpdatePassword => 'Det gikk ikke an å oppdatere passordet.';

  @override
  String profileEditEmail(Object email) {
    return 'Konto: $email';
  }

  @override
  String get profileEditPrimary => 'Primær';

  @override
  String get profileEditSearchCurrency => 'Søk etter valuta';

  @override
  String get profileEditNoCurrenciesFound => 'Ingen valutaer funnet';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Oversiktsbeløpene konverteres til denne valutaen.';

  @override
  String get profileEditPaymentInfoUpdated => 'Betalingsinformasjon oppdatert.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Kunne ikke lagre betalingsinformasjon. Prøv på nytt.';

  @override
  String get profileEditCurrentPassword => 'Gjeldende passord';

  @override
  String get profileEditBankTransferIbanSwift => 'Bankoverføring (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me-lenke';

  @override
  String get profileEditChoosePaymentMethod => 'Velg betalingsmåte';

  @override
  String get profileEditTapChange => 'Trykk for å endre';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'For overføringer i Storbritannia må sorteringskoden være på 6 siffer og kontonummeret på 8 siffer.';

  @override
  String get profileEditPaymentInfo => 'Betalingsinformasjon';

  @override
  String get profileEditSaveDetails => 'Lagre opplysninger';

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
  String get profileEdit8Digits => '8 siffer';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'For innenlandske overføringer i Storbritannia bruker du sort code + kontonummer.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Eksempel: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 eller 11 tegn';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Navnet på kontoinnehaveren hentes fra det fulle navnet i profilen.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username eller brukernavn';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Storbritannia';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Juster avatar';

  @override
  String get imageCropperAdjustTripImage => 'Juster reisebilde';

  @override
  String get copyAction => 'Kopier';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Britisk pund';

  @override
  String get currencyNameChf => 'Sveitsisk franc';

  @override
  String get currencyNameNok => 'Norske kroner';

  @override
  String get currencyNameSek => 'Svensk krone';

  @override
  String get currencyNameDkk => 'Dansk krone';

  @override
  String get currencyNamePln => 'Polsk zloty';

  @override
  String get currencyNameCzk => 'Tsjekkisk koruna';

  @override
  String get currencyNameHuf => 'Ungarsk forint';

  @override
  String get currencyNameRon => 'Rumensk leu';

  @override
  String get currencyNameBgn => 'Bulgarsk lev';

  @override
  String get currencyNameIsk => 'Islandsk krone';

  @override
  String get currencyNameAll => 'Albansk lek';

  @override
  String get currencyNameBam => 'Bosnia-Hercegovina Mark';

  @override
  String get currencyNameByn => 'Hviterussisk rubel';

  @override
  String get currencyNameMdl => 'Moldovsk leu';

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
  String get currencyNameCad => 'Kanadisk dollar';

  @override
  String get currencyNameAud => 'Australske dollar';

  @override
  String get expenseCategoryFood => 'Mat';

  @override
  String get expenseCategoryGroceries => 'Dagligvarer';

  @override
  String get expenseCategoryFuel => 'Drivstoff';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryAccommodation => 'Overnatting';

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
  String get expenseCategoryOther => 'Annet';

  @override
  String get shellTripAlreadyInListOpened => 'Turen er allerede på listen din. Vi har åpnet den for deg.';

  @override
  String get shellJoinedTripFromInviteLink => 'Deltatt i turen via invitasjonslenken.';

  @override
  String get shellFailedToOpenInviteLink => 'Det lyktes ikke å åpne invitasjonslenken.';

  @override
  String get shellFailedToOpenFriendLink => 'Det lyktes ikke å åpne vennelinken.';

  @override
  String get shellTripInviteTitle => 'Reiseinvitasjon';

  @override
  String get shellNoAction => 'Nei';

  @override
  String get shellYesAction => 'Ja';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Kun turarrangøren kan slette denne turen.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Bare aktive turer kan slettes.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Slette «$tripLabel»? Dette er kun tillatt før utgifter legges til.';
  }

  @override
  String get shellTripDeleted => 'Turen er slettet.';

  @override
  String get shellFailedToDeleteTrip => 'Det lyktes ikke å slette turen.';

  @override
  String get shellFailedToLoadNotifications => 'Kunne ikke laste inn varsler.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Ny varsling: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Kunne ikke oppdatere varslinger.';

  @override
  String get shellMarkAllAsReadAction => 'Merk alt som lest';

  @override
  String get shellNewSection => 'Ny';

  @override
  String get shellEarlierSection => 'Tidligere';

  @override
  String get shellShowMoreEarlierAction => 'Vis flere tidligere';

  @override
  String get shellLoadingMore => 'Laster inn mer...';

  @override
  String get shellLoadMoreNotificationsAction => 'Last inn flere varsler';

  @override
  String get shellTripNoLongerAvailable => 'Denne turen er ikke lenger tilgjengelig.';

  @override
  String get shellFailedToOpenTrip => 'Kunne ikke åpne turen.';

  @override
  String get shellYesterday => 'I går';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Du er allerede medlem av «$tripName». Vil du åpne denne turen nå?\n\nInvitert av: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Vil du bli med på turen «$tripName»?\n\nInvitert av: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Valgt bilde: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Turbilde er allerede angitt.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Turen er opprettet, men bildeopplastingen mislyktes.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Turen er opprettet, men bildeopplastingen mislyktes: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Bli med på turen via invitasjon';

  @override
  String get tripsTotalTrips => 'Totalt antall turer';

  @override
  String get tripsTotalSpent => 'Totalt brukt';

  @override
  String get tripsMixedCurrencies => 'Blandede valutaer';

  @override
  String get tripsShowActive => 'Vis aktiv';

  @override
  String get tripsSeeAll => 'Se alt';

  @override
  String get tripsGridView => 'Rutenettvisning';

  @override
  String get tripsListView => 'Listevisning';

  @override
  String get tripsAddNewTrip => 'Legg til ny tur';

  @override
  String get tripsLoadMore => 'Last inn mer';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Slette «$arg1»? Dette er kun tillatt før utgifter legges til.';
  }

  @override
  String get tripsTripDates => 'Reisedatoer';

  @override
  String get tripsFrom => 'Fra';

  @override
  String get tripsSelectDate => 'Velg dato';

  @override
  String get tripsTo => 'Til';

  @override
  String get tripsMainCurrency => 'Hovedvaluta';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Vennligst velg reiseperiode (start- og sluttdato).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Reisens sluttdato må være på eller etter startdatoen.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Formatet for reiseperioden er ugyldig. Vennligst velg datoer på nytt.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Du er allerede medlem av denne turen.';

  @override
  String get tripsJoinedTripSuccessfully => 'Du har blitt med på turen.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Det lyktes ikke å bli med på turen fra invitasjonen.';

  @override
  String get tripsJoinTrip => 'Bli med på turen';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Lim inn invitasjonslenken eller invitasjonstokenet.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Skriv inn en gyldig invitasjonslenke eller et gyldig token.';

  @override
  String get tripsClipboardIsEmpty => 'Utklippstavlen er tom.';

  @override
  String get tripsPaste => 'Lim inn';

  @override
  String get tripsJoin => 'Bli med';

  @override
  String get workspaceTripMembers => 'Reisedeltakere';

  @override
  String get workspaceFailedToLoadFriends => 'Kunne ikke laste inn venner.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Det lyktes ikke å generere invitasjonslenken.';

  @override
  String get workspaceInviteLink => 'Invitasjonslenke';

  @override
  String get workspaceGeneratingInviteLink => 'Genererer invitasjonslenke...';

  @override
  String get workspaceInviteLinkUnavailable => 'Invitasjonslenken er ikke tilgjengelig.';

  @override
  String get workspaceCopyInviteLink => 'Kopier invitasjonslenke';

  @override
  String get workspaceInviteLinkCopied => 'Invitasjonslenken er kopiert.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Utløper: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Ingen venner tilgjengelig. Legg til venner først.';

  @override
  String get workspaceSettle => 'Avregning';

  @override
  String get workspaceOwesToTheGroup => 'Skylder gruppen';

  @override
  String get workspaceGetsBackFromGroup => 'Skal få penger tilbake fra gruppen';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Viser de 4 øverste etter saldoforskjell.';

  @override
  String get workspaceOpenFlow => 'Detaljer';

  @override
  String get workspaceFriend => 'Venn';

  @override
  String get workspaceSettlementTransfer => 'Overføring av oppgjør';

  @override
  String get workspaceCompleted => 'Fullført';

  @override
  String get workspaceWaitingForConfirmation => 'Venter på bekreftelse';

  @override
  String get workspaceWaitingForPayment => 'Venter på betaling';

  @override
  String get workspaceActionNeeded => 'Tiltak som må iverksettes';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Betalinger som skal merkes som sendt: $arg1; bekreftes som mottatt: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Klar til å gjøre opp';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Alle medlemmer er klare. Du kan starte oppgjørene.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Venter på at alle skal merke seg som klare.';

  @override
  String get workspaceIMReady => 'Jeg er klar';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Bekreft at du har lagt til alle utgiftene dine.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => '«Fullfør»-knappen blir tilgjengelig når alle har merket seg som klare.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Skal få penger tilbake fra gruppen';

  @override
  String get workspaceSettledWithTheGroup => 'Avtalt med gruppen';

  @override
  String get workspaceTotalPaid => 'Totalt betalt';

  @override
  String get workspaceTotalOwes => 'Totalt skyldig';

  @override
  String get workspaceTransactionHistory => 'Transaksjonshistorikk';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Ingen transaksjoner ennå for dette medlemmet.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Oppgjør: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Alle medlemmer må merke seg som klare før avregningene starter.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Du har merket deg selv som klar til å betale.';

  @override
  String get workspaceReadyToSettleMarkRemoved => '«Klar til oppgjør»-merket er fjernet.';

  @override
  String get workspaceReminderSent => 'Påminnelse sendt.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Invitasjonslenke eller legg til fra venner';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Bare turarrangøren kan redigere denne turen.';

  @override
  String get workspaceTripUpdated => 'Turen er oppdatert.';

  @override
  String get workspaceFailedToUpdateTrip => 'Kunne ikke oppdatere turen.';

  @override
  String get workspaceNoMembersSelectedYet => 'Ingen medlemmer er valgt ennå.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Ingen internettilgang. Utgiften lagres uten bilde av kvitteringen.';

  @override
  String get workspaceRandomPicker => 'Tilfeldig valg';

  @override
  String get workspaceCurrency => 'Valuta';

  @override
  String get workspaceCategory => 'Kategori';

  @override
  String get workspaceCustomCategory => 'Egendefinert kategori';

  @override
  String get workspaceCategoryName => 'Kategorinavn';

  @override
  String get workspaceApartmentRentParkingEtc => 'Leie av leilighet, parkering osv.';

  @override
  String get workspaceEnterACustomCategory => 'Angi en egendefinert kategori.';

  @override
  String get workspacePickAnExpenseCategory => 'Velg en utgiftskategori.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Kategorien må bestå av minst 2 tegn.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Kategorien må være på opptil 64 tegn.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Prosentfordelingen må til sammen utgjøre 100 %.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Antall andeler må være større enn 0 for hver deltaker.';

  @override
  String get workspaceTotalAmount => 'Totalt beløp';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Totalkostnad';

  @override
  String workspaceStarted(Object arg1) {
    return 'Startet $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Avsluttet $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Arkivert tur';

  @override
  String get workspaceActiveTrip => 'Aktiv tur';

  @override
  String get workspaceMemberProfile => 'Medlemsprofil';

  @override
  String get workspaceTripOwner => 'Tureier';

  @override
  String get workspaceMember => 'Medlem';

  @override
  String get workspaceReadyForSettlement => 'Klar for oppgjør';

  @override
  String get workspaceNotReadyForSettlement => 'Ikke klar for oppgjør';

  @override
  String get workspaceBankDetails => 'Bankopplysninger';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN og utbetalingsopplysninger vil bli lagt til her i en kommende oppdatering.';

  @override
  String get workspacePaymentDetails => 'Betalingsopplysninger';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Dette medlemmet har ikke lagt til utbetalingsopplysninger ennå.';

  @override
  String get workspaceBankTransfer => 'Bankoverføring';

  @override
  String get workspaceHolder => 'Innehaver';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Kunne ikke åpne betalingslenken.';

  @override
  String get workspaceTripActivity => 'Tureaktivitet';

  @override
  String get workspacePaidExpenses => 'Betalte utgifter';

  @override
  String get workspacePaidTotal => 'Betalt totalbeløp';

  @override
  String get workspaceInvolvedIn => 'Involvert i';

  @override
  String get workspaceCurrentTrip => 'Gjeldende tur';

  @override
  String get workspaceCommonTrips => 'Felles reiser';

  @override
  String get workspaceLoadingCommonTrips => 'Laster felles reiser…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Ingen felles reiser funnet ennå.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Ikke alle felles reiser kunne lastes. Den aktuelle reisen vises.';

  @override
  String get workspaceMembers => 'medlemmer';

  @override
  String get workspaceExpense => 'Utgifter';

  @override
  String get workspacePaid => 'betalt';

  @override
  String get workspaceLoadingMoreExpenses => 'Laster inn flere utgifter...';

  @override
  String get workspaceScrollDownToLoadMore => 'Rull ned for å laste inn mer';

  @override
  String get workspaceTripFinished => 'Turen er avsluttet';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Oppgjør er aktivert for denne turen.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Fullfør turen for å starte oppgjørene.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 har merket overføringen som sendt.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Venter på at $arg1 skal merke som betalt.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 har bekreftet mottak av betalingen.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Venter på at $arg1 skal bekrefte.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Alle reiseoppgjør er fullstendig gjennomført.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Endelig status etter at alle overføringer er bekreftet.';

  @override
  String get workspaceSettlementFlow => 'Oppgjørsflyt';

  @override
  String get workspaceActions => 'Handlinger';

  @override
  String get workspaceQuickPay => 'Hurtigbetaling';

  @override
  String get workspacePayWithRevolut => 'Betal med Revolut';

  @override
  String get workspacePayWithPaypal => 'Betal med PayPal';

  @override
  String get workspacePayWithWise => 'Betal med Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Overføringen er bekreftet.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Venter på at det andre medlemmet skal fullføre neste trinn.';

  @override
  String get workspaceSendReminder => 'Send påminnelse';

  @override
  String get workspaceInProgress => 'Pågår';

  @override
  String get workspaceTimeUnknown => 'Tid ukjent';

  @override
  String get workspaceRemind => 'Påminnelse';

  @override
  String get workspaceYourPosition => 'Din posisjon';

  @override
  String get workspaceRecentActivity => 'Nylig aktivitet';

  @override
  String get workspaceNoRecentActivityYet => 'Ingen nylig aktivitet ennå.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Legg til minst ett medlem for å begynne å dele utgiftene.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Merk deg som klar til å gjøre opp etter at du har lagt til alle utgiftene dine.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Deltakere som ikke er klare ennå: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Alle medlemmene er klare. Du kan avslutte turen og starte oppgjøret.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Alle medlemmene er klare. Venter på at turarrangøren skal starte oppgjøret.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Oppgjør pågår: $arg1/$arg2 bekreftet.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Ingen ventende handlinger. Denne turen er avsluttet.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Ingen tiltak er nødvendig akkurat nå.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Du bør motta $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Du bør betale $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Du er for øyeblikket registrert på denne turen.';

  @override
  String get workspaceUnknownTime => 'Ukjent tidspunkt';

  @override
  String get workspaceJustNow => 'Akkurat nå';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'For $arg1 min siden';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'For $arg1 t siden';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'For $arg1 d siden';
  }

  @override
  String get friendsRemoveFriend => 'Fjern venn';

  @override
  String get friendsRemoveThisFriend => 'Fjerne denne vennen?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 vil bli fjernet fra vennelisten din. Du kan legge dem til igjen senere.';
  }

  @override
  String get friendsContinue => 'Fortsett';

  @override
  String get friendsFriendRemoved => 'Vennen er fjernet.';

  @override
  String get friendsCouldNotRemoveFriend => 'Kunne ikke fjerne venn.';

  @override
  String get friendsFriendProfile => 'Venneprofil';

  @override
  String get friendsMoreActions => 'Flere handlinger';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Denne vennen har ikke lagt til utbetalingsopplysninger ennå.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Kunne ikke laste felles reiser akkurat nå.';

  @override
  String get friendsFinished => 'Ferdig';

  @override
  String friendsTrip(Object arg1) {
    return 'Tur nr. $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Medlemmer: $arg1';
  }

  @override
  String get friendsNoDate => 'Ingen dato';

  @override
  String get friendsIncomingRequests => 'INNKOMMENDE FORESPØRSLER';

  @override
  String get friendsSentInvites => 'SENDTE INVITASJONER';

  @override
  String get friendsMyFriends => 'MINE VENNER';

  @override
  String get friendsRequests => 'Forespørsler';

  @override
  String get friendsIncoming => 'Innkommende';

  @override
  String get friendsIncomingRequestSubtitle => 'vil være venner';

  @override
  String get friendsOutgoingInviteSubtitle => 'Invitasjon sendt';

  @override
  String get friendsNoPendingActivity => 'Ingen venneforespørsler';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Invitasjon sendt til $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Ingen innkommende forespørsler';

  @override
  String get friendsDecline => 'Avslå';

  @override
  String get friendsAccept => 'Godta';

  @override
  String get friendsNoSentInvites => 'Ingen sendte invitasjoner';

  @override
  String get friendsNoFriendsYet => 'Ingen venner ennå';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Rull ned for å laste inn flere venner.';

  @override
  String get friendsUser => 'Bruker';

  @override
  String get friendsSearchUsers => 'Søk etter brukere';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Søk etter navn eller e-post og send invitasjon';

  @override
  String get friendsScanQr => 'Skann QR-koden';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Skann en annen bruker for å legge til en venn';

  @override
  String get friendsMyQr => 'Min QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Vis eller del QR-koden din';

  @override
  String get friendsScanFriendQrTitle => 'Skann vennens QR-kode';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Plasser vennens QR-kode inne i rammen';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Hold QR-koden innenfor rammen';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Vil du legge til $arg1 som venn?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 vil motta vennforespørselen din.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Godta ${arg1}s venneforespørsel?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Skann denne QR-koden eller del lenken for å legge meg til på Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Legg meg til på Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Splyto-vennelink';

  @override
  String get shareAction => 'Del';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'QR-koden er ikke en gyldig vennkode.';

  @override
  String get friendsYouCannotAddYourself => 'Du kan ikke legge til deg selv.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Denne brukeren er allerede på vennelisten din.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Invitasjonen til denne brukeren er allerede sendt.';

  @override
  String get friendsFriendRequestProcessed => 'Vennforespørsel behandlet.';

  @override
  String get friendsFailedToProcessFriendQr => 'Kunne ikke behandle vennens QR-kode.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Kunne ikke laste inn brukerprofilen din.';

  @override
  String get friendsMyProfile => 'Min profil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Uventet feil ved innlasting av venner.';

  @override
  String get friendsFriendAdded => 'Venn lagt til.';

  @override
  String get friendsRequestDeclined => 'Forespørsel avvist.';

  @override
  String get friendsFailedToUpdateRequest => 'Kunne ikke oppdatere forespørselen.';

  @override
  String get friendsCancelInvite => 'Avbryt invitasjon';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Avbryte invitasjonen til $arg1?';
  }

  @override
  String get friendsKeep => 'Behold';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Invitasjonen til $arg1 er kansellert.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Det lyktes ikke å avbryte invitasjonen.';

  @override
  String get analyticsOther => 'Annet';

  @override
  String get analyticsSelectATripForAnalytics => 'Velg en tur for analyse';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Medlemmer: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Daglige utgifter';

  @override
  String get analyticsMyDaily => 'Mine daglige utgifter';

  @override
  String get analyticsGroupDaily => 'Gruppens daglige utgifter';

  @override
  String get analyticsByMember => 'Per deltaker';

  @override
  String get analyticsShowLess => 'Vis mindre';

  @override
  String get analyticsByCategory => 'Etter kategori';

  @override
  String get analyticsQuickInsights => 'Raske innsikter';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Største utgift: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Største forbruker: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Gruppens beste dag: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Ingen datoer';

  @override
  String get friendsSearchFailedTryAgain => 'Søket mislyktes. Prøv på nytt.';

  @override
  String get friendsFailedToSendInvite => 'Det lyktes ikke å sende invitasjonen.';

  @override
  String get friendsAddFriend => 'Legg til venn';

  @override
  String get friendsSearchByNameOrEmail => 'Søk etter navn eller e-postadresse';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Skriv inn minst 2 tegn for å søke.';

  @override
  String get friendsNoUsersFound => 'Ingen brukere funnet';

  @override
  String get friendsInviteAction => 'Inviter';

  @override
  String get workspacePaidForGroup => 'Betalt for gruppen';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Betalt for gruppen • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Deling av utgifter';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Utgiftsdeling • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Innehaverens navn er kopiert.';

  @override
  String get paymentIbanCopied => 'IBAN kopiert.';

  @override
  String get paymentSwiftCopied => 'SWIFT kopiert.';

  @override
  String get paymentRevtagCopied => 'Revtag kopiert.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Kunne ikke kopiere til utklippstavlen.';

  @override
  String get paymentCopied => 'Kopiert.';

  @override
  String get paymentRequestAction => 'Be om betaling';

  @override
  String get paymentRecordAction => 'Registrer betaling';

  @override
  String get paymentRequestSheetTitle => 'Be om betaling';

  @override
  String get paymentRecordSheetTitle => 'Registrer betaling';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Be $arg1 om å betale et beløp de for øyeblikket skylder deg.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Bruk dette etter at du har betalt $arg1 utenfor Splyto. De vil bekrefte at de har mottatt beløpet.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Maksimum $arg1';
  }

  @override
  String get paymentNoteHint => 'Bankoverføring, Revolut, kontanter...';

  @override
  String get paymentAmountPositiveError => 'Beløpet må være større enn null.';

  @override
  String get paymentAmountTooHighError => 'Beløpet kan ikke være høyere enn den utestående saldoen.';

  @override
  String get paymentRequestCreated => 'Betalingsforespørsel sendt.';

  @override
  String get paymentRecordedWaiting => 'Betaling registrert. Venter på bekreftelse.';

  @override
  String get paymentConfirmTitle => 'Bekreft betaling';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Bekreft at du har mottatt $arg1 fra $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Betaling bekreftet.';

  @override
  String get paymentCancelRecordTitle => 'Avbryt betalingsregistrering';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Avbryte registreringen av betalingen din på $arg1 til $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Betalingsoppføring kansellert.';

  @override
  String get paymentNotReceivedTitle => 'Betaling ikke mottatt';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Merk $arg1-betalingen fra $arg2 som ikke mottatt?';
  }

  @override
  String get paymentMarkedNotReceived => 'Betaling merket som ikke mottatt.';

  @override
  String get paymentActivityTitle => 'Betalingsaktivitet';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Åpne betalingsforespørsler: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Betalinger som venter på bekreftelse: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Registrerte betalinger';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 har bedt om betaling fra $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 betalte $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Betaling forespurt';

  @override
  String get paymentAwaitingConfirmationStatus => 'Venter på bekreftelse';

  @override
  String get paymentReviewRequestAction => 'Gjennomgå forespørsel';

  @override
  String get paymentViewDetailsAction => 'Betalingsopplysninger';

  @override
  String get paymentMarkPaidAction => 'Jeg har betalt';

  @override
  String get paymentDeclineAction => 'Avslå';

  @override
  String get paymentRequestReviewTitle => 'Betalingsforespørsel';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 har bedt deg om $arg2. Betal utenfor Splyto, og merk deretter betalingen som betalt.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Merk forespørselen som betalt?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Bekreft først etter at du har betalt $arg1 til $arg2 utenfor Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Merkes som betalt. Venter på bekreftelse.';

  @override
  String get paymentRequestCancelTitle => 'Avbryte betalingsforespørsel?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Vil du avbryte din $arg1-forespørsel til $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Betalingsforespørsel avbrutt.';

  @override
  String get paymentRequestDeclineTitle => 'Avslå betalingsforespørsel?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Avslå betalingsforespørselen på $arg1 fra $arg2? Personen får et varsel.';
  }

  @override
  String get paymentRequestDeclined => 'Betalingsforespørsel avvist.';

  @override
  String get paymentPendingBeforeFinish => 'Avklar åpne betalingsforespørsler og ubekreftede betalinger før endelig oppgjør.';

  @override
  String get paymentFinishBlockedByPending => 'Fullføring låses opp etter at betalingsforespørsler og ubekreftede betalinger er løst.';

  @override
  String get notificationPaymentRequestedTitle => 'Betaling forespurt';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 har bedt deg om $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Du har mottatt en betalingsforespørsel.';

  @override
  String get notificationPaymentRequestSentTitle => 'Forespurt betaling sendt';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 har merket din $arg2-betalingsforespørsel som betalt.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Betalingsforespørselen din ble merket som betalt.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Betalingsforespørsel avbrutt';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 har kansellert betalingsforespørselen fra $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'En betalingsforespørsel ble kansellert.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Betalingsforespørsel avvist';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 har avvist din $arg2-betalingsforespørsel.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Betalingsforespørselen din ble avslått.';

  @override
  String get notificationPaymentSentTitle => 'Betaling merket som sendt';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 har merket $arg2 som betalt til deg.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'En betaling ble merket som sendt til deg.';

  @override
  String get notificationPaymentConfirmedTitle => 'Betaling bekreftet';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 har bekreftet mottak av $arg2 fra deg.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Betalingen din er bekreftet.';

  @override
  String get notificationPaymentCancelledTitle => 'Betaling kansellert';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 har kansellert betalingsmerket for $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'En betalingsmarkering ble kansellert.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Betaling ikke mottatt';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 har merket $arg2-betalingen som ikke mottatt.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'En betaling ble merket som ikke mottatt.';

  @override
  String get quickStartTitle => 'Hurtigstart';

  @override
  String get quickStartCreateTitle => 'Opprett en tur';

  @override
  String get quickStartCreateBody => 'Velg et navn og en valuta. Hold orden på dine egne utgifter, eller del kostnadene med en gruppe.';

  @override
  String get quickStartInviteTitle => 'Reis sammen eller alene';

  @override
  String get quickStartInviteBody => 'Inviter venner til å være med på turen din, eller start en personlig tur på egen hånd.';

  @override
  String get quickStartExpenseTitle => 'Legg til din første utgift';

  @override
  String get quickStartExpenseBody => 'Skriv inn beløpet, velg hvem som har betalt, og del kostnaden. Saldoene dine holdes oppdatert.';

  @override
  String get quickStartNext => 'Neste';

  @override
  String get quickStartBack => 'Tilbake';

  @override
  String get quickStartSkip => 'Hopp over';

  @override
  String get quickStartCreateAction => 'Opprett tur';

  @override
  String get quickStartClose => 'Lukk hurtigstart';

  @override
  String get quickStartSubtitle => 'Se hvordan turer og utgifter fungerer';

  @override
  String quickStartStep(int step, int total) {
    return 'Trinn $step av $total';
  }

  @override
  String get workspaceTripTotal => 'Totalsum for turen';

  @override
  String get workspacePersonalTotal => 'Totalt brukt';

  @override
  String get workspaceBalanceEven => 'Saldoen din er i balanse';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Du skylder $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Du får tilbake $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Medlemmer: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Søk etter utgifter';

  @override
  String get workspaceClearSearch => 'Tydelig søk';

  @override
  String get workspaceSearchLoadedHint => 'Søket omfatter registrerte utgifter. Legg til flere for å inkludere eldre utgifter.';

  @override
  String get workspaceNoExpenseMatches => 'Ingen samsvarende utgifter';

  @override
  String get workspaceNoExpenseMatchesBody => 'Prøv et nytt søk eller tøm søket for å se alle innlastede utgifter.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Legg til din første utgift for å begynne å spore utgiftene dine.';

  @override
  String get workspaceEmptyGroupExpenses => 'Legg til din første delte utgift for å se alles andel.';

  @override
  String get workspaceLoadMoreExpenses => 'Last inn flere utgifter';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Opprinnelig beløp: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Kommentarer: $count';
  }

  @override
  String get workspaceExpenseActions => 'Utgiftshandlinger';

  @override
  String get workspaceLoadErrorTitle => 'Kunne ikke laste inn denne turen';

  @override
  String get workspaceCachedWarning => 'Viser lagrede data. Disse kan være utdaterte.';

  @override
  String get workspaceActivityTab => 'Aktivitet';

  @override
  String get workspaceLoadingTrip => 'Laster inn tur';

  @override
  String get workspaceRefreshFailed => 'Oppdatering mislyktes';

  @override
  String get expenseDetailsTitle => 'Utgiftsdetaljer';

  @override
  String get expenseQuickCategories => 'Hurtigkategorier';

  @override
  String get expenseReceiptRead => 'Kvittering lest og skjema oppdatert.';

  @override
  String get expenseReceiptNoData => 'Kvittering vedlagt. Det er ikke angitt noe klart beløp, dato eller forhandler.';

  @override
  String get expenseReceiptScanFailed => 'Kvittering valgt. Automatisk avlesning mislyktes; sjekk feltene manuelt.';

  @override
  String get expenseReceiptOffline => 'Kvitteringen lastes opp når du lagrer. Automatisk avlesning krever en internettforbindelse.';

  @override
  String get expenseReadingReceipt => 'Leser kvitteringen…';

  @override
  String get expenseCommentsLoadFailed => 'Kunne ikke laste inn kommentarer. Prøv igjen.';

  @override
  String get expenseReplyAction => 'Svar';

  @override
  String get expenseReplyHint => 'Skriv et svar…';

  @override
  String expenseReplyTo(String name) {
    return 'Svar til $name';
  }

  @override
  String get balanceEmptyBody => 'Saldoer vises etter at utgifter er lagt til.';

  @override
  String get balanceAfterPayments => 'Saldoene inkluderer bekreftede betalinger.';

  @override
  String get balanceExpenseShare => 'Utgiftsdeling';

  @override
  String get balanceHistoryScope => 'Lagt inn utgifter og bekreftede betalinger. Denne listen inneholder kanskje ikke hele reisehistorikken.';

  @override
  String balancePaymentTo(String name) {
    return 'Betaling til $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Betaling fra $name';
  }

  @override
  String get settlementEmptyActive => 'Merk alle som klare før du starter sluttoppgjøret.';

  @override
  String get settlementEmptyClosed => 'Det er ingen overføringer oppført for denne turen.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count av $total overføringer bekreftet';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count av $total medlemmer er klare';
  }

  @override
  String get settlementMemberReady => 'Klar';

  @override
  String get settlementMemberNotReady => 'Ikke klar';

  @override
  String get settlementSuggested => 'Foreslått overføring';

  @override
  String get activityLoadFailed => 'Kunne ikke oppdatere aktiviteten. Eventuelle synlige oppføringer kan være utdaterte.';

  @override
  String get activityMember => 'Reisedeltaker';

  @override
  String get friendsEmptyBody => 'Finn en venn ved navn eller e-post, eller bruk en QR-kode.';

  @override
  String get friendsDeclineAction => 'Avslå';

  @override
  String get friendsLoading => 'Laster inn venner';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Delte turer: $count';
  }

  @override
  String get memberActivityScope => 'Basert på registrerte utgifter; dette dekker kanskje ikke hele turen.';

  @override
  String get sharedTripsLoadedLimit => 'Viser opptil 20 delte turer.';

  @override
  String get memberRemoveTitle => 'Fjerne medlem?';

  @override
  String memberRemoveBody(String name) {
    return 'Fjerne $name fra denne turen? Dette er kun mulig hvis vedkommende ikke har utgifter, oppgjør eller saldoer.';
  }

  @override
  String get memberRemoveAction => 'Fjern fra turen';

  @override
  String memberRemoved(String name) {
    return '$name er fjernet fra turen.';
  }

  @override
  String get profilePaymentNotAdded => 'Ikke lagt til ennå';

  @override
  String get friendRelationshipLabel => 'Venn';

  @override
  String get sharedTripsEmptyBody => 'Turer dere begge deltar på, vises her.';

  @override
  String get analyticsAllTrips => 'Alle turer';

  @override
  String get analyticsByTrip => 'Per tur';

  @override
  String get analyticsYourSpending => 'Dine utgifter';

  @override
  String get analyticsActiveArchived => 'Aktive og arkiverte turer';

  @override
  String get analyticsTrips => 'Reiser';

  @override
  String get analyticsAveragePerTrip => 'Gjennomsnitt per tur';

  @override
  String get analyticsPaidByMember => 'Betalt av medlem';

  @override
  String get analyticsYouPaid => 'Du betalte';

  @override
  String get analyticsYouGetBack => 'Du får tilbake';

  @override
  String get analyticsYouOwe => 'Du skylder';

  @override
  String get analyticsParticipants => 'Deltakere';

  @override
  String get analyticsYourCategories => 'Utgiftene dine etter kategori';

  @override
  String get analyticsLargestShares => 'Mine største utgiftsandeler';

  @override
  String get analyticsLargestExpenses => 'Største utgifter';

  @override
  String get analyticsSpendingByTrip => 'Dine utgifter per tur';

  @override
  String get analyticsEmptyTitle => 'Ingen utgifter ennå';

  @override
  String get analyticsEmptyBody => 'Utgiftene dine vises her når du legger til utgifter til en reise.';

  @override
  String get analyticsPeriodEmptyBody => 'Det er ingen kostnader for denne visningen. Prøv en annen tur eller periode.';

  @override
  String get analyticsLoadFailed => 'Det var ikke mulig å laste inn hele utgiftsrapporten. Prøv på nytt.';

  @override
  String get analyticsLastLoaded => 'Viser den siste rapporten som ble lastet inn uten feil.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utgifter',
      one: '$count utgift',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Turalternativer';

  @override
  String get editTripAction => 'Rediger tur';

  @override
  String get deleteTripAction => 'Slett tur';

  @override
  String get inviteTripMembersAction => 'Inviter medlemmer';

  @override
  String get tripCoverPhoto => 'Forsidebilde';

  @override
  String get tripInviteLaterHint => 'Du kan invitere personer etter at du har opprettet turen.';

  @override
  String get inviteClipboardFailed => 'Kunne ikke få tilgang til utklippstavlen. Prøv på nytt.';

  @override
  String get friendInviteToTrip => 'Inviter til tur';

  @override
  String get friendChooseTrip => 'Velg en tur';

  @override
  String get friendNoInvitableTrips => 'Ingen tilgjengelige turer. Du kan invitere venner til aktive gruppeturer du administrerer, med mindre de allerede er medlemmer eller har en invitasjon som venter på godkjenning.';

  @override
  String get friendTripInviteSent => 'Invitasjon sendt.';

  @override
  String get friendTripUnavailable => 'Denne turen er ikke lenger tilgjengelig for denne handlingen. Oppdater og prøv på nytt.';

  @override
  String get friendTripActionFailed => 'Kunne ikke fullføre denne handlingen. Prøv på nytt.';

  @override
  String get profileContactDescription => 'Har du et problem, et forslag eller et spørsmål om Splyto? Send oss en e-post – vi hjelper deg gjerne.';

  @override
  String get profileContactEmailAction => 'Skriv en e-post';

  @override
  String get profileContactEmailUnavailable => 'Kunne ikke åpne en e-postapp. Kopier adressen og skriv til oss fra e-postappen din.';

  @override
  String get profilePrivacyPolicy => 'Personvernerklæring';

  @override
  String get privacyLoadFailed => 'Det var ikke mulig å laste inn personvernerklæringen. Prøv på nytt.';

  @override
  String get addReceiptAction => 'Legg til kvittering';

  @override
  String get receiptPickFailed => 'Det gikk ikke an å laste inn kvitteringen. Prøv på nytt.';

  @override
  String get receiptPhotoAccessDenied => 'Gi Splyto tilgang til kameraet eller bildebiblioteket i Innstillinger, og prøv deretter på nytt.';

  @override
  String get receiptPhotoLabel => 'Bilde av kvittering';

  @override
  String get replaceReceiptAction => 'Erstatt kvittering';

  @override
  String get removeReceiptAction => 'Fjern kvittering';

  @override
  String get restoreReceiptAction => 'Gjenopprett forrige kvittering';

  @override
  String get expenseSplitBetween => 'Fordel mellom';

  @override
  String get expenseEditParticipants => 'Velg deltakere';

  @override
  String get expenseCustomSplit => 'Tilpasset fordeling';

  @override
  String expenseSplitAllocated(String amount) {
    return 'Hele $amount fordelt';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return '$amount igjen å dele';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount over totalbeløpet';
  }

  @override
  String get profilePaymentSharingTitle => 'Del betalingsmåter med turene mine';

  @override
  String get profilePaymentSharingDescription => 'La godkjente deltakere på reiser jeg oppretter eller blir med på, se betalingsmetodene mine. Dette gjelder både nåværende og fremtidige reiser. Du kan når som helst slå av delingen for å hindre videre tilgang.';

  @override
  String get memberPaymentDetailsNotShared => 'Betalingsmetoder deles ikke eller er foreløpig utilgjengelige.';

  @override
  String get homeTripInvitations => 'Reiseinvitasjoner';

  @override
  String get homeNoTripInvitations => 'Ingen ventende turinvitasjoner';

  @override
  String get homeInvitationsLoadFailed => 'Kunne ikke laste inn invitasjoner. Prøv på nytt.';

  @override
  String get homeInvitationResponseFailed => 'Kunne ikke svare på invitasjonen. Prøv igjen.';

  @override
  String get homeTripShareFailed => 'Kunne ikke dele turen. Prøv på nytt.';

  @override
  String get settleStillToReceive => 'Gjenstår å motta';

  @override
  String get settleStillToPay => 'Gjenstår å betale';

  @override
  String get settleEstimateCaption => 'Estimat basert på nåværende utgifter. Beløpene kan endres frem til turen er avsluttet.';

  @override
  String get settleOutstandingCaption => 'Venter på betaling eller bekreftelse.';

  @override
  String get settleWaitingForYou => 'Venter på at du skal merke deg som klar.';

  @override
  String get settleWhoPaysWhom => 'Hvem betaler hvem';

  @override
  String get settlePreviewCaption => 'Forhåndsvisning · fullført når turen avsluttes';

  @override
  String get settleOpenPaymentCaption => 'Åpne en betaling for å se detaljer og tilgjengelige handlinger.';

  @override
  String get tripBudgetEnable => 'Sett et budsjett';

  @override
  String get tripBudgetSoloHint => 'Valgfritt utgiftsmål for denne turen.';

  @override
  String get tripBudgetGroupHint => 'Ett felles budsjett for hele gruppen.';

  @override
  String get tripBudgetAmount => 'Budsjettbeløp';

  @override
  String get tripBudgetInvalid => 'Angi et beløp mellom 0,01 og 999999999,99, med opptil to desimaler.';

  @override
  String get tripBudgetTitle => 'Turbudsjett';

  @override
  String get tripBudgetGroupTitle => 'Gruppebudsjett';

  @override
  String get tripBudgetRemaining => 'Gjenværende';

  @override
  String get tripBudgetOver => 'Over budsjett';

  @override
  String get tripBudgetSpent => 'Brukt';

  @override
  String get tripBudgetLimit => 'Budsjett';

  @override
  String get travelMapTitle => 'Mitt reisekart';

  @override
  String get travelMapSubtitle => 'Steder du har besøkt, bare for deg.';

  @override
  String get travelMapHere => 'Jeg har vært her';

  @override
  String get travelMapAdd => 'Legg til sted';

  @override
  String get travelMapSearch => 'Søk etter by og land';

  @override
  String get travelMapSearchAction => 'Søk';

  @override
  String get travelMapSearchHint => 'For eksempel Lisboa, Portugal';

  @override
  String get travelMapEmpty => 'Ditt neste minne starter her';

  @override
  String get travelMapEmptyBody => 'Legg til en by du har besøkt, eller sjekk inn der du er nå.';

  @override
  String get travelMapConfirm => 'Lagre dette besøket?';

  @override
  String get travelMapConfirmBody => 'Sjekk byen og datoen før du lagrer den på ditt private kart.';

  @override
  String get travelMapDate => 'Besøksdato';

  @override
  String get travelMapSave => 'Lagre på kartet mitt';

  @override
  String get travelMapCancel => 'Avbryt';

  @override
  String get travelMapClose => 'Lukk';

  @override
  String get travelMapNoResults => 'Ingen by funnet. Prøv å legge til landet i søket.';

  @override
  String get travelMapLookupError => 'Kunne ikke finne byen. Sjekk nettforbindelsen din eller legg til et sted manuelt.';

  @override
  String get travelMapDenied => 'Tilgang til posisjon er deaktivert. Du kan fortsatt legge til en by manuelt.';

  @override
  String get travelMapDisabled => 'Slå på posisjonstjenester, eller legg til en by manuelt.';

  @override
  String get travelMapError => 'Det gikk ikke an å laste inn reisekartet ditt. Prøv på nytt.';

  @override
  String get travelMapSaveError => 'Kunne ikke lagre besøket. Prøv på nytt.';

  @override
  String get travelMapUnavailable => 'Reisekartet trenger en serveroppdatering.';

  @override
  String get travelMapOffline => 'Offline · viser lagrede steder';

  @override
  String get travelMapRetry => 'Prøv på nytt';

  @override
  String get travelMapDelete => 'Fjern besøk';

  @override
  String get travelMapDeleteConfirm => 'Vil du fjerne dette besøket fra ditt private kart?';

  @override
  String get travelMapFit => 'Vis alle steder';

  @override
  String get travelMapSaved => 'Besøk lagret';

  @override
  String get travelMapVisited => 'Besøkt';

  @override
  String get travelMapLimit => 'Kartet ditt har nådd 1 000 besøk. Fjern et gammelt besøk før du legger til et nytt.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries land',
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
      other: '$count besøk',
      one: '$count besøk',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Reisemål (valgfritt)';

  @override
  String get travelAddDestination => 'Legg til destinasjon';

  @override
  String get travelRemoveDestination => 'Fjern destinasjon';

  @override
  String get travelFromTrip => 'Fra en tur';

  @override
  String get travelChooseTrip => 'Velg en tur';

  @override
  String get travelNoTrips => 'Ingen turer tilgjengelig ennå. Du kan legge til et sted manuelt.';

  @override
  String get travelAddToMap => 'Legg til på kartet mitt';

  @override
  String get travelTripConfirm => 'Lagre kun steder du faktisk har besøkt. Dette legger til et privat minne på kartet ditt.';

  @override
  String get travelVisitTitle => 'Tittel (valgfritt)';

  @override
  String get travelAddPhoto => 'Legg til et bilde';

  @override
  String get travelChangePhoto => 'Endre bilde';

  @override
  String get travelRemovePhoto => 'Fjern bilde';

  @override
  String get travelPhotoError => 'Kunne ikke forberede dette bildet. Vennligst velg et annet.';

  @override
  String get travelEditVisit => 'Rediger besøk';

  @override
  String get travelOpenTrip => 'Åpne tur';

  @override
  String get travelPreviousVisit => 'Forrige besøk';

  @override
  String get travelNextVisit => 'Neste besøk';

  @override
  String get travelDuplicate => 'Dette besøket er allerede på kartet ditt.';

  @override
  String get liveMapTitle => 'Live-kart';

  @override
  String get liveShareTitle => 'Del min posisjon';

  @override
  String get liveConsent => 'Del den nøyaktige posisjonen din bare med godkjente deltakere på denne reisen, i tidsrommet du velger. Delingen fortsetter i bakgrunnen, og du kan stoppe den når som helst.';

  @override
  String get liveBackgroundNote => 'Oppdateringer kan pause uten internett eller hvis du tvinger appen til å lukkes. Kun den siste posisjonen lagres; ingen rutehistorikk registreres.';

  @override
  String get liveStart => 'Begynn å dele';

  @override
  String get liveStop => 'Stopp delingen';

  @override
  String get liveNotification => 'Din posisjon deles med reisefølget ditt. Åpne Splyto for å stoppe delingen.';

  @override
  String get livePermissionError => 'Tillat tilgang til posisjonen din i telefonens innstillinger for å dele den.';

  @override
  String get liveStartError => 'Kunne ikke starte delingen. Sjekk tilgang til posisjon, internett og dato og klokkeslett på telefonen din.';

  @override
  String get liveStopPending => 'Oppdateringer er stoppet. Venter på internettforbindelse for å fjerne din siste posisjon; den forsvinner fra kartet innen 2 minutter uten oppdateringer.';

  @override
  String get liveSharing => 'deler posisjon';

  @override
  String get liveUnavailable => 'Dette sanntidskartet er ikke tilgjengelig. Gå tilbake til turen og oppdater.';

  @override
  String get liveMapLoadError => 'Kartet kunne ikke lastes inn. Sjekk nettforbindelsen din og åpne kartet på nytt.';

  @override
  String get liveLoadError => 'Kunne ikke oppdatere posisjoner. Kun de siste oppdateringene vises.';

  @override
  String get liveFit => 'Vis alle på kartet';

  @override
  String get liveEmpty => 'Ingen deler sin siste posisjon ennå.';

  @override
  String get liveRecent => 'Nettopp oppdatert';

  @override
  String get liveLastKnown => 'Sist oppdatert';

  @override
  String get liveAccuracy => 'Nøyaktighet';

  @override
  String get liveUntil => 'Deling inntil';

  @override
  String get liveOtherSession => 'Startet i en annen økt. Du kan stoppe den her.';

  @override
  String get liveUpdatesPaused => 'Oppdateringer er satt på pause. Sjekk tilgang til posisjon og internett.';

  @override
  String get livePrivateUntilShared => 'Posisjonen din forblir privat inntil du velger å dele den.';

  @override
  String get activityEventExpenseCreated => 'lagt til en utgift';

  @override
  String get activityEventExpenseUpdated => 'oppdatert en utgift';

  @override
  String get activityEventExpenseDeleted => 'slettet en utgift';

  @override
  String get activityEventTripCreated => 'opprettet turen';

  @override
  String get activityEventTripUpdated => 'oppdaterte reisedetaljer';

  @override
  String get activityEventTripMembersAdded => 'tilføyde medlemmer';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'sendte invitasjoner: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'har sluttet seg til turen';

  @override
  String get activityEventTripInvitationDeclined => 'avviste turinvitasjonen';

  @override
  String get activityEventTripInvitationRevoked => 'avlyst en turinvitasjon';

  @override
  String activityEventTripMemberRemoved(String name) {
    return '$name har blitt fjernet fra turen';
  }

  @override
  String get activityEventTripMemberLeft => 'forlot turen';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'endret rollen til $name til $role';
  }

  @override
  String get activityEventTripMemberReady => 'merket som klar til oppgjør';

  @override
  String get activityEventTripMemberNotReady => 'merket som ikke klar';

  @override
  String get activityEventTripAllMembersReady => 'Alle medlemmer er klare til å gjøre opp';

  @override
  String get activityEventTripFinished => 'turen er fullført';

  @override
  String get activityEventSettlementMarkedSent => 'merket en overføring som sendt';

  @override
  String get activityEventSettlementConfirmed => 'bekreftet en overføring';

  @override
  String get activityEventSettlementSentCancelled => 'avbrutt sendt status';

  @override
  String get activityEventSettlementNotReceived => 'merket en overføring som ikke mottatt';

  @override
  String get activityEventSettlementReminderSent => 'sendt en påminnelse om oppgjør';

  @override
  String get activityEventPaymentMarkedSent => 'registrert en betaling';

  @override
  String get activityEventPaymentRequested => 'ba om en betaling';

  @override
  String get activityEventPaymentRequestMarkedSent => 'merket en forespurt betaling som sendt';

  @override
  String get activityEventPaymentRequestCancelled => 'avbrutt en betalingsforespørsel';

  @override
  String get activityEventPaymentRequestDeclined => 'avviste en betalingsforespørsel';

  @override
  String get activityEventPaymentConfirmed => 'bekreftet en betaling';

  @override
  String get activityEventPaymentCancelled => 'avbrutt en betalingspost';

  @override
  String get activityEventPaymentNotReceived => 'merket en betaling som ikke mottatt';

  @override
  String get activityEventUnknown => 'gjort en endring';

  @override
  String get privacyEnglishFallback => 'Personvernerklæringen er foreløpig tilgjengelig på engelsk.';

  @override
  String get activityRoleAdmin => 'Admin';

  @override
  String get accountDeleteTitle => 'Slett konto';

  @override
  String get accountDeleteIntro => 'Bekreft slettingen via e-post. Etter bekreftelsen kan den ikke angres.';

  @override
  String get accountDeleteConsequences => 'Sletting er permanent. Profilen din blir anonymisert, og tilgangen til kontoen fjernes. Delte reise- og utgiftsoppføringer beholdes for andre medlemmer.';

  @override
  String get accountDeleteReasonsTitle => 'Hva kunne vi ha gjort bedre?';

  @override
  String get accountDeleteReasonsHint => 'Årsak (valgfritt)';

  @override
  String get accountDeleteReasonNotUsing => 'Jeg trenger ikke lenger Splyto til turene mine';

  @override
  String get accountDeleteReasonAnotherWay => 'Jeg administrerer delte utgifter på en annen måte';

  @override
  String get accountDeleteReasonComplicated => 'Det krever for mye innsats å få ting gjort';

  @override
  String get accountDeleteReasonTechnical => 'Jeg har støtt på feil eller tekniske problemer';

  @override
  String get accountDeleteReasonPrivacy => 'Jeg vil helst slette kontoopplysningene mine';

  @override
  String get accountDeleteReasonOther => 'Jeg vil slette kontoen min av en annen grunn';

  @override
  String get accountDeleteEmailStep => 'Neste trinn er bekreftelse via e-post.';

  @override
  String get accountDeletePasswordHint => 'Skriv inn ditt nåværende Splyto-passord for å be om bekreftelses-e-posten. Kontoen din er fortsatt aktiv.';

  @override
  String get accountDeleteInboxTitle => 'Ett siste trinn i innboksen din';

  @override
  String accountDeleteSentBody(String email) {
    return 'Bekreftelseslenke sendt til $email.';
  }

  @override
  String get accountDeleteSentHint => 'Kontoen din forblir aktiv til du bekrefter slettingen.';

  @override
  String get accountDeleteSending => 'Sende bekreftelses-e-post';

  @override
  String get friendsShowMore => 'Vis flere';
}
