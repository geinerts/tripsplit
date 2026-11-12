// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get homeFirstTrip => 'Votre premier voyage';

  @override
  String get homeYourShareAllTrips => 'Votre part pour tous les voyages';

  @override
  String get homeAllTime => 'Toute la période';

  @override
  String get homeSolo => 'En solo';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '$count personne',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Actions liées au voyage : $name';
  }

  @override
  String get homeNoActiveTrips => 'Aucun voyage actif';

  @override
  String get homeNoArchivedTrips => 'Aucun voyage archivé';

  @override
  String get homeLoadingTrips => 'Chargement de vos voyages';

  @override
  String get homeLoadErrorTitle => 'Impossible de charger vos voyages';

  @override
  String get homeLoadErrorBody => 'Veuillez réessayer dans quelques instants.';

  @override
  String get homeOfflineTitle => 'Vous êtes hors ligne';

  @override
  String get homeOfflineNoData => 'Vos voyages ne sont pas encore disponibles sur cet appareil.';

  @override
  String get homeOfflineCached => 'Hors ligne. Affichage des voyages enregistrés.';

  @override
  String get homeRefreshError => 'Impossible d’actualiser. Affichage des voyages précédemment chargés.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Partager mes coordonnées de paiement enregistrées avec $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Uniquement tant que cette demande est en attente de paiement. L’annulation de la demande met fin à l’accès.';

  @override
  String get paymentDetailsUnavailable => 'Les détails de paiement ne sont pas disponibles. Connectez-vous à Internet et vérifiez que la demande est toujours en cours.';

  @override
  String get paymentDetailsRetry => 'Réessayez';

  @override
  String get tripModeSolo => 'Moi uniquement';

  @override
  String get tripModeGroup => 'À plusieurs';

  @override
  String get premiumFree => 'Gratuit';

  @override
  String get premiumStatusUnavailable => 'Statut du plan indisponible';

  @override
  String premiumGrantedUntil(String date) {
    return 'Abonnement Premium accordé jusqu’au $date';
  }

  @override
  String get premiumBillingNotActive => 'Pas d’abonnement actif';

  @override
  String get premiumRefreshStatus => 'Actualiser le statut du plan';

  @override
  String get accountSectionTitle => 'Compte';

  @override
  String get activeStatus => 'Actif';

  @override
  String get activeTripPlural => 'voyages en cours';

  @override
  String get activeTripSingle => 'voyage en cours';

  @override
  String get activeTrips => 'Voyages en cours';

  @override
  String get activitiesComingSoon => 'La section « Activités » sera bientôt disponible.';

  @override
  String get addAction => 'Ajouter';

  @override
  String get addExpenseTitle => 'Ajouter une dépense';

  @override
  String get addExpensesAction => 'Ajouter des dépenses';

  @override
  String get addMembersAction => 'Ajouter des participants';

  @override
  String get addTripMembersTitle => 'Inviter des participants au voyage';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations envoyées',
      one: '$count invitation envoyée',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Invitation au voyage refusée.';

  @override
  String get tripInviteAction => 'Inviter';

  @override
  String get tripInvitationsPending => 'En attente de réponse';

  @override
  String get tripInvitationsRetry => 'Invitations indisponibles. Réessayez';

  @override
  String get tripInvitationRevoke => 'Annuler l’invitation';

  @override
  String get tripInvitationRevokeFailed => 'Impossible d’annuler l’invitation. Réessayez.';

  @override
  String get tripInvitationBody => 'Vous avez été invité à un voyage. Ouvrez l’invitation pour y répondre.';

  @override
  String get allCaughtUp => 'Tout est à jour';

  @override
  String get allFilter => 'Tout';

  @override
  String get allMembersLabel => 'Tous les participants';

  @override
  String get allPaymentsConfirmed => 'Tous les paiements sont confirmés.';

  @override
  String get allTrips => 'Tous les voyages';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Montant';

  @override
  String get amountMustBeGreaterThanZero => 'Le montant doit être supérieur à 0.';

  @override
  String get appearance => 'Présentation';

  @override
  String get archivedStatus => 'Archivé';

  @override
  String get authSubtitleLogin => 'Partagez les frais de voyage entre amis';

  @override
  String get authSubtitleRegister => 'Créez un compte et commencez à partager les frais de voyage';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'confirmés : $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'en attente : $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'envoyé : $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'suggéré : $count';
  }

  @override
  String get cancelAction => 'Annuler';

  @override
  String get changeEmailWithPasswordHelper => 'Saisissez votre mot de passe pour modifier votre adresse e-mail.';

  @override
  String get chooseReceiptFile => 'Choisissez le fichier de reçu';

  @override
  String get completeAccountSetupDescription => 'Saisissez votre adresse e-mail et votre mot de passe pour finaliser la création de votre compte.';

  @override
  String get completeAccountSetupTitle => 'Configuration complète du compte';

  @override
  String get confirmReceivedAction => 'Confirmer la réception';

  @override
  String get confirmedAllSettlementsArchived => 'Tous les règlements ont été confirmés. Le voyage a été archivé.';

  @override
  String get confirmedAsReceived => 'Réception confirmée.';

  @override
  String get confirmedLabel => 'Confirmé';

  @override
  String get couldNotOpenReceiptLink => 'Impossible d’ouvrir le lien vers le reçu.';

  @override
  String get createAction => 'Créer';

  @override
  String get createFirstTripHint => 'Créez votre premier voyage pour commencer.';

  @override
  String get createNewTripTitle => 'Créer un nouveau voyage';

  @override
  String get createTripAction => 'Créer un voyage';

  @override
  String get createTripFirst => 'Commencez par créer un voyage.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Créé par $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Le créateur du voyage doit terminer le voyage pour lancer la confirmation du règlement.';

  @override
  String currentEmailLabel(Object email) {
    return 'Adresse e-mail actuelle : $email';
  }

  @override
  String get currentReceiptAttached => 'Le reçu actuel est joint.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Date';

  @override
  String get dateMustMatchFormat => 'La date doit être au format YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Date inconnue';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get deleteExpenseConfirmQuestion => 'Supprimer cette dépense ?';

  @override
  String get deleteExpenseTitle => 'Supprimer une dépense';

  @override
  String get editExpenseConfirmTitle => 'Enregistrer les modifications des dépenses ?';

  @override
  String get editExpenseConfirmText => 'Cela mettra à jour les soldes de tous les participants au voyage.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Explication directe par les dépenses : $amount';
  }

  @override
  String get doneStatus => 'Terminé';

  @override
  String get editAction => 'Modifier';

  @override
  String get editExpenseTitle => 'Modifier une dépense';

  @override
  String get emailAddressLabel => 'Adresse e-mail';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'Courriel';

  @override
  String get emailRequired => 'Une adresse e-mail est obligatoire.';

  @override
  String get enterValidExactAmounts => 'Saisissez des montants exacts et valides pour tous les participants.';

  @override
  String get enterValidPercentages => 'Saisissez des pourcentages valides pour tous les participants.';

  @override
  String get equalSplitLabel => 'Partage égal';

  @override
  String exactAmountWithValue(Object value) {
    return 'Exact : $value';
  }

  @override
  String get exactAmountsLabel => 'Montants exacts';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'La répartition exacte doit totaliser $amount.';
  }

  @override
  String get expenseAdded => 'Dépense ajoutée.';

  @override
  String get expenseBreakdownSubtitle => 'En quoi chaque dépense concerne ce participant.';

  @override
  String get expenseBreakdownTitle => 'Répartition des dépenses';

  @override
  String get expenseDeleted => 'Dépense supprimée.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Dépense n° $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Payé $paid  -  Dette $owes';
  }

  @override
  String get expenseReactionsTitle => 'Réactions';

  @override
  String get expenseCommentsTitle => 'Commentaires';

  @override
  String get expenseNoComments => 'Aucun commentaire pour l\'instant.';

  @override
  String get expenseAddCommentHint => 'Ajouter un commentaire...';

  @override
  String get expenseCommentSend => 'Envoyer';

  @override
  String get expenseMentionNoMatches => 'Aucun membre correspondant';

  @override
  String get expenseMentionMembersLabel => 'Membres du voyage à mentionner';

  @override
  String get expenseDeleteCommentTitle => 'Supprimer le commentaire ?';

  @override
  String get expenseUpdated => 'Dépenses mises à jour.';

  @override
  String expenseWithId(Object id) {
    return 'Dépense n° $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dépenses',
      one: '$count dépense',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Dépenses';

  @override
  String get failedToCreateTrip => 'Échec de la création du voyage.';

  @override
  String get failedToLoadUsersDirectory => 'Échec du chargement du répertoire des utilisateurs.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrer les règlements par membre';

  @override
  String get finishSoloTripConfirmationText => 'Souhaitez-vous clôturer ce voyage et le déplacer vers vos archives ? Vos dépenses resteront consultables.';

  @override
  String get soloTripArchived => 'Voyage terminé et archivé.';

  @override
  String get finishTripSyncPending => 'Synchronisez vos modifications en attente avant de terminer ce voyage.';

  @override
  String get finishTripAction => 'Terminer le voyage';

  @override
  String get finishTripConfirmationText => 'Terminer ce voyage et lancer les règlements ?';

  @override
  String get finishTripStartSettlementsAction => 'Terminer et lancer les règlements';

  @override
  String get finishTripTitle => 'Terminer le voyage';

  @override
  String forParticipants(Object participants) {
    return 'À l’attention de : $participants';
  }

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get profileSetPassword => 'Définir un mot de passe';

  @override
  String get profileManagePassword => 'Définir ou modifier le mot de passe';

  @override
  String get profilePasswordByEmail => 'Définir un mot de passe par e-mail';

  @override
  String get passwordEmailBackToProfile => 'Retour au profil';

  @override
  String get forgotPasswordSubtitle => 'Saisissez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get forgotPasswordSuccessMessage => 'Si un compte associé à cette adresse e-mail existe, nous vous avons envoyé un lien pour réinitialiser votre mot de passe.';

  @override
  String get passwordResetSentTitle => 'Consultez votre boîte de réception';

  @override
  String get passwordResetSentHint => 'Le lien est valable 1 heure. Si vous ne voyez pas l’e-mail, vérifiez votre dossier de spam.';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get friendsProgressSubtitle => 'Chaque participant et son statut de confirmation.';

  @override
  String get friendsProgressTitle => 'Progression des amis';

  @override
  String get friendsSectionComingSoon => 'La section « Amis » sera bientôt disponible.';

  @override
  String fromDirection(Object name) {
    return 'De $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from à $to';
  }

  @override
  String get generateTurnAction => 'Tirer au sort la prochaine personne';

  @override
  String get hasAccountQuestion => 'Vous avez déjà un compte ?';

  @override
  String helloUser(Object name) {
    return 'Salut, $name !';
  }

  @override
  String get iSentAction => 'J\'ai envoyé';

  @override
  String get invalidEmailFormat => 'Format d\'e-mail non valide.';

  @override
  String get languageAction => 'Langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageLatvian => 'Letton';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageSystemSubtitle => 'Utiliser la langue de l’appareil';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Laissez ce champ vide pour conserver le mot de passe actuel.';

  @override
  String get logInButton => 'Se connecter';

  @override
  String get logOutButton => 'Se déconnecter';

  @override
  String get logoutFromDeviceQuestion => 'Se déconnecter de cet appareil ?';

  @override
  String get logoutRevocationUnconfirmed => 'Déconnexion de cet appareil. La révocation de la session serveur n’a pas pu être confirmée.';

  @override
  String get markedAsSent => 'Marqué comme envoyé.';

  @override
  String get markSettlementSentConfirmTitle => 'Marquer le virement comme envoyé ?';

  @override
  String get markSettlementSentConfirmText => 'N’utilisez cette fonction qu’après avoir effectivement envoyé le paiement. Le destinataire sera invité à confirmer.';

  @override
  String get settlementCancelSentAction => 'Marquer comme non envoyé';

  @override
  String get settlementCancelSentConfirmTitle => 'Annuler le statut « envoyé » ?';

  @override
  String get settlementCancelSentConfirmText => 'Cela remettra le virement en attente et en informera le destinataire.';

  @override
  String get settlementSentCancelled => 'Le virement est revenu à l’état « en attente ».';

  @override
  String get settlementNotReceivedAction => 'Je n’ai pas reçu ce message';

  @override
  String get settlementNotReceivedConfirmTitle => 'Signaler un paiement non reçu ?';

  @override
  String get settlementNotReceivedConfirmText => 'Cela remettra le virement en attente et en informera le payeur.';

  @override
  String get settlementMarkedNotReceived => 'Marqué comme non reçu.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Avez-vous bien reçu ce message ?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Ne confirmez qu’une fois que l’argent apparaît sur votre compte. Cette action peut finaliser le règlement.';

  @override
  String get memberSummariesSubtitle => 'État actuel du solde pour les deux parties.';

  @override
  String get memberSummariesTitle => 'Résumés des membres';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Pour payer $total  -  confirmé $confirmed  -  en attente $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Impact estimé du paiement par membre.';

  @override
  String get membersImpactTitle => 'Impact sur les membres';

  @override
  String get membersIncludedInExpense => 'Membres inclus';

  @override
  String get membersLabel => 'Membres';

  @override
  String moreCount(Object count) {
    return '+ $count autres';
  }

  @override
  String get myFilter => 'Mon';

  @override
  String get myImpactTitle => 'Mon impact';

  @override
  String get firstNameHint => 'Votre prénom';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get firstNameLengthValidation => 'Le prénom doit comporter entre 2 et 64 caractères.';

  @override
  String get fullNameHelper => 'Indiquez le prénom et le nom dans un seul champ.';

  @override
  String get fullNameHint => 'Par exemple : Anna Ozolina';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get fullNameValidation => 'Saisissez le prénom et le nom (au moins 2 caractères chacun).';

  @override
  String get lastNameHint => 'Votre nom de famille';

  @override
  String get lastNameLabel => 'Nom de famille';

  @override
  String get lastNameLengthValidation => 'Le nom de famille doit comporter entre 2 et 64 caractères.';

  @override
  String get nameHint => 'Votre nom';

  @override
  String get nameLabel => 'Dénomination';

  @override
  String get nameLengthValidation => 'Le nom doit comporter au moins 2 caractères.';

  @override
  String get navActivities => 'Statistiques';

  @override
  String get navAddTrip => 'Ajouter un voyage';

  @override
  String get navBalances => 'Soldes';

  @override
  String get navExpenses => 'Dépenses';

  @override
  String get navFriends => 'Amis';

  @override
  String get navHome => 'Accueil';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRandom => 'Aléatoire';

  @override
  String get netLabel => 'Solde net';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get nicknameHint => 'Comment vos amis vous verront';

  @override
  String get nicknameLabel => 'Pseudonyme';

  @override
  String get nicknameLengthValidation => 'Le pseudonyme doit comporter au moins 2 caractères.';

  @override
  String get noAccountQuestion => 'Vous n’avez pas encore de compte ?';

  @override
  String get noBalancesYet => 'Pas encore de soldes.';

  @override
  String get noChangesToSave => 'Aucune modification à enregistrer.';

  @override
  String get noDirectExpenseLink => 'Aucun lien direct vers une dépense spécifique n’a été trouvé. Ce règlement est calculé à partir du solde total du voyage.';

  @override
  String get noExpenseImpactForMember => 'Aucune incidence financière pour ce membre.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Aucune dépense pour $name pour l\'instant.';
  }

  @override
  String get noExpensesYet => 'Aucune dépense pour l’instant.';

  @override
  String get noExtraUsersToAdd => 'Aucun utilisateur supplémentaire à ajouter.';

  @override
  String get noInternetDeleteQueued => 'Pas d’Internet. Supprimer de la file d’attente.';

  @override
  String get noInternetExpenseQueued => 'Pas d’Internet. Dépense en attente.';

  @override
  String get noInternetUpdateQueued => 'Pas de connexion Internet. Mise à jour en attente.';

  @override
  String get noMatchingRows => 'Aucune ligne correspondante.';

  @override
  String get noMembersFound => 'Aucun membre trouvé.';

  @override
  String get noNewMembersAdded => 'Ces personnes sont déjà membres ou ont des invitations en attente.';

  @override
  String get noNotePlaceholder => 'Aucune remarque';

  @override
  String get notificationsToday => 'Aujourd’hui';

  @override
  String get notificationsEmptyBody => 'Les mises à jour concernant les voyages, les dépenses et les amis s\'afficheront ici.';

  @override
  String get notificationsCached => 'Hors ligne — affichage des notifications enregistrées.';

  @override
  String get notificationsRefreshFailed => 'Impossible d’actualiser. Les notifications précédemment chargées s’affichent.';

  @override
  String get notificationsJustNow => 'À l’instant même';

  @override
  String notificationsMinutesAgo(int count) {
    return 'Il y a $count min';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'Il y a $count h';
  }

  @override
  String get notificationsUnread => 'Non lu';

  @override
  String get noNotificationsYet => 'Aucune notification pour l’instant.';

  @override
  String get noParticipantData => 'Aucune donnée relative aux participants.';

  @override
  String get noParticipantsSelected => 'Aucun participant sélectionné.';

  @override
  String get noPaymentRowsInTrip => 'Aucune ligne de paiement dans ce voyage.';

  @override
  String get noPaymentsNeeded => 'Aucun paiement n’est nécessaire.';

  @override
  String get noPicksYet => 'Aucun choix pour l\'instant.';

  @override
  String get noSettlementActivityForMember => 'Aucune opération de règlement pour ce membre.';

  @override
  String get noSettlementRowsYet => 'Aucune ligne de règlement pour l\'instant.';

  @override
  String get noSettlements => 'Aucun règlement';

  @override
  String get noTransferNeededForFilter => 'Aucun virement n’est nécessaire pour le filtre sélectionné.';

  @override
  String get noTransferRowsToShow => 'Aucune ligne de virement à afficher.';

  @override
  String get noTripDataLoaded => 'Aucune donnée de voyage n’a été chargée.';

  @override
  String get noTripsYet => 'Aucun voyage pour l\'instant.';

  @override
  String get noUsersFoundYet => 'Aucun utilisateur trouvé pour l\'instant.';

  @override
  String get notSetValue => 'Non défini';

  @override
  String get notYetConfirmedTitle => 'Pas encore confirmé';

  @override
  String get noteHint => 'Dîner, taxi, billets…';

  @override
  String get noteLabel => 'Remarque';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'La note doit comporter au maximum $max caractères.';
  }

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationFriendInviteTitle => 'Demande d’amitié';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name vous a envoyé une invitation d’ami.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Vous avez reçu une invitation à devenir ami.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Invitation acceptée';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name a accepté votre invitation d’amitié.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'L\'invitation de votre ami a été acceptée.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Invitation refusée';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name a refusé votre invitation d’amitié.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Votre invitation d’ami a été refusée.';

  @override
  String get notificationTripAddedTitle => 'Ajouté au voyage';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name vous a ajouté au voyage « $trip ».';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Vous avez été ajouté au voyage « $trip ».';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Vous avez été ajouté à un voyage.';

  @override
  String get notificationExpenseAddedTitle => 'Nouvelle dépense ajoutée';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name a ajouté une dépense de $amount dans « $trip ».';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name a ajouté une dépense de $amount : $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Une nouvelle dépense a été ajoutée.';

  @override
  String get notificationCommentMentionTitle => 'Vous avez été mentionné dans un commentaire';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name vous a mentionné dans un commentaire sur « $note ».';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name vous a mentionné dans un commentaire.';
  }

  @override
  String get notificationTripFinishedTitle => 'Voyage terminé';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name a terminé « $trip ». Les règlements sont prêts.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name a terminé « $trip ». Le voyage est archivé.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '« $trip » est terminé.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Le statut du voyage a été mis à jour.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Membre marqué comme prêt';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name est prêt à s\'inscrire à « $trip ».';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Un membre est prêt à s\'inscrire au « $trip ».';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Un membre est prêt à régler sa part.';

  @override
  String get notificationTripReadyToSettleTitle => 'Tous les participants sont prêts';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Tous les participants sont marqués comme « prêts » dans « $trip ». Vous pouvez lancer les règlements.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Tous les participants sont prêts. Vous pouvez lancer les règlements.';

  @override
  String get notificationSettlementReminderTitle => 'Rappel de règlement';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor a rappelé à $target de marquer $amount comme envoyé.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor a rappelé à $target de confirmer la réception de $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Vous avez reçu un rappel de règlement.';

  @override
  String get notificationPaymentReminderTitle => 'Rappel de paiement';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Rappel : veuillez indiquer « $amount » comme envoyé à « $target » dans « $trip ».';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Rappel : veuillez marquer le paiement comme « envoyé ».';

  @override
  String get notificationConfirmationReminderTitle => 'Rappel de confirmation';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Rappel : veuillez confirmer la réception de $amount de la part de $payer dans le cadre de « $trip ».';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Rappel : veuillez confirmer la réception du paiement.';

  @override
  String get notificationSettlementSentTitle => 'Virement marqué comme envoyé';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name a indiqué que $amount vous a été envoyé.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Un virement a été marqué comme envoyé.';

  @override
  String get notificationSettlementConfirmedTitle => 'Virement confirmé';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name a confirmé avoir reçu $amount de votre part.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Un virement a été confirmé.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications en attente',
      one: '$count modification en attente',
    );
    return 'File d’attente hors ligne : $_temp0';
  }

  @override
  String get syncAllSynced => 'Tout est synchronisé';

  @override
  String syncChangesWaiting(Object count) {
    return '$count en attente de synchronisation';
  }

  @override
  String get syncFailedTapToRetry => 'Échec de la synchronisation, appuyez pour réessayer';

  @override
  String get offlineQueueStatus => 'File d’attente hors ligne';

  @override
  String get offlineStatus => 'Hors ligne';

  @override
  String get onlineStatus => 'En ligne';

  @override
  String get onlyCreatorCanFinishTrip => 'Seul le créateur du voyage peut mettre fin au voyage.';

  @override
  String get openLabel => 'Ouvrir';

  @override
  String get openReceiptAction => 'Ouvrir le justificatif';

  @override
  String get openSettlements => 'Ouvrir les règlements';

  @override
  String get overviewTitle => 'Aperçu';

  @override
  String get owesLabel => 'Doit';

  @override
  String get paidByLabel => 'Payé par';

  @override
  String get paidLabel => 'Payant';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Payé $paid  -  Doit $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Participants (vide = tous les membres)';

  @override
  String get participantsTitle => 'Participants';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordComplexityHelper => 'Utilisez au moins 1 majuscule, 1 chiffre et 1 symbole.';

  @override
  String get passwordComplexityValidation => 'Le mot de passe doit comporter 1 lettre majuscule, 1 chiffre et 1 caractère spécial.';

  @override
  String get passwordMinLength => 'Le mot de passe doit comporter au moins 8 caractères.';

  @override
  String get passwordMinLengthShort => 'Le mot de passe doit comporter au moins 6 caractères.';

  @override
  String get passwordResetComingSoon => 'La réinitialisation du mot de passe sera bientôt disponible.';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String payerName(Object name) {
    return '$name (payeur)';
  }

  @override
  String get pendingLabel => 'En attente';

  @override
  String get pendingPaymentsSubtitle => 'Paiements toujours en attente d’une confirmation définitive.';

  @override
  String get percentLabel => 'Pourcentage';

  @override
  String get percentSplitMustBe100 => 'La somme des pourcentages de répartition doit être exactement égale à 100 %.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Pourcentages';

  @override
  String get pickAtLeastOneParticipant => 'Sélectionnez au moins un participant.';

  @override
  String get pickMembersGenerateTurn => 'Sélectionnez les participants et tirez au sort la prochaine personne.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name sélectionné. Cycle terminé.';
  }

  @override
  String pickedUser(Object name) {
    return '$name a été sélectionné.';
  }

  @override
  String get profileRefreshCachedData => 'Impossible d’actualiser le profil. Affichage des données mises en cache.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpdated => 'Profil mis à jour.';

  @override
  String get uploadAvatarAction => 'Importer un avatar';

  @override
  String get takePhotoAction => 'Prenez une photo';

  @override
  String get chooseFromLibraryAction => 'Faites votre choix dans la bibliothèque';

  @override
  String get removeAvatarAction => 'Supprimer l’avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar mis à jour.';

  @override
  String get avatarRemovedMessage => 'Avatar supprimé.';

  @override
  String get avatarFileTooLarge => 'Le fichier de l’avatar est trop volumineux (5 Mo maximum).';

  @override
  String get avatarPickFailed => 'Impossible de charger l’image de l’avatar.';

  @override
  String get queueAddExpense => 'Ajouter une dépense';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'En attente : ajouter une dépense $amount';
  }

  @override
  String get queueDeleteExpense => 'Supprimer une dépense';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'En attente : supprimer la dépense n° $id';
  }

  @override
  String get queuePendingStatus => 'En attente';

  @override
  String get queueUpdateExpense => 'Mettre à jour les dépenses';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'En attente : mise à jour de la dépense n° $id';
  }

  @override
  String get queuedChange => 'Modification en attente';

  @override
  String queuedChangesTitle(Object count) {
    return 'Modifications en attente ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'En attente ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cycle $cycleNo, tirage $drawNo - $remaining restants';
  }

  @override
  String get receiptFallbackName => 'justificatif';

  @override
  String get receiptLinkInvalid => 'Le lien vers le reçu n\'est pas valide.';

  @override
  String get receiptOptionalLabel => 'Justificatif (facultatif)';

  @override
  String get recentPicksTitle => 'Derniers tirages au sort';

  @override
  String get reloadProfile => 'Actualiser le profil';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get removeCurrentReceipt => 'Supprimer le reçu actuel';

  @override
  String get repeatNewPasswordLabel => 'Confirmez le nouveau mot de passe';

  @override
  String get repeatPasswordLabel => 'Confirmez le mot de passe';

  @override
  String get requestFailedTryAgain => 'Échec de la demande. Veuillez réessayer.';

  @override
  String get retryAction => 'Réessayer';

  @override
  String get rowsLabel => 'Lignes';

  @override
  String get backToLoginAction => 'Retour à la connexion';

  @override
  String get saveAction => 'Enregistrer';

  @override
  String get saveCredentialsButton => 'Enregistrer les identifiants';

  @override
  String get saveProfileButton => 'Enregistrer le profil';

  @override
  String get sendResetLinkButton => 'Envoyer un lien de réinitialisation';

  @override
  String get searchUsersHint => 'Rechercher des personnes par nom ou par e-mail';

  @override
  String get selectedPeopleLabel => 'Personnes sélectionnées';

  @override
  String get noSearchMatches => 'Aucun utilisateur correspondant n’a été trouvé.';

  @override
  String get savingButton => 'Enregistrement en cours...';

  @override
  String get selectAtLeastTwoMembers => 'Sélectionnez au moins deux participants.';

  @override
  String get selectMembersHint => 'Sélectionner les participants';

  @override
  String selectedFileLabel(Object name) {
    return 'Sélectionné : $name';
  }

  @override
  String get selectedLabel => 'Sélectionné';

  @override
  String get selectedUserFallback => 'Utilisateur sélectionné';

  @override
  String get settings => 'Paramètres';

  @override
  String get settleUpAction => 'Régler les comptes';

  @override
  String get settledLabel => 'Soldé';

  @override
  String get settledStatus => 'Soldé';

  @override
  String get settlementActivitySubtitle => 'Virements liés à ce membre.';

  @override
  String get settlementActivityTitle => 'Activité de règlement';

  @override
  String get settlementCompletedTitle => 'Règlement effectué';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total confirmé';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Règlements: $count';
  }

  @override
  String get settlementImpactTitle => 'Impact sur le règlement';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Impact sur le règlement : $name';
  }

  @override
  String get settlementInProgress => 'Règlement en cours';

  @override
  String get settlementInProgressTitle => 'Règlement en cours';

  @override
  String get settlementLabel => 'Règlement';

  @override
  String get settlementOverviewArchivedSubtitle => 'Voyage archivé. Tous les règlements effectués.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Suivez les confirmations de règlement.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Aperçu des virements à effectuer à la fin du voyage.';

  @override
  String get settlementPreview => 'Aperçu du règlement';

  @override
  String get settlementPreviewTitle => 'Aperçu du règlement';

  @override
  String get settlementProgressTripArchived => 'Voyage archivé';

  @override
  String settlementWithId(Object id) {
    return 'Règlement n° $id';
  }

  @override
  String get settlements => 'Règlements';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Règlements déjà effectués.';

  @override
  String get settlementsDone => 'Règlements effectués';

  @override
  String get settlingStatus => 'Règlement';

  @override
  String get shareUnit => 'part';

  @override
  String get sharesLabel => 'Parts';

  @override
  String get sharesMustBePositiveIntegers => 'Le nombre de parts doit être un entier positif.';

  @override
  String sharesWithValue(Object value) {
    return 'Parts: $value';
  }

  @override
  String get showActiveTrips => 'Afficher les voyages en cours';

  @override
  String get signUpButton => 'S’inscrire';

  @override
  String get splitBreakdownSubtitle => 'Comment les dépenses sont-elles réparties ?';

  @override
  String get splitBreakdownTitle => 'Répartition détaillée';

  @override
  String get splitHintEqual => 'Répartir à parts égales entre les participants sélectionnés.';

  @override
  String get splitHintExact => 'Saisissez le montant exact pour chaque participant. La somme doit correspondre au total.';

  @override
  String get splitHintPercent => 'Saisissez un pourcentage pour chaque participant. La somme doit être égale à 100 %.';

  @override
  String get splitHintShares => 'Saisissez le nombre d’unités à partager (1, 2, 3…). Le coût est réparti proportionnellement.';

  @override
  String get splitLabel => 'Séparer';

  @override
  String splitLabelValue(Object value) {
    return 'Répartition : $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Répartition à parts égales ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Montants exacts ($target)';
  }

  @override
  String get splitModeLabel => 'Mode « Split »';

  @override
  String splitModePercent(Object target) {
    return 'Pourcentages ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Parts ($target)';
  }

  @override
  String get statusConfirmed => 'Confirmé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusSent => 'Envoyé';

  @override
  String get statusSuggested => 'Suggestion';

  @override
  String statusWithValue(Object status) {
    return 'Statut : $status';
  }

  @override
  String get suggestedTransferDirections => 'Sens des paiements suggérés';

  @override
  String get suggestedTransferFromExpense => 'Transfert suggéré à partir des dépenses';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count virements suggérés',
      one: '$count virement suggéré',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Lignes « payeur prévu » -> « bénéficiaire prévu ».';

  @override
  String get suggestedTransfersTitle => 'Transferts suggérés';

  @override
  String get summarySettledUp => 'Soldé';

  @override
  String get summaryYouAreOwed => 'On vous doit';

  @override
  String get summaryYouOwe => 'Vous devez';

  @override
  String get syncAction => 'Synchronisation';

  @override
  String get syncNowAction => 'Synchroniser maintenant';

  @override
  String get syncingStatus => 'Synchronisation';

  @override
  String get tapToViewDetails => 'Appuyez pour afficher les détails';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get themeModeDarkSubtitle => 'Noir doux (et non noir pur)';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeSystem => 'Système';

  @override
  String get themeModeSystemSubtitle => 'Utilisez l’apparence de l’appareil';

  @override
  String toDirection(Object name) {
    return 'À $name';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get travelerFallbackName => 'Voyageur';

  @override
  String get tripAlreadyClosed => 'Voyage déjà terminé.';

  @override
  String get tripArchivedReadOnly => 'Le voyage est archivé. Mode lecture seule.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Le voyage est clôturé. La modification des dépenses est désactivée.';

  @override
  String get tripClosedExpensesReadOnly => 'Le voyage est clôturé. Les dépenses sont en lecture seule.';

  @override
  String get tripClosedRandomDisabled => 'Le voyage est terminé. Le tirage au sort est désactivé.';

  @override
  String tripCreated(Object name) {
    return 'Voyage « $name » créé.';
  }

  @override
  String get tripFinished => 'Le voyage est terminé.';

  @override
  String get tripFinishedCompleteSettlements => 'Le voyage est terminé. Effectuez les règlements.';

  @override
  String get tripFinishedSettlementStarted => 'Le voyage est terminé. Le règlement a commencé.';

  @override
  String get tripFullySettledArchived => 'Voyage entièrement réglé et archivé.';

  @override
  String get tripNameHint => 'Voyage au ski en Autriche';

  @override
  String get tripNameLabel => 'Nom du voyage';

  @override
  String get tripNameLengthValidation => 'Le nom du voyage doit comporter au moins 2 caractères.';

  @override
  String get tripSnapshotTitle => 'Aperçu du voyage';

  @override
  String get tripTitleShort => 'Voyage';

  @override
  String tripStatusWithValue(Object status) {
    return 'Statut du voyage : $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Voyage n° $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Erreur inattendue lors du chargement du profil';

  @override
  String get unexpectedErrorLoadingTripData => 'Erreur inattendue lors du chargement des données du voyage';

  @override
  String get unexpectedErrorLoadingTrips => 'Erreur inattendue lors du chargement des voyages';

  @override
  String get unexpectedErrorSavingChanges => 'Erreur inattendue lors de l\'enregistrement des modifications';

  @override
  String get unexpectedErrorSavingCredentials => 'Erreur inattendue lors de l\'enregistrement des identifiants';

  @override
  String get unexpectedErrorUpdatingProfile => 'Erreur inattendue lors de la mise à jour du profil';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get unknownLabel => 'Inconnu';

  @override
  String get unreadLabel => 'Non lu';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mises à jour non lues',
      one: '$count mise à jour non lue',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Argument « itinéraire du voyage » manquant.';

  @override
  String userIdLabel(Object id) {
    return 'Identifiant utilisateur : $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Payé $paid  -  Dette $owes  -  Net $net';
  }

  @override
  String userWithId(Object id) {
    return 'Utilisateur $id';
  }

  @override
  String get valueLabel => 'Valeur';

  @override
  String get viewAllTrips => 'Afficher tous les voyages';

  @override
  String get viewByPersonTitle => 'Affichage par personne';

  @override
  String get whoOwesWhatSubtitle => 'Qui a payé et qui doit de l’argent.';

  @override
  String get whoOwesWhatTitle => 'Qui doit quoi ?';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Qui doit quoi : $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Lignes de dépenses contribuant à ce virement.';

  @override
  String get whyPaymentExistsTitle => 'Pourquoi ce paiement existe-t-il ?';

  @override
  String get youLabel => 'Vous';

  @override
  String get youSettledForExpense => 'Vous avez réglé votre part de cette dépense.';

  @override
  String youShouldPay(Object amount) {
    return 'Tu devrais payer. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Vous devriez recevoir $amount';
  }

  @override
  String get yourShare => 'Votre part';

  @override
  String get yourTrips => 'Vos voyages';

  @override
  String get homeYourActiveTrips => 'Vos voyages actifs';

  @override
  String get homeYourArchivedTrips => 'Vos voyages archivés';

  @override
  String get authIntroSplitSmarter => 'Partagez plus intelligemment.';

  @override
  String get authIntroTravelFree => 'Voyagez librement.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Suivez le partage des frais dans différentes devises et réglez les comptes instantanément – finis les « je te dois » gênants.';

  @override
  String get authIntroPlanTogether => 'Planifiez ensemble.';

  @override
  String get authIntroPayClearly => 'Payez clairement.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Créez des voyages en quelques secondes, ajoutez des amis et assurez la transparence de toutes les dépenses pour tout le monde.';

  @override
  String get authIntroSettleFast => 'Réglez rapidement.';

  @override
  String get authIntroStayFriends => 'Restons amis.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Des dîners partagés aux voyages complets, Splyto garantit des comptes équilibrés et sans stress.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Échec de la connexion Apple. Veuillez réessayer.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Échec de la connexion via Google. Veuillez réessayer.';

  @override
  String get authIntroCreateAccount => 'Créez votre compte.';

  @override
  String get authIntroChooseSign => 'Choisissez la manière dont vous souhaitez vous inscrire.';

  @override
  String get authIntroContinueGoogle => 'Continuer avec Google';

  @override
  String get authIntroContinueApple => 'Continuer avec Apple';

  @override
  String get authIntroBack => 'Retour';

  @override
  String get authIntroSplitSettled => 'Répartition effectuée';

  @override
  String get authIntroParis3Friends => 'Paris · 3 amis';

  @override
  String get authIntroGetStarted => 'Commencer';

  @override
  String get authIntroAlreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get authIntroSignIn => 'Se connecter';

  @override
  String get authIntroSignUpWithEmail => 'Inscrivez-vous par e-mail';

  @override
  String get authIntroOr => 'OU';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'La connexion via Google n’a pas renvoyé de jeton d’identification.';

  @override
  String get authAppleSignAvailableIosDevices => 'La connexion via Apple est disponible sur les appareils iOS.';

  @override
  String get authAppleSignNotAvailableDevice => 'La connexion Apple n’est pas disponible sur cet appareil.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'La connexion Apple n’a pas renvoyé de jeton d’identité.';

  @override
  String get authCancel => 'Annuler';

  @override
  String get authSendLink => 'Envoyer le lien';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'L\'adresse e-mail n\'est pas vérifiée. Saisissez votre adresse e-mail pour recevoir un lien de vérification.';

  @override
  String get authEmailNotVerified => 'Adresse e-mail non vérifiée';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Envoyer un lien de vérification à $email ?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Lien de vérification envoyé. Vérifiez votre messagerie.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Impossible d’envoyer le lien de vérification. Veuillez réessayer.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Un e-mail de vérification vous a été envoyé. Veuillez vérifier votre adresse e-mail avant de vous connecter.';

  @override
  String get authVerifyEmail => 'Vérifiez votre adresse e-mail';

  @override
  String get authEmailLabel => 'E-mail :';

  @override
  String get authClose => 'Fermer';

  @override
  String get authResendLink => 'Renvoyer le lien';

  @override
  String get profileAppSettingsSectionTitle => 'PARAMÈTRES DE L\'APPLICATION';

  @override
  String get profileEmailVerified => 'Vérifié';

  @override
  String get profileEmailNotVerified => 'Non vérifié';

  @override
  String get profileEmailSendVerification => 'Envoyer le lien';

  @override
  String get profileEmailVerificationSent => 'E-mail de vérification envoyé. Consultez votre boîte de réception.';

  @override
  String get profileAccountSectionTitle => 'COMPTE';

  @override
  String get profileAccountSettings => 'Paramètres du compte';

  @override
  String get profileChangePhoto => 'Modifier la photo de profil';

  @override
  String get profileAppearance => 'Présentation';

  @override
  String get profileThemeDisplayMode => 'Thème et mode d’affichage';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileDisplayLanguage => 'Langue d’affichage';

  @override
  String get profileNotificationsSectionHeading => 'NOTIFICATIONS';

  @override
  String get profileAppBanners => 'Bannières dans l’application';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Afficher de nouvelles bannières de notification dans l’application';

  @override
  String get profilePushNotificationsTitle => 'Notifications push';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Notifications sur le téléphone concernant les dépenses, les amis, les voyages et les règlements';

  @override
  String get profileSupportSectionHeading => 'ASSISTANCE';

  @override
  String get profileContactUs => 'Contactez-nous';

  @override
  String get profileReportBugSuggestion => 'Signaler un bug / Suggestion';

  @override
  String get profileRateSplyto => 'Évaluez Splyto';

  @override
  String get profileLeaveStoreRating => 'Laisser un avis sur le magasin';

  @override
  String get profileSecuritySectionHeading => 'SÉCURITÉ';

  @override
  String get profileAccountAndSecurity => 'Compte et sécurité';

  @override
  String get profileHelpTitle => 'Aide';

  @override
  String get profileChangePassword => 'Modifier le mot de passe';

  @override
  String get profileUpdateAccountPassword => 'Mettre à jour le mot de passe du compte';

  @override
  String get profileDangerZoneSectionHeading => 'ZONE DE DANGER';

  @override
  String get profileManageAccountAccess => 'Gérer l’accès au compte';

  @override
  String get profileMadeWithLabel => 'Réalisé avec';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'La fonctionnalité d’évaluation sera intégrée lors de la prochaine étape.';

  @override
  String get profileFailedSaveNotificationSettings => 'Échec de l\'enregistrement des paramètres de notification.';

  @override
  String get profilePushNotificationsSectionTitle => 'NOTIFICATIONS PUSH';

  @override
  String get profileInAppBannersSectionTitle => 'BANNERES DANS L\'APPLICATION';

  @override
  String get profileInAppTripMemberAddedTitle => 'Membre ajouté au voyage';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Rappel automatique de règlement';

  @override
  String get profileExpenseUpdates => 'Mises à jour des dépenses';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Ajout de bannières « Dépenses » dans l’application';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Notifications de dépenses ajoutées sur le téléphone';

  @override
  String get profileFriendInvites => 'Invitation d’un ami';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Bannières de demande d’amitié et de réponse au sein de l’application';

  @override
  String get profileFriendRequestResponseNotifications => 'Notifications de demande d’amitié et de réponse';

  @override
  String get profileTripUpdates => 'Mises à jour du voyage';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Bannières relatives au cycle de vie du voyage et au statut des participants dans l’application';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Cycle de vie du voyage et changements de statut des participants';

  @override
  String get profileSettlementUpdates => 'Mises à jour concernant le règlement';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Bannières « Envoyé » et « Paiement confirmé » affichées dans l’application';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Mises à jour des paiements marquées comme « envoyées » et « confirmées »';

  @override
  String get profileRemoveImage => 'Supprimer l’image';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Ajoutez des détails ou joignez une capture d’écran avant l’envoi';

  @override
  String get profileCouldNotOpenWebsite => 'Impossible d’ouvrir le site web.';

  @override
  String get profileOpenWebsiteQuestion => 'Ouvrir le site web ?';

  @override
  String get profileOpenPortfolioAction => 'Accéder à portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Ce format d’image n’est pas pris en charge sur cet appareil. Veuillez choisir JPG ou PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Une adresse e-mail de compte valide est requise pour modifier votre mot de passe. Contactez le service d’assistance si votre adresse e-mail est manquante ou incorrecte.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Un lien de suppression vous a été envoyé par e-mail.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Impossible d’envoyer le lien de suppression. Veuillez réessayer.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Saisissez votre mot de passe actuel pour modifier votre adresse e-mail.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Une confirmation a été envoyée à la nouvelle adresse e-mail. Une notification de sécurité a été envoyée à votre adresse e-mail actuelle.';

  @override
  String get profileEditOverviewCurrency => 'Aperçu des devises';

  @override
  String get profileEditPaymentMethod => 'Mode de paiement';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Virement bancaire, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Saisissez votre mot de passe (facultatif pour Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Envoyer le lien de suppression par e-mail';

  @override
  String get profileEditBackProfile => 'Retour au profil';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Indiquez une adresse e-mail valide dans votre profil avant de modifier votre mot de passe.';

  @override
  String get profileEditPasswordUpdated => 'Mot de passe mis à jour.';

  @override
  String get profileEditFailedUpdatePassword => 'Échec de la mise à jour du mot de passe.';

  @override
  String profileEditEmail(Object email) {
    return 'Compte : $email';
  }

  @override
  String get profileEditPrimary => 'Principal';

  @override
  String get profileEditSearchCurrency => 'Rechercher une devise';

  @override
  String get profileEditNoCurrenciesFound => 'Aucune devise trouvée';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Les totaux de l’aperçu sont convertis dans cette devise.';

  @override
  String get profileEditPaymentInfoUpdated => 'Informations de paiement mises à jour.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Impossible d’enregistrer les informations de paiement. Veuillez réessayer.';

  @override
  String get profileEditCurrentPassword => 'Mot de passe actuel';

  @override
  String get profileEditBankTransferIbanSwift => 'Virement bancaire (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'Lien paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Choisissez un mode de paiement';

  @override
  String get profileEditTapChange => 'Appuyez pour modifier';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Pour les virements au Royaume-Uni, le code guichet doit comporter 6 chiffres et le numéro de compte 8 chiffres.';

  @override
  String get profileEditPaymentInfo => 'Informations de paiement';

  @override
  String get profileEditSaveDetails => 'Enregistrer les détails';

  @override
  String get profileEditBankRegion => 'Zone bancaire';

  @override
  String get profileEditEurope => 'Europe';

  @override
  String get profileEditSortCode => 'Code guichet';

  @override
  String get profileEditExample112233 => 'Exemple : 112233';

  @override
  String get profileEditNumber => 'Numéro de compte';

  @override
  String get profileEdit8Digits => '8 chiffres';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Pour les virements nationaux au Royaume-Uni, utilisez le code guichet + le numéro de compte.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Exemple : LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 ou 11 caractères';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Le nom du titulaire du compte est tiré du nom complet figurant dans le profil.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username ou nom d’utilisateur';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Royaume-Uni';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Modifier l’avatar';

  @override
  String get imageCropperAdjustTripImage => 'Ajuster l’image du voyage';

  @override
  String get imageCropEditAction => 'Modifier le cadrage';

  @override
  String get imageCropZoomIn => 'Zoomer';

  @override
  String get imageCropZoomOut => 'Dézoomer';

  @override
  String get imageCropZoomOnly => 'Seule la version recadrée de cette photo a été enregistrée : vous pouvez uniquement zoomer.';

  @override
  String get imageCropLoadFailed => 'Impossible d\'ouvrir cette photo.';

  @override
  String get imageCropSaveFailed => 'Impossible d\'enregistrer le nouveau cadrage. Réessayez.';

  @override
  String get imageCropChanged => 'Cette photo a été modifiée entre-temps. Fermez cet écran et rouvrez-le.';

  @override
  String get copyAction => 'Copier';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Livre sterling';

  @override
  String get currencyNameChf => 'Franc suisse';

  @override
  String get currencyNameNok => 'Couronne norvégienne';

  @override
  String get currencyNameSek => 'Couronne suédoise';

  @override
  String get currencyNameDkk => 'Couronne danoise';

  @override
  String get currencyNamePln => 'Zloty polonais';

  @override
  String get currencyNameCzk => 'Couronne tchèque';

  @override
  String get currencyNameHuf => 'Forint hongrois';

  @override
  String get currencyNameRon => 'Leu roumain';

  @override
  String get currencyNameBgn => 'Lev bulgare';

  @override
  String get currencyNameIsk => 'Couronne islandaise';

  @override
  String get currencyNameAll => 'Lek albanais';

  @override
  String get currencyNameBam => 'Mark de Bosnie-Herzégovine';

  @override
  String get currencyNameByn => 'Rouble biélorusse';

  @override
  String get currencyNameMdl => 'Leu moldave';

  @override
  String get currencyNameMkd => 'Denar macédonien';

  @override
  String get currencyNameRsd => 'Dinar serbe';

  @override
  String get currencyNameUah => 'Hryvnia ukrainienne';

  @override
  String get currencyNameGel => 'Lari géorgien';

  @override
  String get currencyNameTry => 'Lire turque';

  @override
  String get currencyNameUsd => 'Dollar américain';

  @override
  String get currencyNameJpy => 'Yen japonais';

  @override
  String get currencyNameCny => 'Yuan chinois';

  @override
  String get currencyNameCad => 'Dollar canadien';

  @override
  String get currencyNameAud => 'Dollar australien';

  @override
  String get currencyNameRub => 'Rouble russe';

  @override
  String get currencyNameMxn => 'Peso mexicain';

  @override
  String get currencyNameBrl => 'Réal brésilien';

  @override
  String get currencyNameArs => 'Peso argentin';

  @override
  String get currencyNameClp => 'Peso chilien';

  @override
  String get currencyNameCop => 'Peso colombien';

  @override
  String get currencyNamePen => 'Sol péruvien';

  @override
  String get currencyNameUyu => 'Peso uruguayen';

  @override
  String get currencyNameBob => 'Boliviano bolivien';

  @override
  String get currencyNamePyg => 'Guaraní paraguayen';

  @override
  String get currencyNameCrc => 'Colón costaricain';

  @override
  String get currencyNameDop => 'Peso dominicain';

  @override
  String get currencyNameGtq => 'Quetzal guatémaltèque';

  @override
  String get currencyNamePab => 'Balboa panaméen';

  @override
  String get currencyNameHnl => 'Lempira hondurien';

  @override
  String get currencyNameNio => 'Córdoba oro nicaraguayen';

  @override
  String get currencyNameJmd => 'Dollar jamaïcain';

  @override
  String get currencyNameBbd => 'Dollar barbadien';

  @override
  String get currencyNameBsd => 'Dollar bahaméen';

  @override
  String get currencyNameTtd => 'Dollar de Trinité-et-Tobago';

  @override
  String get currencyNameXcd => 'Dollar des Caraïbes orientales';

  @override
  String get currencyNameBzd => 'Dollar bélizéen';

  @override
  String get currencyNameAwg => 'Florin arubais';

  @override
  String get currencyNameBmd => 'Dollar bermudien';

  @override
  String get currencyNameKyd => 'Dollar des îles Caïmans';

  @override
  String get currencyNameKrw => 'Won sud-coréen';

  @override
  String get currencyNameInr => 'Roupie indienne';

  @override
  String get currencyNameThb => 'Baht thaïlandais';

  @override
  String get currencyNameVnd => 'Dông vietnamien';

  @override
  String get currencyNameIdr => 'Roupie indonésienne';

  @override
  String get currencyNameMyr => 'Ringgit malais';

  @override
  String get currencyNameSgd => 'Dollar de Singapour';

  @override
  String get currencyNamePhp => 'Peso philippin';

  @override
  String get currencyNameHkd => 'Dollar de Hong Kong';

  @override
  String get currencyNameTwd => 'Nouveau dollar taïwanais';

  @override
  String get currencyNameLkr => 'Roupie srilankaise';

  @override
  String get currencyNameNpr => 'Roupie népalaise';

  @override
  String get currencyNameBdt => 'Taka bangladeshi';

  @override
  String get currencyNamePkr => 'Roupie pakistanaise';

  @override
  String get currencyNameKhr => 'Riel cambodgien';

  @override
  String get currencyNameLak => 'Kip laotien';

  @override
  String get currencyNameMmk => 'Kyat myanmarais';

  @override
  String get currencyNameMnt => 'Tugrik mongol';

  @override
  String get currencyNameMop => 'Pataca macanaise';

  @override
  String get currencyNameBnd => 'Dollar brunéien';

  @override
  String get currencyNameMvr => 'Rufiyaa maldivienne';

  @override
  String get currencyNameBtn => 'Ngultrum bouthanais';

  @override
  String get currencyNameKzt => 'Tenge kazakh';

  @override
  String get currencyNameUzs => 'Sum ouzbek';

  @override
  String get currencyNameKgs => 'Som kirghize';

  @override
  String get currencyNameTjs => 'Somoni tadjik';

  @override
  String get currencyNameAzn => 'Manat azéri';

  @override
  String get currencyNameAmd => 'Dram arménien';

  @override
  String get currencyNameAed => 'Dirham des Émirats arabes unis';

  @override
  String get currencyNameSar => 'Riyal saoudien';

  @override
  String get currencyNameQar => 'Riyal qatari';

  @override
  String get currencyNameOmr => 'Riyal omanais';

  @override
  String get currencyNameKwd => 'Dinar koweïtien';

  @override
  String get currencyNameBhd => 'Dinar bahreïni';

  @override
  String get currencyNameJod => 'Dinar jordanien';

  @override
  String get currencyNameIls => 'Nouveau shekel israélien';

  @override
  String get currencyNameLbp => 'Livre libanaise';

  @override
  String get currencyNameIqd => 'Dinar irakien';

  @override
  String get currencyNameZar => 'Rand sud-africain';

  @override
  String get currencyNameEgp => 'Livre égyptienne';

  @override
  String get currencyNameMad => 'Dirham marocain';

  @override
  String get currencyNameTnd => 'Dinar tunisien';

  @override
  String get currencyNameDzd => 'Dinar algérien';

  @override
  String get currencyNameKes => 'Shilling kényan';

  @override
  String get currencyNameTzs => 'Shilling tanzanien';

  @override
  String get currencyNameUgx => 'Shilling ougandais';

  @override
  String get currencyNameRwf => 'Franc rwandais';

  @override
  String get currencyNameEtb => 'Birr éthiopien';

  @override
  String get currencyNameGhs => 'Cédi ghanéen';

  @override
  String get currencyNameNgn => 'Naira nigérian';

  @override
  String get currencyNameXof => 'Franc CFA (BCEAO)';

  @override
  String get currencyNameXaf => 'Franc CFA (BEAC)';

  @override
  String get currencyNameMur => 'Roupie mauricienne';

  @override
  String get currencyNameScr => 'Roupie des Seychelles';

  @override
  String get currencyNameNad => 'Dollar namibien';

  @override
  String get currencyNameBwp => 'Pula botswanais';

  @override
  String get currencyNameZmw => 'Kwacha zambien';

  @override
  String get currencyNameMzn => 'Metical mozambicain';

  @override
  String get currencyNameAoa => 'Kwanza angolais';

  @override
  String get currencyNameMga => 'Ariary malgache';

  @override
  String get currencyNameCve => 'Escudo capverdien';

  @override
  String get currencyNameGmd => 'Dalasi gambien';

  @override
  String get currencyNameNzd => 'Dollar néo-zélandais';

  @override
  String get currencyNameFjd => 'Dollar fidjien';

  @override
  String get currencyNameXpf => 'Franc CFP';

  @override
  String get currencyNameWst => 'Tala samoan';

  @override
  String get currencyNameVuv => 'Vatu vanuatuan';

  @override
  String get currencyNameTop => 'Pa’anga tongan';

  @override
  String get currencyNamePgk => 'Kina papouan-néo-guinéen';

  @override
  String get expenseCategoryFood => 'Repas';

  @override
  String get expenseCategoryGroceries => 'Courses alimentaires';

  @override
  String get expenseCategoryFuel => 'Carburant';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryAccommodation => 'Hébergement';

  @override
  String get expenseCategoryActivities => 'Activités';

  @override
  String get expenseCategoryTickets => 'Billets';

  @override
  String get expenseCategoryShopping => 'Shopping';

  @override
  String get expenseCategoryParty => 'Fête';

  @override
  String get expenseCategoryParking => 'Stationnement';

  @override
  String get expenseCategoryOther => 'Autre';

  @override
  String get shellTripAlreadyInListOpened => 'Ce voyage figure déjà dans votre liste. Nous l’avons ouvert pour vous.';

  @override
  String get shellJoinedTripFromInviteLink => 'A rejoint le voyage via un lien d’invitation.';

  @override
  String get shellFailedToOpenInviteLink => 'Impossible d’ouvrir le lien d’invitation.';

  @override
  String get shellFailedToOpenFriendLink => 'Impossible d’ouvrir le lien d’ami.';

  @override
  String get shellTripInviteTitle => 'Invitation au voyage';

  @override
  String get shellNoAction => 'Non';

  @override
  String get shellYesAction => 'Oui';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Seul le créateur du voyage peut supprimer ce voyage.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Seuls les voyages actifs peuvent être supprimés.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Supprimer « $tripLabel » ? Cela n’est autorisé qu’avant l’ajout de toute dépense.';
  }

  @override
  String get shellTripDeleted => 'Voyage supprimé.';

  @override
  String get shellFailedToDeleteTrip => 'Échec de la suppression du voyage.';

  @override
  String get shellFailedToLoadNotifications => 'Échec du chargement des notifications.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nouvelle notification : $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Échec de la mise à jour des notifications.';

  @override
  String get shellMarkAllAsReadAction => 'Marquer tout comme lu';

  @override
  String get shellNewSection => 'Nouveau';

  @override
  String get shellEarlierSection => 'Précédent';

  @override
  String get shellShowMoreEarlierAction => 'Afficher plus d\'informations précédentes';

  @override
  String get shellLoadingMore => 'Chargement en cours...';

  @override
  String get shellLoadMoreNotificationsAction => 'Afficher plus de notifications';

  @override
  String get shellTripNoLongerAvailable => 'Ce voyage n’est plus disponible.';

  @override
  String get shellFailedToOpenTrip => 'Échec de l’ouverture du voyage.';

  @override
  String get shellYesterday => 'Hier';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Vous êtes déjà membre de « $tripName ». Ouvrir ce voyage maintenant ?\n\nInvité par : $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Souhaitez-vous rejoindre le voyage « $tripName » ?\n\nInvité par : $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Image sélectionnée : $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Image du voyage déjà définie.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Le voyage a été créé, mais le téléchargement de l’image a échoué.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Voyage créé, mais échec du téléchargement de l’image : $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Rejoindre un voyage via une invitation';

  @override
  String get tripsTotalTrips => 'Nombre total de voyages';

  @override
  String get tripsTotalSpent => 'Total dépensé';

  @override
  String get tripsMixedCurrencies => 'Devises mixtes';

  @override
  String get tripsShowActive => 'Afficher les autorisations actives';

  @override
  String get tripsSeeAll => 'Tout afficher';

  @override
  String get tripsGridView => 'Affichage en grille';

  @override
  String get tripsListView => 'Affichage sous forme de liste';

  @override
  String get tripsAddNewTrip => 'Ajouter un nouveau voyage';

  @override
  String get tripsLoadMore => 'Charger la suite';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Supprimer « $arg1 » ? Cela n’est autorisé qu’avant l’ajout de toute dépense.';
  }

  @override
  String get tripsTripDates => 'Dates du voyage';

  @override
  String get tripsFrom => 'De';

  @override
  String get tripsSelectDate => 'Sélectionnez une date';

  @override
  String get tripsTo => 'À';

  @override
  String get tripsMainCurrency => 'Devise principale';

  @override
  String get tripsSelectStartDate => 'Veuillez choisir la date de début du voyage.';

  @override
  String get tripsEndDateOptional => 'Facultatif';

  @override
  String get tripsClearEndDate => 'Supprimer la date de fin';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'La date de fin du voyage doit être égale ou postérieure à la date de début.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Le format de la période du voyage n\'est pas valide. Veuillez sélectionner à nouveau les dates.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Vous êtes déjà membre de ce voyage.';

  @override
  String get tripsJoinedTripSuccessfully => 'Vous avez rejoint le voyage avec succès.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Échec de la participation au voyage à partir de l’invitation.';

  @override
  String get tripsJoinTrip => 'Rejoindre un voyage';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Collez le lien d’invitation ou le jeton d’invitation.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Saisissez un lien d’invitation ou un jeton valide.';

  @override
  String get tripsClipboardIsEmpty => 'Le presse-papiers est vide.';

  @override
  String get tripsPaste => 'Coller';

  @override
  String get tripsJoin => 'Rejoindre';

  @override
  String get workspaceTripMembers => 'Membres du voyage';

  @override
  String get workspaceFailedToLoadFriends => 'Échec du chargement des amis.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Échec de la génération du lien d’invitation.';

  @override
  String get workspaceInviteLink => 'Lien d’invitation';

  @override
  String get workspaceGeneratingInviteLink => 'Génération du lien d’invitation…';

  @override
  String get workspaceInviteLinkUnavailable => 'Lien d’invitation indisponible.';

  @override
  String get workspaceCopyInviteLink => 'Copier le lien d’invitation';

  @override
  String get workspaceInviteLinkCopied => 'Lien d’invitation copié.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Expiration : $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Aucun ami disponible. Ajoutez d’abord des amis.';

  @override
  String get workspaceSettle => 'Régler';

  @override
  String get workspaceOwesToTheGroup => 'Dette envers le groupe';

  @override
  String get workspaceGetsBackFromGroup => 'Doit recevoir de l’argent du groupe';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Affichage des 4 premiers par écart de solde.';

  @override
  String get workspaceOpenFlow => 'Détails';

  @override
  String get workspaceFriend => 'Ami';

  @override
  String get workspaceSettlementTransfer => 'Transfert de règlement';

  @override
  String get workspaceCompleted => 'Terminé';

  @override
  String get workspaceWaitingForConfirmation => 'En attente de confirmation';

  @override
  String get workspaceWaitingForPayment => 'En attente de paiement';

  @override
  String get workspaceActionNeeded => 'Action requise';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Paiements à marquer comme envoyés : $arg1 ; à confirmer comme reçus : $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Prêt à régler';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Tous les participants sont prêts. Vous pouvez lancer les règlements.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'En attente que tout le monde se déclare prêt.';

  @override
  String get workspaceIMReady => 'Je suis prêt';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Vérifiez que vous avez bien ajouté toutes vos dépenses.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Le bouton « Terminer » se déverrouille une fois que tout le monde s’est déclaré prêt.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Doit recevoir de l’argent du groupe';

  @override
  String get workspaceSettledWithTheGroup => 'Règlement effectué avec le groupe';

  @override
  String get workspaceTotalPaid => 'Total payé';

  @override
  String get workspaceTotalOwes => 'Total dû';

  @override
  String get workspaceTransactionHistory => 'Historique des transactions';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Aucune transaction n’a encore été effectuée pour ce membre.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Règlements : $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Tous les participants doivent se déclarer « prêts » avant de lancer les règlements.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Vous vous êtes déclaré prêt à régler.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'La mention « Prêt à régler » a été supprimée.';

  @override
  String get workspaceReminderSent => 'Rappel envoyé.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Lien d’invitation ou ajout depuis la liste d’amis';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Seul le créateur du voyage peut modifier ce voyage.';

  @override
  String get workspaceTripUpdated => 'Voyage mis à jour.';

  @override
  String get workspaceFailedToUpdateTrip => 'Échec de la mise à jour du voyage.';

  @override
  String get workspaceNoMembersSelectedYet => 'Aucun membre n’a encore été sélectionné.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Pas d’Internet. La dépense sera enregistrée sans image de reçu.';

  @override
  String get workspaceRandomPicker => 'Tirage au sort';

  @override
  String get workspaceCurrency => 'Devise';

  @override
  String get workspaceCategory => 'Catégorie';

  @override
  String get workspaceCustomCategory => 'Catégorie personnalisée';

  @override
  String get workspaceCategoryName => 'Nom de la catégorie';

  @override
  String get workspaceApartmentRentParkingEtc => 'Loyer d’appartement, parking, etc.';

  @override
  String get workspaceEnterACustomCategory => 'Saisissez une catégorie personnalisée.';

  @override
  String get workspacePickAnExpenseCategory => 'Choisissez une catégorie de dépenses.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'La catégorie doit comporter au moins 2 caractères.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'La catégorie doit comporter au maximum 64 caractères.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'La répartition en pourcentage doit totaliser 100 %.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Le nombre de parts doit être supérieur à 0 pour chaque participant.';

  @override
  String get workspaceTotalAmount => 'Montant total';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Coût total';

  @override
  String workspaceStarted(Object arg1) {
    return 'Lancé $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Terminé $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Voyage archivé';

  @override
  String get workspaceActiveTrip => 'Voyage en cours';

  @override
  String get workspaceMemberProfile => 'Profil du membre';

  @override
  String get workspaceTripOwner => 'Organisateur du voyage';

  @override
  String get workspaceMember => 'Membre';

  @override
  String get workspaceReadyForSettlement => 'Prêt pour le règlement';

  @override
  String get workspaceNotReadyForSettlement => 'Pas encore prêt pour le règlement';

  @override
  String get workspaceBankDetails => 'Coordonnées bancaires';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'Les coordonnées IBAN et les détails de paiement seront ajoutés ici lors d’une prochaine mise à jour.';

  @override
  String get workspacePaymentDetails => 'Détails du paiement';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Ce membre n’a pas encore ajouté ses coordonnées bancaires.';

  @override
  String get workspaceBankTransfer => 'Virement bancaire';

  @override
  String get workspaceHolder => 'Titulaire';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Impossible d’ouvrir le lien de paiement.';

  @override
  String get workspaceTripActivity => 'Activité du voyage';

  @override
  String get workspacePaidExpenses => 'Dépenses payées';

  @override
  String get workspacePaidTotal => 'Montant total payé';

  @override
  String get workspaceInvolvedIn => 'Impliqué dans';

  @override
  String get workspaceCurrentTrip => 'Voyage en cours';

  @override
  String get workspaceCommonTrips => 'Voyages en commun';

  @override
  String get workspaceLoadingCommonTrips => 'Chargement des voyages en commun…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Aucun voyage en commun pour le moment.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Impossible de charger tous les voyages en commun. Le voyage actuel est affiché.';

  @override
  String get workspaceMembers => 'membres';

  @override
  String get workspaceExpense => 'Dépenses';

  @override
  String get workspacePaid => 'payé';

  @override
  String get workspaceLoadingMoreExpenses => 'Chargement de dépenses supplémentaires…';

  @override
  String get workspaceScrollDownToLoadMore => 'Faites défiler vers le bas pour afficher davantage de contenu';

  @override
  String get workspaceTripFinished => 'Voyage terminé';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Les règlements sont débloqués pour ce voyage.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Terminez le voyage pour lancer les règlements.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 a marqué le virement comme envoyé.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'En attente que $arg1 marque le paiement comme effectué.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 a confirmé la réception du paiement.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'En attente de la confirmation d’$arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Tous les règlements liés au voyage sont entièrement finalisés.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'État final une fois tous les virements confirmés.';

  @override
  String get workspaceSettlementFlow => 'Flux de règlement';

  @override
  String get workspaceActions => 'Actions';

  @override
  String get workspaceQuickPay => 'Paiement rapide';

  @override
  String get workspacePayWithRevolut => 'Payer avec Revolut';

  @override
  String get workspacePayWithPaypal => 'Payer avec PayPal';

  @override
  String get workspacePayWithWise => 'Payer avec Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Le virement est confirmé.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'En attente que l’autre membre effectue l’étape suivante.';

  @override
  String get workspaceSendReminder => 'Envoyer un rappel';

  @override
  String get workspaceInProgress => 'En cours';

  @override
  String get workspaceTimeUnknown => 'Heure inconnue';

  @override
  String get workspaceRemind => 'Rappel';

  @override
  String get workspaceYourPosition => 'Votre position';

  @override
  String get workspaceRecentActivity => 'Activité récente';

  @override
  String get workspaceNoRecentActivityYet => 'Aucune activité récente pour le moment.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Ajoutez au moins un participant pour commencer à partager les dépenses.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Indiquez que vous êtes prêt à régler après avoir ajouté toutes vos dépenses.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Membres pas encore prêts : $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Tous les participants sont prêts. Vous pouvez terminer le voyage et lancer les règlements.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Tous les participants sont prêts. En attente que l’organisateur du voyage lance les règlements.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Règlement en cours : $arg1 / $arg2 confirmé.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Aucune action en attente. Ce voyage est réglé.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Aucune action n’est requise pour le moment.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Vous devriez recevoir $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Vous devez payer $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Vous êtes actuellement inscrit à ce voyage.';

  @override
  String get workspaceUnknownTime => 'Heure inconnue';

  @override
  String get workspaceJustNow => 'À l’instant même';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'Il y a $arg1 min';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'Il y a $arg1 h';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'Il y a $arg1 j';
  }

  @override
  String get friendsRemoveFriend => 'Supprimer un ami';

  @override
  String get friendsRemoveThisFriend => 'Supprimer cet ami ?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 sera supprimé de votre liste d’amis. Vous pourrez l’ajouter à nouveau ultérieurement.';
  }

  @override
  String get friendsContinue => 'Continuer';

  @override
  String get friendsFriendRemoved => 'Ami supprimé.';

  @override
  String get friendsCouldNotRemoveFriend => 'Impossible de supprimer un ami.';

  @override
  String get friendsFriendProfile => 'Profil d’ami';

  @override
  String get friendsMoreActions => 'Plus d’actions';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Cet ami n’a pas encore ajouté ses coordonnées bancaires.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Impossible de charger les voyages en commun pour le moment.';

  @override
  String get friendsFinished => 'Terminé';

  @override
  String friendsTrip(Object arg1) {
    return 'Voyage n° $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Membres: $arg1';
  }

  @override
  String get friendsNoDate => 'Pas de date';

  @override
  String get friendsIncomingRequests => 'DEMANDES ENCOURANTES';

  @override
  String get friendsSentInvites => 'INVITATIONS ENVOYÉES';

  @override
  String get friendsMyFriends => 'MES AMIS';

  @override
  String get friendsRequests => 'Demandes';

  @override
  String get friendsIncoming => 'Messages entrants';

  @override
  String get friendsIncomingRequestSubtitle => 'souhaite devenir ami';

  @override
  String get friendsOutgoingInviteSubtitle => 'Invitation envoyée';

  @override
  String get friendsNoPendingActivity => 'Pas de demandes d’ajout à la liste d’amis';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Invitation envoyée à $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Aucune demande entrante';

  @override
  String get friendsDecline => 'Refuser';

  @override
  String get friendsAccept => 'Accepter';

  @override
  String get friendsNoSentInvites => 'Aucune invitation envoyée';

  @override
  String get friendsNoFriendsYet => 'Pas encore d’amis';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Faites défiler vers le bas pour afficher davantage d’amis.';

  @override
  String get friendsUser => 'Utilisateur';

  @override
  String get friendsSearchUsers => 'Rechercher des utilisateurs';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Rechercher par nom ou par e-mail et envoyer une invitation';

  @override
  String get friendsScanQr => 'Scanner le QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Scannez un autre utilisateur pour l’ajouter comme ami';

  @override
  String get friendsMyQr => 'Mon QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Afficher ou partager votre code QR';

  @override
  String get friendsScanFriendQrTitle => 'Scanner le QR Code d’un ami';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Placez le code QR de votre ami à l’intérieur du cadre';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Maintenez le QR code dans le cadre';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Ajouter $arg1 comme ami ?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 recevra votre demande d’ami.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Accepter la demande d’ami d’$arg1 ?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Scannez ce QR ou partagez le lien pour m\'ajouter sur Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Ajoute-moi sur Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Lien d’ami Splyto';

  @override
  String get shareAction => 'Partager';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'Le code QR n’est pas un code d’ami valide.';

  @override
  String get friendsYouCannotAddYourself => 'Vous ne pouvez pas vous ajouter vous-même.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Cet utilisateur figure déjà dans votre liste d’amis.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'L\'invitation à cet utilisateur a déjà été envoyée.';

  @override
  String get friendsFriendRequestProcessed => 'Demande d’amitié traitée.';

  @override
  String get friendsFailedToProcessFriendQr => 'Échec du traitement du QR code d’un ami.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Impossible de charger votre profil utilisateur.';

  @override
  String get friendsMyProfile => 'Mon profil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Erreur inattendue lors du chargement des amis.';

  @override
  String get friendsFriendAdded => 'Ami ajouté.';

  @override
  String get friendsRequestDeclined => 'Demande refusée.';

  @override
  String get friendsFailedToUpdateRequest => 'Échec de la mise à jour de la demande.';

  @override
  String get friendsCancelInvite => 'Annuler l’invitation';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Annuler l\'invitation adressée à $arg1 ?';
  }

  @override
  String get friendsKeep => 'Conserver';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Invitation à $arg1 annulée.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Échec de l\'annulation de l\'invitation.';

  @override
  String get analyticsOther => 'Autres';

  @override
  String get analyticsSelectATripForAnalytics => 'Sélectionnez un voyage pour l’analyse';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Membres: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Dépenses quotidiennes';

  @override
  String get analyticsMyDaily => 'Mes dépenses quotidiennes';

  @override
  String get analyticsGroupDaily => 'Dépenses quotidiennes du groupe';

  @override
  String get analyticsByMember => 'Par membre';

  @override
  String get analyticsShowLess => 'Afficher moins';

  @override
  String get analyticsByCategory => 'Par catégorie';

  @override
  String get analyticsQuickInsights => 'Aperçu rapide';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Dépense la plus importante : $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Meilleur dépensier : $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Jour le plus fréquenté du groupe : $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Pas de dates';

  @override
  String get friendsSearchFailedTryAgain => 'Échec de la recherche. Veuillez réessayer.';

  @override
  String get friendsFailedToSendInvite => 'Échec de l\'envoi de l\'invitation.';

  @override
  String get friendsAddFriend => 'Ajouter un ami';

  @override
  String get friendsSearchByNameOrEmail => 'Recherche par nom ou par e-mail';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Tapez au moins 2 caractères pour lancer la recherche.';

  @override
  String get friendsNoUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get friendsInviteAction => 'Inviter';

  @override
  String get workspacePaidForGroup => 'Payant pour les groupes';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Payé pour le groupe • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Partage des frais';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Partage des frais • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Nom du titulaire copié.';

  @override
  String get paymentIbanCopied => 'IBAN copié.';

  @override
  String get paymentSwiftCopied => 'SWIFT copié.';

  @override
  String get paymentRevtagCopied => 'Revtag copié.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Impossible de copier dans le presse-papiers.';

  @override
  String get paymentCopied => 'Copié.';

  @override
  String get paymentRequestAction => 'Demander un paiement';

  @override
  String get paymentRecordAction => 'Enregistrer un paiement';

  @override
  String get paymentRequestSheetTitle => 'Demander un paiement';

  @override
  String get paymentRecordSheetTitle => 'Enregistrer un paiement';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Demandez à $arg1 de vous régler la somme qu’il vous doit actuellement.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Utilisez cette fonction après avoir payé $arg1 en dehors de Splyto. La personne confirmera la réception du paiement.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return '$arg1 maximum';
  }

  @override
  String get paymentNoteHint => 'Virement bancaire, Revolut, espèces…';

  @override
  String get paymentAmountPositiveError => 'Le montant doit être supérieur à zéro.';

  @override
  String get paymentAmountTooHighError => 'Le montant ne peut pas être supérieur au solde restant dû.';

  @override
  String get paymentRequestCreated => 'Demande de paiement envoyée.';

  @override
  String get paymentRecordedWaiting => 'Paiement enregistré. En attente de confirmation.';

  @override
  String get paymentConfirmTitle => 'Confirmer le paiement';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Confirmez que vous avez bien reçu $arg1 de la part de $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Paiement confirmé.';

  @override
  String get paymentCancelRecordTitle => 'Annuler l\'enregistrement d\'un paiement';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Annuler l’enregistrement de votre paiement de $arg1 à $arg2 ?';
  }

  @override
  String get paymentRecordCancelled => 'Enregistrement du paiement annulé.';

  @override
  String get paymentNotReceivedTitle => 'Paiement non reçu';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Marquer le paiement $arg1 provenant de $arg2 comme non reçu ?';
  }

  @override
  String get paymentMarkedNotReceived => 'Paiement marqué comme non reçu.';

  @override
  String get paymentActivityTitle => 'Activité de paiement';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Demandes de paiement en cours : $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Paiements en attente de confirmation : $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Paiements enregistrés';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 a demandé un paiement à $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 a payé $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Paiement demandé';

  @override
  String get paymentAwaitingConfirmationStatus => 'En attente de confirmation';

  @override
  String get paymentReviewRequestAction => 'Demande de révision';

  @override
  String get paymentViewDetailsAction => 'Détails du paiement';

  @override
  String get paymentMarkPaidAction => 'J\'ai payé';

  @override
  String get paymentDeclineAction => 'Refuser';

  @override
  String get paymentRequestReviewTitle => 'Demande de paiement';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 vous a demandé $arg2. Effectuez le paiement en dehors de Splyto, puis marquez-le comme payé.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Marquer la demande comme payée ?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Ne confirmez qu’après avoir versé $arg1 à $arg2 en dehors de Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Marqué comme payé. En attente de confirmation.';

  @override
  String get paymentRequestCancelTitle => 'Annuler la demande de paiement ?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Annuler votre demande de paiement de $arg1 adressée à $arg2 ?';
  }

  @override
  String get paymentRequestCancelled => 'Demande de paiement annulée.';

  @override
  String get paymentRequestDeclineTitle => 'Refuser une demande de paiement ?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Refuser la demande de paiement de $arg1 envoyée par $arg2 ? Cette personne en sera informée.';
  }

  @override
  String get paymentRequestDeclined => 'Demande de paiement refusée.';

  @override
  String get paymentPendingBeforeFinish => 'Réglez les demandes de paiement en suspens et les paiements non confirmés avant le règlement final.';

  @override
  String get paymentFinishBlockedByPending => 'La finalisation est débloquée une fois que les demandes de paiement et les paiements non confirmés ont été réglés.';

  @override
  String get notificationPaymentRequestedTitle => 'Paiement demandé';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 vous a demandé $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Vous avez reçu une demande de paiement.';

  @override
  String get notificationPaymentRequestSentTitle => 'Paiement demandé envoyé';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 a marqué votre demande de paiement $arg2 comme payée.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Votre demande de paiement a été marquée comme payée.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Demande de paiement annulée';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 a annulé la demande de paiement $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Une demande de paiement a été annulée.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Demande de paiement refusée';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 a refusé votre demande de paiement $arg2.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Votre demande de paiement a été refusée.';

  @override
  String get notificationPaymentSentTitle => 'Paiement marqué comme envoyé';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 a marqué $arg2 comme vous ayant été versé.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Un paiement a été marqué comme vous ayant été envoyé.';

  @override
  String get notificationPaymentConfirmedTitle => 'Paiement confirmé';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 a confirmé avoir reçu $arg2 de votre part.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Votre paiement a été confirmé.';

  @override
  String get notificationPaymentCancelledTitle => 'Paiement annulé';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 a annulé la marque de paiement $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Une transaction de paiement a été annulée.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Paiement non reçu';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 a signalé que le paiement $arg2 n\'avait pas été reçu.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Un paiement a été signalé comme non reçu.';

  @override
  String get quickStartTitle => 'Démarrage rapide';

  @override
  String get quickStartCreateTitle => 'Seul ou entre amis';

  @override
  String get quickStartCreateBody => 'Créez un voyage pour vous ou pour un groupe. Ajoutez des amis par lien ou code QR, puis invitez-les.';

  @override
  String get quickStartInviteTitle => 'Voyager ensemble ou en solo';

  @override
  String get quickStartInviteBody => 'Invitez des amis à partager votre voyage, ou lancez un voyage personnel tout seul.';

  @override
  String get quickStartExpenseTitle => 'Dépenses en plusieurs devises';

  @override
  String get quickStartExpenseBody => 'Choisissez qui a payé et comment partager. Les autres devises sont converties au taux de la date d’achat, même si vous les ajoutez plus tard.';

  @override
  String get quickStartSettleTitle => 'Réglez simplement';

  @override
  String get quickStartSettleBody => 'Voyez qui doit quoi à qui, payez comme vous voulez et confirmez dans l’app.';

  @override
  String get quickStartAnalyticsTitle => 'Budget et dépenses';

  @override
  String get quickStartAnalyticsBody => 'Définissez un budget pour votre voyage ou votre groupe, puis consultez les dépenses par catégorie, voyage et jour.';

  @override
  String get quickStartMapTitle => 'Gardez vos lieux';

  @override
  String get quickStartMapBody => 'Ajoutez les villes visitées à votre carte de voyage privée. Elle n’est visible que par vous.';

  @override
  String get quickStartLiveTitle => 'Retrouvez-vous';

  @override
  String get quickStartLiveBody => 'En voyage de groupe, partagez votre position en direct pendant la durée choisie. Les membres du voyage la voient, et vous pouvez arrêter à tout moment.';

  @override
  String get quickStartNext => 'Suivant';

  @override
  String get quickStartBack => 'Retour';

  @override
  String get quickStartSkip => 'Passer';

  @override
  String get quickStartCreateAction => 'Créer un voyage';

  @override
  String get quickStartSignUpAction => 'S\'inscrire';

  @override
  String get quickStartClose => 'Fermer le guide de démarrage rapide';

  @override
  String get quickStartSubtitle => 'Découvrez le fonctionnement des voyages et des dépenses';

  @override
  String quickStartStep(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get workspaceTripTotal => 'Total du voyage';

  @override
  String get workspacePersonalTotal => 'Total dépensé';

  @override
  String get workspaceBalanceEven => 'Votre solde est équilibré';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Vous devez $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Vous récupérez $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Membres: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Rechercher des dépenses';

  @override
  String get workspaceClearSearch => 'Recherche claire';

  @override
  String get workspaceSearchLoadedHint => 'La recherche porte sur les dépenses enregistrées. Enregistrez-en davantage pour inclure des dépenses plus anciennes.';

  @override
  String get workspaceNoExpenseMatches => 'Aucune dépense correspondante';

  @override
  String get workspaceNoExpenseMatchesBody => 'Essayez une autre recherche ou effacez-la pour voir toutes les dépenses chargées.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Ajoutez votre première dépense pour commencer à suivre vos dépenses.';

  @override
  String get workspaceEmptyGroupExpenses => 'Ajoutez votre première dépense partagée pour voir la part de chacun.';

  @override
  String get workspaceLoadMoreExpenses => 'Charger davantage de dépenses';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Montant initial : $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Commentaires: $count';
  }

  @override
  String get workspaceExpenseActions => 'Actions relatives aux dépenses';

  @override
  String get workspaceLoadErrorTitle => 'Impossible de charger ce voyage';

  @override
  String get workspaceCachedWarning => 'Affichage des données enregistrées. Celles-ci peuvent être obsolètes.';

  @override
  String get workspaceActivityTab => 'Activité';

  @override
  String get workspaceLoadingTrip => 'Chargement du voyage';

  @override
  String get workspaceRefreshFailed => 'Échec de l\'actualisation';

  @override
  String get expenseDetailsTitle => 'Détails des dépenses';

  @override
  String get expenseQuickCategories => 'Catégories rapides';

  @override
  String get expenseReceiptUploading => 'Envoi du reçu…';

  @override
  String get expenseReceiptUploadOnSave => 'Le reçu sera envoyé à l\'enregistrement.';

  @override
  String get expenseCommentsLoadFailed => 'Impossible de charger les commentaires. Réessayez.';

  @override
  String get expenseReplyAction => 'Répondre';

  @override
  String get expenseReplyHint => 'Rédigez une réponse…';

  @override
  String expenseReplyTo(String name) {
    return 'Répondre à $name';
  }

  @override
  String get balanceEmptyBody => 'Les soldes s’affichent une fois les dépenses ajoutées.';

  @override
  String get balanceAfterPayments => 'Les soldes incluent les paiements confirmés.';

  @override
  String get balanceExpenseShare => 'Partage des dépenses';

  @override
  String get balanceHistoryScope => 'Dépenses enregistrées et paiements confirmés. Cette liste peut ne pas inclure l’historique complet du voyage.';

  @override
  String balancePaymentTo(String name) {
    return 'Paiement à $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Paiement de la part de $name';
  }

  @override
  String get settlementEmptyActive => 'Marquez tout le monde comme « prêt » avant de procéder aux règlements finaux.';

  @override
  String get settlementEmptyClosed => 'Aucun virement n’est répertorié pour ce voyage.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count sur $total virements confirmés';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count sur $total membres prêts';
  }

  @override
  String get settlementMemberReady => 'Prêt';

  @override
  String get settlementMemberNotReady => 'Pas encore prêt';

  @override
  String get settlementSuggested => 'Transfert suggéré';

  @override
  String get activityLoadFailed => 'Impossible d’actualiser l’activité. Les entrées visibles peuvent être obsolètes.';

  @override
  String get activityMember => 'Membre du voyage';

  @override
  String get friendsEmptyBody => 'Recherchez un ami par son nom ou son e-mail, ou utilisez un code QR.';

  @override
  String get friendsDeclineAction => 'Refuser';

  @override
  String get friendsLoading => 'Chargement des amis';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Voyages partagés : $count';
  }

  @override
  String get memberActivityScope => 'Sur la base des dépenses saisies ; cela peut ne pas couvrir l’intégralité du voyage.';

  @override
  String get sharedTripsLoadedLimit => 'Affichage de 20 voyages partagés au maximum.';

  @override
  String get memberRemoveTitle => 'Supprimer un participant ?';

  @override
  String memberRemoveBody(String name) {
    return 'Supprimer $name de ce voyage ? Cela n’est possible que s’il n’y a ni dépenses, ni règlements, ni soldes en cours.';
  }

  @override
  String get memberRemoveAction => 'Retirer du voyage';

  @override
  String memberRemoved(String name) {
    return '$name a été retiré du voyage.';
  }

  @override
  String get profilePaymentNotAdded => 'Pas encore ajouté';

  @override
  String get friendRelationshipLabel => 'Ami';

  @override
  String get sharedTripsEmptyBody => 'Les voyages auxquels vous participez tous les deux apparaîtront ici.';

  @override
  String get analyticsAllTrips => 'Tous les voyages';

  @override
  String get analyticsByTrip => 'Par voyage';

  @override
  String get analyticsYourSpending => 'Vos dépenses';

  @override
  String get analyticsActiveArchived => 'Voyages actifs et archivés';

  @override
  String get analyticsTrips => 'Voyages';

  @override
  String get analyticsAveragePerTrip => 'Moyenne par voyage';

  @override
  String get analyticsPaidByMember => 'Payé par le membre';

  @override
  String get analyticsYouPaid => 'Vous avez payé.';

  @override
  String get analyticsYouGetBack => 'Vous récupérez';

  @override
  String get analyticsYouOwe => 'Vous devez';

  @override
  String get analyticsPaidForOthers => 'Payé pour les autres';

  @override
  String get analyticsOthersPaidForYou => 'Les autres ont payé pour vous';

  @override
  String get analyticsParticipants => 'Participants';

  @override
  String get analyticsYourCategories => 'Vos dépenses par catégorie';

  @override
  String get analyticsTripTotalByCategory => 'Total du voyage par catégorie';

  @override
  String get analyticsLargestShares => 'Mes plus grosses parts de dépenses';

  @override
  String get analyticsLargestExpenses => 'Dépenses les plus importantes';

  @override
  String get analyticsSpendingByTrip => 'Vos dépenses par voyage';

  @override
  String get analyticsEmptyTitle => 'Aucune dépense pour l’instant';

  @override
  String get analyticsEmptyBody => 'Vos dépenses apparaîtront ici lorsque vous ajouterez des dépenses à un voyage.';

  @override
  String get analyticsPeriodEmptyBody => 'Cette vue n’entraîne aucun frais. Essayez un autre voyage ou une autre période.';

  @override
  String get analyticsLoadFailed => 'Impossible de charger le rapport de dépenses complet. Veuillez réessayer.';

  @override
  String get analyticsLastLoaded => 'Affichage du dernier rapport chargé avec succès.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dépenses',
      one: '$count dépense',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Options de voyage';

  @override
  String get editTripAction => 'Modifier le voyage';

  @override
  String get deleteTripAction => 'Supprimer le voyage';

  @override
  String get inviteTripMembersAction => 'Inviter des participants';

  @override
  String get tripCoverPhoto => 'Photo de couverture';

  @override
  String get tripInviteLaterHint => 'Vous pouvez inviter des personnes après avoir créé le voyage.';

  @override
  String get inviteClipboardFailed => 'Impossible d’accéder au presse-papiers. Réessayez.';

  @override
  String get friendInviteToTrip => 'Inviter à un voyage';

  @override
  String get friendChooseTrip => 'Choisissez un voyage';

  @override
  String get friendNoInvitableTrips => 'Aucun voyage disponible. Vous pouvez inviter des amis à rejoindre des voyages de groupe actifs que vous gérez, à moins qu’ils ne soient déjà membres ou qu’ils aient une invitation en attente.';

  @override
  String get friendTripInviteSent => 'Invitation envoyée.';

  @override
  String get friendTripUnavailable => 'Ce voyage n’est plus disponible pour cette action. Actualisez la page et réessayez.';

  @override
  String get friendTripActionFailed => 'Impossible d’effectuer cette action. Réessayez.';

  @override
  String get profileContactDescription => 'Vous rencontrez un problème, vous avez une suggestion ou une question concernant Splyto ? Envoyez-nous un e-mail — nous serons ravis de vous aider.';

  @override
  String get profileContactEmailAction => 'Rédigez un e-mail';

  @override
  String get profileContactEmailUnavailable => 'Impossible d’ouvrir une application de messagerie. Copiez l’adresse et écrivez-nous depuis votre application de messagerie.';

  @override
  String get profilePrivacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyLoadFailed => 'Impossible de charger la politique de confidentialité. Veuillez réessayer.';

  @override
  String get addReceiptAction => 'Ajouter un justificatif';

  @override
  String get receiptPickFailed => 'Impossible de charger le reçu. Veuillez réessayer.';

  @override
  String get receiptPhotoAccessDenied => 'Autorisez l’accès à l’appareil photo ou à la photothèque pour Splyto dans les Paramètres, puis réessayez.';

  @override
  String get receiptPhotoLabel => 'Photo du justificatif';

  @override
  String get replaceReceiptAction => 'Remplacer le reçu';

  @override
  String get removeReceiptAction => 'Supprimer le reçu';

  @override
  String get restoreReceiptAction => 'Restaurer le reçu précédent';

  @override
  String get expenseSplitBetween => 'Répartition entre';

  @override
  String get expenseEditParticipants => 'Choisissez les participants';

  @override
  String get expenseCustomSplit => 'Répartition personnalisée';

  @override
  String get expenseAdjustmentsLabel => 'Ajustements';

  @override
  String get expenseAdjustmentFieldLabel => '+ ou −';

  @override
  String get expenseAdjustmentsHint => 'Ajoutez ou retirez un montant pour chaque personne. Le reste est partagé à parts égales.';

  @override
  String get expenseAdjustmentsMustFit => 'Les ajustements ne peuvent pas dépasser le total, et personne ne peut devoir moins de zéro.';

  @override
  String get expenseItemsLabel => 'Articles';

  @override
  String get expenseAddItem => 'Ajouter un article';

  @override
  String get expenseRemoveItem => 'Retirer l\'article';

  @override
  String get expenseItemName => 'Article';

  @override
  String get expenseItemExtra => 'Taxes ou pourboire';

  @override
  String get expenseItemExtraHint => 'Réparti proportionnellement aux articles de chacun.';

  @override
  String get expenseItemsInvalid => 'Chaque article doit avoir un nom, un montant et au moins une personne.';

  @override
  String expenseItemsTotal(String total) {
    return 'Total des articles : $total';
  }

  @override
  String expenseItemsMustMatchTotal(String total) {
    return 'Les articles doivent totaliser $total.';
  }

  @override
  String get tripGuestAddAction => 'Ajouter une personne sans l\'appli';

  @override
  String get tripGuestNameLabel => 'Nom';

  @override
  String get tripGuestAddHint => 'Cette personne n\'a pas besoin de l\'appli. Vous saisissez ce qu\'elle a payé et marquez ses paiements.';

  @override
  String get tripGuestBadge => 'Sans l\'appli';

  @override
  String get tripGuestRenameAction => 'Modifier le nom';

  @override
  String tripGuestAdded(String name) {
    return '$name ajouté';
  }

  @override
  String expenseSplitAllocated(String amount) {
    return 'La totalité des $amount est répartie';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Il reste $amount à répartir';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount au-dessus du total';
  }

  @override
  String get profilePaymentSharingTitle => 'Partager les moyens de paiement avec mes voyages';

  @override
  String get profilePaymentSharingDescription => 'Autoriser les membres dont la participation aux voyages que je crée ou rejoins a été acceptée à consulter mes moyens de paiement. Cela concerne les voyages actuels et futurs. Vous pouvez désactiver ce partage à tout moment pour empêcher tout nouvel accès.';

  @override
  String get memberPaymentDetailsNotShared => 'Les modes de paiement ne sont pas partagés ou ne sont actuellement pas disponibles.';

  @override
  String get homeTripInvitations => 'Invitations à un voyage';

  @override
  String get homeNoTripInvitations => 'Aucune invitation de voyage en attente';

  @override
  String get homeInvitationsLoadFailed => 'Impossible de charger les invitations. Veuillez réessayer.';

  @override
  String get homeInvitationResponseFailed => 'Impossible de répondre à l’invitation. Veuillez réessayer.';

  @override
  String get homeTripShareFailed => 'Impossible de partager le voyage. Veuillez réessayer.';

  @override
  String get settleStillToReceive => 'En attente de réception';

  @override
  String get settleStillToPay => 'En attente de paiement';

  @override
  String get settleEstimateCaption => 'Estimation basée sur les dépenses actuelles. Les montants peuvent varier jusqu’à la fin du voyage.';

  @override
  String get settleOutstandingCaption => 'En attente de paiement ou de confirmation.';

  @override
  String get settleWaitingForYou => 'En attente que vous indiquiez que vous êtes prêt.';

  @override
  String get settleWhoPaysWhom => 'Qui paie qui ?';

  @override
  String get settlePreviewCaption => 'Aperçu · finalisé à la fin du voyage';

  @override
  String get settleOpenPaymentCaption => 'Ouvrez un paiement pour consulter les détails et les actions disponibles.';

  @override
  String get tripBudgetEnable => 'Définissez un budget';

  @override
  String get tripBudgetSoloHint => 'Objectif de dépenses facultatif pour ce voyage.';

  @override
  String get tripBudgetGroupHint => 'Un budget commun pour l’ensemble du groupe.';

  @override
  String get tripBudgetAmount => 'Montant du budget';

  @override
  String get tripBudgetInvalid => 'Saisissez un montant compris entre 0,01 et 999999999,99, avec au maximum deux décimales.';

  @override
  String get tripBudgetTitle => 'Budget du voyage';

  @override
  String get tripBudgetGroupTitle => 'Budget du groupe';

  @override
  String get tripBudgetRemaining => 'Reste';

  @override
  String get tripBudgetOver => 'Dépassement du budget';

  @override
  String get tripBudgetSpent => 'Dépensé';

  @override
  String get tripBudgetLimit => 'Budget';

  @override
  String get travelMapTitle => 'Ma carte de voyage';

  @override
  String get travelMapSubtitle => 'Les lieux visités, rien que pour vous.';

  @override
  String get travelMapHere => 'Je suis déjà venu ici';

  @override
  String get travelMapAdd => 'Ajouter un lieu';

  @override
  String get travelMapSearch => 'Rechercher une ville et un pays';

  @override
  String get travelMapSearchAction => 'Recherche';

  @override
  String get travelMapSearchHint => 'Par exemple, Lisbonne, Portugal';

  @override
  String get travelMapEmpty => 'Votre prochain souvenir commence ici';

  @override
  String get travelMapEmptyBody => 'Ajoutez une ville que vous avez visitée ou indiquez où vous vous trouvez actuellement.';

  @override
  String get travelMapConfirm => 'Enregistrer cette visite ?';

  @override
  String get travelMapConfirmBody => 'Vérifiez la ville et la date avant de les enregistrer sur votre carte privée.';

  @override
  String get travelMapDate => 'Date de la visite';

  @override
  String get travelMapSave => 'Enregistrer sur ma carte';

  @override
  String get travelMapCancel => 'Annuler';

  @override
  String get travelMapClose => 'Fermer';

  @override
  String get travelMapNoResults => 'Aucune ville trouvée. Essayez d’ajouter le pays à votre recherche.';

  @override
  String get travelMapLookupError => 'Impossible de trouver la ville. Vérifiez votre connexion ou ajoutez un lieu manuellement.';

  @override
  String get travelMapDenied => 'L\'accès à la localisation est désactivé. Vous pouvez toujours ajouter une ville manuellement.';

  @override
  String get travelMapDisabled => 'Activez les services de localisation ou ajoutez une ville manuellement.';

  @override
  String get travelMapError => 'Impossible de charger votre carte de voyage. Veuillez réessayer.';

  @override
  String get travelMapSaveError => 'Impossible d’enregistrer la visite. Veuillez réessayer.';

  @override
  String get travelMapUnavailable => 'La carte de voyage nécessite une mise à jour du serveur.';

  @override
  String get travelMapOffline => 'Hors ligne · affichage des lieux enregistrés';

  @override
  String get travelMapRetry => 'Réessayer';

  @override
  String get travelMapDelete => 'Supprimer la visite';

  @override
  String get travelMapDeleteConfirm => 'Souhaitez-vous supprimer cette visite de votre carte privée ?';

  @override
  String get travelMapFit => 'Afficher tous les lieux';

  @override
  String get travelMapSaved => 'Consulter les données enregistrées';

  @override
  String get travelMapVisited => 'Visité';

  @override
  String get travelMapLimit => 'Votre carte a atteint 1 000 visites. Supprimez une ancienne visite avant d’en ajouter une autre.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries pays',
      one: '$countries pays',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities villes',
      one: '$cities ville',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visites',
      one: '$count visite',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Destinations (facultatif)';

  @override
  String get travelAddDestination => 'Ajouter une destination';

  @override
  String get travelRemoveDestination => 'Supprimer la destination';

  @override
  String get travelFromTrip => 'À partir d\'un voyage';

  @override
  String get travelChooseTrip => 'Choisissez un voyage';

  @override
  String get travelNoTrips => 'Aucun voyage n’est encore disponible. Vous pouvez ajouter un lieu manuellement.';

  @override
  String get travelAddToMap => 'Ajouter à ma carte';

  @override
  String get travelTripConfirm => 'Enregistrez uniquement les lieux que vous avez réellement visités. Cela ajoute un souvenir personnel à votre carte.';

  @override
  String get travelVisitTitle => 'Titre (facultatif)';

  @override
  String get travelAddPhoto => 'Ajouter une photo';

  @override
  String get travelChangePhoto => 'Changer de photo';

  @override
  String get travelRemovePhoto => 'Supprimer la photo';

  @override
  String get travelPhotoError => 'Impossible de préparer cette photo. Veuillez en choisir une autre.';

  @override
  String get travelEditVisit => 'Modifier la visite';

  @override
  String get travelOpenTrip => 'Voyage ouvert';

  @override
  String get travelPreviousVisit => 'Visite précédente';

  @override
  String get travelNextVisit => 'Prochaine visite';

  @override
  String get travelDuplicate => 'Cette visite figure déjà sur votre carte.';

  @override
  String get liveMapTitle => 'Carte en temps réel';

  @override
  String get liveShareTitle => 'Partager ma position';

  @override
  String get liveConsent => 'Partagez votre position précise uniquement avec les membres dont la participation à ce voyage a été acceptée, pendant la durée de votre choix. Le partage continue en arrière-plan et vous pouvez l’arrêter à tout moment.';

  @override
  String get liveBackgroundNote => 'Les mises à jour peuvent être suspendues en l\'absence de connexion Internet ou si vous forcez la fermeture de l\'application. Seule la dernière position est conservée ; aucun historique d\'itinéraire n\'est enregistré.';

  @override
  String get liveStart => 'Commencer le partage';

  @override
  String get liveStop => 'Arrêter le partage';

  @override
  String get liveNotification => 'Votre position est actuellement partagée avec les participants à votre voyage. Ouvrez Splyto pour arrêter le partage.';

  @override
  String get livePermissionError => 'Autorisez l’accès à votre position dans les réglages de votre téléphone pour la partager.';

  @override
  String get liveStartError => 'Impossible de démarrer le partage. Vérifiez l’accès à la localisation, la connexion Internet ainsi que la date et l’heure de votre téléphone.';

  @override
  String get liveStopPending => 'Les mises à jour sont interrompues. En attente d’une connexion Internet pour supprimer votre dernière position ; celle-ci disparaîtra de la carte dans les 2 minutes si aucune mise à jour n’est effectuée.';

  @override
  String get liveSharing => 'partage la position';

  @override
  String get liveUnavailable => 'Cette carte en temps réel n’est pas disponible. Revenez au voyage et actualisez la page.';

  @override
  String get liveMapLoadError => 'La carte n’a pas pu se charger. Vérifiez votre connexion et réouvrez la carte.';

  @override
  String get liveLoadError => 'Impossible d’actualiser les positions. Seules les mises à jour récentes sont affichées.';

  @override
  String get liveFit => 'Afficher tout le monde sur la carte';

  @override
  String get liveEmpty => 'Personne ne partage encore sa position en temps réel.';

  @override
  String get liveRecent => 'Mise à jour récente';

  @override
  String get liveLastKnown => 'Dernière mise à jour';

  @override
  String get liveAccuracy => 'Précision';

  @override
  String get liveUntil => 'Partage jusqu’à';

  @override
  String get liveOtherSession => 'Lancé lors d’une autre session. Vous pouvez l’arrêter ici.';

  @override
  String get liveUpdatesPaused => 'Mises à jour suspendues. Vérifiez l’accès à la localisation et la connexion Internet.';

  @override
  String get livePrivateUntilShared => 'Votre position reste privée jusqu’à ce que vous choisissiez de la partager.';

  @override
  String get activityEventExpenseCreated => 'a ajouté une dépense';

  @override
  String get activityEventExpenseUpdated => 'a mis à jour une dépense';

  @override
  String get activityEventExpenseDeleted => 'a supprimé une dépense';

  @override
  String get activityEventExpenseCommentAdded => 'a commenté une dépense';

  @override
  String get activityEventTripCreated => 'a créé le voyage';

  @override
  String get activityEventTripUpdated => 'a mis à jour les détails du voyage';

  @override
  String get activityEventTripRenamed => 'a renommé le voyage';

  @override
  String get activityEventTripCurrencyChanged => 'a changé la devise du voyage';

  @override
  String get activityEventTripPhotoChanged => 'a changé la photo du voyage';

  @override
  String get activityEventTripBudgetChanged => 'a modifié le budget du voyage';

  @override
  String get activityEventTripDestinationsChanged => 'a modifié les destinations du voyage';

  @override
  String get activityEventTripMembersAdded => 'a ajouté des participants';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'a envoyé des invitations : $count';
  }

  @override
  String get activityEventTripMemberJoined => 'a rejoint le voyage';

  @override
  String get activityEventTripInvitationDeclined => 'a refusé l’invitation au voyage';

  @override
  String get activityEventTripInvitationRevoked => 'a annulé une invitation au voyage';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'a retiré $name du voyage';
  }

  @override
  String get activityEventTripMemberLeft => 'a quitté le voyage';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'a modifié le rôle de $name en $role';
  }

  @override
  String get activityEventTripMemberReady => 'a indiqué être prêt(e) à régler';

  @override
  String get activityEventTripMemberNotReady => 'a indiqué ne pas être prêt(e)';

  @override
  String get activityEventTripAllMembersReady => 'Tous les participants sont prêts à régler leur part';

  @override
  String get activityEventTripFinished => 'a terminé le voyage';

  @override
  String get activityEventTripSettled => 'Tous les virements sont confirmés, le voyage est réglé';

  @override
  String get activityEventSettlementMarkedSent => 'a marqué un virement comme « envoyé »';

  @override
  String get activityEventSettlementConfirmed => 'a confirmé un virement';

  @override
  String get activityEventSettlementSentCancelled => 'a annulé le statut « envoyé »';

  @override
  String get activityEventSettlementNotReceived => 'a marqué un virement comme non reçu';

  @override
  String get activityEventSettlementReminderSent => 'a envoyé un rappel de règlement';

  @override
  String get activityEventPaymentMarkedSent => 'a enregistré un paiement';

  @override
  String get activityEventPaymentRequested => 'a demandé un paiement';

  @override
  String get activityEventPaymentRequestMarkedSent => 'a marqué un paiement demandé comme « envoyé »';

  @override
  String get activityEventPaymentRequestCancelled => 'a annulé une demande de paiement';

  @override
  String get activityEventPaymentRequestDeclined => 'a refusé une demande de paiement';

  @override
  String get activityEventPaymentConfirmed => 'a confirmé un paiement';

  @override
  String get activityEventPaymentCancelled => 'a annulé un enregistrement de paiement';

  @override
  String get activityEventPaymentNotReceived => 'a marqué un paiement comme non reçu';

  @override
  String get activityEventUnknown => 'a apporté une modification';

  @override
  String get privacyEnglishFallback => 'La politique de confidentialité est actuellement disponible en anglais.';

  @override
  String get activityRoleAdmin => 'Admin';

  @override
  String get accountDeleteTitle => 'Supprimer le compte';

  @override
  String get accountDeleteIntro => 'Confirme la suppression par e-mail. Une fois confirmée, elle est irréversible.';

  @override
  String get accountDeleteConsequences => 'La suppression est définitive. Votre profil est anonymisé et l’accès à votre compte est supprimé. Les relevés de voyage et de dépenses partagés sont conservés pour les autres membres.';

  @override
  String get accountDeleteReasonsTitle => 'Qu’aurions-nous pu mieux faire ?';

  @override
  String get accountDeleteReasonsHint => 'Motif (facultatif)';

  @override
  String get accountDeleteReasonNotUsing => 'Je n’ai plus besoin de Splyto pour mes voyages';

  @override
  String get accountDeleteReasonAnotherWay => 'Je gère les dépenses partagées d’une autre manière';

  @override
  String get accountDeleteReasonComplicated => 'Il faut trop d’efforts pour faire avancer les choses';

  @override
  String get accountDeleteReasonTechnical => 'J’ai rencontré des bugs ou des problèmes techniques';

  @override
  String get accountDeleteReasonPrivacy => 'Je préfère supprimer les informations relatives à mon compte';

  @override
  String get accountDeleteReasonOther => 'Je pars pour une autre raison';

  @override
  String get accountDeleteEmailStep => 'L\'étape suivante consiste en une confirmation par e-mail.';

  @override
  String get accountDeletePasswordHint => 'Saisissez votre mot de passe Splyto actuel pour demander l’e-mail de confirmation. Votre compte est toujours actif.';

  @override
  String get accountDeleteInboxTitle => 'Une dernière étape dans votre boîte de réception';

  @override
  String accountDeleteSentBody(String email) {
    return 'Lien de confirmation envoyé à $email.';
  }

  @override
  String get accountDeleteSentHint => 'Ton compte reste actif jusqu’à confirmation de la suppression.';

  @override
  String get accountDeleteSending => 'Envoi d’un e-mail de confirmation';

  @override
  String get friendsShowMore => 'Afficher plus';

  @override
  String get tripReportTitle => 'Rapport de voyage';

  @override
  String get tripReportDetailedTitle => 'Rapport de voyage détaillé';

  @override
  String get tripReportDates => 'Dates';

  @override
  String get tripReportDestinations => 'Destinations';

  @override
  String get tripReportTotalSpent => 'Total dépensé';

  @override
  String get tripReportExpenses => 'Dépenses';

  @override
  String get tripReportYouPaid => 'Vous avez payé';

  @override
  String get tripReportYourShare => 'Votre part';

  @override
  String get tripReportYourBalance => 'Votre solde';

  @override
  String get tripReportYourSettlements => 'Vos règlements';

  @override
  String tripReportYouPay(Object arg1) {
    return 'Vous payez $arg1';
  }

  @override
  String tripReportPaysYou(Object arg1) {
    return '$arg1 vous paie';
  }

  @override
  String get tripReportStatus => 'Statut';

  @override
  String get tripReportStatusPending => 'En attente';

  @override
  String get tripReportStatusSent => 'Envoyé';

  @override
  String get tripReportStatusConfirmed => 'Confirmé';

  @override
  String get tripReportNoSettlements => 'Vous n\'avez rien à régler.';

  @override
  String get tripReportByCategory => 'Dépenses par catégorie';

  @override
  String get tripReportCategory => 'Catégorie';

  @override
  String get tripReportAmount => 'Montant';

  @override
  String get tripReportMembers => 'Membres';

  @override
  String get tripReportMember => 'Membre';

  @override
  String get tripReportPaid => 'Payé';

  @override
  String get tripReportShare => 'Part';

  @override
  String get tripReportBalance => 'Solde';

  @override
  String get tripReportAllExpenses => 'Toutes les dépenses';

  @override
  String get tripReportDate => 'Date';

  @override
  String get tripReportDescription => 'Description';

  @override
  String get tripReportPaidBy => 'Payé par';

  @override
  String get tripReportOriginalAmount => 'Montant d\'origine';

  @override
  String get tripReportCurrency => 'Devise';

  @override
  String get tripReportRate => 'Taux';

  @override
  String get tripReportPayments => 'Paiements';

  @override
  String get tripReportFrom => 'De';

  @override
  String get tripReportTo => 'À';

  @override
  String get tripReportFooter => 'Créé avec Splyto';

  @override
  String tripReportEmailSubject(Object arg1) {
    return 'Votre rapport de voyage : $arg1';
  }

  @override
  String get tripReportEmailTitle => 'Votre rapport de voyage est prêt';

  @override
  String tripReportEmailGreeting(Object arg1) {
    return 'Bonjour $arg1,';
  }

  @override
  String tripReportEmailBody(Object arg1) {
    return '$arg1 est terminé. Votre rapport est joint au format PDF.';
  }

  @override
  String get tripReportEmailOptOut => 'Vous pouvez désactiver ces e-mails dans Profil, sous Notifications.';

  @override
  String get tripReportEmailSetting => 'Rapport de voyage par e-mail';

  @override
  String get tripReportEmailSettingSubtitle => 'Recevez un résumé PDF à la fin d\'un voyage.';

  @override
  String get tripExportAction => 'Exporter les détails du voyage';

  @override
  String get tripExportPdf => 'PDF détaillé';

  @override
  String get tripExportCsv => 'Feuille de calcul (CSV)';

  @override
  String get tripExportFailed => 'Impossible de créer l\'export. Réessayez.';

  @override
  String get yearSummaryTitle => 'Votre année de voyages';

  @override
  String get yearSummarySubtitle => 'Vos voyages, lieux et dépenses de l\'année.';

  @override
  String yearSummaryEmpty(Object arg1) {
    return 'Aucun voyage terminé en $arg1.';
  }

  @override
  String get yearSummaryLoadFailed => 'Impossible de charger votre année de voyages.';

  @override
  String get yearSummaryTrips => 'Voyages';

  @override
  String get yearSummaryDays => 'Jours en voyage';

  @override
  String get yearSummaryCountries => 'Pays';

  @override
  String get yearSummaryCities => 'Villes';

  @override
  String get yearSummarySpending => 'Vos dépenses';

  @override
  String get yearSummaryBiggestTrip => 'Plus grand voyage';

  @override
  String get yearSummaryTopCategory => 'Catégorie principale';

  @override
  String get yearSummaryTopCompanion => 'Le plus de voyages avec';

  @override
  String yearSummaryTripsTogether(Object arg1) {
    return 'Voyages ensemble : $arg1';
  }

  @override
  String get yearSummaryPartial => 'Certains montants manquent, faute de taux de change disponible.';

  @override
  String get yearSummaryShare => 'Partager';

  @override
  String get yearSummaryShareFailed => 'Impossible de partager l\'image.';

  @override
  String get yearSummaryRetry => 'Réessayer';

  @override
  String get notificationCommentAddedTitle => 'Nouveau commentaire sur ta dépense';

  @override
  String notificationCommentAddedBody(Object name, Object note) {
    return '$name a commenté « $note ».';
  }

  @override
  String notificationCommentAddedBodyGeneric(Object name) {
    return '$name a commenté ta dépense.';
  }

  @override
  String get profilePushCommentsTitle => 'Commentaires et mentions';

  @override
  String get profilePushCommentsSubtitle => 'Nouveaux commentaires sur tes dépenses et mentions de toi';

  @override
  String get profilePushTripInvitesTitle => 'Invitations et membres du voyage';

  @override
  String get profilePushTripInvitesSubtitle => 'Invitations et personnes qui rejoignent ou quittent un voyage';

  @override
  String get profilePushTripStatusTitle => 'Statut du voyage';

  @override
  String get profilePushTripStatusSubtitle => 'Voyage terminé et prêt à être réglé';

  @override
  String get profilePushPaymentRequestsTitle => 'Demandes de paiement';

  @override
  String get profilePushPaymentRequestsSubtitle => 'Demandes reçues, refusées ou annulées';

  @override
  String get profilePushPaymentsTitle => 'Paiements';

  @override
  String get profilePushPaymentsSubtitle => 'Paiements marqués envoyés, confirmés ou non reçus';

  @override
  String get profilePushRemindersTitle => 'Rappels';

  @override
  String get profilePushRemindersSubtitle => 'Rappels de paiements non réglés';

  @override
  String get notificationLiveLocationTitle => 'Position en direct partagée';

  @override
  String notificationLiveLocationBody(Object name, Object trip) {
    return '$name partage sa position en direct dans « $trip ».';
  }

  @override
  String get profilePushLocationTitle => 'Position en direct';

  @override
  String get profilePushLocationSubtitle => 'Quand quelqu’un de ton voyage partage sa position';

  @override
  String get expenseSplitMethodTitle => 'Méthode de partage';

  @override
  String get expenseSplitExactHint => 'Indique ce que paie chaque personne';

  @override
  String get expenseSplitPercentHint => 'Chaque personne paie un pourcentage';

  @override
  String get expenseSplitSharesHint => 'Partager en parts, par ex. 2 : 1 : 1';

  @override
  String get expenseSplitAdjustmentHint => 'Partage égal avec un plus ou un moins par personne';

  @override
  String get expenseSplitItemsHint => 'Chacun paie ses propres articles';

  @override
  String get tripsSearchFriends => 'Rechercher des amis';

  @override
  String get expenseSplitEvenly => 'Partager à parts égales';

  @override
  String expensePaidByName(Object name) {
    return 'Payé par $name';
  }

  @override
  String get workspaceChooseCategory => 'Choisir une catégorie';

  @override
  String get workspaceExpenseFilters => 'Filtres des dépenses';

  @override
  String get workspaceClearFilters => 'Effacer les filtres';

  @override
  String get workspaceFiltersLoadedHint => 'Les filtres concernent les dépenses chargées. Charge davantage de dépenses pour inclure les plus anciennes.';

  @override
  String get workspaceFiltersNoMatchesHint => 'Modifie ou efface les filtres pour voir toutes les dépenses chargées.';
}
