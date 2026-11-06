// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get homeFirstTrip => 'Il tuo primo viaggio';

  @override
  String get homeYourShareAllTrips => 'La tua quota per tutti i viaggi';

  @override
  String get homeAllTime => 'Sempre';

  @override
  String get homeSolo => 'In solitaria';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '$count persona',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Azioni relative al viaggio: $name';
  }

  @override
  String get homeNoActiveTrips => 'Nessun viaggio attivo';

  @override
  String get homeNoArchivedTrips => 'Nessun viaggio archiviato';

  @override
  String get homeLoadingTrips => 'Caricamento dei tuoi viaggi';

  @override
  String get homeLoadErrorTitle => 'Impossibile caricare i tuoi viaggi';

  @override
  String get homeLoadErrorBody => 'Si prega di riprovare tra qualche istante.';

  @override
  String get homeOfflineTitle => 'Sei offline';

  @override
  String get homeOfflineNoData => 'I tuoi viaggi non sono ancora disponibili su questo dispositivo.';

  @override
  String get homeOfflineCached => 'Offline. Visualizzazione dei viaggi salvati.';

  @override
  String get homeRefreshError => 'Impossibile aggiornare. Vengono visualizzati i viaggi caricati in precedenza.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Condividi i miei dati di pagamento salvati con $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Solo mentre questa richiesta è in attesa di pagamento. L’annullamento della richiesta interrompe l’accesso.';

  @override
  String get paymentDetailsUnavailable => 'I dettagli di pagamento non sono disponibili. Connettiti a Internet e verifica che la richiesta sia ancora aperta.';

  @override
  String get paymentDetailsRetry => 'Riprova';

  @override
  String get tripModeSolo => 'Solo io';

  @override
  String get tripModeGroup => 'Con altri';

  @override
  String get premiumFree => 'Gratuito';

  @override
  String get premiumStatusUnavailable => 'Stato del piano non disponibile';

  @override
  String premiumGrantedUntil(String date) {
    return 'Abbonamento Premium concesso fino al $date';
  }

  @override
  String get premiumBillingNotActive => 'Nessun abbonamento attivo';

  @override
  String get premiumRefreshStatus => 'Aggiorna lo stato del piano';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get activeStatus => 'Attivo';

  @override
  String get activeTripPlural => 'viaggi attivi';

  @override
  String get activeTripSingle => 'viaggio attivo';

  @override
  String get activeTrips => 'Viaggi attivi';

  @override
  String get activitiesComingSoon => 'La sezione “Attività” sarà disponibile a breve.';

  @override
  String get addAction => 'Aggiungi';

  @override
  String get addExpenseTitle => 'Aggiungi una spesa';

  @override
  String get addExpensesAction => 'Aggiungi spese';

  @override
  String get addMembersAction => 'Aggiungi membri';

  @override
  String get addTripMembersTitle => 'Invita i partecipanti al viaggio';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inviti inviati',
      one: '$count invito inviato',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Invito al viaggio rifiutato.';

  @override
  String get tripInviteAction => 'Invita';

  @override
  String get tripInvitationsPending => 'In attesa di risposta';

  @override
  String get tripInvitationsRetry => 'Inviti non disponibili. Riprova';

  @override
  String get tripInvitationRevoke => 'Annulla invito';

  @override
  String get tripInvitationRevokeFailed => 'Impossibile annullare l’invito. Riprova.';

  @override
  String get tripInvitationBody => 'Sei stato invitato a un viaggio. Apri l’invito per rispondere.';

  @override
  String get allCaughtUp => 'È tutto aggiornato';

  @override
  String get allFilter => 'Tutto';

  @override
  String get allMembersLabel => 'Tutti i membri';

  @override
  String get allPaymentsConfirmed => 'Tutti i pagamenti vengono confermati.';

  @override
  String get allTrips => 'Tutti i viaggi';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Importo';

  @override
  String get amountMustBeGreaterThanZero => 'L’importo deve essere maggiore di 0.';

  @override
  String get appearance => 'Aspetto';

  @override
  String get archivedStatus => 'Archiviato';

  @override
  String get authSubtitleLogin => 'Dividi le spese di viaggio con gli amici';

  @override
  String get authSubtitleRegister => 'Crea un account e inizia a dividere le spese dei viaggi';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'confermato: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'in sospeso: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'inviato: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'suggerito: $count';
  }

  @override
  String get cancelAction => 'Annulla';

  @override
  String get changeEmailWithPasswordHelper => 'Inserisci la tua password per modificare l’indirizzo e-mail.';

  @override
  String get chooseReceiptFile => 'Scegli il file della ricevuta';

  @override
  String get completeAccountSetupDescription => 'Imposta la tua e-mail e la password per completare la creazione del tuo account.';

  @override
  String get completeAccountSetupTitle => 'Completa la configurazione dell’account';

  @override
  String get confirmReceivedAction => 'Conferma ricezione';

  @override
  String get confirmedAllSettlementsArchived => 'Tutti i pagamenti confermati. Viaggio archiviato.';

  @override
  String get confirmedAsReceived => 'Ricevuto e confermato.';

  @override
  String get confirmedLabel => 'Confermato';

  @override
  String get couldNotOpenReceiptLink => 'Impossibile aprire il link della ricevuta.';

  @override
  String get createAction => 'Crea';

  @override
  String get createFirstTripHint => 'Crea il tuo primo viaggio per iniziare.';

  @override
  String get createNewTripTitle => 'Crea un nuovo viaggio';

  @override
  String get createTripAction => 'Crea viaggio';

  @override
  String get createTripFirst => 'Crea prima un viaggio.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Creato da $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Il creatore del viaggio deve portare a termine il viaggio per avviare la conferma del saldo.';

  @override
  String currentEmailLabel(Object email) {
    return 'Indirizzo e-mail attuale: $email';
  }

  @override
  String get currentReceiptAttached => 'In allegato la ricevuta attuale.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Data';

  @override
  String get dateMustMatchFormat => 'La data deve essere nel formato YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Data sconosciuta';

  @override
  String get deleteAction => 'Elimina';

  @override
  String get deleteExpenseConfirmQuestion => 'Eliminare questa spesa?';

  @override
  String get deleteExpenseTitle => 'Elimina spesa';

  @override
  String get editExpenseConfirmTitle => 'Salvare le modifiche alle spese?';

  @override
  String get editExpenseConfirmText => 'Questo aggiornerà i saldi di tutti i partecipanti al viaggio.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Spiegazione diretta tramite le spese: $amount';
  }

  @override
  String get doneStatus => 'Fatto';

  @override
  String get editAction => 'Modifica';

  @override
  String get editExpenseTitle => 'Modifica spesa';

  @override
  String get emailAddressLabel => 'Indirizzo e-mail';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'L’indirizzo e-mail è obbligatorio.';

  @override
  String get enterValidExactAmounts => 'Inserire importi validi ed esatti per tutti i partecipanti.';

  @override
  String get enterValidPercentages => 'Inserire percentuali valide per tutti i partecipanti.';

  @override
  String get equalSplitLabel => 'Divisione in parti uguali';

  @override
  String exactAmountWithValue(Object value) {
    return 'Esatto: $value';
  }

  @override
  String get exactAmountsLabel => 'Importi esatti';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'La somma esatta delle quote deve essere pari a $amount.';
  }

  @override
  String get expenseAdded => 'Spesa aggiunta.';

  @override
  String get expenseBreakdownSubtitle => 'In che modo questo membro è interessato da ciascuna spesa.';

  @override
  String get expenseBreakdownTitle => 'Ripartizione delle spese';

  @override
  String get expenseDeleted => 'Spesa eliminata.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Spesa n. $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Pagato $paid  -  Debito $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reazioni';

  @override
  String get expenseCommentsTitle => 'Commenti';

  @override
  String get expenseNoComments => 'Nessun commento per ora.';

  @override
  String get expenseAddCommentHint => 'Aggiungi un commento...';

  @override
  String get expenseCommentSend => 'Invia';

  @override
  String get expenseMentionNoMatches => 'Nessun membro corrispondente';

  @override
  String get expenseMentionMembersLabel => 'Membri del viaggio da menzionare';

  @override
  String get expenseDeleteCommentTitle => 'Eliminare il commento?';

  @override
  String get expenseUpdated => 'Spesa aggiornata.';

  @override
  String expenseWithId(Object id) {
    return 'Spesa n. $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spese',
      one: '$count spesa',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Spese';

  @override
  String get failedToCreateTrip => 'Impossibile creare il viaggio.';

  @override
  String get failedToLoadUsersDirectory => 'Impossibile caricare la directory degli utenti.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtra i pagamenti in base ai membri';

  @override
  String get finishSoloTripConfirmationText => 'Vuoi concludere questo viaggio e spostarlo nel tuo archivio? Le tue spese rimarranno visibili.';

  @override
  String get soloTripArchived => 'Viaggio terminato e archiviato.';

  @override
  String get finishTripSyncPending => 'Sincronizza le modifiche in sospeso prima di concludere questo viaggio.';

  @override
  String get finishTripAction => 'Concludi il viaggio';

  @override
  String get finishTripConfirmationText => 'Concludere questo viaggio e avviare i conteggi?';

  @override
  String get finishTripStartSettlementsAction => 'Concludi e avvia i conteggi';

  @override
  String get finishTripTitle => 'Concludi il viaggio';

  @override
  String forParticipants(Object participants) {
    return 'Per: $participants';
  }

  @override
  String get forgotPassword => 'Hai dimenticato la password?';

  @override
  String get profileSetPassword => 'Imposta password';

  @override
  String get profileManagePassword => 'Imposta o modifica password';

  @override
  String get profilePasswordByEmail => 'Imposta la password tramite e-mail';

  @override
  String get passwordEmailBackToProfile => 'Torna al profilo';

  @override
  String get forgotPasswordSubtitle => 'Inserisci la tua e-mail e ti invieremo un link per reimpostare la password.';

  @override
  String get forgotPasswordSuccessMessage => 'Se esiste un account con questo indirizzo e-mail, abbiamo inviato un link per reimpostare la password.';

  @override
  String get passwordResetSentTitle => 'Controlla la posta in arrivo';

  @override
  String get passwordResetSentHint => 'Il link è valido per 1 ora. Se non vedi l’e-mail, controlla la cartella spam.';

  @override
  String get forgotPasswordTitle => 'Reimposta password';

  @override
  String get friendsProgressSubtitle => 'Ogni membro e il relativo stato di conferma.';

  @override
  String get friendsProgressTitle => 'Progressi degli amici';

  @override
  String get friendsSectionComingSoon => 'La sezione “Amici” sarà disponibile a breve.';

  @override
  String fromDirection(Object name) {
    return 'Da $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from a $to';
  }

  @override
  String get generateTurnAction => 'Estrai la prossima persona';

  @override
  String get hasAccountQuestion => 'Hai già un account?';

  @override
  String helloUser(Object name) {
    return 'Ciao, $name!';
  }

  @override
  String get iSentAction => 'Ho inviato';

  @override
  String get invalidEmailFormat => 'Formato e-mail non valido.';

  @override
  String get languageAction => 'Lingua';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageLatvian => 'Lettone';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageSystemSubtitle => 'Usa la lingua del dispositivo';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Lasciare vuoto per mantenere la password attuale.';

  @override
  String get logInButton => 'Accedi';

  @override
  String get logOutButton => 'Esci';

  @override
  String get logoutFromDeviceQuestion => 'Disconnettersi da questo dispositivo?';

  @override
  String get logoutRevocationUnconfirmed => 'Disconnessione da questo dispositivo. Impossibile confermare la revoca della sessione sul server.';

  @override
  String get markedAsSent => 'Contrassegnato come inviato.';

  @override
  String get markSettlementSentConfirmTitle => 'Contrassegnare il trasferimento come inviato?';

  @override
  String get markSettlementSentConfirmText => 'Utilizzare questa opzione solo dopo aver effettivamente inviato il pagamento. Al destinatario verrà chiesto di confermare.';

  @override
  String get settlementCancelSentAction => 'Contrassegna come non inviato';

  @override
  String get settlementCancelSentConfirmTitle => 'Annullare lo stato “inviato”?';

  @override
  String get settlementCancelSentConfirmText => 'In questo modo il trasferimento tornerà allo stato \"in sospeso\" e il destinatario ne verrà informato.';

  @override
  String get settlementSentCancelled => 'Il trasferimento è stato riportato allo stato “in sospeso”.';

  @override
  String get settlementNotReceivedAction => 'Non ho ricevuto questo messaggio';

  @override
  String get settlementNotReceivedConfirmTitle => 'Segnalare il pagamento non ricevuto?';

  @override
  String get settlementNotReceivedConfirmText => 'In questo modo il trasferimento tornerà allo stato \"in sospeso\" e il pagatore ne verrà informato.';

  @override
  String get settlementMarkedNotReceived => 'Contrassegnato come non ricevuto.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Hai ricevuto la conferma?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Conferma solo dopo che il denaro è visibile sul tuo conto. Questa azione potrebbe completare il regolamento.';

  @override
  String get memberSummariesSubtitle => 'Stato del saldo attuale per entrambe le parti.';

  @override
  String get memberSummariesTitle => 'Riepiloghi dei membri';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Per pagare $total  -  confermato $confirmed  -  in attesa $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Impatto stimato del pagamento per membro.';

  @override
  String get membersImpactTitle => 'Impatto dei membri';

  @override
  String get membersIncludedInExpense => 'Membri inclusi';

  @override
  String get membersLabel => 'Membri';

  @override
  String moreCount(Object count) {
    return '+ $count altri';
  }

  @override
  String get myFilter => 'Il mio';

  @override
  String get myImpactTitle => 'Il mio impatto';

  @override
  String get firstNameHint => 'Il tuo nome';

  @override
  String get firstNameLabel => 'Nome';

  @override
  String get firstNameLengthValidation => 'Il nome deve contenere da 2 a 64 caratteri.';

  @override
  String get fullNameHelper => 'Inserire nome e cognome in un unico campo.';

  @override
  String get fullNameHint => 'ad es. Anna Ozolina';

  @override
  String get fullNameLabel => 'Nome completo';

  @override
  String get fullNameValidation => 'Inserisci nome e cognome (almeno 2 caratteri ciascuno).';

  @override
  String get lastNameHint => 'Il tuo cognome';

  @override
  String get lastNameLabel => 'Cognome';

  @override
  String get lastNameLengthValidation => 'Il cognome deve contenere da 2 a 64 caratteri.';

  @override
  String get nameHint => 'Il tuo nome';

  @override
  String get nameLabel => 'Nome';

  @override
  String get nameLengthValidation => 'Il nome deve contenere almeno 2 caratteri.';

  @override
  String get navActivities => 'Statistiche';

  @override
  String get navAddTrip => 'Aggiungi viaggio';

  @override
  String get navBalances => 'Saldi';

  @override
  String get navExpenses => 'Spese';

  @override
  String get navFriends => 'Amici';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navRandom => 'Casuale';

  @override
  String get netLabel => 'Saldo netto';

  @override
  String get newPasswordLabel => 'Nuova password';

  @override
  String get nicknameHint => 'Come ti vedranno i tuoi amici';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameLengthValidation => 'Il nickname deve contenere almeno 2 caratteri.';

  @override
  String get noAccountQuestion => 'Non hai ancora un account?';

  @override
  String get noBalancesYet => 'Non ci sono ancora saldi.';

  @override
  String get noChangesToSave => 'Nessuna modifica da salvare.';

  @override
  String get noDirectExpenseLink => 'Non è stato trovato alcun collegamento diretto a una singola spesa. Questo saldo viene calcolato in base al saldo totale del viaggio.';

  @override
  String get noExpenseImpactForMember => 'Nessun impatto sulle spese per questo membro.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Nessuna spesa per $name, per ora.';
  }

  @override
  String get noExpensesYet => 'Non ci sono ancora spese.';

  @override
  String get noExtraUsersToAdd => 'Non è necessario aggiungere altri utenti.';

  @override
  String get noInternetDeleteQueued => 'Nessuna connessione a Internet. Elimina dalla coda.';

  @override
  String get noInternetExpenseQueued => 'Nessuna connessione a Internet. Spesa in coda.';

  @override
  String get noInternetUpdateQueued => 'Nessuna connessione a Internet. Aggiornamento in coda.';

  @override
  String get noMatchingRows => 'Nessuna riga corrispondente.';

  @override
  String get noMembersFound => 'Nessun membro trovato.';

  @override
  String get noNewMembersAdded => 'Queste persone sono già membri o hanno inviti in sospeso.';

  @override
  String get noNotePlaceholder => 'Nessuna nota';

  @override
  String get notificationsToday => 'Oggi';

  @override
  String get notificationsEmptyBody => 'Qui appariranno gli aggiornamenti relativi a viaggi, spese e amici.';

  @override
  String get notificationsCached => 'Offline — visualizzazione delle notifiche salvate.';

  @override
  String get notificationsRefreshFailed => 'Impossibile aggiornare. Vengono visualizzate le notifiche caricate in precedenza.';

  @override
  String get notificationsJustNow => 'Proprio ora';

  @override
  String notificationsMinutesAgo(int count) {
    return '$count min fa';
  }

  @override
  String notificationsHoursAgo(int count) {
    return '$count h fa';
  }

  @override
  String get notificationsUnread => 'Non letto';

  @override
  String get noNotificationsYet => 'Non ci sono ancora notifiche.';

  @override
  String get noParticipantData => 'Nessun dato sui partecipanti.';

  @override
  String get noParticipantsSelected => 'Nessun partecipante selezionato.';

  @override
  String get noPaymentRowsInTrip => 'Nessuna riga relativa ai pagamenti in questo viaggio.';

  @override
  String get noPaymentsNeeded => 'Non sono necessari pagamenti.';

  @override
  String get noPicksYet => 'Nessuna selezione per ora.';

  @override
  String get noSettlementActivityForMember => 'Nessuna attività di regolamento per questo membro.';

  @override
  String get noSettlementRowsYet => 'Non ci sono ancora righe relative ai pagamenti.';

  @override
  String get noSettlements => 'Nessun saldo dei conti';

  @override
  String get noTransferNeededForFilter => 'Non è necessario alcun trasferimento per il filtro selezionato.';

  @override
  String get noTransferRowsToShow => 'Nessuna riga di trasferimento da mostrare.';

  @override
  String get noTripDataLoaded => 'Nessun dato relativo al viaggio caricato.';

  @override
  String get noTripsYet => 'Nessun viaggio ancora.';

  @override
  String get noUsersFoundYet => 'Non sono stati trovati utenti.';

  @override
  String get notSetValue => 'Non impostato';

  @override
  String get notYetConfirmedTitle => 'Non ancora confermato';

  @override
  String get noteHint => 'Cena, taxi, biglietti...';

  @override
  String get noteLabel => 'Nota';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'La nota deve contenere al massimo $max caratteri.';
  }

  @override
  String get notificationFallbackTitle => 'Notifica';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get notificationFriendInviteTitle => 'Richiesta di amicizia';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name ti ha inviato un invito di amicizia.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Hai ricevuto un invito da un amico.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Invito accettato';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name ha accettato il tuo invito di amicizia.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Il tuo invito è stato accettato.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Invito rifiutato';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name ha rifiutato la tua richiesta di amicizia.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Il tuo invito ad un amico è stato rifiutato.';

  @override
  String get notificationTripAddedTitle => 'Aggiunto al viaggio';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name ti ha aggiunto al viaggio \"$trip\".';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Sei stato aggiunto al viaggio \"$trip\".';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Sei stato aggiunto a un viaggio.';

  @override
  String get notificationExpenseAddedTitle => 'Aggiunta una nuova spesa';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name ha aggiunto una spesa di $amount in \"$trip\".';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name ha aggiunto una spesa di $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'È stata aggiunta una nuova spesa.';

  @override
  String get notificationCommentMentionTitle => 'Sei stato menzionato in un commento';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name ti ha menzionato in un commento su \"$note\".';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name ti ha menzionato in un commento.';
  }

  @override
  String get notificationTripFinishedTitle => 'Viaggio terminato';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name ha completato \"$trip\". I pagamenti sono pronti.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name ha completato \"$trip\". Il viaggio è stato archiviato.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '«$trip» è stato completato.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Lo stato del viaggio è stato aggiornato.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Membro contrassegnato come pronto';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name è pronto per partecipare a \"$trip\".';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Un membro è pronto a partecipare a “$trip”.';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Un membro è pronto a saldare.';

  @override
  String get notificationTripReadyToSettleTitle => 'Tutti i membri sono pronti';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Tutti i membri sono contrassegnati come pronti in «$trip». È possibile avviare i conteggi.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Tutti i membri sono pronti. È possibile avviare i conteggi.';

  @override
  String get notificationSettlementReminderTitle => 'Promemoria di regolamento';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor ha ricordato a $target di contrassegnare $amount come inviato.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor ha ricordato a $target di confermare la ricezione di $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Hai ricevuto un promemoria di pagamento.';

  @override
  String get notificationPaymentReminderTitle => 'Promemoria di pagamento';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Promemoria: si prega di contrassegnare $amount come inviato a $target in \"$trip\".';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Promemoria: si prega di contrassegnare il pagamento come inviato.';

  @override
  String get notificationConfirmationReminderTitle => 'Promemoria di conferma';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Promemoria: si prega di confermare la ricezione di $amount da $payer in \"$trip\".';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Promemoria: si prega di confermare la ricezione del pagamento.';

  @override
  String get notificationSettlementSentTitle => 'Bonifico contrassegnato come inviato';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name ha contrassegnato $amount come inviato a te.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Un bonifico è stato contrassegnato come inviato.';

  @override
  String get notificationSettlementConfirmedTitle => 'Bonifico confermato';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name ha confermato di aver ricevuto $amount da te.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'È stato confermato un trasferimento.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifiche in sospeso',
      one: '$count modifica in sospeso',
    );
    return 'Coda offline: $_temp0';
  }

  @override
  String get syncAllSynced => 'Tutto sincronizzato';

  @override
  String syncChangesWaiting(Object count) {
    return '$count in attesa di sincronizzazione';
  }

  @override
  String get syncFailedTapToRetry => 'Sincronizzazione non riuscita, tocca per riprovare';

  @override
  String get offlineQueueStatus => 'Coda offline';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Solo il creatore del viaggio può concludere il viaggio.';

  @override
  String get openLabel => 'Apri';

  @override
  String get openReceiptAction => 'Apri scontrino';

  @override
  String get openSettlements => 'Apri i saldi dei conti';

  @override
  String get overviewTitle => 'Panoramica';

  @override
  String get owesLabel => 'Deve pagare';

  @override
  String get paidByLabel => 'Pagato da';

  @override
  String get paidLabel => 'A pagamento';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Pagato $paid  -  Debito $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Partecipanti (vuoto = tutti i membri)';

  @override
  String get participantsTitle => 'Partecipanti';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordComplexityHelper => 'Utilizza almeno 1 lettera maiuscola, 1 numero e 1 simbolo.';

  @override
  String get passwordComplexityValidation => 'La password deve includere 1 lettera maiuscola, 1 numero e 1 simbolo.';

  @override
  String get passwordMinLength => 'La password deve contenere almeno 8 caratteri.';

  @override
  String get passwordMinLengthShort => 'La password deve essere composta da almeno 6 caratteri.';

  @override
  String get passwordResetComingSoon => 'La funzione di reimpostazione della password sarà disponibile a breve.';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono.';

  @override
  String payerName(Object name) {
    return '$name (pagatore)';
  }

  @override
  String get pendingLabel => 'In sospeso';

  @override
  String get pendingPaymentsSubtitle => 'I pagamenti sono ancora in attesa di conferma definitiva.';

  @override
  String get percentLabel => 'Percentuale';

  @override
  String get percentSplitMustBe100 => 'La ripartizione percentuale deve sommare esattamente il 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Percentuali';

  @override
  String get pickAtLeastOneParticipant => 'Scegli almeno un partecipante.';

  @override
  String get pickMembersGenerateTurn => 'Scegli i partecipanti ed estrai la prossima persona.';

  @override
  String pickedCycleCompleted(Object name) {
    return 'Selezionato $name. Ciclo completato.';
  }

  @override
  String pickedUser(Object name) {
    return 'Selezionato $name.';
  }

  @override
  String get profileRefreshCachedData => 'Impossibile aggiornare il profilo. Vengono visualizzati i dati memorizzati nella cache.';

  @override
  String get profileTitle => 'Profilo';

  @override
  String get profileUpdated => 'Profilo aggiornato.';

  @override
  String get uploadAvatarAction => 'Carica l’avatar';

  @override
  String get takePhotoAction => 'Fai una foto';

  @override
  String get chooseFromLibraryAction => 'Scegli dalla Libreria';

  @override
  String get removeAvatarAction => 'Rimuovi l’avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar aggiornato.';

  @override
  String get avatarRemovedMessage => 'Avatar rimosso.';

  @override
  String get avatarFileTooLarge => 'Il file dell’avatar è troppo grande (max 5 MB).';

  @override
  String get avatarPickFailed => 'Impossibile caricare l’immagine dell’avatar.';

  @override
  String get queueAddExpense => 'Aggiungi una spesa';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'In coda: aggiungi spesa $amount';
  }

  @override
  String get queueDeleteExpense => 'Elimina spesa';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'In coda: elimina la spesa n. $id';
  }

  @override
  String get queuePendingStatus => 'In coda in sospeso';

  @override
  String get queueUpdateExpense => 'Aggiorna le spese';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'In coda: aggiorna la spesa n. $id';
  }

  @override
  String get queuedChange => 'Modifiche in coda';

  @override
  String queuedChangesTitle(Object count) {
    return 'Modifiche in coda ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'In coda ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Ciclo $cycleNo, prelievo $drawNo - $remaining rimanenti';
  }

  @override
  String get receiptFallbackName => 'scontrino';

  @override
  String get receiptLinkInvalid => 'Il link alla ricevuta non è valido.';

  @override
  String get receiptOptionalLabel => 'Scontrino (facoltativo)';

  @override
  String get recentPicksTitle => 'Ultime estrazioni';

  @override
  String get reloadProfile => 'Aggiorna il profilo';

  @override
  String get rememberMe => 'Ricordami';

  @override
  String get removeCurrentReceipt => 'Rimuovere la ricevuta attuale';

  @override
  String get repeatNewPasswordLabel => 'Ripeti la nuova password';

  @override
  String get repeatPasswordLabel => 'Ripeti la password';

  @override
  String get requestFailedTryAgain => 'Richiesta non riuscita. Riprovare.';

  @override
  String get retryAction => 'Riprova';

  @override
  String get rowsLabel => 'Righe';

  @override
  String get backToLoginAction => 'Torna alla pagina di accesso';

  @override
  String get saveAction => 'Salva';

  @override
  String get saveCredentialsButton => 'Salva le credenziali';

  @override
  String get saveProfileButton => 'Salva profilo';

  @override
  String get sendResetLinkButton => 'Invia link di reimpostazione';

  @override
  String get searchUsersHint => 'Cerca le persone per nome o e-mail';

  @override
  String get selectedPeopleLabel => 'Persone selezionate';

  @override
  String get noSearchMatches => 'Nessun utente corrispondente trovato.';

  @override
  String get savingButton => 'Salvataggio in corso...';

  @override
  String get selectAtLeastTwoMembers => 'Selezionare almeno due membri.';

  @override
  String get selectMembersHint => 'Seleziona i membri';

  @override
  String selectedFileLabel(Object name) {
    return 'Selezionato: $name';
  }

  @override
  String get selectedLabel => 'Selezionato';

  @override
  String get selectedUserFallback => 'Utente selezionato';

  @override
  String get settings => 'Impostazioni';

  @override
  String get settleUpAction => 'Saldare i conti';

  @override
  String get settledLabel => 'Saldato';

  @override
  String get settledStatus => 'Saldato';

  @override
  String get settlementActivitySubtitle => 'Trasferimenti collegati a questo membro.';

  @override
  String get settlementActivityTitle => 'Attività di regolamento';

  @override
  String get settlementCompletedTitle => 'Liquidazione completata';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total confermato';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Saldi dei conti: $count';
  }

  @override
  String get settlementImpactTitle => 'Impatto sulla liquidazione';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Impatto sulla transazione: $name';
  }

  @override
  String get settlementInProgress => 'Liquidazione in corso';

  @override
  String get settlementInProgressTitle => 'Liquidazione in corso';

  @override
  String get settlementLabel => 'Saldo dei conti';

  @override
  String get settlementOverviewArchivedSubtitle => 'Viaggio archiviato. Tutti i pagamenti completati.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Tieni traccia delle conferme di regolamento.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Visualizza in anteprima i trasferimenti previsti al termine del viaggio.';

  @override
  String get settlementPreview => 'Anteprima del regolamento';

  @override
  String get settlementPreviewTitle => 'Anteprima del regolamento';

  @override
  String get settlementProgressTripArchived => 'Viaggio archiviato';

  @override
  String settlementWithId(Object id) {
    return 'Liquidazione n. $id';
  }

  @override
  String get settlements => 'Saldi dei conti';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Liquidazioni già completate.';

  @override
  String get settlementsDone => 'Liquidazioni effettuate';

  @override
  String get settlingStatus => 'Regolamento';

  @override
  String get shareUnit => 'quota';

  @override
  String get sharesLabel => 'Quote';

  @override
  String get sharesMustBePositiveIntegers => 'Il numero di quote deve essere un intero positivo.';

  @override
  String sharesWithValue(Object value) {
    return 'Quote: $value';
  }

  @override
  String get showActiveTrips => 'Mostra i viaggi attivi';

  @override
  String get signUpButton => 'Registrati';

  @override
  String get splitBreakdownSubtitle => 'Come viene suddivisa la spesa';

  @override
  String get splitBreakdownTitle => 'Ripartizione delle spese';

  @override
  String get splitHintEqual => 'Dividere equamente tra i partecipanti selezionati.';

  @override
  String get splitHintExact => 'Inserisci l’importo esatto per ciascun partecipante. La somma deve corrispondere al totale.';

  @override
  String get splitHintPercent => 'Inserisci la percentuale per ciascun partecipante. La somma deve essere pari al 100%.';

  @override
  String get splitHintShares => 'Inserisci le quote di condivisione (1, 2, 3...). Il costo viene suddiviso proporzionalmente.';

  @override
  String get splitLabel => 'Spalato';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Divisione equa ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Importi esatti ($target)';
  }

  @override
  String get splitModeLabel => 'Modalità Split';

  @override
  String splitModePercent(Object target) {
    return 'Percentuali ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Quote ($target)';
  }

  @override
  String get statusConfirmed => 'Confermato';

  @override
  String get statusPending => 'In sospeso';

  @override
  String get statusSent => 'Inviato';

  @override
  String get statusSuggested => 'Suggerito';

  @override
  String statusWithValue(Object status) {
    return 'Stato: $status';
  }

  @override
  String get suggestedTransferDirections => 'Direzioni di pagamento suggerite';

  @override
  String get suggestedTransferFromExpense => 'Trasferimento suggerito dalla voce “Spese”';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trasferimenti suggeriti',
      one: '$count trasferimento suggerito',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Righe previste: pagatore -> destinatario.';

  @override
  String get suggestedTransfersTitle => 'Trasferimenti suggeriti';

  @override
  String get summarySettledUp => 'Saldato';

  @override
  String get summaryYouAreOwed => 'Ti devono';

  @override
  String get summaryYouOwe => 'Devi pagare';

  @override
  String get syncAction => 'Sincronizzazione';

  @override
  String get syncNowAction => 'Sincronizza ora';

  @override
  String get syncingStatus => 'Sincronizzazione';

  @override
  String get tapToViewDetails => 'Tocca per visualizzare i dettagli';

  @override
  String get themeModeDark => 'Scuro';

  @override
  String get themeModeDarkSubtitle => 'Tonalità scura tenue (non nero puro)';

  @override
  String get themeModeLight => 'Chiaro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeSystemSubtitle => 'Utilizzare l’aspetto del dispositivo';

  @override
  String toDirection(Object name) {
    return 'A $name';
  }

  @override
  String get totalLabel => 'Totale';

  @override
  String get travelerFallbackName => 'Viaggiatore';

  @override
  String get tripAlreadyClosed => 'Viaggio già concluso.';

  @override
  String get tripArchivedReadOnly => 'Il viaggio viene archiviato. Modalità di sola lettura.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Il viaggio è chiuso. La modifica delle spese è disabilitata.';

  @override
  String get tripClosedExpensesReadOnly => 'Il viaggio è chiuso. Le spese sono di sola lettura.';

  @override
  String get tripClosedRandomDisabled => 'Il viaggio è chiuso. L’estrazione casuale è disabilitata.';

  @override
  String tripCreated(Object name) {
    return 'Viaggio «$name» creato.';
  }

  @override
  String get tripFinished => 'Viaggio terminato.';

  @override
  String get tripFinishedCompleteSettlements => 'Il viaggio è terminato. Completa i pagamenti tra i partecipanti.';

  @override
  String get tripFinishedSettlementStarted => 'Viaggio terminato. Avviata la liquidazione.';

  @override
  String get tripFullySettledArchived => 'Viaggio completamente saldato e archiviato.';

  @override
  String get tripNameHint => 'Viaggio sciistico in Austria';

  @override
  String get tripNameLabel => 'Nome del viaggio';

  @override
  String get tripNameLengthValidation => 'Il nome del viaggio deve contenere almeno 2 caratteri.';

  @override
  String get tripSnapshotTitle => 'Panoramica del viaggio';

  @override
  String get tripTitleShort => 'Viaggio';

  @override
  String tripStatusWithValue(Object status) {
    return 'Stato del viaggio: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Viaggio n. $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Errore imprevisto durante il caricamento del profilo';

  @override
  String get unexpectedErrorLoadingTripData => 'Errore imprevisto durante il caricamento dei dati del viaggio';

  @override
  String get unexpectedErrorLoadingTrips => 'Errore imprevisto durante il caricamento dei viaggi';

  @override
  String get unexpectedErrorSavingChanges => 'Errore imprevisto durante il salvataggio delle modifiche';

  @override
  String get unexpectedErrorSavingCredentials => 'Errore imprevisto durante il salvataggio delle credenziali';

  @override
  String get unexpectedErrorUpdatingProfile => 'Errore imprevisto durante l’aggiornamento del profilo';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get unknownLabel => 'Sconosciuto';

  @override
  String get unreadLabel => 'Non letto';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aggiornamenti non letti',
      one: '$count aggiornamento non letto',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Manca l’argomento relativo al percorso del viaggio.';

  @override
  String userIdLabel(Object id) {
    return 'ID utente: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Pagato $paid  -  Debito $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Utente $id';
  }

  @override
  String get valueLabel => 'Valore';

  @override
  String get viewAllTrips => 'Visualizza tutti i viaggi';

  @override
  String get viewByPersonTitle => 'Visualizza per persona';

  @override
  String get whoOwesWhatSubtitle => 'Chi ha pagato e chi è debitore.';

  @override
  String get whoOwesWhatTitle => 'Chi deve cosa';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Chi deve cosa: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Righe di spesa relative a questo trasferimento.';

  @override
  String get whyPaymentExistsTitle => 'Perché esiste questo pagamento';

  @override
  String get youLabel => 'Tu';

  @override
  String get youSettledForExpense => 'Hai saldato la tua quota di questa spesa.';

  @override
  String youShouldPay(Object amount) {
    return 'Dovresti pagare. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Si dovrebbe ricevere $amount';
  }

  @override
  String get yourShare => 'La tua parte';

  @override
  String get yourTrips => 'I tuoi viaggi';

  @override
  String get authIntroSplitSmarter => 'Dividi in modo più intelligente.';

  @override
  String get authIntroTravelFree => 'Viaggia in libertà.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Tieni traccia delle spese condivise in diverse valute e regola i conti all’istante, senza imbarazzanti pagherò.';

  @override
  String get authIntroPlanTogether => 'Pianificate insieme.';

  @override
  String get authIntroPayClearly => 'Paga in modo chiaro.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Crea viaggi in pochi secondi, aggiungi amici e mantieni ogni spesa trasparente per tutti.';

  @override
  String get authIntroSettleFast => 'Concludete rapidamente.';

  @override
  String get authIntroStayFriends => 'Rimaniamo amici.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Dalle cene in compagnia ai viaggi completi, Splyto garantisce un saldo equo e senza stress.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Accesso Apple non riuscito. Riprova.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Accesso con Google non riuscito. Riprova.';

  @override
  String get authIntroCreateAccount => 'Crea il tuo account.';

  @override
  String get authIntroChooseSign => 'Scegli come vuoi registrarti.';

  @override
  String get authIntroContinueGoogle => 'Continua con Google';

  @override
  String get authIntroContinueApple => 'Continua con Apple';

  @override
  String get authIntroBack => 'Indietro';

  @override
  String get authIntroSplitSettled => 'Pagamento frazionato effettuato';

  @override
  String get authIntroParis3Friends => 'Parigi · 3 amici';

  @override
  String get authIntroGetStarted => 'Inizia';

  @override
  String get authIntroAlreadyHaveAccount => 'Hai già un account? ';

  @override
  String get authIntroSignIn => 'Accedi';

  @override
  String get authIntroSignUpWithEmail => 'Registrati con l’e-mail';

  @override
  String get authIntroOr => 'OPPURE';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'L\'accesso tramite Google non ha restituito un token ID.';

  @override
  String get authAppleSignAvailableIosDevices => 'L’accesso con Apple è disponibile sui dispositivi iOS.';

  @override
  String get authAppleSignNotAvailableDevice => 'L’accesso con Apple non è disponibile su questo dispositivo.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'L’accesso con Apple non ha restituito un token di identità.';

  @override
  String get authCancel => 'Annulla';

  @override
  String get authSendLink => 'Invia link';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'L’indirizzo e-mail non è verificato. Inserisci il tuo indirizzo e-mail per richiedere il link di verifica.';

  @override
  String get authEmailNotVerified => 'Indirizzo e-mail non verificato';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Inviare il link di verifica a $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Link di verifica inviato. Controlla la tua e-mail.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Impossibile inviare il link di verifica. Riprova.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'E-mail di verifica inviata. Verifica il tuo indirizzo e-mail prima di effettuare l’accesso.';

  @override
  String get authVerifyEmail => 'Verifica il tuo indirizzo e-mail';

  @override
  String get authEmailLabel => 'E-mail:';

  @override
  String get authClose => 'Chiudi';

  @override
  String get authResendLink => 'Invia nuovamente il link';

  @override
  String get profileAppSettingsSectionTitle => 'IMPOSTAZIONI DELL’APP';

  @override
  String get profileAccountSettings => 'Impostazioni dell’account';

  @override
  String get profileChangePhoto => 'Modifica la foto del profilo';

  @override
  String get profileAppearance => 'Aspetto';

  @override
  String get profileThemeDisplayMode => 'Tema e modalità di visualizzazione';

  @override
  String get profileLanguage => 'Lingua';

  @override
  String get profileDisplayLanguage => 'Lingua di visualizzazione';

  @override
  String get profileNotificationsSectionHeading => 'NOTIFICHE';

  @override
  String get profileAppBanners => 'Banner all’interno dell’app';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Mostra i nuovi banner di notifica all’interno dell’app';

  @override
  String get profilePushNotificationsTitle => 'Notifiche push';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Notifiche sul telefono relative a spese, amici, viaggi e liquidazioni';

  @override
  String get profileSupportSectionHeading => 'ASSISTENZA';

  @override
  String get profileContactUs => 'Contattaci';

  @override
  String get profileReportBugSuggestion => 'Segnala un bug / Suggerimento';

  @override
  String get profileRateSplyto => 'Valuta Splyto';

  @override
  String get profileLeaveStoreRating => 'Lascia una valutazione del negozio';

  @override
  String get profileSecuritySectionHeading => 'SICUREZZA';

  @override
  String get profileAccountAndSecurity => 'Account e sicurezza';

  @override
  String get profileHelpTitle => 'Aiuto';

  @override
  String get profileChangePassword => 'Cambia password';

  @override
  String get profileUpdateAccountPassword => 'Aggiorna la password dell’account';

  @override
  String get profileDangerZoneSectionHeading => 'ZONA DI PERICOLO';

  @override
  String get profileManageAccountAccess => 'Gestire l’accesso all’account';

  @override
  String get profileMadeWithLabel => 'Realizzato con';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'L’azione di valutazione del negozio verrà collegata nella fase successiva.';

  @override
  String get profileFailedSaveNotificationSettings => 'Impossibile salvare le impostazioni delle notifiche.';

  @override
  String get profilePushNotificationsSectionTitle => 'NOTIFICHE PUSH';

  @override
  String get profileInAppBannersSectionTitle => 'BANNER NELL’APP';

  @override
  String get profileInAppTripMemberAddedTitle => 'Membro aggiunto al viaggio';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Promemoria automatico di regolamento';

  @override
  String get profileExpenseUpdates => 'Aggiornamenti sulle spese';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Banner relativi alle spese aggiunti all’interno dell’app';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Notifiche relative alle spese aggiunte sul telefono';

  @override
  String get profileFriendInvites => 'Inviti da parte di amici';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Banner relativi alle richieste di amicizia e alle risposte all’interno dell’app';

  @override
  String get profileFriendRequestResponseNotifications => 'Notifiche relative alle richieste di amicizia e alle risposte';

  @override
  String get profileTripUpdates => 'Aggiornamenti sul viaggio';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Banner relativi al ciclo di vita del viaggio e allo stato dei membri all’interno dell’app';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Ciclo di vita del viaggio e modifiche allo stato dei membri';

  @override
  String get profileSettlementUpdates => 'Aggiornamenti sui pagamenti';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Banner contrassegnati come “inviati” e “pagamento confermato” all’interno dell’app';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Aggiornamenti sui pagamenti contrassegnati come inviati e confermati';

  @override
  String get profileScreenshotSizeMust8Mb => 'La dimensione dello screenshot non deve superare gli 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Invia feedback';

  @override
  String get profileFeedbackTypeLabel => 'Tipo';

  @override
  String get profileFeedbackTypeBug => 'Bug';

  @override
  String get profileFeedbackTypeSuggestion => 'Suggerimento';

  @override
  String get profileDescribeIssueSuggestion => 'Descrivi il problema o il suggerimento';

  @override
  String get profilePickingImage => 'Scelta immagine...';

  @override
  String get profileAttachScreenshot => 'Allega uno screenshot';

  @override
  String get profileChangeScreenshot => 'Modifica screenshot';

  @override
  String get profileRemoveImage => 'Rimuovi immagine';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Suggerimento: allegare uno screenshot per una più rapida classificazione dei bug';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Aggiungere dettagli o allegare uno screenshot prima dell’invio';

  @override
  String get profileSendAction => 'Invia';

  @override
  String get profileThanksFeedbackSent => 'Grazie! Feedback inviato';

  @override
  String get profileFailedSendFeedback => 'Impossibile inviare il feedback';

  @override
  String get profileCouldNotOpenWebsite => 'Impossibile aprire il sito web.';

  @override
  String get profileOpenWebsiteQuestion => 'Aprire il sito web?';

  @override
  String get profileOpenPortfolioAction => 'Apri portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Questo formato immagine non è supportato su questo dispositivo. Scegli JPG o PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Per modificare la password è necessario un indirizzo e-mail valido associato all’account. Contatta l’assistenza se il tuo indirizzo e-mail manca o è errato.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Il link per la cancellazione è stato inviato alla tua e-mail.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Impossibile inviare il link di cancellazione. Riprovare.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Inserisci la password attuale per modificare l’indirizzo e-mail.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'È stata inviata una verifica al nuovo indirizzo e-mail. È stata inviata una notifica di sicurezza al tuo indirizzo e-mail attuale.';

  @override
  String get profileEditOverviewCurrency => 'Panoramica sulla valuta';

  @override
  String get profileEditPaymentMethod => 'Metodo di pagamento';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Bonifico bancario, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Inserisci la tua password (facoltativo per Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Invia il link di cancellazione via e-mail';

  @override
  String get profileEditBackProfile => 'Torna al profilo';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Imposta un indirizzo e-mail valido nel profilo prima di modificare la password.';

  @override
  String get profileEditPasswordUpdated => 'Password aggiornata.';

  @override
  String get profileEditFailedUpdatePassword => 'Impossibile aggiornare la password.';

  @override
  String profileEditEmail(Object email) {
    return 'Account: $email';
  }

  @override
  String get profileEditPrimary => 'Primario';

  @override
  String get profileEditSearchCurrency => 'Cerca valuta';

  @override
  String get profileEditNoCurrenciesFound => 'Nessuna valuta trovata';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'I totali della panoramica vengono convertiti in questa valuta.';

  @override
  String get profileEditPaymentInfoUpdated => 'Informazioni di pagamento aggiornate.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Impossibile salvare le informazioni di pagamento. Riprova.';

  @override
  String get profileEditCurrentPassword => 'Password attuale';

  @override
  String get profileEditBankTransferIbanSwift => 'Bonifico bancario (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'link paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Scegli il metodo di pagamento';

  @override
  String get profileEditTapChange => 'Tocca per modificare';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Per i bonifici nel Regno Unito, il codice di identificazione della banca deve essere di 6 cifre e il numero di conto di 8 cifre.';

  @override
  String get profileEditPaymentInfo => 'Informazioni sui pagamenti';

  @override
  String get profileEditSaveDetails => 'Salva i dettagli';

  @override
  String get profileEditBankRegion => 'Area bancaria';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'Codice di identificazione della banca';

  @override
  String get profileEditExample112233 => 'Esempio: 112233';

  @override
  String get profileEditNumber => 'Numero di conto';

  @override
  String get profileEdit8Digits => '8 cifre';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Per i bonifici nazionali nel Regno Unito, utilizzare il codice di ordinamento + il numero di conto.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Esempio: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 o 11 caratteri';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Il nome del titolare del conto viene ricavato dal nome completo presente nel profilo.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username o nome utente';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Regno Unito';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Modifica l’avatar';

  @override
  String get imageCropperAdjustTripImage => 'Modifica l’immagine del viaggio';

  @override
  String get imageCropEditAction => 'Modifica ritaglio';

  @override
  String get imageCropZoomIn => 'Ingrandisci';

  @override
  String get imageCropZoomOut => 'Riduci';

  @override
  String get imageCropZoomOnly => 'È stata salvata solo la versione ritagliata di questa foto, quindi puoi solo ingrandirla.';

  @override
  String get imageCropLoadFailed => 'Impossibile aprire questa foto.';

  @override
  String get imageCropSaveFailed => 'Impossibile salvare il nuovo ritaglio. Riprova.';

  @override
  String get imageCropChanged => 'Questa foto è stata modificata nel frattempo. Chiudi questa schermata e riaprila.';

  @override
  String get copyAction => 'Copia';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Sterlina britannica';

  @override
  String get currencyNameChf => 'Franco svizzero';

  @override
  String get currencyNameNok => 'Corona norvegese';

  @override
  String get currencyNameSek => 'Corona svedese';

  @override
  String get currencyNameDkk => 'Corona danese';

  @override
  String get currencyNamePln => 'Zloty polacco';

  @override
  String get currencyNameCzk => 'Corona ceca';

  @override
  String get currencyNameHuf => 'Forint ungherese';

  @override
  String get currencyNameRon => 'Leu rumeno';

  @override
  String get currencyNameBgn => 'Lev bulgaro';

  @override
  String get currencyNameIsk => 'Corona islandese';

  @override
  String get currencyNameAll => 'Lek albanese';

  @override
  String get currencyNameBam => 'Bosnia-Erzegovina Mark';

  @override
  String get currencyNameByn => 'Rublo bielorusso';

  @override
  String get currencyNameMdl => 'Leu moldavo';

  @override
  String get currencyNameMkd => 'Denar macedone';

  @override
  String get currencyNameRsd => 'Dinar serbo';

  @override
  String get currencyNameUah => 'Grivna ucraina';

  @override
  String get currencyNameGel => 'Lari georgiano';

  @override
  String get currencyNameTry => 'Lira turca';

  @override
  String get currencyNameUsd => 'Dollaro statunitense';

  @override
  String get currencyNameJpy => 'Yen giapponese';

  @override
  String get currencyNameCny => 'Yuan cinese';

  @override
  String get currencyNameCad => 'Dollaro canadese';

  @override
  String get currencyNameAud => 'Dollaro australiano';

  @override
  String get expenseCategoryFood => 'Ristorazione';

  @override
  String get expenseCategoryGroceries => 'Spesa alimentare';

  @override
  String get expenseCategoryFuel => 'Carburante';

  @override
  String get expenseCategoryTransport => 'Trasporti';

  @override
  String get expenseCategoryAccommodation => 'Alloggio';

  @override
  String get expenseCategoryActivities => 'Attività';

  @override
  String get expenseCategoryTickets => 'Biglietti';

  @override
  String get expenseCategoryShopping => 'Shopping';

  @override
  String get expenseCategoryParty => 'Festa';

  @override
  String get expenseCategoryParking => 'Parcheggio';

  @override
  String get expenseCategoryOther => 'Altro';

  @override
  String get shellTripAlreadyInListOpened => 'Il viaggio è già nella tua lista. L’abbiamo aperto per te.';

  @override
  String get shellJoinedTripFromInviteLink => 'Ha aderito al viaggio tramite il link di invito.';

  @override
  String get shellFailedToOpenInviteLink => 'Impossibile aprire il link di invito.';

  @override
  String get shellFailedToOpenFriendLink => 'Impossibile aprire il link dell’amico.';

  @override
  String get shellTripInviteTitle => 'Invito al viaggio';

  @override
  String get shellNoAction => 'No';

  @override
  String get shellYesAction => 'Sì';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Solo il creatore del viaggio può eliminare questo viaggio.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'È possibile eliminare solo i viaggi attivi.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Eliminare «$tripLabel»? Ciò è consentito solo prima che vengano aggiunte spese.';
  }

  @override
  String get shellTripDeleted => 'Viaggio eliminato.';

  @override
  String get shellFailedToDeleteTrip => 'Impossibile eliminare il viaggio.';

  @override
  String get shellFailedToLoadNotifications => 'Impossibile caricare le notifiche.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nuova notifica: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Impossibile aggiornare le notifiche.';

  @override
  String get shellMarkAllAsReadAction => 'Contrassegna tutto come letto';

  @override
  String get shellNewSection => 'Novità';

  @override
  String get shellEarlierSection => 'Precedente';

  @override
  String get shellShowMoreEarlierAction => 'Mostra di più in precedenza';

  @override
  String get shellLoadingMore => 'Caricamento in corso...';

  @override
  String get shellLoadMoreNotificationsAction => 'Carica altre notifiche';

  @override
  String get shellTripNoLongerAvailable => 'Questo viaggio non è più disponibile.';

  @override
  String get shellFailedToOpenTrip => 'Impossibile aprire il viaggio.';

  @override
  String get shellYesterday => 'Ieri';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Sei già membro di \"$tripName\". Vuoi aprire questo viaggio adesso?\n\nInvitato da: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Vuoi partecipare al viaggio \"$tripName\"?\n\nInvitato da: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Immagine selezionata: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Immagine del viaggio già impostata.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Viaggio creato, ma caricamento dell’immagine non riuscito.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Viaggio creato, ma caricamento dell’immagine non riuscito: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Partecipa al viaggio tramite invito';

  @override
  String get tripsTotalTrips => 'Totale viaggi';

  @override
  String get tripsTotalSpent => 'Totale speso';

  @override
  String get tripsMixedCurrencies => 'Valute miste';

  @override
  String get tripsShowActive => 'Mostra attivo';

  @override
  String get tripsSeeAll => 'Vedi tutto';

  @override
  String get tripsGridView => 'Visualizzazione a griglia';

  @override
  String get tripsListView => 'Visualizzazione a elenco';

  @override
  String get tripsAddNewTrip => 'Aggiungi un nuovo viaggio';

  @override
  String get tripsLoadMore => 'Carica altro';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Eliminare «$arg1»? Ciò è consentito solo prima che vengano aggiunte spese.';
  }

  @override
  String get tripsTripDates => 'Date del viaggio';

  @override
  String get tripsFrom => 'Da';

  @override
  String get tripsSelectDate => 'Seleziona la data';

  @override
  String get tripsTo => 'A';

  @override
  String get tripsMainCurrency => 'Valuta principale';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Seleziona il periodo del viaggio (date di inizio e fine).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'La data di fine del viaggio deve essere pari o successiva alla data di inizio.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Il formato del periodo del viaggio non è valido. Seleziona nuovamente le date.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Sei già membro di questo viaggio.';

  @override
  String get tripsJoinedTripSuccessfully => 'Ti sei unito al viaggio con successo.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Impossibile partecipare al viaggio dall’invito.';

  @override
  String get tripsJoinTrip => 'Partecipa al viaggio';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Inserisci il link di invito o il token di invito.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Inserisci un link di invito o un token valido.';

  @override
  String get tripsClipboardIsEmpty => 'Gli appunti sono vuoti.';

  @override
  String get tripsPaste => 'Incolla';

  @override
  String get tripsJoin => 'Iscriviti';

  @override
  String get workspaceTripMembers => 'Partecipanti al viaggio';

  @override
  String get workspaceFailedToLoadFriends => 'Impossibile caricare gli amici.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Impossibile generare il link di invito.';

  @override
  String get workspaceInviteLink => 'Link di invito';

  @override
  String get workspaceGeneratingInviteLink => 'Generazione del link di invito...';

  @override
  String get workspaceInviteLinkUnavailable => 'Link di invito non disponibile.';

  @override
  String get workspaceCopyInviteLink => 'Copia il link di invito';

  @override
  String get workspaceInviteLinkCopied => 'Link di invito copiato.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Scadenza: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Nessun amico disponibile. Aggiungi prima degli amici.';

  @override
  String get workspaceSettle => 'Concludi';

  @override
  String get workspaceOwesToTheGroup => 'Debito nei confronti del gruppo';

  @override
  String get workspaceGetsBackFromGroup => 'Deve ricevere denaro dal gruppo';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Visualizzazione dei primi 4 in base alla differenza di saldo.';

  @override
  String get workspaceOpenFlow => 'Dettagli';

  @override
  String get workspaceFriend => 'Amico';

  @override
  String get workspaceSettlementTransfer => 'Trasferimento di regolamento';

  @override
  String get workspaceCompleted => 'Completato';

  @override
  String get workspaceWaitingForConfirmation => 'In attesa di conferma';

  @override
  String get workspaceWaitingForPayment => 'In attesa di pagamento';

  @override
  String get workspaceActionNeeded => 'Azione richiesta';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Pagamenti da contrassegnare come inviati: $arg1; da confermare come ricevuti: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Pronti per il saldo';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Tutti i membri sono pronti. È possibile avviare i conteggi.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'In attesa che tutti si dichiarino pronti.';

  @override
  String get workspaceIMReady => 'Sono pronto';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Verifica di aver aggiunto tutte le tue spese.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Il pulsante “Fine” si sblocca una volta che tutti si sono dichiarati pronti.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Deve ricevere denaro dal gruppo';

  @override
  String get workspaceSettledWithTheGroup => 'Concordato con il gruppo';

  @override
  String get workspaceTotalPaid => 'Totale pagato';

  @override
  String get workspaceTotalOwes => 'Totale dovuto';

  @override
  String get workspaceTransactionHistory => 'Cronologia delle transazioni';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Non ci sono ancora transazioni per questo membro.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Liquidazioni: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Tutti i membri devono contrassegnarsi come pronti prima di avviare i conteggi.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Ti sei contrassegnato come pronto per il pagamento.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Il contrassegno «Pronto per il saldo» è stato rimosso.';

  @override
  String get workspaceReminderSent => 'Promemoria inviato.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Link di invito o aggiungi dagli amici';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Solo il creatore del viaggio può modificare questo viaggio.';

  @override
  String get workspaceTripUpdated => 'Viaggio aggiornato.';

  @override
  String get workspaceFailedToUpdateTrip => 'Impossibile aggiornare il viaggio.';

  @override
  String get workspaceNoMembersSelectedYet => 'Non sono stati ancora selezionati membri.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Nessuna connessione a Internet. La spesa verrà salvata senza l’immagine della ricevuta.';

  @override
  String get workspaceRandomPicker => 'Selezione casuale';

  @override
  String get workspaceCurrency => 'Valuta';

  @override
  String get workspaceCategory => 'Categoria';

  @override
  String get workspaceCustomCategory => 'Categoria personalizzata';

  @override
  String get workspaceCategoryName => 'Nome della categoria';

  @override
  String get workspaceApartmentRentParkingEtc => 'Affitto dell’appartamento, parcheggio, ecc.';

  @override
  String get workspaceEnterACustomCategory => 'Inserisci una categoria personalizzata.';

  @override
  String get workspacePickAnExpenseCategory => 'Scegli una categoria di spesa.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'La categoria deve contenere almeno 2 caratteri.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'La categoria deve contenere al massimo 64 caratteri.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'La ripartizione percentuale deve ammontare complessivamente al 100%.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Il numero di quote deve essere maggiore di 0 per ogni partecipante.';

  @override
  String get workspaceTotalAmount => 'Importo totale';

  @override
  String get workspaceOriginal => 'Originale';

  @override
  String get workspaceTotalCost => 'Costo totale';

  @override
  String workspaceStarted(Object arg1) {
    return 'Avviato $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Terminato $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Viaggio archiviato';

  @override
  String get workspaceActiveTrip => 'Viaggio attivo';

  @override
  String get workspaceMemberProfile => 'Profilo del membro';

  @override
  String get workspaceTripOwner => 'Organizzatore del viaggio';

  @override
  String get workspaceMember => 'Membro';

  @override
  String get workspaceReadyForSettlement => 'Pronti per il regolamento';

  @override
  String get workspaceNotReadyForSettlement => 'Non pronto per il regolamento';

  @override
  String get workspaceBankDetails => 'Dati bancari';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'L’IBAN e i dettagli relativi ai pagamenti saranno aggiunti qui in un prossimo aggiornamento.';

  @override
  String get workspacePaymentDetails => 'Dettagli di pagamento';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Questo membro non ha ancora aggiunto i dettagli per il pagamento.';

  @override
  String get workspaceBankTransfer => 'Bonifico bancario';

  @override
  String get workspaceHolder => 'Titolare';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Impossibile aprire il link di pagamento.';

  @override
  String get workspaceTripActivity => 'Attività del viaggio';

  @override
  String get workspacePaidExpenses => 'Spese pagate';

  @override
  String get workspacePaidTotal => 'Totale pagato';

  @override
  String get workspaceInvolvedIn => 'Coinvolti in';

  @override
  String get workspaceCurrentTrip => 'Viaggio in corso';

  @override
  String get workspaceCommonTrips => 'Viaggi in comune';

  @override
  String get workspaceLoadingCommonTrips => 'Caricamento dei viaggi in comune…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Nessun viaggio in comune per ora.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Impossibile caricare tutti i viaggi in comune. Viene mostrato il viaggio attuale.';

  @override
  String get workspaceMembers => 'membri';

  @override
  String get workspaceExpense => 'Spese';

  @override
  String get workspacePaid => 'a pagamento';

  @override
  String get workspaceLoadingMoreExpenses => 'Caricamento di altre spese in corso...';

  @override
  String get workspaceScrollDownToLoadMore => 'Scorri verso il basso per caricare altri contenuti';

  @override
  String get workspaceTripFinished => 'Viaggio terminato';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'I pagamenti sono sbloccati per questo viaggio.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Completa il viaggio per avviare i conteggi.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 ha contrassegnato il trasferimento come inviato.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'In attesa che $arg1 contrassegni come pagato.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 ha confermato la ricezione del pagamento.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'In attesa della conferma da parte di $arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Tutti i conteggi relativi al viaggio sono stati completati integralmente.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Stato finale dopo la conferma di tutti i trasferimenti.';

  @override
  String get workspaceSettlementFlow => 'Flusso di regolamento';

  @override
  String get workspaceActions => 'Azioni';

  @override
  String get workspaceQuickPay => 'Pagamento rapido';

  @override
  String get workspacePayWithRevolut => 'Paga con Revolut';

  @override
  String get workspacePayWithPaypal => 'Paga con PayPal';

  @override
  String get workspacePayWithWise => 'Paga con Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Il trasferimento è confermato.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'In attesa che l’altro membro completi il passaggio successivo.';

  @override
  String get workspaceSendReminder => 'Invia promemoria';

  @override
  String get workspaceInProgress => 'In corso';

  @override
  String get workspaceTimeUnknown => 'Ora sconosciuta';

  @override
  String get workspaceRemind => 'Ricorda';

  @override
  String get workspaceYourPosition => 'La tua posizione';

  @override
  String get workspaceRecentActivity => 'Attività recenti';

  @override
  String get workspaceNoRecentActivityYet => 'Nessuna attività recente al momento.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Aggiungi almeno un partecipante per iniziare a dividere le spese.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Contrassegnati come pronto per il saldo dopo aver aggiunto tutte le tue spese.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Partecipanti non ancora pronti: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Tutti i partecipanti sono pronti. È possibile concludere il viaggio e avviare i conteggi.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Tutti i partecipanti sono pronti. Si attende che l’organizzatore del viaggio avvii i conteggi.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Liquidazione in corso: $arg1 / $arg2 confermati.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Nessuna azione in sospeso. Questo viaggio è stato completato.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Al momento non è richiesta alcuna azione.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Dovresti ricevere $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Dovresti pagare $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Al momento sei iscritto a questo viaggio.';

  @override
  String get workspaceUnknownTime => 'Ora sconosciuta';

  @override
  String get workspaceJustNow => 'Proprio ora';

  @override
  String workspaceMinAgo(Object arg1) {
    return '$arg1 min fa';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return '$arg1 h fa';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return '$arg1 g fa';
  }

  @override
  String get friendsRemoveFriend => 'Rimuovi amico';

  @override
  String get friendsRemoveThisFriend => 'Rimuovere questo amico?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 verrà rimosso dalla tua lista di amici. Potrai aggiungerlo nuovamente in un secondo momento.';
  }

  @override
  String get friendsContinue => 'Continua';

  @override
  String get friendsFriendRemoved => 'Amico rimosso.';

  @override
  String get friendsCouldNotRemoveFriend => 'Impossibile rimuovere un amico.';

  @override
  String get friendsFriendProfile => 'Profilo dell’amico';

  @override
  String get friendsMoreActions => 'Altre azioni';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Questo amico non ha ancora aggiunto i dettagli per il pagamento.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Impossibile caricare i viaggi in comune al momento.';

  @override
  String get friendsFinished => 'Fine';

  @override
  String friendsTrip(Object arg1) {
    return 'Viaggio n. $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Membri: $arg1';
  }

  @override
  String get friendsNoDate => 'Nessuna data';

  @override
  String get friendsIncomingRequests => 'RICHIESTE IN ARRIVO';

  @override
  String get friendsSentInvites => 'INVITI INVIATI';

  @override
  String get friendsMyFriends => 'I MIEI AMICI';

  @override
  String get friendsRequests => 'Richieste';

  @override
  String get friendsIncoming => 'In arrivo';

  @override
  String get friendsIncomingRequestSubtitle => 'vuole diventare amico';

  @override
  String get friendsOutgoingInviteSubtitle => 'Invito inviato';

  @override
  String get friendsNoPendingActivity => 'Nessuna richiesta di amicizia';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Invito inviato a $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Nessuna richiesta in arrivo';

  @override
  String get friendsDecline => 'Rifiuta';

  @override
  String get friendsAccept => 'Accetta';

  @override
  String get friendsNoSentInvites => 'Nessun invito inviato';

  @override
  String get friendsNoFriendsYet => 'Non hai ancora amici';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Scorri verso il basso per caricare altri amici.';

  @override
  String get friendsUser => 'Utente';

  @override
  String get friendsSearchUsers => 'Cerca utenti';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Cerca per nome o e-mail e invia l’invito';

  @override
  String get friendsScanQr => 'Scansiona il codice QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Scansiona un altro utente per aggiungerlo come amico';

  @override
  String get friendsMyQr => 'Il mio QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Mostra o condividi il tuo codice QR';

  @override
  String get friendsScanFriendQrTitle => 'Scansiona il QR code di un amico';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Inserisci il codice QR dell’amico all’interno della cornice';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Tenere il codice QR all’interno dell’inquadratura';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Aggiungere $arg1 come amico?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 riceverà la tua richiesta di amicizia.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Accettare la richiesta di amicizia di $arg1?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Scansiona questo QR o condividi il link per aggiungermi su Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Aggiungimi su Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Link amico Splyto';

  @override
  String get shareAction => 'Condividi';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'Il codice QR non è un codice amico valido.';

  @override
  String get friendsYouCannotAddYourself => 'Non è possibile aggiungersi autonomamente.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Questo utente è già presente nella tua lista degli amici.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'L’invito a questo utente è già stato inviato.';

  @override
  String get friendsFriendRequestProcessed => 'Richiesta di amicizia elaborata.';

  @override
  String get friendsFailedToProcessFriendQr => 'Impossibile elaborare il QR dell’amico.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Impossibile caricare il tuo profilo utente.';

  @override
  String get friendsMyProfile => 'Il mio profilo';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Errore imprevisto durante il caricamento degli amici.';

  @override
  String get friendsFriendAdded => 'Amico aggiunto.';

  @override
  String get friendsRequestDeclined => 'Richiesta respinta.';

  @override
  String get friendsFailedToUpdateRequest => 'Impossibile aggiornare la richiesta.';

  @override
  String get friendsCancelInvite => 'Annulla invito';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Annullare l’invito a $arg1?';
  }

  @override
  String get friendsKeep => 'Mantieni';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Invito a $arg1 annullato.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Impossibile annullare l’invito.';

  @override
  String get analyticsOther => 'Altro';

  @override
  String get analyticsSelectATripForAnalytics => 'Seleziona un viaggio per l’analisi';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Membri: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Spese giornaliere';

  @override
  String get analyticsMyDaily => 'Le mie spese giornaliere';

  @override
  String get analyticsGroupDaily => 'Spese giornaliere del gruppo';

  @override
  String get analyticsByMember => 'Per partecipante';

  @override
  String get analyticsShowLess => 'Mostra meno';

  @override
  String get analyticsByCategory => 'Per categoria';

  @override
  String get analyticsQuickInsights => 'Approfondimenti rapidi';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Spesa maggiore: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Chi ha speso di più: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Giorno con il maggior numero di partecipanti: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Nessuna data';

  @override
  String get friendsSearchFailedTryAgain => 'Ricerca non riuscita. Riprova.';

  @override
  String get friendsFailedToSendInvite => 'Impossibile inviare l’invito.';

  @override
  String get friendsAddFriend => 'Aggiungi amico';

  @override
  String get friendsSearchByNameOrEmail => 'Cerca per nome o e-mail';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Digita almeno 2 caratteri per effettuare la ricerca.';

  @override
  String get friendsNoUsersFound => 'Nessun utente trovato';

  @override
  String get friendsInviteAction => 'Invita';

  @override
  String get workspacePaidForGroup => 'Pagato per il gruppo';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Pagato per il gruppo • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Ripartizione delle spese';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Ripartizione delle spese • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Nome del titolare copiato.';

  @override
  String get paymentIbanCopied => 'IBAN copiato.';

  @override
  String get paymentSwiftCopied => 'SWIFT copiato.';

  @override
  String get paymentRevtagCopied => 'Revtag copiato.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Impossibile copiare negli appunti.';

  @override
  String get paymentCopied => 'Copiato.';

  @override
  String get paymentRequestAction => 'Richiedi il pagamento';

  @override
  String get paymentRecordAction => 'Registrazione del pagamento';

  @override
  String get paymentRequestSheetTitle => 'Richiedi il pagamento';

  @override
  String get paymentRecordSheetTitle => 'Registrazione del pagamento';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Chiedi a $arg1 di pagare l’importo che ti deve attualmente.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Utilizza questa funzione dopo aver pagato $arg1 al di fuori di Splyto. L’utente confermerà di aver ricevuto il pagamento.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Massimo $arg1';
  }

  @override
  String get paymentNoteHint => 'Bonifico bancario, Revolut, contanti...';

  @override
  String get paymentAmountPositiveError => 'L’importo deve essere maggiore di zero.';

  @override
  String get paymentAmountTooHighError => 'L’importo non può essere superiore al saldo in sospeso.';

  @override
  String get paymentRequestCreated => 'Richiesta di pagamento inviata.';

  @override
  String get paymentRecordedWaiting => 'Pagamento registrato. In attesa di conferma.';

  @override
  String get paymentConfirmTitle => 'Conferma del pagamento';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Conferma di aver ricevuto $arg1 da $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Pagamento confermato.';

  @override
  String get paymentCancelRecordTitle => 'Annulla la registrazione del pagamento';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Annullare la registrazione del tuo pagamento di $arg1 a $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Registrazione del pagamento annullata.';

  @override
  String get paymentNotReceivedTitle => 'Pagamento non ricevuto';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Contrassegnare il pagamento $arg1 da $arg2 come non ricevuto?';
  }

  @override
  String get paymentMarkedNotReceived => 'Pagamento contrassegnato come non ricevuto.';

  @override
  String get paymentActivityTitle => 'Attività di pagamento';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Richieste di pagamento in sospeso: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Pagamenti in attesa di conferma: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Pagamenti registrati';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 ha richiesto un pagamento a $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 ha pagato $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Pagamento richiesto';

  @override
  String get paymentAwaitingConfirmationStatus => 'In attesa di conferma';

  @override
  String get paymentReviewRequestAction => 'Rivedi la richiesta';

  @override
  String get paymentViewDetailsAction => 'Dettagli di pagamento';

  @override
  String get paymentMarkPaidAction => 'Ho pagato';

  @override
  String get paymentDeclineAction => 'Rifiuta';

  @override
  String get paymentRequestReviewTitle => 'Richiesta di pagamento';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 ti ha richiesto $arg2. Effettua il pagamento al di fuori di Splyto, quindi contrassegnalo come pagato.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Contrassegnare la richiesta come pagata?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Conferma solo dopo aver pagato $arg1 a $arg2 al di fuori di Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Contrassegnato come pagato. In attesa di conferma.';

  @override
  String get paymentRequestCancelTitle => 'Annullare la richiesta di pagamento?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Annullare la richiesta $arg1 a $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Richiesta di pagamento annullata.';

  @override
  String get paymentRequestDeclineTitle => 'Rifiutare la richiesta di pagamento?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Rifiutare la richiesta di pagamento di $arg1 inviata da $arg2? La persona riceverà una notifica.';
  }

  @override
  String get paymentRequestDeclined => 'Richiesta di pagamento rifiutata.';

  @override
  String get paymentPendingBeforeFinish => 'Risolvere le richieste di pagamento in sospeso e i pagamenti non confermati prima della liquidazione finale.';

  @override
  String get paymentFinishBlockedByPending => 'Il completamento viene sbloccato dopo che le richieste di pagamento e i pagamenti non confermati sono stati risolti.';

  @override
  String get notificationPaymentRequestedTitle => 'Pagamento richiesto';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 ti ha richiesto $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Hai ricevuto una richiesta di pagamento.';

  @override
  String get notificationPaymentRequestSentTitle => 'Pagamento richiesto inviato';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 ha contrassegnato la tua richiesta di pagamento $arg2 come pagata.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'La tua richiesta di pagamento è stata contrassegnata come pagata.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Richiesta di pagamento annullata';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 ha annullato la richiesta di pagamento $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Una richiesta di pagamento è stata annullata.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Richiesta di pagamento rifiutata';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 ha rifiutato la tua richiesta di pagamento $arg2.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'La tua richiesta di pagamento è stata rifiutata.';

  @override
  String get notificationPaymentSentTitle => 'Pagamento contrassegnato come inviato';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 ha contrassegnato $arg2 come pagato a te.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Un pagamento è stato contrassegnato come inviato a te.';

  @override
  String get notificationPaymentConfirmedTitle => 'Pagamento confermato';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 ha confermato di aver ricevuto $arg2 da te.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Il tuo pagamento è stato confermato.';

  @override
  String get notificationPaymentCancelledTitle => 'Pagamento annullato';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 ha annullato il contrassegno di pagamento $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Un segno di pagamento è stato annullato.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Pagamento non ricevuto';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 ha contrassegnato il pagamento $arg2 come non ricevuto.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Un pagamento è stato contrassegnato come non ricevuto.';

  @override
  String get quickStartTitle => 'Guida rapida';

  @override
  String get quickStartCreateTitle => 'Da solo o con gli amici';

  @override
  String get quickStartCreateBody => 'Crea un viaggio per te o per un gruppo. Aggiungi amici con un link o un codice QR e invitali.';

  @override
  String get quickStartInviteTitle => 'Viaggiare in gruppo o da soli';

  @override
  String get quickStartInviteBody => 'Invita gli amici a condividere il tuo viaggio oppure avvia un viaggio personale da solo.';

  @override
  String get quickStartExpenseTitle => 'Spese in molte valute';

  @override
  String get quickStartExpenseBody => 'Scegli chi ha pagato e come dividere. Le altre valute vengono convertite al cambio della data di acquisto, anche se le aggiungi dopo.';

  @override
  String get quickStartSettleTitle => 'Salda in modo semplice';

  @override
  String get quickStartSettleBody => 'Vedi chi deve quanto a chi, paga come preferisci e conferma nell’app.';

  @override
  String get quickStartAnalyticsTitle => 'Budget e spese';

  @override
  String get quickStartAnalyticsBody => 'Imposta un budget per il viaggio o il gruppo e guarda le spese per categoria, viaggio e giorno.';

  @override
  String get quickStartMapTitle => 'Salva i tuoi luoghi';

  @override
  String get quickStartMapBody => 'Aggiungi le città visitate alla tua mappa di viaggio privata. Puoi vederla solo tu.';

  @override
  String get quickStartLiveTitle => 'Ritrovatevi';

  @override
  String get quickStartLiveBody => 'Nei viaggi di gruppo, condividi la posizione in tempo reale per il tempo che scegli. I membri del viaggio possono vederla e puoi interrompere quando vuoi.';

  @override
  String get quickStartNext => 'Avanti';

  @override
  String get quickStartBack => 'Indietro';

  @override
  String get quickStartSkip => 'Salta';

  @override
  String get quickStartCreateAction => 'Crea viaggio';

  @override
  String get quickStartClose => 'Chiudi Guida rapida';

  @override
  String get quickStartSubtitle => 'Scopri come funzionano i viaggi e le spese';

  @override
  String quickStartStep(int step, int total) {
    return 'Passo $step di $total';
  }

  @override
  String get workspaceTripTotal => 'Totale del viaggio';

  @override
  String get workspacePersonalTotal => 'Totale speso';

  @override
  String get workspaceBalanceEven => 'Il tuo saldo è in pareggio';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Devi pagare $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Devi ricevere $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Membri: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Cerca le spese';

  @override
  String get workspaceClearSearch => 'Ricerca chiara';

  @override
  String get workspaceSearchLoadedHint => 'La ricerca include le spese già caricate. Carica altre spese per includere quelle più vecchie.';

  @override
  String get workspaceNoExpenseMatches => 'Nessuna spesa corrispondente';

  @override
  String get workspaceNoExpenseMatchesBody => 'Prova a effettuare un’altra ricerca o a cancellarla per visualizzare tutte le spese caricate.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Aggiungi la tua prima spesa per iniziare a tenere traccia delle tue spese.';

  @override
  String get workspaceEmptyGroupExpenses => 'Aggiungi la tua prima spesa condivisa per vedere la quota di ciascuno.';

  @override
  String get workspaceLoadMoreExpenses => 'Carica altre spese';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Importo originale: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Commenti: $count';
  }

  @override
  String get workspaceExpenseActions => 'Azioni relative alle spese';

  @override
  String get workspaceLoadErrorTitle => 'Impossibile caricare questo viaggio';

  @override
  String get workspaceCachedWarning => 'Visualizzazione dei dati salvati. Potrebbero non essere aggiornati.';

  @override
  String get workspaceActivityTab => 'Attività';

  @override
  String get workspaceLoadingTrip => 'Caricamento del viaggio';

  @override
  String get workspaceRefreshFailed => 'Aggiornamento non riuscito';

  @override
  String get expenseDetailsTitle => 'Dettagli delle spese';

  @override
  String get expenseQuickCategories => 'Categorie rapide';

  @override
  String get expenseReceiptRead => 'Ricevuta letta e modulo aggiornato.';

  @override
  String get expenseReceiptNoData => 'Ricevuta allegata. Non sono stati individuati importo, data o esercente chiari.';

  @override
  String get expenseReceiptScanFailed => 'Ricevuta selezionata. Lettura automatica non riuscita; controllare i campi manualmente.';

  @override
  String get expenseReceiptOffline => 'La ricevuta verrà caricata al momento del salvataggio. La lettura automatica richiede una connessione.';

  @override
  String get expenseReadingReceipt => 'Lettura dello scontrino…';

  @override
  String get expenseCommentsLoadFailed => 'Impossibile caricare i commenti. Riprova.';

  @override
  String get expenseReplyAction => 'Rispondi';

  @override
  String get expenseReplyHint => 'Scrivi una risposta…';

  @override
  String expenseReplyTo(String name) {
    return 'Rispondi a $name';
  }

  @override
  String get balanceEmptyBody => 'I saldi vengono visualizzati dopo l’aggiunta delle spese.';

  @override
  String get balanceAfterPayments => 'I saldi includono i pagamenti confermati.';

  @override
  String get balanceExpenseShare => 'Condivisione delle spese';

  @override
  String get balanceHistoryScope => 'Spese registrate e pagamenti confermati. Questo elenco potrebbe non includere l’intera cronologia del viaggio.';

  @override
  String balancePaymentTo(String name) {
    return 'Pagamento a $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Pagamento da $name';
  }

  @override
  String get settlementEmptyActive => 'Contrassegnare tutti come pronti prima di avviare i conteggi finali.';

  @override
  String get settlementEmptyClosed => 'Non sono presenti trasferimenti per questo viaggio.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count di $total trasferimenti confermati';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count su $total membri pronti';
  }

  @override
  String get settlementMemberReady => 'Pronto';

  @override
  String get settlementMemberNotReady => 'Non pronto';

  @override
  String get settlementSuggested => 'Trasferimento suggerito';

  @override
  String get activityLoadFailed => 'Impossibile aggiornare l’attività. Le voci visibili potrebbero non essere aggiornate.';

  @override
  String get activityMember => 'Membro del viaggio';

  @override
  String get friendsEmptyBody => 'Cerca un amico per nome o e-mail, oppure utilizza un codice QR.';

  @override
  String get friendsDeclineAction => 'Rifiuta';

  @override
  String get friendsLoading => 'Caricamento degli amici';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Viaggi condivisi: $count';
  }

  @override
  String get memberActivityScope => 'In base alle spese inserite; ciò potrebbe non coprire l’intero viaggio.';

  @override
  String get sharedTripsLoadedLimit => 'Vengono visualizzati fino a 20 viaggi condivisi.';

  @override
  String get memberRemoveTitle => 'Rimuovere un partecipante?';

  @override
  String memberRemoveBody(String name) {
    return 'Rimuovere $name da questo viaggio? Ciò è possibile solo se non ha spese, liquidazioni o saldi.';
  }

  @override
  String get memberRemoveAction => 'Rimuovi dal viaggio';

  @override
  String memberRemoved(String name) {
    return '$name è stato rimosso dal viaggio.';
  }

  @override
  String get profilePaymentNotAdded => 'Non ancora aggiunto';

  @override
  String get friendRelationshipLabel => 'Amico';

  @override
  String get sharedTripsEmptyBody => 'I viaggi a cui entrambi partecipate appariranno qui.';

  @override
  String get analyticsAllTrips => 'Tutti i viaggi';

  @override
  String get analyticsByTrip => 'Per viaggio';

  @override
  String get analyticsYourSpending => 'Le tue spese';

  @override
  String get analyticsActiveArchived => 'Viaggi attivi e archiviati';

  @override
  String get analyticsTrips => 'Viaggi';

  @override
  String get analyticsAveragePerTrip => 'Media per viaggio';

  @override
  String get analyticsPaidByMember => 'Pagato dal membro';

  @override
  String get analyticsYouPaid => 'Hai pagato.';

  @override
  String get analyticsYouGetBack => 'Devi ricevere';

  @override
  String get analyticsYouOwe => 'Devi pagare';

  @override
  String get analyticsParticipants => 'Partecipanti';

  @override
  String get analyticsYourCategories => 'Le tue spese per categoria';

  @override
  String get analyticsLargestShares => 'Le mie quote di spesa maggiori';

  @override
  String get analyticsLargestExpenses => 'Spese più ingenti';

  @override
  String get analyticsSpendingByTrip => 'Le tue spese per viaggio';

  @override
  String get analyticsEmptyTitle => 'Nessuna spesa per ora';

  @override
  String get analyticsEmptyBody => 'Le tue spese appariranno qui quando aggiungi delle spese a un viaggio.';

  @override
  String get analyticsPeriodEmptyBody => 'Non ci sono spese per questa visualizzazione. Prova un altro viaggio o un altro periodo.';

  @override
  String get analyticsLoadFailed => 'Impossibile caricare il resoconto completo delle spese. Riprovare.';

  @override
  String get analyticsLastLoaded => 'Visualizzazione dell’ultimo rapporto caricato con successo.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spese',
      one: '$count spesa',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Opzioni di viaggio';

  @override
  String get editTripAction => 'Modifica viaggio';

  @override
  String get deleteTripAction => 'Elimina viaggio';

  @override
  String get inviteTripMembersAction => 'Invita i membri';

  @override
  String get tripCoverPhoto => 'Foto di copertina';

  @override
  String get tripInviteLaterHint => 'È possibile invitare persone dopo aver creato il viaggio.';

  @override
  String get inviteClipboardFailed => 'Impossibile accedere agli appunti. Riprova.';

  @override
  String get friendInviteToTrip => 'Invita al viaggio';

  @override
  String get friendChooseTrip => 'Scegli un viaggio';

  @override
  String get friendNoInvitableTrips => 'Nessun viaggio disponibile. Puoi invitare amici a viaggi di gruppo attivi da te gestiti, a meno che non siano già membri o abbiano un invito in sospeso.';

  @override
  String get friendTripInviteSent => 'Invito inviato.';

  @override
  String get friendTripUnavailable => 'Questo viaggio non è più disponibile per questa azione. Aggiorna la pagina e riprova.';

  @override
  String get friendTripActionFailed => 'Impossibile completare questa azione. Riprova.';

  @override
  String get profileContactDescription => 'Hai un problema, un suggerimento o una domanda su Splyto? Scrivici un’e-mail: saremo lieti di aiutarti.';

  @override
  String get profileContactEmailAction => 'Scrivi un’e-mail';

  @override
  String get profileContactEmailUnavailable => 'Impossibile aprire l’app di posta elettronica. Copia l’indirizzo e scrivici dalla tua app di posta elettronica.';

  @override
  String get profilePrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get privacyLoadFailed => 'Impossibile caricare l’informativa sulla privacy. Riprovare.';

  @override
  String get addReceiptAction => 'Aggiungi ricevuta';

  @override
  String get receiptPickFailed => 'Impossibile caricare la ricevuta. Riprovare.';

  @override
  String get receiptPhotoAccessDenied => 'Consenti a Splyto l’accesso alla fotocamera o alla libreria delle foto nelle Impostazioni, quindi riprova.';

  @override
  String get receiptPhotoLabel => 'Foto dello scontrino';

  @override
  String get replaceReceiptAction => 'Sostituisci la ricevuta';

  @override
  String get removeReceiptAction => 'Rimuovi la ricevuta';

  @override
  String get restoreReceiptAction => 'Ripristina la ricevuta precedente';

  @override
  String get expenseSplitBetween => 'Distinguere tra';

  @override
  String get expenseEditParticipants => 'Scegli i partecipanti';

  @override
  String get expenseCustomSplit => 'Ripartizione personalizzata';

  @override
  String expenseSplitAllocated(String amount) {
    return 'Tutti i $amount sono ripartiti';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Rimane da dividere $amount';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount oltre il totale';
  }

  @override
  String get profilePaymentSharingTitle => 'Condividi i metodi di pagamento con i miei viaggi';

  @override
  String get profilePaymentSharingDescription => 'Consenti ai partecipanti accettati dei viaggi che creo o a cui mi unisco di vedere i miei metodi di pagamento. Questa impostazione vale per i viaggi attuali e futuri. Puoi disattivarla in qualsiasi momento per impedire ulteriori accessi.';

  @override
  String get memberPaymentDetailsNotShared => 'I metodi di pagamento non vengono condivisi o sono attualmente non disponibili.';

  @override
  String get homeTripInvitations => 'Inviti al viaggio';

  @override
  String get homeNoTripInvitations => 'Nessun invito di viaggio in sospeso';

  @override
  String get homeInvitationsLoadFailed => 'Impossibile caricare gli inviti. Riprovare.';

  @override
  String get homeInvitationResponseFailed => 'Impossibile rispondere all’invito. Riprovare.';

  @override
  String get homeTripShareFailed => 'Impossibile condividere il viaggio. Riprova.';

  @override
  String get settleStillToReceive => 'Ancora da ricevere';

  @override
  String get settleStillToPay => 'Da pagare';

  @override
  String get settleEstimateCaption => 'Stima basata sulle spese attuali. Gli importi possono variare fino al termine del viaggio.';

  @override
  String get settleOutstandingCaption => 'In attesa di pagamento o conferma.';

  @override
  String get settleWaitingForYou => 'In attesa che tu indichi di essere pronto.';

  @override
  String get settleWhoPaysWhom => 'Chi paga chi';

  @override
  String get settlePreviewCaption => 'Anteprima · finalizzata al termine del viaggio';

  @override
  String get settleOpenPaymentCaption => 'Apri una transazione per visualizzarne i dettagli e le azioni disponibili.';

  @override
  String get tripBudgetEnable => 'Stabilisci un budget';

  @override
  String get tripBudgetSoloHint => 'Obiettivo di spesa facoltativo per questo viaggio.';

  @override
  String get tripBudgetGroupHint => 'Un unico budget condiviso per l’intero gruppo.';

  @override
  String get tripBudgetAmount => 'Importo del budget';

  @override
  String get tripBudgetInvalid => 'Inserisci un importo compreso tra 0,01 e 999999999,99, con un massimo di due cifre decimali.';

  @override
  String get tripBudgetTitle => 'Budget del viaggio';

  @override
  String get tripBudgetGroupTitle => 'Bilancio di gruppo';

  @override
  String get tripBudgetRemaining => 'Rimanente';

  @override
  String get tripBudgetOver => 'Superamento del budget';

  @override
  String get tripBudgetSpent => 'Speso';

  @override
  String get tripBudgetLimit => 'Budget';

  @override
  String get travelMapTitle => 'La mia mappa di viaggio';

  @override
  String get travelMapSubtitle => 'Luoghi visitati, solo per te.';

  @override
  String get travelMapHere => 'Sono stato qui';

  @override
  String get travelMapAdd => 'Aggiungi luogo';

  @override
  String get travelMapSearch => 'Cerca città e paese';

  @override
  String get travelMapSearchAction => 'Cerca';

  @override
  String get travelMapSearchHint => 'Ad esempio, Lisbona, Portogallo';

  @override
  String get travelMapEmpty => 'Il tuo prossimo ricordo inizia qui';

  @override
  String get travelMapEmptyBody => 'Aggiungi una città che hai visitato o fai il check-in nel luogo in cui ti trovi ora.';

  @override
  String get travelMapConfirm => 'Salvare questa visita?';

  @override
  String get travelMapConfirmBody => 'Verifica la città e la data prima di salvarle sulla tua mappa privata.';

  @override
  String get travelMapDate => 'Data della visita';

  @override
  String get travelMapSave => 'Salva sulla mia mappa';

  @override
  String get travelMapCancel => 'Annulla';

  @override
  String get travelMapClose => 'Chiudi';

  @override
  String get travelMapNoResults => 'Nessuna città trovata. Prova ad aggiungere il Paese alla tua ricerca.';

  @override
  String get travelMapLookupError => 'Impossibile trovare la città. Verifica la tua connessione o aggiungi un luogo manualmente.';

  @override
  String get travelMapDenied => 'L’accesso alla posizione è disattivato. È comunque possibile aggiungere manualmente una città.';

  @override
  String get travelMapDisabled => 'Attiva i servizi di localizzazione oppure aggiungi manualmente una città.';

  @override
  String get travelMapError => 'Impossibile caricare la mappa del viaggio. Riprovare.';

  @override
  String get travelMapSaveError => 'Impossibile salvare la visita. Riprovare.';

  @override
  String get travelMapUnavailable => 'La mappa di viaggio richiede un aggiornamento del server.';

  @override
  String get travelMapOffline => 'Offline · visualizzazione dei luoghi salvati';

  @override
  String get travelMapRetry => 'Riprova';

  @override
  String get travelMapDelete => 'Rimuovi visita';

  @override
  String get travelMapDeleteConfirm => 'Rimuovere questa visita dalla tua mappa privata?';

  @override
  String get travelMapFit => 'Mostra tutti i luoghi';

  @override
  String get travelMapSaved => 'Visita salvata';

  @override
  String get travelMapVisited => 'Visitato';

  @override
  String get travelMapLimit => 'La tua mappa ha raggiunto le 1.000 visite. Elimina una visita precedente prima di aggiungerne un’altra.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries paesi',
      one: '$countries paese',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities città',
      one: '$cities città',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visite',
      one: '$count visita',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Destinazioni (facoltativo)';

  @override
  String get travelAddDestination => 'Aggiungi destinazione';

  @override
  String get travelRemoveDestination => 'Rimuovi la destinazione';

  @override
  String get travelFromTrip => 'Da un viaggio';

  @override
  String get travelChooseTrip => 'Scegli un viaggio';

  @override
  String get travelNoTrips => 'Non ci sono ancora viaggi disponibili. Puoi aggiungere manualmente una località.';

  @override
  String get travelAddToMap => 'Aggiungi alla mia mappa';

  @override
  String get travelTripConfirm => 'Salva solo i luoghi che hai effettivamente visitato. Questo aggiunge un ricordo personale alla tua mappa.';

  @override
  String get travelVisitTitle => 'Titolo (facoltativo)';

  @override
  String get travelAddPhoto => 'Aggiungi una foto';

  @override
  String get travelChangePhoto => 'Cambia foto';

  @override
  String get travelRemovePhoto => 'Rimuovi foto';

  @override
  String get travelPhotoError => 'Impossibile elaborare questa foto. Sceglietene un’altra.';

  @override
  String get travelEditVisit => 'Modifica visita';

  @override
  String get travelOpenTrip => 'Viaggio aperto';

  @override
  String get travelPreviousVisit => 'Visita precedente';

  @override
  String get travelNextVisit => 'Prossima visita';

  @override
  String get travelDuplicate => 'Questa visita è già presente sulla tua mappa.';

  @override
  String get liveMapTitle => 'Mappa in tempo reale';

  @override
  String get liveShareTitle => 'Condividi la mia posizione';

  @override
  String get liveConsent => 'Condividi la tua posizione precisa solo con i partecipanti accettati di questo viaggio, per la durata che scegli. La condivisione continua in background e puoi interromperla in qualsiasi momento.';

  @override
  String get liveBackgroundNote => 'Gli aggiornamenti possono essere sospesi in assenza di connessione a Internet o se si chiude forzatamente l’app. Viene conservata solo la posizione più recente; non viene registrata alcuna cronologia del percorso.';

  @override
  String get liveStart => 'Inizia a condividere';

  @override
  String get liveStop => 'Interrompi la condivisione';

  @override
  String get liveNotification => 'La tua posizione è in fase di condivisione con il tuo viaggio. Apri Splyto per interrompere la condivisione.';

  @override
  String get livePermissionError => 'Consenti l’accesso alla posizione nelle impostazioni del telefono per condividere la tua posizione.';

  @override
  String get liveStartError => 'Impossibile avviare la condivisione. Verifica l’accesso alla posizione, la connessione a Internet e la data e l’ora del tuo telefono.';

  @override
  String get liveStopPending => 'Aggiornamenti interrotti. In attesa di una connessione Internet per rimuovere la tua ultima posizione; questa scomparirà dalla mappa entro 2 minuti in assenza di aggiornamenti.';

  @override
  String get liveSharing => 'condivisione della posizione';

  @override
  String get liveUnavailable => 'Questa mappa in tempo reale non è disponibile. Torna al viaggio e aggiorna la pagina.';

  @override
  String get liveMapLoadError => 'Impossibile caricare la mappa. Verifica la tua connessione e riapri la mappa.';

  @override
  String get liveLoadError => 'Impossibile aggiornare le posizioni. Vengono mostrati solo gli aggiornamenti recenti.';

  @override
  String get liveFit => 'Mostra tutti sulla mappa';

  @override
  String get liveEmpty => 'Nessuno sta ancora condividendo la propria posizione recente.';

  @override
  String get liveRecent => 'Appena aggiornato';

  @override
  String get liveLastKnown => 'Ultimo aggiornamento';

  @override
  String get liveAccuracy => 'Accuratezza';

  @override
  String get liveUntil => 'Condivisione fino a';

  @override
  String get liveOtherSession => 'Avviato in un’altra sessione. Puoi interromperlo qui.';

  @override
  String get liveUpdatesPaused => 'Aggiornamenti sospesi. Verificare l’accesso alla posizione e la connessione a Internet.';

  @override
  String get livePrivateUntilShared => 'La tua posizione rimane privata finché non decidi di condividerla.';

  @override
  String get activityEventExpenseCreated => 'ha aggiunto una spesa';

  @override
  String get activityEventExpenseUpdated => 'ha aggiornato una spesa';

  @override
  String get activityEventExpenseDeleted => 'ha eliminato una spesa';

  @override
  String get activityEventExpenseCommentAdded => 'ha commentato una spesa';

  @override
  String get activityEventTripCreated => 'ha creato il viaggio';

  @override
  String get activityEventTripUpdated => 'ha aggiornato i dettagli del viaggio';

  @override
  String get activityEventTripRenamed => 'ha rinominato il viaggio';

  @override
  String get activityEventTripCurrencyChanged => 'ha cambiato la valuta del viaggio';

  @override
  String get activityEventTripPhotoChanged => 'ha cambiato la foto del viaggio';

  @override
  String get activityEventTripBudgetChanged => 'ha modificato il budget del viaggio';

  @override
  String get activityEventTripDestinationsChanged => 'ha modificato le destinazioni del viaggio';

  @override
  String get activityEventTripMembersAdded => 'ha aggiunto dei membri';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'ha inviato inviti: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'si è unito/a al viaggio';

  @override
  String get activityEventTripInvitationDeclined => 'ha rifiutato l’invito al viaggio';

  @override
  String get activityEventTripInvitationRevoked => 'ha annullato un invito al viaggio';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'ha rimosso $name dal viaggio';
  }

  @override
  String get activityEventTripMemberLeft => 'ha lasciato il viaggio';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'ha modificato il ruolo di $name in $role';
  }

  @override
  String get activityEventTripMemberReady => 'ha segnato la disponibilità al saldo';

  @override
  String get activityEventTripMemberNotReady => 'ha ritirato la disponibilità al saldo';

  @override
  String get activityEventTripAllMembersReady => 'Tutti i membri sono pronti a saldare';

  @override
  String get activityEventTripFinished => 'ha terminato il viaggio';

  @override
  String get activityEventTripSettled => 'Tutti i trasferimenti sono confermati, il viaggio è saldato';

  @override
  String get activityEventSettlementMarkedSent => 'ha contrassegnato un trasferimento come inviato';

  @override
  String get activityEventSettlementConfirmed => 'ha confermato un trasferimento';

  @override
  String get activityEventSettlementSentCancelled => 'ha annullato lo stato “inviato”';

  @override
  String get activityEventSettlementNotReceived => 'ha contrassegnato un trasferimento come non ricevuto';

  @override
  String get activityEventSettlementReminderSent => 'ha inviato un promemoria di saldo';

  @override
  String get activityEventPaymentMarkedSent => 'ha registrato un pagamento';

  @override
  String get activityEventPaymentRequested => 'ha richiesto un pagamento';

  @override
  String get activityEventPaymentRequestMarkedSent => 'ha contrassegnato un pagamento richiesto come inviato';

  @override
  String get activityEventPaymentRequestCancelled => 'ha annullato una richiesta di pagamento';

  @override
  String get activityEventPaymentRequestDeclined => 'ha rifiutato una richiesta di pagamento';

  @override
  String get activityEventPaymentConfirmed => 'ha confermato un pagamento';

  @override
  String get activityEventPaymentCancelled => 'ha annullato una registrazione di pagamento';

  @override
  String get activityEventPaymentNotReceived => 'ha contrassegnato un pagamento come non ricevuto';

  @override
  String get activityEventUnknown => 'ha apportato una modifica';

  @override
  String get privacyEnglishFallback => 'L’informativa sulla privacy è attualmente disponibile in inglese.';

  @override
  String get activityRoleAdmin => 'Amministratore';

  @override
  String get accountDeleteTitle => 'Elimina account';

  @override
  String get accountDeleteIntro => 'Conferma l’eliminazione via e-mail. Dopo la conferma, non può essere annullata.';

  @override
  String get accountDeleteConsequences => 'La cancellazione è definitiva. Il tuo profilo viene reso anonimo e l’accesso all’account viene revocato. I registri condivisi relativi al viaggio e alle spese vengono conservati per gli altri membri.';

  @override
  String get accountDeleteReasonsTitle => 'Cosa avremmo potuto fare meglio?';

  @override
  String get accountDeleteReasonsHint => 'Motivo (facoltativo)';

  @override
  String get accountDeleteReasonNotUsing => 'Non ho più bisogno di Splyto per i miei viaggi';

  @override
  String get accountDeleteReasonAnotherWay => 'Gestisco le spese condivise in un altro modo';

  @override
  String get accountDeleteReasonComplicated => 'Ci vuole troppo impegno per portare a termine le cose';

  @override
  String get accountDeleteReasonTechnical => 'Ho riscontrato bug o problemi tecnici';

  @override
  String get accountDeleteReasonPrivacy => 'Preferirei rimuovere i dati del mio account';

  @override
  String get accountDeleteReasonOther => 'Me ne vado per un motivo diverso';

  @override
  String get accountDeleteEmailStep => 'Il passo successivo è la conferma via e-mail.';

  @override
  String get accountDeletePasswordHint => 'Inserisci la tua attuale password di Splyto per richiedere l’e-mail di conferma. Il tuo account è ancora attivo.';

  @override
  String get accountDeleteInboxTitle => 'Un ultimo passaggio nella tua casella di posta';

  @override
  String accountDeleteSentBody(String email) {
    return 'Link di conferma inviato a $email.';
  }

  @override
  String get accountDeleteSentHint => 'Il tuo account resta attivo finché non confermi l’eliminazione.';

  @override
  String get accountDeleteSending => 'Invio dell’e-mail di conferma';

  @override
  String get friendsShowMore => 'Mostra altro';
}
