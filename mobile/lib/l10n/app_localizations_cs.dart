// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get homeFirstTrip => 'Váš první výlet';

  @override
  String get homeYourShareAllTrips => 'Tvůj podíl na všech cestách';

  @override
  String get homeAllTime => 'Celé období';

  @override
  String get homeSolo => 'Sólo';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osob',
      few: '$count osoby',
      one: '$count osoba',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Akce související s cestou: $name';
  }

  @override
  String get homeNoActiveTrips => 'Žádné aktivní cesty';

  @override
  String get homeNoArchivedTrips => 'Žádné archivované cesty';

  @override
  String get homeLoadingTrips => 'Načítání vašich výletů';

  @override
  String get homeLoadErrorTitle => 'Nelze načíst vaše výlety';

  @override
  String get homeLoadErrorBody => 'Zkuste to prosím za chvíli znovu.';

  @override
  String get homeOfflineTitle => 'Jste offline';

  @override
  String get homeOfflineNoData => 'Vaše cesty na tomto zařízení zatím nejsou k dispozici.';

  @override
  String get homeOfflineCached => 'Offline. Zobrazení uložených výletů.';

  @override
  String get homeRefreshError => 'Nedařilo se aktualizovat. Zobrazují se dříve načtené cesty.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Sdílet moje uložené platební údaje s $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Pouze po dobu, kdy tato žádost čeká na platbu. Zrušením žádosti se přístup ukončí.';

  @override
  String get paymentDetailsUnavailable => 'Údaje o platbě nejsou k dispozici. Připojte se k internetu a zkontrolujte, zda je žádost stále otevřená.';

  @override
  String get paymentDetailsRetry => 'Zkuste to znovu';

  @override
  String get tripModeSolo => 'Jen já';

  @override
  String get tripModeGroup => 'S ostatními';

  @override
  String get premiumFree => 'Zdarma';

  @override
  String get premiumStatusUnavailable => 'Stav plánu není k dispozici';

  @override
  String premiumGrantedUntil(String date) {
    return 'Prémiové členství uděleno do $date';
  }

  @override
  String get premiumBillingNotActive => 'Žádné aktivní předplatné';

  @override
  String get premiumRefreshStatus => 'Aktualizovat stav plánu';

  @override
  String get accountSectionTitle => 'Účet';

  @override
  String get activeStatus => 'Aktivní';

  @override
  String get activeTripPlural => 'aktivní výlety';

  @override
  String get activeTripSingle => 'aktivní výlet';

  @override
  String get activeTrips => 'Aktivní výlety';

  @override
  String get activitiesComingSoon => 'Sekce „Aktivity“ bude brzy k dispozici.';

  @override
  String get addAction => 'Přidat';

  @override
  String get addExpenseTitle => 'Přidat výdaj';

  @override
  String get addExpensesAction => 'Přidat výdaje';

  @override
  String get addMembersAction => 'Přidat členy';

  @override
  String get addTripMembersTitle => 'Pozvěte účastníky cesty';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odeslaných pozvánek',
      few: '$count odeslané pozvánky',
      one: '$count odeslaná pozvánka',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Pozvánka na výlet byla odmítnuta.';

  @override
  String get tripInviteAction => 'Pozvat';

  @override
  String get tripInvitationsPending => 'Čekáme na odpověď';

  @override
  String get tripInvitationsRetry => 'Pozvánky nejsou k dispozici. Zkuste to znovu';

  @override
  String get tripInvitationRevoke => 'Zrušit pozvánku';

  @override
  String get tripInvitationRevokeFailed => 'Pozvánku se nepodařilo zrušit. Zkuste to znovu.';

  @override
  String get tripInvitationBody => 'Byli jste pozváni na výlet. Otevřete pozvánku a odpovězte.';

  @override
  String get allCaughtUp => 'Vše je aktuální';

  @override
  String get allFilter => 'Vše';

  @override
  String get allMembersLabel => 'Všichni členové';

  @override
  String get allPaymentsConfirmed => 'Všechny platby jsou potvrzeny.';

  @override
  String get allTrips => 'Všechny výlety';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Částka';

  @override
  String get amountMustBeGreaterThanZero => 'Částka musí být větší než 0.';

  @override
  String get appearance => 'Vzhled';

  @override
  String get archivedStatus => 'Archivováno';

  @override
  String get authSubtitleLogin => 'Rozdělte si cestovní výdaje s přáteli';

  @override
  String get authSubtitleRegister => 'Vytvořte si účet a začněte sdílet náklady na cesty';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'potvrzeno: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'čeká na schválení: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'odesláno: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'navrhováno: $count';
  }

  @override
  String get cancelAction => 'Zrušit';

  @override
  String get changeEmailWithPasswordHelper => 'Zadejte své heslo pro změnu e-mailové adresy.';

  @override
  String get chooseReceiptFile => 'Vyberte soubor s potvrzením';

  @override
  String get completeAccountSetupDescription => 'Zadejte svou e-mailovou adresu a heslo, abyste dokončili registraci účtu.';

  @override
  String get completeAccountSetupTitle => 'Dokončete nastavení účtu';

  @override
  String get confirmReceivedAction => 'Potvrdit přijetí';

  @override
  String get confirmedAllSettlementsArchived => 'Všechny platby potvrzeny. Výlet archivován.';

  @override
  String get confirmedAsReceived => 'Potvrzeno jako přijato.';

  @override
  String get confirmedLabel => 'Potvrzeno';

  @override
  String get couldNotOpenReceiptLink => 'Nelze otevřít odkaz na potvrzení.';

  @override
  String get createAction => 'Vytvořit';

  @override
  String get createFirstTripHint => 'Vytvořte si svůj první výlet a začněte.';

  @override
  String get createNewTripTitle => 'Vytvořit nový výlet';

  @override
  String get createTripAction => 'Vytvořit výlet';

  @override
  String get createTripFirst => 'Nejprve vytvořte výlet.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Vytvořil $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Organizátor cesty musí cestu dokončit, aby mohl zahájit potvrzení vyúčtování.';

  @override
  String currentEmailLabel(Object email) {
    return 'Aktuální e-mail: $email';
  }

  @override
  String get currentReceiptAttached => 'Aktuální potvrzení je přiloženo.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Datum';

  @override
  String get dateMustMatchFormat => 'Datum musí být ve formátu YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Datum neznámé';

  @override
  String get deleteAction => 'Smazat';

  @override
  String get deleteExpenseConfirmQuestion => 'Smazat tento výdaj?';

  @override
  String get deleteExpenseTitle => 'Smazat výdaj';

  @override
  String get editExpenseConfirmTitle => 'Uložit změny výdajů?';

  @override
  String get editExpenseConfirmText => 'Tím se aktualizují zůstatky u všech účastníků cesty.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Přímo vysvětleno na příkladu výdajů: $amount';
  }

  @override
  String get doneStatus => 'Hotovo';

  @override
  String get editAction => 'Upravit';

  @override
  String get editExpenseTitle => 'Upravit výdaj';

  @override
  String get emailAddressLabel => 'E-mailová adresa';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailRequired => 'E-mailová adresa je povinná.';

  @override
  String get enterValidExactAmounts => 'Zadejte platné a přesné částky pro všechny účastníky.';

  @override
  String get enterValidPercentages => 'Zadejte platné procentní podíly pro všechny účastníky.';

  @override
  String get equalSplitLabel => 'Rovnoměrné rozdělení';

  @override
  String exactAmountWithValue(Object value) {
    return 'Přesně: $value';
  }

  @override
  String get exactAmountsLabel => 'Přesné částky';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Přesný rozpis musí v součtu činit $amount.';
  }

  @override
  String get expenseAdded => 'Výdaj přidaný.';

  @override
  String get expenseBreakdownSubtitle => 'Jak se jednotlivé výdaje dotýkají tohoto člena.';

  @override
  String get expenseBreakdownTitle => 'Rozpis výdajů';

  @override
  String get expenseDeleted => 'Výdaj smazán.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Výdaj č. $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Zaplaceno $paid  -  Dluží $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reakce';

  @override
  String get expenseCommentsTitle => 'Komentáře';

  @override
  String get expenseNoComments => 'Zatím žádné komentáře.';

  @override
  String get expenseAddCommentHint => 'Přidat komentář...';

  @override
  String get expenseCommentSend => 'Odeslat';

  @override
  String get expenseMentionNoMatches => 'Žádní odpovídající členové';

  @override
  String get expenseMentionMembersLabel => 'Členové výletu, které lze zmínit';

  @override
  String get expenseDeleteCommentTitle => 'Smazat komentář?';

  @override
  String get expenseUpdated => 'Výdaje aktualizovány.';

  @override
  String expenseWithId(Object id) {
    return 'Výdaj č. $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdajů',
      few: '$count výdaje',
      one: '$count výdaj',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Výdaje';

  @override
  String get failedToCreateTrip => 'Vytvoření cesty se nezdařilo.';

  @override
  String get failedToLoadUsersDirectory => 'Nepodařilo se načíst adresář uživatelů.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrování vyúčtování podle účastníků';

  @override
  String get finishSoloTripConfirmationText => 'Chcete tuto cestu dokončit a přesunout do archivu? Vaše výdaje zůstanou k nahlédnutí.';

  @override
  String get soloTripArchived => 'Cesta byla dokončena a archivována.';

  @override
  String get finishTripSyncPending => 'Před dokončením této cesty synchronizujte své čekající změny.';

  @override
  String get finishTripAction => 'Dokončit výlet';

  @override
  String get finishTripConfirmationText => 'Dokončit tuto cestu a zahájit vyúčtování?';

  @override
  String get finishTripStartSettlementsAction => 'Dokončete a zahajte vyúčtování';

  @override
  String get finishTripTitle => 'Dokončit výlet';

  @override
  String forParticipants(Object participants) {
    return 'Pro: $participants';
  }

  @override
  String get forgotPassword => 'Zapomněli jste heslo?';

  @override
  String get profileSetPassword => 'Nastavit heslo';

  @override
  String get profileManagePassword => 'Nastavit nebo změnit heslo';

  @override
  String get profilePasswordByEmail => 'Nastavení hesla e-mailem';

  @override
  String get passwordEmailBackToProfile => 'Zpět na profil';

  @override
  String get forgotPasswordSubtitle => 'Zadejte svůj e-mail a my vám zašleme odkaz pro obnovení hesla.';

  @override
  String get forgotPasswordSuccessMessage => 'Pokud existuje účet s touto e-mailovou adresou, zaslali jsme vám odkaz pro obnovení hesla.';

  @override
  String get passwordResetSentTitle => 'Zkontrolujte doručenou poštu';

  @override
  String get passwordResetSentHint => 'Odkaz platí 1 hodinu. Pokud e-mail nevidíte, zkontrolujte složku spam.';

  @override
  String get forgotPasswordTitle => 'Obnovit heslo';

  @override
  String get friendsProgressSubtitle => 'Každý člen a jeho stav potvrzení.';

  @override
  String get friendsProgressTitle => 'Pokrok přátel';

  @override
  String get friendsSectionComingSoon => 'Sekce „Přátelé“ bude brzy k dispozici.';

  @override
  String fromDirection(Object name) {
    return 'Od $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from až $to';
  }

  @override
  String get generateTurnAction => 'Vylosovat další osobu';

  @override
  String get hasAccountQuestion => 'Už máte účet?';

  @override
  String helloUser(Object name) {
    return 'Ahoj, $name!';
  }

  @override
  String get iSentAction => 'Poslal jsem';

  @override
  String get invalidEmailFormat => 'Neplatný formát e-mailu.';

  @override
  String get languageAction => 'Jazyk';

  @override
  String get languageEnglish => 'Angličtina';

  @override
  String get languageLatvian => 'Lotyšština';

  @override
  String get languageSpanish => 'Španělština';

  @override
  String get languageSystem => 'Systém';

  @override
  String get languageSystemSubtitle => 'Použít jazyk zařízení';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Nechte pole prázdné, chcete-li zachovat stávající heslo.';

  @override
  String get logInButton => 'Přihlásit se';

  @override
  String get logOutButton => 'Odhlásit se';

  @override
  String get logoutFromDeviceQuestion => 'Odhlásit se z tohoto zařízení?';

  @override
  String get logoutRevocationUnconfirmed => 'Z tohoto zařízení ses odhlásil(a). Zrušení relace na serveru se nepodařilo potvrdit.';

  @override
  String get markedAsSent => 'Označeno jako odeslané.';

  @override
  String get markSettlementSentConfirmTitle => 'Označit převod jako odeslaný?';

  @override
  String get markSettlementSentConfirmText => 'Tuto funkci použijte až poté, co jste platbu skutečně odeslali. Příjemce bude vyzván k potvrzení.';

  @override
  String get settlementCancelSentAction => 'Označit jako neodeslané';

  @override
  String get settlementCancelSentConfirmTitle => 'Zrušit odeslaný status?';

  @override
  String get settlementCancelSentConfirmText => 'Tím se převod vrátí do stavu „čekající“ a příjemce bude o tom informován.';

  @override
  String get settlementSentCancelled => 'Převod byl vrácen do stavu „čeká na zpracování“.';

  @override
  String get settlementNotReceivedAction => 'Toto jsem neobdržel';

  @override
  String get settlementNotReceivedConfirmTitle => 'Nahlásit nepřijatou platbu?';

  @override
  String get settlementNotReceivedConfirmText => 'Tím se převod vrátí do stavu „čekající“ a plátce bude o tom informován.';

  @override
  String get settlementMarkedNotReceived => 'Označeno jako nepřijaté.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Potvrzujete přijetí?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Potvrďte až poté, co se peníze objeví na vašem účtu. Tímto krokem může být vypořádání dokončeno.';

  @override
  String get memberSummariesSubtitle => 'Aktuální stav zůstatku pro obě strany.';

  @override
  String get memberSummariesTitle => 'Přehledy členů';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Zaplatit $total  -  potvrzeno $confirmed  -  čeká se $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Odhadovaný dopad na platbu na jednoho člena.';

  @override
  String get membersImpactTitle => 'Vliv členů';

  @override
  String get membersIncludedInExpense => 'Zahrnutí členů';

  @override
  String get membersLabel => 'Členové';

  @override
  String moreCount(Object count) {
    return '+dalších $count';
  }

  @override
  String get myFilter => 'Moje';

  @override
  String get myImpactTitle => 'Můj dopad';

  @override
  String get firstNameHint => 'Vaše křestní jméno';

  @override
  String get firstNameLabel => 'Jméno';

  @override
  String get firstNameLengthValidation => 'Křestní jméno musí mít 2–64 znaků.';

  @override
  String get fullNameHelper => 'Jméno a příjmení uveďte v jednom poli.';

  @override
  String get fullNameHint => 'např. Anna Ozolina';

  @override
  String get fullNameLabel => 'Celé jméno';

  @override
  String get fullNameValidation => 'Zadejte jméno a příjmení (minimálně 2 znaky v každém poli).';

  @override
  String get lastNameHint => 'Vaše příjmení';

  @override
  String get lastNameLabel => 'Jméno';

  @override
  String get lastNameLengthValidation => 'Příjmení musí mít 2–64 znaků.';

  @override
  String get nameHint => 'Vaše jméno';

  @override
  String get nameLabel => 'Název';

  @override
  String get nameLengthValidation => 'Jméno musí mít alespoň 2 znaky.';

  @override
  String get navActivities => 'Statistiky';

  @override
  String get navAddTrip => 'Přidat výlet';

  @override
  String get navBalances => 'Zůstatky';

  @override
  String get navExpenses => 'Výdaje';

  @override
  String get navFriends => 'Přátelé';

  @override
  String get navHome => 'Domů';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRandom => 'Náhodné';

  @override
  String get netLabel => 'Čistý zůstatek';

  @override
  String get newPasswordLabel => 'Nové heslo';

  @override
  String get nicknameHint => 'Jak vás uvidí vaši přátelé';

  @override
  String get nicknameLabel => 'Přezdívka';

  @override
  String get nicknameLengthValidation => 'Přezdívka musí mít alespoň 2 znaky.';

  @override
  String get noAccountQuestion => 'Ještě nemáte účet?';

  @override
  String get noBalancesYet => 'Zatím žádné zůstatky.';

  @override
  String get noChangesToSave => 'Žádné změny k uložení.';

  @override
  String get noDirectExpenseLink => 'Nebyl nalezen žádný přímý odkaz na jednotlivé výdaje. Tato úhrada se vypočítává z celkové částky za výlet.';

  @override
  String get noExpenseImpactForMember => 'Pro tohoto člena to nemá žádný finanční dopad.';

  @override
  String noExpensesByUserYet(Object name) {
    return '$name zatím nemá žádné výdaje.';
  }

  @override
  String get noExpensesYet => 'Zatím žádné výdaje.';

  @override
  String get noExtraUsersToAdd => 'Není třeba přidávat žádné další uživatele.';

  @override
  String get noInternetDeleteQueued => 'Žádné připojení k internetu. Smazat položky ve frontě.';

  @override
  String get noInternetExpenseQueued => 'Žádné připojení k internetu. Výdaj zařazen do fronty.';

  @override
  String get noInternetUpdateQueued => 'Žádné připojení k internetu. Aktualizace zařazena do fronty.';

  @override
  String get noMatchingRows => 'Žádné shodné řádky.';

  @override
  String get noMembersFound => 'Nebyli nalezeni žádní členové.';

  @override
  String get noNewMembersAdded => 'Tito lidé již jsou členy nebo mají nevyřízené pozvánky.';

  @override
  String get noNotePlaceholder => 'Žádná poznámka';

  @override
  String get notificationsToday => 'Dnes';

  @override
  String get notificationsEmptyBody => 'Zde se budou zobrazovat aktualizace týkající se výletů, výdajů a přátel.';

  @override
  String get notificationsCached => 'Offline — zobrazení uložených oznámení.';

  @override
  String get notificationsRefreshFailed => 'Nedařilo se aktualizovat. Zobrazují se dříve načtené oznámení.';

  @override
  String get notificationsJustNow => 'Právě teď';

  @override
  String notificationsMinutesAgo(int count) {
    return 'Před $count min';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'Před $count h';
  }

  @override
  String get notificationsUnread => 'Nepřečteno';

  @override
  String get noNotificationsYet => 'Zatím žádná oznámení.';

  @override
  String get noParticipantData => 'Žádné údaje o účastnících.';

  @override
  String get noParticipantsSelected => 'Nebyli vybráni žádní účastníci.';

  @override
  String get noPaymentRowsInTrip => 'V této cestě nejsou žádné platební řádky.';

  @override
  String get noPaymentsNeeded => 'Žádné platby nejsou nutné.';

  @override
  String get noPicksYet => 'Zatím žádné výběry.';

  @override
  String get noSettlementActivityForMember => 'U tohoto člena nedochází k žádným platebním transakcím.';

  @override
  String get noSettlementRowsYet => 'Zatím žádné řádky vyúčtování.';

  @override
  String get noSettlements => 'Žádná vyrovnání';

  @override
  String get noTransferNeededForFilter => 'Pro vybraný filtr není nutný žádný převod.';

  @override
  String get noTransferRowsToShow => 'Nezobrazují se žádné řádky s převody.';

  @override
  String get noTripDataLoaded => 'Nebyly načteny žádné údaje o cestě.';

  @override
  String get noTripsYet => 'Zatím žádné výlety.';

  @override
  String get noUsersFoundYet => 'Zatím nebyli nalezeni žádní uživatelé.';

  @override
  String get notSetValue => 'Není nastaveno';

  @override
  String get notYetConfirmedTitle => 'Zatím nepotvrzeno';

  @override
  String get noteHint => 'Večeře, taxi, vstupenky...';

  @override
  String get noteLabel => 'Poznámka';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Poznámka smí mít maximálně $max znaků.';
  }

  @override
  String get notificationFallbackTitle => 'Oznámení';

  @override
  String get notificationsTitle => 'Oznámení';

  @override
  String get notificationFriendInviteTitle => 'Žádost o přátelství';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name vám poslal pozvánku k přátelství.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Obdrželi jste pozvánku k přátelství.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Pozvánka přijata';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name přijal/a vaši pozvánku k přátelství.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Vaše pozvánka pro přítele byla přijata.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Pozvánka odmítnuta';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name odmítl/a vaši pozvánku k přátelství.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Vaše pozvánka pro přítele byla odmítnuta.';

  @override
  String get notificationTripAddedTitle => 'Přidáno k výletu';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name vás přidal do výletu „$trip“.';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Byl/a jste přidán/a do výletu „$trip“.';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Byl/a jsi přidán/a do výletu.';

  @override
  String get notificationExpenseAddedTitle => 'Přidán nový výdaj';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name přidal výdaj ve výši $amount v rámci „$trip“.';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name přidal výdaj ve výši $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Byla přidána nová výdajová položka.';

  @override
  String get notificationCommentMentionTitle => 'Někdo vás zmínil v komentáři';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name vás zmínil v komentáři k „$note“.';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name vás zmínil v komentáři.';
  }

  @override
  String get notificationTripFinishedTitle => 'Cesta skončila';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name dokončil/a „$trip“. Vyúčtování jsou připravena.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name dokončil/a „$trip“. Cesta je archivována.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '„$trip“ bylo dokončeno.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Stav cesty byl aktualizován.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Člen označený jako připravený';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name je připraven/a k účasti na „$trip“.';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Člen je připraven k vyúčtování v „$trip“.';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Člen je připraven k vypořádání.';

  @override
  String get notificationTripReadyToSettleTitle => 'Všichni členové jsou připraveni';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Všichni členové jsou v „$trip“ označeni jako připravení. Můžete zahájit vyúčtování.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Všichni členové jsou připraveni. Můžete zahájit vyúčtování.';

  @override
  String get notificationSettlementReminderTitle => 'Upomínka k vyúčtování';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor připomněl $target, aby označil $amount jako odeslané.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor připomněl $target, aby potvrdil přijetí částky $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Obdrželi jste upomínku k vyúčtování.';

  @override
  String get notificationPaymentReminderTitle => 'Upomínka k platbě';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Připomenutí: v položce „$trip“ prosím označte částku $amount jako odeslanou na $target.';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Připomenutí: označte prosím platbu jako odeslanou.';

  @override
  String get notificationConfirmationReminderTitle => 'Připomenutí potvrzení';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Připomenutí: potvrďte prosím přijetí částky $amount od $payer v rámci „$trip“.';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Připomenutí: potvrďte prosím přijetí platby.';

  @override
  String get notificationSettlementSentTitle => 'Převod označen jako odeslaný';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name označil částku $amount jako odeslanou vám.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Převod byl označen jako odeslaný.';

  @override
  String get notificationSettlementConfirmedTitle => 'Převod potvrzen';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name potvrdil, že od vás obdržel částku $amount.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Převod byl potvrzen.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count čekajících změn',
      few: '$count čekající změny',
      one: '$count čekající změna',
    );
    return 'Offline fronta: $_temp0';
  }

  @override
  String get syncAllSynced => 'Vše synchronizováno';

  @override
  String syncChangesWaiting(Object count) {
    return '$count čeká na synchronizaci';
  }

  @override
  String get syncFailedTapToRetry => 'Synchronizace se nezdařila, klepnutím zkusit znovu';

  @override
  String get offlineQueueStatus => 'Offline fronta';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Výlet může ukončit pouze jeho organizátor.';

  @override
  String get openLabel => 'Otevřít';

  @override
  String get openReceiptAction => 'Otevřít účtenku';

  @override
  String get openSettlements => 'Otevřít vyrovnání';

  @override
  String get overviewTitle => 'Přehled';

  @override
  String get owesLabel => 'Dluží';

  @override
  String get paidByLabel => 'Platí';

  @override
  String get paidLabel => 'Placené';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Zaplaceno $paid -  Dluží $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Účastníci (prázdné = všichni členové)';

  @override
  String get participantsTitle => 'Účastníci';

  @override
  String get passwordLabel => 'Heslo';

  @override
  String get passwordComplexityHelper => 'Použijte alespoň 1 velké písmeno, 1 číslici a 1 symbol.';

  @override
  String get passwordComplexityValidation => 'Heslo musí obsahovat 1 velké písmeno, 1 číslici a 1 symbol.';

  @override
  String get passwordMinLength => 'Heslo musí mít alespoň 8 znaků.';

  @override
  String get passwordMinLengthShort => 'Heslo musí mít alespoň 6 znaků.';

  @override
  String get passwordResetComingSoon => 'Obnovení hesla bude brzy k dispozici.';

  @override
  String get passwordsDoNotMatch => 'Hesla se neshodují.';

  @override
  String payerName(Object name) {
    return '$name (plátce)';
  }

  @override
  String get pendingLabel => 'Čeká';

  @override
  String get pendingPaymentsSubtitle => 'Platby stále čekají na úplné potvrzení.';

  @override
  String get percentLabel => 'Procenta';

  @override
  String get percentSplitMustBe100 => 'Součet procentuálních podílů musí činit přesně 100 %.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Procenta';

  @override
  String get pickAtLeastOneParticipant => 'Vyberte alespoň jednoho účastníka.';

  @override
  String get pickMembersGenerateTurn => 'Vyber účastníky a vylosuj další osobu.';

  @override
  String pickedCycleCompleted(Object name) {
    return 'Vybrán $name. Cyklus dokončen.';
  }

  @override
  String pickedUser(Object name) {
    return 'Vybrán $name.';
  }

  @override
  String get profileRefreshCachedData => 'Nepodařilo se aktualizovat profil. Zobrazují se data z mezipaměti.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpdated => 'Profil aktualizován.';

  @override
  String get uploadAvatarAction => 'Nahrát avatar';

  @override
  String get takePhotoAction => 'Vyfoť to.';

  @override
  String get chooseFromLibraryAction => 'Vyberte z knihovny';

  @override
  String get removeAvatarAction => 'Odstranit avatar';

  @override
  String get avatarUpdatedMessage => 'Aktualizován avatar.';

  @override
  String get avatarRemovedMessage => 'Avatar byl odstraněn.';

  @override
  String get avatarFileTooLarge => 'Soubor s avatarem je příliš velký (max. 5 MB).';

  @override
  String get avatarPickFailed => 'Nepodařilo se načíst obrázek avatara.';

  @override
  String get queueAddExpense => 'Přidat výdaj';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'Ve frontě: přidat výdaj $amount';
  }

  @override
  String get queueDeleteExpense => 'Smazat výdaj';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'Ve frontě: smazat výdaj č. $id';
  }

  @override
  String get queuePendingStatus => 'Čekající ve frontě';

  @override
  String get queueUpdateExpense => 'Aktualizovat výdaje';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'Ve frontě: aktualizace výdaje č. $id';
  }

  @override
  String get queuedChange => 'Změny ve frontě';

  @override
  String queuedChangesTitle(Object count) {
    return 'Změny ve frontě ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'Ve frontě ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cyklus $cycleNo, čerpání $drawNo – zbývá $remaining';
  }

  @override
  String get receiptFallbackName => 'účtenka';

  @override
  String get receiptLinkInvalid => 'Odkaz na potvrzení je neplatný.';

  @override
  String get receiptOptionalLabel => 'Účtenka (nepovinné)';

  @override
  String get recentPicksTitle => 'Poslední losování';

  @override
  String get reloadProfile => 'Obnovit profil';

  @override
  String get rememberMe => 'Zapamatovat si mě';

  @override
  String get removeCurrentReceipt => 'Odstranit aktuální potvrzení';

  @override
  String get repeatNewPasswordLabel => 'Zadejte nové heslo znovu';

  @override
  String get repeatPasswordLabel => 'Zadejte heslo znovu';

  @override
  String get requestFailedTryAgain => 'Žádost se nezdařila. Zkuste to znovu.';

  @override
  String get retryAction => 'Zkuste to znovu';

  @override
  String get rowsLabel => 'Řádky';

  @override
  String get backToLoginAction => 'Zpět k přihlášení';

  @override
  String get saveAction => 'Uložit';

  @override
  String get saveCredentialsButton => 'Uložení přihlašovacích údajů';

  @override
  String get saveProfileButton => 'Uložit profil';

  @override
  String get sendResetLinkButton => 'Odeslat odkaz pro resetování';

  @override
  String get searchUsersHint => 'Vyhledávejte osoby podle jména nebo e-mailu';

  @override
  String get selectedPeopleLabel => 'Vybrané osoby';

  @override
  String get noSearchMatches => 'Nebyli nalezeni žádní odpovídající uživatelé.';

  @override
  String get savingButton => 'Ukládání...';

  @override
  String get selectAtLeastTwoMembers => 'Vyberte alespoň dva členy.';

  @override
  String get selectMembersHint => 'Vybrat členy';

  @override
  String selectedFileLabel(Object name) {
    return 'Vybráno: $name';
  }

  @override
  String get selectedLabel => 'Vybrané';

  @override
  String get selectedUserFallback => 'Vybraný uživatel';

  @override
  String get settings => 'Nastavení';

  @override
  String get settleUpAction => 'Vyrovnat dluhy';

  @override
  String get settledLabel => 'Vyrovnáno';

  @override
  String get settledStatus => 'Vyrovnáno';

  @override
  String get settlementActivitySubtitle => 'Převody spojené s tímto členem.';

  @override
  String get settlementActivityTitle => 'Účtování';

  @override
  String get settlementCompletedTitle => 'Vypořádání dokončeno';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total potvrzeno';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Vyrovnání: $count';
  }

  @override
  String get settlementImpactTitle => 'Dopad na vypořádání';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Dopad na vypořádání: $name';
  }

  @override
  String get settlementInProgress => 'Probíhá vypořádání';

  @override
  String get settlementInProgressTitle => 'Probíhá vypořádání';

  @override
  String get settlementLabel => 'Vyrovnání';

  @override
  String get settlementOverviewArchivedSubtitle => 'Cesta archivována. Všechny vyúčtování dokončeny.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Sledujte potvrzení o vypořádání.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Zobrazte náhled převodů po skončení cesty.';

  @override
  String get settlementPreview => 'Náhled vyúčtování';

  @override
  String get settlementPreviewTitle => 'Náhled vyúčtování';

  @override
  String get settlementProgressTripArchived => 'Cesta archivována';

  @override
  String settlementWithId(Object id) {
    return 'Vyúčtování č. $id';
  }

  @override
  String get settlements => 'Vyrovnání';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Vyúčtování již byla dokončena.';

  @override
  String get settlementsDone => 'Provedené vyúčtování';

  @override
  String get settlingStatus => 'Vypořádání';

  @override
  String get shareUnit => 'podíl';

  @override
  String get sharesLabel => 'Podíly';

  @override
  String get sharesMustBePositiveIntegers => 'Počet podílů musí být kladné celé číslo.';

  @override
  String sharesWithValue(Object value) {
    return 'Podíly: $value';
  }

  @override
  String get showActiveTrips => 'Zobrazit aktivní výlety';

  @override
  String get signUpButton => 'Zaregistrovat se';

  @override
  String get splitBreakdownSubtitle => 'Jak se rozdělují výdaje';

  @override
  String get splitBreakdownTitle => 'Rozpis rozdělení';

  @override
  String get splitHintEqual => 'Rozdělte částku rovným dílem mezi vybrané účastníky.';

  @override
  String get splitHintExact => 'Zadejte přesnou částku pro každého účastníka. Součet se musí shodovat s celkovou částkou.';

  @override
  String get splitHintPercent => 'Zadejte procentuální podíl pro každého účastníka. Součet musí činit 100 %.';

  @override
  String get splitHintShares => 'Zadejte počet sdílených jednotek (1, 2, 3...). Náklady se rozdělí proporcionálně.';

  @override
  String get splitLabel => 'Rozdělit';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Rovnoměrné rozdělení ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Přesné částky ($target)';
  }

  @override
  String get splitModeLabel => 'Režim rozdělení';

  @override
  String splitModePercent(Object target) {
    return 'Procenta ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Podíly ($target)';
  }

  @override
  String get statusConfirmed => 'Potvrzeno';

  @override
  String get statusPending => 'Čeká';

  @override
  String get statusSent => 'Odesláno';

  @override
  String get statusSuggested => 'Navrženo';

  @override
  String statusWithValue(Object status) {
    return 'Stav: $status';
  }

  @override
  String get suggestedTransferDirections => 'Navržené směry plateb';

  @override
  String get suggestedTransferFromExpense => 'Navrhovaný převod z výdajů';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count navržených převodů',
      few: '$count navržené převody',
      one: '$count navržený převod',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Očekávané řádky plátce -> příjemce.';

  @override
  String get suggestedTransfersTitle => 'Doporučené převody';

  @override
  String get summarySettledUp => 'Vyrovnáno';

  @override
  String get summaryYouAreOwed => 'Ostatní ti dluží';

  @override
  String get summaryYouOwe => 'Dlužíš';

  @override
  String get syncAction => 'Synchronizace';

  @override
  String get syncNowAction => 'Synchronizovat nyní';

  @override
  String get syncingStatus => 'Synchronizace';

  @override
  String get tapToViewDetails => 'Klepnutím zobrazíte podrobnosti';

  @override
  String get themeModeDark => 'Tmavý';

  @override
  String get themeModeDarkSubtitle => 'Jemná tmavá barva (ne čistě černá)';

  @override
  String get themeModeLight => 'Světlý';

  @override
  String get themeModeSystem => 'Systém';

  @override
  String get themeModeSystemSubtitle => 'Používejte vzhled zařízení';

  @override
  String toDirection(Object name) {
    return 'Příjemce: $name';
  }

  @override
  String get totalLabel => 'Celkem';

  @override
  String get travelerFallbackName => 'Cestující';

  @override
  String get tripAlreadyClosed => 'Cesta již byla ukončena.';

  @override
  String get tripArchivedReadOnly => 'Cesta je archivována. Režim pouze pro čtení.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Cesta je uzavřena. Úpravy výdajů jsou deaktivovány.';

  @override
  String get tripClosedExpensesReadOnly => 'Cesta je uzavřena. Výdaje jsou pouze pro čtení.';

  @override
  String get tripClosedRandomDisabled => 'Výlet je uzavřen. Náhodné losování je deaktivováno.';

  @override
  String tripCreated(Object name) {
    return 'Cesta „$name“ byla vytvořena.';
  }

  @override
  String get tripFinished => 'Cesta skončila.';

  @override
  String get tripFinishedCompleteSettlements => 'Cesta je ukončena. Proveďte vyúčtování.';

  @override
  String get tripFinishedSettlementStarted => 'Cesta skončila. Zahájeno vyúčtování.';

  @override
  String get tripFullySettledArchived => 'Cesta je zcela vypořádána a archivována.';

  @override
  String get tripNameHint => 'Lyžařský výlet do Rakouska';

  @override
  String get tripNameLabel => 'Název výletu';

  @override
  String get tripNameLengthValidation => 'Název cesty musí mít alespoň 2 znaky.';

  @override
  String get tripSnapshotTitle => 'Snímek cesty';

  @override
  String get tripTitleShort => 'Výlet';

  @override
  String tripStatusWithValue(Object status) {
    return 'Stav cesty: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Cesta č. $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Došlo k neočekávané chybě při načítání profilu';

  @override
  String get unexpectedErrorLoadingTripData => 'Došlo k neočekávané chybě při načítání údajů o cestě';

  @override
  String get unexpectedErrorLoadingTrips => 'Došlo k neočekávané chybě při načítání výletů';

  @override
  String get unexpectedErrorSavingChanges => 'Neočekávaná chyba při ukládání změn';

  @override
  String get unexpectedErrorSavingCredentials => 'Neočekávaná chyba při ukládání přihlašovacích údajů';

  @override
  String get unexpectedErrorUpdatingProfile => 'Neočekávaná chyba při aktualizaci profilu';

  @override
  String get unknownError => 'Neznámá chyba';

  @override
  String get unknownLabel => 'Neznámé';

  @override
  String get unreadLabel => 'Nepřečteno';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nepřečtených aktualizací',
      few: '$count nepřečtené aktualizace',
      one: '$count nepřečtená aktualizace',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Chybí argument trasy cesty.';

  @override
  String userIdLabel(Object id) {
    return 'ID uživatele: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Zaplaceno $paid  -  Dluží $owes  -  Čistá částka $net';
  }

  @override
  String userWithId(Object id) {
    return 'Uživatel $id';
  }

  @override
  String get valueLabel => 'Hodnota';

  @override
  String get viewAllTrips => 'Zobrazit všechny výlety';

  @override
  String get viewByPersonTitle => 'Zobrazení podle osoby';

  @override
  String get whoOwesWhatSubtitle => 'Kdo zaplatil a kdo dluží.';

  @override
  String get whoOwesWhatTitle => 'Kdo komu co dluží';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Kdo komu dluží: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Řádky výdajů, které se na tento převod vztahují.';

  @override
  String get whyPaymentExistsTitle => 'Proč tato platba existuje';

  @override
  String get youLabel => 'Vy';

  @override
  String get youSettledForExpense => 'Svůj podíl na tomto výdaji už máš vyrovnaný.';

  @override
  String youShouldPay(Object amount) {
    return 'Měl bys zaplatit. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Měli byste dostávat $amount';
  }

  @override
  String get yourShare => 'Tvůj podíl.';

  @override
  String get yourTrips => 'Vaše výlety';

  @override
  String get authIntroSplitSmarter => 'Dělejte si účty chytřeji.';

  @override
  String get authIntroTravelFree => 'Cestujte svobodně.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Sledujte sdílené náklady v různých měnách a vyúčtujte je okamžitě – žádné trapné dlužní úpisy.';

  @override
  String get authIntroPlanTogether => 'Plánujte společně.';

  @override
  String get authIntroPayClearly => 'Platby provádějte jasně.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Vytvářejte výlety během několika sekund, přidávejte přátele a zajistěte, aby všechny výdaje byly pro všechny transparentní.';

  @override
  String get authIntroSettleFast => 'Vyřizujte věci rychle.';

  @override
  String get authIntroStayFriends => 'Zůstaňme přáteli.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Od společných večeří až po celé výlety – Splyto zajišťuje spravedlivé vyúčtování bez stresu.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Přihlášení přes Apple se nezdařilo. Zkuste to prosím znovu.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Přihlášení přes Google se nezdařilo. Zkuste to prosím znovu.';

  @override
  String get authIntroCreateAccount => 'Vytvořte si účet.';

  @override
  String get authIntroChooseSign => 'Vyberte si, jak se chcete zaregistrovat.';

  @override
  String get authIntroContinueGoogle => 'Pokračovat s Google';

  @override
  String get authIntroContinueApple => 'Pokračovat s Apple';

  @override
  String get authIntroBack => 'Zpět';

  @override
  String get authIntroSplitSettled => 'Rozdělení vypořádáno';

  @override
  String get authIntroParis3Friends => 'Paříž · 3 přátelé';

  @override
  String get authIntroGetStarted => 'Začínáme';

  @override
  String get authIntroAlreadyHaveAccount => 'Už máte účet? ';

  @override
  String get authIntroSignIn => 'Přihlásit se';

  @override
  String get authIntroSignUpWithEmail => 'Zaregistrujte se pomocí e-mailu';

  @override
  String get authIntroOr => 'NEBO';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Přihlášení přes Google nevrátilo identifikační token.';

  @override
  String get authAppleSignAvailableIosDevices => 'Přihlášení přes Apple je k dispozici na zařízeních s iOS.';

  @override
  String get authAppleSignNotAvailableDevice => 'Přihlášení přes Apple není na tomto zařízení k dispozici.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Přihlášení přes Apple nevrátilo identifikační token.';

  @override
  String get authCancel => 'Zrušit';

  @override
  String get authSendLink => 'Odeslat odkaz';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'E-mailová adresa není ověřena. Zadejte svou e-mailovou adresu a vyžádejte si ověřovací odkaz.';

  @override
  String get authEmailNotVerified => 'E-mail nebyl ověřen';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Odeslat ověřovací odkaz na $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Ověřovací odkaz byl odeslán. Zkontrolujte si e-mail.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Nepodařilo se odeslat ověřovací odkaz. Zkuste to prosím znovu.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Byl odeslán ověřovací e-mail. Před přihlášením si prosím ověřte svou e-mailovou adresu.';

  @override
  String get authVerifyEmail => 'Ověřte svou e-mailovou adresu';

  @override
  String get authEmailLabel => 'E-mail:';

  @override
  String get authClose => 'Zavřít';

  @override
  String get authResendLink => 'Znovu odeslat odkaz';

  @override
  String get profileAppSettingsSectionTitle => 'NASTAVENÍ APLIKACE';

  @override
  String get profileEmailVerified => 'Ověřeno';

  @override
  String get profileEmailNotVerified => 'Neověřeno';

  @override
  String get profileEmailSendVerification => 'Odeslat odkaz';

  @override
  String get profileEmailVerificationSent => 'Ověřovací e-mail byl odeslán. Zkontrolujte doručenou poštu.';

  @override
  String get profileAccountSectionTitle => 'ÚČET';

  @override
  String get profileAccountSettings => 'Nastavení účtu';

  @override
  String get profileChangePhoto => 'Změnit profilovou fotku';

  @override
  String get profileAppearance => 'Vzhled';

  @override
  String get profileThemeDisplayMode => 'Téma a režim zobrazení';

  @override
  String get profileLanguage => 'Jazyk';

  @override
  String get profileDisplayLanguage => 'Jazyk zobrazení';

  @override
  String get profileNotificationsSectionHeading => 'OZNÁMENÍ';

  @override
  String get profileAppBanners => 'Bannery v aplikaci';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Zobrazovat nové oznamovací pruhy uvnitř aplikace';

  @override
  String get profilePushNotificationsTitle => 'Push notifikace';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Telefonní oznámení týkající se výdajů, přátel, výletů a vyúčtování';

  @override
  String get profileSupportSectionHeading => 'PODPORA';

  @override
  String get profileContactUs => 'Kontaktujte nás';

  @override
  String get profileReportBugSuggestion => 'Nahlásit chybu / Návrh';

  @override
  String get profileRateSplyto => 'Ohodnoťte Splyto';

  @override
  String get profileLeaveStoreRating => 'Zanechte hodnocení obchodu';

  @override
  String get profileSecuritySectionHeading => 'BEZPEČNOST';

  @override
  String get profileAccountAndSecurity => 'Účet a zabezpečení';

  @override
  String get profileHelpTitle => 'Nápověda';

  @override
  String get profileChangePassword => 'Změnit heslo';

  @override
  String get profileUpdateAccountPassword => 'Aktualizujte heslo k účtu';

  @override
  String get profileDangerZoneSectionHeading => 'NEBEZPEČNÁ ZÓNA';

  @override
  String get profileManageAccountAccess => 'Správa přístupu k účtu';

  @override
  String get profileMadeWithLabel => 'Vytvořeno pomocí';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Funkce hodnocení v obchodě bude propojena v dalším kroku.';

  @override
  String get profileFailedSaveNotificationSettings => 'Nepodařilo se uložit nastavení oznámení.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSHOVÁ OZNÁMENÍ';

  @override
  String get profileInAppBannersSectionTitle => 'BANNERY V APLIKACI';

  @override
  String get profileInAppTripMemberAddedTitle => 'Člen přidaný do výletu';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatická upomínka k vyúčtování';

  @override
  String get profileExpenseUpdates => 'Aktualizace výdajů';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Bannery s přidanými výdaji uvnitř aplikace';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Oznámení o přidaných výdajích do telefonu';

  @override
  String get profileFriendInvites => 'Pozvánka od přítele';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Bannery s žádostmi o přátelství a odpověďmi v aplikaci';

  @override
  String get profileFriendRequestResponseNotifications => 'Oznámení o žádostech o přátelství a odpovědích na ně';

  @override
  String get profileTripUpdates => 'Aktualizace výletu';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Bannery s informacemi o průběhu cesty a stavu členů v aplikaci';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Životní cyklus výletu a změny stavu členů';

  @override
  String get profileSettlementUpdates => 'Aktualizace vyúčtování';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Označené bannery „odesláno“ a „potvrzeno“ v aplikaci';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Označené odeslané a potvrzené aktualizace plateb';

  @override
  String get profileScreenshotSizeMust8Mb => 'Velikost snímku obrazovky nesmí přesáhnout 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Poslat zpětnou vazbu';

  @override
  String get profileFeedbackTypeLabel => 'Typ';

  @override
  String get profileFeedbackTypeBug => 'Chyba';

  @override
  String get profileFeedbackTypeSuggestion => 'Doporučení';

  @override
  String get profileDescribeIssueSuggestion => 'Popište problém nebo návrh';

  @override
  String get profilePickingImage => 'Vybírání obrázku...';

  @override
  String get profileAttachScreenshot => 'Přiložte snímek obrazovky';

  @override
  String get profileChangeScreenshot => 'Změnit snímek obrazovky';

  @override
  String get profileRemoveImage => 'Odstranit obrázek';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Tip: přiložte snímek obrazovky pro rychlejší vyhodnocení chyby';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Před odesláním doplňte podrobnosti nebo přiložte snímek obrazovky';

  @override
  String get profileSendAction => 'Odeslat';

  @override
  String get profileThanksFeedbackSent => 'Děkujeme! Zpětná vazba odeslána';

  @override
  String get profileFailedSendFeedback => 'Nepodařilo se odeslat zpětnou vazbu';

  @override
  String get profileCouldNotOpenWebsite => 'Nelze otevřít webovou stránku.';

  @override
  String get profileOpenWebsiteQuestion => 'Otevřít webovou stránku?';

  @override
  String get profileOpenPortfolioAction => 'Otevřete portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Tento formát obrázku není na tomto zařízení podporován. Vyberte prosím formát JPG nebo PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Ke změně hesla je nutná platná e-mailová adresa účtu. Pokud vám e-mailová adresa chybí nebo je nesprávná, obraťte se na podporu.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Odkaz pro smazání byl zaslán na váš e-mail.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Nepodařilo se odeslat odkaz pro smazání. Zkuste to prosím znovu.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Pro změnu e-mailové adresy zadejte aktuální heslo.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Ověřovací e-mail byl odeslán na novou e-mailovou adresu. Bezpečnostní upozornění bylo odesláno na vaši aktuální e-mailovou adresu.';

  @override
  String get profileEditOverviewCurrency => 'Přehled měn';

  @override
  String get profileEditPaymentMethod => 'Způsob platby';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Bankovní převod, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Zadejte své heslo (volitelné pro Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Odeslat odkaz na smazání na e-mail';

  @override
  String get profileEditBackProfile => 'Zpět na profil';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Před změnou hesla zadejte do profilu platnou e-mailovou adresu.';

  @override
  String get profileEditPasswordUpdated => 'Heslo bylo aktualizováno.';

  @override
  String get profileEditFailedUpdatePassword => 'Aktualizace hesla se nezdařila.';

  @override
  String profileEditEmail(Object email) {
    return 'Účet: $email';
  }

  @override
  String get profileEditPrimary => 'Hlavní';

  @override
  String get profileEditSearchCurrency => 'Vyhledávání měny';

  @override
  String get profileEditNoCurrenciesFound => 'Nebyly nalezeny žádné měny';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Souhrnné částky v přehledu jsou přepočítány na tuto měnu.';

  @override
  String get profileEditPaymentInfoUpdated => 'Informace o platbách byly aktualizovány.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Nepodařilo se uložit platební údaje. Zkuste to prosím znovu.';

  @override
  String get profileEditCurrentPassword => 'Aktuální heslo';

  @override
  String get profileEditBankTransferIbanSwift => 'Bankovní převod (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'odkaz paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Vyberte způsob platby';

  @override
  String get profileEditTapChange => 'Klepnutím změňte';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'U převodů ve Velké Británii musí mít kód banky 6 číslic a číslo účtu 8 číslic.';

  @override
  String get profileEditPaymentInfo => 'Informace o platbách';

  @override
  String get profileEditSaveDetails => 'Uložit podrobnosti';

  @override
  String get profileEditBankRegion => 'Bankovní region';

  @override
  String get profileEditEurope => 'Evropa';

  @override
  String get profileEditSortCode => 'Kód banky';

  @override
  String get profileEditExample112233 => 'Příklad: 112233';

  @override
  String get profileEditNumber => 'Číslo účtu';

  @override
  String get profileEdit8Digits => '8 číslic';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Pro vnitrostátní převody ve Velké Británii použijte kód banky (sort code) + číslo účtu.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Příklad: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 nebo 11 znaků';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Jméno držitele účtu se přebírá z celého jména v profilu.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username nebo uživatelské jméno';

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
  String get imageCropperAdjustAvatar => 'Upravte avatar';

  @override
  String get imageCropperAdjustTripImage => 'Upravte obrázek výletu';

  @override
  String get imageCropEditAction => 'Upravit oříznutí';

  @override
  String get imageCropZoomIn => 'Přiblížit';

  @override
  String get imageCropZoomOut => 'Oddálit';

  @override
  String get imageCropZoomOnly => 'Z této fotky se uložila jen oříznutá verze, takže ji můžete pouze přiblížit.';

  @override
  String get imageCropLoadFailed => 'Tuto fotku se nepodařilo otevřít.';

  @override
  String get imageCropSaveFailed => 'Nové oříznutí se nepodařilo uložit. Zkuste to znovu.';

  @override
  String get imageCropChanged => 'Tato fotka se mezitím změnila. Zavřete tuto obrazovku a otevřete ji znovu.';

  @override
  String get copyAction => 'Kopírovat';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Britská libra';

  @override
  String get currencyNameChf => 'Švýcarský frank';

  @override
  String get currencyNameNok => 'Norská koruna';

  @override
  String get currencyNameSek => 'Švédská koruna';

  @override
  String get currencyNameDkk => 'Dánská koruna';

  @override
  String get currencyNamePln => 'Polský zlotý';

  @override
  String get currencyNameCzk => 'Česká koruna';

  @override
  String get currencyNameHuf => 'Maďarský forint';

  @override
  String get currencyNameRon => 'Rumunský leu';

  @override
  String get currencyNameBgn => 'Bulharský lev';

  @override
  String get currencyNameIsk => 'Islandská koruna';

  @override
  String get currencyNameAll => 'Albánský lek';

  @override
  String get currencyNameBam => 'Bosna a Hercegovina Marka';

  @override
  String get currencyNameByn => 'Běloruský rubl';

  @override
  String get currencyNameMdl => 'Moldavský leu';

  @override
  String get currencyNameMkd => 'Makedonský denár';

  @override
  String get currencyNameRsd => 'Srbský dinár';

  @override
  String get currencyNameUah => 'Ukrajinská hřivna';

  @override
  String get currencyNameGel => 'Gruzínský lari';

  @override
  String get currencyNameTry => 'Turecká lira';

  @override
  String get currencyNameUsd => 'Americký dolar';

  @override
  String get currencyNameJpy => 'Japonský jen';

  @override
  String get currencyNameCny => 'Čínský jüan';

  @override
  String get currencyNameCad => 'Kanadský dolar';

  @override
  String get currencyNameAud => 'Australský dolar';

  @override
  String get currencyNameRub => 'Ruský rubl';

  @override
  String get currencyNameMxn => 'Mexické peso';

  @override
  String get currencyNameBrl => 'Brazilský real';

  @override
  String get currencyNameArs => 'Argentinské peso';

  @override
  String get currencyNameClp => 'Chilské peso';

  @override
  String get currencyNameCop => 'Kolumbijské peso';

  @override
  String get currencyNamePen => 'Peruánský sol';

  @override
  String get currencyNameUyu => 'Uruguayské peso';

  @override
  String get currencyNameBob => 'Bolivijský boliviano';

  @override
  String get currencyNamePyg => 'Paraguajské guarani';

  @override
  String get currencyNameCrc => 'Kostarický colón';

  @override
  String get currencyNameDop => 'Dominikánské peso';

  @override
  String get currencyNameGtq => 'Guatemalský quetzal';

  @override
  String get currencyNamePab => 'Panamská balboa';

  @override
  String get currencyNameHnl => 'Honduraská lempira';

  @override
  String get currencyNameNio => 'Nikaragujská córdoba';

  @override
  String get currencyNameJmd => 'Jamajský dolar';

  @override
  String get currencyNameBbd => 'Barbadoský dolar';

  @override
  String get currencyNameBsd => 'Bahamský dolar';

  @override
  String get currencyNameTtd => 'Trinidadský dolar';

  @override
  String get currencyNameXcd => 'Východokaribský dolar';

  @override
  String get currencyNameBzd => 'Belizský dolar';

  @override
  String get currencyNameAwg => 'Arubský zlatý';

  @override
  String get currencyNameBmd => 'Bermudský dolar';

  @override
  String get currencyNameKyd => 'Kajmanský dolar';

  @override
  String get currencyNameKrw => 'Jihokorejský won';

  @override
  String get currencyNameInr => 'Indická rupie';

  @override
  String get currencyNameThb => 'Thajský baht';

  @override
  String get currencyNameVnd => 'Vietnamský dong';

  @override
  String get currencyNameIdr => 'Indonéská rupie';

  @override
  String get currencyNameMyr => 'Malajsijský ringgit';

  @override
  String get currencyNameSgd => 'Singapurský dolar';

  @override
  String get currencyNamePhp => 'Filipínské peso';

  @override
  String get currencyNameHkd => 'Hongkongský dolar';

  @override
  String get currencyNameTwd => 'Tchajwanský dolar';

  @override
  String get currencyNameLkr => 'Srílanská rupie';

  @override
  String get currencyNameNpr => 'Nepálská rupie';

  @override
  String get currencyNameBdt => 'Bangladéšská taka';

  @override
  String get currencyNamePkr => 'Pákistánská rupie';

  @override
  String get currencyNameKhr => 'Kambodžský riel';

  @override
  String get currencyNameLak => 'Laoský kip';

  @override
  String get currencyNameMmk => 'Myanmarský kyat';

  @override
  String get currencyNameMnt => 'Mongolský tugrik';

  @override
  String get currencyNameMop => 'Macajská pataca';

  @override
  String get currencyNameBnd => 'Brunejský dolar';

  @override
  String get currencyNameMvr => 'Maledivská rupie';

  @override
  String get currencyNameBtn => 'Bhútánský ngultrum';

  @override
  String get currencyNameKzt => 'Kazašské tenge';

  @override
  String get currencyNameUzs => 'Uzbecký sum';

  @override
  String get currencyNameKgs => 'Kyrgyzský som';

  @override
  String get currencyNameTjs => 'Tádžické somoni';

  @override
  String get currencyNameAzn => 'Ázerbájdžánský manat';

  @override
  String get currencyNameAmd => 'Arménský dram';

  @override
  String get currencyNameAed => 'SAE dirham';

  @override
  String get currencyNameSar => 'Saúdský rijál';

  @override
  String get currencyNameQar => 'Katarský rijál';

  @override
  String get currencyNameOmr => 'Ománský rijál';

  @override
  String get currencyNameKwd => 'Kuvajtský dinár';

  @override
  String get currencyNameBhd => 'Bahrajnský dinár';

  @override
  String get currencyNameJod => 'Jordánský dinár';

  @override
  String get currencyNameIls => 'Izraelský nový šekel';

  @override
  String get currencyNameLbp => 'Libanonská libra';

  @override
  String get currencyNameIqd => 'Irácký dinár';

  @override
  String get currencyNameZar => 'Jihoafrický rand';

  @override
  String get currencyNameEgp => 'Egyptská libra';

  @override
  String get currencyNameMad => 'Marocký dinár';

  @override
  String get currencyNameTnd => 'Tuniský dinár';

  @override
  String get currencyNameDzd => 'Alžírský dinár';

  @override
  String get currencyNameKes => 'Keňský šilink';

  @override
  String get currencyNameTzs => 'Tanzanský šilink';

  @override
  String get currencyNameUgx => 'Ugandský šilink';

  @override
  String get currencyNameRwf => 'Rwandský frank';

  @override
  String get currencyNameEtb => 'Etiopský birr';

  @override
  String get currencyNameGhs => 'Ghanský cedi';

  @override
  String get currencyNameNgn => 'Nigerijská naira';

  @override
  String get currencyNameXof => 'CFA/BCEAO frank';

  @override
  String get currencyNameXaf => 'CFA/BEAC frank';

  @override
  String get currencyNameMur => 'Mauricijská rupie';

  @override
  String get currencyNameScr => 'Seychelská rupie';

  @override
  String get currencyNameNad => 'Namibijský dolar';

  @override
  String get currencyNameBwp => 'Botswanská pula';

  @override
  String get currencyNameZmw => 'Zambijská kwacha';

  @override
  String get currencyNameMzn => 'Mozambický metical';

  @override
  String get currencyNameAoa => 'Angolská kwanza';

  @override
  String get currencyNameMga => 'Madagaskarský ariary';

  @override
  String get currencyNameCve => 'Kapverdské escudo';

  @override
  String get currencyNameGmd => 'Gambijský dalasi';

  @override
  String get currencyNameNzd => 'Novozélandský dolar';

  @override
  String get currencyNameFjd => 'Fidžijský dolar';

  @override
  String get currencyNameXpf => 'CFP frank';

  @override
  String get currencyNameWst => 'Samojská tala';

  @override
  String get currencyNameVuv => 'Vanuatský vatu';

  @override
  String get currencyNameTop => 'Tonžská paanga';

  @override
  String get currencyNamePgk => 'Papuánská nová kina';

  @override
  String get expenseCategoryFood => 'Jídlo';

  @override
  String get expenseCategoryGroceries => 'Potraviny';

  @override
  String get expenseCategoryFuel => 'Palivo';

  @override
  String get expenseCategoryTransport => 'Doprava';

  @override
  String get expenseCategoryAccommodation => 'Ubytování';

  @override
  String get expenseCategoryActivities => 'Aktivity';

  @override
  String get expenseCategoryTickets => 'Vstupenky';

  @override
  String get expenseCategoryShopping => 'Nákupy';

  @override
  String get expenseCategoryParty => 'Večírek';

  @override
  String get expenseCategoryParking => 'Parkování';

  @override
  String get expenseCategoryOther => 'Ostatní';

  @override
  String get shellTripAlreadyInListOpened => 'Výlet již máte ve svém seznamu. Otevřeli jsme jej za vás.';

  @override
  String get shellJoinedTripFromInviteLink => 'Připojil se k výletu přes pozvánkový odkaz.';

  @override
  String get shellFailedToOpenInviteLink => 'Nepodařilo se otevřít odkaz s pozvánkou.';

  @override
  String get shellFailedToOpenFriendLink => 'Nepodařilo se otevřít odkaz na přítele.';

  @override
  String get shellTripInviteTitle => 'Pozvánka na výlet';

  @override
  String get shellNoAction => 'Ne';

  @override
  String get shellYesAction => 'Ano';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Tuto cestu může smazat pouze její tvůrce.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Smazat lze pouze aktivní výlety.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Smazat „$tripLabel“? To je povoleno pouze před přidáním jakýchkoli výdajů.';
  }

  @override
  String get shellTripDeleted => 'Cesta byla smazána.';

  @override
  String get shellFailedToDeleteTrip => 'Vymazání cesty se nezdařilo.';

  @override
  String get shellFailedToLoadNotifications => 'Nepodařilo se načíst oznámení.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nové oznámení: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Nepodařilo se aktualizovat oznámení.';

  @override
  String get shellMarkAllAsReadAction => 'Označit vše jako přečtené';

  @override
  String get shellNewSection => 'Nové';

  @override
  String get shellEarlierSection => 'Dříve';

  @override
  String get shellShowMoreEarlierAction => 'Zobrazit více dřívějších';

  @override
  String get shellLoadingMore => 'Načítání dalších...';

  @override
  String get shellLoadMoreNotificationsAction => 'Načíst další oznámení';

  @override
  String get shellTripNoLongerAvailable => 'Tato cesta již není k dispozici.';

  @override
  String get shellFailedToOpenTrip => 'Nepodařilo se otevřít výlet.';

  @override
  String get shellYesterday => 'Včera';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Již jste členem výletu „$tripName“. Chcete tento výlet otevřít nyní?\n\nPozval vás: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Chcete se připojit k výletu „$tripName“?\n\nPozval vás: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Vybraný obrázek: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Obrázek výletu je již nastaven.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Cesta byla vytvořena, ale nahrání obrázku se nezdařilo.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Cesta byla vytvořena, ale nahrání obrázku se nezdařilo: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Připojte se k výletu na základě pozvánky';

  @override
  String get tripsTotalTrips => 'Celkový počet výletů';

  @override
  String get tripsTotalSpent => 'Celková částka utracená';

  @override
  String get tripsMixedCurrencies => 'Smíšené měny';

  @override
  String get tripsShowActive => 'Zobrazit aktivní';

  @override
  String get tripsSeeAll => 'Zobrazit vše';

  @override
  String get tripsGridView => 'Zobrazení v mřížce';

  @override
  String get tripsListView => 'Zobrazení seznamu';

  @override
  String get tripsAddNewTrip => 'Přidat nový výlet';

  @override
  String get tripsLoadMore => 'Načíst více';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Odstranit „$arg1“? To je povoleno pouze před přidáním jakýchkoli výdajů.';
  }

  @override
  String get tripsTripDates => 'Termíny výletu';

  @override
  String get tripsFrom => 'Od';

  @override
  String get tripsSelectDate => 'Vyberte datum';

  @override
  String get tripsTo => 'K';

  @override
  String get tripsMainCurrency => 'Hlavní měna';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Vyberte prosím období cesty (datum od a do).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Datum ukončení cesty musí být stejné jako datum zahájení nebo pozdější.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Formát období cesty je neplatný. Zvolte prosím data znovu.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Již jste členem této cesty.';

  @override
  String get tripsJoinedTripSuccessfully => 'Účast na výletu byla úspěšně potvrzena.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Nepodařilo se připojit k výletu z pozvánky.';

  @override
  String get tripsJoinTrip => 'Připojit se k výletu';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Vložte odkaz na pozvánku nebo token pozvánky.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Zadejte platný pozvánkový odkaz nebo token.';

  @override
  String get tripsClipboardIsEmpty => 'Schránka je prázdná.';

  @override
  String get tripsPaste => 'Vložit';

  @override
  String get tripsJoin => 'Připojit se';

  @override
  String get workspaceTripMembers => 'Účastníci cesty';

  @override
  String get workspaceFailedToLoadFriends => 'Načtení přátel se nezdařilo.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Nepodařilo se vygenerovat odkaz na pozvánku.';

  @override
  String get workspaceInviteLink => 'Odkaz pro pozvání';

  @override
  String get workspaceGeneratingInviteLink => 'Vytváření pozvánkového odkazu...';

  @override
  String get workspaceInviteLinkUnavailable => 'Odkaz pro pozvání není k dispozici.';

  @override
  String get workspaceCopyInviteLink => 'Zkopírujte odkaz na pozvánku';

  @override
  String get workspaceInviteLinkCopied => 'Odkaz na pozvánku zkopírován.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Platnost vyprší: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Žádní přátelé k dispozici. Nejprve si přidejte přátele.';

  @override
  String get workspaceSettle => 'Vypořádání';

  @override
  String get workspaceOwesToTheGroup => 'Dluží skupině';

  @override
  String get workspaceGetsBackFromGroup => 'Má dostat peníze od skupiny';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Zobrazuje 4 nejvýznamnější položky podle rozdílu zůstatku.';

  @override
  String get workspaceOpenFlow => 'Podrobnosti';

  @override
  String get workspaceFriend => 'Přítel';

  @override
  String get workspaceSettlementTransfer => 'Převod vyúčtování';

  @override
  String get workspaceCompleted => 'Dokončeno';

  @override
  String get workspaceWaitingForConfirmation => 'Čekání na potvrzení';

  @override
  String get workspaceWaitingForPayment => 'Čekání na platbu';

  @override
  String get workspaceActionNeeded => 'Potřebné kroky';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Platby k označení jako odeslané: $arg1; k potvrzení jako přijaté: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Připraveni k vypořádání';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Všichni členové jsou připraveni. Můžete zahájit vyúčtování.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Čeká se, až všichni označí, že jsou připraveni.';

  @override
  String get workspaceIMReady => 'Jsem připraven';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Ověřte, zda jste zadali všechny své výdaje.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Tlačítko „Dokončit“ se odemkne, jakmile všichni označí, že jsou připraveni.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Má dostat peníze od skupiny';

  @override
  String get workspaceSettledWithTheGroup => 'Dohodnuto se skupinou';

  @override
  String get workspaceTotalPaid => 'Celková zaplacená částka';

  @override
  String get workspaceTotalOwes => 'Celková dlužná částka';

  @override
  String get workspaceTransactionHistory => 'Historie transakcí';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'U tohoto člena zatím nebyly provedeny žádné transakce.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Vyúčtování: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Všichni členové musí před zahájením vyúčtování označit, že jsou připraveni.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Označili jste se jako připraveni k vypořádání.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Označení „Připraveno k vypořádání“ bylo odstraněno.';

  @override
  String get workspaceReminderSent => 'Byla odeslána upomínka.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Pozvánkový odkaz nebo přidání z přátel';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Tuto cestu může upravovat pouze její tvůrce.';

  @override
  String get workspaceTripUpdated => 'Cesta aktualizována.';

  @override
  String get workspaceFailedToUpdateTrip => 'Aktualizace cesty se nezdařila.';

  @override
  String get workspaceNoMembersSelectedYet => 'Zatím nebyli vybráni žádní členové.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Bez připojení k internetu. Výdaj bude uložen bez snímku účtenky.';

  @override
  String get workspaceRandomPicker => 'Náhodný výběr';

  @override
  String get workspaceCurrency => 'Měna';

  @override
  String get workspaceCategory => 'Kategorie';

  @override
  String get workspaceCustomCategory => 'Vlastní kategorie';

  @override
  String get workspaceCategoryName => 'Název kategorie';

  @override
  String get workspaceApartmentRentParkingEtc => 'Nájem bytu, parkování atd.';

  @override
  String get workspaceEnterACustomCategory => 'Zadejte vlastní kategorii.';

  @override
  String get workspacePickAnExpenseCategory => 'Vyberte kategorii výdajů.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Kategorie musí mít alespoň 2 znaky.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Název kategorie musí mít maximálně 64 znaků.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Součet procentuálních podílů musí činit 100 %.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Počet podílů musí být u každého účastníka větší než 0.';

  @override
  String get workspaceTotalAmount => 'Celková částka';

  @override
  String get workspaceOriginal => 'Originál';

  @override
  String get workspaceTotalCost => 'Celkové náklady';

  @override
  String workspaceStarted(Object arg1) {
    return 'Spuštěno $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Ukončeno $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Archivovaná cesta';

  @override
  String get workspaceActiveTrip => 'Aktivní výlet';

  @override
  String get workspaceMemberProfile => 'Profil člena';

  @override
  String get workspaceTripOwner => 'Organizátor cesty';

  @override
  String get workspaceMember => 'Člen';

  @override
  String get workspaceReadyForSettlement => 'Připraveno k vyúčtování';

  @override
  String get workspaceNotReadyForSettlement => 'Není připraveno k vypořádání';

  @override
  String get workspaceBankDetails => 'Bankovní údaje';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'Údaje o čísle IBAN a výplatě budou přidány v příští aktualizaci.';

  @override
  String get workspacePaymentDetails => 'Údaje o platbě';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Tento člen zatím nezadal údaje pro výplatu.';

  @override
  String get workspaceBankTransfer => 'Bankovní převod';

  @override
  String get workspaceHolder => 'Držitel';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Nelze otevřít odkaz na platbu.';

  @override
  String get workspaceTripActivity => 'Aktivita výletu';

  @override
  String get workspacePaidExpenses => 'Proplacené výdaje';

  @override
  String get workspacePaidTotal => 'Celková zaplacená částka';

  @override
  String get workspaceInvolvedIn => 'Zapojeno do';

  @override
  String get workspaceCurrentTrip => 'Aktuální výlet';

  @override
  String get workspaceCommonTrips => 'Společné cesty';

  @override
  String get workspaceLoadingCommonTrips => 'Načítání společných cest…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Zatím nebyly nalezeny žádné společné cesty.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Nepodařilo se načíst všechny společné cesty. Zobrazuje se aktuální cesta.';

  @override
  String get workspaceMembers => 'členové';

  @override
  String get workspaceExpense => 'Výdaje';

  @override
  String get workspacePaid => 'placené';

  @override
  String get workspaceLoadingMoreExpenses => 'Načítání dalších výdajů...';

  @override
  String get workspaceScrollDownToLoadMore => 'Přejděte dolů a načtěte další informace';

  @override
  String get workspaceTripFinished => 'Cesta skončila';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Pro tuto cestu jsou odemčeny vyúčtování.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Dokončete výlet, abyste mohli zahájit vyúčtování.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 označil převod jako odeslaný.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Čeká se na označení $arg1 jako zaplacené.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 potvrdil přijetí platby.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Čeká se na potvrzení od $arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Všechny vyúčtování výletů jsou zcela dokončeny.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Konečný stav po potvrzení všech převodů.';

  @override
  String get workspaceSettlementFlow => 'Průběh vypořádání';

  @override
  String get workspaceActions => 'Akce';

  @override
  String get workspaceQuickPay => 'Rychlá platba';

  @override
  String get workspacePayWithRevolut => 'Plaťte přes Revolut';

  @override
  String get workspacePayWithPaypal => 'Plaťte přes PayPal';

  @override
  String get workspacePayWithWise => 'Plaťte přes Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Převod je potvrzen.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Čeká se, až druhý člen dokončí další krok.';

  @override
  String get workspaceSendReminder => 'Odeslat připomenutí';

  @override
  String get workspaceInProgress => 'Probíhá';

  @override
  String get workspaceTimeUnknown => 'Čas neznámý';

  @override
  String get workspaceRemind => 'Připomenutí';

  @override
  String get workspaceYourPosition => 'Vaše pozice';

  @override
  String get workspaceRecentActivity => 'Nedávná aktivita';

  @override
  String get workspaceNoRecentActivityYet => 'Zatím žádná nedávná aktivita.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Přidejte alespoň jednoho člena, abyste mohli začít rozdělovat výdaje.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Po přidání všech výdajů se označte jako připravený k vyúčtování.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Účastníci, kteří ještě nejsou připraveni: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Všichni členové jsou připraveni. Můžete výlet ukončit a zahájit vyúčtování.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Všichni členové jsou připraveni. Čeká se na organizátora cesty, aby zahájil vyúčtování.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Probíhá vypořádání: $arg1 / $arg2 potvrzeno.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Žádné nevyřízené akce. Tato cesta je vyřízena.';

  @override
  String get workspaceNoActionsNeededRightNow => 'V tuto chvíli není třeba podnikat žádné kroky.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Měli byste obdržet $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Měli byste zaplatit $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'V současné době jste zařazeni do této cesty.';

  @override
  String get workspaceUnknownTime => 'Neznámý čas';

  @override
  String get workspaceJustNow => 'Právě teď';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'Před $arg1 min';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'Před $arg1 h';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'Před $arg1 d';
  }

  @override
  String get friendsRemoveFriend => 'Odstranit přítele';

  @override
  String get friendsRemoveThisFriend => 'Odstranit tohoto přítele?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 bude odstraněn z vašeho seznamu přátel. Později jej můžete přidat znovu.';
  }

  @override
  String get friendsContinue => 'Pokračovat';

  @override
  String get friendsFriendRemoved => 'Přítel byl odstraněn.';

  @override
  String get friendsCouldNotRemoveFriend => 'Nepodařilo se odstranit přítele.';

  @override
  String get friendsFriendProfile => 'Profil přítele';

  @override
  String get friendsMoreActions => 'Další akce';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Tento přítel ještě nezadal údaje pro výplatu.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Společné cesty se nyní nepodařilo načíst.';

  @override
  String get friendsFinished => 'Dokončeno';

  @override
  String friendsTrip(Object arg1) {
    return 'Výlet č. $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Členové: $arg1';
  }

  @override
  String get friendsNoDate => 'Žádné datum';

  @override
  String get friendsIncomingRequests => 'PŘICHÁZEJÍCÍ ŽÁDOSTI';

  @override
  String get friendsSentInvites => 'ODESLANÉ POZVÁNKY';

  @override
  String get friendsMyFriends => 'MOJI PŘÁTELÉ';

  @override
  String get friendsRequests => 'Žádosti';

  @override
  String get friendsIncoming => 'Příchozí';

  @override
  String get friendsIncomingRequestSubtitle => 'chce být přáteli';

  @override
  String get friendsOutgoingInviteSubtitle => 'Pozvánka odeslána';

  @override
  String get friendsNoPendingActivity => 'Žádné žádosti o přátelství';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Pozvánka odeslána $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Žádné příchozí žádosti';

  @override
  String get friendsDecline => 'Odmítnout';

  @override
  String get friendsAccept => 'Přijmout';

  @override
  String get friendsNoSentInvites => 'Žádné odeslané pozvánky';

  @override
  String get friendsNoFriendsYet => 'Zatím žádní přátelé';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Přejděte dolů a načtěte další přátele.';

  @override
  String get friendsUser => 'Uživatel';

  @override
  String get friendsSearchUsers => 'Vyhledávání uživatelů';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Vyhledejte podle jména nebo e-mailu a odešlete pozvánku';

  @override
  String get friendsScanQr => 'Naskenujte QR kód';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Naskenujte jiného uživatele a přidejte si ho jako přítele';

  @override
  String get friendsMyQr => 'Můj QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Zobrazte nebo sdílejte svůj QR kód';

  @override
  String get friendsScanFriendQrTitle => 'Naskenujte QR kód přítele';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Umístěte QR kód přítele do rámečku';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Držte QR kód uvnitř rámečku';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Přidat $arg1 jako přítele?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 obdrží vaši žádost o přátelství.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Přijmout žádost o přátelství od $arg1?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Naskenujte tento QR kód nebo sdílejte odkaz, abyste mě přidali na Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Přidejte si mě na Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Odkaz na přítele ve Splyto';

  @override
  String get shareAction => 'Sdílet';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'QR kód není platným kódem pro přidání do seznamu přátel.';

  @override
  String get friendsYouCannotAddYourself => 'Nemůžete přidat sami sebe.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Tento uživatel je již ve vašem seznamu přátel.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Pozvánka tomuto uživateli již byla odeslána.';

  @override
  String get friendsFriendRequestProcessed => 'Žádost o přátelství byla zpracována.';

  @override
  String get friendsFailedToProcessFriendQr => 'Zpracování QR kódu přítele se nezdařilo.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Nepodařilo se načíst váš uživatelský profil.';

  @override
  String get friendsMyProfile => 'Můj profil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Došlo k neočekávané chybě při načítání přátel.';

  @override
  String get friendsFriendAdded => 'Přidán přítel.';

  @override
  String get friendsRequestDeclined => 'Žádost zamítnuta.';

  @override
  String get friendsFailedToUpdateRequest => 'Aktualizaci žádosti se nepodařilo provést.';

  @override
  String get friendsCancelInvite => 'Zrušit pozvánku';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Zrušit pozvánku pro $arg1?';
  }

  @override
  String get friendsKeep => 'Ponechat';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Pozvánka na $arg1 byla zrušena.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Zrušení pozvánky se nezdařilo.';

  @override
  String get analyticsOther => 'Ostatní';

  @override
  String get analyticsSelectATripForAnalytics => 'Vyberte výlet pro analýzu';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Členové: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Denní výdaje';

  @override
  String get analyticsMyDaily => 'Moje denní výdaje';

  @override
  String get analyticsGroupDaily => 'Denní výdaje skupiny';

  @override
  String get analyticsByMember => 'Podle účastníka';

  @override
  String get analyticsShowLess => 'Zobrazit méně';

  @override
  String get analyticsByCategory => 'Podle kategorie';

  @override
  String get analyticsQuickInsights => 'Stručné informace';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Největší výdaj: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Největší utráceč: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Nejvyšší denní počet členů ve skupině: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Žádná data';

  @override
  String get friendsSearchFailedTryAgain => 'Vyhledávání se nezdařilo. Zkuste to znovu.';

  @override
  String get friendsFailedToSendInvite => 'Odeslání pozvánky se nezdařilo.';

  @override
  String get friendsAddFriend => 'Přidat přítele';

  @override
  String get friendsSearchByNameOrEmail => 'Vyhledávání podle jména nebo e-mailu';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Pro vyhledávání zadejte alespoň 2 znaky.';

  @override
  String get friendsNoUsersFound => 'Nebyli nalezeni žádní uživatelé';

  @override
  String get friendsInviteAction => 'Pozvat';

  @override
  String get workspacePaidForGroup => 'Placená skupina';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Zaplaceno za skupinu • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Rozdělení nákladů';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Rozdělení nákladů • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Jméno držitele zkopírováno.';

  @override
  String get paymentIbanCopied => 'IBAN zkopírován.';

  @override
  String get paymentSwiftCopied => 'SWIFT zkopírováno.';

  @override
  String get paymentRevtagCopied => 'Revtag zkopírován.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Nelze zkopírovat do schránky.';

  @override
  String get paymentCopied => 'Zkopírováno.';

  @override
  String get paymentRequestAction => 'Žádost o platbu';

  @override
  String get paymentRecordAction => 'Zaznamenat platbu';

  @override
  String get paymentRequestSheetTitle => 'Žádost o platbu';

  @override
  String get paymentRecordSheetTitle => 'Zaznamenat platbu';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Požádejte $arg1, aby zaplatil částku, kterou vám v současné době dluží.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Tuto funkci použijte poté, co jste zaplatili $arg1 mimo Splyto. Ten potvrdí její přijetí.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Maximálně $arg1';
  }

  @override
  String get paymentNoteHint => 'Bankovní převod, Revolut, hotovost...';

  @override
  String get paymentAmountPositiveError => 'Částka musí být větší než nula.';

  @override
  String get paymentAmountTooHighError => 'Částka nesmí být vyšší než nesplacený zůstatek.';

  @override
  String get paymentRequestCreated => 'Žádost o platbu odeslána.';

  @override
  String get paymentRecordedWaiting => 'Platba zaznamenána. Čeká se na potvrzení.';

  @override
  String get paymentConfirmTitle => 'Potvrďte platbu';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Potvrďte, že jste obdrželi $arg1 od $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Platba potvrzena.';

  @override
  String get paymentCancelRecordTitle => 'Zrušit záznam o platbě';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Zrušit záznam tvé platby ve výši $arg1 osobě $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Záznam o platbě byl zrušen.';

  @override
  String get paymentNotReceivedTitle => 'Platba nebyla přijata';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Označit platbu $arg1 od $arg2 jako nepřijatou?';
  }

  @override
  String get paymentMarkedNotReceived => 'Platba označena jako nepřijatá.';

  @override
  String get paymentActivityTitle => 'Platební činnost';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Otevřené žádosti o platbu: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Platby čekající na potvrzení: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Zaznamenané platby';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 požádal o platbu od $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 zaplatil $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Žádost o platbu';

  @override
  String get paymentAwaitingConfirmationStatus => 'Čeká se na potvrzení';

  @override
  String get paymentReviewRequestAction => 'Žádost o přezkoumání';

  @override
  String get paymentViewDetailsAction => 'Údaje o platbě';

  @override
  String get paymentMarkPaidAction => 'Zaplatil jsem';

  @override
  String get paymentDeclineAction => 'Odmítnout';

  @override
  String get paymentRequestReviewTitle => 'Žádost o platbu';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 vás požádal o $arg2. Proveďte platbu mimo Splyto a poté ji označte jako zaplacenou.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Označit žádost jako zaplacenou?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Potvrď až poté, co mimo Splyto zaplatíš osobě $arg2 částku $arg1.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Označeno jako zaplacené. Čeká se na potvrzení.';

  @override
  String get paymentRequestCancelTitle => 'Zrušit žádost o platbu?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Chcete zrušit svou žádost $arg1 adresovanou $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Žádost o platbu byla zrušena.';

  @override
  String get paymentRequestDeclineTitle => 'Odmítnout žádost o platbu?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Odmítnout žádost o platbu ve výši $arg1 od osoby $arg2? Tato osoba dostane oznámení.';
  }

  @override
  String get paymentRequestDeclined => 'Žádost o platbu byla zamítnuta.';

  @override
  String get paymentPendingBeforeFinish => 'Vyřešte otevřené platební žádosti a nepotvrzené platby před konečným vyúčtováním.';

  @override
  String get paymentFinishBlockedByPending => 'Dokončení se odemkne až po vyřešení žádostí o platbu a nepotvrzených plateb.';

  @override
  String get notificationPaymentRequestedTitle => 'Žádost o platbu';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 vás požádal o $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Obdrželi jste žádost o platbu.';

  @override
  String get notificationPaymentRequestSentTitle => 'Požadovaná platba odeslána';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 označil vaši žádost o platbu $arg2 jako uhrazenou.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Vaše žádost o platbu byla označena jako uhrazená.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Žádost o platbu byla zrušena';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 zrušil žádost o platbu $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Žádost o platbu byla zrušena.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Žádost o platbu byla zamítnuta';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 odmítl vaši žádost o platbu $arg2.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Vaše žádost o platbu byla zamítnuta.';

  @override
  String get notificationPaymentSentTitle => 'Platba označena jako odeslaná';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 označil $arg2 jako zaplacené vám.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Byla vám označena platba jako odeslaná.';

  @override
  String get notificationPaymentConfirmedTitle => 'Platba potvrzena';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 potvrdil, že od vás obdržel $arg2.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Vaše platba byla potvrzena.';

  @override
  String get notificationPaymentCancelledTitle => 'Platba zrušena';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 zrušil označení platby $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Značka platby byla zrušena.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Platba nebyla přijata';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 označil platbu $arg2 jako nepřijatou.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Platba byla označena jako nepřijatá.';

  @override
  String get quickStartTitle => 'Rychlý start';

  @override
  String get quickStartCreateTitle => 'Sami nebo s přáteli';

  @override
  String get quickStartCreateBody => 'Vytvořte výlet pro sebe nebo skupinu. Přidejte přátele odkazem nebo QR kódem a pozvěte je.';

  @override
  String get quickStartInviteTitle => 'Cestujte společně nebo sami';

  @override
  String get quickStartInviteBody => 'Pozvěte přátele, aby se k vaší cestě připojili, nebo si sami založte vlastní cestu.';

  @override
  String get quickStartExpenseTitle => 'Výdaje v mnoha měnách';

  @override
  String get quickStartExpenseBody => 'Zvolte, kdo platil a jak se má částka rozdělit. Jiné měny se převádějí podle kurzu z data nákupu, i když je přidáte později.';

  @override
  String get quickStartSettleTitle => 'Vyrovnejte se snadno';

  @override
  String get quickStartSettleBody => 'Podívejte se, kdo komu dluží, zaplaťte, jak vám vyhovuje, a potvrďte to v aplikaci.';

  @override
  String get quickStartAnalyticsTitle => 'Rozpočet a výdaje';

  @override
  String get quickStartAnalyticsBody => 'Nastavte rozpočet pro výlet nebo skupinu a sledujte výdaje podle kategorií, výletů a dnů.';

  @override
  String get quickStartMapTitle => 'Uložte si svá místa';

  @override
  String get quickStartMapBody => 'Přidejte navštívená města na svou soukromou cestovní mapu. Vidíte ji jen vy.';

  @override
  String get quickStartLiveTitle => 'Najděte se navzájem';

  @override
  String get quickStartLiveBody => 'Na skupinových výletech sdílejte svou polohu živě po zvolenou dobu. Vidí ji členové výletu a můžete ji kdykoli ukončit.';

  @override
  String get quickStartNext => 'Další';

  @override
  String get quickStartBack => 'Zpět';

  @override
  String get quickStartSkip => 'Přeskočit';

  @override
  String get quickStartCreateAction => 'Vytvořit výlet';

  @override
  String get quickStartSignUpAction => 'Zaregistrovat se';

  @override
  String get quickStartClose => 'Zavřít Rychlý start';

  @override
  String get quickStartSubtitle => 'Podívejte se, jak fungují výlety a výdaje';

  @override
  String quickStartStep(int step, int total) {
    return 'Krok $step z $total';
  }

  @override
  String get workspaceTripTotal => 'Celková částka za výlet';

  @override
  String get workspacePersonalTotal => 'Celková částka utracená';

  @override
  String get workspaceBalanceEven => 'Tvůj zůstatek je vyrovnaný';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Dlužíš $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Dostaneš zpět $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Členové: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Vyhledávání výdajů';

  @override
  String get workspaceClearSearch => 'Čisté vyhledávání';

  @override
  String get workspaceSearchLoadedHint => 'Vyhledávání zahrnuje načtené výdaje. Načtěte další, chcete-li zahrnout starší výdaje.';

  @override
  String get workspaceNoExpenseMatches => 'Žádné odpovídající výdaje';

  @override
  String get workspaceNoExpenseMatchesBody => 'Zkuste jiné vyhledávání nebo vymažte vyhledávání, abyste viděli všechny načtené výdaje.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Přidejte svůj první výdaj a začněte sledovat své výdaje.';

  @override
  String get workspaceEmptyGroupExpenses => 'Přidejte svůj první sdílený výdaj, abyste viděli podíl každého účastníka.';

  @override
  String get workspaceLoadMoreExpenses => 'Načíst další výdaje';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Původní částka: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Komentáře: $count';
  }

  @override
  String get workspaceExpenseActions => 'Úkony související s výdaji';

  @override
  String get workspaceLoadErrorTitle => 'Tento výlet se nepodařilo načíst';

  @override
  String get workspaceCachedWarning => 'Zobrazení uložených údajů. Mohou být zastaralé.';

  @override
  String get workspaceActivityTab => 'Aktivita';

  @override
  String get workspaceLoadingTrip => 'Načítání cesty';

  @override
  String get workspaceRefreshFailed => 'Obnovení se nezdařilo';

  @override
  String get expenseDetailsTitle => 'Podrobnosti o výdajích';

  @override
  String get expenseQuickCategories => 'Rychlé kategorie';

  @override
  String get expenseReceiptUploading => 'Nahrávání účtenky…';

  @override
  String get expenseReceiptUploadOnSave => 'Účtenka se nahraje při uložení.';

  @override
  String get expenseCommentsLoadFailed => 'Nepodařilo se načíst komentáře. Zkuste to znovu.';

  @override
  String get expenseReplyAction => 'Odpovědět';

  @override
  String get expenseReplyHint => 'Napište odpověď…';

  @override
  String expenseReplyTo(String name) {
    return 'Odpovězte $name';
  }

  @override
  String get balanceEmptyBody => 'Zůstatky se zobrazí po přidání výdajů.';

  @override
  String get balanceAfterPayments => 'Zůstatky zahrnují potvrzené platby.';

  @override
  String get balanceExpenseShare => 'Sdílení výdajů';

  @override
  String get balanceHistoryScope => 'Nahrané výdaje a potvrzené platby. Tento seznam nemusí obsahovat celou historii cesty.';

  @override
  String balancePaymentTo(String name) {
    return 'Platba pro $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Platba od $name';
  }

  @override
  String get settlementEmptyActive => 'Před zahájením konečného vyúčtování označte všechny účastníky jako připravené.';

  @override
  String get settlementEmptyClosed => 'U této cesty nejsou uvedeny žádné převody.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count z $total převodů potvrzeno';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count z $total členů je připraveno';
  }

  @override
  String get settlementMemberReady => 'Hotovo';

  @override
  String get settlementMemberNotReady => 'Není připraveno';

  @override
  String get settlementSuggested => 'Doporučený převod';

  @override
  String get activityLoadFailed => 'Nelze aktualizovat aktivitu. Veškeré zobrazené záznamy mohou být zastaralé.';

  @override
  String get activityMember => 'Účastník cesty';

  @override
  String get friendsEmptyBody => 'Vyhledejte přítele podle jména nebo e-mailu, případně použijte QR kód.';

  @override
  String get friendsDeclineAction => 'Odmítnout';

  @override
  String get friendsLoading => 'Načítání přátel';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Sdílené výlety: $count';
  }

  @override
  String get memberActivityScope => 'Na základě zadaných výdajů; nemusí to pokrývat celou cestu.';

  @override
  String get sharedTripsLoadedLimit => 'Zobrazuje se až 20 sdílených výletů.';

  @override
  String get memberRemoveTitle => 'Odstranit člena?';

  @override
  String memberRemoveBody(String name) {
    return 'Odstranit $name z této cesty? To je možné pouze v případě, že nemá žádné výdaje, vyúčtování ani zůstatky.';
  }

  @override
  String get memberRemoveAction => 'Odstranit z cesty';

  @override
  String memberRemoved(String name) {
    return '$name byl/a odstraněn/a z cesty.';
  }

  @override
  String get profilePaymentNotAdded => 'Zatím nepřidáno';

  @override
  String get friendRelationshipLabel => 'Přítel';

  @override
  String get sharedTripsEmptyBody => 'Zde se zobrazí výlety, ke kterým se oba připojíte.';

  @override
  String get analyticsAllTrips => 'Všechny výlety';

  @override
  String get analyticsByTrip => 'Podle cesty';

  @override
  String get analyticsYourSpending => 'Tvoje výdaje';

  @override
  String get analyticsActiveArchived => 'Aktivní a archivované výlety';

  @override
  String get analyticsTrips => 'Výlety';

  @override
  String get analyticsAveragePerTrip => 'Průměr na jednu cestu';

  @override
  String get analyticsPaidByMember => 'Hradí člen';

  @override
  String get analyticsYouPaid => 'Zaplatil jsi.';

  @override
  String get analyticsYouGetBack => 'Dostaneš zpět';

  @override
  String get analyticsYouOwe => 'Dlužíš';

  @override
  String get analyticsParticipants => 'Účastníci';

  @override
  String get analyticsYourCategories => 'Vaše výdaje podle kategorií';

  @override
  String get analyticsLargestShares => 'Moje největší podíly na výdajích';

  @override
  String get analyticsLargestExpenses => 'Největší výdaje';

  @override
  String get analyticsSpendingByTrip => 'Vaše výdaje podle cesty';

  @override
  String get analyticsEmptyTitle => 'Zatím žádné výdaje';

  @override
  String get analyticsEmptyBody => 'Vaše výdaje se zde zobrazí, jakmile k cestě přidáte výdaje.';

  @override
  String get analyticsPeriodEmptyBody => 'Pro tento pohled nejsou žádné výdaje. Zkuste jiný výlet nebo období.';

  @override
  String get analyticsLoadFailed => 'Nepodařilo se načíst kompletní přehled výdajů. Zkuste to prosím znovu.';

  @override
  String get analyticsLastLoaded => 'Zobrazuje se poslední úspěšně načtená zpráva.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdajů',
      few: '$count výdaje',
      one: '$count výdaj',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Možnosti cesty';

  @override
  String get editTripAction => 'Upravit výlet';

  @override
  String get deleteTripAction => 'Odstranit výlet';

  @override
  String get inviteTripMembersAction => 'Pozvěte členy';

  @override
  String get tripCoverPhoto => 'Úvodní fotografie';

  @override
  String get tripInviteLaterHint => 'Lidi můžete pozvat až po vytvoření výletu.';

  @override
  String get inviteClipboardFailed => 'Nelze získat přístup ke schránce. Zkuste to znovu.';

  @override
  String get friendInviteToTrip => 'Pozvat na výlet';

  @override
  String get friendChooseTrip => 'Vyberte výlet';

  @override
  String get friendNoInvitableTrips => 'Žádné dostupné výlety. Můžete pozvat přátele do aktivních skupinových výletů, které spravujete, pokud již nejsou členy nebo nemají pozvánku v čekání.';

  @override
  String get friendTripInviteSent => 'Pozvánka odeslána.';

  @override
  String get friendTripUnavailable => 'Tento výlet již není pro tuto akci k dispozici. Obnovte stránku a zkuste to znovu.';

  @override
  String get friendTripActionFailed => 'Tuto akci nebylo možné dokončit. Zkuste to znovu.';

  @override
  String get profileContactDescription => 'Máte problém, návrh nebo dotaz ohledně Splyto? Napište nám e-mail – rádi vám pomůžeme.';

  @override
  String get profileContactEmailAction => 'Napište e-mail';

  @override
  String get profileContactEmailUnavailable => 'Nepodařilo se otevřít e-mailovou aplikaci. Zkopírujte adresu a napište nám ze své e-mailové aplikace.';

  @override
  String get profilePrivacyPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get privacyLoadFailed => 'Nepodařilo se načíst zásady ochrany osobních údajů. Zkuste to prosím znovu.';

  @override
  String get addReceiptAction => 'Přidat účtenku';

  @override
  String get receiptPickFailed => 'Nepodařilo se načíst účtenku. Zkuste to prosím znovu.';

  @override
  String get receiptPhotoAccessDenied => 'V nastaveních povolte aplikaci Splyto přístup k fotoaparátu nebo knihovně fotografií a zkuste to znovu.';

  @override
  String get receiptPhotoLabel => 'Fotografie účtenky';

  @override
  String get replaceReceiptAction => 'Nahraďte potvrzení';

  @override
  String get removeReceiptAction => 'Odstranit potvrzení';

  @override
  String get restoreReceiptAction => 'Obnovit předchozí potvrzení';

  @override
  String get expenseSplitBetween => 'Rozdělení mezi';

  @override
  String get expenseEditParticipants => 'Vyberte účastníky';

  @override
  String get expenseCustomSplit => 'Vlastní rozdělení';

  @override
  String get expenseAdjustmentsLabel => 'Úpravy';

  @override
  String get expenseAdjustmentFieldLabel => '+ nebo −';

  @override
  String get expenseAdjustmentsHint => 'Každé osobě přičtěte nebo odečtěte. Zbytek se rozdělí rovným dílem.';

  @override
  String get expenseAdjustmentsMustFit => 'Úpravy nesmí překročit celkovou částku a nikdo nesmí dlužit méně než nula.';

  @override
  String get expenseItemsLabel => 'Položky';

  @override
  String get expenseAddItem => 'Přidat položku';

  @override
  String get expenseRemoveItem => 'Odebrat položku';

  @override
  String get expenseItemName => 'Položka';

  @override
  String get expenseItemExtra => 'Daň nebo spropitné';

  @override
  String get expenseItemExtraHint => 'Rozdělí se poměrně podle položek každé osoby.';

  @override
  String get expenseItemsInvalid => 'Každá položka potřebuje název, částku a alespoň jednu osobu.';

  @override
  String expenseItemsTotal(String total) {
    return 'Celkem z položek: $total';
  }

  @override
  String expenseItemsMustMatchTotal(String total) {
    return 'Položky musí dát dohromady $total.';
  }

  @override
  String get tripGuestAddAction => 'Přidat osobu bez aplikace';

  @override
  String get tripGuestNameLabel => 'Jméno';

  @override
  String get tripGuestAddHint => 'Tato osoba aplikaci nepotřebuje. Vy zadáváte, co zaplatila, a označujete její platby.';

  @override
  String get tripGuestBadge => 'Bez aplikace';

  @override
  String get tripGuestRenameAction => 'Změnit jméno';

  @override
  String tripGuestAdded(String name) {
    return 'Přidáno: $name';
  }

  @override
  String expenseSplitAllocated(String amount) {
    return 'Celá částka $amount rozdělena';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Zbývá rozdělit $amount';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount nad celkovou částku';
  }

  @override
  String get profilePaymentSharingTitle => 'Sdílet platební metody s mými výlety';

  @override
  String get profilePaymentSharingDescription => 'Umožnit schváleným účastníkům cest, které vytvářím nebo ke kterým se připojuji, zobrazit moje platební metody. Platí to pro současné i budoucí cesty. Sdílení můžeš kdykoli vypnout a zabránit tak dalšímu přístupu.';

  @override
  String get memberPaymentDetailsNotShared => 'Způsoby platby nejsou sdíleny nebo nejsou v současné době k dispozici.';

  @override
  String get homeTripInvitations => 'Pozvánky na výlet';

  @override
  String get homeNoTripInvitations => 'Žádné nevyřízené pozvánky na výlet';

  @override
  String get homeInvitationsLoadFailed => 'Nepodařilo se načíst pozvánky. Zkuste to prosím znovu.';

  @override
  String get homeInvitationResponseFailed => 'Nebylo možné odpovědět na pozvánku. Zkuste to prosím znovu.';

  @override
  String get homeTripShareFailed => 'Cestu se nepodařilo sdílet. Zkuste to prosím znovu.';

  @override
  String get settleStillToReceive => 'Zbývá obdržet';

  @override
  String get settleStillToPay => 'Ještě k zaplacení';

  @override
  String get settleEstimateCaption => 'Odhad vychází z aktuálních výdajů. Částky se mohou měnit až do konce cesty.';

  @override
  String get settleOutstandingCaption => 'Čeká se na platbu nebo potvrzení.';

  @override
  String get settleWaitingForYou => 'Čekáme, až označíte, že jste připraveni.';

  @override
  String get settleWhoPaysWhom => 'Kdo komu platí';

  @override
  String get settlePreviewCaption => 'Náhled · dokončeno po skončení cesty';

  @override
  String get settleOpenPaymentCaption => 'Otevřete platbu, abyste si prohlédli podrobnosti a dostupné akce.';

  @override
  String get tripBudgetEnable => 'Stanovte rozpočet';

  @override
  String get tripBudgetSoloHint => 'Volitelný cíl výdajů pro tuto cestu.';

  @override
  String get tripBudgetGroupHint => 'Jeden sdílený rozpočet pro celou skupinu.';

  @override
  String get tripBudgetAmount => 'Výše rozpočtu';

  @override
  String get tripBudgetInvalid => 'Zadejte částku od 0,01 do 999999999,99 s maximálně dvěma desetinnými místy.';

  @override
  String get tripBudgetTitle => 'Rozpočet cesty';

  @override
  String get tripBudgetGroupTitle => 'Skupinový rozpočet';

  @override
  String get tripBudgetRemaining => 'Zbývající';

  @override
  String get tripBudgetOver => 'Překročení rozpočtu';

  @override
  String get tripBudgetSpent => 'Utraceno';

  @override
  String get tripBudgetLimit => 'Rozpočet';

  @override
  String get travelMapTitle => 'Moje cestovní mapa';

  @override
  String get travelMapSubtitle => 'Navštívená místa, jen pro vás.';

  @override
  String get travelMapHere => 'Už jsem tu byl';

  @override
  String get travelMapAdd => 'Přidat místo';

  @override
  String get travelMapSearch => 'Vyhledat město a zemi';

  @override
  String get travelMapSearchAction => 'Vyhledávání';

  @override
  String get travelMapSearchHint => 'Například Lisabon, Portugalsko';

  @override
  String get travelMapEmpty => 'Vaše další vzpomínka začíná právě zde';

  @override
  String get travelMapEmptyBody => 'Přidejte město, které jste navštívili, nebo se přihlaste tam, kde právě jste.';

  @override
  String get travelMapConfirm => 'Uložit tuto návštěvu?';

  @override
  String get travelMapConfirmBody => 'Před uložením do své soukromé mapy zkontrolujte město a datum.';

  @override
  String get travelMapDate => 'Datum návštěvy';

  @override
  String get travelMapSave => 'Uložit na mou mapu';

  @override
  String get travelMapCancel => 'Zrušit';

  @override
  String get travelMapClose => 'Zavřít';

  @override
  String get travelMapNoResults => 'Nebylo nalezeno žádné město. Zkuste do vyhledávání přidat zemi.';

  @override
  String get travelMapLookupError => 'Město nebylo nalezeno. Zkontrolujte připojení nebo místo přidejte ručně.';

  @override
  String get travelMapDenied => 'Přístup k poloze je vypnutý. Město můžete i nadále přidat ručně.';

  @override
  String get travelMapDisabled => 'Zapněte služby určování polohy nebo ručně přidejte město.';

  @override
  String get travelMapError => 'Nepodařilo se načíst vaši cestovní mapu. Zkuste to prosím znovu.';

  @override
  String get travelMapSaveError => 'Návštěvu se nepodařilo uložit. Zkuste to prosím znovu.';

  @override
  String get travelMapUnavailable => 'Cestovní mapa vyžaduje aktualizaci serveru.';

  @override
  String get travelMapOffline => 'Offline · zobrazení uložených míst';

  @override
  String get travelMapRetry => 'Zkuste to znovu';

  @override
  String get travelMapDelete => 'Odstranit návštěvu';

  @override
  String get travelMapDeleteConfirm => 'Chcete tuto návštěvu odstranit ze své soukromé mapy?';

  @override
  String get travelMapFit => 'Zobrazit všechna místa';

  @override
  String get travelMapSaved => 'Navštivte uložené';

  @override
  String get travelMapVisited => 'Navštívené';

  @override
  String get travelMapLimit => 'Vaše mapa dosáhla 1 000 návštěv. Před přidáním další návštěvy odstraňte starou.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries zemí',
      few: '$countries země',
      one: '$countries země',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities měst',
      few: '$cities města',
      one: '$cities město',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count návštěv',
      few: '$count návštěvy',
      one: '$count návštěva',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Cíle (volitelné)';

  @override
  String get travelAddDestination => 'Přidat cíl';

  @override
  String get travelRemoveDestination => 'Odebrat cíl';

  @override
  String get travelFromTrip => 'Z výletu';

  @override
  String get travelChooseTrip => 'Vyberte výlet';

  @override
  String get travelNoTrips => 'Zatím nejsou k dispozici žádné výlety. Místo můžete přidat ručně.';

  @override
  String get travelAddToMap => 'Přidat na mou mapu';

  @override
  String get travelTripConfirm => 'Ukládejte pouze místa, která jste skutečně navštívili. Tím na své mapě vytvoříte soukromou vzpomínku.';

  @override
  String get travelVisitTitle => 'Název (volitelné)';

  @override
  String get travelAddPhoto => 'Přidejte fotografii';

  @override
  String get travelChangePhoto => 'Změnit fotografii';

  @override
  String get travelRemovePhoto => 'Odstranit fotografii';

  @override
  String get travelPhotoError => 'Tuto fotografii se nepodařilo připravit. Vyberte prosím jinou.';

  @override
  String get travelEditVisit => 'Upravit návštěvu';

  @override
  String get travelOpenTrip => 'Otevřít výlet';

  @override
  String get travelPreviousVisit => 'Předchozí návštěva';

  @override
  String get travelNextVisit => 'Příští návštěva';

  @override
  String get travelDuplicate => 'Tato návštěva je již na vaší mapě.';

  @override
  String get liveMapTitle => 'Mapa v reálném čase';

  @override
  String get liveShareTitle => 'Sdílet mou polohu';

  @override
  String get liveConsent => 'Sdílej svou přesnou polohu pouze se schválenými účastníky této cesty po dobu, kterou si zvolíš. Sdílení pokračuje na pozadí a můžeš ho kdykoli ukončit.';

  @override
  String get liveBackgroundNote => 'Aktualizace se mohou pozastavit bez připojení k internetu nebo pokud aplikaci násilně ukončíte. Uchovává se pouze poslední poloha; historie trasy se nezaznamenává.';

  @override
  String get liveStart => 'Začít sdílet';

  @override
  String get liveStop => 'Zastavit sdílení';

  @override
  String get liveNotification => 'Vaše poloha je sdílená s účastníky vaší cesty. Chcete-li sdílení zastavit, otevřete aplikaci Splyto.';

  @override
  String get livePermissionError => 'Povol přístup k poloze v nastavení telefonu, abys mohl(a) sdílet svou polohu.';

  @override
  String get liveStartError => 'Sdílení se nepodařilo spustit. Zkontrolujte přístup k poloze, připojení k internetu a datum a čas ve vašem telefonu.';

  @override
  String get liveStopPending => 'Aktualizace byly zastaveny. Čeká se na připojení k internetu, aby byla odstraněna vaše poslední poloha; bez aktualizací zmizí z mapy do 2 minut.';

  @override
  String get liveSharing => 'sdílí polohu';

  @override
  String get liveUnavailable => 'Tato živá mapa není k dispozici. Vraťte se k výletu a obnovte stránku.';

  @override
  String get liveMapLoadError => 'Mapu se nepodařilo načíst. Zkontrolujte připojení a mapu znovu otevřete.';

  @override
  String get liveLoadError => 'Nepodařilo se aktualizovat polohy. Zobrazují se pouze nejnovější aktualizace.';

  @override
  String get liveFit => 'Zobrazit všechny na mapě';

  @override
  String get liveEmpty => 'Zatím nikdo nesdílí svou aktuální polohu.';

  @override
  String get liveRecent => 'Právě aktualizováno';

  @override
  String get liveLastKnown => 'Poslední aktualizace';

  @override
  String get liveAccuracy => 'Přesnost';

  @override
  String get liveUntil => 'Sdílení do';

  @override
  String get liveOtherSession => 'Spuštěno v jiné relaci. Zde jej můžete zastavit.';

  @override
  String get liveUpdatesPaused => 'Aktualizace pozastaveny. Zkontrolujte přístup k poloze a připojení k internetu.';

  @override
  String get livePrivateUntilShared => 'Vaše poloha zůstává soukromá, dokud se nerozhodnete ji sdílet.';

  @override
  String get activityEventExpenseCreated => 'přidal(a) výdaj';

  @override
  String get activityEventExpenseUpdated => 'aktualizoval(a) výdaj';

  @override
  String get activityEventExpenseDeleted => 'smazal(a) výdaj';

  @override
  String get activityEventExpenseCommentAdded => 'okomentoval(a) výdaj';

  @override
  String get activityEventTripCreated => 'vytvořil(a) cestu';

  @override
  String get activityEventTripUpdated => 'aktualizoval(a) podrobnosti cesty';

  @override
  String get activityEventTripRenamed => 'změnil(a) název cesty';

  @override
  String get activityEventTripCurrencyChanged => 'změnil(a) měnu cesty';

  @override
  String get activityEventTripPhotoChanged => 'změnil(a) fotku cesty';

  @override
  String get activityEventTripBudgetChanged => 'změnil(a) rozpočet cesty';

  @override
  String get activityEventTripDestinationsChanged => 'změnil(a) destinace cesty';

  @override
  String get activityEventTripMembersAdded => 'přidal(a) členy';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'odeslal(a) pozvánky: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'se připojil(a) k cestě';

  @override
  String get activityEventTripInvitationDeclined => 'odmítl(a) pozvánku na cestu';

  @override
  String get activityEventTripInvitationRevoked => 'zrušil(a) pozvánku na cestu';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'odebral(a) $name z cesty';
  }

  @override
  String get activityEventTripMemberLeft => 'opustil(a) cestu';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'změnil(a) roli $name na $role';
  }

  @override
  String get activityEventTripMemberReady => 'potvrdil(a) připravenost k vyúčtování';

  @override
  String get activityEventTripMemberNotReady => 'zrušil(a) připravenost k vyúčtování';

  @override
  String get activityEventTripAllMembersReady => 'Všichni členové jsou připraveni k vyúčtování';

  @override
  String get activityEventTripFinished => 'ukončil(a) cestu';

  @override
  String get activityEventTripSettled => 'Všechny převody jsou potvrzeny, cesta je vyúčtována';

  @override
  String get activityEventSettlementMarkedSent => 'označil(a) převod jako odeslaný';

  @override
  String get activityEventSettlementConfirmed => 'potvrdil(a) převod';

  @override
  String get activityEventSettlementSentCancelled => 'zrušil(a) stav „odesláno“';

  @override
  String get activityEventSettlementNotReceived => 'označil(a) převod jako nepřijatý';

  @override
  String get activityEventSettlementReminderSent => 'odeslal(a) upomínku k vyúčtování';

  @override
  String get activityEventPaymentMarkedSent => 'zaznamenal(a) platbu';

  @override
  String get activityEventPaymentRequested => 'požádal(a) o platbu';

  @override
  String get activityEventPaymentRequestMarkedSent => 'označil(a) požadovanou platbu jako odeslanou';

  @override
  String get activityEventPaymentRequestCancelled => 'zrušil(a) žádost o platbu';

  @override
  String get activityEventPaymentRequestDeclined => 'zamítl(a) žádost o platbu';

  @override
  String get activityEventPaymentConfirmed => 'potvrdil(a) platbu';

  @override
  String get activityEventPaymentCancelled => 'zrušil(a) záznam o platbě';

  @override
  String get activityEventPaymentNotReceived => 'označil(a) platbu jako nepřijatou';

  @override
  String get activityEventUnknown => 'provedl(a) změnu';

  @override
  String get privacyEnglishFallback => 'Zásady ochrany osobních údajů jsou zatím dostupné v angličtině.';

  @override
  String get activityRoleAdmin => 'Správce';

  @override
  String get accountDeleteTitle => 'Smazat účet';

  @override
  String get accountDeleteIntro => 'Potvrď smazání e-mailem. Po potvrzení ho nelze vrátit zpět.';

  @override
  String get accountDeleteConsequences => 'Vymazání je trvalé. Váš profil je anonymizován a přístup k účtu je zrušen. Sdílené záznamy o cestách a výdajích jsou uchovávány pro ostatní členy.';

  @override
  String get accountDeleteReasonsTitle => 'Co jsme mohli udělat lépe?';

  @override
  String get accountDeleteReasonsHint => 'Důvod (nepovinné)';

  @override
  String get accountDeleteReasonNotUsing => 'Pro své výlety již Splyto nepotřebuji';

  @override
  String get accountDeleteReasonAnotherWay => 'Sdílené výdaje spravuji jiným způsobem';

  @override
  String get accountDeleteReasonComplicated => 'Vyřízení věcí vyžaduje příliš mnoho úsilí';

  @override
  String get accountDeleteReasonTechnical => 'Narazil jsem na chyby nebo technické problémy';

  @override
  String get accountDeleteReasonPrivacy => 'Raději bych odstranil údaje o svém účtu';

  @override
  String get accountDeleteReasonOther => 'Odcházím z jiného důvodu';

  @override
  String get accountDeleteEmailStep => 'Dalším krokem je potvrzení e-mailem.';

  @override
  String get accountDeletePasswordHint => 'Zadejte své aktuální heslo ke Splyto a požádejte o potvrzovací e-mail. Váš účet je stále aktivní.';

  @override
  String get accountDeleteInboxTitle => 'Ještě jeden poslední krok ve vaší doručené poště';

  @override
  String accountDeleteSentBody(String email) {
    return 'Potvrzovací odkaz byl odeslán na $email.';
  }

  @override
  String get accountDeleteSentHint => 'Tvůj účet zůstává aktivní, dokud nepotvrdíš smazání.';

  @override
  String get accountDeleteSending => 'Odeslání potvrzovacího e-mailu';

  @override
  String get friendsShowMore => 'Zobrazit více';

  @override
  String get tripReportTitle => 'Zpráva z cesty';

  @override
  String get tripReportDetailedTitle => 'Podrobná zpráva z cesty';

  @override
  String get tripReportDates => 'Termín';

  @override
  String get tripReportDestinations => 'Cíle';

  @override
  String get tripReportTotalSpent => 'Celkem utraceno';

  @override
  String get tripReportExpenses => 'Výdaje';

  @override
  String get tripReportYouPaid => 'Zaplatili jste';

  @override
  String get tripReportYourShare => 'Váš podíl';

  @override
  String get tripReportYourBalance => 'Váš zůstatek';

  @override
  String get tripReportYourSettlements => 'Vaše vyrovnání';

  @override
  String tripReportYouPay(Object arg1) {
    return 'Platíte: $arg1';
  }

  @override
  String tripReportPaysYou(Object arg1) {
    return '$arg1 platí vám';
  }

  @override
  String get tripReportStatus => 'Stav';

  @override
  String get tripReportStatusPending => 'Čeká';

  @override
  String get tripReportStatusSent => 'Odesláno';

  @override
  String get tripReportStatusConfirmed => 'Potvrzeno';

  @override
  String get tripReportNoSettlements => 'Nemáte co vyrovnávat.';

  @override
  String get tripReportByCategory => 'Výdaje podle kategorií';

  @override
  String get tripReportCategory => 'Kategorie';

  @override
  String get tripReportAmount => 'Částka';

  @override
  String get tripReportMembers => 'Členové';

  @override
  String get tripReportMember => 'Člen';

  @override
  String get tripReportPaid => 'Zaplaceno';

  @override
  String get tripReportShare => 'Podíl';

  @override
  String get tripReportBalance => 'Zůstatek';

  @override
  String get tripReportAllExpenses => 'Všechny výdaje';

  @override
  String get tripReportDate => 'Datum';

  @override
  String get tripReportDescription => 'Popis';

  @override
  String get tripReportPaidBy => 'Zaplatil(a)';

  @override
  String get tripReportOriginalAmount => 'Původní částka';

  @override
  String get tripReportCurrency => 'Měna';

  @override
  String get tripReportRate => 'Kurz';

  @override
  String get tripReportPayments => 'Platby';

  @override
  String get tripReportFrom => 'Od';

  @override
  String get tripReportTo => 'Komu';

  @override
  String get tripReportFooter => 'Vytvořeno ve Splyto';

  @override
  String tripReportEmailSubject(Object arg1) {
    return 'Vaše zpráva z cesty: $arg1';
  }

  @override
  String get tripReportEmailTitle => 'Vaše zpráva z cesty je připravena';

  @override
  String tripReportEmailGreeting(Object arg1) {
    return 'Dobrý den, $arg1,';
  }

  @override
  String tripReportEmailBody(Object arg1) {
    return 'Cesta $arg1 je dokončena. Zprávu najdete v příloze jako PDF.';
  }

  @override
  String get tripReportEmailOptOut => 'Tyto e-maily můžete vypnout v Profilu v části Oznámení.';

  @override
  String get tripReportEmailSetting => 'Zpráva z cesty e-mailem';

  @override
  String get tripReportEmailSettingSubtitle => 'Po dokončení cesty dostanete souhrn v PDF.';

  @override
  String get tripExportAction => 'Exportovat podrobnosti cesty';

  @override
  String get tripExportPdf => 'Podrobné PDF';

  @override
  String get tripExportCsv => 'Tabulka (CSV)';

  @override
  String get tripExportFailed => 'Export se nepodařilo vytvořit. Zkuste to znovu.';

  @override
  String get yearSummaryTitle => 'Váš rok na cestách';

  @override
  String get yearSummarySubtitle => 'Vaše cesty, místa a výdaje za rok.';

  @override
  String yearSummaryEmpty(Object arg1) {
    return 'V roce $arg1 nejsou žádné dokončené cesty.';
  }

  @override
  String get yearSummaryLoadFailed => 'Váš rok na cestách se nepodařilo načíst.';

  @override
  String get yearSummaryTrips => 'Cesty';

  @override
  String get yearSummaryDays => 'Dny na cestách';

  @override
  String get yearSummaryCountries => 'Země';

  @override
  String get yearSummaryCities => 'Města';

  @override
  String get yearSummarySpending => 'Vaše výdaje';

  @override
  String get yearSummaryBiggestTrip => 'Největší cesta';

  @override
  String get yearSummaryTopCategory => 'Hlavní kategorie';

  @override
  String get yearSummaryTopCompanion => 'Nejvíc cest s';

  @override
  String yearSummaryTripsTogether(Object arg1) {
    return 'Společné cesty: $arg1';
  }

  @override
  String get yearSummaryPartial => 'Některé částky chybí, protože nebyl k dispozici směnný kurz.';

  @override
  String get yearSummaryShare => 'Sdílet';

  @override
  String get yearSummaryShareFailed => 'Obrázek se nepodařilo sdílet.';

  @override
  String get yearSummaryRetry => 'Zkusit znovu';

  @override
  String get notificationCommentAddedTitle => 'Nový komentář k vašemu výdaji';

  @override
  String notificationCommentAddedBody(Object name, Object note) {
    return '$name okomentoval(a) „$note“.';
  }

  @override
  String notificationCommentAddedBodyGeneric(Object name) {
    return '$name okomentoval(a) váš výdaj.';
  }

  @override
  String get profilePushCommentsTitle => 'Komentáře a zmínky';

  @override
  String get profilePushCommentsSubtitle => 'Nové komentáře k vašim výdajům a zmínky o vás';

  @override
  String get profilePushTripInvitesTitle => 'Pozvánky a členové výletu';

  @override
  String get profilePushTripInvitesSubtitle => 'Pozvánky a lidé, kteří se k výletu připojí nebo ho opustí';

  @override
  String get profilePushTripStatusTitle => 'Stav výletu';

  @override
  String get profilePushTripStatusSubtitle => 'Výlet ukončen a připraven k vyrovnání';

  @override
  String get profilePushPaymentRequestsTitle => 'Žádosti o platbu';

  @override
  String get profilePushPaymentRequestsSubtitle => 'Žádosti pro vás, odmítnuté nebo zrušené';

  @override
  String get profilePushPaymentsTitle => 'Platby';

  @override
  String get profilePushPaymentsSubtitle => 'Platby označené jako odeslané, potvrzené nebo nepřijaté';

  @override
  String get profilePushRemindersTitle => 'Připomínky';

  @override
  String get profilePushRemindersSubtitle => 'Připomínky nevyrovnaných plateb';
}
