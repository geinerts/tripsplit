// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get homeFirstTrip => 'Deine erste Reise';

  @override
  String get homeYourShareAllTrips => 'Dein Anteil an allen Reisen';

  @override
  String get homeAllTime => 'Gesamter Zeitraum';

  @override
  String get homeSolo => 'Allein';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '$count Person',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Reiseaktionen: $name';
  }

  @override
  String get homeNoActiveTrips => 'Keine aktiven Reisen';

  @override
  String get homeNoArchivedTrips => 'Keine archivierten Reisen';

  @override
  String get homeLoadingTrips => 'Laden Ihrer Reisen';

  @override
  String get homeLoadErrorTitle => 'Ihre Reisen konnten nicht geladen werden';

  @override
  String get homeLoadErrorBody => 'Bitte versuche es in einem Moment erneut.';

  @override
  String get homeOfflineTitle => 'Sie sind offline';

  @override
  String get homeOfflineNoData => 'Deine Reisen sind auf diesem Gerät noch nicht verfügbar.';

  @override
  String get homeOfflineCached => 'Offline. Anzeige gespeicherter Reisen.';

  @override
  String get homeRefreshError => 'Aktualisierung nicht möglich. Es werden zuvor geladene Reisen angezeigt.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Meine gespeicherten Zahlungsdaten mit $arg1 teilen';
  }

  @override
  String get paymentShareDetailsScope => 'Nur solange diese Anfrage auf eine Zahlung wartet. Durch das Stornieren der Anfrage wird der Zugriff beendet.';

  @override
  String get paymentDetailsUnavailable => 'Zahlungsdetails sind nicht verfügbar. Stellen Sie eine Internetverbindung her und überprüfen Sie, ob die Anfrage noch offen ist.';

  @override
  String get paymentDetailsRetry => 'Versuchen Sie es erneut';

  @override
  String get tripModeSolo => 'Nur ich';

  @override
  String get tripModeGroup => 'Mit anderen';

  @override
  String get premiumFree => 'Kostenlos';

  @override
  String get premiumStatusUnavailable => 'Planstatus nicht verfügbar';

  @override
  String premiumGrantedUntil(String date) {
    return 'Premium-Zugang gewährt bis $date';
  }

  @override
  String get premiumBillingNotActive => 'Kein aktives Abonnement';

  @override
  String get premiumRefreshStatus => 'Planstatus aktualisieren';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String get activeStatus => 'Aktiv';

  @override
  String get activeTripPlural => 'aktive Reisen';

  @override
  String get activeTripSingle => 'aktive Reise';

  @override
  String get activeTrips => 'Aktive Reisen';

  @override
  String get activitiesComingSoon => 'Der Abschnitt „Aktivitäten“ folgt in Kürze.';

  @override
  String get addAction => 'Hinzufügen';

  @override
  String get addExpenseTitle => 'Ausgabe hinzufügen';

  @override
  String get addExpensesAction => 'Ausgaben hinzufügen';

  @override
  String get addMembersAction => 'Mitglieder hinzufügen';

  @override
  String get addTripMembersTitle => 'Reiseteilnehmer einladen';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einladungen gesendet',
      one: '$count Einladung gesendet',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Reiseeinladung abgelehnt.';

  @override
  String get tripInviteAction => 'Einladen';

  @override
  String get tripInvitationsPending => 'Warten auf Antwort';

  @override
  String get tripInvitationsRetry => 'Einladungen nicht verfügbar. Bitte versuchen Sie es erneut.';

  @override
  String get tripInvitationRevoke => 'Einladung widerrufen';

  @override
  String get tripInvitationRevokeFailed => 'Die Einladung konnte nicht storniert werden. Bitte versuche es erneut.';

  @override
  String get tripInvitationBody => 'Du wurdest zu einer Reise eingeladen. Öffne die Einladung, um zu antworten.';

  @override
  String get allCaughtUp => 'Alles auf dem neuesten Stand';

  @override
  String get allFilter => 'Alle';

  @override
  String get allMembersLabel => 'Alle Mitglieder';

  @override
  String get allPaymentsConfirmed => 'Alle Zahlungen werden bestätigt.';

  @override
  String get allTrips => 'Alle Reisen';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Betrag';

  @override
  String get amountMustBeGreaterThanZero => 'Der Betrag muss größer als 0 sein.';

  @override
  String get appearance => 'Darstellung';

  @override
  String get archivedStatus => 'Archiviert';

  @override
  String get authSubtitleLogin => 'Reisekosten mit Freunden aufteilen';

  @override
  String get authSubtitleRegister => 'Erstelle ein Konto und beginne mit der Aufteilung von Reisen';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'bestätigt: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'Ausstehend: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'gesendet: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'Vorschlag: $count';
  }

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get changeEmailWithPasswordHelper => 'Geben Sie Ihr Passwort ein, um die E-Mail-Adresse zu ändern.';

  @override
  String get chooseReceiptFile => 'Belegdatei auswählen';

  @override
  String get completeAccountSetupDescription => 'Geben Sie Ihre E-Mail-Adresse und Ihr Passwort ein, um Ihr Konto zu vervollständigen.';

  @override
  String get completeAccountSetupTitle => 'Kontoeinrichtung abschließen';

  @override
  String get confirmReceivedAction => 'Erhalt bestätigen';

  @override
  String get confirmedAllSettlementsArchived => 'Alle Abrechnungen bestätigt. Reise archiviert.';

  @override
  String get confirmedAsReceived => 'Als erhalten bestätigt.';

  @override
  String get confirmedLabel => 'Bestätigt';

  @override
  String get couldNotOpenReceiptLink => 'Der Beleg-Link konnte nicht geöffnet werden.';

  @override
  String get createAction => 'Erstellen';

  @override
  String get createFirstTripHint => 'Erstellen Sie Ihre erste Reise, um loszulegen.';

  @override
  String get createNewTripTitle => 'Neue Reise erstellen';

  @override
  String get createTripAction => 'Reise erstellen';

  @override
  String get createTripFirst => 'Erstellen Sie zunächst eine Reise.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Erstellt von $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Der Reiseorganisator muss die Reise abschließen, um die Abrechnungsbestätigung zu starten.';

  @override
  String currentEmailLabel(Object email) {
    return 'Aktuelle E-Mail-Adresse: $email';
  }

  @override
  String get currentReceiptAttached => 'Die aktuelle Quittung ist beigefügt.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Datum';

  @override
  String get dateMustMatchFormat => 'Das Datum muss im Format YYYY-MM-DD angegeben werden.';

  @override
  String get dateUnknown => 'Datum unbekannt';

  @override
  String get deleteAction => 'Löschen';

  @override
  String get deleteExpenseConfirmQuestion => 'Diese Ausgabe löschen?';

  @override
  String get deleteExpenseTitle => 'Ausgabe löschen';

  @override
  String get editExpenseConfirmTitle => 'Änderungen an den Ausgaben speichern?';

  @override
  String get editExpenseConfirmText => 'Dadurch werden die Salden für alle Teilnehmer der Reise aktualisiert.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Direkt anhand der Ausgaben erläutert: $amount';
  }

  @override
  String get doneStatus => 'Fertig';

  @override
  String get editAction => 'Bearbeiten';

  @override
  String get editExpenseTitle => 'Ausgaben bearbeiten';

  @override
  String get emailAddressLabel => 'E-Mail-Adresse';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get emailRequired => 'Eine E-Mail-Adresse ist erforderlich.';

  @override
  String get enterValidExactAmounts => 'Geben Sie für alle Teilnehmer gültige, genaue Beträge ein.';

  @override
  String get enterValidPercentages => 'Geben Sie für alle Teilnehmer gültige Prozentsätze ein.';

  @override
  String get equalSplitLabel => 'Gleichmäßig aufteilen';

  @override
  String exactAmountWithValue(Object value) {
    return 'Genau: $value';
  }

  @override
  String get exactAmountsLabel => 'Genaue Beträge';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Die genaue Aufteilung muss sich auf $amount summieren.';
  }

  @override
  String get expenseAdded => 'Ausgabe hinzugefügt.';

  @override
  String get expenseBreakdownSubtitle => 'Inwiefern dieses Mitglied von den einzelnen Ausgaben betroffen ist.';

  @override
  String get expenseBreakdownTitle => 'Aufschlüsselung der Ausgaben';

  @override
  String get expenseDeleted => 'Ausgabe gelöscht.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Ausgabe Nr. $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Bezahlt $paid  -  Schuldet $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reaktionen';

  @override
  String get expenseCommentsTitle => 'Kommentare';

  @override
  String get expenseNoComments => 'Noch keine Kommentare.';

  @override
  String get expenseAddCommentHint => 'Kommentar hinzufügen...';

  @override
  String get expenseCommentSend => 'Senden';

  @override
  String get expenseMentionNoMatches => 'Keine passenden Mitglieder';

  @override
  String get expenseMentionMembersLabel => 'Reisemitglieder zum Erwähnen';

  @override
  String get expenseDeleteCommentTitle => 'Kommentar löschen?';

  @override
  String get expenseUpdated => 'Ausgaben aktualisiert.';

  @override
  String expenseWithId(Object id) {
    return 'Ausgabe Nr. $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben',
      one: '$count Ausgabe',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Ausgaben';

  @override
  String get failedToCreateTrip => 'Die Reise konnte nicht erstellt werden.';

  @override
  String get failedToLoadUsersDirectory => 'Das Benutzerverzeichnis konnte nicht geladen werden.';

  @override
  String get filterSettlementByMemberSubtitle => 'Abrechnungen nach Mitglied filtern';

  @override
  String get finishSoloTripConfirmationText => 'Diese Reise abschließen und in Ihr Archiv verschieben? Ihre Ausgaben bleiben weiterhin einsehbar.';

  @override
  String get soloTripArchived => 'Reise beendet und archiviert.';

  @override
  String get finishTripSyncPending => 'Synchronisieren Sie Ihre ausstehenden Änderungen, bevor Sie diese Reise abschließen.';

  @override
  String get finishTripAction => 'Reise beenden';

  @override
  String get finishTripConfirmationText => 'Diese Reise abschließen und mit der Abrechnung beginnen?';

  @override
  String get finishTripStartSettlementsAction => 'Abrechnungen abschließen und beginnen';

  @override
  String get finishTripTitle => 'Reise beenden';

  @override
  String forParticipants(Object participants) {
    return 'Für: $participants';
  }

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get profileSetPassword => 'Passwort festlegen';

  @override
  String get profileManagePassword => 'Passwort festlegen oder ändern';

  @override
  String get profilePasswordByEmail => 'Passwort per E-Mail festlegen';

  @override
  String get passwordEmailBackToProfile => 'Zurück zum Profil';

  @override
  String get forgotPasswordSubtitle => 'Gib deine E-Mail-Adresse ein, dann senden wir dir einen Link zum Zurücksetzen des Passworts.';

  @override
  String get forgotPasswordSuccessMessage => 'Falls ein Konto mit dieser E-Mail-Adresse existiert, haben wir einen Link zum Zurücksetzen des Passworts gesendet.';

  @override
  String get passwordResetSentTitle => 'Prüfe dein Postfach';

  @override
  String get passwordResetSentHint => 'Der Link ist 1 Stunde gültig. Falls du die E-Mail nicht findest, schau im Spam-Ordner nach.';

  @override
  String get forgotPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get friendsProgressSubtitle => 'Jedes Mitglied und dessen Bestätigungsstatus.';

  @override
  String get friendsProgressTitle => 'Fortschritte der Freunde';

  @override
  String get friendsSectionComingSoon => 'Der Bereich „Freunde“ folgt in Kürze.';

  @override
  String fromDirection(Object name) {
    return 'Von $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from bis $to';
  }

  @override
  String get generateTurnAction => 'Nächste Person auslosen';

  @override
  String get hasAccountQuestion => 'Hast du bereits ein Konto?';

  @override
  String helloUser(Object name) {
    return 'Hallo, $name!';
  }

  @override
  String get iSentAction => 'Ich habe gesendet';

  @override
  String get invalidEmailFormat => 'Ungültiges E-Mail-Format.';

  @override
  String get languageAction => 'Sprache';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageLatvian => 'Lettisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemSubtitle => 'Gerätesprache verwenden';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Lassen Sie das Feld leer, um das aktuelle Passwort beizubehalten.';

  @override
  String get logInButton => 'Anmelden';

  @override
  String get logOutButton => 'Abmelden';

  @override
  String get logoutFromDeviceQuestion => 'Von diesem Gerät abmelden?';

  @override
  String get logoutRevocationUnconfirmed => 'Auf diesem Gerät abgemeldet. Die Aufhebung der Serversitzung konnte nicht bestätigt werden.';

  @override
  String get markedAsSent => 'Als gesendet markiert.';

  @override
  String get markSettlementSentConfirmTitle => 'Überweisung als gesendet markieren?';

  @override
  String get markSettlementSentConfirmText => 'Verwenden Sie diese Funktion erst, nachdem Sie die Zahlung tatsächlich gesendet haben. Der Empfänger wird zur Bestätigung aufgefordert.';

  @override
  String get settlementCancelSentAction => 'Als „nicht gesendet“ markieren';

  @override
  String get settlementCancelSentConfirmTitle => 'Den Status „Gesendet“ rückgängig machen?';

  @override
  String get settlementCancelSentConfirmText => 'Dadurch wird die Überweisung wieder in den Status „Ausstehend“ versetzt und der Empfänger benachrichtigt.';

  @override
  String get settlementSentCancelled => 'Die Überweisung wurde wieder in den Status „Ausstehend“ versetzt.';

  @override
  String get settlementNotReceivedAction => 'Ich habe dies nicht erhalten';

  @override
  String get settlementNotReceivedConfirmTitle => 'Nicht erhaltene Zahlung melden?';

  @override
  String get settlementNotReceivedConfirmText => 'Dadurch wird die Überweisung wieder in den Status „Ausstehend“ versetzt und der Zahler benachrichtigt.';

  @override
  String get settlementMarkedNotReceived => 'Als „nicht erhalten“ markiert.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Bestätigen Sie den Empfang?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Bestätigen Sie erst, nachdem das Geld auf Ihrem Konto eingegangen ist. Diese Aktion kann die Abrechnung abschließen.';

  @override
  String get memberSummariesSubtitle => 'Aktueller Kontostand für beide Seiten.';

  @override
  String get memberSummariesTitle => 'Mitgliederübersichten';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Zur Zahlung $total  -  bestätigt $confirmed  -  ausstehend $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Geschätzte Auswirkungen auf die Zahlungen pro Mitglied.';

  @override
  String get membersImpactTitle => 'Auswirkungen auf die Mitglieder';

  @override
  String get membersIncludedInExpense => 'Eingeschlossene Mitglieder';

  @override
  String get membersLabel => 'Mitglieder';

  @override
  String moreCount(Object count) {
    return '+ $count weitere';
  }

  @override
  String get myFilter => 'Mein';

  @override
  String get myImpactTitle => 'Meine Auswirkungen';

  @override
  String get firstNameHint => 'Dein Vorname';

  @override
  String get firstNameLabel => 'Vorname';

  @override
  String get firstNameLengthValidation => 'Der Vorname muss aus 2 bis 64 Zeichen bestehen.';

  @override
  String get fullNameHelper => 'Verwenden Sie Vor- und Nachnamen in einem Feld.';

  @override
  String get fullNameHint => 'z. B. Anna Ozolina';

  @override
  String get fullNameLabel => 'Vollständiger Name';

  @override
  String get fullNameValidation => 'Geben Sie Vor- und Nachnamen ein (jeweils mindestens 2 Zeichen).';

  @override
  String get lastNameHint => 'Ihr Nachname';

  @override
  String get lastNameLabel => 'Nachname';

  @override
  String get lastNameLengthValidation => 'Der Nachname muss aus 2 bis 64 Zeichen bestehen.';

  @override
  String get nameHint => 'Ihr Name';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameLengthValidation => 'Der Name muss mindestens 2 Zeichen lang sein.';

  @override
  String get navActivities => 'Statistik';

  @override
  String get navAddTrip => 'Reise hinzufügen';

  @override
  String get navBalances => 'Salden';

  @override
  String get navExpenses => 'Ausgaben';

  @override
  String get navFriends => 'Freunde';

  @override
  String get navHome => 'Startseite';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRandom => 'Zufällig';

  @override
  String get netLabel => 'Saldo';

  @override
  String get newPasswordLabel => 'Neues Passwort';

  @override
  String get nicknameHint => 'So sehen dich deine Freunde';

  @override
  String get nicknameLabel => 'Spitzname';

  @override
  String get nicknameLengthValidation => 'Der Spitzname muss mindestens 2 Zeichen lang sein.';

  @override
  String get noAccountQuestion => 'Noch kein Konto?';

  @override
  String get noBalancesYet => 'Noch keine Salden.';

  @override
  String get noChangesToSave => 'Es sind keine Änderungen zu speichern.';

  @override
  String get noDirectExpenseLink => 'Es wurde kein direkter Link zu einer einzelnen Ausgabe gefunden. Diese Abrechnung wird auf Basis des gesamten Reisebetrags berechnet.';

  @override
  String get noExpenseImpactForMember => 'Für dieses Mitglied entstehen keine Kosten.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Bisher keine Ausgaben für $name.';
  }

  @override
  String get noExpensesYet => 'Bisher keine Ausgaben.';

  @override
  String get noExtraUsersToAdd => 'Es müssen keine zusätzlichen Nutzer hinzugefügt werden.';

  @override
  String get noInternetDeleteQueued => 'Kein Internet. Aus der Warteschlange löschen.';

  @override
  String get noInternetExpenseQueued => 'Kein Internet. Ausgabe in der Warteschlange.';

  @override
  String get noInternetUpdateQueued => 'Kein Internet. Aktualisierung in der Warteschlange.';

  @override
  String get noMatchingRows => 'Keine übereinstimmenden Zeilen.';

  @override
  String get noMembersFound => 'Es wurden keine Mitglieder gefunden.';

  @override
  String get noNewMembersAdded => 'Diese Personen sind bereits Mitglieder oder haben ausstehende Einladungen.';

  @override
  String get noNotePlaceholder => 'Keine Anmerkung';

  @override
  String get notificationsToday => 'Heute';

  @override
  String get notificationsEmptyBody => 'Aktuelle Informationen zu Reisen, Ausgaben und Freunden werden hier angezeigt.';

  @override
  String get notificationsCached => 'Offline – Anzeige gespeicherter Benachrichtigungen.';

  @override
  String get notificationsRefreshFailed => 'Aktualisierung nicht möglich. Es werden zuvor geladene Benachrichtigungen angezeigt.';

  @override
  String get notificationsJustNow => 'Gerade eben';

  @override
  String notificationsMinutesAgo(int count) {
    return 'vor $count Min.';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'vor $count Std.';
  }

  @override
  String get notificationsUnread => 'Ungelesen';

  @override
  String get noNotificationsYet => 'Noch keine Benachrichtigungen.';

  @override
  String get noParticipantData => 'Keine Teilnehmerdaten.';

  @override
  String get noParticipantsSelected => 'Es wurden keine Teilnehmer ausgewählt.';

  @override
  String get noPaymentRowsInTrip => 'Keine Zahlungszeilen in dieser Reise.';

  @override
  String get noPaymentsNeeded => 'Es sind keine Zahlungen erforderlich.';

  @override
  String get noPicksYet => 'Noch keine Auswahl.';

  @override
  String get noSettlementActivityForMember => 'Für dieses Mitglied liegen keine Abrechnungsvorgänge vor.';

  @override
  String get noSettlementRowsYet => 'Noch keine Abrechnungszeilen.';

  @override
  String get noSettlements => 'Keine Abrechnungen';

  @override
  String get noTransferNeededForFilter => 'Für den ausgewählten Filter ist keine Überweisung erforderlich.';

  @override
  String get noTransferRowsToShow => 'Es sind keine Überweisungszeilen anzuzeigen.';

  @override
  String get noTripDataLoaded => 'Es wurden keine Reisedaten geladen.';

  @override
  String get noTripsYet => 'Noch keine Reisen.';

  @override
  String get noUsersFoundYet => 'Es wurden noch keine Nutzer gefunden.';

  @override
  String get notSetValue => 'Nicht festgelegt';

  @override
  String get notYetConfirmedTitle => 'Noch nicht bestätigt';

  @override
  String get noteHint => 'Abendessen, Taxi, Eintrittskarten...';

  @override
  String get noteLabel => 'Hinweis';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Die Notiz darf höchstens $max Zeichen lang sein.';
  }

  @override
  String get notificationFallbackTitle => 'Benachrichtigung';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationFriendInviteTitle => 'Freundschaftsanfrage';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name hat dir eine Freundschaftseinladung gesendet.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Du hast eine Freundschaftseinladung erhalten.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Einladung angenommen';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name hat deine Freundschaftseinladung angenommen.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Deine Einladung wurde angenommen.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Einladung abgelehnt';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name hat deine Freundschaftseinladung abgelehnt.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Deine Einladung als Freund wurde abgelehnt.';

  @override
  String get notificationTripAddedTitle => 'Zur Reise hinzugefügt';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name hat dich zur Reise „$trip“ hinzugefügt.';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Du wurdest zur Reise „$trip“ hinzugefügt.';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Du wurdest zu einer Reise hinzugefügt.';

  @override
  String get notificationExpenseAddedTitle => 'Neue Ausgabe hinzugefügt';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name hat unter „$trip“ eine Ausgabe in Höhe von $amount hinzugefügt.';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name hat eine Ausgabe in Höhe von $amount hinzugefügt: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Eine neue Ausgabe wurde hinzugefügt.';

  @override
  String get notificationCommentMentionTitle => 'Du wurdest in einem Kommentar erwähnt';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name hat dich in einem Kommentar zu „$note“ erwähnt.';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name hat dich in einem Kommentar erwähnt.';
  }

  @override
  String get notificationTripFinishedTitle => 'Reise beendet';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name hat „$trip“ abgeschlossen. Die Abrechnungen sind bereit.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name hat „$trip“ abgeschlossen. Die Reise wurde archiviert.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '„$trip“ wurde abgeschlossen.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Der Reisestatus wurde aktualisiert.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Mitglied als „bereit“ markiert';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name ist bereit, die Abrechnung für „$trip“ vorzunehmen.';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Ein Teilnehmer ist bereit, die Rechnung für „$trip“ zu begleichen.';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Ein Mitglied ist bereit zur Abrechnung.';

  @override
  String get notificationTripReadyToSettleTitle => 'Alle Teilnehmer sind bereit';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Alle Mitglieder sind in „$trip“ als bereit markiert. Sie können mit der Abrechnung beginnen.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Alle Teilnehmer sind bereit. Sie können mit der Abrechnung beginnen.';

  @override
  String get notificationSettlementReminderTitle => 'Erinnerung zur Abrechnung';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor erinnerte $target daran, $amount als gesendet zu markieren.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor erinnerte $target daran, den Erhalt von $amount zu bestätigen.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Sie haben eine Zahlungserinnerung erhalten.';

  @override
  String get notificationPaymentReminderTitle => 'Zahlungserinnerung';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Zur Erinnerung: Bitte markieren Sie $amount in „$trip“ als an $target gesendet.';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Zur Erinnerung: Bitte markieren Sie die Zahlung als gesendet.';

  @override
  String get notificationConfirmationReminderTitle => 'Erinnerung zur Bestätigung';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Erinnerung: Bitte bestätige den Erhalt von $amount von $payer in „$trip“.';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Zur Erinnerung: Bitte bestätigen Sie den Zahlungseingang.';

  @override
  String get notificationSettlementSentTitle => 'Überweisung als gesendet markiert';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name hat $amount als an Sie gesendet markiert.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Eine Überweisung wurde als gesendet markiert.';

  @override
  String get notificationSettlementConfirmedTitle => 'Überweisung bestätigt';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name hat den Erhalt von $amount von dir bestätigt.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Eine Überweisung wurde bestätigt.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausstehende Änderungen',
      one: '$count ausstehende Änderung',
    );
    return 'Offline-Warteschlange: $_temp0';
  }

  @override
  String get syncAllSynced => 'Alles synchronisiert';

  @override
  String syncChangesWaiting(Object count) {
    return '$count warten auf die Synchronisierung';
  }

  @override
  String get syncFailedTapToRetry => 'Synchronisierung fehlgeschlagen, zum erneuten Versuch antippen';

  @override
  String get offlineQueueStatus => 'Offline-Warteschlange';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Nur der Reiseorganisator kann die Reise beenden.';

  @override
  String get openLabel => 'Öffnen';

  @override
  String get openReceiptAction => 'Beleg öffnen';

  @override
  String get openSettlements => 'Abrechnungen öffnen';

  @override
  String get overviewTitle => 'Übersicht';

  @override
  String get owesLabel => 'Schuldet';

  @override
  String get paidByLabel => 'Bezahlt von';

  @override
  String get paidLabel => 'Bezahlt';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Bezahlt $paid  -  Schuldet $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Teilnehmer (leer = alle Mitglieder)';

  @override
  String get participantsTitle => 'Teilnehmer';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get passwordComplexityHelper => 'Verwende mindestens 1 Großbuchstaben, 1 Ziffer und 1 Sonderzeichen.';

  @override
  String get passwordComplexityValidation => 'Das Passwort muss 1 Großbuchstaben, 1 Ziffer und 1 Sonderzeichen enthalten.';

  @override
  String get passwordMinLength => 'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get passwordMinLengthShort => 'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get passwordResetComingSoon => 'Die Passwortzurücksetzung ist in Kürze verfügbar.';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String payerName(Object name) {
    return '$name (Zahler)';
  }

  @override
  String get pendingLabel => 'Ausstehend';

  @override
  String get pendingPaymentsSubtitle => 'Zahlungen warten noch auf die vollständige Bestätigung.';

  @override
  String get percentLabel => 'Prozent';

  @override
  String get percentSplitMustBe100 => 'Die prozentuale Aufteilung muss sich genau auf 100 % summieren.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Prozentanteile';

  @override
  String get pickAtLeastOneParticipant => 'Wählen Sie mindestens einen Teilnehmer aus.';

  @override
  String get pickMembersGenerateTurn => 'Wähle Teilnehmer aus und lose die nächste Person aus.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name ausgewählt. Zyklus abgeschlossen.';
  }

  @override
  String pickedUser(Object name) {
    return '$name ausgewählt.';
  }

  @override
  String get profileRefreshCachedData => 'Das Profil konnte nicht aktualisiert werden. Es werden zwischengespeicherte Daten angezeigt.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpdated => 'Profil aktualisiert.';

  @override
  String get uploadAvatarAction => 'Avatar hochladen';

  @override
  String get takePhotoAction => 'Machen Sie ein Foto';

  @override
  String get chooseFromLibraryAction => 'Aus der Bibliothek auswählen';

  @override
  String get removeAvatarAction => 'Avatar entfernen';

  @override
  String get avatarUpdatedMessage => 'Avatar aktualisiert.';

  @override
  String get avatarRemovedMessage => 'Avatar entfernt.';

  @override
  String get avatarFileTooLarge => 'Die Avatar-Datei ist zu groß (max. 5 MB).';

  @override
  String get avatarPickFailed => 'Das Avatar-Bild konnte nicht geladen werden.';

  @override
  String get queueAddExpense => 'Ausgabe hinzufügen';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'In der Warteschlange: Ausgabe hinzufügen $amount';
  }

  @override
  String get queueDeleteExpense => 'Ausgabe löschen';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'In der Warteschlange: Ausgabe Nr. $id löschen';
  }

  @override
  String get queuePendingStatus => 'Warteschlange ausstehend';

  @override
  String get queueUpdateExpense => 'Ausgaben aktualisieren';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'In der Warteschlange: Spesenbeleg Nr. $id aktualisieren';
  }

  @override
  String get queuedChange => 'Änderungen in der Warteschlange';

  @override
  String queuedChangesTitle(Object count) {
    return 'Änderungen in der Warteschlange ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'In der Warteschlange ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Zyklus $cycleNo, Ziehung $drawNo – $remaining übrig';
  }

  @override
  String get receiptFallbackName => 'Beleg';

  @override
  String get receiptLinkInvalid => 'Der Beleg-Link ist ungültig.';

  @override
  String get receiptOptionalLabel => 'Beleg (optional)';

  @override
  String get recentPicksTitle => 'Letzte Auslosungen';

  @override
  String get reloadProfile => 'Profil neu laden';

  @override
  String get rememberMe => 'Angemeldet bleiben';

  @override
  String get removeCurrentReceipt => 'Aktuelle Quittung entfernen';

  @override
  String get repeatNewPasswordLabel => 'Neues Passwort wiederholen';

  @override
  String get repeatPasswordLabel => 'Passwort wiederholen';

  @override
  String get requestFailedTryAgain => 'Anfrage fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get retryAction => 'Erneut versuchen';

  @override
  String get rowsLabel => 'Zeilen';

  @override
  String get backToLoginAction => 'Zurück zur Anmeldung';

  @override
  String get saveAction => 'Speichern';

  @override
  String get saveCredentialsButton => 'Anmeldedaten speichern';

  @override
  String get saveProfileButton => 'Profil speichern';

  @override
  String get sendResetLinkButton => 'Link zum Zurücksetzen senden';

  @override
  String get searchUsersHint => 'Personen nach Namen oder E-Mail-Adresse suchen';

  @override
  String get selectedPeopleLabel => 'Ausgewählte Personen';

  @override
  String get noSearchMatches => 'Es wurden keine passenden Nutzer gefunden.';

  @override
  String get savingButton => 'Wird gespeichert...';

  @override
  String get selectAtLeastTwoMembers => 'Wählen Sie mindestens zwei Teilnehmer aus.';

  @override
  String get selectMembersHint => 'Mitglieder auswählen';

  @override
  String selectedFileLabel(Object name) {
    return 'Ausgewählt: $name';
  }

  @override
  String get selectedLabel => 'Ausgewählt';

  @override
  String get selectedUserFallback => 'Ausgewählter Nutzer';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settleUpAction => 'Abrechnen';

  @override
  String get settledLabel => 'Ausgeglichen';

  @override
  String get settledStatus => 'Ausgeglichen';

  @override
  String get settlementActivitySubtitle => 'Mit diesem Mitglied verknüpfte Überweisungen.';

  @override
  String get settlementActivityTitle => 'Abrechnungsvorgänge';

  @override
  String get settlementCompletedTitle => 'Abrechnung abgeschlossen';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total bestätigt';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Abrechnungen: $count';
  }

  @override
  String get settlementImpactTitle => 'Auswirkungen auf die Abrechnung';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Auswirkungen auf die Abrechnung: $name';
  }

  @override
  String get settlementInProgress => 'Abrechnung läuft';

  @override
  String get settlementInProgressTitle => 'Abrechnung läuft';

  @override
  String get settlementLabel => 'Abrechnung';

  @override
  String get settlementOverviewArchivedSubtitle => 'Reise archiviert. Alle Abrechnungen abgeschlossen.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Verfolgen Sie die Zahlungsbestätigungen.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Vorschau auf Überweisungen nach Abschluss der Reise.';

  @override
  String get settlementPreview => 'Vorschau auf die Abrechnung';

  @override
  String get settlementPreviewTitle => 'Vorschau auf die Abrechnung';

  @override
  String get settlementProgressTripArchived => 'Reise archiviert';

  @override
  String settlementWithId(Object id) {
    return 'Abrechnung Nr. $id';
  }

  @override
  String get settlements => 'Abrechnungen';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Die Abrechnungen sind bereits abgeschlossen.';

  @override
  String get settlementsDone => 'Abrechnungen abgeschlossen';

  @override
  String get settlingStatus => 'Abrechnung';

  @override
  String get shareUnit => 'Anteil';

  @override
  String get sharesLabel => 'Anteile';

  @override
  String get sharesMustBePositiveIntegers => 'Die Anzahl der Anteile muss eine positive ganze Zahl sein.';

  @override
  String sharesWithValue(Object value) {
    return 'Anteile: $value';
  }

  @override
  String get showActiveTrips => 'Aktive Reisen anzeigen';

  @override
  String get signUpButton => 'Registrieren';

  @override
  String get splitBreakdownSubtitle => 'Wie die Kosten aufgeteilt werden';

  @override
  String get splitBreakdownTitle => 'Aufschlüsselung der Kosten';

  @override
  String get splitHintEqual => 'Gleichmäßige Aufteilung unter den ausgewählten Teilnehmern.';

  @override
  String get splitHintExact => 'Geben Sie für jeden Teilnehmer den genauen Betrag ein. Die Summe muss mit dem Gesamtbetrag übereinstimmen.';

  @override
  String get splitHintPercent => 'Geben Sie für jeden Teilnehmer einen Prozentsatz ein. Die Summe muss 100 % betragen.';

  @override
  String get splitHintShares => 'Geben Sie die Anteile ein (1, 2, 3...). Die Kosten werden anteilig aufgeteilt.';

  @override
  String get splitLabel => 'Splitter';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Gleichmäßige Aufteilung ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Genaue Beträge ($target)';
  }

  @override
  String get splitModeLabel => 'Split-Modus';

  @override
  String splitModePercent(Object target) {
    return 'Prozentsätze ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Anteile ($target)';
  }

  @override
  String get statusConfirmed => 'Bestätigt';

  @override
  String get statusPending => 'Ausstehend';

  @override
  String get statusSent => 'Abgesandt';

  @override
  String get statusSuggested => 'Vorgeschlagen';

  @override
  String statusWithValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get suggestedTransferDirections => 'Vorgeschlagene Zahlungsrichtungen';

  @override
  String get suggestedTransferFromExpense => 'Vorgeschlagene Übertragung aus den Ausgaben';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vorgeschlagene Überweisungen',
      one: '$count vorgeschlagene Überweisung',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Erwartete Zeilen für Zahler und Empfänger.';

  @override
  String get suggestedTransfersTitle => 'Vorgeschlagene Überweisungen';

  @override
  String get summarySettledUp => 'Ausgeglichen';

  @override
  String get summaryYouAreOwed => 'Andere schulden dir';

  @override
  String get summaryYouOwe => 'Du schuldest';

  @override
  String get syncAction => 'Synchronisieren';

  @override
  String get syncNowAction => 'Jetzt synchronisieren';

  @override
  String get syncingStatus => 'Synchronisierung';

  @override
  String get tapToViewDetails => 'Tippen Sie hier, um Details anzuzeigen';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get themeModeDarkSubtitle => 'Sanftes Dunkel (kein reines Schwarz)';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeSystemSubtitle => 'Geräte-Design verwenden';

  @override
  String toDirection(Object name) {
    return 'An $name';
  }

  @override
  String get totalLabel => 'Gesamt';

  @override
  String get travelerFallbackName => 'Reisender';

  @override
  String get tripAlreadyClosed => 'Die Reise ist bereits abgeschlossen.';

  @override
  String get tripArchivedReadOnly => 'Die Reise wird archiviert. Nur-Lese-Modus.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Die Reise ist abgeschlossen. Die Bearbeitung von Ausgaben ist deaktiviert.';

  @override
  String get tripClosedExpensesReadOnly => 'Die Reise ist abgeschlossen. Ausgaben sind schreibgeschützt.';

  @override
  String get tripClosedRandomDisabled => 'Die Reise ist beendet. Die Zufallsauswahl ist deaktiviert.';

  @override
  String tripCreated(Object name) {
    return 'Reise „$name“ erstellt.';
  }

  @override
  String get tripFinished => 'Reise beendet.';

  @override
  String get tripFinishedCompleteSettlements => 'Die Reise ist beendet. Schließen Sie die Abrechnungen ab.';

  @override
  String get tripFinishedSettlementStarted => 'Reise beendet. Abrechnung gestartet.';

  @override
  String get tripFullySettledArchived => 'Die Reise ist vollständig abgerechnet und archiviert.';

  @override
  String get tripNameHint => 'Skiurlaub in Österreich';

  @override
  String get tripNameLabel => 'Reisename';

  @override
  String get tripNameLengthValidation => 'Der Name der Reise muss mindestens 2 Zeichen lang sein.';

  @override
  String get tripSnapshotTitle => 'Reiseübersicht';

  @override
  String get tripTitleShort => 'Reise';

  @override
  String tripStatusWithValue(Object status) {
    return 'Reisestatus: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Reise Nr. $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Unerwarteter Fehler beim Laden des Profils';

  @override
  String get unexpectedErrorLoadingTripData => 'Unerwarteter Fehler beim Laden der Reisedaten';

  @override
  String get unexpectedErrorLoadingTrips => 'Unerwarteter Fehler beim Laden von Reisen';

  @override
  String get unexpectedErrorSavingChanges => 'Unerwarteter Fehler beim Speichern der Änderungen';

  @override
  String get unexpectedErrorSavingCredentials => 'Unerwarteter Fehler beim Speichern der Anmeldedaten';

  @override
  String get unexpectedErrorUpdatingProfile => 'Unerwarteter Fehler beim Aktualisieren des Profils';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get unknownLabel => 'Unbekannt';

  @override
  String get unreadLabel => 'Ungelesen';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Aktualisierungen',
      one: '$count ungelesene Aktualisierung',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Argument „Reiseroute“ fehlt.';

  @override
  String userIdLabel(Object id) {
    return 'Benutzer-ID: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Bezahlt $paid  -  Schuldet $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Benutzer $id';
  }

  @override
  String get valueLabel => 'Wert';

  @override
  String get viewAllTrips => 'Alle Reisen anzeigen';

  @override
  String get viewByPersonTitle => 'Ansicht nach Person';

  @override
  String get whoOwesWhatSubtitle => 'Wer hat bezahlt und wer schuldet noch etwas?';

  @override
  String get whoOwesWhatTitle => 'Wer schuldet was?';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Wer schuldet was: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Zu dieser Überweisung beitragende Ausgabenzeilen.';

  @override
  String get whyPaymentExistsTitle => 'Warum diese Zahlungsart existiert';

  @override
  String get youLabel => 'Sie';

  @override
  String get youSettledForExpense => 'Du hast deinen Anteil an dieser Ausgabe beglichen.';

  @override
  String youShouldPay(Object amount) {
    return 'Du solltest bezahlen $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Sie sollten erhalten $amount';
  }

  @override
  String get yourShare => 'Dein Anteil';

  @override
  String get yourTrips => 'Deine Reisen';

  @override
  String get authIntroSplitSmarter => 'Teilt die Kosten smarter auf.';

  @override
  String get authIntroTravelFree => 'Reise frei.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Verfolgen Sie geteilte Kosten währungsübergreifend und rechnen Sie sofort ab – ganz ohne umständliche Schuldscheine.';

  @override
  String get authIntroPlanTogether => 'Plant gemeinsam.';

  @override
  String get authIntroPayClearly => 'Zahlen Sie klar und deutlich.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Erstellen Sie Reisen in Sekundenschnelle, fügen Sie Freunde hinzu und sorgen Sie dafür, dass alle Ausgaben für alle transparent sind.';

  @override
  String get authIntroSettleFast => 'Klären Sie die Abrechnung zügig ab.';

  @override
  String get authIntroStayFriends => 'Bleibt Freunde.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Von gemeinsamen Abendessen bis hin zu kompletten Reisen sorgt Splyto für faire und stressfreie Abrechnungen.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Die Anmeldung bei Apple ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Die Google-Anmeldung ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authIntroCreateAccount => 'Erstellen Sie Ihr Konto.';

  @override
  String get authIntroChooseSign => 'Wählen Sie aus, wie Sie sich anmelden möchten.';

  @override
  String get authIntroContinueGoogle => 'Weiter mit Google';

  @override
  String get authIntroContinueApple => 'Weiter mit Apple';

  @override
  String get authIntroBack => 'Zurück';

  @override
  String get authIntroSplitSettled => 'Aufteilung abgeschlossen';

  @override
  String get authIntroParis3Friends => 'Paris · 3 Freunde';

  @override
  String get authIntroGetStarted => 'Los geht’s';

  @override
  String get authIntroAlreadyHaveAccount => 'Hast du bereits ein Konto? ';

  @override
  String get authIntroSignIn => 'Anmelden';

  @override
  String get authIntroSignUpWithEmail => 'Registrieren Sie sich per E-Mail';

  @override
  String get authIntroOr => 'ODER';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Die Google-Anmeldung hat kein ID-Token zurückgegeben.';

  @override
  String get authAppleSignAvailableIosDevices => 'Die Apple-Anmeldung ist auf iOS-Geräten verfügbar.';

  @override
  String get authAppleSignNotAvailableDevice => 'Die Apple-Anmeldung ist auf diesem Gerät nicht verfügbar.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Die Apple-Anmeldung hat kein Identitäts-Token zurückgegeben.';

  @override
  String get authCancel => 'Abbrechen';

  @override
  String get authSendLink => 'Link senden';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'Die E-Mail-Adresse ist nicht verifiziert. Geben Sie Ihre E-Mail-Adresse ein, um einen Verifizierungslink anzufordern.';

  @override
  String get authEmailNotVerified => 'E-Mail-Adresse nicht verifiziert';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Bestätigungslink an $email senden?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Verifizierungslink gesendet. Bitte überprüfen Sie Ihre E-Mails.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Der Bestätigungslink konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Bestätigungs-E-Mail gesendet. Bitte bestätige deine E-Mail-Adresse, bevor du dich anmeldest.';

  @override
  String get authVerifyEmail => 'Bestätigen Sie Ihre E-Mail-Adresse';

  @override
  String get authEmailLabel => 'E-Mail:';

  @override
  String get authClose => 'Schließen';

  @override
  String get authResendLink => 'Link erneut senden';

  @override
  String get profileAppSettingsSectionTitle => 'APP-EINSTELLUNGEN';

  @override
  String get profileEmailVerified => 'Bestätigt';

  @override
  String get profileEmailNotVerified => 'Nicht bestätigt';

  @override
  String get profileEmailSendVerification => 'Link senden';

  @override
  String get profileEmailVerificationSent => 'Bestätigungs-E-Mail gesendet. Sieh in deinem Postfach nach.';

  @override
  String get profileAccountSectionTitle => 'KONTO';

  @override
  String get profileAccountSettings => 'Kontoeinstellungen';

  @override
  String get profileChangePhoto => 'Profilfoto ändern';

  @override
  String get profileAppearance => 'Darstellung';

  @override
  String get profileThemeDisplayMode => 'Thema & Anzeigemodus';

  @override
  String get profileLanguage => 'Sprache';

  @override
  String get profileDisplayLanguage => 'Anzeigesprache';

  @override
  String get profileNotificationsSectionHeading => 'BENACHRICHTIGUNGEN';

  @override
  String get profileAppBanners => 'In-App-Banner';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Neue Benachrichtigungsbanner innerhalb der App anzeigen';

  @override
  String get profilePushNotificationsTitle => 'Push-Benachrichtigungen';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Benachrichtigungen auf dem Smartphone zu Ausgaben, Freunden, Reisen und Abrechnungen';

  @override
  String get profileSupportSectionHeading => 'SUPPORT';

  @override
  String get profileContactUs => 'Kontaktieren Sie uns';

  @override
  String get profileReportBugSuggestion => 'Fehler melden / Vorschlag';

  @override
  String get profileRateSplyto => 'Bewerten Sie Splyto';

  @override
  String get profileLeaveStoreRating => 'Eine Bewertung für den Shop abgeben';

  @override
  String get profileSecuritySectionHeading => 'SICHERHEIT';

  @override
  String get profileAccountAndSecurity => 'Konto und Sicherheit';

  @override
  String get profileHelpTitle => 'Hilfe';

  @override
  String get profileChangePassword => 'Passwort ändern';

  @override
  String get profileUpdateAccountPassword => 'Passwort für das Konto aktualisieren';

  @override
  String get profileDangerZoneSectionHeading => 'GEFAHRENZONE';

  @override
  String get profileManageAccountAccess => 'Zugriff auf das Konto verwalten';

  @override
  String get profileMadeWithLabel => 'Erstellt mit';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Die Funktion zum Speichern von Bewertungen wird im nächsten Schritt integriert.';

  @override
  String get profileFailedSaveNotificationSettings => 'Das Speichern der Benachrichtigungseinstellungen ist fehlgeschlagen.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH-BENACHRICHTIGUNGEN';

  @override
  String get profileInAppBannersSectionTitle => 'IN-APP-BANNER';

  @override
  String get profileInAppTripMemberAddedTitle => 'Mitglied zur Reise hinzugefügt';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatische Zahlungserinnerung';

  @override
  String get profileExpenseUpdates => 'Aktualisierungen zu Ausgaben';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Banner zu hinzugefügten Ausgaben innerhalb der App';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Benachrichtigungen über hinzugefügte Ausgaben auf dem Smartphone';

  @override
  String get profileFriendInvites => 'Freund lädt ein';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Banner für Freundschaftsanfragen und Antworten innerhalb der App';

  @override
  String get profileFriendRequestResponseNotifications => 'Benachrichtigungen zu Freundschaftsanfragen und Antworten';

  @override
  String get profileTripUpdates => 'Reise-Updates';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Banner zum Reiseverlauf und zum Teilnehmerstatus innerhalb der App';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Verlauf der Reise und Änderungen des Teilnehmerstatus';

  @override
  String get profileSettlementUpdates => 'Aktualisierungen zur Abrechnung';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'In der App angezeigte Banner für „Als gesendet markiert“ und „Zahlung bestätigt“';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Als gesendet markierte und bestätigte Zahlungsaktualisierungen';

  @override
  String get profileScreenshotSizeMust8Mb => 'Die Größe von Screenshots darf maximal 8 MB betragen';

  @override
  String get profileFeedbackSendTitle => 'Feedback senden';

  @override
  String get profileFeedbackTypeLabel => 'Typ';

  @override
  String get profileFeedbackTypeBug => 'Fehler';

  @override
  String get profileFeedbackTypeSuggestion => 'Vorschlag';

  @override
  String get profileDescribeIssueSuggestion => 'Beschreiben Sie das Problem oder den Vorschlag';

  @override
  String get profilePickingImage => 'Bild wird ausgewählt...';

  @override
  String get profileAttachScreenshot => 'Screenshot anhängen';

  @override
  String get profileChangeScreenshot => 'Screenshot ändern';

  @override
  String get profileRemoveImage => 'Bild entfernen';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Tipp: Fügen Sie einen Screenshot bei, um die Fehlerbehebung zu beschleunigen';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Fügen Sie vor dem Absenden Details hinzu oder hängen Sie einen Screenshot an';

  @override
  String get profileSendAction => 'Senden';

  @override
  String get profileThanksFeedbackSent => 'Vielen Dank! Feedback gesendet';

  @override
  String get profileFailedSendFeedback => 'Das Senden des Feedbacks ist fehlgeschlagen';

  @override
  String get profileCouldNotOpenWebsite => 'Die Website konnte nicht geöffnet werden.';

  @override
  String get profileOpenWebsiteQuestion => 'Website öffnen?';

  @override
  String get profileOpenPortfolioAction => 'Öffnen Sie portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Dieses Bildformat wird auf diesem Gerät nicht unterstützt. Bitte wählen Sie JPG oder PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Zum Ändern Ihres Passworts ist eine gültige E-Mail-Adresse für Ihr Konto erforderlich. Wenden Sie sich an den Support, falls Ihre E-Mail-Adresse fehlt oder falsch ist.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Der Link zum Löschen wurde an Ihre E-Mail-Adresse gesendet.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Der Löschlink konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Geben Sie Ihr aktuelles Passwort ein, um die E-Mail-Adresse zu ändern.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Die Bestätigungs-E-Mail wurde an die neue E-Mail-Adresse gesendet. Der Sicherheitshinweis wurde an Ihre aktuelle E-Mail-Adresse gesendet.';

  @override
  String get profileEditOverviewCurrency => 'Übersicht Währung';

  @override
  String get profileEditPaymentMethod => 'Zahlungsmethode';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Banküberweisung, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Geben Sie Ihr Passwort ein (optional für Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Löschlink per E-Mail senden';

  @override
  String get profileEditBackProfile => 'Zurück zum Profil';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Geben Sie im Profil eine gültige E-Mail-Adresse an, bevor Sie das Passwort ändern.';

  @override
  String get profileEditPasswordUpdated => 'Passwort aktualisiert.';

  @override
  String get profileEditFailedUpdatePassword => 'Die Aktualisierung des Passworts ist fehlgeschlagen.';

  @override
  String profileEditEmail(Object email) {
    return 'Konto: $email';
  }

  @override
  String get profileEditPrimary => 'Primär';

  @override
  String get profileEditSearchCurrency => 'Währung suchen';

  @override
  String get profileEditNoCurrenciesFound => 'Keine Währungen gefunden';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Die Gesamtbeträge in der Übersicht werden in diese Währung umgerechnet.';

  @override
  String get profileEditPaymentInfoUpdated => 'Zahlungsinformationen aktualisiert.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Die Zahlungsdaten konnten nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get profileEditCurrentPassword => 'Aktuelles Passwort';

  @override
  String get profileEditBankTransferIbanSwift => 'Banküberweisung (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me-Link';

  @override
  String get profileEditChoosePaymentMethod => 'Zahlungsmethode auswählen';

  @override
  String get profileEditTapChange => 'Zum Ändern antippen';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Bei Überweisungen innerhalb Großbritanniens muss die Bankleitzahl 6-stellig und die Kontonummer 8-stellig sein.';

  @override
  String get profileEditPaymentInfo => 'Zahlungsinformationen';

  @override
  String get profileEditSaveDetails => 'Details speichern';

  @override
  String get profileEditBankRegion => 'Bankregion';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'Bankleitzahl';

  @override
  String get profileEditExample112233 => 'Beispiel: 112233';

  @override
  String get profileEditNumber => 'Kontonummer';

  @override
  String get profileEdit8Digits => '8 Ziffern';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Verwenden Sie für Inlandsüberweisungen im Vereinigten Königreich die Bankleitzahl + Kontonummer.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Beispiel: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 oder 11 Zeichen';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Der Name des Kontoinhabers wird aus dem vollständigen Namen im Profil übernommen.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username oder Benutzername';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Großbritannien';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Avatar anpassen';

  @override
  String get imageCropperAdjustTripImage => 'Reisebild anpassen';

  @override
  String get imageCropEditAction => 'Zuschnitt bearbeiten';

  @override
  String get imageCropZoomIn => 'Vergrößern';

  @override
  String get imageCropZoomOut => 'Verkleinern';

  @override
  String get imageCropZoomOnly => 'Von diesem Foto wurde nur die zugeschnittene Version gespeichert. Du kannst daher nur hineinzoomen.';

  @override
  String get imageCropLoadFailed => 'Dieses Foto konnte nicht geöffnet werden.';

  @override
  String get imageCropSaveFailed => 'Der neue Zuschnitt konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get imageCropChanged => 'Dieses Foto wurde inzwischen geändert. Schließe diese Ansicht und öffne sie erneut.';

  @override
  String get copyAction => 'Kopie';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Britisches Pfund';

  @override
  String get currencyNameChf => 'Schweizer Franken';

  @override
  String get currencyNameNok => 'Norwegische Krone';

  @override
  String get currencyNameSek => 'Schwedische Krone';

  @override
  String get currencyNameDkk => 'Dänische Krone';

  @override
  String get currencyNamePln => 'Polnischer Zloty';

  @override
  String get currencyNameCzk => 'Tschechische Krone';

  @override
  String get currencyNameHuf => 'Ungarischer Forint';

  @override
  String get currencyNameRon => 'Rumänischer Leu';

  @override
  String get currencyNameBgn => 'Bulgarischer Lew';

  @override
  String get currencyNameIsk => 'Isländische Krone';

  @override
  String get currencyNameAll => 'Albanischer Lek';

  @override
  String get currencyNameBam => 'Bosnien und Herzegowina Mark';

  @override
  String get currencyNameByn => 'Belarussischer Rubel';

  @override
  String get currencyNameMdl => 'Moldauischer Leu';

  @override
  String get currencyNameMkd => 'Mazedonischer Denar';

  @override
  String get currencyNameRsd => 'Serbischer Dinar';

  @override
  String get currencyNameUah => 'Ukrainische Hrywnja';

  @override
  String get currencyNameGel => 'Georgischer Lari';

  @override
  String get currencyNameTry => 'Türkische Lira';

  @override
  String get currencyNameUsd => 'US-Dollar';

  @override
  String get currencyNameJpy => 'Japanischer Yen';

  @override
  String get currencyNameCny => 'Chinesischer Yuan';

  @override
  String get currencyNameCad => 'Kanadischer Dollar';

  @override
  String get currencyNameAud => 'Australischer Dollar';

  @override
  String get currencyNameRub => 'Russischer Rubel';

  @override
  String get currencyNameMxn => 'Mexikanischer Peso';

  @override
  String get currencyNameBrl => 'Brasilianischer Real';

  @override
  String get currencyNameArs => 'Argentinischer Peso';

  @override
  String get currencyNameClp => 'Chilenischer Peso';

  @override
  String get currencyNameCop => 'Kolumbianischer Peso';

  @override
  String get currencyNamePen => 'Peruanischer Sol';

  @override
  String get currencyNameUyu => 'Uruguayischer Peso';

  @override
  String get currencyNameBob => 'Bolivianischer Boliviano';

  @override
  String get currencyNamePyg => 'Paraguayischer Guaraní';

  @override
  String get currencyNameCrc => 'Costa-Rica-Colón';

  @override
  String get currencyNameDop => 'Dominikanischer Peso';

  @override
  String get currencyNameGtq => 'Guatemaltekischer Quetzal';

  @override
  String get currencyNamePab => 'Panamaischer Balboa';

  @override
  String get currencyNameHnl => 'Honduras-Lempira';

  @override
  String get currencyNameNio => 'Nicaragua-Córdoba';

  @override
  String get currencyNameJmd => 'Jamaika-Dollar';

  @override
  String get currencyNameBbd => 'Barbados-Dollar';

  @override
  String get currencyNameBsd => 'Bahamas-Dollar';

  @override
  String get currencyNameTtd => 'Trinidad-und-Tobago-Dollar';

  @override
  String get currencyNameXcd => 'Ostkaribischer Dollar';

  @override
  String get currencyNameBzd => 'Belize-Dollar';

  @override
  String get currencyNameAwg => 'Aruba-Florin';

  @override
  String get currencyNameBmd => 'Bermuda-Dollar';

  @override
  String get currencyNameKyd => 'Kaiman-Dollar';

  @override
  String get currencyNameKrw => 'Südkoreanischer Won';

  @override
  String get currencyNameInr => 'Indische Rupie';

  @override
  String get currencyNameThb => 'Thailändischer Baht';

  @override
  String get currencyNameVnd => 'Vietnamesischer Dong';

  @override
  String get currencyNameIdr => 'Indonesische Rupiah';

  @override
  String get currencyNameMyr => 'Malaysischer Ringgit';

  @override
  String get currencyNameSgd => 'Singapur-Dollar';

  @override
  String get currencyNamePhp => 'Philippinischer Peso';

  @override
  String get currencyNameHkd => 'Hongkong-Dollar';

  @override
  String get currencyNameTwd => 'Neuer Taiwan-Dollar';

  @override
  String get currencyNameLkr => 'Sri-Lanka-Rupie';

  @override
  String get currencyNameNpr => 'Nepalesische Rupie';

  @override
  String get currencyNameBdt => 'Bangladesch-Taka';

  @override
  String get currencyNamePkr => 'Pakistanische Rupie';

  @override
  String get currencyNameKhr => 'Kambodschanischer Riel';

  @override
  String get currencyNameLak => 'Laotischer Kip';

  @override
  String get currencyNameMmk => 'Myanmarischer Kyat';

  @override
  String get currencyNameMnt => 'Mongolischer Tögrög';

  @override
  String get currencyNameMop => 'Macao-Pataca';

  @override
  String get currencyNameBnd => 'Brunei-Dollar';

  @override
  String get currencyNameMvr => 'Malediven-Rufiyaa';

  @override
  String get currencyNameBtn => 'Bhutan-Ngultrum';

  @override
  String get currencyNameKzt => 'Kasachischer Tenge';

  @override
  String get currencyNameUzs => 'Usbekistan-Sum';

  @override
  String get currencyNameKgs => 'Kirgisischer Som';

  @override
  String get currencyNameTjs => 'Tadschikistan-Somoni';

  @override
  String get currencyNameAzn => 'Aserbaidschan-Manat';

  @override
  String get currencyNameAmd => 'Armenischer Dram';

  @override
  String get currencyNameAed => 'VAE-Dirham';

  @override
  String get currencyNameSar => 'Saudi-Rial';

  @override
  String get currencyNameQar => 'Katar-Riyal';

  @override
  String get currencyNameOmr => 'Omanischer Rial';

  @override
  String get currencyNameKwd => 'Kuwait-Dinar';

  @override
  String get currencyNameBhd => 'Bahrain-Dinar';

  @override
  String get currencyNameJod => 'Jordanischer Dinar';

  @override
  String get currencyNameIls => 'Israelischer Neuer Schekel';

  @override
  String get currencyNameLbp => 'Libanesisches Pfund';

  @override
  String get currencyNameIqd => 'Irakischer Dinar';

  @override
  String get currencyNameZar => 'Südafrikanischer Rand';

  @override
  String get currencyNameEgp => 'Ägyptisches Pfund';

  @override
  String get currencyNameMad => 'Marokkanischer Dirham';

  @override
  String get currencyNameTnd => 'Tunesischer Dinar';

  @override
  String get currencyNameDzd => 'Algerischer Dinar';

  @override
  String get currencyNameKes => 'Kenia-Schilling';

  @override
  String get currencyNameTzs => 'Tansania-Schilling';

  @override
  String get currencyNameUgx => 'Uganda-Schilling';

  @override
  String get currencyNameRwf => 'Ruanda-Franc';

  @override
  String get currencyNameEtb => 'Äthiopischer Birr';

  @override
  String get currencyNameGhs => 'Ghanaischer Cedi';

  @override
  String get currencyNameNgn => 'Nigerianischer Naira';

  @override
  String get currencyNameXof => 'CFA-Franc (BCEAO)';

  @override
  String get currencyNameXaf => 'CFA-Franc (BEAC)';

  @override
  String get currencyNameMur => 'Mauritius-Rupie';

  @override
  String get currencyNameScr => 'Seychellen-Rupie';

  @override
  String get currencyNameNad => 'Namibia-Dollar';

  @override
  String get currencyNameBwp => 'Botswanischer Pula';

  @override
  String get currencyNameZmw => 'Kwacha';

  @override
  String get currencyNameMzn => 'Mosambikanischer Metical';

  @override
  String get currencyNameAoa => 'Angolanischer Kwanza';

  @override
  String get currencyNameMga => 'Madagaskar-Ariary';

  @override
  String get currencyNameCve => 'Cabo-Verde-Escudo';

  @override
  String get currencyNameGmd => 'Gambia-Dalasi';

  @override
  String get currencyNameNzd => 'Neuseeland-Dollar';

  @override
  String get currencyNameFjd => 'Fidschi-Dollar';

  @override
  String get currencyNameXpf => 'CFP-Franc';

  @override
  String get currencyNameWst => 'Samoanischer Tala';

  @override
  String get currencyNameVuv => 'Vanuatu-Vatu';

  @override
  String get currencyNameTop => 'Tongaischer Paʻanga';

  @override
  String get currencyNamePgk => 'Papua-neuguineischer Kina';

  @override
  String get expenseCategoryFood => 'Essen';

  @override
  String get expenseCategoryGroceries => 'Lebensmittel';

  @override
  String get expenseCategoryFuel => 'Kraftstoff';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryAccommodation => 'Unterkunft';

  @override
  String get expenseCategoryActivities => 'Aktivitäten';

  @override
  String get expenseCategoryTickets => 'Tickets';

  @override
  String get expenseCategoryShopping => 'Einkäufe';

  @override
  String get expenseCategoryParty => 'Feiern';

  @override
  String get expenseCategoryParking => 'Parken';

  @override
  String get expenseCategoryOther => 'Sonstiges';

  @override
  String get shellTripAlreadyInListOpened => 'Die Reise ist bereits in Ihrer Liste. Wir haben sie für Sie geöffnet.';

  @override
  String get shellJoinedTripFromInviteLink => 'Über den Einladungslink an der Reise teilgenommen.';

  @override
  String get shellFailedToOpenInviteLink => 'Der Einladungslink konnte nicht geöffnet werden.';

  @override
  String get shellFailedToOpenFriendLink => 'Der Freundeslink konnte nicht geöffnet werden.';

  @override
  String get shellTripInviteTitle => 'Reiseeinladung';

  @override
  String get shellNoAction => 'Nein';

  @override
  String get shellYesAction => 'Ja';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Nur der Reiseorganisator kann diese Reise löschen.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Nur aktive Reisen können gelöscht werden.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return '„$tripLabel“ löschen? Dies ist nur zulässig, bevor Ausgaben hinzugefügt werden.';
  }

  @override
  String get shellTripDeleted => 'Reise gelöscht.';

  @override
  String get shellFailedToDeleteTrip => 'Das Löschen der Reise ist fehlgeschlagen.';

  @override
  String get shellFailedToLoadNotifications => 'Benachrichtigungen konnten nicht geladen werden.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Neue Benachrichtigung: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Die Benachrichtigungen konnten nicht aktualisiert werden.';

  @override
  String get shellMarkAllAsReadAction => 'Alle als gelesen markieren';

  @override
  String get shellNewSection => 'Neu';

  @override
  String get shellEarlierSection => 'Früher';

  @override
  String get shellShowMoreEarlierAction => 'Mehr anzeigen (früher)';

  @override
  String get shellLoadingMore => 'Wird geladen...';

  @override
  String get shellLoadMoreNotificationsAction => 'Weitere Benachrichtigungen laden';

  @override
  String get shellTripNoLongerAvailable => 'Diese Reise ist nicht mehr verfügbar.';

  @override
  String get shellFailedToOpenTrip => 'Die Reise konnte nicht geöffnet werden.';

  @override
  String get shellYesterday => 'Gestern';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Du bist bereits Mitglied von „$tripName“. Diese Reise jetzt öffnen?\n\nEingeladen von: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Möchtest du an der Reise „$tripName“ teilnehmen?\n\nEingeladen von: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Ausgewähltes Bild: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Reisebild bereits festgelegt.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Reise erstellt, aber Bild-Upload fehlgeschlagen.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Reise erstellt, aber Bild-Upload fehlgeschlagen: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Per Einladung an einer Reise teilnehmen';

  @override
  String get tripsTotalTrips => 'Gesamtzahl der Reisen';

  @override
  String get tripsTotalSpent => 'Gesamtbetrag';

  @override
  String get tripsMixedCurrencies => 'Gemischte Währungen';

  @override
  String get tripsShowActive => 'Aktiv anzeigen';

  @override
  String get tripsSeeAll => 'Alle anzeigen';

  @override
  String get tripsGridView => 'Rasteransicht';

  @override
  String get tripsListView => 'Listenansicht';

  @override
  String get tripsAddNewTrip => 'Neue Reise hinzufügen';

  @override
  String get tripsLoadMore => 'Mehr laden';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return '„$arg1“ löschen? Dies ist nur zulässig, bevor Ausgaben hinzugefügt werden.';
  }

  @override
  String get tripsTripDates => 'Reisetermine';

  @override
  String get tripsFrom => 'Von';

  @override
  String get tripsSelectDate => 'Datum auswählen';

  @override
  String get tripsTo => 'Zu';

  @override
  String get tripsMainCurrency => 'Hauptwährung';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Bitte wählen Sie den Reisezeitraum (Start- und Enddatum) aus.';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Das Enddatum der Reise muss am oder nach dem Startdatum liegen.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Das Format des Reisezeitraums ist ungültig. Bitte wählen Sie die Daten erneut aus.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Du bist bereits Mitglied dieser Reise.';

  @override
  String get tripsJoinedTripSuccessfully => 'Reise erfolgreich beigetreten.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Der Beitritt zur Reise über die Einladung ist fehlgeschlagen.';

  @override
  String get tripsJoinTrip => 'An der Reise teilnehmen';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Fügen Sie den Einladungslink oder das Einladungs-Token ein.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Geben Sie einen gültigen Einladungslink oder ein gültiges Token ein.';

  @override
  String get tripsClipboardIsEmpty => 'Die Zwischenablage ist leer.';

  @override
  String get tripsPaste => 'Einfügen';

  @override
  String get tripsJoin => 'Beitreten';

  @override
  String get workspaceTripMembers => 'Reiseteilnehmer';

  @override
  String get workspaceFailedToLoadFriends => 'Freunde konnten nicht geladen werden.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Die Erstellung des Einladungslinks ist fehlgeschlagen.';

  @override
  String get workspaceInviteLink => 'Einladungslink';

  @override
  String get workspaceGeneratingInviteLink => 'Einladungslink wird generiert...';

  @override
  String get workspaceInviteLinkUnavailable => 'Einladungslink nicht verfügbar.';

  @override
  String get workspaceCopyInviteLink => 'Einladungslink kopieren';

  @override
  String get workspaceInviteLinkCopied => 'Einladungslink kopiert.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Ablauf: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Es sind keine Freunde verfügbar. Füge zuerst Freunde hinzu.';

  @override
  String get workspaceSettle => 'Abrechnen';

  @override
  String get workspaceOwesToTheGroup => 'Schuld gegenüber der Gruppe';

  @override
  String get workspaceGetsBackFromGroup => 'Bekommt Geld von der Gruppe zurück';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Anzeige der Top 4 nach Saldo-Differenz.';

  @override
  String get workspaceOpenFlow => 'Details';

  @override
  String get workspaceFriend => 'Freund';

  @override
  String get workspaceSettlementTransfer => 'Überweisung zur Abrechnung';

  @override
  String get workspaceCompleted => 'Abgeschlossen';

  @override
  String get workspaceWaitingForConfirmation => 'Warten auf Bestätigung';

  @override
  String get workspaceWaitingForPayment => 'Warten auf Zahlung';

  @override
  String get workspaceActionNeeded => 'Erforderliche Maßnahme';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return '$arg1 Zahlung(en) als gesendet markieren, $arg2 als erhalten bestätigen.';
  }

  @override
  String get workspaceReadyToSettle => 'Bereit zur Abrechnung';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Alle Teilnehmer sind bereit. Sie können mit der Abrechnung beginnen.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Es wird gewartet, bis alle sich als bereit markiert haben.';

  @override
  String get workspaceIMReady => 'Ich bin bereit';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Vergewissere dich, dass du alle deine Ausgaben hinzugefügt hast.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Die Schaltfläche „Beenden“ wird freigeschaltet, sobald alle Teilnehmer „Bereit“ markiert haben.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Bekommt Geld von der Gruppe zurück';

  @override
  String get workspaceSettledWithTheGroup => 'Mit der Gruppe abgeklärt';

  @override
  String get workspaceTotalPaid => 'Gesamtbetrag bezahlt';

  @override
  String get workspaceTotalOwes => 'Gesamtbetrag der Verbindlichkeiten';

  @override
  String get workspaceTransactionHistory => 'Transaktionsverlauf';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Für dieses Mitglied liegen noch keine Transaktionen vor.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Abrechnungen: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Alle Teilnehmer müssen sich als „bereit“ markieren, bevor mit der Abrechnung begonnen wird.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Sie haben sich als zahlungsbereit markiert.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Die Markierung „Zur Abrechnung bereit“ wurde entfernt.';

  @override
  String get workspaceReminderSent => 'Erinnerung gesendet.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Einladungslink oder aus dem Freundeskreis hinzufügen';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Nur der Reiseersteller kann diese Reise bearbeiten.';

  @override
  String get workspaceTripUpdated => 'Reise aktualisiert.';

  @override
  String get workspaceFailedToUpdateTrip => 'Die Aktualisierung der Reise ist fehlgeschlagen.';

  @override
  String get workspaceNoMembersSelectedYet => 'Es wurden noch keine Teilnehmer ausgewählt.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Kein Internet. Die Ausgabe wird ohne Belegbild gespeichert.';

  @override
  String get workspaceRandomPicker => 'Zufallsauswahl';

  @override
  String get workspaceCurrency => 'Währung';

  @override
  String get workspaceCategory => 'Kategorie';

  @override
  String get workspaceCustomCategory => 'Benutzerdefinierte Kategorie';

  @override
  String get workspaceCategoryName => 'Kategoriename';

  @override
  String get workspaceApartmentRentParkingEtc => 'Miete für eine Wohnung, Parkplatz usw.';

  @override
  String get workspaceEnterACustomCategory => 'Geben Sie eine benutzerdefinierte Kategorie ein.';

  @override
  String get workspacePickAnExpenseCategory => 'Wählen Sie eine Ausgabenkategorie aus.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Die Kategorie muss mindestens 2 Zeichen lang sein.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Die Kategorie darf maximal 64 Zeichen lang sein.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Die prozentuale Aufteilung muss insgesamt 100 % ergeben.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Die Anzahl der Anteile muss für alle Teilnehmer größer als 0 sein.';

  @override
  String get workspaceTotalAmount => 'Gesamtbetrag';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Gesamtkosten';

  @override
  String workspaceStarted(Object arg1) {
    return '$arg1 gestartet';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Beendet $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Archivierte Reise';

  @override
  String get workspaceActiveTrip => 'Aktive Reise';

  @override
  String get workspaceMemberProfile => 'Mitgliederprofil';

  @override
  String get workspaceTripOwner => 'Reiseveranstalter';

  @override
  String get workspaceMember => 'Mitglied';

  @override
  String get workspaceReadyForSettlement => 'Bereit zur Abrechnung';

  @override
  String get workspaceNotReadyForSettlement => 'Noch nicht bereit zur Abrechnung';

  @override
  String get workspaceBankDetails => 'Bankdaten';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN und Auszahlungsdetails werden hier in einem nächsten Update hinzugefügt.';

  @override
  String get workspacePaymentDetails => 'Zahlungsdetails';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Dieses Mitglied hat noch keine Auszahlungsdaten hinzugefügt.';

  @override
  String get workspaceBankTransfer => 'Banküberweisung';

  @override
  String get workspaceHolder => 'Inhaber';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Der Zahlungslink konnte nicht geöffnet werden.';

  @override
  String get workspaceTripActivity => 'Reiseaktivität';

  @override
  String get workspacePaidExpenses => 'Bezahlte Ausgaben';

  @override
  String get workspacePaidTotal => 'Gesamtbetrag';

  @override
  String get workspaceInvolvedIn => 'Beteiligt an';

  @override
  String get workspaceCurrentTrip => 'Aktuelle Reise';

  @override
  String get workspaceCommonTrips => 'Gemeinsame Reisen';

  @override
  String get workspaceLoadingCommonTrips => 'Gemeinsame Reisen werden geladen…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Noch keine gemeinsamen Reisen gefunden.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Nicht alle gemeinsamen Reisen konnten geladen werden. Die aktuelle Reise wird angezeigt.';

  @override
  String get workspaceMembers => 'Mitglieder';

  @override
  String get workspaceExpense => 'Ausgaben';

  @override
  String get workspacePaid => 'bezahlt';

  @override
  String get workspaceLoadingMoreExpenses => 'Weitere Ausgaben werden geladen...';

  @override
  String get workspaceScrollDownToLoadMore => 'Scrollen Sie nach unten, um weitere Inhalte zu laden';

  @override
  String get workspaceTripFinished => 'Reise beendet';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Die Abrechnungen für diese Reise sind freigeschaltet.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Beenden Sie die Reise, um die Abrechnungen zu starten.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 hat die Überweisung als gesendet markiert.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Warten auf $arg1, um als bezahlt zu markieren.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 hat den Zahlungseingang bestätigt.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Warten auf die Bestätigung von $arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Alle Reiseabrechnungen sind vollständig abgeschlossen.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Endzustand, nachdem alle Überweisungen bestätigt wurden.';

  @override
  String get workspaceSettlementFlow => 'Abrechnungsablauf';

  @override
  String get workspaceActions => 'Aktionen';

  @override
  String get workspaceQuickPay => 'Schnellzahlung';

  @override
  String get workspacePayWithRevolut => 'Bezahlen mit Revolut';

  @override
  String get workspacePayWithPaypal => 'Bezahlen mit PayPal';

  @override
  String get workspacePayWithWise => 'Bezahlen mit Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Die Überweisung wurde bestätigt.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Warten darauf, dass das andere Mitglied den nächsten Schritt abschließt.';

  @override
  String get workspaceSendReminder => 'Erinnerung senden';

  @override
  String get workspaceInProgress => 'In Bearbeitung';

  @override
  String get workspaceTimeUnknown => 'Zeit unbekannt';

  @override
  String get workspaceRemind => 'Zur Erinnerung';

  @override
  String get workspaceYourPosition => 'Ihre Position';

  @override
  String get workspaceRecentActivity => 'Aktuelle Aktivitäten';

  @override
  String get workspaceNoRecentActivityYet => 'Noch keine aktuellen Aktivitäten.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Füge mindestens ein Mitglied hinzu, um mit der Aufteilung der Ausgaben zu beginnen.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Markieren Sie sich als bereit zur Abrechnung, nachdem Sie alle Ihre Ausgaben hinzugefügt haben.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Noch nicht bereite Mitglieder: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Alle Teilnehmer sind bereit. Du kannst die Reise abschließen und mit der Abrechnung beginnen.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Alle Teilnehmer sind bereit. Es wird darauf gewartet, dass der Reiseveranstalter die Abrechnung einleitet.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Abrechnung läuft: $arg1/$arg2 bestätigt.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Es stehen keine Aktionen aus. Diese Reise ist abgeschlossen.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Derzeit sind keine Maßnahmen erforderlich.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Sie sollten $arg1 erhalten.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Sie sollten $arg1 bezahlen.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Sie sind derzeit für diese Reise angemeldet.';

  @override
  String get workspaceUnknownTime => 'Unbekannte Uhrzeit';

  @override
  String get workspaceJustNow => 'Gerade eben';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'vor $arg1 Min.';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'vor $arg1 Std.';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'vor $arg1 Tagen';
  }

  @override
  String get friendsRemoveFriend => 'Freund entfernen';

  @override
  String get friendsRemoveThisFriend => 'Diesen Freund entfernen?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 wird aus deiner Freundesliste entfernt. Du kannst die Person später wieder hinzufügen.';
  }

  @override
  String get friendsContinue => 'Weiter';

  @override
  String get friendsFriendRemoved => 'Freund entfernt.';

  @override
  String get friendsCouldNotRemoveFriend => 'Freund konnte nicht entfernt werden.';

  @override
  String get friendsFriendProfile => 'Freundesprofil';

  @override
  String get friendsMoreActions => 'Weitere Aktionen';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Dieser Freund hat noch keine Auszahlungsdaten hinzugefügt.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Gemeinsame Reisen konnten gerade nicht geladen werden.';

  @override
  String get friendsFinished => 'Fertig';

  @override
  String friendsTrip(Object arg1) {
    return 'Reise Nr. $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Mitglieder: $arg1';
  }

  @override
  String get friendsNoDate => 'Kein Datum';

  @override
  String get friendsIncomingRequests => 'EINGEHENDE ANFRAGEN';

  @override
  String get friendsSentInvites => 'VERSANDTE EINLADUNGEN';

  @override
  String get friendsMyFriends => 'MEINE FREUNDE';

  @override
  String get friendsRequests => 'Anfragen';

  @override
  String get friendsIncoming => 'Eingehend';

  @override
  String get friendsIncomingRequestSubtitle => 'möchte befreundet sein';

  @override
  String get friendsOutgoingInviteSubtitle => 'Einladung gesendet';

  @override
  String get friendsNoPendingActivity => 'Keine Freundschaftsanfragen';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Einladung an $arg1 gesendet.';
  }

  @override
  String get friendsNoIncomingRequests => 'Keine eingehenden Anfragen';

  @override
  String get friendsDecline => 'Ablehnen';

  @override
  String get friendsAccept => 'Akzeptieren';

  @override
  String get friendsNoSentInvites => 'Keine versendeten Einladungen';

  @override
  String get friendsNoFriendsYet => 'Noch keine Freunde';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Scrolle nach unten, um weitere Freunde zu laden.';

  @override
  String get friendsUser => 'Benutzer';

  @override
  String get friendsSearchUsers => 'Benutzer suchen';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Nach Namen oder E-Mail-Adresse suchen und Einladung versenden';

  @override
  String get friendsScanQr => 'QR-Code scannen';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Scannen Sie einen anderen Nutzer, um ihn als Freund hinzuzufügen';

  @override
  String get friendsMyQr => 'Mein QR-Code';

  @override
  String get friendsShowOrShareYourQrCode => 'Zeigen oder teilen Sie Ihren QR-Code';

  @override
  String get friendsScanFriendQrTitle => 'QR-Code eines Freundes scannen';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Fügen Sie den QR-Code eines Freundes in den Rahmen ein';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Halten Sie den QR-Code innerhalb des Rahmens';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return '$arg1 als Freund hinzufügen?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 wird Ihre Freundschaftsanfrage erhalten.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Die Freundschaftsanfrage von $arg1 annehmen?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Scanne diesen QR-Code oder teile den Link, um mich auf Splyto hinzuzufügen.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Füge mich auf Splyto hinzu.';

  @override
  String get friendsTripSplitFriendCode => 'Splyto-Freundeslink';

  @override
  String get shareAction => 'Teilen';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'Ein QR-Code ist kein gültiger Freundescode.';

  @override
  String get friendsYouCannotAddYourself => 'Sie können sich nicht selbst hinzufügen.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Dieser Nutzer befindet sich bereits in deiner Freundesliste.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Die Einladung an diesen Nutzer wurde bereits versendet.';

  @override
  String get friendsFriendRequestProcessed => 'Freundschaftsanfrage bearbeitet.';

  @override
  String get friendsFailedToProcessFriendQr => 'Die Verarbeitung des Freundes-QR-Codes ist fehlgeschlagen.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Ihr Benutzerprofil konnte nicht geladen werden.';

  @override
  String get friendsMyProfile => 'Mein Profil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Unerwarteter Fehler beim Laden von Freunden.';

  @override
  String get friendsFriendAdded => 'Freund hinzugefügt.';

  @override
  String get friendsRequestDeclined => 'Antrag abgelehnt.';

  @override
  String get friendsFailedToUpdateRequest => 'Die Aktualisierung der Anfrage ist fehlgeschlagen.';

  @override
  String get friendsCancelInvite => 'Einladung widerrufen';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Einladung an $arg1 widerrufen?';
  }

  @override
  String get friendsKeep => 'Behalten';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Einladung zu $arg1 storniert.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Die Einladung konnte nicht storniert werden.';

  @override
  String get analyticsOther => 'Sonstiges';

  @override
  String get analyticsSelectATripForAnalytics => 'Wählen Sie eine Reise für die Auswertung aus';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Mitglieder: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Tägliche Ausgaben';

  @override
  String get analyticsMyDaily => 'Meine täglichen Ausgaben';

  @override
  String get analyticsGroupDaily => 'Tägliche Gruppenausgaben';

  @override
  String get analyticsByMember => 'Nach Mitglied';

  @override
  String get analyticsShowLess => 'Weniger anzeigen';

  @override
  String get analyticsByCategory => 'Nach Kategorie';

  @override
  String get analyticsQuickInsights => 'Schnelle Einblicke';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Größter Kostenpunkt: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Größter Ausgeber: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Tag mit den meisten Gruppenmitgliedern: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Keine Daten';

  @override
  String get friendsSearchFailedTryAgain => 'Die Suche ist fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get friendsFailedToSendInvite => 'Das Senden der Einladung ist fehlgeschlagen.';

  @override
  String get friendsAddFriend => 'Freund hinzufügen';

  @override
  String get friendsSearchByNameOrEmail => 'Suche nach Name oder E-Mail-Adresse';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Geben Sie mindestens 2 Zeichen ein, um zu suchen.';

  @override
  String get friendsNoUsersFound => 'Keine Nutzer gefunden';

  @override
  String get friendsInviteAction => 'Einladen';

  @override
  String get workspacePaidForGroup => 'Bezahlt für die Gruppe';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Bezahlt für die Gruppe • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Kostenbeteiligung';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Kostenteilung • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Name des Inhabers kopiert.';

  @override
  String get paymentIbanCopied => 'IBAN kopiert.';

  @override
  String get paymentSwiftCopied => 'SWIFT kopiert.';

  @override
  String get paymentRevtagCopied => 'Revtag kopiert.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Konnte nicht in die Zwischenablage kopiert werden.';

  @override
  String get paymentCopied => 'Kopiert.';

  @override
  String get paymentRequestAction => 'Zahlung anfordern';

  @override
  String get paymentRecordAction => 'Zahlung erfassen';

  @override
  String get paymentRequestSheetTitle => 'Zahlung anfordern';

  @override
  String get paymentRecordSheetTitle => 'Zahlung erfassen';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Bitte $arg1, einen Betrag zu zahlen, den diese Person dir aktuell schuldet.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Nutze diese Funktion, nachdem du $arg1 außerhalb von Splyto bezahlt hast. Die Person bestätigt anschließend den Erhalt.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Maximal $arg1';
  }

  @override
  String get paymentNoteHint => 'Banküberweisung, Revolut, Bargeld...';

  @override
  String get paymentAmountPositiveError => 'Der Betrag muss größer als Null sein.';

  @override
  String get paymentAmountTooHighError => 'Der Betrag darf den ausstehenden Saldo nicht übersteigen.';

  @override
  String get paymentRequestCreated => 'Zahlungsaufforderung gesendet.';

  @override
  String get paymentRecordedWaiting => 'Zahlung erfasst. Warten auf Bestätigung.';

  @override
  String get paymentConfirmTitle => 'Zahlung bestätigen';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Bestätige, dass du $arg1 von $arg2 erhalten hast.';
  }

  @override
  String get paymentConfirmedMessage => 'Zahlung bestätigt.';

  @override
  String get paymentCancelRecordTitle => 'Zahlungsbeleg stornieren';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Den Eintrag deiner Zahlung über $arg1 an $arg2 stornieren?';
  }

  @override
  String get paymentRecordCancelled => 'Zahlungsbeleg storniert.';

  @override
  String get paymentNotReceivedTitle => 'Zahlung nicht eingegangen';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Die Zahlung über $arg1 von $arg2 als nicht erhalten markieren?';
  }

  @override
  String get paymentMarkedNotReceived => 'Zahlung als nicht eingegangen markiert.';

  @override
  String get paymentActivityTitle => 'Zahlungsvorgänge';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Offene Zahlungsanfragen: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Zahlungen, die auf Bestätigung warten: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Erfasste Zahlungen';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 hat eine Zahlung von $arg2 angefordert';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 hat $arg2 bezahlt';
  }

  @override
  String get paymentRequestPendingStatus => 'Zahlungsaufforderung';

  @override
  String get paymentAwaitingConfirmationStatus => 'Wartet auf Bestätigung';

  @override
  String get paymentReviewRequestAction => 'Anfrage prüfen';

  @override
  String get paymentViewDetailsAction => 'Zahlungsdetails';

  @override
  String get paymentMarkPaidAction => 'Ich habe bezahlt';

  @override
  String get paymentDeclineAction => 'Ablehnen';

  @override
  String get paymentRequestReviewTitle => 'Zahlungsaufforderung';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 hat $arg2 von dir angefordert. Bezahle außerhalb von Splyto und markiere die Zahlung anschließend als bezahlt.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Anfrage als bezahlt markieren?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Bestätige erst, nachdem du $arg1 an $arg2 außerhalb von Splyto bezahlt hast.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Als bezahlt markiert. Warten auf Bestätigung.';

  @override
  String get paymentRequestCancelTitle => 'Zahlungsanforderung stornieren?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Deine Zahlungsanfrage über $arg1 an $arg2 stornieren?';
  }

  @override
  String get paymentRequestCancelled => 'Zahlungsaufforderung storniert.';

  @override
  String get paymentRequestDeclineTitle => 'Zahlungsanfrage ablehnen?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Zahlungsanfrage von $arg2 über $arg1 ablehnen? Die Person wird benachrichtigt.';
  }

  @override
  String get paymentRequestDeclined => 'Zahlungsanforderung abgelehnt.';

  @override
  String get paymentPendingBeforeFinish => 'Klären Sie offene Zahlungsanfragen und unbestätigte Zahlungen vor der endgültigen Abrechnung.';

  @override
  String get paymentFinishBlockedByPending => 'Die Freigabe erfolgt, nachdem Zahlungsaufforderungen und unbestätigte Zahlungen geklärt sind.';

  @override
  String get notificationPaymentRequestedTitle => 'Zahlungsaufforderung';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 hat $arg2 von dir angefordert.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Sie haben eine Zahlungsanforderung erhalten.';

  @override
  String get notificationPaymentRequestSentTitle => 'Angeforderte Zahlung gesendet';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 hat Ihre $arg2-Zahlungsanforderung als bezahlt markiert.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Ihre Zahlungsanforderung wurde als bezahlt markiert.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Zahlungsaufforderung storniert';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 hat die Zahlungsanforderung von $arg2 storniert.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Eine Zahlungsanforderung wurde storniert.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Zahlungsanforderung abgelehnt';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 hat Ihre $arg2-Zahlungsanfrage abgelehnt.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Deine Zahlungsanforderung wurde abgelehnt.';

  @override
  String get notificationPaymentSentTitle => 'Zahlung als gesendet markiert';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 hat $arg2 als an dich bezahlt markiert.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Eine Zahlung wurde als an Sie gesendet markiert.';

  @override
  String get notificationPaymentConfirmedTitle => 'Zahlung bestätigt';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 hat den Erhalt von $arg2 von Ihnen bestätigt.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Ihre Zahlung wurde bestätigt.';

  @override
  String get notificationPaymentCancelledTitle => 'Zahlung storniert';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 hat die Zahlungsmarkierung für $arg2 aufgehoben.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Eine Zahlungsmarkierung wurde storniert.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Zahlung nicht eingegangen';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 hat die Zahlung $arg2 als nicht eingegangen markiert.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Eine Zahlung wurde als nicht eingegangen markiert.';

  @override
  String get quickStartTitle => 'Schnellstart';

  @override
  String get quickStartCreateTitle => 'Allein oder mit Freunden';

  @override
  String get quickStartCreateBody => 'Erstellen Sie eine Reise für sich oder eine Gruppe. Fügen Sie Freunde per Link oder QR-Code hinzu und laden Sie sie ein.';

  @override
  String get quickStartInviteTitle => 'Gemeinsam oder alleine reisen';

  @override
  String get quickStartInviteBody => 'Lade Freunde ein, an deiner Reise teilzunehmen, oder starte ganz allein eine persönliche Reise.';

  @override
  String get quickStartExpenseTitle => 'Ausgaben in vielen Währungen';

  @override
  String get quickStartExpenseBody => 'Wählen Sie, wer gezahlt hat und wie geteilt wird. Andere Währungen werden zum Kurs des Kaufdatums umgerechnet, auch wenn Sie sie später eintragen.';

  @override
  String get quickStartSettleTitle => 'Einfach abrechnen';

  @override
  String get quickStartSettleBody => 'Sehen Sie, wer wem etwas schuldet, zahlen Sie auf Ihre Weise und bestätigen Sie es in der App.';

  @override
  String get quickStartAnalyticsTitle => 'Budget und Ausgaben';

  @override
  String get quickStartAnalyticsBody => 'Legen Sie ein Budget für Ihre Reise oder Gruppe fest und sehen Sie Ausgaben nach Kategorie, Reise und Tag.';

  @override
  String get quickStartMapTitle => 'Ihre Orte festhalten';

  @override
  String get quickStartMapBody => 'Fügen Sie besuchte Städte zu Ihrer privaten Reisekarte hinzu. Nur Sie können sie sehen.';

  @override
  String get quickStartLiveTitle => 'Einander finden';

  @override
  String get quickStartLiveBody => 'Teilen Sie auf Gruppenreisen Ihren Live-Standort für die gewählte Zeit. Reiseteilnehmer können ihn sehen, und Sie können jederzeit beenden.';

  @override
  String get quickStartNext => 'Weiter';

  @override
  String get quickStartBack => 'Zurück';

  @override
  String get quickStartSkip => 'Überspringen';

  @override
  String get quickStartCreateAction => 'Reise erstellen';

  @override
  String get quickStartSignUpAction => 'Registrieren';

  @override
  String get quickStartClose => 'Schnellstart schließen';

  @override
  String get quickStartSubtitle => 'Erfahren Sie, wie Reisen und Spesen funktionieren';

  @override
  String quickStartStep(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get workspaceTripTotal => 'Reisekosten insgesamt';

  @override
  String get workspacePersonalTotal => 'Gesamtbetrag';

  @override
  String get workspaceBalanceEven => 'Dein Saldo ist ausgeglichen';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Du schuldest $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Du erhältst $amount zurück';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Mitglieder: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Ausgaben suchen';

  @override
  String get workspaceClearSearch => 'Klare Suche';

  @override
  String get workspaceSearchLoadedHint => 'Die Suche umfasst hochgeladene Ausgaben. Laden Sie weitere hoch, um ältere Ausgaben einzubeziehen.';

  @override
  String get workspaceNoExpenseMatches => 'Keine passenden Ausgaben';

  @override
  String get workspaceNoExpenseMatchesBody => 'Versuchen Sie eine andere Suche oder löschen Sie die Suchanfrage, um alle geladenen Ausgaben anzuzeigen.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Füge deine erste Ausgabe hinzu, um mit der Erfassung deiner Ausgaben zu beginnen.';

  @override
  String get workspaceEmptyGroupExpenses => 'Füge deine erste geteilte Ausgabe hinzu, um den Anteil jedes Teilnehmers zu sehen.';

  @override
  String get workspaceLoadMoreExpenses => 'Weitere Ausgaben laden';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Ursprünglicher Betrag: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Kommentare: $count';
  }

  @override
  String get workspaceExpenseActions => 'Maßnahmen im Zusammenhang mit Ausgaben';

  @override
  String get workspaceLoadErrorTitle => 'Diese Reise konnte nicht geladen werden';

  @override
  String get workspaceCachedWarning => 'Anzeige gespeicherter Daten. Diese können veraltet sein.';

  @override
  String get workspaceActivityTab => 'Aktivität';

  @override
  String get workspaceLoadingTrip => 'Reise wird geladen';

  @override
  String get workspaceRefreshFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get expenseDetailsTitle => 'Ausgabenangaben';

  @override
  String get expenseQuickCategories => 'Schnellkategorien';

  @override
  String get expenseReceiptUploading => 'Beleg wird hochgeladen…';

  @override
  String get expenseReceiptUploadOnSave => 'Der Beleg wird beim Speichern hochgeladen.';

  @override
  String get expenseCommentsLoadFailed => 'Kommentare konnten nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get expenseReplyAction => 'Antworten';

  @override
  String get expenseReplyHint => 'Eine Antwort schreiben…';

  @override
  String expenseReplyTo(String name) {
    return 'Antwort an $name';
  }

  @override
  String get balanceEmptyBody => 'Salden werden angezeigt, nachdem Ausgaben hinzugefügt wurden.';

  @override
  String get balanceAfterPayments => 'Die Kontostände enthalten bestätigte Zahlungen.';

  @override
  String get balanceExpenseShare => 'Kostenbeteiligung';

  @override
  String get balanceHistoryScope => 'Hochgeladene Ausgaben und bestätigte Zahlungen. Diese Liste enthält möglicherweise nicht den gesamten Reiseverlauf.';

  @override
  String balancePaymentTo(String name) {
    return 'Zahlung an $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Zahlung von $name';
  }

  @override
  String get settlementEmptyActive => 'Markieren Sie alle als bereit, bevor Sie mit der endgültigen Abrechnung beginnen.';

  @override
  String get settlementEmptyClosed => 'Für diese Reise sind keine Überweisungen aufgeführt.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count von $total Überweisungen bestätigt';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count von $total Mitgliedern bereit';
  }

  @override
  String get settlementMemberReady => 'Bereit';

  @override
  String get settlementMemberNotReady => 'Noch nicht bereit';

  @override
  String get settlementSuggested => 'Vorgeschlagene Übertragung';

  @override
  String get activityLoadFailed => 'Die Aktivitäten konnten nicht aktualisiert werden. Alle sichtbaren Einträge sind möglicherweise veraltet.';

  @override
  String get activityMember => 'Reiseteilnehmer';

  @override
  String get friendsEmptyBody => 'Finden Sie einen Freund anhand des Namens oder der E-Mail-Adresse oder verwenden Sie einen QR-Code.';

  @override
  String get friendsDeclineAction => 'Ablehnen';

  @override
  String get friendsLoading => 'Freunde werden geladen';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Geteilte Reisen: $count';
  }

  @override
  String get memberActivityScope => 'Basierend auf den hochgeladenen Ausgaben; dies deckt möglicherweise nicht die gesamte Reise ab.';

  @override
  String get sharedTripsLoadedLimit => 'Es werden bis zu 20 geteilte Reisen angezeigt.';

  @override
  String get memberRemoveTitle => 'Mitglied entfernen?';

  @override
  String memberRemoveBody(String name) {
    return '$name aus dieser Reise entfernen? Dies ist nur möglich, wenn keine Ausgaben, Abrechnungen oder Salden vorliegen.';
  }

  @override
  String get memberRemoveAction => 'Aus der Reise entfernen';

  @override
  String memberRemoved(String name) {
    return '$name wurde aus der Reise entfernt.';
  }

  @override
  String get profilePaymentNotAdded => 'Noch nicht hinzugefügt';

  @override
  String get friendRelationshipLabel => 'Freund';

  @override
  String get sharedTripsEmptyBody => 'Reisen, an denen ihr beide teilnehmt, werden hier angezeigt.';

  @override
  String get analyticsAllTrips => 'Alle Reisen';

  @override
  String get analyticsByTrip => 'Nach Reise';

  @override
  String get analyticsYourSpending => 'Deine Ausgaben';

  @override
  String get analyticsActiveArchived => 'Aktive & archivierte Reisen';

  @override
  String get analyticsTrips => 'Reisen';

  @override
  String get analyticsAveragePerTrip => 'Durchschnitt pro Reise';

  @override
  String get analyticsPaidByMember => 'Bezahlung durch das Mitglied';

  @override
  String get analyticsYouPaid => 'Du hast bezahlt';

  @override
  String get analyticsYouGetBack => 'Du erhältst zurück';

  @override
  String get analyticsYouOwe => 'Du schuldest';

  @override
  String get analyticsParticipants => 'Teilnehmer';

  @override
  String get analyticsYourCategories => 'Ihre Ausgaben nach Kategorien';

  @override
  String get analyticsLargestShares => 'Meine größten Kostenanteile';

  @override
  String get analyticsLargestExpenses => 'Größte Ausgaben';

  @override
  String get analyticsSpendingByTrip => 'Ihre Ausgaben pro Reise';

  @override
  String get analyticsEmptyTitle => 'Bisher keine Ausgaben';

  @override
  String get analyticsEmptyBody => 'Ihre Ausgaben werden hier angezeigt, wenn Sie einer Reise Ausgaben hinzufügen.';

  @override
  String get analyticsPeriodEmptyBody => 'Für diese Ansicht fallen keine Kosten an. Versuchen Sie es mit einer anderen Reise oder einem anderen Zeitraum.';

  @override
  String get analyticsLoadFailed => 'Der vollständige Ausgabenbericht konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get analyticsLastLoaded => 'Anzeige des zuletzt erfolgreich geladenen Berichts.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben',
      one: '$count Ausgabe',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Reiseoptionen';

  @override
  String get editTripAction => 'Reise bearbeiten';

  @override
  String get deleteTripAction => 'Reise löschen';

  @override
  String get inviteTripMembersAction => 'Mitglieder einladen';

  @override
  String get tripCoverPhoto => 'Titelbild';

  @override
  String get tripInviteLaterHint => 'Sie können Personen einladen, nachdem Sie die Reise erstellt haben.';

  @override
  String get inviteClipboardFailed => 'Auf die Zwischenablage konnte nicht zugegriffen werden. Bitte versuche es erneut.';

  @override
  String get friendInviteToTrip => 'Zur Reise einladen';

  @override
  String get friendChooseTrip => 'Wähle eine Reise aus';

  @override
  String get friendNoInvitableTrips => 'Es sind keine Reisen verfügbar. Du kannst Freunde zu aktiven Gruppenreisen einladen, die du verwaltest, sofern sie nicht bereits Mitglieder sind oder eine ausstehende Einladung haben.';

  @override
  String get friendTripInviteSent => 'Einladung gesendet.';

  @override
  String get friendTripUnavailable => 'Diese Reise steht für diese Aktion nicht mehr zur Verfügung. Aktualisieren Sie die Seite und versuchen Sie es erneut.';

  @override
  String get friendTripActionFailed => 'Diese Aktion konnte nicht abgeschlossen werden. Bitte versuche es erneut.';

  @override
  String get profileContactDescription => 'Hast du ein Problem, einen Vorschlag oder eine Frage zu Splyto? Schreib uns eine E-Mail – wir helfen dir gerne weiter.';

  @override
  String get profileContactEmailAction => 'Schreiben Sie eine E-Mail';

  @override
  String get profileContactEmailUnavailable => 'Die E-Mail-App konnte nicht geöffnet werden. Kopieren Sie die Adresse und schreiben Sie uns über Ihre E-Mail-App.';

  @override
  String get profilePrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get privacyLoadFailed => 'Die Datenschutzerklärung konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get addReceiptAction => 'Beleg hinzufügen';

  @override
  String get receiptPickFailed => 'Der Beleg konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get receiptPhotoAccessDenied => 'Erlauben Sie Splyto in den Einstellungen den Zugriff auf die Kamera oder die Fotobibliothek und versuchen Sie es dann erneut.';

  @override
  String get receiptPhotoLabel => 'Belegfoto';

  @override
  String get replaceReceiptAction => 'Quittung ersetzen';

  @override
  String get removeReceiptAction => 'Quittung entfernen';

  @override
  String get restoreReceiptAction => 'Vorherige Quittung wiederherstellen';

  @override
  String get expenseSplitBetween => 'Aufteilung zwischen';

  @override
  String get expenseEditParticipants => 'Teilnehmer auswählen';

  @override
  String get expenseCustomSplit => 'Individuelle Aufteilung';

  @override
  String get expenseAdjustmentsLabel => 'Anpassungen';

  @override
  String get expenseAdjustmentFieldLabel => '+ oder −';

  @override
  String get expenseAdjustmentsHint => 'Für jede Person addieren oder abziehen. Der Rest wird gleichmäßig aufgeteilt.';

  @override
  String get expenseAdjustmentsMustFit => 'Anpassungen dürfen die Summe nicht übersteigen, und niemand darf weniger als null schulden.';

  @override
  String get expenseItemsLabel => 'Positionen';

  @override
  String get expenseAddItem => 'Position hinzufügen';

  @override
  String get expenseRemoveItem => 'Position entfernen';

  @override
  String get expenseItemName => 'Position';

  @override
  String get expenseItemExtra => 'Steuer oder Trinkgeld';

  @override
  String get expenseItemExtraHint => 'Wird anteilig nach den Positionen jeder Person aufgeteilt.';

  @override
  String get expenseItemsInvalid => 'Jede Position braucht einen Namen, einen Betrag und mindestens eine Person.';

  @override
  String expenseItemsTotal(String total) {
    return 'Summe der Positionen: $total';
  }

  @override
  String expenseItemsMustMatchTotal(String total) {
    return 'Die Positionen müssen $total ergeben.';
  }

  @override
  String get tripGuestAddAction => 'Person ohne App hinzufügen';

  @override
  String get tripGuestNameLabel => 'Name';

  @override
  String get tripGuestAddHint => 'Die Person braucht die App nicht. Du trägst ein, was sie bezahlt hat, und markierst ihre Zahlungen.';

  @override
  String get tripGuestBadge => 'Ohne App';

  @override
  String get tripGuestRenameAction => 'Namen ändern';

  @override
  String tripGuestAdded(String name) {
    return '$name hinzugefügt';
  }

  @override
  String expenseSplitAllocated(String amount) {
    return 'Gesamte $amount aufgeteilt';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return '$amount noch aufzuteilen';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount über dem Gesamtbetrag';
  }

  @override
  String get profilePaymentSharingTitle => 'Zahlungsmethoden für meine Reisen freigeben';

  @override
  String get profilePaymentSharingDescription => 'Erlaube bestätigten Mitgliedern von Reisen, die ich erstelle oder denen ich beitrete, meine Zahlungsmethoden einzusehen. Dies gilt für aktuelle und zukünftige Reisen. Du kannst die Freigabe jederzeit deaktivieren, um weiteren Zugriff zu verhindern.';

  @override
  String get memberPaymentDetailsNotShared => 'Zahlungsmethoden werden nicht weitergegeben oder sind derzeit nicht verfügbar.';

  @override
  String get homeTripInvitations => 'Reiseeinladungen';

  @override
  String get homeNoTripInvitations => 'Keine ausstehenden Reiseeinladungen';

  @override
  String get homeInvitationsLoadFailed => 'Einladungen konnten nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get homeInvitationResponseFailed => 'Die Einladung konnte nicht beantwortet werden. Bitte versuche es erneut.';

  @override
  String get homeTripShareFailed => 'Die Reise konnte nicht geteilt werden. Bitte versuche es erneut.';

  @override
  String get settleStillToReceive => 'Noch zu erhalten';

  @override
  String get settleStillToPay => 'Noch zu bezahlen';

  @override
  String get settleEstimateCaption => 'Die Schätzung basiert auf den aktuellen Ausgaben. Die Beträge können sich bis zum Ende der Reise ändern.';

  @override
  String get settleOutstandingCaption => 'Warten auf Zahlung oder Bestätigung.';

  @override
  String get settleWaitingForYou => 'Wir warten darauf, dass du dich als bereit markierst.';

  @override
  String get settleWhoPaysWhom => 'Wer bezahlt wen?';

  @override
  String get settlePreviewCaption => 'Vorschau · wird nach Beendigung der Reise finalisiert';

  @override
  String get settleOpenPaymentCaption => 'Öffnen Sie eine Zahlung, um Details und verfügbare Aktionen anzuzeigen.';

  @override
  String get tripBudgetEnable => 'Legen Sie ein Budget fest';

  @override
  String get tripBudgetSoloHint => 'Optionales Ausgabenziel für diese Reise.';

  @override
  String get tripBudgetGroupHint => 'Ein gemeinsames Budget für die gesamte Gruppe.';

  @override
  String get tripBudgetAmount => 'Budgetbetrag';

  @override
  String get tripBudgetInvalid => 'Geben Sie einen Betrag zwischen 0,01 und 999999999,99 ein, mit bis zu zwei Dezimalstellen.';

  @override
  String get tripBudgetTitle => 'Reisebudget';

  @override
  String get tripBudgetGroupTitle => 'Gruppenbudget';

  @override
  String get tripBudgetRemaining => 'Verbleibend';

  @override
  String get tripBudgetOver => 'Budgetüberschreitung';

  @override
  String get tripBudgetSpent => 'Ausgegeben';

  @override
  String get tripBudgetLimit => 'Budget';

  @override
  String get travelMapTitle => 'Meine Reisekarte';

  @override
  String get travelMapSubtitle => 'Besuchte Orte – nur für dich.';

  @override
  String get travelMapHere => 'Ich war schon einmal hier';

  @override
  String get travelMapAdd => 'Ort hinzufügen';

  @override
  String get travelMapSearch => 'Stadt und Land suchen';

  @override
  String get travelMapSearchAction => 'Suche';

  @override
  String get travelMapSearchHint => 'Zum Beispiel: Lissabon, Portugal';

  @override
  String get travelMapEmpty => 'Deine nächste Erinnerung beginnt hier';

  @override
  String get travelMapEmptyBody => 'Füge eine Stadt hinzu, die du besucht hast, oder checke dort ein, wo du dich gerade befindest.';

  @override
  String get travelMapConfirm => 'Diesen Besuch speichern?';

  @override
  String get travelMapConfirmBody => 'Überprüfen Sie die Stadt und das Datum, bevor Sie diese in Ihrer privaten Karte speichern.';

  @override
  String get travelMapDate => 'Besuchsdatum';

  @override
  String get travelMapSave => 'Auf meiner Karte speichern';

  @override
  String get travelMapCancel => 'Abbrechen';

  @override
  String get travelMapClose => 'Schließen';

  @override
  String get travelMapNoResults => 'Keine Stadt gefunden. Versuchen Sie, das Land zu Ihrer Suche hinzuzufügen.';

  @override
  String get travelMapLookupError => 'Die Stadt konnte nicht gefunden werden. Überprüfen Sie Ihre Verbindung oder fügen Sie einen Ort manuell hinzu.';

  @override
  String get travelMapDenied => 'Der Standortzugriff ist deaktiviert. Sie können dennoch manuell eine Stadt hinzufügen.';

  @override
  String get travelMapDisabled => 'Aktivieren Sie die Standortdienste oder fügen Sie eine Stadt manuell hinzu.';

  @override
  String get travelMapError => 'Ihre Reisekarte konnte nicht geladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get travelMapSaveError => 'Der Besuch konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get travelMapUnavailable => 'Die Reisekarte benötigt ein Server-Update.';

  @override
  String get travelMapOffline => 'Offline · gespeicherte Orte anzeigen';

  @override
  String get travelMapRetry => 'Erneut versuchen';

  @override
  String get travelMapDelete => 'Besuch entfernen';

  @override
  String get travelMapDeleteConfirm => 'Soll dieser Besuch von deiner privaten Karte entfernt werden?';

  @override
  String get travelMapFit => 'Alle Orte anzeigen';

  @override
  String get travelMapSaved => 'Besuch gespeichert';

  @override
  String get travelMapVisited => 'Besucht';

  @override
  String get travelMapLimit => 'Ihre Karte hat 1.000 Besuche erreicht. Löschen Sie einen alten Besuch, bevor Sie einen neuen hinzufügen.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries Länder',
      one: '$countries Land',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities Städte',
      one: '$cities Stadt',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Besuche',
      one: '$count Besuch',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Reiseziele (optional)';

  @override
  String get travelAddDestination => 'Ziel hinzufügen';

  @override
  String get travelRemoveDestination => 'Zielort entfernen';

  @override
  String get travelFromTrip => 'Aus einer Reise';

  @override
  String get travelChooseTrip => 'Wähle eine Reise aus';

  @override
  String get travelNoTrips => 'Es sind noch keine Reisen verfügbar. Du kannst einen Ort manuell hinzufügen.';

  @override
  String get travelAddToMap => 'Zu meiner Karte hinzufügen';

  @override
  String get travelTripConfirm => 'Speichere nur Orte, die du tatsächlich besucht hast. So fügst du deiner Karte eine persönliche Erinnerung hinzu.';

  @override
  String get travelVisitTitle => 'Titel (optional)';

  @override
  String get travelAddPhoto => 'Foto hinzufügen';

  @override
  String get travelChangePhoto => 'Foto ändern';

  @override
  String get travelRemovePhoto => 'Foto entfernen';

  @override
  String get travelPhotoError => 'Dieses Foto konnte nicht vorbereitet werden. Bitte wählen Sie ein anderes aus.';

  @override
  String get travelEditVisit => 'Besuch bearbeiten';

  @override
  String get travelOpenTrip => 'Reise eröffnen';

  @override
  String get travelPreviousVisit => 'Vorheriger Besuch';

  @override
  String get travelNextVisit => 'Nächster Besuch';

  @override
  String get travelDuplicate => 'Dieser Besuch ist bereits auf Ihrer Karte vermerkt.';

  @override
  String get liveMapTitle => 'Live-Karte';

  @override
  String get liveShareTitle => 'Meinen Standort teilen';

  @override
  String get liveConsent => 'Teile deinen genauen Standort nur mit bestätigten Mitgliedern dieser Reise und nur für die von dir gewählte Dauer. Die Freigabe läuft im Hintergrund weiter. Du kannst sie jederzeit beenden.';

  @override
  String get liveBackgroundNote => 'Aktualisierungen können ohne Internetverbindung oder beim erzwungenen Schließen der App unterbrochen werden. Es wird nur der letzte Standort gespeichert; es wird kein Routenverlauf aufgezeichnet.';

  @override
  String get liveStart => 'Freigabe starten';

  @override
  String get liveStop => 'Freigabe beenden';

  @override
  String get liveNotification => 'Ihr Standort wird mit Ihrer Reise geteilt. Öffnen Sie Splyto, um die Freigabe zu beenden.';

  @override
  String get livePermissionError => 'Aktiviere den Standortzugriff in den Einstellungen deines Telefons, um deinen Standort zu teilen.';

  @override
  String get liveStartError => 'Die Freigabe konnte nicht gestartet werden. Überprüfen Sie den Standortzugriff, die Internetverbindung sowie Datum und Uhrzeit Ihres Smartphones.';

  @override
  String get liveStopPending => 'Aktualisierungen wurden gestoppt. Es wird auf eine Internetverbindung gewartet, um Ihren letzten Standort zu entfernen; dieser verschwindet ohne Aktualisierungen innerhalb von 2 Minuten von der Karte.';

  @override
  String get liveSharing => 'teilt den Standort';

  @override
  String get liveUnavailable => 'Diese Live-Karte ist nicht verfügbar. Kehre zur Reise zurück und aktualisiere die Seite.';

  @override
  String get liveMapLoadError => 'Die Karte konnte nicht geladen werden. Überprüfen Sie Ihre Verbindung und öffnen Sie die Karte erneut.';

  @override
  String get liveLoadError => 'Standorte konnten nicht aktualisiert werden. Es werden nur die letzten Aktualisierungen angezeigt.';

  @override
  String get liveFit => 'Alle auf der Karte zeigen';

  @override
  String get liveEmpty => 'Bislang gibt noch niemand seinen aktuellen Standort weiter.';

  @override
  String get liveRecent => 'Soeben aktualisiert';

  @override
  String get liveLastKnown => 'Zuletzt aktualisiert';

  @override
  String get liveAccuracy => 'Genauigkeit';

  @override
  String get liveUntil => 'Freigabe bis';

  @override
  String get liveOtherSession => 'In einer anderen Sitzung gestartet. Sie können es hier beenden.';

  @override
  String get liveUpdatesPaused => 'Aktualisierungen wurden angehalten. Überprüfen Sie den Standortzugriff und die Internetverbindung.';

  @override
  String get livePrivateUntilShared => 'Dein Standort bleibt privat, bis du dich entscheidest, ihn freizugeben.';

  @override
  String get activityEventExpenseCreated => 'hat eine Ausgabe hinzugefügt';

  @override
  String get activityEventExpenseUpdated => 'hat eine Ausgabe aktualisiert';

  @override
  String get activityEventExpenseDeleted => 'hat eine Ausgabe gelöscht';

  @override
  String get activityEventExpenseCommentAdded => 'hat eine Ausgabe kommentiert';

  @override
  String get activityEventTripCreated => 'hat die Reise erstellt';

  @override
  String get activityEventTripUpdated => 'hat die Reisedetails aktualisiert';

  @override
  String get activityEventTripRenamed => 'hat die Reise umbenannt';

  @override
  String get activityEventTripCurrencyChanged => 'hat die Reisewährung geändert';

  @override
  String get activityEventTripPhotoChanged => 'hat das Reisefoto geändert';

  @override
  String get activityEventTripBudgetChanged => 'hat das Reisebudget geändert';

  @override
  String get activityEventTripDestinationsChanged => 'hat die Reiseziele geändert';

  @override
  String get activityEventTripMembersAdded => 'hat Mitglieder hinzugefügt';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'hat Einladungen versendet: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'ist der Reise beigetreten';

  @override
  String get activityEventTripInvitationDeclined => 'hat die Reiseeinladung abgelehnt';

  @override
  String get activityEventTripInvitationRevoked => 'hat eine Reiseeinladung storniert';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'hat $name aus der Reise entfernt';
  }

  @override
  String get activityEventTripMemberLeft => 'hat die Reise verlassen';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'hat die Rolle von $name in $role geändert';
  }

  @override
  String get activityEventTripMemberReady => 'hat sich als abrechnungsbereit markiert';

  @override
  String get activityEventTripMemberNotReady => 'hat sich als noch nicht bereit markiert';

  @override
  String get activityEventTripAllMembersReady => 'Alle Teilnehmer sind bereit zur Abrechnung';

  @override
  String get activityEventTripFinished => 'hat die Reise beendet';

  @override
  String get activityEventTripSettled => 'Alle Überweisungen sind bestätigt, die Reise ist abgerechnet';

  @override
  String get activityEventSettlementMarkedSent => 'hat eine Überweisung als gesendet markiert';

  @override
  String get activityEventSettlementConfirmed => 'hat eine Überweisung bestätigt';

  @override
  String get activityEventSettlementSentCancelled => 'hat den Status „gesendet“ storniert';

  @override
  String get activityEventSettlementNotReceived => 'hat eine Überweisung als nicht eingegangen markiert';

  @override
  String get activityEventSettlementReminderSent => 'hat eine Zahlungserinnerung gesendet';

  @override
  String get activityEventPaymentMarkedSent => 'hat eine Zahlung verbucht';

  @override
  String get activityEventPaymentRequested => 'hat eine Zahlung angefordert';

  @override
  String get activityEventPaymentRequestMarkedSent => 'hat eine angeforderte Zahlung als gesendet markiert';

  @override
  String get activityEventPaymentRequestCancelled => 'hat eine Zahlungsanforderung storniert';

  @override
  String get activityEventPaymentRequestDeclined => 'hat eine Zahlungsanforderung abgelehnt';

  @override
  String get activityEventPaymentConfirmed => 'hat eine Zahlung bestätigt';

  @override
  String get activityEventPaymentCancelled => 'hat einen Zahlungsbeleg storniert';

  @override
  String get activityEventPaymentNotReceived => 'hat eine Zahlung als nicht eingegangen markiert';

  @override
  String get activityEventUnknown => 'hat eine Änderung vorgenommen';

  @override
  String get privacyEnglishFallback => 'Die Datenschutzerklärung ist derzeit auf Englisch verfügbar.';

  @override
  String get activityRoleAdmin => 'Admin';

  @override
  String get accountDeleteTitle => 'Konto löschen';

  @override
  String get accountDeleteIntro => 'Bestätige die Löschung per E-Mail. Danach kann sie nicht rückgängig gemacht werden.';

  @override
  String get accountDeleteConsequences => 'Die Löschung ist endgültig. Dein Profil wird anonymisiert und der Kontozugriff entfernt. Gemeinsame Reise- und Ausgabeneinträge bleiben für andere Mitglieder erhalten.';

  @override
  String get accountDeleteReasonsTitle => 'Was hätten wir besser machen können?';

  @override
  String get accountDeleteReasonsHint => 'Grund (optional)';

  @override
  String get accountDeleteReasonNotUsing => 'Ich benötige Splyto für meine Reisen nicht mehr';

  @override
  String get accountDeleteReasonAnotherWay => 'Ich verwalte geteilte Ausgaben auf andere Weise';

  @override
  String get accountDeleteReasonComplicated => 'Die Bedienung ist mir zu umständlich';

  @override
  String get accountDeleteReasonTechnical => 'Ich bin auf Fehler oder technische Probleme gestoßen';

  @override
  String get accountDeleteReasonPrivacy => 'Ich möchte meine Kontodaten lieber löschen';

  @override
  String get accountDeleteReasonOther => 'Ich möchte mein Konto aus einem anderen Grund löschen';

  @override
  String get accountDeleteEmailStep => 'Der nächste Schritt ist die Bestätigung per E-Mail.';

  @override
  String get accountDeletePasswordHint => 'Gib dein aktuelles Splyto-Passwort ein, um die Bestätigungs-E-Mail anzufordern. Dein Konto ist weiterhin aktiv.';

  @override
  String get accountDeleteInboxTitle => 'Ein letzter Schritt in deinem Posteingang';

  @override
  String accountDeleteSentBody(String email) {
    return 'Bestätigungslink an $email gesendet.';
  }

  @override
  String get accountDeleteSentHint => 'Dein Konto bleibt aktiv, bis du die Löschung bestätigst.';

  @override
  String get accountDeleteSending => 'Versenden einer Bestätigungs-E-Mail';

  @override
  String get friendsShowMore => 'Mehr anzeigen';

  @override
  String get tripReportTitle => 'Reisebericht';

  @override
  String get tripReportDetailedTitle => 'Ausführlicher Reisebericht';

  @override
  String get tripReportDates => 'Zeitraum';

  @override
  String get tripReportDestinations => 'Reiseziele';

  @override
  String get tripReportTotalSpent => 'Gesamtausgaben';

  @override
  String get tripReportExpenses => 'Ausgaben';

  @override
  String get tripReportYouPaid => 'Du hast bezahlt';

  @override
  String get tripReportYourShare => 'Dein Anteil';

  @override
  String get tripReportYourBalance => 'Dein Saldo';

  @override
  String get tripReportYourSettlements => 'Deine Abrechnungen';

  @override
  String tripReportYouPay(Object arg1) {
    return 'Du zahlst an $arg1';
  }

  @override
  String tripReportPaysYou(Object arg1) {
    return '$arg1 zahlt an dich';
  }

  @override
  String get tripReportStatus => 'Status';

  @override
  String get tripReportStatusPending => 'Offen';

  @override
  String get tripReportStatusSent => 'Gesendet';

  @override
  String get tripReportStatusConfirmed => 'Bestätigt';

  @override
  String get tripReportNoSettlements => 'Für dich gibt es nichts abzurechnen.';

  @override
  String get tripReportByCategory => 'Ausgaben nach Kategorie';

  @override
  String get tripReportCategory => 'Kategorie';

  @override
  String get tripReportAmount => 'Betrag';

  @override
  String get tripReportMembers => 'Mitglieder';

  @override
  String get tripReportMember => 'Mitglied';

  @override
  String get tripReportPaid => 'Bezahlt';

  @override
  String get tripReportShare => 'Anteil';

  @override
  String get tripReportBalance => 'Saldo';

  @override
  String get tripReportAllExpenses => 'Alle Ausgaben';

  @override
  String get tripReportDate => 'Datum';

  @override
  String get tripReportDescription => 'Beschreibung';

  @override
  String get tripReportPaidBy => 'Bezahlt von';

  @override
  String get tripReportOriginalAmount => 'Ursprünglicher Betrag';

  @override
  String get tripReportCurrency => 'Währung';

  @override
  String get tripReportRate => 'Kurs';

  @override
  String get tripReportPayments => 'Zahlungen';

  @override
  String get tripReportFrom => 'Von';

  @override
  String get tripReportTo => 'An';

  @override
  String get tripReportFooter => 'Erstellt mit Splyto';

  @override
  String tripReportEmailSubject(Object arg1) {
    return 'Dein Reisebericht: $arg1';
  }

  @override
  String get tripReportEmailTitle => 'Dein Reisebericht ist fertig';

  @override
  String tripReportEmailGreeting(Object arg1) {
    return 'Hallo $arg1,';
  }

  @override
  String tripReportEmailBody(Object arg1) {
    return '$arg1 ist beendet. Dein Bericht ist als PDF angehängt.';
  }

  @override
  String get tripReportEmailOptOut => 'Du kannst diese E-Mails im Profil unter Benachrichtigungen abschalten.';

  @override
  String get tripReportEmailSetting => 'Reisebericht per E-Mail';

  @override
  String get tripReportEmailSettingSubtitle => 'Erhalte eine PDF-Zusammenfassung, wenn eine Reise endet.';

  @override
  String get tripExportAction => 'Reisedetails exportieren';

  @override
  String get tripExportPdf => 'Ausführliches PDF';

  @override
  String get tripExportCsv => 'Tabelle (CSV)';

  @override
  String get tripExportFailed => 'Der Export konnte nicht erstellt werden. Versuche es erneut.';

  @override
  String get yearSummaryTitle => 'Dein Reisejahr';

  @override
  String get yearSummarySubtitle => 'Deine Reisen, Orte und Ausgaben des Jahres.';

  @override
  String yearSummaryEmpty(Object arg1) {
    return 'Keine abgeschlossenen Reisen in $arg1.';
  }

  @override
  String get yearSummaryLoadFailed => 'Dein Reisejahr konnte nicht geladen werden.';

  @override
  String get yearSummaryTrips => 'Reisen';

  @override
  String get yearSummaryDays => 'Tage unterwegs';

  @override
  String get yearSummaryCountries => 'Länder';

  @override
  String get yearSummaryCities => 'Städte';

  @override
  String get yearSummarySpending => 'Deine Ausgaben';

  @override
  String get yearSummaryBiggestTrip => 'Größte Reise';

  @override
  String get yearSummaryTopCategory => 'Top-Kategorie';

  @override
  String get yearSummaryTopCompanion => 'Die meisten Reisen mit';

  @override
  String yearSummaryTripsTogether(Object arg1) {
    return 'Gemeinsame Reisen: $arg1';
  }

  @override
  String get yearSummaryPartial => 'Einige Beträge fehlen, weil kein Wechselkurs verfügbar war.';

  @override
  String get yearSummaryShare => 'Teilen';

  @override
  String get yearSummaryShareFailed => 'Das Bild konnte nicht geteilt werden.';

  @override
  String get yearSummaryRetry => 'Erneut versuchen';

  @override
  String get notificationCommentAddedTitle => 'Neuer Kommentar zu deiner Ausgabe';

  @override
  String notificationCommentAddedBody(Object name, Object note) {
    return '$name hat „$note“ kommentiert.';
  }

  @override
  String notificationCommentAddedBodyGeneric(Object name) {
    return '$name hat deine Ausgabe kommentiert.';
  }

  @override
  String get profilePushCommentsTitle => 'Kommentare und Erwähnungen';

  @override
  String get profilePushCommentsSubtitle => 'Neue Kommentare zu deinen Ausgaben und Erwähnungen von dir';

  @override
  String get profilePushTripInvitesTitle => 'Reiseeinladungen und Mitglieder';

  @override
  String get profilePushTripInvitesSubtitle => 'Einladungen und Personen, die einer Reise beitreten oder sie verlassen';

  @override
  String get profilePushTripStatusTitle => 'Reisestatus';

  @override
  String get profilePushTripStatusSubtitle => 'Reise beendet und bereit zur Abrechnung';

  @override
  String get profilePushPaymentRequestsTitle => 'Zahlungsanfragen';

  @override
  String get profilePushPaymentRequestsSubtitle => 'An dich gesendete, abgelehnte oder stornierte Anfragen';

  @override
  String get profilePushPaymentsTitle => 'Zahlungen';

  @override
  String get profilePushPaymentsSubtitle => 'Zahlungen als gesendet, bestätigt oder nicht erhalten markiert';

  @override
  String get profilePushRemindersTitle => 'Erinnerungen';

  @override
  String get profilePushRemindersSubtitle => 'Erinnerungen an offene Zahlungen';
}
