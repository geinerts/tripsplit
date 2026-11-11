// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get homeFirstTrip => 'Je eerste reis';

  @override
  String get homeYourShareAllTrips => 'Jouw aandeel in alle reizen';

  @override
  String get homeAllTime => 'Altijd';

  @override
  String get homeSolo => 'Solo';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personen',
      one: '$count persoon',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Reisacties: $name';
  }

  @override
  String get homeNoActiveTrips => 'Geen actieve reizen';

  @override
  String get homeNoArchivedTrips => 'Geen gearchiveerde reizen';

  @override
  String get homeLoadingTrips => 'Je reizen laden';

  @override
  String get homeLoadErrorTitle => 'Je reizen konden niet worden geladen';

  @override
  String get homeLoadErrorBody => 'Probeer het over een momentje nog eens.';

  @override
  String get homeOfflineTitle => 'Je bent offline';

  @override
  String get homeOfflineNoData => 'Je reizen zijn nog niet beschikbaar op dit apparaat.';

  @override
  String get homeOfflineCached => 'Offline. Opgeslagen reizen weergeven.';

  @override
  String get homeRefreshError => 'Kan niet vernieuwen. Toont eerder geladen reizen.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Mijn opgeslagen betaalgegevens delen met $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Alleen zolang dit verzoek in afwachting is van betaling. Het annuleren van het verzoek beëindigt de toegang.';

  @override
  String get paymentDetailsUnavailable => 'Betalingsgegevens zijn niet beschikbaar. Maak verbinding met het internet en controleer of het verzoek nog openstaat.';

  @override
  String get paymentDetailsRetry => 'Probeer het opnieuw';

  @override
  String get tripModeSolo => 'Alleen ik';

  @override
  String get tripModeGroup => 'Met anderen';

  @override
  String get premiumFree => 'Gratis';

  @override
  String get premiumStatusUnavailable => 'Status van het plan niet beschikbaar';

  @override
  String premiumGrantedUntil(String date) {
    return 'Premium verleend tot $date';
  }

  @override
  String get premiumBillingNotActive => 'Geen actief abonnement';

  @override
  String get premiumRefreshStatus => 'De status van het plan vernieuwen';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get activeStatus => 'Actief';

  @override
  String get activeTripPlural => 'actieve reizen';

  @override
  String get activeTripSingle => 'actieve reis';

  @override
  String get activeTrips => 'Actieve reizen';

  @override
  String get activitiesComingSoon => 'Het gedeelte ‘Activiteiten’ volgt binnenkort.';

  @override
  String get addAction => 'Toevoegen';

  @override
  String get addExpenseTitle => 'Uitgave toevoegen';

  @override
  String get addExpensesAction => 'Uitgaven toevoegen';

  @override
  String get addMembersAction => 'Leden toevoegen';

  @override
  String get addTripMembersTitle => 'Nodig reisdeelnemers uit';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uitnodigingen verstuurd',
      one: '$count uitnodiging verstuurd',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Uitnodiging voor de reis afgewezen.';

  @override
  String get tripInviteAction => 'Uitnodigen';

  @override
  String get tripInvitationsPending => 'In afwachting van een reactie';

  @override
  String get tripInvitationsRetry => 'Uitnodigingen zijn niet beschikbaar. Probeer het opnieuw';

  @override
  String get tripInvitationRevoke => 'Uitnodiging annuleren';

  @override
  String get tripInvitationRevokeFailed => 'Uitnodiging kon niet worden geannuleerd. Probeer het opnieuw.';

  @override
  String get tripInvitationBody => 'Je bent uitgenodigd voor een reis. Open de uitnodiging om te reageren.';

  @override
  String get allCaughtUp => 'Alles bijgewerkt';

  @override
  String get allFilter => 'Alle';

  @override
  String get allMembersLabel => 'Alle leden';

  @override
  String get allPaymentsConfirmed => 'Alle betalingen worden bevestigd.';

  @override
  String get allTrips => 'Alle reizen';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Bedrag';

  @override
  String get amountMustBeGreaterThanZero => 'Het bedrag moet groter zijn dan 0.';

  @override
  String get appearance => 'Uiterlijk';

  @override
  String get archivedStatus => 'Gearchiveerd';

  @override
  String get authSubtitleLogin => 'Deel reiskosten met vrienden';

  @override
  String get authSubtitleRegister => 'Maak een account aan en begin met het splitsen van reizen';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'bevestigd: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'in behandeling: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'verzonden: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'voorgesteld: $count';
  }

  @override
  String get cancelAction => 'Annuleren';

  @override
  String get changeEmailWithPasswordHelper => 'Voer je wachtwoord in om je e-mailadres te wijzigen.';

  @override
  String get chooseReceiptFile => 'Kies een ontvangstbewijsbestand';

  @override
  String get completeAccountSetupDescription => 'Stel je e-mailadres en wachtwoord in om je account aan te maken.';

  @override
  String get completeAccountSetupTitle => 'Voltooi de accountinstellingen';

  @override
  String get confirmReceivedAction => 'Ontvangst bevestigen';

  @override
  String get confirmedAllSettlementsArchived => 'Alle afrekeningen bevestigd. Reis gearchiveerd.';

  @override
  String get confirmedAsReceived => 'Ontvangst bevestigd.';

  @override
  String get confirmedLabel => 'Bevestigd';

  @override
  String get couldNotOpenReceiptLink => 'De link naar de ontvangstbevestiging kon niet worden geopend.';

  @override
  String get createAction => 'Aanmaken';

  @override
  String get createFirstTripHint => 'Maak je eerste reis aan om aan de slag te gaan.';

  @override
  String get createNewTripTitle => 'Maak een nieuwe reis aan';

  @override
  String get createTripAction => 'Reis aanmaken';

  @override
  String get createTripFirst => 'Maak eerst een reis aan.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date  -  Aangemaakt door $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'De reisorganisator moet de reis afronden om de afrekening te kunnen bevestigen.';

  @override
  String currentEmailLabel(Object email) {
    return 'Huidige e-mail: $email';
  }

  @override
  String get currentReceiptAttached => 'Het huidige ontvangstbewijs is bijgevoegd.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Datum';

  @override
  String get dateMustMatchFormat => 'De datum moet in de notatie YYYY-MM-DD worden opgegeven.';

  @override
  String get dateUnknown => 'Datum onbekend';

  @override
  String get deleteAction => 'Verwijderen';

  @override
  String get deleteExpenseConfirmQuestion => 'Deze uitgave verwijderen?';

  @override
  String get deleteExpenseTitle => 'Uitgave verwijderen';

  @override
  String get editExpenseConfirmTitle => 'Wijzigingen in uitgaven opslaan?';

  @override
  String get editExpenseConfirmText => 'Hierdoor worden de saldi voor iedereen in de reis bijgewerkt.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Direct uitgelegd aan de hand van uitgaven: $amount';
  }

  @override
  String get doneStatus => 'Klaar';

  @override
  String get editAction => 'Bewerken';

  @override
  String get editExpenseTitle => 'Uitgaven bewerken';

  @override
  String get emailAddressLabel => 'E-mailadres';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailRequired => 'Een e-mailadres is verplicht.';

  @override
  String get enterValidExactAmounts => 'Voer voor alle deelnemers geldige, exacte bedragen in.';

  @override
  String get enterValidPercentages => 'Voer geldige percentages in voor alle deelnemers.';

  @override
  String get equalSplitLabel => 'Gelijk verdelen';

  @override
  String exactAmountWithValue(Object value) {
    return 'Nauwkeurig: $value';
  }

  @override
  String get exactAmountsLabel => 'Exacte bedragen';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'De exacte verdeling moet in totaal $amount opleveren.';
  }

  @override
  String get expenseAdded => 'Kosten toegevoegd.';

  @override
  String get expenseBreakdownSubtitle => 'Hoe dit lid door elke uitgave wordt beïnvloed.';

  @override
  String get expenseBreakdownTitle => 'Uitsplitsing van uitgaven';

  @override
  String get expenseDeleted => 'Uitgave verwijderd.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Uitgave #$id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Betaald $paid  -  Schuldig $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reacties';

  @override
  String get expenseCommentsTitle => 'Opmerkingen';

  @override
  String get expenseNoComments => 'Nog geen reacties.';

  @override
  String get expenseAddCommentHint => 'Voeg een opmerking toe...';

  @override
  String get expenseCommentSend => 'Verzenden';

  @override
  String get expenseMentionNoMatches => 'Geen overeenkomende leden';

  @override
  String get expenseMentionMembersLabel => 'Reisleden om te noemen';

  @override
  String get expenseDeleteCommentTitle => 'Reactie verwijderen?';

  @override
  String get expenseUpdated => 'Uitgaven bijgewerkt.';

  @override
  String expenseWithId(Object id) {
    return 'Uitgave #$id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uitgaven',
      one: '$count uitgave',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Onkosten';

  @override
  String get failedToCreateTrip => 'Het aanmaken van de reis is mislukt.';

  @override
  String get failedToLoadUsersDirectory => 'Het laden van de gebruikerslijst is mislukt.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filter afrekeningen op deelnemer';

  @override
  String get finishSoloTripConfirmationText => 'Deze reis afronden en naar je archief verplaatsen? Je uitgaven blijven beschikbaar om in te zien.';

  @override
  String get soloTripArchived => 'Reis voltooid en gearchiveerd.';

  @override
  String get finishTripSyncPending => 'Synchroniseer je nog niet opgeslagen wijzigingen voordat je deze reis afrondt.';

  @override
  String get finishTripAction => 'Reis beëindigen';

  @override
  String get finishTripConfirmationText => 'Deze reis afronden en de afrekening starten?';

  @override
  String get finishTripStartSettlementsAction => 'Afrekeningen afronden en starten';

  @override
  String get finishTripTitle => 'Reis beëindigen';

  @override
  String forParticipants(Object participants) {
    return 'Voor: $participants';
  }

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get profileSetPassword => 'Wachtwoord instellen';

  @override
  String get profileManagePassword => 'Wachtwoord instellen of wijzigen';

  @override
  String get profilePasswordByEmail => 'Wachtwoord instellen via e-mail';

  @override
  String get passwordEmailBackToProfile => 'Terug naar profiel';

  @override
  String get forgotPasswordSubtitle => 'Voer je e-mailadres in en we sturen je een link om je wachtwoord opnieuw in te stellen.';

  @override
  String get forgotPasswordSuccessMessage => 'Als er een account met dit e-mailadres bestaat, hebben we een link voor het opnieuw instellen van het wachtwoord verzonden.';

  @override
  String get passwordResetSentTitle => 'Controleer je inbox';

  @override
  String get passwordResetSentHint => 'De link is 1 uur geldig. Zie je de e-mail niet, kijk dan in je spammap.';

  @override
  String get forgotPasswordTitle => 'Wachtwoord opnieuw instellen';

  @override
  String get friendsProgressSubtitle => 'Elk lid en de status van zijn of haar bevestiging.';

  @override
  String get friendsProgressTitle => 'Vrienden vorderen';

  @override
  String get friendsSectionComingSoon => 'De sectie ‘Vrienden’ komt binnenkort beschikbaar.';

  @override
  String fromDirection(Object name) {
    return 'Van $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from tot $to';
  }

  @override
  String get generateTurnAction => 'Volgende persoon loten';

  @override
  String get hasAccountQuestion => 'Heb je al een account?';

  @override
  String helloUser(Object name) {
    return 'Hallo, $name!';
  }

  @override
  String get iSentAction => 'Ik heb verzonden';

  @override
  String get invalidEmailFormat => 'Ongeldig e-mailformaat.';

  @override
  String get languageAction => 'Taal';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageLatvian => 'Lets';

  @override
  String get languageSpanish => 'Spaans';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get languageSystemSubtitle => 'Apparaattaal gebruiken';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Laat leeg om het huidige wachtwoord te behouden.';

  @override
  String get logInButton => 'Inloggen';

  @override
  String get logOutButton => 'Uitloggen';

  @override
  String get logoutFromDeviceQuestion => 'Uitloggen op dit apparaat?';

  @override
  String get logoutRevocationUnconfirmed => 'Uitgelogd op dit apparaat. Het intrekken van de serversessie kon niet worden bevestigd.';

  @override
  String get markedAsSent => 'Gemarkeerd als verzonden.';

  @override
  String get markSettlementSentConfirmTitle => 'Overboeking markeren als verzonden?';

  @override
  String get markSettlementSentConfirmText => 'Gebruik dit pas nadat je de betaling daadwerkelijk hebt verzonden. De ontvanger wordt gevraagd om te bevestigen.';

  @override
  String get settlementCancelSentAction => 'Markeer als niet verzonden';

  @override
  String get settlementCancelSentConfirmTitle => 'De status ‘verzonden’ annuleren?';

  @override
  String get settlementCancelSentConfirmText => 'Hierdoor wordt de overboeking weer op ‘in behandeling’ gezet en ontvangt de ontvanger hiervan een melding.';

  @override
  String get settlementSentCancelled => 'De overboeking is teruggezet naar ‘in behandeling’.';

  @override
  String get settlementNotReceivedAction => 'Ik heb dit niet ontvangen';

  @override
  String get settlementNotReceivedConfirmTitle => 'Niet-ontvangen betaling melden?';

  @override
  String get settlementNotReceivedConfirmText => 'Hierdoor wordt de overboeking weer naar ‘in behandeling’ gezet en wordt de betaler hiervan op de hoogte gesteld.';

  @override
  String get settlementMarkedNotReceived => 'Gemarkeerd als niet ontvangen.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Bevestiging ontvangen?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Bevestig pas nadat het geld op je rekening zichtbaar is. Deze handeling kan de afwikkeling voltooien.';

  @override
  String get memberSummariesSubtitle => 'Huidige saldi voor beide partijen.';

  @override
  String get memberSummariesTitle => 'Overzichten van leden';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Om te betalen $total  -  bevestigd $confirmed  -  in afwachting $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Geschatte financiële impact per deelnemer.';

  @override
  String get membersImpactTitle => 'Invloed van leden';

  @override
  String get membersIncludedInExpense => 'Inbegrepen leden';

  @override
  String get membersLabel => 'Leden';

  @override
  String moreCount(Object count) {
    return '+ $count meer';
  }

  @override
  String get myFilter => 'Mijn';

  @override
  String get myImpactTitle => 'Mijn impact';

  @override
  String get firstNameHint => 'Je voornaam';

  @override
  String get firstNameLabel => 'Voornaam';

  @override
  String get firstNameLengthValidation => 'De voornaam moet 2-64 tekens lang zijn.';

  @override
  String get fullNameHelper => 'Gebruik voor- en achternaam in één veld.';

  @override
  String get fullNameHint => 'bijv. Anna Ozolina';

  @override
  String get fullNameLabel => 'Volledige naam';

  @override
  String get fullNameValidation => 'Voer voor- en achternaam in (minimaal 2 tekens per naam).';

  @override
  String get lastNameHint => 'Je achternaam';

  @override
  String get lastNameLabel => 'Achternaam';

  @override
  String get lastNameLengthValidation => 'De achternaam moet uit 2 tot 64 tekens bestaan.';

  @override
  String get nameHint => 'Je naam';

  @override
  String get nameLabel => 'Naam';

  @override
  String get nameLengthValidation => 'De naam moet uit minimaal 2 tekens bestaan.';

  @override
  String get navActivities => 'Statistieken';

  @override
  String get navAddTrip => 'Reis toevoegen';

  @override
  String get navBalances => 'Saldi';

  @override
  String get navExpenses => 'Uitgaven';

  @override
  String get navFriends => 'Vrienden';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profiel';

  @override
  String get navRandom => 'Willekeurig';

  @override
  String get netLabel => 'Nettosaldo';

  @override
  String get newPasswordLabel => 'Nieuw wachtwoord';

  @override
  String get nicknameHint => 'Hoe vrienden je zullen zien';

  @override
  String get nicknameLabel => 'Bijnaam';

  @override
  String get nicknameLengthValidation => 'Een bijnaam moet uit minimaal 2 tekens bestaan.';

  @override
  String get noAccountQuestion => 'Nog geen account?';

  @override
  String get noBalancesYet => 'Er zijn nog geen saldi.';

  @override
  String get noChangesToSave => 'Geen wijzigingen om op te slaan.';

  @override
  String get noDirectExpenseLink => 'Er is geen directe link voor een enkele uitgave gevonden. Deze afrekening wordt berekend op basis van het volledige reissaldo.';

  @override
  String get noExpenseImpactForMember => 'Geen financiële gevolgen voor dit lid.';

  @override
  String noExpensesByUserYet(Object name) {
    return '$name heeft nog geen uitgaven.';
  }

  @override
  String get noExpensesYet => 'Nog geen uitgaven.';

  @override
  String get noExtraUsersToAdd => 'Er hoeven geen extra gebruikers te worden toegevoegd.';

  @override
  String get noInternetDeleteQueued => 'Geen internet. Uit wachtrij verwijderd.';

  @override
  String get noInternetExpenseQueued => 'Geen internet. Uitgave in de wachtrij geplaatst.';

  @override
  String get noInternetUpdateQueued => 'Geen internet. Update in de wachtrij.';

  @override
  String get noMatchingRows => 'Geen overeenkomende rijen.';

  @override
  String get noMembersFound => 'Er zijn geen leden gevonden.';

  @override
  String get noNewMembersAdded => 'Deze personen zijn al lid of hebben uitstaande uitnodigingen.';

  @override
  String get noNotePlaceholder => 'Geen opmerking';

  @override
  String get notificationsToday => 'Vandaag';

  @override
  String get notificationsEmptyBody => 'Updates over reizen, uitgaven en vrienden verschijnen hier.';

  @override
  String get notificationsCached => 'Offline — weergeven van opgeslagen meldingen.';

  @override
  String get notificationsRefreshFailed => 'Kan niet vernieuwen. Eerder geladen meldingen worden weergegeven.';

  @override
  String get notificationsJustNow => 'Zojuist';

  @override
  String notificationsMinutesAgo(int count) {
    return '$count min geleden';
  }

  @override
  String notificationsHoursAgo(int count) {
    return '$count uur geleden';
  }

  @override
  String get notificationsUnread => 'Ongelezen';

  @override
  String get noNotificationsYet => 'Nog geen meldingen.';

  @override
  String get noParticipantData => 'Geen deelnemersgegevens.';

  @override
  String get noParticipantsSelected => 'Er zijn geen deelnemers geselecteerd.';

  @override
  String get noPaymentRowsInTrip => 'Geen betalingsregels in deze reis.';

  @override
  String get noPaymentsNeeded => 'Er zijn geen betalingen nodig.';

  @override
  String get noPicksYet => 'Nog geen selecties.';

  @override
  String get noSettlementActivityForMember => 'Geen afrekeningsactiviteit voor dit lid.';

  @override
  String get noSettlementRowsYet => 'Nog geen afrekeningsregels.';

  @override
  String get noSettlements => 'Geen verrekeningen';

  @override
  String get noTransferNeededForFilter => 'Geen overboeking nodig voor het geselecteerde filter.';

  @override
  String get noTransferRowsToShow => 'Er zijn geen overboekingsregels om weer te geven.';

  @override
  String get noTripDataLoaded => 'Er zijn geen reisgegevens geladen.';

  @override
  String get noTripsYet => 'Nog geen reizen.';

  @override
  String get noUsersFoundYet => 'Er zijn nog geen gebruikers gevonden.';

  @override
  String get notSetValue => 'Niet ingesteld';

  @override
  String get notYetConfirmedTitle => 'Nog niet bevestigd';

  @override
  String get noteHint => 'Diner, taxi, kaartjes...';

  @override
  String get noteLabel => 'Opmerking';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'De notitie mag maximaal $max tekens bevatten.';
  }

  @override
  String get notificationFallbackTitle => 'Kennisgeving';

  @override
  String get notificationsTitle => 'Meldingen';

  @override
  String get notificationFriendInviteTitle => 'Vriendschapsverzoek';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name heeft je een uitnodiging gestuurd om vrienden te worden.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Je hebt een uitnodiging van een vriend ontvangen.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Uitnodiging geaccepteerd';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name heeft je vriendschapsverzoek geaccepteerd.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Je uitnodiging is geaccepteerd.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Uitnodiging afgewezen';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name heeft je vriendschapsverzoek afgewezen.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Je uitnodiging aan een vriend is afgewezen.';

  @override
  String get notificationTripAddedTitle => 'Toegevoegd aan reis';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name heeft je toegevoegd aan de reis \"$trip\".';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Je bent toegevoegd aan de reis \"$trip\".';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Je bent toegevoegd aan een reis.';

  @override
  String get notificationExpenseAddedTitle => 'Nieuwe uitgave toegevoegd';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name heeft een uitgave van $amount toegevoegd aan \"$trip\".';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name heeft een uitgave van $amount toegevoegd: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Er is een nieuwe uitgave toegevoegd.';

  @override
  String get notificationCommentMentionTitle => 'Je bent genoemd in een opmerking';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name heeft je genoemd in een opmerking bij \"$note\".';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name heeft je genoemd in een opmerking.';
  }

  @override
  String get notificationTripFinishedTitle => 'Reis voltooid';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name heeft \"$trip\" voltooid. De afrekeningen zijn klaar.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name heeft \"$trip\" voltooid. De reis is gearchiveerd.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '\"$trip\" is voltooid.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'De reisstatus is bijgewerkt.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Lid gemarkeerd als gereed';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name is klaar om deel te nemen aan \"$trip\".';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Een deelnemer is klaar om deel te nemen aan \"$trip\".';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Een deelnemer is klaar om af te rekenen.';

  @override
  String get notificationTripReadyToSettleTitle => 'Alle deelnemers zijn klaar';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Alle leden zijn gemarkeerd als ‘klaar’ in ‘$trip’. Je kunt beginnen met de afrekeningen.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Alle deelnemers zijn klaar. U kunt beginnen met de afrekeningen.';

  @override
  String get notificationSettlementReminderTitle => 'Herinnering aan afrekening';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor herinnerde $target eraan om $amount als verzonden te markeren.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor herinnerde $target eraan om de ontvangst van $amount te bevestigen.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Je hebt een herinnering voor de afrekening ontvangen.';

  @override
  String get notificationPaymentReminderTitle => 'Betalingsherinnering';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Herinnering: markeer $amount als verzonden naar $target in \"$trip\".';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Herinnering: markeer de betaling alstublieft als verzonden.';

  @override
  String get notificationConfirmationReminderTitle => 'Herinnering aan bevestiging';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Herinnering: bevestig alstublieft de ontvangst van $amount van $payer in \"$trip\".';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Herinnering: bevestig alstublieft de ontvangst van de betaling.';

  @override
  String get notificationSettlementSentTitle => 'Overschrijving gemarkeerd als verzonden';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name heeft $amount gemarkeerd als naar jou verzonden.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Een overschrijving is gemarkeerd als verzonden.';

  @override
  String get notificationSettlementConfirmedTitle => 'Overschrijving bevestigd';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name heeft de ontvangst van $amount van jou bevestigd.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Een overboeking is bevestigd.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wijzigingen in behandeling',
      one: '$count wijziging in behandeling',
    );
    return 'Offlinewachtrij: $_temp0';
  }

  @override
  String get syncAllSynced => 'Alles gesynchroniseerd';

  @override
  String syncChangesWaiting(Object count) {
    return '$count wachten op synchronisatie';
  }

  @override
  String get syncFailedTapToRetry => 'Synchronisatie mislukt, tik om het opnieuw te proberen';

  @override
  String get offlineQueueStatus => 'Offline wachtrij';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Alleen de reisorganisator kan de reis beëindigen.';

  @override
  String get openLabel => 'Open';

  @override
  String get openReceiptAction => 'Bon openen';

  @override
  String get openSettlements => 'Verrekeningen openen';

  @override
  String get overviewTitle => 'Overzicht';

  @override
  String get owesLabel => 'Verschuldigd';

  @override
  String get paidByLabel => 'Betaald door';

  @override
  String get paidLabel => 'Betaald';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Betaald $paid -  Schuldig $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Deelnemers (leeg = alle leden)';

  @override
  String get participantsTitle => 'Deelnemers';

  @override
  String get passwordLabel => 'Wachtwoord';

  @override
  String get passwordComplexityHelper => 'Gebruik ten minste 1 hoofdletter, 1 cijfer en 1 symbool.';

  @override
  String get passwordComplexityValidation => 'Het wachtwoord moet 1 hoofdletter, 1 cijfer en 1 symbool bevatten.';

  @override
  String get passwordMinLength => 'Het wachtwoord moet uit minimaal 8 tekens bestaan.';

  @override
  String get passwordMinLengthShort => 'Het wachtwoord moet uit minimaal 6 tekens bestaan.';

  @override
  String get passwordResetComingSoon => 'Wachtwoord opnieuw instellen volgt binnenkort.';

  @override
  String get passwordsDoNotMatch => 'De wachtwoorden komen niet overeen.';

  @override
  String payerName(Object name) {
    return '$name (betaler)';
  }

  @override
  String get pendingLabel => 'In afwachting';

  @override
  String get pendingPaymentsSubtitle => 'Betalingen wachten nog op volledige bevestiging.';

  @override
  String get percentLabel => 'Procent';

  @override
  String get percentSplitMustBe100 => 'Het percentage van de verdeling moet in totaal precies 100% bedragen.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Percentages';

  @override
  String get pickAtLeastOneParticipant => 'Kies ten minste één deelnemer.';

  @override
  String get pickMembersGenerateTurn => 'Kies deelnemers en loot de volgende persoon.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name, geselecteerd. Cyclus voltooid.';
  }

  @override
  String pickedUser(Object name) {
    return '$name, gekozen.';
  }

  @override
  String get profileRefreshCachedData => 'Profiel kon niet worden vernieuwd. Er worden gegevens uit de cache weergegeven.';

  @override
  String get profileTitle => 'Profiel';

  @override
  String get profileUpdated => 'Profiel bijgewerkt.';

  @override
  String get uploadAvatarAction => 'Avatar uploaden';

  @override
  String get takePhotoAction => 'Neem een foto.';

  @override
  String get chooseFromLibraryAction => 'Kies uit de bibliotheek';

  @override
  String get removeAvatarAction => 'Avatar verwijderen';

  @override
  String get avatarUpdatedMessage => 'Avatar bijgewerkt.';

  @override
  String get avatarRemovedMessage => 'Avatar verwijderd.';

  @override
  String get avatarFileTooLarge => 'Het avatarbestand is te groot (max. 5 MB).';

  @override
  String get avatarPickFailed => 'De afbeelding van de avatar kon niet worden geladen.';

  @override
  String get queueAddExpense => 'Uitgave toevoegen';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'In de wachtrij: uitgave toevoegen $amount';
  }

  @override
  String get queueDeleteExpense => 'Uitgave verwijderen';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'In de wachtrij: uitgave #$id verwijderen';
  }

  @override
  String get queuePendingStatus => 'In de wachtrij';

  @override
  String get queueUpdateExpense => 'Uitgaven bijwerken';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'In de wachtrij: uitgave #$id bijwerken';
  }

  @override
  String get queuedChange => 'Wijzigingen in de wachtrij';

  @override
  String queuedChangesTitle(Object count) {
    return 'Wijzigingen in de wachtrij ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'In de wachtrij ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cyclus $cycleNo, tekening $drawNo - $remaining over';
  }

  @override
  String get receiptFallbackName => 'bon';

  @override
  String get receiptLinkInvalid => 'De link naar de ontvangstbevestiging is ongeldig.';

  @override
  String get receiptOptionalLabel => 'Bon (optioneel)';

  @override
  String get recentPicksTitle => 'Recente lotingen';

  @override
  String get reloadProfile => 'Profiel opnieuw laden';

  @override
  String get rememberMe => 'Onthoud mij';

  @override
  String get removeCurrentReceipt => 'Huidige ontvangstbewijs verwijderen';

  @override
  String get repeatNewPasswordLabel => 'Herhaal het nieuwe wachtwoord';

  @override
  String get repeatPasswordLabel => 'Wachtwoord herhalen';

  @override
  String get requestFailedTryAgain => 'Het verzoek is mislukt. Probeer het opnieuw.';

  @override
  String get retryAction => 'Opnieuw proberen';

  @override
  String get rowsLabel => 'Rijen';

  @override
  String get backToLoginAction => 'Terug naar inloggen';

  @override
  String get saveAction => 'Opslaan';

  @override
  String get saveCredentialsButton => 'Inloggegevens opslaan';

  @override
  String get saveProfileButton => 'Profiel opslaan';

  @override
  String get sendResetLinkButton => 'Resetlink verzenden';

  @override
  String get searchUsersHint => 'Zoek mensen op naam of e-mailadres';

  @override
  String get selectedPeopleLabel => 'Geselecteerde personen';

  @override
  String get noSearchMatches => 'Er zijn geen overeenkomende gebruikers gevonden.';

  @override
  String get savingButton => 'Bezig met opslaan...';

  @override
  String get selectAtLeastTwoMembers => 'Selecteer ten minste twee deelnemers.';

  @override
  String get selectMembersHint => 'Leden selecteren';

  @override
  String selectedFileLabel(Object name) {
    return 'Geselecteerd: $name';
  }

  @override
  String get selectedLabel => 'Geselecteerd';

  @override
  String get selectedUserFallback => 'Geselecteerde gebruiker';

  @override
  String get settings => 'Instellingen';

  @override
  String get settleUpAction => 'Afrekenen';

  @override
  String get settledLabel => 'Vereffend';

  @override
  String get settledStatus => 'Vereffend';

  @override
  String get settlementActivitySubtitle => 'Overboekingen die aan dit lid zijn gekoppeld.';

  @override
  String get settlementActivityTitle => 'Afwikkelingsactiviteit';

  @override
  String get settlementCompletedTitle => 'Afwikkeling voltooid';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed$total bevestigd';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Verrekeningen: $count';
  }

  @override
  String get settlementImpactTitle => 'Gevolgen voor de afwikkeling';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Gevolgen voor de afwikkeling: $name';
  }

  @override
  String get settlementInProgress => 'Afwikkeling aan de gang';

  @override
  String get settlementInProgressTitle => 'Afwikkeling aan de gang';

  @override
  String get settlementLabel => 'Verrekening';

  @override
  String get settlementOverviewArchivedSubtitle => 'Reis gearchiveerd. Alle afrekeningen voltooid.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Houd afrekeningsbevestigingen bij.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Bekijk een voorbeeld van de overboekingen voor wanneer de reis is afgelopen.';

  @override
  String get settlementPreview => 'Voorbeeld van de afrekening';

  @override
  String get settlementPreviewTitle => 'Voorbeeld van de afrekening';

  @override
  String get settlementProgressTripArchived => 'Reis gearchiveerd';

  @override
  String settlementWithId(Object id) {
    return 'Afrekening #$id';
  }

  @override
  String get settlements => 'Verrekeningen';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Afrekeningen zijn reeds voltooid.';

  @override
  String get settlementsDone => 'Afwikkelingen voltooid';

  @override
  String get settlingStatus => 'Afrekenen';

  @override
  String get shareUnit => 'aandeel';

  @override
  String get sharesLabel => 'Aandelen';

  @override
  String get sharesMustBePositiveIntegers => 'Het aantal aandelen moet een positief geheel getal zijn.';

  @override
  String sharesWithValue(Object value) {
    return 'Aandelen: $value';
  }

  @override
  String get showActiveTrips => 'Actieve reizen weergeven';

  @override
  String get signUpButton => 'Registreren';

  @override
  String get splitBreakdownSubtitle => 'Hoe de kosten worden verdeeld';

  @override
  String get splitBreakdownTitle => 'Uitsplitsing';

  @override
  String get splitHintEqual => 'Verdeel het bedrag gelijkmatig over de geselecteerde deelnemers.';

  @override
  String get splitHintExact => 'Voer voor elke deelnemer het exacte bedrag in. Het totaal moet overeenkomen met het eindbedrag.';

  @override
  String get splitHintPercent => 'Voer voor elke deelnemer een percentage in. Het totaal moet 100% zijn.';

  @override
  String get splitHintShares => 'Voer het aantal deelgenoten in (1, 2, 3...). De kosten worden evenredig verdeeld.';

  @override
  String get splitLabel => 'Splitsen';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Gelijke verdeling ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Exacte bedragen ($target)';
  }

  @override
  String get splitModeLabel => 'Split-modus';

  @override
  String splitModePercent(Object target) {
    return 'Percentages ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Aandelen ($target)';
  }

  @override
  String get statusConfirmed => 'Bevestigd';

  @override
  String get statusPending => 'In afwachting';

  @override
  String get statusSent => 'Verzonden';

  @override
  String get statusSuggested => 'Voorgesteld';

  @override
  String statusWithValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get suggestedTransferDirections => 'Voorgestelde betaalrichtingen';

  @override
  String get suggestedTransferFromExpense => 'Voorgestelde overboeking vanuit onkosten';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voorgestelde overschrijvingen',
      one: '$count voorgestelde overschrijving',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Verwachte betaler -> ontvanger-rijen.';

  @override
  String get suggestedTransfersTitle => 'Voorgestelde overboekingen';

  @override
  String get summarySettledUp => 'Vereffend';

  @override
  String get summaryYouAreOwed => 'Anderen zijn je geld schuldig';

  @override
  String get summaryYouOwe => 'Je bent verschuldigd';

  @override
  String get syncAction => 'Synchroniseren';

  @override
  String get syncNowAction => 'Nu synchroniseren';

  @override
  String get syncingStatus => 'Synchroniseren';

  @override
  String get tapToViewDetails => 'Tik om details te bekijken';

  @override
  String get themeModeDark => 'Donker';

  @override
  String get themeModeDarkSubtitle => 'Zacht donker (niet puur zwart)';

  @override
  String get themeModeLight => 'Licht';

  @override
  String get themeModeSystem => 'Systeem';

  @override
  String get themeModeSystemSubtitle => 'Gebruik de uiterlijke vorm van het apparaat';

  @override
  String toDirection(Object name) {
    return 'Aan $name';
  }

  @override
  String get totalLabel => 'Totaal';

  @override
  String get travelerFallbackName => 'Reiziger';

  @override
  String get tripAlreadyClosed => 'Reis is al afgesloten.';

  @override
  String get tripArchivedReadOnly => 'De reis wordt gearchiveerd. Alleen-lezenmodus.';

  @override
  String get tripClosedExpenseEditingDisabled => 'De reis is afgesloten. Het bewerken van onkosten is uitgeschakeld.';

  @override
  String get tripClosedExpensesReadOnly => 'De reis is afgesloten. Uitgaven zijn alleen-lezen.';

  @override
  String get tripClosedRandomDisabled => 'De reis is afgesloten. De willekeurige loting is uitgeschakeld.';

  @override
  String tripCreated(Object name) {
    return 'Reis „$name“ aangemaakt.';
  }

  @override
  String get tripFinished => 'Reis voltooid.';

  @override
  String get tripFinishedCompleteSettlements => 'De reis is voltooid. Rond de afrekeningen af.';

  @override
  String get tripFinishedSettlementStarted => 'Reis voltooid. Afrekening gestart.';

  @override
  String get tripFullySettledArchived => 'Reis volledig afgewikkeld en gearchiveerd.';

  @override
  String get tripNameHint => 'Skireis naar Oostenrijk';

  @override
  String get tripNameLabel => 'Reisnaam';

  @override
  String get tripNameLengthValidation => 'De naam van de reis moet uit minimaal 2 tekens bestaan.';

  @override
  String get tripSnapshotTitle => 'Reisoverzicht';

  @override
  String get tripTitleShort => 'Reis';

  @override
  String tripStatusWithValue(Object status) {
    return 'Reisstatus: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Reis #$id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Onverwachte fout bij het laden van het profiel';

  @override
  String get unexpectedErrorLoadingTripData => 'Onverwachte fout bij het laden van reisgegevens';

  @override
  String get unexpectedErrorLoadingTrips => 'Onverwachte fout bij het laden van reizen';

  @override
  String get unexpectedErrorSavingChanges => 'Onverwachte fout bij het opslaan van wijzigingen';

  @override
  String get unexpectedErrorSavingCredentials => 'Onverwachte fout bij het opslaan van inloggegevens';

  @override
  String get unexpectedErrorUpdatingProfile => 'Onverwachte fout bij het bijwerken van het profiel';

  @override
  String get unknownError => 'Onbekende fout';

  @override
  String get unknownLabel => 'Onbekend';

  @override
  String get unreadLabel => 'Ongelezen';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ongelezen updates',
      one: '$count ongelezen update',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Argument voor reisroute ontbreekt.';

  @override
  String userIdLabel(Object id) {
    return 'Gebruikers-ID: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Betaald $paid  -  Verschuldigd $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Gebruiker $id';
  }

  @override
  String get valueLabel => 'Waarde';

  @override
  String get viewAllTrips => 'Bekijk alle reizen';

  @override
  String get viewByPersonTitle => 'Weergave per persoon';

  @override
  String get whoOwesWhatSubtitle => 'Wie heeft betaald en wie is nog iets verschuldigd.';

  @override
  String get whoOwesWhatTitle => 'Wie is wat verschuldigd?';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Wie is wat verschuldigd: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Uitgavenregels die bijdragen aan deze overboeking.';

  @override
  String get whyPaymentExistsTitle => 'Waarom deze betaling bestaat';

  @override
  String get youLabel => 'Je';

  @override
  String get youSettledForExpense => 'Je hebt jouw deel van deze uitgave vereffend.';

  @override
  String youShouldPay(Object amount) {
    return 'Je moet betalen. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'U moet $amount';
  }

  @override
  String get yourShare => 'Jouw aandeel';

  @override
  String get yourTrips => 'Je reizen';

  @override
  String get homeYourActiveTrips => 'Je actieve reizen';

  @override
  String get homeYourArchivedTrips => 'Je gearchiveerde reizen';

  @override
  String get authIntroSplitSmarter => 'Slimmer verdelen.';

  @override
  String get authIntroTravelFree => 'Reis vrijuit.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Houd gedeelde kosten in verschillende valuta bij en reken direct af – geen ongemakkelijke schuldbriefjes.';

  @override
  String get authIntroPlanTogether => 'Plan samen.';

  @override
  String get authIntroPayClearly => 'Betaal op een duidelijke manier.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Maak in enkele seconden reizen aan, voeg vrienden toe en houd elke uitgave voor iedereen transparant.';

  @override
  String get authIntroSettleFast => 'Regel het snel.';

  @override
  String get authIntroStayFriends => 'Blijf vrienden.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Van gezamenlijke etentjes tot complete reizen: Splyto zorgt voor een eerlijke en zorgeloze afrekening.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Inloggen via Apple is mislukt. Probeer het opnieuw.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Inloggen via Google is mislukt. Probeer het opnieuw.';

  @override
  String get authIntroCreateAccount => 'Maak je account aan.';

  @override
  String get authIntroChooseSign => 'Kies hoe je je wilt aanmelden.';

  @override
  String get authIntroContinueGoogle => 'Doorgaan met Google';

  @override
  String get authIntroContinueApple => 'Ga verder met Apple';

  @override
  String get authIntroBack => 'Terug';

  @override
  String get authIntroSplitSettled => 'Verdeling afgerond';

  @override
  String get authIntroParis3Friends => 'Parijs · 3 vrienden';

  @override
  String get authIntroGetStarted => 'Aan de slag';

  @override
  String get authIntroAlreadyHaveAccount => 'Heb je al een account? ';

  @override
  String get authIntroSignIn => 'Inloggen';

  @override
  String get authIntroSignUpWithEmail => 'Meld je aan met je e-mailadres';

  @override
  String get authIntroOr => 'OF';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Google Sign-In heeft geen ID-token geretourneerd.';

  @override
  String get authAppleSignAvailableIosDevices => 'Inloggen via Apple is beschikbaar op iOS-apparaten.';

  @override
  String get authAppleSignNotAvailableDevice => 'Inloggen via Apple is niet beschikbaar op dit apparaat.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Apple Sign-in heeft geen identiteitstoken geretourneerd.';

  @override
  String get authCancel => 'Annuleren';

  @override
  String get authSendLink => 'Link verzenden';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'Het e-mailadres is niet geverifieerd. Voer je e-mailadres in om een verificatielink aan te vragen.';

  @override
  String get authEmailNotVerified => 'E-mailadres niet geverifieerd';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Verificatielink verzenden naar $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Verificatielink verzonden. Controleer je e-mail.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'De verificatielink kon niet worden verzonden. Probeer het opnieuw.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Er is een verificatie-e-mail verzonden. Verifieer je e-mailadres voordat je inlogt.';

  @override
  String get authVerifyEmail => 'Verifieer je e-mailadres';

  @override
  String get authEmailLabel => 'E-mail:';

  @override
  String get authClose => 'Sluiten';

  @override
  String get authResendLink => 'Link opnieuw verzenden';

  @override
  String get profileAppSettingsSectionTitle => 'APP-INSTELLINGEN';

  @override
  String get profileEmailVerified => 'Geverifieerd';

  @override
  String get profileEmailNotVerified => 'Niet geverifieerd';

  @override
  String get profileEmailSendVerification => 'Link versturen';

  @override
  String get profileEmailVerificationSent => 'Verificatie-e-mail verstuurd. Controleer je inbox.';

  @override
  String get profileAccountSectionTitle => 'ACCOUNT';

  @override
  String get profileAccountSettings => 'Accountinstellingen';

  @override
  String get profileChangePhoto => 'Profielfoto wijzigen';

  @override
  String get profileAppearance => 'Uiterlijk';

  @override
  String get profileThemeDisplayMode => 'Thema & weergavemodus';

  @override
  String get profileLanguage => 'Taal';

  @override
  String get profileDisplayLanguage => 'Weergavetaal';

  @override
  String get profileNotificationsSectionHeading => 'MELDINGEN';

  @override
  String get profileAppBanners => 'Banners in de app';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Toon nieuwe meldingsbanners in de app';

  @override
  String get profilePushNotificationsTitle => 'Pushmeldingen';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Meldingen op de telefoon voor uitgaven, vrienden, reizen en afrekeningen';

  @override
  String get profileSupportSectionHeading => 'ONDERSTEUNING';

  @override
  String get profileContactUs => 'Neem contact met ons op';

  @override
  String get profileReportBugSuggestion => 'Fout melden / Suggestie';

  @override
  String get profileRateSplyto => 'Beoordeel Splyto';

  @override
  String get profileLeaveStoreRating => 'Geef een beoordeling voor de winkel';

  @override
  String get profileSecuritySectionHeading => 'BEVEILIGING';

  @override
  String get profileAccountAndSecurity => 'Account en beveiliging';

  @override
  String get profileHelpTitle => 'Help';

  @override
  String get profileChangePassword => 'Wachtwoord wijzigen';

  @override
  String get profileUpdateAccountPassword => 'Wachtwoord van het account bijwerken';

  @override
  String get profileDangerZoneSectionHeading => 'GEVAARZONE';

  @override
  String get profileManageAccountAccess => 'Beheer de toegang tot het account';

  @override
  String get profileMadeWithLabel => 'Gemaakt met';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'De beoordelingsfunctie wordt in de volgende stap gekoppeld.';

  @override
  String get profileFailedSaveNotificationSettings => 'Het opslaan van de meldingsinstellingen is mislukt.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH-MELDINGEN';

  @override
  String get profileInAppBannersSectionTitle => 'BANNERS IN DE APP';

  @override
  String get profileInAppTripMemberAddedTitle => 'Deelnemer toegevoegd aan reis';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatische herinnering voor afrekening';

  @override
  String get profileExpenseUpdates => 'Uitgavenupdates';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Banners voor toegevoegde onkosten binnen de app';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Meldingen over toegevoegde uitgaven op de telefoon';

  @override
  String get profileFriendInvites => 'Vriend uitnodigen';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Banners voor vriendschapsverzoeken en reacties in de app';

  @override
  String get profileFriendRequestResponseNotifications => 'Meldingen over vriendschapsverzoeken en reacties daarop';

  @override
  String get profileTripUpdates => 'Reisupdates';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Banners over de levenscyclus van de reis en de status van deelnemers in de app';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Verloop van de reis en wijzigingen in de status van deelnemers';

  @override
  String get profileSettlementUpdates => 'Updates over de afrekening';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Banners voor ‘verzonden’ en ‘bevestigde betaling’ in de app';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Als verzonden gemarkeerde en bevestigde betalingsupdates';

  @override
  String get profileScreenshotSizeMust8Mb => 'De grootte van de schermafbeelding mag maximaal 8 MB bedragen';

  @override
  String get profileFeedbackSendTitle => 'Feedback versturen';

  @override
  String get profileFeedbackTypeLabel => 'Type';

  @override
  String get profileFeedbackTypeBug => 'Bug';

  @override
  String get profileFeedbackTypeSuggestion => 'Suggestie';

  @override
  String get profileDescribeIssueSuggestion => 'Beschrijf het probleem of de suggestie';

  @override
  String get profilePickingImage => 'Afbeelding wordt geselecteerd...';

  @override
  String get profileAttachScreenshot => 'Voeg een screenshot toe';

  @override
  String get profileChangeScreenshot => 'Screenshot wijzigen';

  @override
  String get profileRemoveImage => 'Afbeelding verwijderen';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Tip: voeg een screenshot toe voor een snellere bugtriage';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Voeg details toe of voeg een screenshot toe voordat je het bericht verstuurt';

  @override
  String get profileSendAction => 'Verzenden';

  @override
  String get profileThanksFeedbackSent => 'Bedankt! Feedback verzonden';

  @override
  String get profileFailedSendFeedback => 'Het verzenden van feedback is mislukt';

  @override
  String get profileCouldNotOpenWebsite => 'De website kon niet worden geopend.';

  @override
  String get profileOpenWebsiteQuestion => 'Website openen?';

  @override
  String get profileOpenPortfolioAction => 'Open portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Dit afbeeldingsformaat wordt op dit apparaat niet ondersteund. Kies JPG of PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Een geldig e-mailadres voor je account is vereist om je wachtwoord te wijzigen. Neem contact op met de ondersteuning als je e-mailadres ontbreekt of onjuist is.';

  @override
  String get profileEditDeletionLinkSentEmail => 'De verwijderingslink is naar je e-mailadres verzonden.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'De verwijderingslink kon niet worden verzonden. Probeer het opnieuw.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Voer het huidige wachtwoord in om het e-mailadres te wijzigen.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Er is een verificatiebericht verzonden naar het nieuwe e-mailadres. Er is een beveiligingsmelding verzonden naar je huidige e-mailadres.';

  @override
  String get profileEditOverviewCurrency => 'Overzicht valuta';

  @override
  String get profileEditPaymentMethod => 'Betaalmethode';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Bankoverschrijving, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Voer je wachtwoord in (optioneel voor Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Verzend een verwijderingslink naar e-mail';

  @override
  String get profileEditBackProfile => 'Terug naar profiel';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Stel een geldig e-mailadres in je profiel in voordat je het wachtwoord wijzigt.';

  @override
  String get profileEditPasswordUpdated => 'Wachtwoord bijgewerkt.';

  @override
  String get profileEditFailedUpdatePassword => 'Het bijwerken van het wachtwoord is mislukt.';

  @override
  String profileEditEmail(Object email) {
    return 'Account: $email';
  }

  @override
  String get profileEditPrimary => 'Primair';

  @override
  String get profileEditSearchCurrency => 'Zoek valuta';

  @override
  String get profileEditNoCurrenciesFound => 'Geen valuta\'s gevonden';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'De totalen in het overzicht worden omgerekend naar deze valuta.';

  @override
  String get profileEditPaymentInfoUpdated => 'Betalingsgegevens bijgewerkt.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Betalingsgegevens konden niet worden opgeslagen. Probeer het opnieuw.';

  @override
  String get profileEditCurrentPassword => 'Huidig wachtwoord';

  @override
  String get profileEditBankTransferIbanSwift => 'Bankoverschrijving (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me-link';

  @override
  String get profileEditChoosePaymentMethod => 'Kies een betaalmethode';

  @override
  String get profileEditTapChange => 'Tik om te wijzigen';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Voor overschrijvingen in het Verenigd Koninkrijk moet de sortcode uit 6 cijfers bestaan en het rekeningnummer uit 8 cijfers.';

  @override
  String get profileEditPaymentInfo => 'Betalingsgegevens';

  @override
  String get profileEditSaveDetails => 'Gegevens opslaan';

  @override
  String get profileEditBankRegion => 'Bankregio';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'Sorteercode';

  @override
  String get profileEditExample112233 => 'Voorbeeld: 112233';

  @override
  String get profileEditNumber => 'Rekeningnummer';

  @override
  String get profileEdit8Digits => '8 cijfers';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Gebruik voor binnenlandse overschrijvingen in het VK de sort code + rekeningnummer.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Voorbeeld: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 of 11 tekens';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'De naam van de rekeninghouder wordt overgenomen uit de volledige naam in het profiel.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username of gebruikersnaam';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'VK';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Pas de avatar aan';

  @override
  String get imageCropperAdjustTripImage => 'Pas de reisfoto aan';

  @override
  String get imageCropEditAction => 'Uitsnede bewerken';

  @override
  String get imageCropZoomIn => 'Inzoomen';

  @override
  String get imageCropZoomOut => 'Uitzoomen';

  @override
  String get imageCropZoomOnly => 'Van deze foto is alleen de bijgesneden versie bewaard, dus je kunt alleen inzoomen.';

  @override
  String get imageCropLoadFailed => 'Deze foto kon niet worden geopend.';

  @override
  String get imageCropSaveFailed => 'De nieuwe uitsnede kon niet worden opgeslagen. Probeer het opnieuw.';

  @override
  String get imageCropChanged => 'Deze foto is intussen gewijzigd. Sluit dit scherm en open het opnieuw.';

  @override
  String get copyAction => 'Kopiëren';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Brits pond';

  @override
  String get currencyNameChf => 'Zwitserse frank';

  @override
  String get currencyNameNok => 'Noorse kroon';

  @override
  String get currencyNameSek => 'Zweedse kroon';

  @override
  String get currencyNameDkk => 'Deense kroon';

  @override
  String get currencyNamePln => 'Poolse zloty';

  @override
  String get currencyNameCzk => 'Tsjechische kroon';

  @override
  String get currencyNameHuf => 'Hongaarse forint';

  @override
  String get currencyNameRon => 'Roemeense leu';

  @override
  String get currencyNameBgn => 'Bulgaarse lev';

  @override
  String get currencyNameIsk => 'IJslandse kroon';

  @override
  String get currencyNameAll => 'Albanese lek';

  @override
  String get currencyNameBam => 'Bosnië en Herzegovina Mark';

  @override
  String get currencyNameByn => 'Wit-Russische roebel';

  @override
  String get currencyNameMdl => 'Moldavische leu';

  @override
  String get currencyNameMkd => 'Macedonische denar';

  @override
  String get currencyNameRsd => 'Servische dinar';

  @override
  String get currencyNameUah => 'Oekraïense hryvnia';

  @override
  String get currencyNameGel => 'Georgische lari';

  @override
  String get currencyNameTry => 'Turkse lira';

  @override
  String get currencyNameUsd => 'Amerikaanse dollar';

  @override
  String get currencyNameJpy => 'Japanse yen';

  @override
  String get currencyNameCny => 'Chinese yuan';

  @override
  String get currencyNameCad => 'Canadese dollar';

  @override
  String get currencyNameAud => 'Australische dollar';

  @override
  String get currencyNameRub => 'Russische roebel';

  @override
  String get currencyNameMxn => 'Mexicaanse peso';

  @override
  String get currencyNameBrl => 'Braziliaanse real';

  @override
  String get currencyNameArs => 'Argentijnse peso';

  @override
  String get currencyNameClp => 'Chileense peso';

  @override
  String get currencyNameCop => 'Colombiaanse peso';

  @override
  String get currencyNamePen => 'Peruaanse sol';

  @override
  String get currencyNameUyu => 'Uruguayaanse peso';

  @override
  String get currencyNameBob => 'Boliviaanse boliviano';

  @override
  String get currencyNamePyg => 'Paraguayaanse guarani';

  @override
  String get currencyNameCrc => 'Costa Ricaanse colon';

  @override
  String get currencyNameDop => 'Dominicaanse peso';

  @override
  String get currencyNameGtq => 'Guatemalteekse quetzal';

  @override
  String get currencyNamePab => 'Panamese balboa';

  @override
  String get currencyNameHnl => 'Hondurese lempira';

  @override
  String get currencyNameNio => 'Nicaraguaanse córdoba';

  @override
  String get currencyNameJmd => 'Jamaicaanse dollar';

  @override
  String get currencyNameBbd => 'Barbadaanse dollar';

  @override
  String get currencyNameBsd => 'Bahamaanse dollar';

  @override
  String get currencyNameTtd => 'Trinidad en Tobago-dollar';

  @override
  String get currencyNameXcd => 'Oost-Caribische dollar';

  @override
  String get currencyNameBzd => 'Belizaanse dollar';

  @override
  String get currencyNameAwg => 'Arubaanse gulden';

  @override
  String get currencyNameBmd => 'Bermuda-dollar';

  @override
  String get currencyNameKyd => 'Kaaimaneilandse dollar';

  @override
  String get currencyNameKrw => 'Zuid-Koreaanse won';

  @override
  String get currencyNameInr => 'Indiase roepie';

  @override
  String get currencyNameThb => 'Thaise baht';

  @override
  String get currencyNameVnd => 'Vietnamese dong';

  @override
  String get currencyNameIdr => 'Indonesische roepia';

  @override
  String get currencyNameMyr => 'Maleisische ringgit';

  @override
  String get currencyNameSgd => 'Singaporese dollar';

  @override
  String get currencyNamePhp => 'Filipijnse peso';

  @override
  String get currencyNameHkd => 'Hongkongse dollar';

  @override
  String get currencyNameTwd => 'Nieuwe Taiwanese dollar';

  @override
  String get currencyNameLkr => 'Sri Lankaanse roepie';

  @override
  String get currencyNameNpr => 'Nepalese roepie';

  @override
  String get currencyNameBdt => 'Bengalese taka';

  @override
  String get currencyNamePkr => 'Pakistaanse roepie';

  @override
  String get currencyNameKhr => 'Cambodjaanse riel';

  @override
  String get currencyNameLak => 'Laotiaanse kip';

  @override
  String get currencyNameMmk => 'Myanmarese kyat';

  @override
  String get currencyNameMnt => 'Mongoolse tugrik';

  @override
  String get currencyNameMop => 'Macause pataca';

  @override
  String get currencyNameBnd => 'Bruneise dollar';

  @override
  String get currencyNameMvr => 'Maldivische rufiyaa';

  @override
  String get currencyNameBtn => 'Bhutaanse ngultrum';

  @override
  String get currencyNameKzt => 'Kazachse tenge';

  @override
  String get currencyNameUzs => 'Oezbeekse sum';

  @override
  String get currencyNameKgs => 'Kirgizische som';

  @override
  String get currencyNameTjs => 'Tadzjiekse somoni';

  @override
  String get currencyNameAzn => 'Azerbeidzjaanse manat';

  @override
  String get currencyNameAmd => 'Armeense dram';

  @override
  String get currencyNameAed => 'Verenigde Arabische Emiraten-dirham';

  @override
  String get currencyNameSar => 'Saoedi-Arabische riyal';

  @override
  String get currencyNameQar => 'Qatarese rial';

  @override
  String get currencyNameOmr => 'Omaanse rial';

  @override
  String get currencyNameKwd => 'Koeweitse dinar';

  @override
  String get currencyNameBhd => 'Bahreinse dinar';

  @override
  String get currencyNameJod => 'Jordaanse dinar';

  @override
  String get currencyNameIls => 'Israëlische nieuwe shekel';

  @override
  String get currencyNameLbp => 'Libanees pond';

  @override
  String get currencyNameIqd => 'Iraakse dinar';

  @override
  String get currencyNameZar => 'Zuid-Afrikaanse rand';

  @override
  String get currencyNameEgp => 'Egyptisch pond';

  @override
  String get currencyNameMad => 'Marokkaanse dirham';

  @override
  String get currencyNameTnd => 'Tunesische dinar';

  @override
  String get currencyNameDzd => 'Algerijnse dinar';

  @override
  String get currencyNameKes => 'Keniaanse shilling';

  @override
  String get currencyNameTzs => 'Tanzaniaanse shilling';

  @override
  String get currencyNameUgx => 'Oegandese shilling';

  @override
  String get currencyNameRwf => 'Rwandese frank';

  @override
  String get currencyNameEtb => 'Ethiopische birr';

  @override
  String get currencyNameGhs => 'Ghanese cedi';

  @override
  String get currencyNameNgn => 'Nigeriaanse naira';

  @override
  String get currencyNameXof => 'CFA-franc BCEAO';

  @override
  String get currencyNameXaf => 'CFA-frank';

  @override
  String get currencyNameMur => 'Mauritiaanse roepie';

  @override
  String get currencyNameScr => 'Seychelse roepie';

  @override
  String get currencyNameNad => 'Namibische dollar';

  @override
  String get currencyNameBwp => 'Botswaanse pula';

  @override
  String get currencyNameZmw => 'Zambiaanse kwacha';

  @override
  String get currencyNameMzn => 'Mozambikaanse metical';

  @override
  String get currencyNameAoa => 'Angolese kwanza';

  @override
  String get currencyNameMga => 'Malagassische ariary';

  @override
  String get currencyNameCve => 'Kaapverdische escudo';

  @override
  String get currencyNameGmd => 'Gambiaanse dalasi';

  @override
  String get currencyNameNzd => 'Nieuw-Zeelandse dollar';

  @override
  String get currencyNameFjd => 'Fiji-dollar';

  @override
  String get currencyNameXpf => 'CFP-frank';

  @override
  String get currencyNameWst => 'Samoaanse tala';

  @override
  String get currencyNameVuv => 'Vanuatuaanse vatu';

  @override
  String get currencyNameTop => 'Tongaanse paʻanga';

  @override
  String get currencyNamePgk => 'Papoea-Nieuw-Guinese kina';

  @override
  String get expenseCategoryFood => 'Eten';

  @override
  String get expenseCategoryGroceries => 'Boodschappen';

  @override
  String get expenseCategoryFuel => 'Brandstof';

  @override
  String get expenseCategoryTransport => 'Vervoer';

  @override
  String get expenseCategoryAccommodation => 'Accommodatie';

  @override
  String get expenseCategoryActivities => 'Activiteiten';

  @override
  String get expenseCategoryTickets => 'Tickets';

  @override
  String get expenseCategoryShopping => 'Winkelen';

  @override
  String get expenseCategoryParty => 'Feest';

  @override
  String get expenseCategoryParking => 'Parkeren';

  @override
  String get expenseCategoryOther => 'Overig';

  @override
  String get shellTripAlreadyInListOpened => 'De reis staat al in je lijst. We hebben deze voor je geopend.';

  @override
  String get shellJoinedTripFromInviteLink => 'Deelname aan de reis via de uitnodigingslink.';

  @override
  String get shellFailedToOpenInviteLink => 'Het openen van de uitnodigingslink is mislukt.';

  @override
  String get shellFailedToOpenFriendLink => 'Kan de vriendlink niet openen.';

  @override
  String get shellTripInviteTitle => 'Uitnodiging voor een reis';

  @override
  String get shellNoAction => 'Nee';

  @override
  String get shellYesAction => 'Ja';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Alleen de aanmaker van de reis kan deze reis verwijderen.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Alleen actieve reizen kunnen worden verwijderd.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return '\"$tripLabel\" verwijderen? Dit is alleen toegestaan voordat er uitgaven zijn toegevoegd.';
  }

  @override
  String get shellTripDeleted => 'Reis verwijderd.';

  @override
  String get shellFailedToDeleteTrip => 'Het verwijderen van de reis is mislukt.';

  @override
  String get shellFailedToLoadNotifications => 'Het laden van meldingen is mislukt.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nieuwe melding: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Meldingen konden niet worden bijgewerkt.';

  @override
  String get shellMarkAllAsReadAction => 'Alles als gelezen markeren';

  @override
  String get shellNewSection => 'Nieuw';

  @override
  String get shellEarlierSection => 'Eerder';

  @override
  String get shellShowMoreEarlierAction => 'Meer eerdere resultaten weergeven';

  @override
  String get shellLoadingMore => 'Meer laden...';

  @override
  String get shellLoadMoreNotificationsAction => 'Meer meldingen laden';

  @override
  String get shellTripNoLongerAvailable => 'Deze reis is niet langer beschikbaar.';

  @override
  String get shellFailedToOpenTrip => 'Het openen van de reis is mislukt.';

  @override
  String get shellYesterday => 'Gisteren';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Je bent al lid van \"$tripName\". Wil je deze reis nu openen?\n\nUitgenodigd door: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Wil je deelnemen aan reis \"$tripName\"?\n\nUitgenodigd door: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Geselecteerde afbeelding: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Reisafbeelding is al ingesteld.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Reis aangemaakt, maar het uploaden van de afbeelding is mislukt.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Reis aangemaakt, maar het uploaden van de afbeelding is mislukt: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Deel aan de reis via een uitnodiging';

  @override
  String get tripsTotalTrips => 'Totaal aantal reizen';

  @override
  String get tripsTotalSpent => 'Totaal uitgegeven';

  @override
  String get tripsMixedCurrencies => 'Gemengde valuta’s';

  @override
  String get tripsShowActive => 'Toon actief';

  @override
  String get tripsSeeAll => 'Alles bekijken';

  @override
  String get tripsGridView => 'Rasterweergave';

  @override
  String get tripsListView => 'Lijstweergave';

  @override
  String get tripsAddNewTrip => 'Nieuwe reis toevoegen';

  @override
  String get tripsLoadMore => 'Meer laden';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return '\"$arg1\" verwijderen? Dit is alleen toegestaan voordat er uitgaven zijn toegevoegd.';
  }

  @override
  String get tripsTripDates => 'Reisdata';

  @override
  String get tripsFrom => 'Van';

  @override
  String get tripsSelectDate => 'Selecteer datum';

  @override
  String get tripsTo => 'Om';

  @override
  String get tripsMainCurrency => 'Hoofdvaluta';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Selecteer de reisperiode (begin- en einddatum).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'De einddatum van de reis moet op of na de startdatum liggen.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Het formaat van de reisperiode is ongeldig. Kies alstublieft opnieuw een datum.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Je bent al lid van deze reis.';

  @override
  String get tripsJoinedTripSuccessfully => 'Je bent succesvol toegevoegd aan de reis.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Het is niet gelukt om via de uitnodiging deel te nemen aan de reis.';

  @override
  String get tripsJoinTrip => 'Deel aan de reis';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Plak de uitnodigingslink of het uitnodigingstoken.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Voer een geldige uitnodigingslink of token in.';

  @override
  String get tripsClipboardIsEmpty => 'Het klembord is leeg.';

  @override
  String get tripsPaste => 'Plakken';

  @override
  String get tripsJoin => 'Deelnemen';

  @override
  String get workspaceTripMembers => 'Reisdeelnemers';

  @override
  String get workspaceFailedToLoadFriends => 'Het laden van vrienden is mislukt.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Het genereren van de uitnodigingslink is mislukt.';

  @override
  String get workspaceInviteLink => 'Uitnodigingslink';

  @override
  String get workspaceGeneratingInviteLink => 'Uitnodigingslink wordt gegenereerd...';

  @override
  String get workspaceInviteLinkUnavailable => 'Uitnodigingslink niet beschikbaar.';

  @override
  String get workspaceCopyInviteLink => 'Kopieer uitnodigingslink';

  @override
  String get workspaceInviteLinkCopied => 'Uitnodigingslink gekopieerd.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Vervalt: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Er zijn geen vrienden beschikbaar. Voeg eerst vrienden toe.';

  @override
  String get workspaceSettle => 'Afrekenen';

  @override
  String get workspaceOwesToTheGroup => 'Is verschuldigd aan de groep';

  @override
  String get workspaceGetsBackFromGroup => 'Krijgt geld terug van de groep';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Weergave van de top 4 op basis van saldo-verschil.';

  @override
  String get workspaceOpenFlow => 'Details';

  @override
  String get workspaceFriend => 'Vriend';

  @override
  String get workspaceSettlementTransfer => 'Overboeking';

  @override
  String get workspaceCompleted => 'Voltooid';

  @override
  String get workspaceWaitingForConfirmation => 'Wachten op bevestiging';

  @override
  String get workspaceWaitingForPayment => 'Wachten op betaling';

  @override
  String get workspaceActionNeeded => 'Noodzakelijke actie';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Betalingen om als verzonden te markeren: $arg1; om als ontvangen te bevestigen: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Klaar om af te rekenen';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Alle deelnemers zijn klaar. U kunt beginnen met de afrekeningen.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Wachten tot iedereen aangeeft dat hij/zij klaar is.';

  @override
  String get workspaceIMReady => 'Ik ben er klaar voor';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Controleer of je al je uitgaven hebt toegevoegd.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'De knop ‘Voltooien’ wordt ontgrendeld zodra iedereen aangeeft klaar te zijn.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Krijgt geld terug van de groep';

  @override
  String get workspaceSettledWithTheGroup => 'Afgesproken met de groep';

  @override
  String get workspaceTotalPaid => 'Totaal betaald';

  @override
  String get workspaceTotalOwes => 'Totaal verschuldigd';

  @override
  String get workspaceTransactionHistory => 'Transactiegeschiedenis';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Nog geen transacties voor dit lid.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Afrekeningen: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Alle deelnemers moeten aangeven dat ze klaar zijn voordat de afrekeningen kunnen beginnen.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Je hebt aangegeven dat je klaar bent om af te rekenen.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'De markering ‘Klaar voor afrekening’ is verwijderd.';

  @override
  String get workspaceReminderSent => 'Herinnering verzonden.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Uitnodigingslink of toevoegen via vrienden';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Alleen de reisorganisator kan deze reis bewerken.';

  @override
  String get workspaceTripUpdated => 'Reis bijgewerkt.';

  @override
  String get workspaceFailedToUpdateTrip => 'Het bijwerken van de reis is mislukt.';

  @override
  String get workspaceNoMembersSelectedYet => 'Er zijn nog geen leden geselecteerd.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Geen internet. De uitgave wordt opgeslagen zonder afbeelding van de bon.';

  @override
  String get workspaceRandomPicker => 'Willekeurige selectie';

  @override
  String get workspaceCurrency => 'Valuta';

  @override
  String get workspaceCategory => 'Categorie';

  @override
  String get workspaceCustomCategory => 'Aangepaste categorie';

  @override
  String get workspaceCategoryName => 'Categorienaam';

  @override
  String get workspaceApartmentRentParkingEtc => 'Huur van een appartement, parkeren, enz.';

  @override
  String get workspaceEnterACustomCategory => 'Voer een aangepaste categorie in.';

  @override
  String get workspacePickAnExpenseCategory => 'Kies een onkostencategorie.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'De categorie moet uit minimaal 2 tekens bestaan.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'De categorie mag maximaal 64 tekens bevatten.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Het totaal van de procentuele verdeling moet 100% bedragen.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Het aantal aandelen moet voor elke deelnemer groter zijn dan 0.';

  @override
  String get workspaceTotalAmount => 'Totaalbedrag';

  @override
  String get workspaceOriginal => 'Origineel';

  @override
  String get workspaceTotalCost => 'Totale kosten';

  @override
  String workspaceStarted(Object arg1) {
    return 'Gestart $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Beëindigd $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Gearchiveerde reis';

  @override
  String get workspaceActiveTrip => 'Actieve reis';

  @override
  String get workspaceMemberProfile => 'Ledenprofiel';

  @override
  String get workspaceTripOwner => 'Reisorganisator';

  @override
  String get workspaceMember => 'Lid';

  @override
  String get workspaceReadyForSettlement => 'Klaar voor afrekening';

  @override
  String get workspaceNotReadyForSettlement => 'Nog niet klaar voor afwikkeling';

  @override
  String get workspaceBankDetails => 'Bankgegevens';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN- en uitbetalingsgegevens worden hier in een volgende update toegevoegd.';

  @override
  String get workspacePaymentDetails => 'Betalingsgegevens';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Dit lid heeft nog geen uitbetalingsgegevens toegevoegd.';

  @override
  String get workspaceBankTransfer => 'Bankoverschrijving';

  @override
  String get workspaceHolder => 'Houder';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'De betalingslink kon niet worden geopend.';

  @override
  String get workspaceTripActivity => 'Reisactiviteit';

  @override
  String get workspacePaidExpenses => 'Betaalde uitgaven';

  @override
  String get workspacePaidTotal => 'Betaald totaalbedrag';

  @override
  String get workspaceInvolvedIn => 'Betrokken bij';

  @override
  String get workspaceCurrentTrip => 'Huidige reis';

  @override
  String get workspaceCommonTrips => 'Gezamenlijke reizen';

  @override
  String get workspaceLoadingCommonTrips => 'Gezamenlijke reizen laden…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Nog geen gezamenlijke reizen gevonden.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Niet alle gezamenlijke reizen konden worden geladen. De huidige reis wordt getoond.';

  @override
  String get workspaceMembers => 'leden';

  @override
  String get workspaceExpense => 'Onkosten';

  @override
  String get workspacePaid => 'betaald';

  @override
  String get workspaceLoadingMoreExpenses => 'Meer uitgaven worden geladen...';

  @override
  String get workspaceScrollDownToLoadMore => 'Scroll naar beneden om meer te laden';

  @override
  String get workspaceTripFinished => 'Reis voltooid';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'De afrekeningen zijn voor deze reis ontgrendeld.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Rond de reis af om de afrekening te starten.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 heeft de overboeking gemarkeerd als verzonden.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Wachten tot $arg1 de betaling als betaald markeert.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 heeft de ontvangst van de betaling bevestigd.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Wachten op bevestiging van $arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Alle afrekeningen van de reis zijn volledig afgerond.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Eindstatus nadat alle overboekingen zijn bevestigd.';

  @override
  String get workspaceSettlementFlow => 'Afwikkelingsproces';

  @override
  String get workspaceActions => 'Acties';

  @override
  String get workspaceQuickPay => 'Snel betalen';

  @override
  String get workspacePayWithRevolut => 'Betaal met Revolut';

  @override
  String get workspacePayWithPaypal => 'Betaal met PayPal';

  @override
  String get workspacePayWithWise => 'Betaal met Wise';

  @override
  String get workspaceTransferIsConfirmed => 'De overboeking is bevestigd.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Wachten tot het andere lid de volgende stap voltooit.';

  @override
  String get workspaceSendReminder => 'Herinnering versturen';

  @override
  String get workspaceInProgress => 'In uitvoering';

  @override
  String get workspaceTimeUnknown => 'Tijd onbekend';

  @override
  String get workspaceRemind => 'Herinnering';

  @override
  String get workspaceYourPosition => 'Uw standpunt';

  @override
  String get workspaceRecentActivity => 'Recente activiteit';

  @override
  String get workspaceNoRecentActivityYet => 'Nog geen recente activiteit.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Voeg ten minste één deelnemer toe om te beginnen met het delen van de kosten.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Geef aan dat je klaar bent om af te rekenen nadat je al je uitgaven hebt toegevoegd.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Deelnemers die nog niet klaar zijn: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Alle deelnemers zijn klaar. Je kunt de reis afronden en beginnen met de afrekening.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Alle deelnemers zijn klaar. Wachten op de reisorganisator om de afrekening te starten.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Afwikkeling bezig: $arg1/$arg2 bevestigd.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Er zijn geen acties in behandeling. Deze reis is afgerond.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Er zijn op dit moment geen acties nodig.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'U zou $arg1 moeten ontvangen.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Je moet $arg1 betalen.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Je bent momenteel ingeschreven voor deze reis.';

  @override
  String get workspaceUnknownTime => 'Onbekende tijd';

  @override
  String get workspaceJustNow => 'Zojuist';

  @override
  String workspaceMinAgo(Object arg1) {
    return '$arg1 min geleden';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return '$arg1 uur geleden';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return '$arg1 d geleden';
  }

  @override
  String get friendsRemoveFriend => 'Vriend verwijderen';

  @override
  String get friendsRemoveThisFriend => 'Deze vriend verwijderen?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 wordt uit je vriendenlijst verwijderd. Je kunt deze persoon later weer toevoegen.';
  }

  @override
  String get friendsContinue => 'Ga verder';

  @override
  String get friendsFriendRemoved => 'Vriend verwijderd.';

  @override
  String get friendsCouldNotRemoveFriend => 'Kon vriend niet verwijderen.';

  @override
  String get friendsFriendProfile => 'Vriendprofiel';

  @override
  String get friendsMoreActions => 'Meer acties';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Deze vriend heeft nog geen uitbetalingsgegevens toegevoegd.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'De gezamenlijke reizen konden nu niet worden geladen.';

  @override
  String get friendsFinished => 'Klaar';

  @override
  String friendsTrip(Object arg1) {
    return 'Reis #$arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Leden: $arg1';
  }

  @override
  String get friendsNoDate => 'Geen datum';

  @override
  String get friendsIncomingRequests => 'BINNENKOMENDE VERZOEKEN';

  @override
  String get friendsSentInvites => 'VERZONDEN UITNODIGINGEN';

  @override
  String get friendsMyFriends => 'MIJN VRIENDEN';

  @override
  String get friendsRequests => 'Verzoeken';

  @override
  String get friendsIncoming => 'Inkomend';

  @override
  String get friendsIncomingRequestSubtitle => 'wil vrienden worden';

  @override
  String get friendsOutgoingInviteSubtitle => 'Uitnodiging verzonden';

  @override
  String get friendsNoPendingActivity => 'Geen vriendschapsverzoeken';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Uitnodiging verzonden naar $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Geen inkomende verzoeken';

  @override
  String get friendsDecline => 'Weigeren';

  @override
  String get friendsAccept => 'Accepteren';

  @override
  String get friendsNoSentInvites => 'Geen verzonden uitnodigingen';

  @override
  String get friendsNoFriendsYet => 'Nog geen vrienden';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Scroll naar beneden om meer vrienden te laden.';

  @override
  String get friendsUser => 'Gebruiker';

  @override
  String get friendsSearchUsers => 'Gebruikers zoeken';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Zoek op naam of e-mailadres en verstuur een uitnodiging';

  @override
  String get friendsScanQr => 'Scan QR-code';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Scan een andere gebruiker om een vriend toe te voegen';

  @override
  String get friendsMyQr => 'Mijn QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Toon of deel je QR-code';

  @override
  String get friendsScanFriendQrTitle => 'Scan de QR-code van een vriend';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Plaats de QR-code van een vriend in het kader';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Houd de QR-code binnen het kader';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return '${arg1}toevoegen als vriend?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 ontvangt je vriendschapsverzoek.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return '$arg1\'s vriendschapsverzoek accepteren?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Scan deze QR-code of deel de link om mij toe te voegen op Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Voeg me toe op Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Splyto-vriendenlink';

  @override
  String get shareAction => 'Delen';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'Een QR-code is geen geldige vriendcode.';

  @override
  String get friendsYouCannotAddYourself => 'Je kunt jezelf niet toevoegen.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Deze gebruiker staat al in je vriendenlijst.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'De uitnodiging naar deze gebruiker is al verzonden.';

  @override
  String get friendsFriendRequestProcessed => 'Vriendschapsverzoek verwerkt.';

  @override
  String get friendsFailedToProcessFriendQr => 'Het verwerken van de QR-code van een vriend is mislukt.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Je gebruikersprofiel kon niet worden geladen.';

  @override
  String get friendsMyProfile => 'Mijn profiel';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Onverwachte fout bij het laden van vrienden.';

  @override
  String get friendsFriendAdded => 'Vriend toegevoegd.';

  @override
  String get friendsRequestDeclined => 'Verzoek afgewezen.';

  @override
  String get friendsFailedToUpdateRequest => 'Het bijwerken van het verzoek is mislukt.';

  @override
  String get friendsCancelInvite => 'Uitnodiging annuleren';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Uitnodiging voor $arg1 annuleren?';
  }

  @override
  String get friendsKeep => 'Behouden';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Uitnodiging voor $arg1 geannuleerd.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Het annuleren van de uitnodiging is mislukt.';

  @override
  String get analyticsOther => 'Overige';

  @override
  String get analyticsSelectATripForAnalytics => 'Selecteer een reis voor analyses';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Leden: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Dagelijkse uitgaven';

  @override
  String get analyticsMyDaily => 'Mijn dagelijkse uitgaven';

  @override
  String get analyticsGroupDaily => 'Dagelijkse groepsuitgaven';

  @override
  String get analyticsByMember => 'Per deelnemer';

  @override
  String get analyticsShowLess => 'Minder weergeven';

  @override
  String get analyticsByCategory => 'Per categorie';

  @override
  String get analyticsQuickInsights => 'Snelle inzichten';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Grootste uitgave: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Grootste spender: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Dag met de meeste groepsdeelnemers: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Geen datums';

  @override
  String get friendsSearchFailedTryAgain => 'Zoeken mislukt. Probeer het opnieuw.';

  @override
  String get friendsFailedToSendInvite => 'Het verzenden van de uitnodiging is mislukt.';

  @override
  String get friendsAddFriend => 'Vriend toevoegen';

  @override
  String get friendsSearchByNameOrEmail => 'Zoeken op naam of e-mailadres';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Typ minimaal 2 tekens om te zoeken.';

  @override
  String get friendsNoUsersFound => 'Geen gebruikers gevonden';

  @override
  String get friendsInviteAction => 'Uitnodigen';

  @override
  String get workspacePaidForGroup => 'Betaald voor groep';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Betaald voor groep • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Kostenverdeling';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Kostenverdeling • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Naam van de houder gekopieerd.';

  @override
  String get paymentIbanCopied => 'IBAN gekopieerd.';

  @override
  String get paymentSwiftCopied => 'SWIFT gekopieerd.';

  @override
  String get paymentRevtagCopied => 'Revtag gekopieerd.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Kon niet naar het klembord kopiëren.';

  @override
  String get paymentCopied => 'Gekopieerd.';

  @override
  String get paymentRequestAction => 'Betaling aanvragen';

  @override
  String get paymentRecordAction => 'Betaling vastleggen';

  @override
  String get paymentRequestSheetTitle => 'Betaling aanvragen';

  @override
  String get paymentRecordSheetTitle => 'Betaling vastleggen';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Vraag $arg1 om een bedrag te betalen dat hij/zij je op dit moment verschuldigd is.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Gebruik dit nadat je $arg1 buiten Splyto hebt betaald. Zij zullen de ontvangst bevestigen.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Maximaal $arg1';
  }

  @override
  String get paymentNoteHint => 'Bankoverschrijving, Revolut, contant geld...';

  @override
  String get paymentAmountPositiveError => 'Het bedrag moet groter zijn dan nul.';

  @override
  String get paymentAmountTooHighError => 'Het bedrag mag niet hoger zijn dan het openstaande saldo.';

  @override
  String get paymentRequestCreated => 'Betalingsverzoek verzonden.';

  @override
  String get paymentRecordedWaiting => 'Betaling geregistreerd. In afwachting van bevestiging.';

  @override
  String get paymentConfirmTitle => 'Bevestig betaling';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Bevestig dat je $arg1 van $arg2 hebt ontvangen.';
  }

  @override
  String get paymentConfirmedMessage => 'Betaling bevestigd.';

  @override
  String get paymentCancelRecordTitle => 'Betalingsgegevens annuleren';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'De registratie van je betaling van $arg1 aan $arg2 annuleren?';
  }

  @override
  String get paymentRecordCancelled => 'Betalingsvermelding geannuleerd.';

  @override
  String get paymentNotReceivedTitle => 'Betaling niet ontvangen';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'De betaling van $arg1 van $arg2 markeren als niet ontvangen?';
  }

  @override
  String get paymentMarkedNotReceived => 'Betaling gemarkeerd als niet ontvangen.';

  @override
  String get paymentActivityTitle => 'Betalingsactiviteit';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Openstaande betaalverzoeken: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Betalingen die op bevestiging wachten: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Geregistreerde betalingen';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 heeft een betaling aangevraagd bij $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 heeft $arg2 betaald';
  }

  @override
  String get paymentRequestPendingStatus => 'Betaling aangevraagd';

  @override
  String get paymentAwaitingConfirmationStatus => 'In afwachting van bevestiging';

  @override
  String get paymentReviewRequestAction => 'Beoordelingsverzoek';

  @override
  String get paymentViewDetailsAction => 'Betalingsgegevens';

  @override
  String get paymentMarkPaidAction => 'Ik heb betaald';

  @override
  String get paymentDeclineAction => 'Weigeren';

  @override
  String get paymentRequestReviewTitle => 'Betalingsverzoek';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 heeft $arg2 bij je aangevraagd. Betaal buiten Splyto om en markeer het vervolgens als betaald.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Verzoek als betaald markeren?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Bevestig pas nadat je $arg1 hebt betaald aan $arg2 buiten Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Gemarkeerd als betaald. In afwachting van bevestiging.';

  @override
  String get paymentRequestCancelTitle => 'Betalingsverzoek annuleren?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Je betaalverzoek van $arg1 aan $arg2 annuleren?';
  }

  @override
  String get paymentRequestCancelled => 'Betalingsverzoek geannuleerd.';

  @override
  String get paymentRequestDeclineTitle => 'Betalingsverzoek afwijzen?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Het betaalverzoek van $arg2 voor $arg1 afwijzen? Deze persoon krijgt een melding.';
  }

  @override
  String get paymentRequestDeclined => 'Betalingsverzoek afgewezen.';

  @override
  String get paymentPendingBeforeFinish => 'Los openstaande betalingsverzoeken en onbevestigde betalingen op vóór de definitieve afrekening.';

  @override
  String get paymentFinishBlockedByPending => 'De voltooiing wordt ontgrendeld nadat betalingsverzoeken en onbevestigde betalingen zijn afgehandeld.';

  @override
  String get notificationPaymentRequestedTitle => 'Betaling aangevraagd';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 heeft $arg2 bij u aangevraagd.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Je hebt een betalingsverzoek ontvangen.';

  @override
  String get notificationPaymentRequestSentTitle => 'Gevraagde betaling verzonden';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 heeft je $arg2-betalingsverzoek gemarkeerd als betaald.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Je betalingsverzoek is gemarkeerd als betaald.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Betalingsverzoek geannuleerd';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 heeft het betalingsverzoek van $arg2 geannuleerd.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Een betalingsverzoek is geannuleerd.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Betalingsverzoek afgewezen';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 heeft je $arg2-betalingsverzoek afgewezen.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Uw betalingsverzoek is afgewezen.';

  @override
  String get notificationPaymentSentTitle => 'Betaling gemarkeerd als verzonden';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 heeft $arg2 gemarkeerd als aan jou betaald.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Er is een betaling gemarkeerd als naar jou verzonden.';

  @override
  String get notificationPaymentConfirmedTitle => 'Betaling bevestigd';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 heeft de ontvangst van $arg2 van jou bevestigd.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Uw betaling is bevestigd.';

  @override
  String get notificationPaymentCancelledTitle => 'Betaling geannuleerd';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 heeft de $arg2-betalingsmarkering geannuleerd.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Een betalingsmarkering is geannuleerd.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Betaling niet ontvangen';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 heeft de $arg2-betaling gemarkeerd als niet ontvangen.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Een betaling is gemarkeerd als niet ontvangen.';

  @override
  String get quickStartTitle => 'Snel aan de slag';

  @override
  String get quickStartCreateTitle => 'Alleen of met vrienden';

  @override
  String get quickStartCreateBody => 'Maak een reis voor jezelf of een groep. Voeg vrienden toe via een link of QR-code en nodig ze uit.';

  @override
  String get quickStartInviteTitle => 'Reis samen of alleen';

  @override
  String get quickStartInviteBody => 'Nodig vrienden uit om je reis te delen, of begin zelf een persoonlijke reis.';

  @override
  String get quickStartExpenseTitle => 'Uitgaven in veel valuta';

  @override
  String get quickStartExpenseBody => 'Kies wie betaald heeft en hoe je deelt. Andere valuta worden omgerekend tegen de koers van de aankoopdatum, ook als je ze later toevoegt.';

  @override
  String get quickStartSettleTitle => 'Eenvoudig afrekenen';

  @override
  String get quickStartSettleBody => 'Zie wie wat aan wie schuldig is, betaal op je eigen manier en bevestig het in de app.';

  @override
  String get quickStartAnalyticsTitle => 'Budget en uitgaven';

  @override
  String get quickStartAnalyticsBody => 'Stel een budget in voor je reis of groep en bekijk uitgaven per categorie, reis en dag.';

  @override
  String get quickStartMapTitle => 'Bewaar je plekken';

  @override
  String get quickStartMapBody => 'Voeg bezochte steden toe aan je privéreiskaart. Alleen jij kunt die zien.';

  @override
  String get quickStartLiveTitle => 'Vind elkaar';

  @override
  String get quickStartLiveBody => 'Deel op groepsreizen je live locatie voor de tijd die je kiest. Reisdeelnemers kunnen die zien en je kunt altijd stoppen.';

  @override
  String get quickStartNext => 'Volgende';

  @override
  String get quickStartBack => 'Terug';

  @override
  String get quickStartSkip => 'Overslaan';

  @override
  String get quickStartCreateAction => 'Reis aanmaken';

  @override
  String get quickStartSignUpAction => 'Registreren';

  @override
  String get quickStartClose => 'Sluit Snelstart';

  @override
  String get quickStartSubtitle => 'Bekijk hoe reizen en onkosten werken';

  @override
  String quickStartStep(int step, int total) {
    return 'Stap $step van $total';
  }

  @override
  String get workspaceTripTotal => 'Totaal van de reis';

  @override
  String get workspacePersonalTotal => 'Totaal uitgegeven';

  @override
  String get workspaceBalanceEven => 'Je saldo is vereffend';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Je bent $amount verschuldigd';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Je krijgt $amount terug';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Leden: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Uitgaven zoeken';

  @override
  String get workspaceClearSearch => 'Zoek';

  @override
  String get workspaceSearchLoadedHint => 'De zoekfunctie omvat geladen uitgaven. Laad meer om oudere uitgaven mee te nemen.';

  @override
  String get workspaceNoExpenseMatches => 'Geen overeenkomende uitgaven';

  @override
  String get workspaceNoExpenseMatchesBody => 'Probeer een andere zoekopdracht of wis deze om alle geladen uitgaven te zien.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Voeg je eerste uitgave toe om je uitgaven bij te houden.';

  @override
  String get workspaceEmptyGroupExpenses => 'Voeg je eerste gedeelde uitgave toe om het aandeel van iedereen te zien.';

  @override
  String get workspaceLoadMoreExpenses => 'Meer uitgaven laden';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Oorspronkelijk bedrag: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Opmerkingen: $count';
  }

  @override
  String get workspaceExpenseActions => 'Acties met betrekking tot uitgaven';

  @override
  String get workspaceLoadErrorTitle => 'Deze reis kon niet worden geladen';

  @override
  String get workspaceCachedWarning => 'Weergave van opgeslagen gegevens. Deze kunnen verouderd zijn.';

  @override
  String get workspaceActivityTab => 'Activiteit';

  @override
  String get workspaceLoadingTrip => 'Reis wordt geladen';

  @override
  String get workspaceRefreshFailed => 'Vernieuwen mislukt';

  @override
  String get expenseDetailsTitle => 'Uitgavendetails';

  @override
  String get expenseQuickCategories => 'Snelle categorieën';

  @override
  String get expenseReceiptUploading => 'Bon uploaden…';

  @override
  String get expenseReceiptUploadOnSave => 'De bon wordt geüpload wanneer je opslaat.';

  @override
  String get expenseCommentsLoadFailed => 'Reacties konden niet worden geladen. Probeer het opnieuw.';

  @override
  String get expenseReplyAction => 'Reageren';

  @override
  String get expenseReplyHint => 'Schrijf een antwoord…';

  @override
  String expenseReplyTo(String name) {
    return 'Beantwoord aan $name';
  }

  @override
  String get balanceEmptyBody => 'Saldi worden weergegeven nadat uitgaven zijn toegevoegd.';

  @override
  String get balanceAfterPayments => 'Saldi omvatten bevestigde betalingen.';

  @override
  String get balanceExpenseShare => 'Kostenverdeling';

  @override
  String get balanceHistoryScope => 'Geüploade uitgaven en bevestigde betalingen. Deze lijst bevat mogelijk niet de volledige reisgeschiedenis.';

  @override
  String balancePaymentTo(String name) {
    return 'Betaling aan $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Betaling van $name';
  }

  @override
  String get settlementEmptyActive => 'Markeer iedereen als ‘klaar’ voordat je begint met de eindafrekening.';

  @override
  String get settlementEmptyClosed => 'Er zijn geen overboekingen vermeld voor deze reis.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count van $total overboekingen bevestigd';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count van $total leden zijn klaar';
  }

  @override
  String get settlementMemberReady => 'Klaar';

  @override
  String get settlementMemberNotReady => 'Nog niet klaar';

  @override
  String get settlementSuggested => 'Voorgestelde overboeking';

  @override
  String get activityLoadFailed => 'De activiteit kon niet worden vernieuwd. Eventuele zichtbare vermeldingen zijn mogelijk verouderd.';

  @override
  String get activityMember => 'Reisdeelnemer';

  @override
  String get friendsEmptyBody => 'Zoek een vriend op naam of e-mailadres, of gebruik een QR-code.';

  @override
  String get friendsDeclineAction => 'Weigeren';

  @override
  String get friendsLoading => 'Vrienden worden geladen';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Gedeelde reizen: $count';
  }

  @override
  String get memberActivityScope => 'Gebaseerd op ingevoerde uitgaven; dit dekt mogelijk niet de gehele reis.';

  @override
  String get sharedTripsLoadedLimit => 'Er worden maximaal 20 gedeelde reizen weergegeven.';

  @override
  String get memberRemoveTitle => 'Lid verwijderen?';

  @override
  String memberRemoveBody(String name) {
    return '$name uit deze reis verwijderen? Dit is alleen mogelijk als er geen uitgaven, afrekeningen of saldi zijn.';
  }

  @override
  String get memberRemoveAction => 'Verwijderen uit de reis';

  @override
  String memberRemoved(String name) {
    return '$name is uit de reis verwijderd.';
  }

  @override
  String get profilePaymentNotAdded => 'Nog niet toegevoegd';

  @override
  String get friendRelationshipLabel => 'Vriend';

  @override
  String get sharedTripsEmptyBody => 'Reizen waaraan jullie beiden deelnemen, verschijnen hier.';

  @override
  String get analyticsAllTrips => 'Alle reizen';

  @override
  String get analyticsByTrip => 'Per reis';

  @override
  String get analyticsYourSpending => 'Je uitgaven';

  @override
  String get analyticsActiveArchived => 'Actieve en gearchiveerde reizen';

  @override
  String get analyticsTrips => 'Reizen';

  @override
  String get analyticsAveragePerTrip => 'Gemiddelde per reis';

  @override
  String get analyticsPaidByMember => 'Betaald door lid';

  @override
  String get analyticsYouPaid => 'Je hebt betaald.';

  @override
  String get analyticsYouGetBack => 'Je krijgt terug';

  @override
  String get analyticsYouOwe => 'Je bent verschuldigd';

  @override
  String get analyticsPaidForOthers => 'Betaald voor anderen';

  @override
  String get analyticsOthersPaidForYou => 'Anderen betaalden voor jou';

  @override
  String get analyticsParticipants => 'Deelnemers';

  @override
  String get analyticsYourCategories => 'Uw uitgaven per categorie';

  @override
  String get analyticsTripTotalByCategory => 'Reistotaal per categorie';

  @override
  String get analyticsLargestShares => 'Mijn grootste kostenaandelen';

  @override
  String get analyticsLargestExpenses => 'Grootste uitgaven';

  @override
  String get analyticsSpendingByTrip => 'Uw uitgaven per reis';

  @override
  String get analyticsEmptyTitle => 'Nog geen uitgaven';

  @override
  String get analyticsEmptyBody => 'Je uitgaven verschijnen hier wanneer je uitgaven aan een reis toevoegt.';

  @override
  String get analyticsPeriodEmptyBody => 'Er zijn geen kosten verbonden aan deze weergave. Probeer een andere reis of periode.';

  @override
  String get analyticsLoadFailed => 'Het volledige uitgavenoverzicht kon niet worden geladen. Probeer het opnieuw.';

  @override
  String get analyticsLastLoaded => 'Het laat het laatst succesvol geladen rapport zien.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uitgaven',
      one: '$count uitgave',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Reisopties';

  @override
  String get editTripAction => 'Reis bewerken';

  @override
  String get deleteTripAction => 'Reis verwijderen';

  @override
  String get inviteTripMembersAction => 'Leden uitnodigen';

  @override
  String get tripCoverPhoto => 'Omslagfoto';

  @override
  String get tripInviteLaterHint => 'Je kunt mensen uitnodigen nadat je de reis hebt aangemaakt.';

  @override
  String get inviteClipboardFailed => 'Toegang tot het klembord is niet mogelijk. Probeer het opnieuw.';

  @override
  String get friendInviteToTrip => 'Uitnodigen voor een reis';

  @override
  String get friendChooseTrip => 'Kies een reis';

  @override
  String get friendNoInvitableTrips => 'Er zijn geen beschikbare reizen. Je kunt vrienden uitnodigen voor actieve groepsreizen die je beheert, tenzij ze al lid zijn of een uitstaande uitnodiging hebben.';

  @override
  String get friendTripInviteSent => 'Uitnodiging verzonden.';

  @override
  String get friendTripUnavailable => 'Deze reis is niet langer beschikbaar voor deze actie. Vernieuw de pagina en probeer het opnieuw.';

  @override
  String get friendTripActionFailed => 'Deze actie kon niet worden voltooid. Probeer het opnieuw.';

  @override
  String get profileContactDescription => 'Heb je een probleem, een suggestie of een vraag over Splyto? Stuur ons een e-mail — we helpen je graag verder.';

  @override
  String get profileContactEmailAction => 'Schrijf een e-mail';

  @override
  String get profileContactEmailUnavailable => 'De e-mailapp kon niet worden geopend. Kopieer het adres en stuur ons een e-mail vanuit je eigen e-mailapp.';

  @override
  String get profilePrivacyPolicy => 'Privacybeleid';

  @override
  String get privacyLoadFailed => 'Het privacybeleid kon niet worden geladen. Probeer het opnieuw.';

  @override
  String get addReceiptAction => 'Ontvangstbewijs toevoegen';

  @override
  String get receiptPickFailed => 'Het ontvangstbewijs kon niet worden geladen. Probeer het opnieuw.';

  @override
  String get receiptPhotoAccessDenied => 'Geef Splyto in de Instellingen toegang tot de camera of fotobibliotheek en probeer het vervolgens opnieuw.';

  @override
  String get receiptPhotoLabel => 'Foto van de bon';

  @override
  String get replaceReceiptAction => 'Vervang \'ontvangstbewijs\'';

  @override
  String get removeReceiptAction => 'Ontvangstbewijs verwijderen';

  @override
  String get restoreReceiptAction => 'Vorige ontvangstbewijs herstellen';

  @override
  String get expenseSplitBetween => 'Verdeling tussen';

  @override
  String get expenseEditParticipants => 'Kies deelnemers';

  @override
  String get expenseCustomSplit => 'Aangepaste verdeling';

  @override
  String get expenseAdjustmentsLabel => 'Aanpassingen';

  @override
  String get expenseAdjustmentFieldLabel => '+ of −';

  @override
  String get expenseAdjustmentsHint => 'Tel op of trek af per persoon. De rest wordt gelijk verdeeld.';

  @override
  String get expenseAdjustmentsMustFit => 'Aanpassingen mogen het totaal niet overschrijden en niemand kan minder dan nul schuldig zijn.';

  @override
  String get expenseItemsLabel => 'Items';

  @override
  String get expenseAddItem => 'Item toevoegen';

  @override
  String get expenseRemoveItem => 'Item verwijderen';

  @override
  String get expenseItemName => 'Item';

  @override
  String get expenseItemExtra => 'Belasting of fooi';

  @override
  String get expenseItemExtraHint => 'Verdeeld naar verhouding van ieders items.';

  @override
  String get expenseItemsInvalid => 'Elk item heeft een naam, een bedrag en minstens één persoon nodig.';

  @override
  String expenseItemsTotal(String total) {
    return 'Totaal van items: $total';
  }

  @override
  String expenseItemsMustMatchTotal(String total) {
    return 'Items moeten samen $total zijn.';
  }

  @override
  String get tripGuestAddAction => 'Persoon zonder app toevoegen';

  @override
  String get tripGuestNameLabel => 'Naam';

  @override
  String get tripGuestAddHint => 'Deze persoon heeft de app niet nodig. Jij voert in wat diegene betaalde en markeert de betalingen.';

  @override
  String get tripGuestBadge => 'Zonder app';

  @override
  String get tripGuestRenameAction => 'Naam wijzigen';

  @override
  String tripGuestAdded(String name) {
    return '$name toegevoegd';
  }

  @override
  String expenseSplitAllocated(String amount) {
    return 'Alle $amount verdeeld';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Nog $amount te verdelen';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount boven het totaal';
  }

  @override
  String get profilePaymentSharingTitle => 'Betaalmethoden delen met mijn reizen';

  @override
  String get profilePaymentSharingDescription => 'Geef geaccepteerde deelnemers van reizen die ik aanmaak of waaraan ik deelneem toegang tot mijn betaalmethoden. Dit geldt voor huidige en toekomstige reizen. Je kunt dit op elk moment uitschakelen om verdere toegang te voorkomen.';

  @override
  String get memberPaymentDetailsNotShared => 'Betaalmethoden worden niet gedeeld of zijn momenteel niet beschikbaar.';

  @override
  String get homeTripInvitations => 'Uitnodigingen voor reizen';

  @override
  String get homeNoTripInvitations => 'Geen uitstaande reisuitnodigingen';

  @override
  String get homeInvitationsLoadFailed => 'Uitnodigingen konden niet worden geladen. Probeer het nogmaals.';

  @override
  String get homeInvitationResponseFailed => 'De uitnodiging kon niet worden beantwoord. Probeer het nogmaals.';

  @override
  String get homeTripShareFailed => 'De reis kon niet worden gedeeld. Probeer het opnieuw.';

  @override
  String get settleStillToReceive => 'Nog te ontvangen';

  @override
  String get settleStillToPay => 'Nog te betalen';

  @override
  String get settleEstimateCaption => 'Schatting op basis van huidige uitgaven. Bedragen kunnen veranderen totdat de reis is afgelopen.';

  @override
  String get settleOutstandingCaption => 'In afwachting van betaling of bevestiging.';

  @override
  String get settleWaitingForYou => 'We wachten tot je aangeeft dat je klaar bent.';

  @override
  String get settleWhoPaysWhom => 'Wie betaalt wie?';

  @override
  String get settlePreviewCaption => 'Voorbeeld · afgerond wanneer de reis eindigt';

  @override
  String get settleOpenPaymentCaption => 'Open een betaling om de details en beschikbare acties te bekijken.';

  @override
  String get tripBudgetEnable => 'Stel een budget vast';

  @override
  String get tripBudgetSoloHint => 'Optioneel uitgavendoel voor deze reis.';

  @override
  String get tripBudgetGroupHint => 'Eén gedeeld budget voor de hele groep.';

  @override
  String get tripBudgetAmount => 'Budgetbedrag';

  @override
  String get tripBudgetInvalid => 'Voer een bedrag in van 0,01 tot 999999999,99, met maximaal twee decimalen.';

  @override
  String get tripBudgetTitle => 'Reisbudget';

  @override
  String get tripBudgetGroupTitle => 'Groepsbudget';

  @override
  String get tripBudgetRemaining => 'Resterend';

  @override
  String get tripBudgetOver => 'Boven het budget';

  @override
  String get tripBudgetSpent => 'Uitgegeven';

  @override
  String get tripBudgetLimit => 'Budget';

  @override
  String get travelMapTitle => 'Mijn reiskaart';

  @override
  String get travelMapSubtitle => 'Bezochte plaatsen, speciaal voor jou.';

  @override
  String get travelMapHere => 'Ik ben hier al';

  @override
  String get travelMapAdd => 'Plaats toevoegen';

  @override
  String get travelMapSearch => 'Zoek stad en land';

  @override
  String get travelMapSearchAction => 'Zoeken';

  @override
  String get travelMapSearchHint => 'Bijvoorbeeld: Lissabon, Portugal';

  @override
  String get travelMapEmpty => 'Je volgende herinnering begint hier';

  @override
  String get travelMapEmptyBody => 'Voeg een stad toe die je hebt bezocht, of check in op de plek waar je nu bent.';

  @override
  String get travelMapConfirm => 'Dit bezoek opslaan?';

  @override
  String get travelMapConfirmBody => 'Controleer de stad en de datum voordat je deze op je privékkaart opslaat.';

  @override
  String get travelMapDate => 'Bezoekdatum';

  @override
  String get travelMapSave => 'Opslaan op mijn kaart';

  @override
  String get travelMapCancel => 'Annuleren';

  @override
  String get travelMapClose => 'Sluiten';

  @override
  String get travelMapNoResults => 'Er is geen stad gevonden. Probeer het land aan je zoekopdracht toe te voegen.';

  @override
  String get travelMapLookupError => 'De stad kon niet worden gevonden. Controleer je verbinding of voeg handmatig een plaats toe.';

  @override
  String get travelMapDenied => 'Toegang tot locatie is uitgeschakeld. Je kunt nog steeds handmatig een stad toevoegen.';

  @override
  String get travelMapDisabled => 'Schakel locatiediensten in of voeg handmatig een stad toe.';

  @override
  String get travelMapError => 'Je reiskaart kon niet worden geladen. Probeer het nog eens.';

  @override
  String get travelMapSaveError => 'Het bezoek kon niet worden opgeslagen. Probeer het opnieuw.';

  @override
  String get travelMapUnavailable => 'De reiskaart heeft een serverupdate nodig.';

  @override
  String get travelMapOffline => 'Offline · opgeslagen plaatsen weergeven';

  @override
  String get travelMapRetry => 'Opnieuw proberen';

  @override
  String get travelMapDelete => 'Bezoek verwijderen';

  @override
  String get travelMapDeleteConfirm => 'Wil je dit bezoek van je privékkaart verwijderen?';

  @override
  String get travelMapFit => 'Alle plaatsen weergeven';

  @override
  String get travelMapSaved => 'Bezoek opgeslagen';

  @override
  String get travelMapVisited => 'Bezocht';

  @override
  String get travelMapLimit => 'Je kaart heeft 1.000 bezoeken bereikt. Verwijder een oud bezoek voordat je een nieuw toevoegt.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries landen',
      one: '$countries land',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities steden',
      one: '$cities stad',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bezoeken',
      one: '$count bezoek',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Bestemmingen (optioneel)';

  @override
  String get travelAddDestination => 'Bestemming toevoegen';

  @override
  String get travelRemoveDestination => 'Bestemming verwijderen';

  @override
  String get travelFromTrip => 'Vanuit een reis';

  @override
  String get travelChooseTrip => 'Kies een reis';

  @override
  String get travelNoTrips => 'Er zijn nog geen reizen beschikbaar. Je kunt handmatig een locatie toevoegen.';

  @override
  String get travelAddToMap => 'Toevoegen aan mijn kaart';

  @override
  String get travelTripConfirm => 'Sla alleen plaatsen op die je daadwerkelijk hebt bezocht. Dit voegt een persoonlijke herinnering toe aan je kaart.';

  @override
  String get travelVisitTitle => 'Titel (optioneel)';

  @override
  String get travelAddPhoto => 'Voeg een foto toe';

  @override
  String get travelChangePhoto => 'Foto wijzigen';

  @override
  String get travelRemovePhoto => 'Foto verwijderen';

  @override
  String get travelPhotoError => 'Deze foto kon niet worden voorbereid. Kies er een andere.';

  @override
  String get travelEditVisit => 'Bezoek bewerken';

  @override
  String get travelOpenTrip => 'Reis starten';

  @override
  String get travelPreviousVisit => 'Vorige bezoek';

  @override
  String get travelNextVisit => 'Volgend bezoek';

  @override
  String get travelDuplicate => 'Dit bezoek staat al op je kaart.';

  @override
  String get liveMapTitle => 'Livekaart';

  @override
  String get liveShareTitle => 'Deel mijn locatie';

  @override
  String get liveConsent => 'Deel je exacte locatie alleen met geaccepteerde deelnemers van deze reis, gedurende de periode die je kiest. Het delen gaat op de achtergrond door en je kunt het op elk moment stoppen.';

  @override
  String get liveBackgroundNote => 'Updates kunnen worden onderbroken zonder internetverbinding of als je de app geforceerd sluit. Alleen de meest recente locatie wordt bewaard; er wordt geen routegeschiedenis vastgelegd.';

  @override
  String get liveStart => 'Begin met delen';

  @override
  String get liveStop => 'Deel niet langer';

  @override
  String get liveNotification => 'Je locatie wordt gedeeld met je reis. Open Splyto om het delen te stoppen.';

  @override
  String get livePermissionError => 'Sta locatietoegang toe in de instellingen van je telefoon om je locatie te delen.';

  @override
  String get liveStartError => 'Het delen kon niet worden gestart. Controleer de toegang tot de locatie, de internetverbinding en de datum en tijd van je telefoon.';

  @override
  String get liveStopPending => 'Updates zijn gestopt. We wachten op internetverbinding om je laatste locatie te verwijderen; deze verdwijnt binnen 2 minuten van de kaart als er geen updates plaatsvinden.';

  @override
  String get liveSharing => 'deelt locatie';

  @override
  String get liveUnavailable => 'Deze livekaart is niet beschikbaar. Ga terug naar de reis en vernieuw de pagina.';

  @override
  String get liveMapLoadError => 'De kaart kon niet worden geladen. Controleer je verbinding en open de kaart opnieuw.';

  @override
  String get liveLoadError => 'Locaties konden niet worden vernieuwd. Alleen recente updates worden weergegeven.';

  @override
  String get liveFit => 'Iedereen op de kaart tonen';

  @override
  String get liveEmpty => 'Niemand deelt op dit moment een recente locatie.';

  @override
  String get liveRecent => 'Zojuist bijgewerkt';

  @override
  String get liveLastKnown => 'Laatst bijgewerkt';

  @override
  String get liveAccuracy => 'Nauwkeurigheid';

  @override
  String get liveUntil => 'Delen tot';

  @override
  String get liveOtherSession => 'Gestart in een andere sessie. Je kunt het hier stoppen.';

  @override
  String get liveUpdatesPaused => 'Updates zijn gepauzeerd. Controleer de toegang tot de locatie en de internetverbinding.';

  @override
  String get livePrivateUntilShared => 'Je locatie blijft privé totdat je ervoor kiest deze te delen.';

  @override
  String get activityEventExpenseCreated => 'heeft een uitgave toegevoegd';

  @override
  String get activityEventExpenseUpdated => 'heeft een uitgave bijgewerkt';

  @override
  String get activityEventExpenseDeleted => 'heeft een uitgave verwijderd';

  @override
  String get activityEventExpenseCommentAdded => 'heeft gereageerd op een uitgave';

  @override
  String get activityEventTripCreated => 'heeft de reis aangemaakt';

  @override
  String get activityEventTripUpdated => 'heeft de reisgegevens bijgewerkt';

  @override
  String get activityEventTripRenamed => 'heeft de reis hernoemd';

  @override
  String get activityEventTripCurrencyChanged => 'heeft de reisvaluta gewijzigd';

  @override
  String get activityEventTripPhotoChanged => 'heeft de reisfoto gewijzigd';

  @override
  String get activityEventTripBudgetChanged => 'heeft het reisbudget gewijzigd';

  @override
  String get activityEventTripDestinationsChanged => 'heeft de reisbestemmingen gewijzigd';

  @override
  String get activityEventTripMembersAdded => 'heeft deelnemers toegevoegd';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'heeft uitnodigingen verzonden: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'heeft zich bij de reis aangesloten';

  @override
  String get activityEventTripInvitationDeclined => 'heeft de reisuitnodiging afgewezen';

  @override
  String get activityEventTripInvitationRevoked => 'heeft een reisuitnodiging geannuleerd';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'heeft $name uit de reis verwijderd';
  }

  @override
  String get activityEventTripMemberLeft => 'heeft de reis verlaten';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'heeft de rol van $name gewijzigd in $role';
  }

  @override
  String get activityEventTripMemberReady => 'heeft aangegeven klaar te zijn om af te rekenen';

  @override
  String get activityEventTripMemberNotReady => 'heeft aangegeven nog niet klaar te zijn';

  @override
  String get activityEventTripAllMembersReady => 'Alle deelnemers zijn klaar om af te rekenen';

  @override
  String get activityEventTripFinished => 'heeft de reis voltooid';

  @override
  String get activityEventTripSettled => 'Alle overschrijvingen zijn bevestigd, de reis is afgerekend';

  @override
  String get activityEventSettlementMarkedSent => 'heeft een overschrijving gemarkeerd als verzonden';

  @override
  String get activityEventSettlementConfirmed => 'heeft een overschrijving bevestigd';

  @override
  String get activityEventSettlementSentCancelled => 'heeft de status ‘verzonden’ geannuleerd';

  @override
  String get activityEventSettlementNotReceived => 'heeft een overschrijving gemarkeerd als niet ontvangen';

  @override
  String get activityEventSettlementReminderSent => 'heeft een betalingsherinnering verzonden';

  @override
  String get activityEventPaymentMarkedSent => 'heeft een betaling geregistreerd';

  @override
  String get activityEventPaymentRequested => 'heeft een betaling aangevraagd';

  @override
  String get activityEventPaymentRequestMarkedSent => 'heeft een aangevraagde betaling gemarkeerd als verzonden';

  @override
  String get activityEventPaymentRequestCancelled => 'heeft een betalingsverzoek geannuleerd';

  @override
  String get activityEventPaymentRequestDeclined => 'heeft een betalingsverzoek afgewezen';

  @override
  String get activityEventPaymentConfirmed => 'heeft een betaling bevestigd';

  @override
  String get activityEventPaymentCancelled => 'heeft een betalingsrecord geannuleerd';

  @override
  String get activityEventPaymentNotReceived => 'heeft een betaling gemarkeerd als niet ontvangen';

  @override
  String get activityEventUnknown => 'heeft een wijziging aangebracht';

  @override
  String get privacyEnglishFallback => 'Het privacybeleid is momenteel beschikbaar in het Engels.';

  @override
  String get activityRoleAdmin => 'Beheerder';

  @override
  String get accountDeleteTitle => 'Account verwijderen';

  @override
  String get accountDeleteIntro => 'Bevestig de verwijdering via e-mail. Na bevestiging kan dit niet ongedaan worden gemaakt.';

  @override
  String get accountDeleteConsequences => 'Verwijdering is definitief. Je profiel wordt geanonimiseerd en de toegang tot je account wordt ingetrokken. Gedeelde reis- en onkostendossiers blijven bewaard voor andere leden.';

  @override
  String get accountDeleteReasonsTitle => 'Wat hadden we beter kunnen doen?';

  @override
  String get accountDeleteReasonsHint => 'Reden (optioneel)';

  @override
  String get accountDeleteReasonNotUsing => 'Ik heb Splyto niet langer nodig voor mijn reizen';

  @override
  String get accountDeleteReasonAnotherWay => 'Ik beheer gedeelde uitgaven op een andere manier';

  @override
  String get accountDeleteReasonComplicated => 'Het kost te veel moeite om dingen voor elkaar te krijgen';

  @override
  String get accountDeleteReasonTechnical => 'Ik ben bugs of technische problemen tegengekomen';

  @override
  String get accountDeleteReasonPrivacy => 'Ik wil mijn accountgegevens liever verwijderen';

  @override
  String get accountDeleteReasonOther => 'Ik vertrek om een andere reden';

  @override
  String get accountDeleteEmailStep => 'De volgende stap is bevestiging per e-mail.';

  @override
  String get accountDeletePasswordHint => 'Voer je huidige Splyto-wachtwoord in om de bevestigingsmail aan te vragen. Je account is nog steeds actief.';

  @override
  String get accountDeleteInboxTitle => 'Nog één laatste stap in je inbox';

  @override
  String accountDeleteSentBody(String email) {
    return 'Bevestigingslink verzonden naar $email.';
  }

  @override
  String get accountDeleteSentHint => 'Je account blijft actief totdat je de verwijdering bevestigt.';

  @override
  String get accountDeleteSending => 'Bevestigingsmail versturen';

  @override
  String get friendsShowMore => 'Meer tonen';

  @override
  String get tripReportTitle => 'Reisrapport';

  @override
  String get tripReportDetailedTitle => 'Gedetailleerd reisrapport';

  @override
  String get tripReportDates => 'Data';

  @override
  String get tripReportDestinations => 'Bestemmingen';

  @override
  String get tripReportTotalSpent => 'Totaal uitgegeven';

  @override
  String get tripReportExpenses => 'Uitgaven';

  @override
  String get tripReportYouPaid => 'Jij betaalde';

  @override
  String get tripReportYourShare => 'Jouw deel';

  @override
  String get tripReportYourBalance => 'Jouw saldo';

  @override
  String get tripReportYourSettlements => 'Jouw afrekeningen';

  @override
  String tripReportYouPay(Object arg1) {
    return 'Jij betaalt $arg1';
  }

  @override
  String tripReportPaysYou(Object arg1) {
    return '$arg1 betaalt jou';
  }

  @override
  String get tripReportStatus => 'Status';

  @override
  String get tripReportStatusPending => 'Open';

  @override
  String get tripReportStatusSent => 'Verzonden';

  @override
  String get tripReportStatusConfirmed => 'Bevestigd';

  @override
  String get tripReportNoSettlements => 'Je hoeft niets af te rekenen.';

  @override
  String get tripReportByCategory => 'Uitgaven per categorie';

  @override
  String get tripReportCategory => 'Categorie';

  @override
  String get tripReportAmount => 'Bedrag';

  @override
  String get tripReportMembers => 'Leden';

  @override
  String get tripReportMember => 'Lid';

  @override
  String get tripReportPaid => 'Betaald';

  @override
  String get tripReportShare => 'Deel';

  @override
  String get tripReportBalance => 'Saldo';

  @override
  String get tripReportAllExpenses => 'Alle uitgaven';

  @override
  String get tripReportDate => 'Datum';

  @override
  String get tripReportDescription => 'Omschrijving';

  @override
  String get tripReportPaidBy => 'Betaald door';

  @override
  String get tripReportOriginalAmount => 'Oorspronkelijk bedrag';

  @override
  String get tripReportCurrency => 'Valuta';

  @override
  String get tripReportRate => 'Koers';

  @override
  String get tripReportPayments => 'Betalingen';

  @override
  String get tripReportFrom => 'Van';

  @override
  String get tripReportTo => 'Aan';

  @override
  String get tripReportFooter => 'Gemaakt met Splyto';

  @override
  String tripReportEmailSubject(Object arg1) {
    return 'Je reisrapport: $arg1';
  }

  @override
  String get tripReportEmailTitle => 'Je reisrapport staat klaar';

  @override
  String tripReportEmailGreeting(Object arg1) {
    return 'Hallo $arg1,';
  }

  @override
  String tripReportEmailBody(Object arg1) {
    return '$arg1 is afgerond. Je rapport zit als pdf in de bijlage.';
  }

  @override
  String get tripReportEmailOptOut => 'Je kunt deze e-mails uitzetten in Profiel, onder Meldingen.';

  @override
  String get tripReportEmailSetting => 'Reisrapport per e-mail';

  @override
  String get tripReportEmailSettingSubtitle => 'Ontvang een pdf-overzicht als een reis is afgerond.';

  @override
  String get tripExportAction => 'Reisdetails exporteren';

  @override
  String get tripExportPdf => 'Gedetailleerde pdf';

  @override
  String get tripExportCsv => 'Spreadsheet (CSV)';

  @override
  String get tripExportFailed => 'De export kon niet worden gemaakt. Probeer het opnieuw.';

  @override
  String get yearSummaryTitle => 'Jouw reisjaar';

  @override
  String get yearSummarySubtitle => 'Je reizen, plekken en uitgaven van het jaar.';

  @override
  String yearSummaryEmpty(Object arg1) {
    return 'Geen afgeronde reizen in $arg1.';
  }

  @override
  String get yearSummaryLoadFailed => 'Je reisjaar kon niet worden geladen.';

  @override
  String get yearSummaryTrips => 'Reizen';

  @override
  String get yearSummaryDays => 'Dagen op reis';

  @override
  String get yearSummaryCountries => 'Landen';

  @override
  String get yearSummaryCities => 'Steden';

  @override
  String get yearSummarySpending => 'Jouw uitgaven';

  @override
  String get yearSummaryBiggestTrip => 'Grootste reis';

  @override
  String get yearSummaryTopCategory => 'Topcategorie';

  @override
  String get yearSummaryTopCompanion => 'De meeste reizen met';

  @override
  String yearSummaryTripsTogether(Object arg1) {
    return 'Reizen samen: $arg1';
  }

  @override
  String get yearSummaryPartial => 'Sommige bedragen ontbreken omdat er geen wisselkoers beschikbaar was.';

  @override
  String get yearSummaryShare => 'Delen';

  @override
  String get yearSummaryShareFailed => 'De afbeelding kon niet worden gedeeld.';

  @override
  String get yearSummaryRetry => 'Opnieuw proberen';

  @override
  String get notificationCommentAddedTitle => 'Nieuwe reactie op je uitgave';

  @override
  String notificationCommentAddedBody(Object name, Object note) {
    return '$name reageerde op \"$note\".';
  }

  @override
  String notificationCommentAddedBodyGeneric(Object name) {
    return '$name reageerde op je uitgave.';
  }

  @override
  String get profilePushCommentsTitle => 'Reacties en vermeldingen';

  @override
  String get profilePushCommentsSubtitle => 'Nieuwe reacties op je uitgaven en vermeldingen van jou';

  @override
  String get profilePushTripInvitesTitle => 'Reisuitnodigingen en leden';

  @override
  String get profilePushTripInvitesSubtitle => 'Uitnodigingen en mensen die een reis joinen of verlaten';

  @override
  String get profilePushTripStatusTitle => 'Reisstatus';

  @override
  String get profilePushTripStatusSubtitle => 'Reis afgerond en klaar om te verrekenen';

  @override
  String get profilePushPaymentRequestsTitle => 'Betaalverzoeken';

  @override
  String get profilePushPaymentRequestsSubtitle => 'Ontvangen, geweigerde of geannuleerde verzoeken';

  @override
  String get profilePushPaymentsTitle => 'Betalingen';

  @override
  String get profilePushPaymentsSubtitle => 'Betalingen gemarkeerd als verzonden, bevestigd of niet ontvangen';

  @override
  String get profilePushRemindersTitle => 'Herinneringen';

  @override
  String get profilePushRemindersSubtitle => 'Herinneringen aan openstaande betalingen';

  @override
  String get notificationLiveLocationTitle => 'Live locatie gedeeld';

  @override
  String notificationLiveLocationBody(Object name, Object trip) {
    return '$name deelt nu de live locatie in \"$trip\".';
  }

  @override
  String get profilePushLocationTitle => 'Live locatie';

  @override
  String get profilePushLocationSubtitle => 'Als iemand in je reis zijn locatie begint te delen';

  @override
  String get expenseSplitMethodTitle => 'Verdeelmethode';

  @override
  String get expenseSplitExactHint => 'Vul in wat iedereen betaalt';

  @override
  String get expenseSplitPercentHint => 'Iedereen betaalt een percentage';

  @override
  String get expenseSplitSharesHint => 'Verdeel in delen, bijv. 2 : 1 : 1';

  @override
  String get expenseSplitAdjustmentHint => 'Gelijk verdeeld, met een plus of min per persoon';

  @override
  String get expenseSplitItemsHint => 'Iedereen betaalt zijn eigen items';

  @override
  String get tripsSearchFriends => 'Vrienden zoeken';

  @override
  String get expenseSplitEvenly => 'Gelijk verdelen';

  @override
  String expensePaidByName(Object name) {
    return '$name betaalde';
  }

  @override
  String get workspaceChooseCategory => 'Kies categorie';

  @override
  String get workspaceExpenseFilters => 'Uitgavenfilters';

  @override
  String get workspaceClearFilters => 'Filters wissen';

  @override
  String get workspaceFiltersLoadedHint => 'De filters gelden voor geladen uitgaven. Laad meer om oudere uitgaven mee te nemen.';

  @override
  String get workspaceFiltersNoMatchesHint => 'Wijzig of wis de filters om alle geladen uitgaven te zien.';
}
