// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get homeFirstTrip => 'Din första resa';

  @override
  String get homeYourShareAllTrips => 'Din andel av alla resor';

  @override
  String get homeAllTime => 'Hela perioden';

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
    return 'Reserelaterade åtgärder: $name';
  }

  @override
  String get homeNoActiveTrips => 'Inga aktiva resor';

  @override
  String get homeNoArchivedTrips => 'Inga arkiverade resor';

  @override
  String get homeLoadingTrips => 'Laddar dina resor';

  @override
  String get homeLoadErrorTitle => 'Det gick inte att ladda dina resor';

  @override
  String get homeLoadErrorBody => 'Vänligen försök igen om en stund.';

  @override
  String get homeOfflineTitle => 'Du är offline';

  @override
  String get homeOfflineNoData => 'Dina resor är ännu inte tillgängliga på den här enheten.';

  @override
  String get homeOfflineCached => 'Offline. Visar sparade resor.';

  @override
  String get homeRefreshError => 'Det gick inte att uppdatera. Visar tidigare laddade resor.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Dela mina sparade betalningsuppgifter med $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Endast så länge denna begäran väntar på betalning. Om begäran avbryts upphör åtkomsten.';

  @override
  String get paymentDetailsUnavailable => 'Betalningsuppgifterna är inte tillgängliga. Anslut till internet och kontrollera att begäran fortfarande är öppen.';

  @override
  String get paymentDetailsRetry => 'Försök igen';

  @override
  String get tripModeSolo => 'Bara jag';

  @override
  String get tripModeGroup => 'Med andra';

  @override
  String get premiumFree => 'Gratis';

  @override
  String get premiumStatusUnavailable => 'Planstatus ej tillgänglig';

  @override
  String premiumGrantedUntil(String date) {
    return 'Premium beviljat till och med $date';
  }

  @override
  String get premiumBillingNotActive => 'Inget aktivt abonnemang';

  @override
  String get premiumRefreshStatus => 'Uppdatera planens status';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String get activeStatus => 'Aktiv';

  @override
  String get activeTripPlural => 'aktiva resor';

  @override
  String get activeTripSingle => 'aktiv resa';

  @override
  String get activeTrips => 'Aktiva resor';

  @override
  String get activitiesComingSoon => 'Avsnittet om aktiviteter kommer snart.';

  @override
  String get addAction => 'Lägg till';

  @override
  String get addExpenseTitle => 'Lägg till utgift';

  @override
  String get addExpensesAction => 'Lägg till utgifter';

  @override
  String get addMembersAction => 'Lägg till deltagare';

  @override
  String get addTripMembersTitle => 'Bjud in resedeltagare';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inbjudningar skickade',
      one: '$count inbjudan skickad',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Reseinbjudan avvisad.';

  @override
  String get tripInviteAction => 'Bjud in';

  @override
  String get tripInvitationsPending => 'Väntar på svar';

  @override
  String get tripInvitationsRetry => 'Inbjudningar är inte tillgängliga. Försök igen';

  @override
  String get tripInvitationRevoke => 'Avbryt inbjudan';

  @override
  String get tripInvitationRevokeFailed => 'Det gick inte att avboka inbjudan. Försök igen.';

  @override
  String get tripInvitationBody => 'Du har blivit inbjuden till en resa. Öppna inbjudan för att svara.';

  @override
  String get allCaughtUp => 'Allt är uppdaterat';

  @override
  String get allFilter => 'Alla';

  @override
  String get allMembersLabel => 'Alla deltagare';

  @override
  String get allPaymentsConfirmed => 'Alla betalningar bekräftas.';

  @override
  String get allTrips => 'Alla resor';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Belopp';

  @override
  String get amountMustBeGreaterThanZero => 'Beloppet måste vara större än 0.';

  @override
  String get appearance => 'Utseende';

  @override
  String get archivedStatus => 'Arkiverat';

  @override
  String get authSubtitleLogin => 'Dela resekostnader med vänner';

  @override
  String get authSubtitleRegister => 'Skapa ett konto och börja dela resekostnader';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'bekräftade: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'väntar på: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'skickat: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'förslag: $count';
  }

  @override
  String get cancelAction => 'Avbryt';

  @override
  String get changeEmailWithPasswordHelper => 'Ange ditt lösenord för att ändra e-postadress.';

  @override
  String get chooseReceiptFile => 'Välj kvittensfil';

  @override
  String get completeAccountSetupDescription => 'Ange din e-postadress och ditt lösenord för att slutföra ditt konto.';

  @override
  String get completeAccountSetupTitle => 'Slutför kontoinställningarna';

  @override
  String get confirmReceivedAction => 'Bekräfta mottagandet';

  @override
  String get confirmedAllSettlementsArchived => 'Alla avräkningar bekräftade. Resan arkiverad.';

  @override
  String get confirmedAsReceived => 'Bekräftat som mottaget.';

  @override
  String get confirmedLabel => 'Bekräftad';

  @override
  String get couldNotOpenReceiptLink => 'Det gick inte att öppna länken till kvittot.';

  @override
  String get createAction => 'Skapa';

  @override
  String get createFirstTripHint => 'Skapa din första resa för att komma igång.';

  @override
  String get createNewTripTitle => 'Skapa ny resa';

  @override
  String get createTripAction => 'Skapa resa';

  @override
  String get createTripFirst => 'Skapa först en resa.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date  -  Skapad av $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Resans skapare måste avsluta resan för att påbörja bekräftelsen av avräkningen.';

  @override
  String currentEmailLabel(Object email) {
    return 'Aktuell e-postadress: $email';
  }

  @override
  String get currentReceiptAttached => 'Aktuellt kvitto bifogas.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Datum';

  @override
  String get dateMustMatchFormat => 'Datumet måste anges i formatet YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Datum okänt';

  @override
  String get deleteAction => 'Ta bort';

  @override
  String get deleteExpenseConfirmQuestion => 'Ska denna utgift raderas?';

  @override
  String get deleteExpenseTitle => 'Ta bort utgift';

  @override
  String get editExpenseConfirmTitle => 'Spara ändringar i utgifterna?';

  @override
  String get editExpenseConfirmText => 'Detta kommer att uppdatera saldon för alla i resan.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Förklaras direkt genom utgifter: $amount';
  }

  @override
  String get doneStatus => 'Klart';

  @override
  String get editAction => 'Redigera';

  @override
  String get editExpenseTitle => 'Redigera utgift';

  @override
  String get emailAddressLabel => 'E-postadress';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E-post';

  @override
  String get emailRequired => 'E-postadress krävs.';

  @override
  String get enterValidExactAmounts => 'Ange giltiga och exakta belopp för alla deltagare.';

  @override
  String get enterValidPercentages => 'Ange giltiga procentandelar för alla deltagare.';

  @override
  String get equalSplitLabel => 'Dela lika';

  @override
  String exactAmountWithValue(Object value) {
    return 'Exakt: $value';
  }

  @override
  String get exactAmountsLabel => 'Exakta belopp';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Den exakta fördelningen måste summera till $amount.';
  }

  @override
  String get expenseAdded => 'Utgift tillagd.';

  @override
  String get expenseBreakdownSubtitle => 'Hur denna medlem påverkas av varje utgift.';

  @override
  String get expenseBreakdownTitle => 'Kostnadsfördelning';

  @override
  String get expenseDeleted => 'Utgiften har raderats.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Utgift nr $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Betalt $paid  -  Skyldig $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reaktioner';

  @override
  String get expenseCommentsTitle => 'Kommentarer';

  @override
  String get expenseNoComments => 'Inga kommentarer ännu.';

  @override
  String get expenseAddCommentHint => 'Lägg till en kommentar...';

  @override
  String get expenseCommentSend => 'Skicka';

  @override
  String get expenseMentionNoMatches => 'Inga matchande medlemmar';

  @override
  String get expenseMentionMembersLabel => 'Resemedlemmar att nämna';

  @override
  String get expenseDeleteCommentTitle => 'Ta bort kommentar?';

  @override
  String get expenseUpdated => 'Utgifter uppdaterade.';

  @override
  String expenseWithId(Object id) {
    return 'Utgift nr $id';
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
  String get failedToCreateTrip => 'Det gick inte att skapa resan.';

  @override
  String get failedToLoadUsersDirectory => 'Det gick inte att ladda användarkatalogen.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrera avräkningar efter medlem';

  @override
  String get finishSoloTripConfirmationText => 'Vill du avsluta denna resa och flytta den till ditt arkiv? Dina utgifter kommer fortfarande att vara tillgängliga att se.';

  @override
  String get soloTripArchived => 'Resan är avslutad och arkiverad.';

  @override
  String get finishTripSyncPending => 'Synkronisera dina väntande ändringar innan du avslutar denna resa.';

  @override
  String get finishTripAction => 'Avsluta resan';

  @override
  String get finishTripConfirmationText => 'Avsluta denna resa och påbörja avräkningen?';

  @override
  String get finishTripStartSettlementsAction => 'Avsluta och påbörja avräkningar';

  @override
  String get finishTripTitle => 'Avsluta resan';

  @override
  String forParticipants(Object participants) {
    return 'För: $participants';
  }

  @override
  String get forgotPassword => 'Har du glömt lösenordet?';

  @override
  String get profileSetPassword => 'Ange lösenord';

  @override
  String get profileManagePassword => 'Ange eller ändra lösenord';

  @override
  String get profilePasswordByEmail => 'Ställ in lösenord via e-post';

  @override
  String get passwordEmailBackToProfile => 'Tillbaka till profilen';

  @override
  String get forgotPasswordSubtitle => 'Ange din e-postadress så skickar vi en länk för att återställa lösenordet.';

  @override
  String get forgotPasswordSuccessMessage => 'Om det finns ett konto med den här e-postadressen har vi skickat en länk för att återställa lösenordet.';

  @override
  String get passwordResetSentTitle => 'Kolla din inkorg';

  @override
  String get passwordResetSentHint => 'Länken är giltig i 1 timme. Hittar du inte e-postmeddelandet, titta i skräppostmappen.';

  @override
  String get forgotPasswordTitle => 'Återställ lösenord';

  @override
  String get friendsProgressSubtitle => 'Varje medlem och dennes bekräftelsestatus.';

  @override
  String get friendsProgressTitle => 'Vännernas framsteg';

  @override
  String get friendsSectionComingSoon => 'Avsnittet ”Vänner” kommer snart.';

  @override
  String fromDirection(Object name) {
    return 'Från $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from till $to';
  }

  @override
  String get generateTurnAction => 'Lotta nästa person';

  @override
  String get hasAccountQuestion => 'Har du redan ett konto?';

  @override
  String helloUser(Object name) {
    return 'Hej, $name!';
  }

  @override
  String get iSentAction => 'Jag skickade';

  @override
  String get invalidEmailFormat => 'Ogiltigt e-postformat.';

  @override
  String get languageAction => 'Språk';

  @override
  String get languageEnglish => 'Engelska';

  @override
  String get languageLatvian => 'Lettiska';

  @override
  String get languageSpanish => 'Spanska';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemSubtitle => 'Använd enhetens språk';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Lämna fältet tomt för att behålla det nuvarande lösenordet.';

  @override
  String get logInButton => 'Logga in';

  @override
  String get logOutButton => 'Logga ut';

  @override
  String get logoutFromDeviceQuestion => 'Logga ut från den här enheten?';

  @override
  String get logoutRevocationUnconfirmed => 'Utloggad på den här enheten. Återkallandet av serversessionen kunde inte bekräftas.';

  @override
  String get markedAsSent => 'Markerad som skickad.';

  @override
  String get markSettlementSentConfirmTitle => 'Markera överföringen som skickad?';

  @override
  String get markSettlementSentConfirmText => 'Använd detta först efter att du faktiskt har skickat betalningen. Mottagaren kommer att ombes att bekräfta.';

  @override
  String get settlementCancelSentAction => 'Markera som ej skickat';

  @override
  String get settlementCancelSentConfirmTitle => 'Avbryta statusen ”skickad”?';

  @override
  String get settlementCancelSentConfirmText => 'Detta kommer att återföra överföringen till väntande status och meddela mottagaren.';

  @override
  String get settlementSentCancelled => 'Överföringen har återförts till vänteläge.';

  @override
  String get settlementNotReceivedAction => 'Jag har inte fått detta';

  @override
  String get settlementNotReceivedConfirmTitle => 'Anmäla att betalningen inte kommit fram?';

  @override
  String get settlementNotReceivedConfirmText => 'Detta kommer att återföra överföringen till väntande status och meddela betalaren.';

  @override
  String get settlementMarkedNotReceived => 'Markerad som ej mottagen.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Bekräftar du mottagandet?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Bekräfta först när pengarna syns på ditt konto. Denna åtgärd kan slutföra avräkningen.';

  @override
  String get memberSummariesSubtitle => 'Aktuellt saldotillstånd för båda parter.';

  @override
  String get memberSummariesTitle => 'Medlemsöversikter';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'För att betala $total  -  bekräftad $confirmed  -  väntar $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Uppskattad betalningspåverkan per medlem.';

  @override
  String get membersImpactTitle => 'Medlemmarnas inverkan';

  @override
  String get membersIncludedInExpense => 'Medlemmar som ingår';

  @override
  String get membersLabel => 'Medlemmar';

  @override
  String moreCount(Object count) {
    return '+ $count fler';
  }

  @override
  String get myFilter => 'Min';

  @override
  String get myImpactTitle => 'Min påverkan';

  @override
  String get firstNameHint => 'Ditt förnamn';

  @override
  String get firstNameLabel => 'Förnamn';

  @override
  String get firstNameLengthValidation => 'Förnamnet måste bestå av 2–64 tecken.';

  @override
  String get fullNameHelper => 'Ange för- och efternamn i ett fält.';

  @override
  String get fullNameHint => 't.ex. Anna Ozolina';

  @override
  String get fullNameLabel => 'Fullständigt namn';

  @override
  String get fullNameValidation => 'Ange för- och efternamn (minst 2 tecken vardera).';

  @override
  String get lastNameHint => 'Ditt efternamn';

  @override
  String get lastNameLabel => 'efternamn';

  @override
  String get lastNameLengthValidation => 'Efternamnet måste bestå av 2–64 tecken.';

  @override
  String get nameHint => 'Ditt namn';

  @override
  String get nameLabel => 'Namnnamn';

  @override
  String get nameLengthValidation => 'Namnet måste bestå av minst 2 tecken.';

  @override
  String get navActivities => 'Statistik';

  @override
  String get navAddTrip => 'Lägg till resa';

  @override
  String get navBalances => 'Saldon';

  @override
  String get navExpenses => 'Utgifter';

  @override
  String get navFriends => 'Vänner';

  @override
  String get navHome => 'Hem';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRandom => 'Slumpmässigt';

  @override
  String get netLabel => 'Nettosaldo';

  @override
  String get newPasswordLabel => 'Nytt lösenord';

  @override
  String get nicknameHint => 'Hur dina vänner ser dig';

  @override
  String get nicknameLabel => 'Smeknamn';

  @override
  String get nicknameLengthValidation => 'Smeknamnet måste bestå av minst 2 tecken.';

  @override
  String get noAccountQuestion => 'Har du inget konto ännu?';

  @override
  String get noBalancesYet => 'Inga saldon ännu.';

  @override
  String get noChangesToSave => 'Inga ändringar att spara.';

  @override
  String get noDirectExpenseLink => 'Ingen direkt länk till en enskild utgift hittades. Denna avräkning beräknas utifrån resans totala saldo.';

  @override
  String get noExpenseImpactForMember => 'Ingen kostnad för denna medlem.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Inga utgifter för $name ännu.';
  }

  @override
  String get noExpensesYet => 'Inga utgifter ännu.';

  @override
  String get noExtraUsersToAdd => 'Inga ytterligare användare att lägga till.';

  @override
  String get noInternetDeleteQueued => 'Inget internet. Ta bort från kö.';

  @override
  String get noInternetExpenseQueued => 'Inget internet. Utgiften i kö.';

  @override
  String get noInternetUpdateQueued => 'Inget internet. Uppdatering i kö.';

  @override
  String get noMatchingRows => 'Inga matchande rader.';

  @override
  String get noMembersFound => 'Inga medlemmar hittades.';

  @override
  String get noNewMembersAdded => 'Dessa personer är redan medlemmar eller har inbjudningar som väntar på svar.';

  @override
  String get noNotePlaceholder => 'Ingen anmärkning';

  @override
  String get notificationsToday => 'Idag';

  @override
  String get notificationsEmptyBody => 'Uppdateringar om resor, utgifter och vänner kommer att visas här.';

  @override
  String get notificationsCached => 'Offline – visar sparade meddelanden.';

  @override
  String get notificationsRefreshFailed => 'Det gick inte att uppdatera. Tidigare laddade aviseringar visas.';

  @override
  String get notificationsJustNow => 'Just nu';

  @override
  String notificationsMinutesAgo(int count) {
    return 'För $count min sedan';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'För $count h sedan';
  }

  @override
  String get notificationsUnread => 'Oläst';

  @override
  String get noNotificationsYet => 'Inga meddelanden ännu.';

  @override
  String get noParticipantData => 'Inga deltagaruppgifter.';

  @override
  String get noParticipantsSelected => 'Inga deltagare har valts ut.';

  @override
  String get noPaymentRowsInTrip => 'Inga betalningsrader för denna resa.';

  @override
  String get noPaymentsNeeded => 'Inga betalningar krävs.';

  @override
  String get noPicksYet => 'Inga val ännu.';

  @override
  String get noSettlementActivityForMember => 'Ingen avräkningsaktivitet för denna medlem.';

  @override
  String get noSettlementRowsYet => 'Inga avräkningsrader ännu.';

  @override
  String get noSettlements => 'Inga avräkningar';

  @override
  String get noTransferNeededForFilter => 'Ingen överföring krävs för det valda filtret.';

  @override
  String get noTransferRowsToShow => 'Inga överföringsrader att visa.';

  @override
  String get noTripDataLoaded => 'Inga resedata har laddats.';

  @override
  String get noTripsYet => 'Inga resor ännu.';

  @override
  String get noUsersFoundYet => 'Inga användare hittades ännu.';

  @override
  String get notSetValue => 'Ej angivet';

  @override
  String get notYetConfirmedTitle => 'Ännu inte bekräftat';

  @override
  String get noteHint => 'Middag, taxi, biljetter...';

  @override
  String get noteLabel => 'Observera';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Anteckningen får innehålla högst $max tecken.';
  }

  @override
  String get notificationFallbackTitle => 'Meddelande';

  @override
  String get notificationsTitle => 'Meddelanden';

  @override
  String get notificationFriendInviteTitle => 'Vänförfrågan';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name har skickat en vänförfrågan till dig.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Du har fått en inbjudan att bli vän.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Inbjudan accepterad';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name har accepterat din vänförfrågan.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Din inbjudan till en vän har godkänts.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Inbjudan avböjd';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name har avböjt din vänförfrågan.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Din inbjudan till en vän har avvisats.';

  @override
  String get notificationTripAddedTitle => 'Lagt till i resan';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name har lagt till dig i resan ”$trip”.';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Du har lagts till i resan ”$trip”.';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Du har lagts till i en resa.';

  @override
  String get notificationExpenseAddedTitle => 'Ny utgift tillagd';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name har lagt till en utgift på $amount i ”$trip”.';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name har lagt till en utgift på $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'En ny utgift har lagts till.';

  @override
  String get notificationCommentMentionTitle => 'Du nämndes i en kommentar';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name nämnde dig i en kommentar om ”$note”.';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name nämnde dig i en kommentar.';
  }

  @override
  String get notificationTripFinishedTitle => 'Resan är avslutad';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name har avslutat ”$trip”. Avräkningarna är klara.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name har avslutat ”$trip”. Resan är arkiverad.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '”$trip” är klart.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Resestatusen har uppdaterats.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Medlem markerad som redo';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name är redo att delta i ”$trip”.';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'En medlem är redo att delta i ”$trip”.';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'En medlem är redo att betala.';

  @override
  String get notificationTripReadyToSettleTitle => 'Alla deltagare är redo';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Alla deltagare är markerade som redo i ”$trip”. Du kan påbörja avräkningen.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Alla deltagare är redo. Du kan påbörja avräkningen.';

  @override
  String get notificationSettlementReminderTitle => 'Påminnelse om betalning';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor påminde $target om att markera $amount som skickat.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor påminde $target om att bekräfta mottagandet av $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Du har fått en påminnelse om betalning.';

  @override
  String get notificationPaymentReminderTitle => 'Betalningspåminnelse';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Påminnelse: markera $amount som skickat till $target i ”$trip”.';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Påminnelse: markera gärna betalningen som skickad.';

  @override
  String get notificationConfirmationReminderTitle => 'Påminnelse om bekräftelse';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Påminnelse: bekräfta mottagandet av $amount från $payer i ”$trip”.';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Påminnelse: bekräfta gärna att du har mottagit betalningen.';

  @override
  String get notificationSettlementSentTitle => 'Överföring markerad som skickad';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name har markerat $amount som skickat till dig.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'En överföring har markerats som skickad.';

  @override
  String get notificationSettlementConfirmedTitle => 'Överföring bekräftad';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name har bekräftat mottagandet av $amount från dig.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'En överföring har bekräftats.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count väntande ändringar',
      one: '$count väntande ändring',
    );
    return 'Offlinekö: $_temp0';
  }

  @override
  String get syncAllSynced => 'Allt synkroniserat';

  @override
  String syncChangesWaiting(Object count) {
    return '$count väntar på synkronisering';
  }

  @override
  String get syncFailedTapToRetry => 'Synkroniseringen misslyckades, tryck för att försöka igen';

  @override
  String get offlineQueueStatus => 'Offlinekö';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Endast resans skapare kan avsluta resan.';

  @override
  String get openLabel => 'Öppna';

  @override
  String get openReceiptAction => 'Öppna kvitto';

  @override
  String get openSettlements => 'Öppna avräkningar';

  @override
  String get overviewTitle => 'Översikt';

  @override
  String get owesLabel => 'Är skyldig';

  @override
  String get paidByLabel => 'Betalas av';

  @override
  String get paidLabel => 'Betalt';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Betalt $paid -  Skyldig $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Deltagare (tomt = alla medlemmar)';

  @override
  String get participantsTitle => 'Deltagare';

  @override
  String get passwordLabel => 'Lösenord';

  @override
  String get passwordComplexityHelper => 'Använd minst 1 versal, 1 siffra och 1 symbol.';

  @override
  String get passwordComplexityValidation => 'Lösenordet måste innehålla 1 versal, 1 siffra och 1 symbol.';

  @override
  String get passwordMinLength => 'Lösenordet måste bestå av minst 8 tecken.';

  @override
  String get passwordMinLengthShort => 'Lösenordet måste bestå av minst 6 tecken.';

  @override
  String get passwordResetComingSoon => 'Återställning av lösenord kommer snart.';

  @override
  String get passwordsDoNotMatch => 'Lösenorden stämmer inte överens.';

  @override
  String payerName(Object name) {
    return '$name (betalare)';
  }

  @override
  String get pendingLabel => 'Väntar';

  @override
  String get pendingPaymentsSubtitle => 'Betalningar väntar fortfarande på fullständig bekräftelse.';

  @override
  String get percentLabel => 'Procent';

  @override
  String get percentSplitMustBe100 => 'Procentfördelningen måste summera till exakt 100 %.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Procentandelar';

  @override
  String get pickAtLeastOneParticipant => 'Välj minst en deltagare.';

  @override
  String get pickMembersGenerateTurn => 'Välj deltagare och lotta nästa person.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name har valts. Cykeln är avslutad.';
  }

  @override
  String pickedUser(Object name) {
    return '$name har valts.';
  }

  @override
  String get profileRefreshCachedData => 'Det gick inte att uppdatera profilen. Visar cachade data.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpdated => 'Profilen har uppdaterats.';

  @override
  String get uploadAvatarAction => 'Ladda upp avatar';

  @override
  String get takePhotoAction => 'Ta en bild';

  @override
  String get chooseFromLibraryAction => 'Välj från biblioteket';

  @override
  String get removeAvatarAction => 'Ta bort avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar uppdaterad.';

  @override
  String get avatarRemovedMessage => 'Avatar borttagen.';

  @override
  String get avatarFileTooLarge => 'Avatarfilen är för stor (max 5 MB).';

  @override
  String get avatarPickFailed => 'Det gick inte att ladda avatarbilden.';

  @override
  String get queueAddExpense => 'Lägg till utgift';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'I kö: lägg till utgift $amount';
  }

  @override
  String get queueDeleteExpense => 'Ta bort utgift';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'I kö: ta bort utgift nr $id';
  }

  @override
  String get queuePendingStatus => 'Kö väntar';

  @override
  String get queueUpdateExpense => 'Uppdatera utgifter';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'I kö: uppdatera utgift nr $id';
  }

  @override
  String get queuedChange => 'Ändringar i kö';

  @override
  String queuedChangesTitle(Object count) {
    return 'Ändringar i kö ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'I kö ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cykel $cycleNo, dra $drawNo – $remaining kvar';
  }

  @override
  String get receiptFallbackName => 'kvitto';

  @override
  String get receiptLinkInvalid => 'Länken till kvittot är ogiltig.';

  @override
  String get receiptOptionalLabel => 'Kvitto (valfritt)';

  @override
  String get recentPicksTitle => 'Senaste lottningar';

  @override
  String get reloadProfile => 'Uppdatera profilen';

  @override
  String get rememberMe => 'Kom ihåg mig';

  @override
  String get removeCurrentReceipt => 'Ta bort nuvarande kvitto';

  @override
  String get repeatNewPasswordLabel => 'Upprepa nytt lösenord';

  @override
  String get repeatPasswordLabel => 'Upprepa lösenord';

  @override
  String get requestFailedTryAgain => 'Begäran misslyckades. Försök igen.';

  @override
  String get retryAction => 'Försök igen';

  @override
  String get rowsLabel => 'Rader';

  @override
  String get backToLoginAction => 'Tillbaka till inloggning';

  @override
  String get saveAction => 'Spara';

  @override
  String get saveCredentialsButton => 'Spara inloggningsuppgifter';

  @override
  String get saveProfileButton => 'Spara profil';

  @override
  String get sendResetLinkButton => 'Skicka återställningslänk';

  @override
  String get searchUsersHint => 'Sök efter personer efter namn eller e-postadress';

  @override
  String get selectedPeopleLabel => 'Utvalda personer';

  @override
  String get noSearchMatches => 'Inga matchande användare hittades.';

  @override
  String get savingButton => 'Sparar...';

  @override
  String get selectAtLeastTwoMembers => 'Välj minst två deltagare.';

  @override
  String get selectMembersHint => 'Välj deltagare';

  @override
  String selectedFileLabel(Object name) {
    return 'Vald: $name';
  }

  @override
  String get selectedLabel => 'Utvalda';

  @override
  String get selectedUserFallback => 'Vald användare';

  @override
  String get settings => 'Inställningar';

  @override
  String get settleUpAction => 'Gör upp';

  @override
  String get settledLabel => 'Reglerat';

  @override
  String get settledStatus => 'Reglerat';

  @override
  String get settlementActivitySubtitle => 'Överföringar kopplade till denna medlem.';

  @override
  String get settlementActivityTitle => 'Avräkningsaktivitet';

  @override
  String get settlementCompletedTitle => 'Avräkningen är slutförd';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total bekräftade';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Avräkningar: $count';
  }

  @override
  String get settlementImpactTitle => 'Konsekvenser för avräkningen';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Konsekvenser för avräkningen: $name';
  }

  @override
  String get settlementInProgress => 'Avräkning pågår';

  @override
  String get settlementInProgressTitle => 'Avräkning pågår';

  @override
  String get settlementLabel => 'Avräkning';

  @override
  String get settlementOverviewArchivedSubtitle => 'Resan har arkiverats. Alla avräkningar är slutförda.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Spåra bekräftelser av betalningar.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Förhandsgranska överföringar för när resan avslutas.';

  @override
  String get settlementPreview => 'Förhandsgranskning av avräkningen';

  @override
  String get settlementPreviewTitle => 'Förhandsgranskning av avräkningen';

  @override
  String get settlementProgressTripArchived => 'Resan arkiverad';

  @override
  String settlementWithId(Object id) {
    return 'Avräkning nr $id';
  }

  @override
  String get settlements => 'Avräkningar';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Avräkningar redan genomförda.';

  @override
  String get settlementsDone => 'Avräkningar genomförda';

  @override
  String get settlingStatus => 'Avräkning';

  @override
  String get shareUnit => 'andel';

  @override
  String get sharesLabel => 'Andelar';

  @override
  String get sharesMustBePositiveIntegers => 'Antalet andelar måste vara ett positivt heltal.';

  @override
  String sharesWithValue(Object value) {
    return 'Andelar: $value';
  }

  @override
  String get showActiveTrips => 'Visa aktiva resor';

  @override
  String get signUpButton => 'Registrera dig';

  @override
  String get splitBreakdownSubtitle => 'Hur kostnaden fördelas';

  @override
  String get splitBreakdownTitle => 'Uppdelning av kostnader';

  @override
  String get splitHintEqual => 'Dela lika mellan de valda deltagarna.';

  @override
  String get splitHintExact => 'Ange exakt belopp för varje deltagare. Summan måste stämma överens med totalbeloppet.';

  @override
  String get splitHintPercent => 'Ange procentandel för varje deltagare. Summan måste vara 100 %.';

  @override
  String get splitHintShares => 'Ange delningsenheter (1, 2, 3...). Kostnaden delas proportionellt.';

  @override
  String get splitLabel => 'Split';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Jämn fördelning ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Exakta belopp ($target)';
  }

  @override
  String get splitModeLabel => 'Delat läge';

  @override
  String splitModePercent(Object target) {
    return 'Procenttal ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Andelar ($target)';
  }

  @override
  String get statusConfirmed => 'Bekräftad';

  @override
  String get statusPending => 'Väntar';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusSuggested => 'Föreslagen';

  @override
  String statusWithValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get suggestedTransferDirections => 'Föreslagna betalningsriktningar';

  @override
  String get suggestedTransferFromExpense => 'Föreslagen överföring från utgifter';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count föreslagna överföringar',
      one: '$count föreslagen överföring',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Förväntade rader för betalare -> mottagare.';

  @override
  String get suggestedTransfersTitle => 'Föreslagna överföringar';

  @override
  String get summarySettledUp => 'Reglerat';

  @override
  String get summaryYouAreOwed => 'Andra är skyldiga dig';

  @override
  String get summaryYouOwe => 'Du är skyldig';

  @override
  String get syncAction => 'Synkronisering';

  @override
  String get syncNowAction => 'Synkronisera nu';

  @override
  String get syncingStatus => 'Synkronisering';

  @override
  String get tapToViewDetails => 'Tryck för att visa detaljer';

  @override
  String get themeModeDark => 'Mörkt';

  @override
  String get themeModeDarkSubtitle => 'Mjuk mörk färg (inte helt svart)';

  @override
  String get themeModeLight => 'Ljust';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeSystemSubtitle => 'Använd enhetens utseende';

  @override
  String toDirection(Object name) {
    return 'Till $name';
  }

  @override
  String get totalLabel => 'Totalt';

  @override
  String get travelerFallbackName => 'Resenär';

  @override
  String get tripAlreadyClosed => 'Resan är redan avslutad.';

  @override
  String get tripArchivedReadOnly => 'Resan arkiveras. Skrivskyddat läge.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Resan är avslutad. Redigering av utgifter är inaktiverad.';

  @override
  String get tripClosedExpensesReadOnly => 'Resan är avslutad. Utgifterna är skrivskyddade.';

  @override
  String get tripClosedRandomDisabled => 'Resan är avslutad. Slumpmässig lottning är inaktiverad.';

  @override
  String tripCreated(Object name) {
    return 'Resan ”$name” har skapats.';
  }

  @override
  String get tripFinished => 'Resan är avslutad.';

  @override
  String get tripFinishedCompleteSettlements => 'Resan är avslutad. Slutför avräkningen.';

  @override
  String get tripFinishedSettlementStarted => 'Resan är avslutad. Avräkningen har påbörjats.';

  @override
  String get tripFullySettledArchived => 'Resan är helt avslutad och arkiverad.';

  @override
  String get tripNameHint => 'Skidresa till Österrike';

  @override
  String get tripNameLabel => 'Resans namn';

  @override
  String get tripNameLengthValidation => 'Resans namn måste bestå av minst 2 tecken.';

  @override
  String get tripSnapshotTitle => 'Resöversikt';

  @override
  String get tripTitleShort => 'Resan';

  @override
  String tripStatusWithValue(Object status) {
    return 'Resestatus: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Resan nr $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Oväntat fel vid inläsning av profil';

  @override
  String get unexpectedErrorLoadingTripData => 'Oväntat fel vid inläsning av resedata';

  @override
  String get unexpectedErrorLoadingTrips => 'Oväntat fel vid inläsning av resor';

  @override
  String get unexpectedErrorSavingChanges => 'Oväntat fel vid sparande av ändringar';

  @override
  String get unexpectedErrorSavingCredentials => 'Oväntat fel vid sparande av inloggningsuppgifter';

  @override
  String get unexpectedErrorUpdatingProfile => 'Oväntat fel vid uppdatering av profil';

  @override
  String get unknownError => 'Okänt fel';

  @override
  String get unknownLabel => 'Okänt';

  @override
  String get unreadLabel => 'Oläst';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count olästa uppdateringar',
      one: '$count oläst uppdatering',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Argumentet för resrutten saknas.';

  @override
  String userIdLabel(Object id) {
    return 'Användar-ID: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Betalt $paid  -  Skyldig $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Användare $id';
  }

  @override
  String get valueLabel => 'Värde';

  @override
  String get viewAllTrips => 'Visa alla resor';

  @override
  String get viewByPersonTitle => 'Visa per person';

  @override
  String get whoOwesWhatSubtitle => 'Vem som har betalat och vem som är skyldig.';

  @override
  String get whoOwesWhatTitle => 'Vem är skyldig vad';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Vem är skyldig vad: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Utgiftsrader som ingår i denna överföring.';

  @override
  String get whyPaymentExistsTitle => 'Varför denna betalning finns';

  @override
  String get youLabel => 'Du';

  @override
  String get youSettledForExpense => 'Du har reglerat din del av den här utgiften.';

  @override
  String youShouldPay(Object amount) {
    return 'Du bör betala $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Du bör ta emot $amount';
  }

  @override
  String get yourShare => 'Din aktie';

  @override
  String get yourTrips => 'Dina resor';

  @override
  String get homeYourActiveTrips => 'Dina aktiva resor';

  @override
  String get homeYourArchivedTrips => 'Dina arkiverade resor';

  @override
  String get authIntroSplitSmarter => 'Dela upp på ett smartare sätt.';

  @override
  String get authIntroTravelFree => 'Res fritt.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Spåra delade kostnader i olika valutor och gör upp räkningen direkt – inga besvärliga skuldsedlar.';

  @override
  String get authIntroPlanTogether => 'Planera tillsammans.';

  @override
  String get authIntroPayClearly => 'Betala tydligt.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Skapa resor på några sekunder, lägg till vänner och se till att alla utgifter är transparenta för alla.';

  @override
  String get authIntroSettleFast => 'Avsluta snabbt.';

  @override
  String get authIntroStayFriends => 'Håll kontakten.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Från gemensamma middagar till hela resor – Splyto ser till att avräkningen blir rättvis och stressfri.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Inloggning via Apple misslyckades. Försök igen.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Inloggningen via Google misslyckades. Försök igen.';

  @override
  String get authIntroCreateAccount => 'Skapa ditt konto.';

  @override
  String get authIntroChooseSign => 'Välj hur du vill registrera dig.';

  @override
  String get authIntroContinueGoogle => 'Fortsätt med Google';

  @override
  String get authIntroContinueApple => 'Fortsätt med Apple';

  @override
  String get authIntroBack => 'Tillbaka';

  @override
  String get authIntroSplitSettled => 'Delad betalning';

  @override
  String get authIntroParis3Friends => 'Paris · 3 vänner';

  @override
  String get authIntroGetStarted => 'Kom igång';

  @override
  String get authIntroAlreadyHaveAccount => 'Har du redan ett konto? ';

  @override
  String get authIntroSignIn => 'Logga in';

  @override
  String get authIntroSignUpWithEmail => 'Registrera dig med e-post';

  @override
  String get authIntroOr => 'ELLER';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Inloggningen via Google returnerade inte något ID-token.';

  @override
  String get authAppleSignAvailableIosDevices => 'Apple-inloggning är tillgänglig på iOS-enheter.';

  @override
  String get authAppleSignNotAvailableDevice => 'Apple-inloggning är inte tillgänglig på den här enheten.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Apple-inloggningen returnerade inte någon identitetstoken.';

  @override
  String get authCancel => 'Avbryt';

  @override
  String get authSendLink => 'Skicka länk';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'E-postadressen är inte verifierad. Ange din e-postadress för att begära en verifieringslänk.';

  @override
  String get authEmailNotVerified => 'E-postadressen är inte verifierad';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Skicka verifieringslänk till $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Verifieringslänk har skickats. Kontrollera din e-post.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Det gick inte att skicka verifieringslänken. Försök igen.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Verifieringsmejl har skickats. Verifiera din e-postadress innan du loggar in.';

  @override
  String get authVerifyEmail => 'Verifiera din e-postadress';

  @override
  String get authEmailLabel => 'E-post:';

  @override
  String get authClose => 'Stäng';

  @override
  String get authResendLink => 'Skicka länken på nytt';

  @override
  String get profileAppSettingsSectionTitle => 'APP-INSTÄLLNINGAR';

  @override
  String get profileEmailVerified => 'Verifierad';

  @override
  String get profileEmailNotVerified => 'Inte verifierad';

  @override
  String get profileEmailSendVerification => 'Skicka länk';

  @override
  String get profileEmailVerificationSent => 'Verifieringsmejl skickat. Kolla din inkorg.';

  @override
  String get profileAccountSectionTitle => 'KONTO';

  @override
  String get profileAccountSettings => 'Kontoinställningar';

  @override
  String get profileChangePhoto => 'Ändra profilbild';

  @override
  String get profileAppearance => 'Utseende';

  @override
  String get profileThemeDisplayMode => 'Tema och visningsläge';

  @override
  String get profileLanguage => 'Språk';

  @override
  String get profileDisplayLanguage => 'Visningsspråk';

  @override
  String get profileNotificationsSectionHeading => 'MEDDELANDEN';

  @override
  String get profileAppBanners => 'Banners i appen';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Visa nya meddelandebannrar i appen';

  @override
  String get profilePushNotificationsTitle => 'Push-meddelanden';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Telefonaviseringar för utgifter, vänner, resor och avräkningar';

  @override
  String get profileSupportSectionHeading => 'SUPPORT';

  @override
  String get profileContactUs => 'Kontakta oss';

  @override
  String get profileReportBugSuggestion => 'Rapportera fel / Förslag';

  @override
  String get profileRateSplyto => 'Betygsätt Splyto';

  @override
  String get profileLeaveStoreRating => 'Lämna ett betyg på butiken';

  @override
  String get profileSecuritySectionHeading => 'SÄKERHET';

  @override
  String get profileAccountAndSecurity => 'Konto och säkerhet';

  @override
  String get profileHelpTitle => 'Hjälp';

  @override
  String get profileChangePassword => 'Ändra lösenord';

  @override
  String get profileUpdateAccountPassword => 'Uppdatera kontots lösenord';

  @override
  String get profileDangerZoneSectionHeading => 'FARZON';

  @override
  String get profileManageAccountAccess => 'Hantera åtkomst till kontot';

  @override
  String get profileMadeWithLabel => 'Skapad med';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Funktionen för att lämna betyg kommer att kopplas in i nästa steg.';

  @override
  String get profileFailedSaveNotificationSettings => 'Det gick inte att spara meddelandeinställningarna.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH-MEDDELANDEN';

  @override
  String get profileInAppBannersSectionTitle => 'BANNER I APPEN';

  @override
  String get profileInAppTripMemberAddedTitle => 'Medlem tillagd till resan';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatisk påminnelse om avräkning';

  @override
  String get profileExpenseUpdates => 'Uppdateringar av utgifter';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Banners för tillagda utgifter i appen';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Meddelanden om tillagda utgifter till telefonen';

  @override
  String get profileFriendInvites => 'Väninbjudningar';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Banners för vänförfrågningar och svar i appen';

  @override
  String get profileFriendRequestResponseNotifications => 'Meddelanden om vänförfrågningar och svar';

  @override
  String get profileTripUpdates => 'Resuppdateringar';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Banners om resans livscykel och deltagarnas status i appen';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Resans livscykel och förändringar i deltagarnas status';

  @override
  String get profileSettlementUpdates => 'Uppdateringar om avräkning';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Markerade banners för skickade och bekräftade betalningar i appen';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Uppdateringar om skickade och bekräftade betalningar';

  @override
  String get profileScreenshotSizeMust8Mb => 'Skärmdumpens storlek får vara högst 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Skicka feedback';

  @override
  String get profileFeedbackTypeLabel => 'Typ';

  @override
  String get profileFeedbackTypeBug => 'Bug';

  @override
  String get profileFeedbackTypeSuggestion => 'Förslag';

  @override
  String get profileDescribeIssueSuggestion => 'Beskriv problem eller förslag';

  @override
  String get profilePickingImage => 'Väljer bild...';

  @override
  String get profileAttachScreenshot => 'Bifoga skärmdump';

  @override
  String get profileChangeScreenshot => 'Ändra skärmdump';

  @override
  String get profileRemoveImage => 'Ta bort bild';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Tips: bifoga en skärmdump för snabbare felsökning';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Lägg till detaljer eller bifoga en skärmdump innan du skickar';

  @override
  String get profileSendAction => 'Skicka';

  @override
  String get profileThanksFeedbackSent => 'Tack! Feedback skickad';

  @override
  String get profileFailedSendFeedback => 'Det gick inte att skicka feedback';

  @override
  String get profileCouldNotOpenWebsite => 'Det gick inte att öppna webbplatsen.';

  @override
  String get profileOpenWebsiteQuestion => 'Öppna webbplatsen?';

  @override
  String get profileOpenPortfolioAction => 'Öppna portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Detta bildformat stöds inte på den här enheten. Välj JPG eller PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'En giltig e-postadress för kontot krävs för att ändra ditt lösenord. Kontakta supporten om din e-postadress saknas eller är felaktig.';

  @override
  String get profileEditDeletionLinkSentEmail => 'En länk för borttagning har skickats till din e-postadress.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Det gick inte att skicka länken för borttagning. Försök igen.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Ange ditt nuvarande lösenord för att ändra e-postadress.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Verifieringsmeddelandet har skickats till den nya e-postadressen. Säkerhetsmeddelandet har skickats till din nuvarande e-postadress.';

  @override
  String get profileEditOverviewCurrency => 'Översikt över valuta';

  @override
  String get profileEditPaymentMethod => 'Betalningssätt';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Banköverföring, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Ange ditt lösenord (valfritt för Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Skicka en länk för radering till e-post';

  @override
  String get profileEditBackProfile => 'Tillbaka till profilen';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Ange en giltig e-postadress i profilen innan du byter lösenord.';

  @override
  String get profileEditPasswordUpdated => 'Lösenordet har uppdaterats.';

  @override
  String get profileEditFailedUpdatePassword => 'Det gick inte att uppdatera lösenordet.';

  @override
  String profileEditEmail(Object email) {
    return 'Konto: $email';
  }

  @override
  String get profileEditPrimary => 'Primär';

  @override
  String get profileEditSearchCurrency => 'Sök valuta';

  @override
  String get profileEditNoCurrenciesFound => 'Inga valutor hittades';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Översiktssummorna omräknas till denna valuta.';

  @override
  String get profileEditPaymentInfoUpdated => 'Betalningsinformation uppdaterad.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Det gick inte att spara betalningsuppgifterna. Försök igen.';

  @override
  String get profileEditCurrentPassword => 'Nuvarande lösenord';

  @override
  String get profileEditBankTransferIbanSwift => 'Banköverföring (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me-länk';

  @override
  String get profileEditChoosePaymentMethod => 'Välj betalningssätt';

  @override
  String get profileEditTapChange => 'Tryck för att ändra';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'För överföringar i Storbritannien måste sorteringskoden bestå av 6 siffror och kontonumret av 8 siffror.';

  @override
  String get profileEditPaymentInfo => 'Betalningsinformation';

  @override
  String get profileEditSaveDetails => 'Spara uppgifter';

  @override
  String get profileEditBankRegion => 'Bankregion';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'Bankkod';

  @override
  String get profileEditExample112233 => 'Exempel: 112233';

  @override
  String get profileEditNumber => 'Kontonummer';

  @override
  String get profileEdit8Digits => '8 siffror';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'För inhemska överföringar i Storbritannien använder du sort code + kontonummer.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Exempel: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 eller 11 tecken';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Kontoinnehavarens namn hämtas från det fullständiga namnet i profilen.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username eller användarnamn';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Storbritannien';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Justera avataren';

  @override
  String get imageCropperAdjustTripImage => 'Justera resebilden';

  @override
  String get imageCropEditAction => 'Redigera beskärning';

  @override
  String get imageCropZoomIn => 'Zooma in';

  @override
  String get imageCropZoomOut => 'Zooma ut';

  @override
  String get imageCropZoomOnly => 'Bara den beskurna versionen av bilden sparades, så du kan bara zooma in.';

  @override
  String get imageCropLoadFailed => 'Det gick inte att öppna bilden.';

  @override
  String get imageCropSaveFailed => 'Det gick inte att spara den nya beskärningen. Försök igen.';

  @override
  String get imageCropChanged => 'Bilden har ändrats under tiden. Stäng den här skärmen och öppna den igen.';

  @override
  String get copyAction => 'Kopiera';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Brittiska pund';

  @override
  String get currencyNameChf => 'Schweizisk franc';

  @override
  String get currencyNameNok => 'Norska kronor';

  @override
  String get currencyNameSek => 'Svenska kronor';

  @override
  String get currencyNameDkk => 'Dansk krona';

  @override
  String get currencyNamePln => 'Polska zloty';

  @override
  String get currencyNameCzk => 'Tjeckisk koruna';

  @override
  String get currencyNameHuf => 'Ungersk forint';

  @override
  String get currencyNameRon => 'Rumänsk leu';

  @override
  String get currencyNameBgn => 'Bulgarisk lev';

  @override
  String get currencyNameIsk => 'Isländsk krona';

  @override
  String get currencyNameAll => 'Albansk lek';

  @override
  String get currencyNameBam => 'Bosnien och Hercegovina Mark';

  @override
  String get currencyNameByn => 'Vitrysk rubel';

  @override
  String get currencyNameMdl => 'Moldavisk leu';

  @override
  String get currencyNameMkd => 'Makedonsk denar';

  @override
  String get currencyNameRsd => 'Serbisk dinar';

  @override
  String get currencyNameUah => 'Ukrainsk hryvnia';

  @override
  String get currencyNameGel => 'Georgiska lari';

  @override
  String get currencyNameTry => 'Turkisk lira';

  @override
  String get currencyNameUsd => 'Amerikanska dollar';

  @override
  String get currencyNameJpy => 'Japanska yen';

  @override
  String get currencyNameCny => 'Kinesisk yuan';

  @override
  String get currencyNameCad => 'Kanadensisk dollar';

  @override
  String get currencyNameAud => 'Australisk dollar';

  @override
  String get currencyNameRub => 'Rysk rubel';

  @override
  String get currencyNameMxn => 'Mexikansk peso';

  @override
  String get currencyNameBrl => 'Brasiliansk real';

  @override
  String get currencyNameArs => 'Argentinsk peso';

  @override
  String get currencyNameClp => 'Chilensk peso';

  @override
  String get currencyNameCop => 'Colombiansk peso';

  @override
  String get currencyNamePen => 'Peruansk sol';

  @override
  String get currencyNameUyu => 'Uruguayansk peso';

  @override
  String get currencyNameBob => 'Boliviansk boliviano';

  @override
  String get currencyNamePyg => 'Paraguayansk guarani';

  @override
  String get currencyNameCrc => 'Costarikansk colón';

  @override
  String get currencyNameDop => 'Dominikansk peso';

  @override
  String get currencyNameGtq => 'Guatemalansk quetzal';

  @override
  String get currencyNamePab => 'Panamansk balboa';

  @override
  String get currencyNameHnl => 'Honduransk lempira';

  @override
  String get currencyNameNio => 'Nicaraguansk córdoba';

  @override
  String get currencyNameJmd => 'Jamaicansk dollar';

  @override
  String get currencyNameBbd => 'Barbadisk dollar';

  @override
  String get currencyNameBsd => 'Bahamansk dollar';

  @override
  String get currencyNameTtd => 'Trinidaddollar';

  @override
  String get currencyNameXcd => 'Östkaribisk dollar';

  @override
  String get currencyNameBzd => 'Belizisk dollar';

  @override
  String get currencyNameAwg => 'Arubansk florin';

  @override
  String get currencyNameBmd => 'Bermudisk dollar';

  @override
  String get currencyNameKyd => 'Caymansk dollar';

  @override
  String get currencyNameKrw => 'Sydkoreansk won';

  @override
  String get currencyNameInr => 'Indisk rupie';

  @override
  String get currencyNameThb => 'Thailändsk baht';

  @override
  String get currencyNameVnd => 'Vietnamesisk dong';

  @override
  String get currencyNameIdr => 'Indonesisk rupie';

  @override
  String get currencyNameMyr => 'Malaysisk ringgit';

  @override
  String get currencyNameSgd => 'Singaporiansk dollar';

  @override
  String get currencyNamePhp => 'Filippinsk peso';

  @override
  String get currencyNameHkd => 'Hongkongdollar';

  @override
  String get currencyNameTwd => 'Taiwanesisk dollar';

  @override
  String get currencyNameLkr => 'Srilankesisk rupie';

  @override
  String get currencyNameNpr => 'Nepalesisk rupie';

  @override
  String get currencyNameBdt => 'Bangladeshisk taka';

  @override
  String get currencyNamePkr => 'Pakistansk rupie';

  @override
  String get currencyNameKhr => 'Kambodjansk riel';

  @override
  String get currencyNameLak => 'Laotisk kip';

  @override
  String get currencyNameMmk => 'Myanmarisk kyat';

  @override
  String get currencyNameMnt => 'Mongolisk tögrög';

  @override
  String get currencyNameMop => 'Makanesisk pataca';

  @override
  String get currencyNameBnd => 'Bruneisk dollar';

  @override
  String get currencyNameMvr => 'Maldivisk rufiyaa';

  @override
  String get currencyNameBtn => 'Bhutanesisk ngultrum';

  @override
  String get currencyNameKzt => 'Kazakisk tenge';

  @override
  String get currencyNameUzs => 'Uzbekisk sum';

  @override
  String get currencyNameKgs => 'Kirgizisk som';

  @override
  String get currencyNameTjs => 'Tadzjikisk somoni';

  @override
  String get currencyNameAzn => 'Azerbajdzjansk manat';

  @override
  String get currencyNameAmd => 'Armenisk dram';

  @override
  String get currencyNameAed => 'Emiratisk dirham';

  @override
  String get currencyNameSar => 'Saudisk riyal';

  @override
  String get currencyNameQar => 'Qatarisk rial';

  @override
  String get currencyNameOmr => 'Omansk rial';

  @override
  String get currencyNameKwd => 'Kuwaitisk dinar';

  @override
  String get currencyNameBhd => 'Bahrainsk dinar';

  @override
  String get currencyNameJod => 'Jordansk dinar';

  @override
  String get currencyNameIls => 'Israelisk ny shekel';

  @override
  String get currencyNameLbp => 'Libanesiskt pund';

  @override
  String get currencyNameIqd => 'Irakisk dinar';

  @override
  String get currencyNameZar => 'Sydafrikansk rand';

  @override
  String get currencyNameEgp => 'Egyptiskt pund';

  @override
  String get currencyNameMad => 'Marockansk dirham';

  @override
  String get currencyNameTnd => 'Tunisisk dinar';

  @override
  String get currencyNameDzd => 'Algerisk dinar';

  @override
  String get currencyNameKes => 'Kenyansk shilling';

  @override
  String get currencyNameTzs => 'Tanzanisk shilling';

  @override
  String get currencyNameUgx => 'Ugandisk shilling';

  @override
  String get currencyNameRwf => 'Rwandisk franc';

  @override
  String get currencyNameEtb => 'Etiopisk birr';

  @override
  String get currencyNameGhs => 'Ghanansk cedi';

  @override
  String get currencyNameNgn => 'Nigeriansk naira';

  @override
  String get currencyNameXof => 'Västafrikansk franc';

  @override
  String get currencyNameXaf => 'Centralafrikansk franc';

  @override
  String get currencyNameMur => 'Mauritisk rupie';

  @override
  String get currencyNameScr => 'Seychellisk rupie';

  @override
  String get currencyNameNad => 'Namibisk dollar';

  @override
  String get currencyNameBwp => 'Botswansk pula';

  @override
  String get currencyNameZmw => 'Zambisk kwacha';

  @override
  String get currencyNameMzn => 'Moçambikisk metical';

  @override
  String get currencyNameAoa => 'Angolansk kwanza';

  @override
  String get currencyNameMga => 'Madagaskisk ariary';

  @override
  String get currencyNameCve => 'Kapverdisk escudo';

  @override
  String get currencyNameGmd => 'Gambisk dalasi';

  @override
  String get currencyNameNzd => 'Nyzeeländsk dollar';

  @override
  String get currencyNameFjd => 'Fijidollar';

  @override
  String get currencyNameXpf => 'CFP-franc';

  @override
  String get currencyNameWst => 'Västsamoansk tala';

  @override
  String get currencyNameVuv => 'Vanuatisk vatu';

  @override
  String get currencyNameTop => 'Tongansk paʻanga';

  @override
  String get currencyNamePgk => 'Papuansk kina';

  @override
  String get expenseCategoryFood => 'Mat';

  @override
  String get expenseCategoryGroceries => 'Livsmedel';

  @override
  String get expenseCategoryFuel => 'Bränsle';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryAccommodation => 'Boende';

  @override
  String get expenseCategoryActivities => 'Aktiviteter';

  @override
  String get expenseCategoryTickets => 'Biljetter';

  @override
  String get expenseCategoryShopping => 'Shopping';

  @override
  String get expenseCategoryParty => 'Fest';

  @override
  String get expenseCategoryParking => 'Parkering';

  @override
  String get expenseCategoryOther => 'Övrigt';

  @override
  String get shellTripAlreadyInListOpened => 'Resan finns redan i din lista. Vi har öppnat den åt dig.';

  @override
  String get shellJoinedTripFromInviteLink => 'Anslöt sig till resan via inbjudningslänken.';

  @override
  String get shellFailedToOpenInviteLink => 'Det gick inte att öppna inbjudningslänken.';

  @override
  String get shellFailedToOpenFriendLink => 'Det gick inte att öppna vänlänken.';

  @override
  String get shellTripInviteTitle => 'Reseinbjudan';

  @override
  String get shellNoAction => 'Nej';

  @override
  String get shellYesAction => 'Ja';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Endast resans skapare kan radera denna resa.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Endast aktiva resor kan raderas.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Ta bort ”$tripLabel”? Detta är endast tillåtet innan några utgifter har lagts till.';
  }

  @override
  String get shellTripDeleted => 'Resan har raderats.';

  @override
  String get shellFailedToDeleteTrip => 'Det gick inte att radera resan.';

  @override
  String get shellFailedToLoadNotifications => 'Det gick inte att ladda aviseringarna.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nytt meddelande: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Det gick inte att uppdatera aviseringarna.';

  @override
  String get shellMarkAllAsReadAction => 'Markera alla som lästa';

  @override
  String get shellNewSection => 'Ny';

  @override
  String get shellEarlierSection => 'Tidigare';

  @override
  String get shellShowMoreEarlierAction => 'Visa fler tidigare';

  @override
  String get shellLoadingMore => 'Laddar mer...';

  @override
  String get shellLoadMoreNotificationsAction => 'Ladda fler meddelanden';

  @override
  String get shellTripNoLongerAvailable => 'Denna resa är inte längre tillgänglig.';

  @override
  String get shellFailedToOpenTrip => 'Det gick inte att öppna resan.';

  @override
  String get shellYesterday => 'Igår';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Du är redan medlem i ”$tripName”. Vill du öppna denna resa nu?\n\nInbjuden av: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Vill du delta i resan ”$tripName”?\n\nInbjuden av: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Valad bild: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Resebild redan inställd.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Resan har skapats, men bilduppladdningen misslyckades.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Resan har skapats, men bilduppladdningen misslyckades: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Gå med i resan via inbjudan';

  @override
  String get tripsTotalTrips => 'Totalt antal resor';

  @override
  String get tripsTotalSpent => 'Totalt spenderat';

  @override
  String get tripsMixedCurrencies => 'Blandade valutor';

  @override
  String get tripsShowActive => 'Visa aktiva';

  @override
  String get tripsSeeAll => 'Visa alla';

  @override
  String get tripsGridView => 'Rutnätsvy';

  @override
  String get tripsListView => 'Listvy';

  @override
  String get tripsAddNewTrip => 'Lägg till ny resa';

  @override
  String get tripsLoadMore => 'Ladda mer';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Ta bort ”$arg1”? Detta är endast tillåtet innan några utgifter har lagts till.';
  }

  @override
  String get tripsTripDates => 'Resedatum';

  @override
  String get tripsFrom => 'Från';

  @override
  String get tripsSelectDate => 'Välj datum';

  @override
  String get tripsTo => 'Till';

  @override
  String get tripsMainCurrency => 'Huvudvaluta';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Välj reseperiod (start- och slutdatum).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Resans slutdatum måste vara på eller efter startdatumet.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Formatet för resans tidsperiod är ogiltigt. Välj datum på nytt.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Du är redan medlem i denna resa.';

  @override
  String get tripsJoinedTripSuccessfully => 'Du har anslutit dig till resan.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Det gick inte att ansluta sig till resan från inbjudan.';

  @override
  String get tripsJoinTrip => 'Gå med i resan';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Klistra in inbjudningslänken eller inbjudningstoken.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Ange en giltig inbjudningslänk eller ett giltigt token.';

  @override
  String get tripsClipboardIsEmpty => 'Urklipp är tomt.';

  @override
  String get tripsPaste => 'Klistra in';

  @override
  String get tripsJoin => 'Gå med';

  @override
  String get workspaceTripMembers => 'Resedeltagare';

  @override
  String get workspaceFailedToLoadFriends => 'Det gick inte att ladda vänner.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Det gick inte att skapa en inbjudningslänk.';

  @override
  String get workspaceInviteLink => 'Inbjudningslänk';

  @override
  String get workspaceGeneratingInviteLink => 'Skapar inbjudningslänk...';

  @override
  String get workspaceInviteLinkUnavailable => 'Inbjudningslänken är inte tillgänglig.';

  @override
  String get workspaceCopyInviteLink => 'Kopiera inbjudningslänken';

  @override
  String get workspaceInviteLinkCopied => 'Inbjudningslänken har kopierats.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Giltighetstid: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Inga vänner tillgängliga. Lägg till vänner först.';

  @override
  String get workspaceSettle => 'Avsluta';

  @override
  String get workspaceOwesToTheGroup => 'Skyldig gruppen';

  @override
  String get workspaceGetsBackFromGroup => 'Ska få pengar tillbaka från gruppen';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Visar de 4 bästa efter saldoskillnad.';

  @override
  String get workspaceOpenFlow => 'Detaljer';

  @override
  String get workspaceFriend => 'Vän';

  @override
  String get workspaceSettlementTransfer => 'Överföring av betalning';

  @override
  String get workspaceCompleted => 'Slutfört';

  @override
  String get workspaceWaitingForConfirmation => 'Väntar på bekräftelse';

  @override
  String get workspaceWaitingForPayment => 'Väntar på betalning';

  @override
  String get workspaceActionNeeded => 'Åtgärd krävs';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Betalningar att markera som skickade: $arg1; att bekräfta som mottagna: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Redo att reglera';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Alla deltagare är redo. Du kan påbörja avräkningen.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Väntar på att alla ska markera sig som redo.';

  @override
  String get workspaceIMReady => 'Jag är redo';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Kontrollera att du har lagt till alla dina utgifter.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Knappen ”Avsluta” låses upp när alla har markerat att de är redo.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Ska få pengar tillbaka från gruppen';

  @override
  String get workspaceSettledWithTheGroup => 'Överenskommet med gruppen';

  @override
  String get workspaceTotalPaid => 'Totalt betalt';

  @override
  String get workspaceTotalOwes => 'Totalt belopp att betala';

  @override
  String get workspaceTransactionHistory => 'Transaktionshistorik';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Inga transaktioner ännu för denna medlem.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Avräkningar: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Alla deltagare måste markera sig som redo innan avräkningen påbörjas.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Du har markerat dig själv som redo att betala.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Markeringen ”Redo att reglera” har tagits bort.';

  @override
  String get workspaceReminderSent => 'Påminnelse skickad.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Inbjudningslänk eller lägg till från vänner';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Endast resans skapare kan redigera denna resa.';

  @override
  String get workspaceTripUpdated => 'Resan har uppdaterats.';

  @override
  String get workspaceFailedToUpdateTrip => 'Det gick inte att uppdatera resan.';

  @override
  String get workspaceNoMembersSelectedYet => 'Inga medlemmar har valts ut ännu.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Inget internet. Utgiften sparas utan bild på kvittot.';

  @override
  String get workspaceRandomPicker => 'Slumpval';

  @override
  String get workspaceCurrency => 'Valuta';

  @override
  String get workspaceCategory => 'Kategori';

  @override
  String get workspaceCustomCategory => 'Anpassad kategori';

  @override
  String get workspaceCategoryName => 'Kategorinamn';

  @override
  String get workspaceApartmentRentParkingEtc => 'Hyra för lägenhet, parkering m.m.';

  @override
  String get workspaceEnterACustomCategory => 'Ange en anpassad kategori.';

  @override
  String get workspacePickAnExpenseCategory => 'Välj en utgiftskategori.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Kategorin måste bestå av minst 2 tecken.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Kategorin får innehålla upp till 64 tecken.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Procentfördelningen måste summera till 100 %.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Antalet andelar måste vara större än 0 för varje deltagare.';

  @override
  String get workspaceTotalAmount => 'Totalt belopp';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Total kostnad';

  @override
  String workspaceStarted(Object arg1) {
    return 'Startad $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Avslutad $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Arkiverad resa';

  @override
  String get workspaceActiveTrip => 'Aktiv resa';

  @override
  String get workspaceMemberProfile => 'Medlemsprofil';

  @override
  String get workspaceTripOwner => 'Resans ägare';

  @override
  String get workspaceMember => 'Medlem';

  @override
  String get workspaceReadyForSettlement => 'Redo för avräkning';

  @override
  String get workspaceNotReadyForSettlement => 'Inte redo för avräkning';

  @override
  String get workspaceBankDetails => 'Bankuppgifter';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN och utbetalningsuppgifter kommer att läggas till här i en kommande uppdatering.';

  @override
  String get workspacePaymentDetails => 'Betalningsuppgifter';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Denna medlem har ännu inte lagt till utbetalningsuppgifter.';

  @override
  String get workspaceBankTransfer => 'Banköverföring';

  @override
  String get workspaceHolder => 'Innehavare';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Det gick inte att öppna betalningslänken.';

  @override
  String get workspaceTripActivity => 'Resaktivitet';

  @override
  String get workspacePaidExpenses => 'Betalda utgifter';

  @override
  String get workspacePaidTotal => 'Betalt totalbelopp';

  @override
  String get workspaceInvolvedIn => 'Inblandad i';

  @override
  String get workspaceCurrentTrip => 'Aktuell resa';

  @override
  String get workspaceCommonTrips => 'Gemensamma resor';

  @override
  String get workspaceLoadingCommonTrips => 'Laddar gemensamma resor…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Inga gemensamma resor hittades ännu.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Alla gemensamma resor kunde inte laddas. Den aktuella resan visas.';

  @override
  String get workspaceMembers => 'medlemmar';

  @override
  String get workspaceExpense => 'Utgifter';

  @override
  String get workspacePaid => 'betald';

  @override
  String get workspaceLoadingMoreExpenses => 'Laddar fler utgifter...';

  @override
  String get workspaceScrollDownToLoadMore => 'Bläddra nedåt för att ladda mer';

  @override
  String get workspaceTripFinished => 'Resan är avslutad';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Betalningar är aktiverade för denna resa.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Avsluta resan för att påbörja avräkningen.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 har markerat överföringen som skickad.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Väntar på att $arg1 ska markera som betalt.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 har bekräftat mottagandet av betalningen.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Väntar på att $arg1 ska bekräfta.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Alla reseräkningar är fullständigt avslutade.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Slutligt tillstånd efter att alla överföringar har bekräftats.';

  @override
  String get workspaceSettlementFlow => 'Betalningsflöde';

  @override
  String get workspaceActions => 'Åtgärder';

  @override
  String get workspaceQuickPay => 'Snabbutbetalning';

  @override
  String get workspacePayWithRevolut => 'Betala med Revolut';

  @override
  String get workspacePayWithPaypal => 'Betala med PayPal';

  @override
  String get workspacePayWithWise => 'Betala med Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Överföringen är bekräftad.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Väntar på att den andra deltagaren ska slutföra nästa steg.';

  @override
  String get workspaceSendReminder => 'Skicka påminnelse';

  @override
  String get workspaceInProgress => 'Pågår';

  @override
  String get workspaceTimeUnknown => 'Tid okänd';

  @override
  String get workspaceRemind => 'Påminnelse';

  @override
  String get workspaceYourPosition => 'Din ståndpunkt';

  @override
  String get workspaceRecentActivity => 'Senaste aktivitet';

  @override
  String get workspaceNoRecentActivityYet => 'Ingen aktivitet på senare tid ännu.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Lägg till minst en deltagare för att börja dela på utgifterna.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Markera dig som redo att göra upp räkningen efter att du har lagt till alla dina utgifter.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Deltagare som inte är redo än: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Alla deltagare är redo. Du kan avsluta resan och påbörja avräkningen.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Alla deltagare är redo. Väntar på att resans arrangör ska påbörja avräkningen.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Avräkning pågår: $arg1/$arg2 bekräftat.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Inga åtgärder väntar. Denna resa är avslutad.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Inga åtgärder behövs just nu.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Du bör få $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Du bör betala $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Du är för närvarande anmäld till denna resa.';

  @override
  String get workspaceUnknownTime => 'Okänd tid';

  @override
  String get workspaceJustNow => 'Just nu';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'För $arg1 min sedan';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'För $arg1 h sedan';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'För $arg1 d sedan';
  }

  @override
  String get friendsRemoveFriend => 'Ta bort vän';

  @override
  String get friendsRemoveThisFriend => 'Ta bort denna vän?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 kommer att tas bort från din vänlista. Du kan lägga till dem igen senare.';
  }

  @override
  String get friendsContinue => 'Fortsätt';

  @override
  String get friendsFriendRemoved => 'Vän borttagen.';

  @override
  String get friendsCouldNotRemoveFriend => 'Det gick inte att ta bort en vän.';

  @override
  String get friendsFriendProfile => 'Vänprofil';

  @override
  String get friendsMoreActions => 'Fler åtgärder';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Den här vännen har ännu inte lagt till utbetalningsuppgifter.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Det gick inte att ladda gemensamma resor just nu.';

  @override
  String get friendsFinished => 'Klart';

  @override
  String friendsTrip(Object arg1) {
    return 'Resa nr $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Medlemmar: $arg1';
  }

  @override
  String get friendsNoDate => 'Inget datum';

  @override
  String get friendsIncomingRequests => 'INKOMMANDE FÖRFRÅGNINGAR';

  @override
  String get friendsSentInvites => 'SKICKADE INBJUDNINGAR';

  @override
  String get friendsMyFriends => 'MINA VÄNNER';

  @override
  String get friendsRequests => 'Förfrågningar';

  @override
  String get friendsIncoming => 'Inkommande';

  @override
  String get friendsIncomingRequestSubtitle => 'vill bli vänner';

  @override
  String get friendsOutgoingInviteSubtitle => 'Inbjudan skickad';

  @override
  String get friendsNoPendingActivity => 'Inga vänförfrågningar';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Inbjudan skickad till $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Inga inkommande förfrågningar';

  @override
  String get friendsDecline => 'Avvisa';

  @override
  String get friendsAccept => 'Godkänn';

  @override
  String get friendsNoSentInvites => 'Inga skickade inbjudningar';

  @override
  String get friendsNoFriendsYet => 'Inga vänner ännu';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Bläddra nedåt för att ladda fler vänner.';

  @override
  String get friendsUser => 'Användare';

  @override
  String get friendsSearchUsers => 'Sök efter användare';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Sök efter namn eller e-postadress och skicka en inbjudan';

  @override
  String get friendsScanQr => 'Skanna QR-koden';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Skanna en annan användare för att lägga till en vän';

  @override
  String get friendsMyQr => 'Min QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Visa eller dela din QR-kod';

  @override
  String get friendsScanFriendQrTitle => 'Skanna väns QR-kod';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Placera vännens QR-kod inuti ramen';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Håll QR-koden inom ramen';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Vill du lägga till $arg1 som vän?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 kommer att få din vänförfrågan.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Ska ${arg1}s vänförfrågan godkännas?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Skanna denna QR-kod eller dela länken för att lägga till mig på Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Lägg till mig på Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Splyto-vänlänk';

  @override
  String get shareAction => 'Dela';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'En QR-kod är inte en giltig vänkod.';

  @override
  String get friendsYouCannotAddYourself => 'Du kan inte lägga till dig själv.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Den här användaren finns redan i din vänlista.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Inbjudan till denna användare har redan skickats.';

  @override
  String get friendsFriendRequestProcessed => 'Vänförfrågan behandlad.';

  @override
  String get friendsFailedToProcessFriendQr => 'Det gick inte att bearbeta vänens QR-kod.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Det gick inte att ladda din användarprofil.';

  @override
  String get friendsMyProfile => 'Min profil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Oväntat fel vid inläsning av vänner.';

  @override
  String get friendsFriendAdded => 'Vän tillagd.';

  @override
  String get friendsRequestDeclined => 'Begäran avslagen.';

  @override
  String get friendsFailedToUpdateRequest => 'Det gick inte att uppdatera begäran.';

  @override
  String get friendsCancelInvite => 'Avbryt inbjudan';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Avbryta inbjudan till $arg1?';
  }

  @override
  String get friendsKeep => 'Behåll';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Inbjudan till $arg1 har avbrutits.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Det gick inte att avboka inbjudan.';

  @override
  String get analyticsOther => 'Övrigt';

  @override
  String get analyticsSelectATripForAnalytics => 'Välj en resa för analys';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Medlemmar: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Dagliga utgifter';

  @override
  String get analyticsMyDaily => 'Mina dagliga utgifter';

  @override
  String get analyticsGroupDaily => 'Gruppens dagliga utgifter';

  @override
  String get analyticsByMember => 'Per deltagare';

  @override
  String get analyticsShowLess => 'Visa mindre';

  @override
  String get analyticsByCategory => 'Efter kategori';

  @override
  String get analyticsQuickInsights => 'Snabba insikter';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Största utgiften: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Största utgiftsansvarig: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Gruppens högsta dag: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Inga datum';

  @override
  String get friendsSearchFailedTryAgain => 'Sökningen misslyckades. Försök igen.';

  @override
  String get friendsFailedToSendInvite => 'Det gick inte att skicka inbjudan.';

  @override
  String get friendsAddFriend => 'Lägg till vän';

  @override
  String get friendsSearchByNameOrEmail => 'Sök efter namn eller e-postadress';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Skriv minst 2 tecken för att söka.';

  @override
  String get friendsNoUsersFound => 'Inga användare hittades';

  @override
  String get friendsInviteAction => 'Bjud in';

  @override
  String get workspacePaidForGroup => 'Betalt för gruppen';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Betalt för gruppen • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Kostnadsdelning';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Kostnadsdelning • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Innehavarens namn har kopierats.';

  @override
  String get paymentIbanCopied => 'IBAN har kopierats.';

  @override
  String get paymentSwiftCopied => 'SWIFT kopierat.';

  @override
  String get paymentRevtagCopied => 'Revtag kopierad.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Det gick inte att kopiera till urklipp.';

  @override
  String get paymentCopied => 'Kopierat.';

  @override
  String get paymentRequestAction => 'Begär betalning';

  @override
  String get paymentRecordAction => 'Registrera betalning';

  @override
  String get paymentRequestSheetTitle => 'Begär betalning';

  @override
  String get paymentRecordSheetTitle => 'Registrera betalning';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Be $arg1 att betala ett belopp som hen för närvarande är skyldig dig.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Använd detta efter att du har betalat $arg1 utanför Splyto. De kommer att bekräfta mottagandet.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Maximalt $arg1';
  }

  @override
  String get paymentNoteHint => 'Banköverföring, Revolut, kontanter...';

  @override
  String get paymentAmountPositiveError => 'Beloppet måste vara större än noll.';

  @override
  String get paymentAmountTooHighError => 'Beloppet får inte överstiga det utestående saldot.';

  @override
  String get paymentRequestCreated => 'Betalningsförfrågan skickad.';

  @override
  String get paymentRecordedWaiting => 'Betalning registrerad. Väntar på bekräftelse.';

  @override
  String get paymentConfirmTitle => 'Bekräfta betalning';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Bekräfta att du har mottagit $arg1 från $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Betalning bekräftad.';

  @override
  String get paymentCancelRecordTitle => 'Avbryt betalningsregistrering';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Avbryta registreringen av din betalning på $arg1 till $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Betalningsposten har annullerats.';

  @override
  String get paymentNotReceivedTitle => 'Betalning ej mottagen';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Markera betalningen $arg1 från $arg2 som ej mottagen?';
  }

  @override
  String get paymentMarkedNotReceived => 'Betalningen har markerats som ej mottagen.';

  @override
  String get paymentActivityTitle => 'Betalningsaktivitet';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Öppna betalningsbegäranden: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Betalningar som väntar på bekräftelse: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Registrerade betalningar';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 begärde betalning från $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 betalade $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Betalning begärs';

  @override
  String get paymentAwaitingConfirmationStatus => 'Väntar på bekräftelse';

  @override
  String get paymentReviewRequestAction => 'Granska begäran';

  @override
  String get paymentViewDetailsAction => 'Betalningsuppgifter';

  @override
  String get paymentMarkPaidAction => 'Jag har betalat';

  @override
  String get paymentDeclineAction => 'Avvisa';

  @override
  String get paymentRequestReviewTitle => 'Betalningsförfrågan';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 har begärt $arg2 från dig. Betala utanför Splyto och markera sedan betalningen som genomförd.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Markera begäran som betald?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Bekräfta först efter att du har betalat $arg1 till $arg2 utanför Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Markerad som betald. Väntar på bekräftelse.';

  @override
  String get paymentRequestCancelTitle => 'Avbryta betalningsbegäran?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Vill du avbryta din $arg1-förfrågan till $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Betalningsförfrågan avbruten.';

  @override
  String get paymentRequestDeclineTitle => 'Avvisa betalningsförfrågan?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Avböja betalningsbegäran på $arg1 från $arg2? Personen får ett meddelande.';
  }

  @override
  String get paymentRequestDeclined => 'Betalningsförfrågan avvisad.';

  @override
  String get paymentPendingBeforeFinish => 'Lös öppna betalningsförfrågningar och obekräftade betalningar innan den slutliga avräkningen.';

  @override
  String get paymentFinishBlockedByPending => 'Avslutningen låses upp efter att betalningsförfrågningar och obekräftade betalningar har lösts.';

  @override
  String get notificationPaymentRequestedTitle => 'Betalning begärs';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 har begärt $arg2 från dig.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Du har fått en betalningsförfrågan.';

  @override
  String get notificationPaymentRequestSentTitle => 'Begärd betalning skickad';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 har markerat din $arg2-betalningsförfrågan som betald.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Din betalningsförfrågan har markerats som betald.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Betalningsförfrågan avbruten';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 har avbrutit betalningsförfrågan för $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'En betalningsförfrågan har avbrutits.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Betalningsförfrågan avvisad';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 har avvisat din $arg2-betalningsförfrågan.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Din betalningsförfrågan har avvisats.';

  @override
  String get notificationPaymentSentTitle => 'Betalning markerad som skickad';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 har markerat $arg2 som betalt till dig.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'En betalning har markerats som skickad till dig.';

  @override
  String get notificationPaymentConfirmedTitle => 'Betalning bekräftad';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 har bekräftat mottagandet av $arg2 från dig.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Din betalning har bekräftats.';

  @override
  String get notificationPaymentCancelledTitle => 'Betalningen har avbrutits';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 har avmarkerat betalningen för $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'En betalningsmarkering har avbrutits.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Betalning ej mottagen';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 har markerat betalningen $arg2 som ej mottagen.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'En betalning har markerats som ej mottagen.';

  @override
  String get quickStartTitle => 'Snabbstart';

  @override
  String get quickStartCreateTitle => 'Själv eller med vänner';

  @override
  String get quickStartCreateBody => 'Skapa en resa för dig själv eller en grupp. Lägg till vänner med länk eller QR-kod och bjud in dem.';

  @override
  String get quickStartInviteTitle => 'Res tillsammans eller på egen hand';

  @override
  String get quickStartInviteBody => 'Bjud in vänner att dela din resa, eller starta en personlig resa på egen hand.';

  @override
  String get quickStartExpenseTitle => 'Utgifter i många valutor';

  @override
  String get quickStartExpenseBody => 'Välj vem som betalade och hur det delas. Andra valutor räknas om till kursen på köpdatumet, även om du lägger till dem senare.';

  @override
  String get quickStartSettleTitle => 'Gör upp enkelt';

  @override
  String get quickStartSettleBody => 'Se vem som är skyldig vem, betala som du vill och bekräfta i appen.';

  @override
  String get quickStartAnalyticsTitle => 'Budget och utgifter';

  @override
  String get quickStartAnalyticsBody => 'Ange en budget för resan eller gruppen och se utgifter per kategori, resa och dag.';

  @override
  String get quickStartMapTitle => 'Spara dina platser';

  @override
  String get quickStartMapBody => 'Lägg till städer du besökt på din privata resekarta. Bara du kan se den.';

  @override
  String get quickStartLiveTitle => 'Hitta varandra';

  @override
  String get quickStartLiveBody => 'På gruppresor delar du din position live under den tid du väljer. Resans deltagare kan se den och du kan sluta när som helst.';

  @override
  String get quickStartNext => 'Nästa';

  @override
  String get quickStartBack => 'Tillbaka';

  @override
  String get quickStartSkip => 'Hoppa över';

  @override
  String get quickStartCreateAction => 'Skapa resa';

  @override
  String get quickStartSignUpAction => 'Registrera dig';

  @override
  String get quickStartClose => 'Stäng snabbstart';

  @override
  String get quickStartSubtitle => 'Se hur resor och utgifter fungerar';

  @override
  String quickStartStep(int step, int total) {
    return 'Steg $step av $total';
  }

  @override
  String get workspaceTripTotal => 'Resans totalsumma';

  @override
  String get workspacePersonalTotal => 'Totalt spenderat';

  @override
  String get workspaceBalanceEven => 'Ditt saldo är balanserat';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Du är skyldig $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Du får tillbaka $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Medlemmar: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Sök efter utgifter';

  @override
  String get workspaceClearSearch => 'Töm sökningen';

  @override
  String get workspaceSearchLoadedHint => 'Sökningen omfattar inlagda utgifter. Lägg till fler för att inkludera äldre utgifter.';

  @override
  String get workspaceNoExpenseMatches => 'Inga matchande utgifter';

  @override
  String get workspaceNoExpenseMatchesBody => 'Prova en annan sökning eller rensa sökningen för att se alla inlästa utgifter.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Lägg till din första utgift för att börja spåra dina utgifter.';

  @override
  String get workspaceEmptyGroupExpenses => 'Lägg till din första delade utgift för att se allas andel.';

  @override
  String get workspaceLoadMoreExpenses => 'Ladda fler utgifter';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Ursprungligt belopp: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Kommentarer: $count';
  }

  @override
  String get workspaceExpenseActions => 'Åtgärder rörande utgifter';

  @override
  String get workspaceLoadErrorTitle => 'Det gick inte att ladda denna resa';

  @override
  String get workspaceCachedWarning => 'Visning av sparade uppgifter. Dessa kan vara inaktuella.';

  @override
  String get workspaceActivityTab => 'Aktivitet';

  @override
  String get workspaceLoadingTrip => 'Laddar resa';

  @override
  String get workspaceRefreshFailed => 'Uppdateringen misslyckades';

  @override
  String get expenseDetailsTitle => 'Uppgifter om utgifter';

  @override
  String get expenseQuickCategories => 'Snabbkategorier';

  @override
  String get expenseReceiptUploading => 'Laddar upp kvittot…';

  @override
  String get expenseReceiptUploadOnSave => 'Kvittot laddas upp när du sparar.';

  @override
  String get expenseCommentsLoadFailed => 'Det gick inte att ladda kommentarerna. Försök igen.';

  @override
  String get expenseReplyAction => 'Svara';

  @override
  String get expenseReplyHint => 'Skriv ett svar…';

  @override
  String expenseReplyTo(String name) {
    return 'Svara till $name';
  }

  @override
  String get balanceEmptyBody => 'Saldon visas efter att utgifter har lagts till.';

  @override
  String get balanceAfterPayments => 'Saldo inkluderar bekräftade betalningar.';

  @override
  String get balanceExpenseShare => 'Kostnadsdelning';

  @override
  String get balanceHistoryScope => 'Inlagda utgifter och bekräftade betalningar. Denna lista innehåller eventuellt inte hela resehistoriken.';

  @override
  String balancePaymentTo(String name) {
    return 'Betalning till $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Betalning från $name';
  }

  @override
  String get settlementEmptyActive => 'Markera alla som redo innan du påbörjar slutavräkningen.';

  @override
  String get settlementEmptyClosed => 'Inga överföringar anges för denna resa.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count av $total överföringar bekräftade';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count av $total medlemmar är redo';
  }

  @override
  String get settlementMemberReady => 'Klar';

  @override
  String get settlementMemberNotReady => 'Inte redo';

  @override
  String get settlementSuggested => 'Föreslagen överföring';

  @override
  String get activityLoadFailed => 'Det gick inte att uppdatera aktiviteten. Eventuella synliga poster kan vara inaktuella.';

  @override
  String get activityMember => 'Resedeltagare';

  @override
  String get friendsEmptyBody => 'Hitta en vän via namn eller e-post, eller använd en QR-kod.';

  @override
  String get friendsDeclineAction => 'Avvisa';

  @override
  String get friendsLoading => 'Laddar vänner';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Delade resor: $count';
  }

  @override
  String get memberActivityScope => 'Baserat på inlagda utgifter; detta täcker eventuellt inte hela resan.';

  @override
  String get sharedTripsLoadedLimit => 'Visar upp till 20 delade resor.';

  @override
  String get memberRemoveTitle => 'Ta bort medlem?';

  @override
  String memberRemoveBody(String name) {
    return 'Ta bort $name från denna resa? Detta är endast möjligt om personen inte har några utgifter, avräkningar eller saldon.';
  }

  @override
  String get memberRemoveAction => 'Ta bort från resan';

  @override
  String memberRemoved(String name) {
    return '$name har tagits bort från resan.';
  }

  @override
  String get profilePaymentNotAdded => 'Har inte lagts till ännu';

  @override
  String get friendRelationshipLabel => 'Vän';

  @override
  String get sharedTripsEmptyBody => 'Resor som ni båda deltar i kommer att visas här.';

  @override
  String get analyticsAllTrips => 'Alla resor';

  @override
  String get analyticsByTrip => 'Per resa';

  @override
  String get analyticsYourSpending => 'Dina utgifter';

  @override
  String get analyticsActiveArchived => 'Aktiva och arkiverade resor';

  @override
  String get analyticsTrips => 'Resor';

  @override
  String get analyticsAveragePerTrip => 'Genomsnitt per resa';

  @override
  String get analyticsPaidByMember => 'Betalas av medlemmen';

  @override
  String get analyticsYouPaid => 'Du betalade';

  @override
  String get analyticsYouGetBack => 'Du får tillbaka';

  @override
  String get analyticsYouOwe => 'Du är skyldig';

  @override
  String get analyticsPaidForOthers => 'Betalat för andra';

  @override
  String get analyticsOthersPaidForYou => 'Andra betalade för dig';

  @override
  String get analyticsParticipants => 'Deltagare';

  @override
  String get analyticsYourCategories => 'Dina utgifter per kategori';

  @override
  String get analyticsTripTotalByCategory => 'Resans totalsumma per kategori';

  @override
  String get analyticsLargestShares => 'Mina största kostnadsandelar';

  @override
  String get analyticsLargestExpenses => 'Största utgifterna';

  @override
  String get analyticsSpendingByTrip => 'Dina utgifter per resa';

  @override
  String get analyticsEmptyTitle => 'Inga utgifter ännu';

  @override
  String get analyticsEmptyBody => 'Dina utgifter visas här när du lägger till utgifter till en resa.';

  @override
  String get analyticsPeriodEmptyBody => 'Det finns inga kostnader för denna vy. Prova en annan resa eller period.';

  @override
  String get analyticsLoadFailed => 'Det gick inte att ladda hela utgiftsrapporten. Försök igen.';

  @override
  String get analyticsLastLoaded => 'Visar den senaste rapporten som laddats in utan problem.';

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
  String get tripOptionsTitle => 'Resalternativ';

  @override
  String get editTripAction => 'Redigera resa';

  @override
  String get deleteTripAction => 'Ta bort resa';

  @override
  String get inviteTripMembersAction => 'Bjud in deltagare';

  @override
  String get tripCoverPhoto => 'Omslagsbild';

  @override
  String get tripInviteLaterHint => 'Du kan bjuda in personer efter att du har skapat resan.';

  @override
  String get inviteClipboardFailed => 'Det gick inte att komma åt urklipp. Försök igen.';

  @override
  String get friendInviteToTrip => 'Bjud in till resa';

  @override
  String get friendChooseTrip => 'Välj en resa';

  @override
  String get friendNoInvitableTrips => 'Inga tillgängliga resor. Du kan bjuda in vänner till aktiva gruppresor som du administrerar, såvida de inte redan är medlemmar eller har en väntande inbjudan.';

  @override
  String get friendTripInviteSent => 'Inbjudan skickad.';

  @override
  String get friendTripUnavailable => 'Denna resa är inte längre tillgänglig för denna åtgärd. Uppdatera och försök igen.';

  @override
  String get friendTripActionFailed => 'Det gick inte att slutföra denna åtgärd. Försök igen.';

  @override
  String get profileContactDescription => 'Har du ett problem, ett förslag eller en fråga om Splyto? Skicka ett e-postmeddelande till oss – vi hjälper dig gärna.';

  @override
  String get profileContactEmailAction => 'Skriv ett e-postmeddelande';

  @override
  String get profileContactEmailUnavailable => 'Det gick inte att öppna e-postappen. Kopiera adressen och skriv till oss från din e-postapp.';

  @override
  String get profilePrivacyPolicy => 'Integritetspolicy';

  @override
  String get privacyLoadFailed => 'Det gick inte att ladda integritetspolicyn. Försök igen.';

  @override
  String get addReceiptAction => 'Lägg till kvitto';

  @override
  String get receiptPickFailed => 'Det gick inte att ladda kvittot. Försök igen.';

  @override
  String get receiptPhotoAccessDenied => 'Bevilja Splyto åtkomst till kameran eller fotobiblioteket i Inställningar och försök sedan igen.';

  @override
  String get receiptPhotoLabel => 'Foto av kvittot';

  @override
  String get replaceReceiptAction => 'Ersätt kvitto';

  @override
  String get removeReceiptAction => 'Ta bort kvittot';

  @override
  String get restoreReceiptAction => 'Återställ tidigare kvitto';

  @override
  String get expenseSplitBetween => 'Uppdelning mellan';

  @override
  String get expenseEditParticipants => 'Välj deltagare';

  @override
  String get expenseCustomSplit => 'Anpassad fördelning';

  @override
  String get expenseAdjustmentsLabel => 'Justeringar';

  @override
  String get expenseAdjustmentFieldLabel => '+ eller −';

  @override
  String get expenseAdjustmentsHint => 'Lägg till eller dra av för varje person. Resten delas lika.';

  @override
  String get expenseAdjustmentsMustFit => 'Justeringar får inte överstiga totalen, och ingen kan vara skyldig mindre än noll.';

  @override
  String get expenseItemsLabel => 'Artiklar';

  @override
  String get expenseAddItem => 'Lägg till artikel';

  @override
  String get expenseRemoveItem => 'Ta bort artikel';

  @override
  String get expenseItemName => 'Artikel';

  @override
  String get expenseItemExtra => 'Skatt eller dricks';

  @override
  String get expenseItemExtraHint => 'Delas i proportion till varje persons artiklar.';

  @override
  String get expenseItemsInvalid => 'Varje artikel behöver ett namn, ett belopp och minst en person.';

  @override
  String expenseItemsTotal(String total) {
    return 'Summa av artiklar: $total';
  }

  @override
  String expenseItemsMustMatchTotal(String total) {
    return 'Artiklarna måste bli $total totalt.';
  }

  @override
  String get tripGuestAddAction => 'Lägg till person utan appen';

  @override
  String get tripGuestNameLabel => 'Namn';

  @override
  String get tripGuestAddHint => 'Personen behöver inte appen. Du lägger in vad personen betalat och markerar betalningarna.';

  @override
  String get tripGuestBadge => 'Utan appen';

  @override
  String get tripGuestRenameAction => 'Ändra namn';

  @override
  String tripGuestAdded(String name) {
    return '$name har lagts till';
  }

  @override
  String expenseSplitAllocated(String amount) {
    return 'Hela $amount fördelat';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return '$amount kvar att dela';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount över totalbeloppet';
  }

  @override
  String get profilePaymentSharingTitle => 'Dela betalningsmetoder med mina resor';

  @override
  String get profilePaymentSharingDescription => 'Låt godkända deltagare i resor som jag skapar eller går med i se mina betalningsmetoder. Detta gäller både nuvarande och framtida resor. Du kan när som helst stänga av delningen för att förhindra fortsatt åtkomst.';

  @override
  String get memberPaymentDetailsNotShared => 'Betalningsmetoder delas inte eller är för närvarande otillgängliga.';

  @override
  String get homeTripInvitations => 'Reseinbjudningar';

  @override
  String get homeNoTripInvitations => 'Inga väntande reseinbjudningar';

  @override
  String get homeInvitationsLoadFailed => 'Det gick inte att ladda inbjudningarna. Försök igen.';

  @override
  String get homeInvitationResponseFailed => 'Det gick inte att svara på inbjudan. Försök igen.';

  @override
  String get homeTripShareFailed => 'Det gick inte att dela resan. Försök igen.';

  @override
  String get settleStillToReceive => 'Återstår att ta emot';

  @override
  String get settleStillToPay => 'Återstår att betala';

  @override
  String get settleEstimateCaption => 'Uppskattning baserad på aktuella utgifter. Beloppen kan ändras fram till resans slut.';

  @override
  String get settleOutstandingCaption => 'Väntar på betalning eller bekräftelse.';

  @override
  String get settleWaitingForYou => 'Väntar på att du ska markera dig som redo.';

  @override
  String get settleWhoPaysWhom => 'Vem betalar vem?';

  @override
  String get settlePreviewCaption => 'Förhandsgranskning · slutförs när resan avslutas';

  @override
  String get settleOpenPaymentCaption => 'Öppna en betalning för att se detaljer och tillgängliga åtgärder.';

  @override
  String get tripBudgetEnable => 'Ställ in en budget';

  @override
  String get tripBudgetSoloHint => 'Valfritt utgiftsmål för denna resa.';

  @override
  String get tripBudgetGroupHint => 'En gemensam budget för hela gruppen.';

  @override
  String get tripBudgetAmount => 'Budgetbelopp';

  @override
  String get tripBudgetInvalid => 'Ange ett belopp mellan 0,01 och 999999999,99, med upp till två decimaler.';

  @override
  String get tripBudgetTitle => 'Resebudget';

  @override
  String get tripBudgetGroupTitle => 'Gruppbudget';

  @override
  String get tripBudgetRemaining => 'Återstående';

  @override
  String get tripBudgetOver => 'Överskrider budgeten';

  @override
  String get tripBudgetSpent => 'Spent';

  @override
  String get tripBudgetLimit => 'Budget';

  @override
  String get travelMapTitle => 'Min resekarta';

  @override
  String get travelMapSubtitle => 'Besökta platser, bara för dig.';

  @override
  String get travelMapHere => 'Jag har varit här';

  @override
  String get travelMapAdd => 'Lägg till plats';

  @override
  String get travelMapSearch => 'Sök efter stad och land';

  @override
  String get travelMapSearchAction => 'Sök';

  @override
  String get travelMapSearchHint => 'Till exempel Lissabon, Portugal';

  @override
  String get travelMapEmpty => 'Ditt nästa minne börjar här';

  @override
  String get travelMapEmptyBody => 'Lägg till en stad du har besökt, eller checka in där du befinner dig just nu.';

  @override
  String get travelMapConfirm => 'Spara detta besök?';

  @override
  String get travelMapConfirmBody => 'Kontrollera staden och datumet innan du sparar det på din privata karta.';

  @override
  String get travelMapDate => 'Besöksdatum';

  @override
  String get travelMapSave => 'Spara på min karta';

  @override
  String get travelMapCancel => 'Avbryt';

  @override
  String get travelMapClose => 'Stäng';

  @override
  String get travelMapNoResults => 'Ingen stad hittades. Försök att lägga till landet i din sökning.';

  @override
  String get travelMapLookupError => 'Det gick inte att hitta staden. Kontrollera din anslutning eller lägg till en plats manuellt.';

  @override
  String get travelMapDenied => 'Åtkomst till platsinformation är avstängd. Du kan fortfarande lägga till en stad manuellt.';

  @override
  String get travelMapDisabled => 'Aktivera platstjänster eller lägg till en stad manuellt.';

  @override
  String get travelMapError => 'Det gick inte att ladda din resekarta. Försök igen.';

  @override
  String get travelMapSaveError => 'Det gick inte att spara besöket. Försök igen.';

  @override
  String get travelMapUnavailable => 'Resekartan behöver en serveruppdatering.';

  @override
  String get travelMapOffline => 'Offline · visar sparade platser';

  @override
  String get travelMapRetry => 'Försök igen';

  @override
  String get travelMapDelete => 'Ta bort besök';

  @override
  String get travelMapDeleteConfirm => 'Vill du ta bort detta besök från din privata karta?';

  @override
  String get travelMapFit => 'Visa alla platser';

  @override
  String get travelMapSaved => 'Besök sparade';

  @override
  String get travelMapVisited => 'Besökta';

  @override
  String get travelMapLimit => 'Din karta har nått 1 000 besök. Ta bort ett gammalt besök innan du lägger till ett nytt.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries länder',
      one: '$countries land',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities städer',
      one: '$cities stad',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count besök',
      one: '$count besök',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Resmål (valfritt)';

  @override
  String get travelAddDestination => 'Lägg till destination';

  @override
  String get travelRemoveDestination => 'Ta bort destination';

  @override
  String get travelFromTrip => 'Från en resa';

  @override
  String get travelChooseTrip => 'Välj en resa';

  @override
  String get travelNoTrips => 'Inga resor tillgängliga ännu. Du kan lägga till en plats manuellt.';

  @override
  String get travelAddToMap => 'Lägg till på min karta';

  @override
  String get travelTripConfirm => 'Spara endast platser som du faktiskt har besökt. Detta lägger till ett privat minne på din karta.';

  @override
  String get travelVisitTitle => 'Titel (valfritt)';

  @override
  String get travelAddPhoto => 'Lägg till en bild';

  @override
  String get travelChangePhoto => 'Ändra foto';

  @override
  String get travelRemovePhoto => 'Ta bort foto';

  @override
  String get travelPhotoError => 'Det gick inte att förbereda den här bilden. Välj en annan.';

  @override
  String get travelEditVisit => 'Redigera besök';

  @override
  String get travelOpenTrip => 'Öppen resa';

  @override
  String get travelPreviousVisit => 'Tidigare besök';

  @override
  String get travelNextVisit => 'Nästa besök';

  @override
  String get travelDuplicate => 'Detta besök finns redan på din karta.';

  @override
  String get liveMapTitle => 'Karta i realtid';

  @override
  String get liveShareTitle => 'Dela min position';

  @override
  String get liveConsent => 'Dela din exakta plats endast med godkända deltagare i den här resan under den tid du väljer. Delningen fortsätter i bakgrunden och du kan stoppa den när som helst.';

  @override
  String get liveBackgroundNote => 'Uppdateringar kan pausas utan internet eller om du tvingar appen att stängas. Endast den senaste positionen sparas; ingen ruttlogg registreras.';

  @override
  String get liveStart => 'Börja dela';

  @override
  String get liveStop => 'Sluta dela';

  @override
  String get liveNotification => 'Din position delas med din resa. Öppna Splyto för att avbryta delningen.';

  @override
  String get livePermissionError => 'Tillåt platsåtkomst i telefonens inställningar för att dela din plats.';

  @override
  String get liveStartError => 'Det gick inte att starta delningen. Kontrollera åtkomsten till platsinformation, internetanslutningen samt datum och tid på din telefon.';

  @override
  String get liveStopPending => 'Uppdateringarna har avbrutits. Väntar på internetanslutning för att ta bort din senaste position; den försvinner från kartan inom 2 minuter utan uppdateringar.';

  @override
  String get liveSharing => 'delar plats';

  @override
  String get liveUnavailable => 'Denna realtidskarta är inte tillgänglig. Gå tillbaka till resan och uppdatera.';

  @override
  String get liveMapLoadError => 'Kartan kunde inte laddas. Kontrollera din anslutning och öppna kartan igen.';

  @override
  String get liveLoadError => 'Det gick inte att uppdatera positionerna. Endast de senaste uppdateringarna visas.';

  @override
  String get liveFit => 'Visa alla på kartan';

  @override
  String get liveEmpty => 'Ingen delar sin aktuella position ännu.';

  @override
  String get liveRecent => 'Nyss uppdaterad';

  @override
  String get liveLastKnown => 'Senast uppdaterad';

  @override
  String get liveAccuracy => 'Noggrannhet';

  @override
  String get liveUntil => 'Dela tills';

  @override
  String get liveOtherSession => 'Startades i en annan session. Du kan stoppa den här.';

  @override
  String get liveUpdatesPaused => 'Uppdateringar pausade. Kontrollera åtkomst till platsinformation och internet.';

  @override
  String get livePrivateUntilShared => 'Din position förblir privat tills du väljer att dela den.';

  @override
  String get activityEventExpenseCreated => 'lade till en utgift';

  @override
  String get activityEventExpenseUpdated => 'uppdaterade en utgift';

  @override
  String get activityEventExpenseDeleted => 'raderade en utgift';

  @override
  String get activityEventExpenseCommentAdded => 'kommenterade en utgift';

  @override
  String get activityEventTripCreated => 'skapade resan';

  @override
  String get activityEventTripUpdated => 'uppdaterade resedetaljerna';

  @override
  String get activityEventTripRenamed => 'bytte namn på resan';

  @override
  String get activityEventTripCurrencyChanged => 'ändrade resans valuta';

  @override
  String get activityEventTripPhotoChanged => 'ändrade resans foto';

  @override
  String get activityEventTripBudgetChanged => 'ändrade resans budget';

  @override
  String get activityEventTripDestinationsChanged => 'ändrade resans resmål';

  @override
  String get activityEventTripMembersAdded => 'lade till deltagare';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'skickade inbjudningar: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'anslöt sig till resan';

  @override
  String get activityEventTripInvitationDeclined => 'avböjde reseinbjudan';

  @override
  String get activityEventTripInvitationRevoked => 'avbröt en reseinbjudan';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'tog bort $name från resan';
  }

  @override
  String get activityEventTripMemberLeft => 'lämnade resan';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'ändrade rollen för $name till $role';
  }

  @override
  String get activityEventTripMemberReady => 'markerade sig som redo för avräkning';

  @override
  String get activityEventTripMemberNotReady => 'markerade sig som inte redo';

  @override
  String get activityEventTripAllMembersReady => 'Alla deltagare är redo att reglera';

  @override
  String get activityEventTripFinished => 'avslutade resan';

  @override
  String get activityEventTripSettled => 'Alla överföringar är bekräftade, resan är reglerad';

  @override
  String get activityEventSettlementMarkedSent => 'markerade en överföring som skickad';

  @override
  String get activityEventSettlementConfirmed => 'bekräftade en överföring';

  @override
  String get activityEventSettlementSentCancelled => 'avbröt statusen ”skickad”';

  @override
  String get activityEventSettlementNotReceived => 'markerade en överföring som ej mottagen';

  @override
  String get activityEventSettlementReminderSent => 'skickade en påminnelse om betalning';

  @override
  String get activityEventPaymentMarkedSent => 'registrerade en betalning';

  @override
  String get activityEventPaymentRequested => 'begärde en betalning';

  @override
  String get activityEventPaymentRequestMarkedSent => 'markerade en begärd betalning som skickad';

  @override
  String get activityEventPaymentRequestCancelled => 'avbröt en betalningsförfrågan';

  @override
  String get activityEventPaymentRequestDeclined => 'avvisade en betalningsförfrågan';

  @override
  String get activityEventPaymentConfirmed => 'bekräftade en betalning';

  @override
  String get activityEventPaymentCancelled => 'avbröt en betalningspost';

  @override
  String get activityEventPaymentNotReceived => 'markerade en betalning som ej mottagen';

  @override
  String get activityEventUnknown => 'gjorde en ändring';

  @override
  String get privacyEnglishFallback => 'Integritetspolicyn finns för närvarande på engelska.';

  @override
  String get activityRoleAdmin => 'Admin';

  @override
  String get accountDeleteTitle => 'Ta bort konto';

  @override
  String get accountDeleteIntro => 'Bekräfta raderingen via e-post. Efter bekräftelsen går den inte att ångra.';

  @override
  String get accountDeleteConsequences => 'Radering är permanent. Din profil anonymiseras och åtkomsten till kontot tas bort. Delade rese- och utgiftsuppgifter sparas för andra medlemmar.';

  @override
  String get accountDeleteReasonsTitle => 'Vad kunde vi ha gjort bättre?';

  @override
  String get accountDeleteReasonsHint => 'Anledning (valfritt)';

  @override
  String get accountDeleteReasonNotUsing => 'Jag behöver inte längre Splyto för mina resor';

  @override
  String get accountDeleteReasonAnotherWay => 'Jag hanterar delade utgifter på ett annat sätt';

  @override
  String get accountDeleteReasonComplicated => 'Det kräver för mycket ansträngning att få saker gjorda';

  @override
  String get accountDeleteReasonTechnical => 'Jag har stött på buggar eller tekniska problem';

  @override
  String get accountDeleteReasonPrivacy => 'Jag vill helst ta bort mina kontouppgifter';

  @override
  String get accountDeleteReasonOther => 'Jag lämnar av en annan anledning';

  @override
  String get accountDeleteEmailStep => 'Nästa steg är bekräftelse via e-post.';

  @override
  String get accountDeletePasswordHint => 'Ange ditt nuvarande Splyto-lösenord för att begära bekräftelsemejlet. Ditt konto är fortfarande aktivt.';

  @override
  String get accountDeleteInboxTitle => 'Ett sista steg i din inkorg';

  @override
  String accountDeleteSentBody(String email) {
    return 'Bekräftelselänk skickad till $email.';
  }

  @override
  String get accountDeleteSentHint => 'Ditt konto förblir aktivt tills du bekräftar raderingen.';

  @override
  String get accountDeleteSending => 'Skicka bekräftelsemejl';

  @override
  String get friendsShowMore => 'Visa fler';

  @override
  String get tripReportTitle => 'Resrapport';

  @override
  String get tripReportDetailedTitle => 'Detaljerad resrapport';

  @override
  String get tripReportDates => 'Datum';

  @override
  String get tripReportDestinations => 'Resmål';

  @override
  String get tripReportTotalSpent => 'Totalt spenderat';

  @override
  String get tripReportExpenses => 'Utgifter';

  @override
  String get tripReportYouPaid => 'Du betalade';

  @override
  String get tripReportYourShare => 'Din andel';

  @override
  String get tripReportYourBalance => 'Ditt saldo';

  @override
  String get tripReportYourSettlements => 'Dina avräkningar';

  @override
  String tripReportYouPay(Object arg1) {
    return 'Du betalar $arg1';
  }

  @override
  String tripReportPaysYou(Object arg1) {
    return '$arg1 betalar dig';
  }

  @override
  String get tripReportStatus => 'Status';

  @override
  String get tripReportStatusPending => 'Väntar';

  @override
  String get tripReportStatusSent => 'Skickat';

  @override
  String get tripReportStatusConfirmed => 'Bekräftat';

  @override
  String get tripReportNoSettlements => 'Du har inget att avräkna.';

  @override
  String get tripReportByCategory => 'Utgifter per kategori';

  @override
  String get tripReportCategory => 'Kategori';

  @override
  String get tripReportAmount => 'Belopp';

  @override
  String get tripReportMembers => 'Medlemmar';

  @override
  String get tripReportMember => 'Medlem';

  @override
  String get tripReportPaid => 'Betalat';

  @override
  String get tripReportShare => 'Andel';

  @override
  String get tripReportBalance => 'Saldo';

  @override
  String get tripReportAllExpenses => 'Alla utgifter';

  @override
  String get tripReportDate => 'Datum';

  @override
  String get tripReportDescription => 'Beskrivning';

  @override
  String get tripReportPaidBy => 'Betalat av';

  @override
  String get tripReportOriginalAmount => 'Ursprungligt belopp';

  @override
  String get tripReportCurrency => 'Valuta';

  @override
  String get tripReportRate => 'Kurs';

  @override
  String get tripReportPayments => 'Betalningar';

  @override
  String get tripReportFrom => 'Från';

  @override
  String get tripReportTo => 'Till';

  @override
  String get tripReportFooter => 'Skapad med Splyto';

  @override
  String tripReportEmailSubject(Object arg1) {
    return 'Din resrapport: $arg1';
  }

  @override
  String get tripReportEmailTitle => 'Din resrapport är klar';

  @override
  String tripReportEmailGreeting(Object arg1) {
    return 'Hej $arg1,';
  }

  @override
  String tripReportEmailBody(Object arg1) {
    return '$arg1 är avslutad. Din rapport finns bifogad som pdf.';
  }

  @override
  String get tripReportEmailOptOut => 'Du kan stänga av de här mejlen i Profil, under Aviseringar.';

  @override
  String get tripReportEmailSetting => 'Resrapport via mejl';

  @override
  String get tripReportEmailSettingSubtitle => 'Få en sammanfattning som pdf när en resa avslutas.';

  @override
  String get tripExportAction => 'Exportera resedetaljer';

  @override
  String get tripExportPdf => 'Detaljerad pdf';

  @override
  String get tripExportCsv => 'Kalkylblad (CSV)';

  @override
  String get tripExportFailed => 'Det gick inte att skapa exporten. Försök igen.';

  @override
  String get yearSummaryTitle => 'Ditt resår';

  @override
  String get yearSummarySubtitle => 'Dina resor, platser och utgifter under året.';

  @override
  String yearSummaryEmpty(Object arg1) {
    return 'Inga avslutade resor $arg1.';
  }

  @override
  String get yearSummaryLoadFailed => 'Det gick inte att läsa in ditt resår.';

  @override
  String get yearSummaryTrips => 'Resor';

  @override
  String get yearSummaryDays => 'Dagar på resa';

  @override
  String get yearSummaryCountries => 'Länder';

  @override
  String get yearSummaryCities => 'Städer';

  @override
  String get yearSummarySpending => 'Dina utgifter';

  @override
  String get yearSummaryBiggestTrip => 'Största resan';

  @override
  String get yearSummaryTopCategory => 'Toppkategori';

  @override
  String get yearSummaryTopCompanion => 'Flest resor med';

  @override
  String yearSummaryTripsTogether(Object arg1) {
    return 'Resor tillsammans: $arg1';
  }

  @override
  String get yearSummaryPartial => 'Vissa belopp saknas eftersom ingen växelkurs fanns tillgänglig.';

  @override
  String get yearSummaryShare => 'Dela';

  @override
  String get yearSummaryShareFailed => 'Det gick inte att dela bilden.';

  @override
  String get yearSummaryRetry => 'Försök igen';

  @override
  String get notificationCommentAddedTitle => 'Ny kommentar på din utgift';

  @override
  String notificationCommentAddedBody(Object name, Object note) {
    return '$name kommenterade \"$note\".';
  }

  @override
  String notificationCommentAddedBodyGeneric(Object name) {
    return '$name kommenterade din utgift.';
  }

  @override
  String get profilePushCommentsTitle => 'Kommentarer och omnämnanden';

  @override
  String get profilePushCommentsSubtitle => 'Nya kommentarer på dina utgifter och omnämnanden av dig';

  @override
  String get profilePushTripInvitesTitle => 'Resinbjudningar och medlemmar';

  @override
  String get profilePushTripInvitesSubtitle => 'Inbjudningar och personer som går med i eller lämnar en resa';

  @override
  String get profilePushTripStatusTitle => 'Resans status';

  @override
  String get profilePushTripStatusSubtitle => 'Resan avslutad och redo att göras upp';

  @override
  String get profilePushPaymentRequestsTitle => 'Betalningsförfrågningar';

  @override
  String get profilePushPaymentRequestsSubtitle => 'Förfrågningar till dig, avböjda eller avbrutna';

  @override
  String get profilePushPaymentsTitle => 'Betalningar';

  @override
  String get profilePushPaymentsSubtitle => 'Betalningar markerade som skickade, bekräftade eller inte mottagna';

  @override
  String get profilePushRemindersTitle => 'Påminnelser';

  @override
  String get profilePushRemindersSubtitle => 'Påminnelser om obetalda skulder';

  @override
  String get notificationLiveLocationTitle => 'Liveplats delad';

  @override
  String notificationLiveLocationBody(Object name, Object trip) {
    return '$name började dela sin liveplats i \"$trip\".';
  }

  @override
  String get profilePushLocationTitle => 'Liveplats';

  @override
  String get profilePushLocationSubtitle => 'När någon i resan börjar dela sin plats';

  @override
  String get expenseSplitMethodTitle => 'Delningssätt';

  @override
  String get expenseSplitExactHint => 'Ange vad varje person betalar';

  @override
  String get expenseSplitPercentHint => 'Varje person betalar en procentandel';

  @override
  String get expenseSplitSharesHint => 'Dela i delar, t.ex. 2 : 1 : 1';

  @override
  String get expenseSplitAdjustmentHint => 'Lika delar, med plus eller minus per person';

  @override
  String get expenseSplitItemsHint => 'Var och en betalar sina egna poster';

  @override
  String get tripsSearchFriends => 'Sök vänner';

  @override
  String get expenseSplitEvenly => 'Dela lika';

  @override
  String expensePaidByName(Object name) {
    return '$name betalade';
  }

  @override
  String get workspaceChooseCategory => 'Välj kategori';

  @override
  String get workspaceExpenseFilters => 'Utgiftsfilter';

  @override
  String get workspaceClearFilters => 'Rensa filter';

  @override
  String get workspaceFiltersLoadedHint => 'Filtren gäller inlästa utgifter. Läs in fler för att inkludera äldre utgifter.';

  @override
  String get workspaceFiltersNoMatchesHint => 'Ändra eller rensa filtren för att se alla inlästa utgifter.';
}
