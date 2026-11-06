// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get homeFirstTrip => 'Twoja pierwsza wycieczka';

  @override
  String get homeYourShareAllTrips => 'Twój udział we wszystkich podróżach';

  @override
  String get homeAllTime => 'Cały okres';

  @override
  String get homeSolo => 'Solo';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osób',
      many: '$count osób',
      few: '$count osoby',
      one: '$count osoba',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Czynności związane z podróżą: $name';
  }

  @override
  String get homeNoActiveTrips => 'Brak aktywnych podróży';

  @override
  String get homeNoArchivedTrips => 'Brak zarchiwizowanych podróży';

  @override
  String get homeLoadingTrips => 'Ładowanie Twoich wycieczek';

  @override
  String get homeLoadErrorTitle => 'Nie udało się załadować Twoich wycieczek';

  @override
  String get homeLoadErrorBody => 'Spróbuj ponownie za chwilę.';

  @override
  String get homeOfflineTitle => 'Jesteś offline';

  @override
  String get homeOfflineNoData => 'Twoje wycieczki nie są jeszcze dostępne na tym urządzeniu.';

  @override
  String get homeOfflineCached => 'Tryb offline. Wyświetlanie zapisanych wycieczek.';

  @override
  String get homeRefreshError => 'Nie udało się odświeżyć. Wyświetlane są wcześniej załadowane wycieczki.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Udostępnij moje zapisane dane do płatności osobie $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Tylko dopóki ta prośba oczekuje na płatność. Anulowanie prośby powoduje zakończenie dostępu.';

  @override
  String get paymentDetailsUnavailable => 'Szczegóły płatności są niedostępne. Połącz się z internetem i sprawdź, czy żądanie jest nadal otwarte.';

  @override
  String get paymentDetailsRetry => 'Spróbuj ponownie';

  @override
  String get tripModeSolo => 'Tylko ja';

  @override
  String get tripModeGroup => 'Z innymi';

  @override
  String get premiumFree => 'Bezpłatne';

  @override
  String get premiumStatusUnavailable => 'Status planu niedostępny';

  @override
  String premiumGrantedUntil(String date) {
    return 'Dostęp do wersji Premium przyznany do dnia $date';
  }

  @override
  String get premiumBillingNotActive => 'Brak aktywnej subskrypcji';

  @override
  String get premiumRefreshStatus => 'Odśwież status planu';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String get activeStatus => 'Aktywne';

  @override
  String get activeTripPlural => 'aktywne wycieczki';

  @override
  String get activeTripSingle => 'aktywna wycieczka';

  @override
  String get activeTrips => 'Aktywne wycieczki';

  @override
  String get activitiesComingSoon => 'Sekcja „Działania” wkrótce.';

  @override
  String get addAction => 'Dodaj';

  @override
  String get addExpenseTitle => 'Dodaj wydatek';

  @override
  String get addExpensesAction => 'Dodaj wydatki';

  @override
  String get addMembersAction => 'Dodaj uczestników';

  @override
  String get addTripMembersTitle => 'Zaproś uczestników wycieczki';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wysłanych zaproszeń',
      many: '$count wysłanych zaproszeń',
      few: '$count wysłane zaproszenia',
      one: '$count wysłane zaproszenie',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Zaproszenie na wycieczkę zostało odrzucone.';

  @override
  String get tripInviteAction => 'Zaproś';

  @override
  String get tripInvitationsPending => 'Oczekuję na odpowiedź';

  @override
  String get tripInvitationsRetry => 'Zaproszenia niedostępne. Spróbuj ponownie';

  @override
  String get tripInvitationRevoke => 'Anuluj zaproszenie';

  @override
  String get tripInvitationRevokeFailed => 'Nie udało się anulować zaproszenia. Spróbuj ponownie.';

  @override
  String get tripInvitationBody => 'Zostałeś zaproszony na wycieczkę. Otwórz zaproszenie, aby odpowiedzieć.';

  @override
  String get allCaughtUp => 'Wszystko na bieżąco';

  @override
  String get allFilter => 'Wszystkie';

  @override
  String get allMembersLabel => 'Wszyscy członkowie';

  @override
  String get allPaymentsConfirmed => 'Wszystkie płatności są potwierdzane.';

  @override
  String get allTrips => 'Wszystkie wycieczki';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Kwota';

  @override
  String get amountMustBeGreaterThanZero => 'Kwota musi być większa od 0.';

  @override
  String get appearance => 'Wygląd';

  @override
  String get archivedStatus => 'Archiwizowane';

  @override
  String get authSubtitleLogin => 'Podziel się kosztami podróży z przyjaciółmi';

  @override
  String get authSubtitleRegister => 'Załóż konto i zacznij dzielić koszty podróży';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'potwierdzono: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'oczekujące: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'wysłano: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'sugerowane: $count';
  }

  @override
  String get cancelAction => 'Anuluj';

  @override
  String get changeEmailWithPasswordHelper => 'Wprowadź hasło, aby zmienić adres e-mail.';

  @override
  String get chooseReceiptFile => 'Wybierz plik z potwierdzeniem';

  @override
  String get completeAccountSetupDescription => 'Ustaw swój adres e-mail i hasło, aby zakończyć tworzenie konta.';

  @override
  String get completeAccountSetupTitle => 'Zakończ konfigurację konta';

  @override
  String get confirmReceivedAction => 'Potwierdź otrzymanie';

  @override
  String get confirmedAllSettlementsArchived => 'Wszystkie rozliczenia potwierdzone. Wycieczka zarchiwizowana.';

  @override
  String get confirmedAsReceived => 'Potwierdzono odbiór.';

  @override
  String get confirmedLabel => 'Potwierdzone';

  @override
  String get couldNotOpenReceiptLink => 'Nie udało się otworzyć linku do paragonu.';

  @override
  String get createAction => 'Utwórz';

  @override
  String get createFirstTripHint => 'Utwórz swoją pierwszą podróż, aby rozpocząć.';

  @override
  String get createNewTripTitle => 'Utwórz nową wycieczkę';

  @override
  String get createTripAction => 'Utwórz wycieczkę';

  @override
  String get createTripFirst => 'Najpierw utwórz wycieczkę.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Utworzone przez $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Organizator wycieczki musi zakończyć wycieczkę, aby rozpocząć proces potwierdzania rozliczenia.';

  @override
  String currentEmailLabel(Object email) {
    return 'Aktualny adres e-mail: $email';
  }

  @override
  String get currentReceiptAttached => 'Aktualny dowód wpłaty znajduje się w załączniku.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Data';

  @override
  String get dateMustMatchFormat => 'Data musi być podana w formacie YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Data nieznana';

  @override
  String get deleteAction => 'Usuń';

  @override
  String get deleteExpenseConfirmQuestion => 'Usunąć ten wydatek?';

  @override
  String get deleteExpenseTitle => 'Usuń wydatek';

  @override
  String get editExpenseConfirmTitle => 'Zapisać zmiany w wydatkach?';

  @override
  String get editExpenseConfirmText => 'Spowoduje to aktualizację sald wszystkich uczestników wycieczki.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Wyjaśnienie bezpośrednio na podstawie wydatków: $amount';
  }

  @override
  String get doneStatus => 'Gotowe';

  @override
  String get editAction => 'Edytuj';

  @override
  String get editExpenseTitle => 'Edytuj wydatek';

  @override
  String get emailAddressLabel => 'Adres e-mail';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailRequired => 'Adres e-mail jest wymagany.';

  @override
  String get enterValidExactAmounts => 'Wprowadź prawidłowe, dokładne kwoty dla wszystkich uczestników.';

  @override
  String get enterValidPercentages => 'Wprowadź prawidłowe wartości procentowe dla wszystkich uczestników.';

  @override
  String get equalSplitLabel => 'Podział po równo';

  @override
  String exactAmountWithValue(Object value) {
    return 'Dokładnie: $value';
  }

  @override
  String get exactAmountsLabel => 'Dokładne kwoty';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Dokładny podział musi dać w sumie $amount.';
  }

  @override
  String get expenseAdded => 'Dodano wydatek.';

  @override
  String get expenseBreakdownSubtitle => 'W jaki sposób każdy wydatek wpływa na tego uczestnika.';

  @override
  String get expenseBreakdownTitle => 'Zestawienie wydatków';

  @override
  String get expenseDeleted => 'Wydatek usunięty.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Wydatek nr $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Opłacone $paid  -  Zadłużone $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reakcje';

  @override
  String get expenseCommentsTitle => 'Komentarze';

  @override
  String get expenseNoComments => 'Brak komentarzy.';

  @override
  String get expenseAddCommentHint => 'Dodaj komentarz...';

  @override
  String get expenseCommentSend => 'Wyślij';

  @override
  String get expenseMentionNoMatches => 'Brak pasujących uczestników';

  @override
  String get expenseMentionMembersLabel => 'Uczestnicy wycieczki do oznaczenia';

  @override
  String get expenseDeleteCommentTitle => 'Usunąć komentarz?';

  @override
  String get expenseUpdated => 'Zaktualizowano wydatki.';

  @override
  String expenseWithId(Object id) {
    return 'Wydatek nr $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków',
      many: '$count wydatków',
      few: '$count wydatki',
      one: '$count wydatek',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Wydatki';

  @override
  String get failedToCreateTrip => 'Nie udało się utworzyć wycieczki.';

  @override
  String get failedToLoadUsersDirectory => 'Nie udało się załadować katalogu użytkowników.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtruj rozliczenia według uczestników';

  @override
  String get finishSoloTripConfirmationText => 'Chcesz zakończyć tę podróż i przenieść ją do archiwum? Twoje wydatki pozostaną dostępne do wglądu.';

  @override
  String get soloTripArchived => 'Wycieczka zakończona i zarchiwizowana.';

  @override
  String get finishTripSyncPending => 'Zsynchronizuj oczekujące zmiany przed zakończeniem tej podróży.';

  @override
  String get finishTripAction => 'Zakończ wycieczkę';

  @override
  String get finishTripConfirmationText => 'Zakończyć tę podróż i rozpocząć rozliczenia?';

  @override
  String get finishTripStartSettlementsAction => 'Zakończ i rozpocznij rozliczenia';

  @override
  String get finishTripTitle => 'Zakończ wycieczkę';

  @override
  String forParticipants(Object participants) {
    return 'Dla: $participants';
  }

  @override
  String get forgotPassword => 'Nie pamiętasz hasła?';

  @override
  String get profileSetPassword => 'Ustaw hasło';

  @override
  String get profileManagePassword => 'Ustaw lub zmień hasło';

  @override
  String get profilePasswordByEmail => 'Ustaw hasło za pomocą wiadomości e-mail';

  @override
  String get passwordEmailBackToProfile => 'Powrót do profilu';

  @override
  String get forgotPasswordSubtitle => 'Wpisz swój adres e-mail, a wyślemy Ci link do zresetowania hasła.';

  @override
  String get forgotPasswordSuccessMessage => 'Jeśli istnieje konto z tym adresem e-mail, wysłaliśmy link do zresetowania hasła.';

  @override
  String get passwordResetSentTitle => 'Sprawdź skrzynkę odbiorczą';

  @override
  String get passwordResetSentHint => 'Link jest ważny przez 1 godzinę. Jeśli nie widzisz wiadomości, sprawdź folder spam.';

  @override
  String get forgotPasswordTitle => 'Zresetuj hasło';

  @override
  String get friendsProgressSubtitle => 'Każdy uczestnik i jego status potwierdzenia.';

  @override
  String get friendsProgressTitle => 'Postępy znajomych';

  @override
  String get friendsSectionComingSoon => 'Sekcja „Znajomi” wkrótce.';

  @override
  String fromDirection(Object name) {
    return 'Od $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from do $to';
  }

  @override
  String get generateTurnAction => 'Wylosuj następną osobę';

  @override
  String get hasAccountQuestion => 'Masz już konto?';

  @override
  String helloUser(Object name) {
    return 'Cześć, $name!';
  }

  @override
  String get iSentAction => 'Wysłałem';

  @override
  String get invalidEmailFormat => 'Nieprawidłowy format adresu e-mail.';

  @override
  String get languageAction => 'Język';

  @override
  String get languageEnglish => 'angielski';

  @override
  String get languageLatvian => 'Łotewski';

  @override
  String get languageSpanish => 'Hiszpański';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSystemSubtitle => 'Używaj języka urządzenia';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Pozostaw puste, aby zachować aktualne hasło.';

  @override
  String get logInButton => 'Zaloguj się';

  @override
  String get logOutButton => 'Wyloguj się';

  @override
  String get logoutFromDeviceQuestion => 'Wylogować się z tego urządzenia?';

  @override
  String get logoutRevocationUnconfirmed => 'Wylogowano się na tym urządzeniu. Nie udało się potwierdzić unieważnienia sesji serwerowej.';

  @override
  String get markedAsSent => 'Oznaczone jako wysłane.';

  @override
  String get markSettlementSentConfirmTitle => 'Oznaczyć przelew jako wysłany?';

  @override
  String get markSettlementSentConfirmText => 'Użyj tej opcji dopiero po faktycznym wysłaniu płatności. Odbiorca zostanie poproszony o potwierdzenie.';

  @override
  String get settlementCancelSentAction => 'Oznacz jako niewysłane';

  @override
  String get settlementCancelSentConfirmTitle => 'Anulować status „wysłano”?';

  @override
  String get settlementCancelSentConfirmText => 'Spowoduje to przywrócenie statusu przelewu do „oczekującego” i powiadomienie odbiorcy.';

  @override
  String get settlementSentCancelled => 'Przelew został przywrócony do statusu „oczekujące”.';

  @override
  String get settlementNotReceivedAction => 'Nie otrzymałem tej wiadomości';

  @override
  String get settlementNotReceivedConfirmTitle => 'Zgłosić nieotrzymaną płatność?';

  @override
  String get settlementNotReceivedConfirmText => 'Spowoduje to przywrócenie statusu przelewu do „oczekującego” i powiadomienie płatnika.';

  @override
  String get settlementMarkedNotReceived => 'Oznaczone jako nieodebrane.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Czy potwierdzasz odbiór?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Potwierdź dopiero po pojawieniu się środków na Twoim koncie. Ta czynność może zakończyć rozliczenie.';

  @override
  String get memberSummariesSubtitle => 'Aktualny stan salda dla obu stron.';

  @override
  String get memberSummariesTitle => 'Podsumowania dotyczące uczestników';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Aby zapłacić $total  -  potwierdzone $confirmed  -  oczekujące $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Szacowany wpływ płatności na jednego uczestnika.';

  @override
  String get membersImpactTitle => 'Wpływ uczestników';

  @override
  String get membersIncludedInExpense => 'Uczestnicy uwzględnieni';

  @override
  String get membersLabel => 'Uczestnicy';

  @override
  String moreCount(Object count) {
    return '+jeszcze $count';
  }

  @override
  String get myFilter => 'Moje';

  @override
  String get myImpactTitle => 'Mój wpływ';

  @override
  String get firstNameHint => 'Twoje imię';

  @override
  String get firstNameLabel => 'Imię';

  @override
  String get firstNameLengthValidation => 'Imię musi składać się z 2–64 znaków.';

  @override
  String get fullNameHelper => 'W jednym polu należy podać imię i nazwisko.';

  @override
  String get fullNameHint => 'np. Anna Ozolina';

  @override
  String get fullNameLabel => 'Imię i nazwisko';

  @override
  String get fullNameValidation => 'Wprowadź imię i nazwisko (co najmniej 2 znaki w każdym polu).';

  @override
  String get lastNameHint => 'Twoje nazwisko';

  @override
  String get lastNameLabel => 'Nazwisko';

  @override
  String get lastNameLengthValidation => 'Nazwisko musi składać się z 2–64 znaków.';

  @override
  String get nameHint => 'Twoje imię i nazwisko';

  @override
  String get nameLabel => 'Nazwa';

  @override
  String get nameLengthValidation => 'Nazwa musi składać się z co najmniej 2 znaków.';

  @override
  String get navActivities => 'Statystyki';

  @override
  String get navAddTrip => 'Dodaj wycieczkę';

  @override
  String get navBalances => 'Salda';

  @override
  String get navExpenses => 'Wydatki';

  @override
  String get navFriends => 'Znajomi';

  @override
  String get navHome => 'Strona główna';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRandom => 'Losowe';

  @override
  String get netLabel => 'Saldo netto';

  @override
  String get newPasswordLabel => 'Nowe hasło';

  @override
  String get nicknameHint => 'Jak będą Cię postrzegać znajomi';

  @override
  String get nicknameLabel => 'Pseudonim';

  @override
  String get nicknameLengthValidation => 'Pseudonim musi składać się z co najmniej 2 znaków.';

  @override
  String get noAccountQuestion => 'Nie masz jeszcze konta?';

  @override
  String get noBalancesYet => 'Brak sald.';

  @override
  String get noChangesToSave => 'Brak zmian do zapisania.';

  @override
  String get noDirectExpenseLink => 'Nie znaleziono bezpośredniego linku do pojedynczego wydatku. Rozliczenie to jest obliczane na podstawie pełnego salda wycieczki.';

  @override
  String get noExpenseImpactForMember => 'Nie ma to wpływu na wydatki tego uczestnika.';

  @override
  String noExpensesByUserYet(Object name) {
    return '$name nie ma jeszcze żadnych wydatków.';
  }

  @override
  String get noExpensesYet => 'Na razie nie ma żadnych wydatków.';

  @override
  String get noExtraUsersToAdd => 'Nie ma potrzeby dodawania dodatkowych użytkowników.';

  @override
  String get noInternetDeleteQueued => 'Brak połączenia z internetem. Usunięto z kolejki.';

  @override
  String get noInternetExpenseQueued => 'Brak połączenia z internetem. Wydatek w kolejce.';

  @override
  String get noInternetUpdateQueued => 'Brak połączenia z internetem. Aktualizacja w kolejce.';

  @override
  String get noMatchingRows => 'Brak pasujących wierszy.';

  @override
  String get noMembersFound => 'Nie znaleziono żadnych uczestników.';

  @override
  String get noNewMembersAdded => 'Osoby te są już członkami lub mają zaproszenia oczekujące na akceptację.';

  @override
  String get noNotePlaceholder => 'Brak uwagi';

  @override
  String get notificationsToday => 'Dzisiaj';

  @override
  String get notificationsEmptyBody => 'W tym miejscu będą pojawiać się aktualizacje dotyczące wycieczek, wydatków i znajomych.';

  @override
  String get notificationsCached => 'Tryb offline — wyświetlanie zapisanych powiadomień.';

  @override
  String get notificationsRefreshFailed => 'Nie udało się odświeżyć. Wyświetlane są wcześniej załadowane powiadomienia.';

  @override
  String get notificationsJustNow => 'Właśnie teraz';

  @override
  String notificationsMinutesAgo(int count) {
    return '$count min temu';
  }

  @override
  String notificationsHoursAgo(int count) {
    return '$count godz. temu';
  }

  @override
  String get notificationsUnread => 'Nieprzeczytane';

  @override
  String get noNotificationsYet => 'Brak powiadomień.';

  @override
  String get noParticipantData => 'Brak danych uczestników.';

  @override
  String get noParticipantsSelected => 'Nie wybrano żadnych uczestników.';

  @override
  String get noPaymentRowsInTrip => 'W tej podróży nie ma żadnych pozycji dotyczących płatności.';

  @override
  String get noPaymentsNeeded => 'Nie są wymagane żadne płatności.';

  @override
  String get noPicksYet => 'Brak dotychczasowych wyborów.';

  @override
  String get noSettlementActivityForMember => 'Brak operacji rozliczeniowych dla tego członka.';

  @override
  String get noSettlementRowsYet => 'Brak jeszcze wierszy rozliczeniowych.';

  @override
  String get noSettlements => 'Brak rozliczeń';

  @override
  String get noTransferNeededForFilter => 'Dla wybranego filtra nie jest wymagany żaden przelew.';

  @override
  String get noTransferRowsToShow => 'Nie ma wierszy dotyczących przelewów do wyświetlenia.';

  @override
  String get noTripDataLoaded => 'Nie załadowano żadnych danych dotyczących podróży.';

  @override
  String get noTripsYet => 'Brak wycieczek.';

  @override
  String get noUsersFoundYet => 'Nie znaleziono jeszcze żadnych użytkowników.';

  @override
  String get notSetValue => 'Nie ustalono';

  @override
  String get notYetConfirmedTitle => 'Jeszcze niepotwierdzone';

  @override
  String get noteHint => 'Kolacja, taksówka, bilety...';

  @override
  String get noteLabel => 'Uwaga';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Notatka może zawierać maksymalnie $max znaków.';
  }

  @override
  String get notificationFallbackTitle => 'Powiadomienie';

  @override
  String get notificationsTitle => 'Powiadomienia';

  @override
  String get notificationFriendInviteTitle => 'Zaproszenie do znajomych';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name wysłał(a) Ci zaproszenie do grona znajomych.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Otrzymałeś zaproszenie do grona znajomych.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Zaproszenie zaakceptowane';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name zaakceptował Twoje zaproszenie do grona znajomych.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Twoje zaproszenie do grona znajomych zostało zaakceptowane.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Zaproszenie odrzucone';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name odrzucił Twoje zaproszenie do grona znajomych.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Twoje zaproszenie dla znajomego zostało odrzucone.';

  @override
  String get notificationTripAddedTitle => 'Dodano do wycieczki';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name dodał(a) Cię do wycieczki „$trip”.';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Zostałeś dodany do wycieczki „$trip”.';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Zostałeś dodany do wycieczki.';

  @override
  String get notificationExpenseAddedTitle => 'Dodano nowy wydatek';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name dodał wydatek w wysokości $amount w ramach „$trip”.';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name dodał wydatek w wysokości $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Dodano nowy wydatek.';

  @override
  String get notificationCommentMentionTitle => 'Oznaczono Cię w komentarzu';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name oznaczył(a) Cię w komentarzu do „$note”.';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name oznaczył(a) Cię w komentarzu.';
  }

  @override
  String get notificationTripFinishedTitle => 'Wycieczka zakończona';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name zakończył „$trip”. Rozliczenia są gotowe.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name zakończył(a) „$trip”. Wycieczka została zarchiwizowana.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '„$trip” zostało ukończone.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Zaktualizowano status wycieczki.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Uczestnik oznaczony jako gotowy';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name jest gotowy do udziału w „$trip”.';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Uczestnik jest gotowy do rozliczenia się w ramach „$trip”.';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Uczestnik jest gotowy do rozliczenia.';

  @override
  String get notificationTripReadyToSettleTitle => 'Wszyscy członkowie są gotowi';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Wszyscy uczestnicy zostali oznaczeni jako gotowi w „$trip”. Możesz rozpocząć rozliczenia.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Wszyscy członkowie są gotowi. Możesz rozpocząć rozliczenia.';

  @override
  String get notificationSettlementReminderTitle => 'Przypomnienie o rozliczeniu';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor przypomniał $target, aby oznaczył kwotę $amount jako wysłaną.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor przypomniał $target o potwierdzeniu otrzymania kwoty $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Otrzymałeś przypomnienie o rozliczeniu.';

  @override
  String get notificationPaymentReminderTitle => 'Przypomnienie o płatności';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Przypomnienie: proszę oznaczyć kwotę $amount jako wysłaną do $target w ramach „$trip”.';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Przypomnienie: prosimy o oznaczenie płatności jako wysłanej.';

  @override
  String get notificationConfirmationReminderTitle => 'Przypomnienie o potwierdzeniu';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Przypomnienie: proszę potwierdzić otrzymanie kwoty $amount od $payer w ramach „$trip”.';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Przypomnienie: proszę potwierdzić otrzymanie płatności.';

  @override
  String get notificationSettlementSentTitle => 'Przelew oznaczony jako wysłany';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name oznaczył kwotę $amount jako wysłaną do Ciebie.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Przelew został oznaczony jako wysłany.';

  @override
  String get notificationSettlementConfirmedTitle => 'Przelew potwierdzony';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name potwierdził otrzymanie od Ciebie kwoty $amount.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Przelew został potwierdzony.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oczekujących zmian',
      many: '$count oczekujących zmian',
      few: '$count oczekujące zmiany',
      one: '$count oczekująca zmiana',
    );
    return 'Kolejka offline: $_temp0';
  }

  @override
  String get syncAllSynced => 'Wszystkie zsynchronizowane';

  @override
  String syncChangesWaiting(Object count) {
    return '$count oczekuje na synchronizację';
  }

  @override
  String get syncFailedTapToRetry => 'Synchronizacja nie powiodła się, dotknij, aby spróbować ponownie';

  @override
  String get offlineQueueStatus => 'Kolejka offline';

  @override
  String get offlineStatus => 'Tryb offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Tylko organizator wycieczki może zakończyć wycieczkę.';

  @override
  String get openLabel => 'Otwórz';

  @override
  String get openReceiptAction => 'Otwórz paragon';

  @override
  String get openSettlements => 'Otwórz rozliczenia';

  @override
  String get overviewTitle => 'Przegląd';

  @override
  String get owesLabel => 'Do zapłaty';

  @override
  String get paidByLabel => 'Opłacone przez';

  @override
  String get paidLabel => 'Płatne';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Opłacone $paid -  Zadłużone $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Uczestnicy (puste = wszyscy członkowie)';

  @override
  String get participantsTitle => 'Uczestnicy';

  @override
  String get passwordLabel => 'Hasło';

  @override
  String get passwordComplexityHelper => 'Użyj co najmniej 1 wielkiej litery, 1 cyfry i 1 symbolu.';

  @override
  String get passwordComplexityValidation => 'Hasło musi zawierać 1 wielką literę, 1 cyfrę i 1 znak specjalny.';

  @override
  String get passwordMinLength => 'Hasło musi składać się z co najmniej 8 znaków.';

  @override
  String get passwordMinLengthShort => 'Hasło musi składać się z co najmniej 6 znaków.';

  @override
  String get passwordResetComingSoon => 'Wkrótce dostępna będzie funkcja resetowania hasła.';

  @override
  String get passwordsDoNotMatch => 'Hasła nie są zgodne.';

  @override
  String payerName(Object name) {
    return '$name (płatnik)';
  }

  @override
  String get pendingLabel => 'Oczekujące';

  @override
  String get pendingPaymentsSubtitle => 'Płatności wciąż oczekują na pełne potwierdzenie.';

  @override
  String get percentLabel => 'Procent';

  @override
  String get percentSplitMustBe100 => 'Suma procentowych podziałów musi wynosić dokładnie 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Procenty';

  @override
  String get pickAtLeastOneParticipant => 'Wybierz co najmniej jednego uczestnika.';

  @override
  String get pickMembersGenerateTurn => 'Wybierz uczestników i wylosuj następną osobę.';

  @override
  String pickedCycleCompleted(Object name) {
    return 'Wybrano $name. Cykl zakończony.';
  }

  @override
  String pickedUser(Object name) {
    return 'Wybrano $name.';
  }

  @override
  String get profileRefreshCachedData => 'Nie udało się odświeżyć profilu. Wyświetlane są dane z pamięci podręcznej.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUpdated => 'Profil zaktualizowany.';

  @override
  String get uploadAvatarAction => 'Prześlij awatar';

  @override
  String get takePhotoAction => 'Zrób zdjęcie.';

  @override
  String get chooseFromLibraryAction => 'Wybierz z biblioteki';

  @override
  String get removeAvatarAction => 'Usuń awatar';

  @override
  String get avatarUpdatedMessage => 'Zaktualizowano awatara.';

  @override
  String get avatarRemovedMessage => 'Usunięto awatar.';

  @override
  String get avatarFileTooLarge => 'Plik awatara jest zbyt duży (maks. 5 MB).';

  @override
  String get avatarPickFailed => 'Nie udało się załadować obrazu awatara.';

  @override
  String get queueAddExpense => 'Dodaj wydatek';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'W kolejce: dodaj wydatek $amount';
  }

  @override
  String get queueDeleteExpense => 'Usuń wydatek';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'W kolejce: usuń wydatek nr $id';
  }

  @override
  String get queuePendingStatus => 'Kolejka oczekujących';

  @override
  String get queueUpdateExpense => 'Zaktualizuj wydatki';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'W kolejce: aktualizacja wydatku nr $id';
  }

  @override
  String get queuedChange => 'Zmiany w kolejce';

  @override
  String queuedChangesTitle(Object count) {
    return 'Zmiany w kolejce ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'W kolejce ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Cykl $cycleNo, losowanie $drawNo – pozostało $remaining';
  }

  @override
  String get receiptFallbackName => 'paragon';

  @override
  String get receiptLinkInvalid => 'Link do potwierdzenia płatności jest nieprawidłowy.';

  @override
  String get receiptOptionalLabel => 'Paragon (opcjonalnie)';

  @override
  String get recentPicksTitle => 'Ostatnie losowania';

  @override
  String get reloadProfile => 'Odśwież profil';

  @override
  String get rememberMe => 'Zapamiętaj mnie';

  @override
  String get removeCurrentReceipt => 'Usuń aktualny dowód wpłaty';

  @override
  String get repeatNewPasswordLabel => 'Powtórz nowe hasło';

  @override
  String get repeatPasswordLabel => 'Powtórz hasło';

  @override
  String get requestFailedTryAgain => 'Żądanie nie powiodło się. Spróbuj ponownie.';

  @override
  String get retryAction => 'Spróbuj ponownie';

  @override
  String get rowsLabel => 'Wiersze';

  @override
  String get backToLoginAction => 'Powrót do logowania';

  @override
  String get saveAction => 'Zapisz';

  @override
  String get saveCredentialsButton => 'Zapisz dane uwierzytelniające';

  @override
  String get saveProfileButton => 'Zapisz profil';

  @override
  String get sendResetLinkButton => 'Wyślij link do resetowania';

  @override
  String get searchUsersHint => 'Wyszukuj osoby według nazwiska lub adresu e-mail';

  @override
  String get selectedPeopleLabel => 'Wybrane osoby';

  @override
  String get noSearchMatches => 'Nie znaleziono pasujących użytkowników.';

  @override
  String get savingButton => 'Zapisywanie...';

  @override
  String get selectAtLeastTwoMembers => 'Wybierz co najmniej dwóch uczestników.';

  @override
  String get selectMembersHint => 'Wybierz uczestników';

  @override
  String selectedFileLabel(Object name) {
    return 'Wybrany: $name';
  }

  @override
  String get selectedLabel => 'Wybrane';

  @override
  String get selectedUserFallback => 'Wybrany użytkownik';

  @override
  String get settings => 'Ustawienia';

  @override
  String get settleUpAction => 'Rozlicz się';

  @override
  String get settledLabel => 'Rozliczone';

  @override
  String get settledStatus => 'Rozliczone';

  @override
  String get settlementActivitySubtitle => 'Przelewy powiązane z tym uczestnikiem.';

  @override
  String get settlementActivityTitle => 'Działania związane z rozliczeniami';

  @override
  String get settlementCompletedTitle => 'Rozliczenie zakończone';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total potwierdzonych';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Rozliczenia: $count';
  }

  @override
  String get settlementImpactTitle => 'Wpływ na rozliczenia';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Wpływ na rozliczenie: $name';
  }

  @override
  String get settlementInProgress => 'Trwa rozliczanie';

  @override
  String get settlementInProgressTitle => 'Trwa rozliczanie';

  @override
  String get settlementLabel => 'Rozliczenie';

  @override
  String get settlementOverviewArchivedSubtitle => 'Wycieczka zarchiwizowana. Wszystkie rozliczenia zakończone.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Śledź potwierdzenia rozliczeń.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Podgląd przelewów po zakończeniu wycieczki.';

  @override
  String get settlementPreview => 'Podgląd rozliczenia';

  @override
  String get settlementPreviewTitle => 'Podgląd rozliczenia';

  @override
  String get settlementProgressTripArchived => 'Wycieczka zarchiwizowana';

  @override
  String settlementWithId(Object id) {
    return 'Rozliczenie nr $id';
  }

  @override
  String get settlements => 'Rozliczenia';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Rozliczenia zostały już zakończone.';

  @override
  String get settlementsDone => 'Rozliczenia zakończone';

  @override
  String get settlingStatus => 'Rozliczanie';

  @override
  String get shareUnit => 'udział';

  @override
  String get sharesLabel => 'Udziały';

  @override
  String get sharesMustBePositiveIntegers => 'Liczba udziałów musi być dodatnią liczbą całkowitą.';

  @override
  String sharesWithValue(Object value) {
    return 'Udziały: $value';
  }

  @override
  String get showActiveTrips => 'Pokaż aktywne wycieczki';

  @override
  String get signUpButton => 'Zarejestruj się';

  @override
  String get splitBreakdownSubtitle => 'Jak dzielone są wydatki';

  @override
  String get splitBreakdownTitle => 'Podział kosztów';

  @override
  String get splitHintEqual => 'Podziel równo między wybranych uczestników.';

  @override
  String get splitHintExact => 'Wprowadź dokładną kwotę dla każdego uczestnika. Suma musi być zgodna z kwotą całkowitą.';

  @override
  String get splitHintPercent => 'Wprowadź wartość procentową dla każdego uczestnika. Suma musi wynosić 100%.';

  @override
  String get splitHintShares => 'Wprowadź liczbę osób, z którymi chcesz dzielić się kosztami (1, 2, 3...). Koszt zostanie podzielony proporcjonalnie.';

  @override
  String get splitLabel => 'Podziel';

  @override
  String splitLabelValue(Object value) {
    return 'Podział: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Równy podział ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Dokładne kwoty ($target)';
  }

  @override
  String get splitModeLabel => 'Tryb podziału';

  @override
  String splitModePercent(Object target) {
    return 'Wartości procentowe ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Udziały ($target)';
  }

  @override
  String get statusConfirmed => 'Potwierdzone';

  @override
  String get statusPending => 'Oczekujące';

  @override
  String get statusSent => 'Wysłany';

  @override
  String get statusSuggested => 'Sugerowane';

  @override
  String statusWithValue(Object status) {
    return 'Status: $status';
  }

  @override
  String get suggestedTransferDirections => 'Sugerowane kierunki płatności';

  @override
  String get suggestedTransferFromExpense => 'Sugerowany przelew z wydatków';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugerowanych przelewów',
      many: '$count sugerowanych przelewów',
      few: '$count sugerowane przelewy',
      one: '$count sugerowany przelew',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Przewidywane wiersze „płatnik” -> „odbiorca”.';

  @override
  String get suggestedTransfersTitle => 'Sugerowane przelewy';

  @override
  String get summarySettledUp => 'Rozliczone';

  @override
  String get summaryYouAreOwed => 'Inni są Ci winni';

  @override
  String get summaryYouOwe => 'Do zapłaty';

  @override
  String get syncAction => 'Synchronizacja';

  @override
  String get syncNowAction => 'Zsynchronizuj teraz';

  @override
  String get syncingStatus => 'Synchronizacja';

  @override
  String get tapToViewDetails => 'Kliknij, aby wyświetlić szczegóły';

  @override
  String get themeModeDark => 'Ciemny';

  @override
  String get themeModeDarkSubtitle => 'Delikatna czerń (nie czysta czerń)';

  @override
  String get themeModeLight => 'Jasny';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeSystemSubtitle => 'Wykorzystaj wygląd urządzenia';

  @override
  String toDirection(Object name) {
    return 'Do $name';
  }

  @override
  String get totalLabel => 'Razem';

  @override
  String get travelerFallbackName => 'Podróżny';

  @override
  String get tripAlreadyClosed => 'Wycieczka została już zamknięta.';

  @override
  String get tripArchivedReadOnly => 'Wycieczka jest archiwizowana. Tryb tylko do odczytu.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Wycieczka została zamknięta. Edycja wydatków jest wyłączona.';

  @override
  String get tripClosedExpensesReadOnly => 'Wycieczka została zamknięta. Wydatki są dostępne tylko do odczytu.';

  @override
  String get tripClosedRandomDisabled => 'Wycieczka została zamknięta. Losowanie jest wyłączone.';

  @override
  String tripCreated(Object name) {
    return 'Wycieczka „$name” została utworzona.';
  }

  @override
  String get tripFinished => 'Wycieczka zakończona.';

  @override
  String get tripFinishedCompleteSettlements => 'Wycieczka została zakończona. Dokonaj rozliczeń.';

  @override
  String get tripFinishedSettlementStarted => 'Wycieczka zakończona. Rozpoczęto rozliczenie.';

  @override
  String get tripFullySettledArchived => 'Wycieczka w pełni rozliczona i zarchiwizowana.';

  @override
  String get tripNameHint => 'Wycieczka narciarska do Austrii';

  @override
  String get tripNameLabel => 'Nazwa wycieczki';

  @override
  String get tripNameLengthValidation => 'Nazwa wycieczki musi składać się z co najmniej 2 znaków.';

  @override
  String get tripSnapshotTitle => 'Podsumowanie wycieczki';

  @override
  String get tripTitleShort => 'Wycieczka';

  @override
  String tripStatusWithValue(Object status) {
    return 'Status wycieczki: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Wycieczka nr $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Wystąpił nieoczekiwany błąd podczas ładowania profilu';

  @override
  String get unexpectedErrorLoadingTripData => 'Wystąpił nieoczekiwany błąd podczas ładowania danych dotyczących wycieczki';

  @override
  String get unexpectedErrorLoadingTrips => 'Wystąpił nieoczekiwany błąd podczas ładowania wycieczek';

  @override
  String get unexpectedErrorSavingChanges => 'Nieoczekiwany błąd podczas zapisywania zmian';

  @override
  String get unexpectedErrorSavingCredentials => 'Nieoczekiwany błąd podczas zapisywania danych uwierzytelniających';

  @override
  String get unexpectedErrorUpdatingProfile => 'Wystąpił nieoczekiwany błąd podczas aktualizacji profilu';

  @override
  String get unknownError => 'Nieznany błąd';

  @override
  String get unknownLabel => 'Nieznane';

  @override
  String get unreadLabel => 'Nieprzeczytane';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieprzeczytanych aktualizacji',
      many: '$count nieprzeczytanych aktualizacji',
      few: '$count nieprzeczytane aktualizacje',
      one: '$count nieprzeczytana aktualizacja',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Brak argumentu trasy podróży.';

  @override
  String userIdLabel(Object id) {
    return 'Identyfikator użytkownika: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Opłacone $paid  -  Zadłużone $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Użytkownik $id';
  }

  @override
  String get valueLabel => 'Wartość';

  @override
  String get viewAllTrips => 'Wyświetl wszystkie wycieczki';

  @override
  String get viewByPersonTitle => 'Widok według osoby';

  @override
  String get whoOwesWhatSubtitle => 'Kto zapłacił, a kto jest winien.';

  @override
  String get whoOwesWhatTitle => 'Kto jest komu winien';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Kto jest komu winien: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Wiersze wydatków składające się na ten przelew.';

  @override
  String get whyPaymentExistsTitle => 'Dlaczego ta płatność istnieje';

  @override
  String get youLabel => 'Ty';

  @override
  String get youSettledForExpense => 'Twoja część tego wydatku została rozliczona.';

  @override
  String youShouldPay(Object amount) {
    return 'Powinieneś zapłacić. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Pacjent powinien otrzymywać $amount';
  }

  @override
  String get yourShare => 'Twój udział';

  @override
  String get yourTrips => 'Twoje wycieczki';

  @override
  String get authIntroSplitSmarter => 'Dziel się mądrzej.';

  @override
  String get authIntroTravelFree => 'Podróżuj swobodnie.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Śledź wspólne wydatki w różnych walutach i rozliczaj się natychmiast – bez niezręcznych weksli.';

  @override
  String get authIntroPlanTogether => 'Planujcie razem.';

  @override
  String get authIntroPayClearly => 'Płać w przejrzysty sposób.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Twórz wycieczki w kilka sekund, dodawaj znajomych i dbaj o przejrzystość wszystkich wydatków dla wszystkich.';

  @override
  String get authIntroSettleFast => 'Działaj szybko.';

  @override
  String get authIntroStayFriends => 'Pozostańmy przyjaciółmi.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Od wspólnych kolacji po pełne wycieczki — Splyto dba o sprawiedliwy podział kosztów i pozwala uniknąć stresu.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Nie udało się zalogować za pomocą konta Apple. Spróbuj ponownie.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Nie udało się zalogować za pomocą konta Google. Spróbuj ponownie.';

  @override
  String get authIntroCreateAccount => 'Załóż konto.';

  @override
  String get authIntroChooseSign => 'Wybierz sposób rejestracji.';

  @override
  String get authIntroContinueGoogle => 'Kontynuuj z Google';

  @override
  String get authIntroContinueApple => 'Kontynuuj z Apple';

  @override
  String get authIntroBack => 'Powrót';

  @override
  String get authIntroSplitSettled => 'Podział rozliczony';

  @override
  String get authIntroParis3Friends => 'Paryż · 3 znajomych';

  @override
  String get authIntroGetStarted => 'Rozpocznij';

  @override
  String get authIntroAlreadyHaveAccount => 'Masz już konto? ';

  @override
  String get authIntroSignIn => 'Zaloguj się';

  @override
  String get authIntroSignUpWithEmail => 'Zarejestruj się za pomocą adresu e-mail';

  @override
  String get authIntroOr => 'LUB';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Logowanie przez Google nie zwróciło tokenu identyfikacyjnego.';

  @override
  String get authAppleSignAvailableIosDevices => 'Logowanie za pomocą konta Apple jest dostępne na urządzeniach z systemem iOS.';

  @override
  String get authAppleSignNotAvailableDevice => 'Logowanie za pomocą konta Apple nie jest dostępne na tym urządzeniu.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Logowanie za pomocą Apple nie zwróciło tokenu tożsamości.';

  @override
  String get authCancel => 'Anuluj';

  @override
  String get authSendLink => 'Wyślij link';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'Adres e-mail nie został zweryfikowany. Wpisz swój adres e-mail, aby otrzymać link weryfikacyjny.';

  @override
  String get authEmailNotVerified => 'Adres e-mail nie został zweryfikowany';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Wysłać link weryfikacyjny na adres $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Wysłano link weryfikacyjny. Sprawdź swoją skrzynkę e-mailową.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Nie udało się wysłać linku weryfikacyjnego. Spróbuj ponownie.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Wysłano wiadomość e-mail z linkiem weryfikacyjnym. Prosimy o zweryfikowanie adresu e-mail przed zalogowaniem się.';

  @override
  String get authVerifyEmail => 'Zweryfikuj swój adres e-mail';

  @override
  String get authEmailLabel => 'E-mail:';

  @override
  String get authClose => 'Zamknij';

  @override
  String get authResendLink => 'Wyślij link ponownie';

  @override
  String get profileAppSettingsSectionTitle => 'USTAWIENIA APLIKACJI';

  @override
  String get profileAccountSettings => 'Ustawienia konta';

  @override
  String get profileChangePhoto => 'Zmień zdjęcie profilowe';

  @override
  String get profileAppearance => 'Wygląd';

  @override
  String get profileThemeDisplayMode => 'Motyw i tryb wyświetlania';

  @override
  String get profileLanguage => 'Język';

  @override
  String get profileDisplayLanguage => 'Język wyświetlania';

  @override
  String get profileNotificationsSectionHeading => 'POWIADOMIENIA';

  @override
  String get profileAppBanners => 'Banery w aplikacji';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Wyświetlaj nowe banery powiadomień w aplikacji';

  @override
  String get profilePushNotificationsTitle => 'Powiadomienia push';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Powiadomienia na telefon dotyczące wydatków, znajomych, wycieczek i rozliczeń';

  @override
  String get profileSupportSectionHeading => 'WSPARCIE';

  @override
  String get profileContactUs => 'Skontaktuj się z nami';

  @override
  String get profileReportBugSuggestion => 'Zgłoś błąd / Sugestia';

  @override
  String get profileRateSplyto => 'Oceń Splyto';

  @override
  String get profileLeaveStoreRating => 'Zostaw ocenę sklepu';

  @override
  String get profileSecuritySectionHeading => 'BEZPIECZEŃSTWO';

  @override
  String get profileAccountAndSecurity => 'Konto i bezpieczeństwo';

  @override
  String get profileHelpTitle => 'Pomoc';

  @override
  String get profileChangePassword => 'Zmień hasło';

  @override
  String get profileUpdateAccountPassword => 'Zaktualizuj hasło do konta';

  @override
  String get profileDangerZoneSectionHeading => 'STREFA ZAGROŻENIA';

  @override
  String get profileManageAccountAccess => 'Zarządzaj dostępem do konta';

  @override
  String get profileMadeWithLabel => 'Stworzono przy użyciu';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Funkcja oceniania sklepu zostanie uruchomiona w następnym kroku.';

  @override
  String get profileFailedSaveNotificationSettings => 'Nie udało się zapisać ustawień powiadomień.';

  @override
  String get profilePushNotificationsSectionTitle => 'POWIADOMIENIA PUSH';

  @override
  String get profileInAppBannersSectionTitle => 'BANERY W APLIKACJI';

  @override
  String get profileInAppTripMemberAddedTitle => 'Członek dodany do wycieczki';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automatyczne przypomnienie o rozliczeniu';

  @override
  String get profileExpenseUpdates => 'Aktualizacje wydatków';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Bannery dotyczące dodanych wydatków w aplikacji';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Powiadomienia o dodanych wydatkach na telefon';

  @override
  String get profileFriendInvites => 'Zaproszenia od znajomych';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Banery z prośbami o dodanie do znajomych i odpowiedziami w aplikacji';

  @override
  String get profileFriendRequestResponseNotifications => 'Powiadomienia o zaproszeniach do grona znajomych i odpowiedziach na nie';

  @override
  String get profileTripUpdates => 'Aktualizacje dotyczące wycieczki';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Paski informacyjne dotyczące cyklu życia wycieczki i statusu uczestników w aplikacji';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Cykl życia wycieczki i zmiany statusu uczestników';

  @override
  String get profileSettlementUpdates => 'Aktualizacje dotyczące rozliczeń';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Oznaczone jako wysłane i potwierdzone banery płatności w aplikacji';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Oznaczone jako wysłane i potwierdzone aktualizacje dotyczące płatności';

  @override
  String get profileScreenshotSizeMust8Mb => 'Rozmiar zrzutu ekranu nie może przekraczać 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Prześlij opinię';

  @override
  String get profileFeedbackTypeLabel => 'Typ';

  @override
  String get profileFeedbackTypeBug => 'Błąd';

  @override
  String get profileFeedbackTypeSuggestion => 'Sugestia';

  @override
  String get profileDescribeIssueSuggestion => 'Opisz problem lub sugestię';

  @override
  String get profilePickingImage => 'Wybieranie obrazu...';

  @override
  String get profileAttachScreenshot => 'Załącz zrzut ekranu';

  @override
  String get profileChangeScreenshot => 'Zmień zrzut ekranu';

  @override
  String get profileRemoveImage => 'Usuń obrazek';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Wskazówka: dołącz zrzut ekranu, aby przyspieszyć klasyfikację błędów';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Przed wysłaniem dodaj szczegóły lub załącz zrzut ekranu';

  @override
  String get profileSendAction => 'Wyślij';

  @override
  String get profileThanksFeedbackSent => 'Dziękujemy! Opinia wysłana';

  @override
  String get profileFailedSendFeedback => 'Nie udało się wysłać opinii';

  @override
  String get profileCouldNotOpenWebsite => 'Nie udało się otworzyć strony internetowej.';

  @override
  String get profileOpenWebsiteQuestion => 'Otwórz stronę internetową?';

  @override
  String get profileOpenPortfolioAction => 'Otwórz portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Ten format obrazu nie jest obsługiwany na tym urządzeniu. Wybierz format JPG lub PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Do zmiany hasła wymagany jest prawidłowy adres e-mail konta. Skontaktuj się z pomocą techniczną, jeśli brakuje adresu e-mail lub jest on nieprawidłowy.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Link do usunięcia został wysłany na Twój adres e-mail.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Nie udało się wysłać linku do usunięcia. Spróbuj ponownie.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Wprowadź aktualne hasło, aby zmienić adres e-mail.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Wiadomość weryfikacyjna została wysłana na nowy adres e-mail. Powiadomienie dotyczące bezpieczeństwa zostało wysłane na Twój aktualny adres e-mail.';

  @override
  String get profileEditOverviewCurrency => 'Przegląd walut';

  @override
  String get profileEditPaymentMethod => 'Metoda płatności';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Przelew bankowy, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Wprowadź hasło (opcjonalnie w przypadku Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Wyślij link do usunięcia na adres e-mail';

  @override
  String get profileEditBackProfile => 'Powrót do profilu';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Przed zmianą hasła należy podać prawidłowy adres e-mail w profilu.';

  @override
  String get profileEditPasswordUpdated => 'Zaktualizowano hasło.';

  @override
  String get profileEditFailedUpdatePassword => 'Nie udało się zaktualizować hasła.';

  @override
  String profileEditEmail(Object email) {
    return 'Konto: $email';
  }

  @override
  String get profileEditPrimary => 'Podstawowe';

  @override
  String get profileEditSearchCurrency => 'Wyszukiwanie waluty';

  @override
  String get profileEditNoCurrenciesFound => 'Nie znaleziono walut';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Sumy w przeglądzie są przeliczane na tę walutę.';

  @override
  String get profileEditPaymentInfoUpdated => 'Zaktualizowano informacje dotyczące płatności.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Nie udało się zapisać informacji o płatności. Spróbuj ponownie.';

  @override
  String get profileEditCurrentPassword => 'Aktualne hasło';

  @override
  String get profileEditBankTransferIbanSwift => 'Przelew bankowy (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'link paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Wybierz metodę płatności';

  @override
  String get profileEditTapChange => 'Dotknij, aby zmienić';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'W przypadku przelewów w Wielkiej Brytanii kod sortujący musi składać się z 6 cyfr, a numer konta z 8 cyfr.';

  @override
  String get profileEditPaymentInfo => 'Informacje o płatnościach';

  @override
  String get profileEditSaveDetails => 'Zapisz szczegóły';

  @override
  String get profileEditBankRegion => 'Region bankowy';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'Kod sortujący';

  @override
  String get profileEditExample112233 => 'Przykład: 112233';

  @override
  String get profileEditNumber => 'Numer konta';

  @override
  String get profileEdit8Digits => '8 cyfr';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'W przypadku przelewów krajowych w Wielkiej Brytanii należy podać kod sortujący + numer konta.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Przykład: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 lub 11 znaków';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Nazwisko posiadacza konta pochodzi z pełnego imienia i nazwiska podanego w profilu.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username lub nazwa użytkownika';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Wielka Brytania';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Dostosuj awatar';

  @override
  String get imageCropperAdjustTripImage => 'Dostosuj zdjęcie wycieczki';

  @override
  String get imageCropEditAction => 'Edytuj kadrowanie';

  @override
  String get imageCropZoomIn => 'Powiększ';

  @override
  String get imageCropZoomOut => 'Pomniejsz';

  @override
  String get imageCropZoomOnly => 'Zapisano tylko przyciętą wersję tego zdjęcia, więc możesz je tylko powiększyć.';

  @override
  String get imageCropLoadFailed => 'Nie udało się otworzyć tego zdjęcia.';

  @override
  String get imageCropSaveFailed => 'Nie udało się zapisać nowego kadrowania. Spróbuj ponownie.';

  @override
  String get imageCropChanged => 'To zdjęcie zostało w międzyczasie zmienione. Zamknij ten ekran i otwórz go ponownie.';

  @override
  String get copyAction => 'Kopiuj';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Funt brytyjski';

  @override
  String get currencyNameChf => 'Frank szwajcarski';

  @override
  String get currencyNameNok => 'Korona norweska';

  @override
  String get currencyNameSek => 'Korona szwedzka';

  @override
  String get currencyNameDkk => 'Korona duńska';

  @override
  String get currencyNamePln => 'Złoty polski';

  @override
  String get currencyNameCzk => 'Korona czeska';

  @override
  String get currencyNameHuf => 'Forint węgierski';

  @override
  String get currencyNameRon => 'Lej rumuński';

  @override
  String get currencyNameBgn => 'Lew bułgarski';

  @override
  String get currencyNameIsk => 'Korona islandzka';

  @override
  String get currencyNameAll => 'Lek albański';

  @override
  String get currencyNameBam => 'Bośnia i Hercegowina Mark';

  @override
  String get currencyNameByn => 'Rubel białoruski';

  @override
  String get currencyNameMdl => 'Leu mołdawski';

  @override
  String get currencyNameMkd => 'Denar macedoński';

  @override
  String get currencyNameRsd => 'Dinar serbski';

  @override
  String get currencyNameUah => 'Hrywna ukraińska';

  @override
  String get currencyNameGel => 'Lari gruzińskie';

  @override
  String get currencyNameTry => 'Lira turecka';

  @override
  String get currencyNameUsd => 'Dolar amerykański';

  @override
  String get currencyNameJpy => 'Jen japoński';

  @override
  String get currencyNameCny => 'Juan chiński';

  @override
  String get currencyNameCad => 'Dolar kanadyjski';

  @override
  String get currencyNameAud => 'Dolar australijski';

  @override
  String get expenseCategoryFood => 'Jedzenie';

  @override
  String get expenseCategoryGroceries => 'Artykuły spożywcze';

  @override
  String get expenseCategoryFuel => 'Paliwo';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryAccommodation => 'Zakwaterowanie';

  @override
  String get expenseCategoryActivities => 'Atrakcje';

  @override
  String get expenseCategoryTickets => 'Bilety';

  @override
  String get expenseCategoryShopping => 'Zakupy';

  @override
  String get expenseCategoryParty => 'Imprezy';

  @override
  String get expenseCategoryParking => 'Parkowanie';

  @override
  String get expenseCategoryOther => 'Inne';

  @override
  String get shellTripAlreadyInListOpened => 'Wycieczka znajduje się już na Twojej liście. Otworzyliśmy ją dla Ciebie.';

  @override
  String get shellJoinedTripFromInviteLink => 'Dołączyłem do wycieczki poprzez link z zaproszeniem.';

  @override
  String get shellFailedToOpenInviteLink => 'Nie udało się otworzyć linku z zaproszeniem.';

  @override
  String get shellFailedToOpenFriendLink => 'Nie udało się otworzyć linku znajomego.';

  @override
  String get shellTripInviteTitle => 'Zaproszenie na wycieczkę';

  @override
  String get shellNoAction => 'Nie';

  @override
  String get shellYesAction => 'Tak';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Tylko twórca wycieczki może usunąć tę wycieczkę.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Usunąć można wyłącznie aktywne wycieczki.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Usunąć „$tripLabel”? Jest to dozwolone wyłącznie przed dodaniem jakichkolwiek wydatków.';
  }

  @override
  String get shellTripDeleted => 'Wycieczka została usunięta.';

  @override
  String get shellFailedToDeleteTrip => 'Nie udało się usunąć wycieczki.';

  @override
  String get shellFailedToLoadNotifications => 'Nie udało się załadować powiadomień.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nowe powiadomienie: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Nie udało się zaktualizować powiadomień.';

  @override
  String get shellMarkAllAsReadAction => 'Oznacz wszystko jako przeczytane';

  @override
  String get shellNewSection => 'Nowe';

  @override
  String get shellEarlierSection => 'Wcześniej';

  @override
  String get shellShowMoreEarlierAction => 'Pokaż więcej wcześniejszych wpisów';

  @override
  String get shellLoadingMore => 'Ładowanie kolejnych danych...';

  @override
  String get shellLoadMoreNotificationsAction => 'Pobierz więcej powiadomień';

  @override
  String get shellTripNoLongerAvailable => 'Ta wycieczka nie jest już dostępna.';

  @override
  String get shellFailedToOpenTrip => 'Nie udało się otworzyć wycieczki.';

  @override
  String get shellYesterday => 'Wczoraj';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Jesteś już członkiem wycieczki „$tripName”. Czy chcesz otworzyć tę wycieczkę teraz?\n\nZaprosił: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Czy chcesz dołączyć do wycieczki „$tripName”?\n\nZaprosił: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Wybrany obraz: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Zdjęcie wycieczki zostało już ustawione.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Wycieczka została utworzona, ale nie udało się przesłać zdjęcia.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Wycieczka utworzona, ale nie udało się przesłać zdjęcia: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Dołącz do wycieczki poprzez zaproszenie';

  @override
  String get tripsTotalTrips => 'Łączna liczba wycieczek';

  @override
  String get tripsTotalSpent => 'Łączna kwota wydatków';

  @override
  String get tripsMixedCurrencies => 'Mieszane waluty';

  @override
  String get tripsShowActive => 'Pokaż aktywne';

  @override
  String get tripsSeeAll => 'Zobacz wszystkie';

  @override
  String get tripsGridView => 'Widok siatki';

  @override
  String get tripsListView => 'Widok listy';

  @override
  String get tripsAddNewTrip => 'Dodaj nową wycieczkę';

  @override
  String get tripsLoadMore => 'Pobierz więcej';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Usunąć „$arg1”? Jest to dozwolone wyłącznie przed dodaniem jakichkolwiek wydatków.';
  }

  @override
  String get tripsTripDates => 'Terminy wycieczki';

  @override
  String get tripsFrom => 'Z';

  @override
  String get tripsSelectDate => 'Wybierz datę';

  @override
  String get tripsTo => 'Do';

  @override
  String get tripsMainCurrency => 'Waluta główna';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Proszę wybrać okres podróży (daty od i do).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Data zakończenia wycieczki musi przypadać w dniu rozpoczęcia lub później.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Format okresu podróży jest nieprawidłowy. Wybierz daty ponownie.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Jesteś już uczestnikiem tej wycieczki.';

  @override
  String get tripsJoinedTripSuccessfully => 'Pomyślnie dołączyłeś do wycieczki.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Nie udało się dołączyć do wycieczki na podstawie zaproszenia.';

  @override
  String get tripsJoinTrip => 'Dołącz do wycieczki';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Wklej link zaproszenia lub token zaproszenia.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Wprowadź prawidłowy link zaproszeniowy lub token.';

  @override
  String get tripsClipboardIsEmpty => 'Schowek jest pusty.';

  @override
  String get tripsPaste => 'Wklej';

  @override
  String get tripsJoin => 'Dołącz';

  @override
  String get workspaceTripMembers => 'Uczestnicy wycieczki';

  @override
  String get workspaceFailedToLoadFriends => 'Nie udało się załadować znajomych.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Nie udało się wygenerować linku zaproszeniowego.';

  @override
  String get workspaceInviteLink => 'Link zaproszeniowy';

  @override
  String get workspaceGeneratingInviteLink => 'Tworzenie linku zaproszeniowego...';

  @override
  String get workspaceInviteLinkUnavailable => 'Link zaproszeniowy niedostępny.';

  @override
  String get workspaceCopyInviteLink => 'Skopiuj link zaproszenia';

  @override
  String get workspaceInviteLinkCopied => 'Link zaproszenia skopiowany.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Wygasanie: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Brak dostępnych znajomych. Najpierw dodaj znajomych.';

  @override
  String get workspaceSettle => 'Rozlicz';

  @override
  String get workspaceOwesToTheGroup => 'Zobowiązania wobec grupy';

  @override
  String get workspaceGetsBackFromGroup => 'Ma otrzymać pieniądze od grupy';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Wyświetlanie 4 najlepszych wyników według różnicy salda.';

  @override
  String get workspaceOpenFlow => 'Szczegóły';

  @override
  String get workspaceFriend => 'Przyjaciel';

  @override
  String get workspaceSettlementTransfer => 'Przelew rozliczeniowy';

  @override
  String get workspaceCompleted => 'Zakończono';

  @override
  String get workspaceWaitingForConfirmation => 'Oczekiwanie na potwierdzenie';

  @override
  String get workspaceWaitingForPayment => 'Oczekiwanie na płatność';

  @override
  String get workspaceActionNeeded => 'Konieczne działanie';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return '$arg1 płatności do oznaczenia jako wysłane, $arg2 do potwierdzenia jako odebrane.';
  }

  @override
  String get workspaceReadyToSettle => 'Gotowi do rozliczenia';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Wszyscy członkowie są gotowi. Możesz rozpocząć rozliczenia.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Czekamy, aż wszyscy zaznaczą, że są gotowi.';

  @override
  String get workspaceIMReady => 'Jestem gotowy';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Upewnij się, że dodałeś wszystkie swoje wydatki.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Przycisk „Zakończ” odblokowuje się, gdy wszyscy zaznaczą, że są gotowi.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Ma otrzymać pieniądze od grupy';

  @override
  String get workspaceSettledWithTheGroup => 'Uzgodnione z grupą';

  @override
  String get workspaceTotalPaid => 'Łączna kwota zapłacona';

  @override
  String get workspaceTotalOwes => 'Łączna kwota należności';

  @override
  String get workspaceTransactionHistory => 'Historia transakcji';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Brak transakcji dla tego członka.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Rozliczenia: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Wszyscy uczestnicy muszą zaznaczyć, że są gotowi, przed rozpoczęciem rozliczeń.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Oznaczyłeś, że jesteś gotowy do rozliczenia.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Usunięto oznaczenie „gotowe do rozliczenia”.';

  @override
  String get workspaceReminderSent => 'Wysłano przypomnienie.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Link zaproszeniowy lub dodaj z listy znajomych';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Tylko twórca wycieczki może edytować tę wycieczkę.';

  @override
  String get workspaceTripUpdated => 'Wycieczka zaktualizowana.';

  @override
  String get workspaceFailedToUpdateTrip => 'Nie udało się zaktualizować wycieczki.';

  @override
  String get workspaceNoMembersSelectedYet => 'Nie wybrano jeszcze żadnych uczestników.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Brak połączenia z internetem. Wydatek zostanie zapisany bez zdjęcia paragonu.';

  @override
  String get workspaceRandomPicker => 'Losowanie';

  @override
  String get workspaceCurrency => 'Waluta';

  @override
  String get workspaceCategory => 'Kategoria';

  @override
  String get workspaceCustomCategory => 'Kategoria niestandardowa';

  @override
  String get workspaceCategoryName => 'Nazwa kategorii';

  @override
  String get workspaceApartmentRentParkingEtc => 'Czynsz za mieszkanie, parking itp.';

  @override
  String get workspaceEnterACustomCategory => 'Wprowadź własną kategorię.';

  @override
  String get workspacePickAnExpenseCategory => 'Wybierz kategorię wydatków.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Nazwa kategorii musi składać się z co najmniej 2 znaków.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Nazwa kategorii musi mieć maksymalnie 64 znaki.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Suma procentowych podziałów musi wynosić 100%.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Liczba udziałów musi być większa od 0 dla każdego uczestnika.';

  @override
  String get workspaceTotalAmount => 'Kwota całkowita';

  @override
  String get workspaceOriginal => 'Oryginał';

  @override
  String get workspaceTotalCost => 'Całkowity koszt';

  @override
  String workspaceStarted(Object arg1) {
    return 'Rozpoczęto $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Zakończono $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Archiwalna wycieczka';

  @override
  String get workspaceActiveTrip => 'Aktywna wycieczka';

  @override
  String get workspaceMemberProfile => 'Profil członka';

  @override
  String get workspaceTripOwner => 'Organizator wycieczki';

  @override
  String get workspaceMember => 'Członek';

  @override
  String get workspaceReadyForSettlement => 'Gotowe do rozliczenia';

  @override
  String get workspaceNotReadyForSettlement => 'Nie gotowy do rozliczenia';

  @override
  String get workspaceBankDetails => 'Dane bankowe';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'Dane dotyczące numeru IBAN i wypłat zostaną dodane w tym miejscu w kolejnej aktualizacji.';

  @override
  String get workspacePaymentDetails => 'Szczegóły płatności';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Ten uczestnik nie dodał jeszcze danych dotyczących wypłaty.';

  @override
  String get workspaceBankTransfer => 'Przelew bankowy';

  @override
  String get workspaceHolder => 'Posiadacz';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Nie udało się otworzyć linku do płatności.';

  @override
  String get workspaceTripActivity => 'Aktywność związana z podróżą';

  @override
  String get workspacePaidExpenses => 'Pokryte wydatki';

  @override
  String get workspacePaidTotal => 'Łączna kwota do zapłaty';

  @override
  String get workspaceInvolvedIn => 'Zaangażowany w';

  @override
  String get workspaceCurrentTrip => 'Bieżąca podróż';

  @override
  String get workspaceCommonTrips => 'Wspólne podróże';

  @override
  String get workspaceLoadingCommonTrips => 'Ładowanie wspólnych podróży…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Nie znaleziono jeszcze wspólnych podróży.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Nie udało się wczytać wszystkich wspólnych podróży. Wyświetlana jest bieżąca podróż.';

  @override
  String get workspaceMembers => 'uczestnicy';

  @override
  String get workspaceExpense => 'Wydatki';

  @override
  String get workspacePaid => 'opłacone';

  @override
  String get workspaceLoadingMoreExpenses => 'Ładowanie kolejnych wydatków...';

  @override
  String get workspaceScrollDownToLoadMore => 'Przewiń w dół, aby załadować więcej';

  @override
  String get workspaceTripFinished => 'Wycieczka zakończona';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Rozliczenia są odblokowane dla tej podróży.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Zakończ wycieczkę, aby rozpocząć rozliczenia.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 oznaczył przelew jako wysłany.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Oczekiwanie na oznaczenie przez $arg1 jako opłacone.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 potwierdził otrzymanie płatności.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Oczekiwanie na potwierdzenie od $arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Wszystkie rozliczenia związane z podróżą są w pełni zakończone.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Stan końcowy po potwierdzeniu wszystkich przelewów.';

  @override
  String get workspaceSettlementFlow => 'Przebieg rozliczenia';

  @override
  String get workspaceActions => 'Działania';

  @override
  String get workspaceQuickPay => 'Szybka płatność';

  @override
  String get workspacePayWithRevolut => 'Płać za pomocą Revolut';

  @override
  String get workspacePayWithPaypal => 'Płać przez PayPal';

  @override
  String get workspacePayWithWise => 'Płać za pomocą Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Przelew został potwierdzony.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Oczekiwanie na wykonanie kolejnego kroku przez drugiego uczestnika.';

  @override
  String get workspaceSendReminder => 'Wyślij przypomnienie';

  @override
  String get workspaceInProgress => 'W trakcie realizacji';

  @override
  String get workspaceTimeUnknown => 'Czas nieznany';

  @override
  String get workspaceRemind => 'Przypomnienie';

  @override
  String get workspaceYourPosition => 'Twoje stanowisko';

  @override
  String get workspaceRecentActivity => 'Ostatnia aktywność';

  @override
  String get workspaceNoRecentActivityYet => 'Brak ostatnich działań.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Dodaj co najmniej jednego uczestnika, aby rozpocząć dzielenie kosztów.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Oznacz się jako gotowy do rozliczenia po dodaniu wszystkich wydatków.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Uczestnicy, którzy nie są jeszcze gotowi: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Wszyscy uczestnicy są gotowi. Możesz zakończyć wycieczkę i rozpocząć rozliczenia.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Wszyscy uczestnicy są gotowi. Czekamy na organizatora wycieczki, aby rozpocząć rozliczenia.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Rozliczenie w toku: $arg1 / $arg2 potwierdzone.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Brak działań oczekujących. Ta wycieczka została rozliczona.';

  @override
  String get workspaceNoActionsNeededRightNow => 'W tej chwili nie są wymagane żadne działania.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Powinieneś otrzymać $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Powinieneś zapłacić $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Jesteś obecnie zapisany na tę wycieczkę.';

  @override
  String get workspaceUnknownTime => 'Nieznany czas';

  @override
  String get workspaceJustNow => 'Właśnie teraz';

  @override
  String workspaceMinAgo(Object arg1) {
    return '$arg1 min temu';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return '$arg1 godz. temu';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return '$arg1 dni temu';
  }

  @override
  String get friendsRemoveFriend => 'Usuń znajomego';

  @override
  String get friendsRemoveThisFriend => 'Usunąć tego znajomego?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 zostanie usunięty z listy znajomych. Możesz dodać tę osobę ponownie później.';
  }

  @override
  String get friendsContinue => 'Kontynuuj';

  @override
  String get friendsFriendRemoved => 'Zuszyto znajomego.';

  @override
  String get friendsCouldNotRemoveFriend => 'Nie udało się usunąć znajomego.';

  @override
  String get friendsFriendProfile => 'Profil użytkownika';

  @override
  String get friendsMoreActions => 'Więcej działań';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Ten znajomy nie dodał jeszcze danych dotyczących wypłaty.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Nie udało się teraz wczytać wspólnych podróży.';

  @override
  String get friendsFinished => 'Zakończono';

  @override
  String friendsTrip(Object arg1) {
    return 'Wycieczka nr $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Uczestnicy: $arg1';
  }

  @override
  String get friendsNoDate => 'Brak daty';

  @override
  String get friendsIncomingRequests => 'PRZYCHODZĄCE PROŚBY';

  @override
  String get friendsSentInvites => 'WYSŁANE ZAPROSZENIA';

  @override
  String get friendsMyFriends => 'MOI ZNAJOMI';

  @override
  String get friendsRequests => 'Prośby';

  @override
  String get friendsIncoming => 'Wchodzące';

  @override
  String get friendsIncomingRequestSubtitle => 'chce się zaprzyjaźnić';

  @override
  String get friendsOutgoingInviteSubtitle => 'Wysłano zaproszenie';

  @override
  String get friendsNoPendingActivity => 'Brak zaproszeń do grona znajomych';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Zaproszenie wysłane do $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Brak przychodzących wniosków';

  @override
  String get friendsDecline => 'Odrzuć';

  @override
  String get friendsAccept => 'Akceptuj';

  @override
  String get friendsNoSentInvites => 'Brak wysłanych zaproszeń';

  @override
  String get friendsNoFriendsYet => 'Nie masz jeszcze znajomych';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Przewiń w dół, aby załadować więcej znajomych.';

  @override
  String get friendsUser => 'Użytkownik';

  @override
  String get friendsSearchUsers => 'Wyszukiwanie użytkowników';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Wyszukaj według nazwiska lub adresu e-mail i wyślij zaproszenie';

  @override
  String get friendsScanQr => 'Zeskanuj kod QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Zeskanuj innego użytkownika, aby dodać go do znajomych';

  @override
  String get friendsMyQr => 'Mój kod QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Pokaż lub udostępnij swój kod QR';

  @override
  String get friendsScanFriendQrTitle => 'Zeskanuj kod QR znajomego';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Umieść kod QR znajomego w ramce';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Trzymaj kod QR w kadrze';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Dodaj $arg1 do znajomych?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 otrzyma Twoje zaproszenie do grona znajomych.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Czy zaakceptować zaproszenie do grona znajomych od $arg1?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Zeskanuj ten kod QR lub udostępnij link, aby dodać mnie na Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Dodaj mnie na Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Link do znajomego w Splyto';

  @override
  String get shareAction => 'Udostępnij';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'Kod QR nie jest prawidłowym kodem znajomego.';

  @override
  String get friendsYouCannotAddYourself => 'Nie można dodać siebie samego.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Ten użytkownik znajduje się już na Twojej liście znajomych.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Zaproszenie do tego użytkownika zostało już wysłane.';

  @override
  String get friendsFriendRequestProcessed => 'Prośba o dodanie do znajomych została przetworzona.';

  @override
  String get friendsFailedToProcessFriendQr => 'Nie udało się przetworzyć kodu QR znajomego.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Nie udało się załadować Twojego profilu użytkownika.';

  @override
  String get friendsMyProfile => 'Mój profil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Wystąpił nieoczekiwany błąd podczas ładowania znajomych.';

  @override
  String get friendsFriendAdded => 'Dodano znajomego.';

  @override
  String get friendsRequestDeclined => 'Wniosek odrzucony.';

  @override
  String get friendsFailedToUpdateRequest => 'Nie udało się zaktualizować żądania.';

  @override
  String get friendsCancelInvite => 'Anuluj zaproszenie';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Czy chcesz anulować zaproszenie dla $arg1?';
  }

  @override
  String get friendsKeep => 'Zachowaj';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Zaproszenie do $arg1 zostało anulowane.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Nie udało się anulować zaproszenia.';

  @override
  String get analyticsOther => 'Inne';

  @override
  String get analyticsSelectATripForAnalytics => 'Wybierz wycieczkę do analizy';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Uczestnicy: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Codzienne wydatki';

  @override
  String get analyticsMyDaily => 'Moje dzienne wydatki';

  @override
  String get analyticsGroupDaily => 'Dzienne wydatki grupy';

  @override
  String get analyticsByMember => 'Według uczestnika';

  @override
  String get analyticsShowLess => 'Pokaż mniej';

  @override
  String get analyticsByCategory => 'Według kategorii';

  @override
  String get analyticsQuickInsights => 'Szybki przegląd';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Największy wydatek: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Największy wydawca: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Najwyższy dzień w grupie: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Brak dat';

  @override
  String get friendsSearchFailedTryAgain => 'Wyszukiwanie nie powiodło się. Spróbuj ponownie.';

  @override
  String get friendsFailedToSendInvite => 'Nie udało się wysłać zaproszenia.';

  @override
  String get friendsAddFriend => 'Dodaj znajomego';

  @override
  String get friendsSearchByNameOrEmail => 'Wyszukiwanie według nazwiska lub adresu e-mail';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Wpisz co najmniej 2 znaki, aby rozpocząć wyszukiwanie.';

  @override
  String get friendsNoUsersFound => 'Nie znaleziono żadnych użytkowników';

  @override
  String get friendsInviteAction => 'Zaproś';

  @override
  String get workspacePaidForGroup => 'Płatna grupa';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Opłacona grupa • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Podział kosztów';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Podział kosztów • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Skopiowano nazwisko posiadacza.';

  @override
  String get paymentIbanCopied => 'Skopiowano numer IBAN.';

  @override
  String get paymentSwiftCopied => 'Kopiowano z SWIFT.';

  @override
  String get paymentRevtagCopied => 'Revtag skopiowany.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Nie udało się skopiować do schowka.';

  @override
  String get paymentCopied => 'Skopiowano.';

  @override
  String get paymentRequestAction => 'Poproś o płatność';

  @override
  String get paymentRecordAction => 'Rejestruj płatności';

  @override
  String get paymentRequestSheetTitle => 'Poproś o płatność';

  @override
  String get paymentRecordSheetTitle => 'Rejestruj płatności';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Poproś $arg1 o zapłacenie kwoty, którą obecnie jest ci winien.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Użyj tej opcji po dokonaniu płatności na rzecz $arg1 poza platformą Splyto. Osoba ta potwierdzi jej otrzymanie.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Maksymalnie $arg1';
  }

  @override
  String get paymentNoteHint => 'Przelew bankowy, Revolut, gotówka...';

  @override
  String get paymentAmountPositiveError => 'Kwota musi być większa od zera.';

  @override
  String get paymentAmountTooHighError => 'Kwota nie może przekraczać salda należności.';

  @override
  String get paymentRequestCreated => 'Wysłano prośbę o płatność.';

  @override
  String get paymentRecordedWaiting => 'Płatność zarejestrowana. Oczekujemy na potwierdzenie.';

  @override
  String get paymentConfirmTitle => 'Potwierdź płatność';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Potwierdź, że otrzymałeś $arg1 od $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Płatność potwierdzona.';

  @override
  String get paymentCancelRecordTitle => 'Anuluj zapis płatności';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Anulować zapis Twojej płatności na kwotę $arg1 dla osoby $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Rejestracja płatności została anulowana.';

  @override
  String get paymentNotReceivedTitle => 'Płatność nie została otrzymana';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Czy oznaczyć płatność $arg1 od $arg2 jako nieotrzymaną?';
  }

  @override
  String get paymentMarkedNotReceived => 'Płatność oznaczona jako nieotrzymana.';

  @override
  String get paymentActivityTitle => 'Działania związane z płatnościami';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Otwarte prośby o płatność: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Płatności oczekujące na potwierdzenie: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Zarejestrowane płatności';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 poprosił $arg2 o płatność';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 zapłacił $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Wniosek o płatność';

  @override
  String get paymentAwaitingConfirmationStatus => 'Oczekiwanie na potwierdzenie';

  @override
  String get paymentReviewRequestAction => 'Wniosek o weryfikację';

  @override
  String get paymentViewDetailsAction => 'Szczegóły płatności';

  @override
  String get paymentMarkPaidAction => 'Zapłaciłem';

  @override
  String get paymentDeclineAction => 'Odrzuć';

  @override
  String get paymentRequestReviewTitle => 'Prośba o płatność';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 poprosił Cię o $arg2. Dokonaj płatności poza Splyto, a następnie oznacz ją jako opłaconą.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Oznaczyć prośbę jako opłaconą?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Potwierdź dopiero po dokonaniu płatności $arg1 na rzecz $arg2 poza platformą Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Oznaczone jako opłacone. Oczekiwanie na potwierdzenie.';

  @override
  String get paymentRequestCancelTitle => 'Anulować żądanie płatności?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Czy chcesz anulować swoją prośbę $arg1 skierowaną do $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Żądanie płatności zostało anulowane.';

  @override
  String get paymentRequestDeclineTitle => 'Odrzucić prośbę o płatność?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Odrzucić prośbę o zapłatę kwoty $arg1 od osoby $arg2? Ta osoba otrzyma powiadomienie.';
  }

  @override
  String get paymentRequestDeclined => 'Prośba o płatność została odrzucona.';

  @override
  String get paymentPendingBeforeFinish => 'Przed ostatecznym rozliczeniem należy rozstrzygnąć otwarte wnioski o płatność i niepotwierdzone płatności.';

  @override
  String get paymentFinishBlockedByPending => 'Zakończenie zostaje odblokowane po rozstrzygnięciu żądań płatności i niepotwierdzonych płatności.';

  @override
  String get notificationPaymentRequestedTitle => 'Wniosek o płatność';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 poprosił Cię o $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Otrzymałeś prośbę o płatność.';

  @override
  String get notificationPaymentRequestSentTitle => 'Wysłano żądaną płatność';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 oznaczył Twoje zlecenie płatnicze $arg2 jako opłacone.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Twoje zlecenie płatnicze zostało oznaczone jako opłacone.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Anulowano prośbę o płatność';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 anulował żądanie płatności $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Żądanie płatności zostało anulowane.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Odmowa prośby o płatność';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 odrzucił Twoją prośbę o płatność $arg2.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Twoja prośba o płatność została odrzucona.';

  @override
  String get notificationPaymentSentTitle => 'Płatność oznaczona jako wysłana';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 oznaczył $arg2 jako zapłacone na Twoją rzecz.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Płatność została oznaczona jako wysłana do Ciebie.';

  @override
  String get notificationPaymentConfirmedTitle => 'Płatność potwierdzona';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 potwierdził otrzymanie od Ciebie kwoty $arg2.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Twoja płatność została potwierdzona.';

  @override
  String get notificationPaymentCancelledTitle => 'Płatność anulowana';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 anulował oznaczenie płatności $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Znacznik płatności został anulowany.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Płatność nie została otrzymana';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 oznaczył płatność $arg2 jako nieotrzymaną.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Płatność została oznaczona jako nieotrzymana.';

  @override
  String get quickStartTitle => 'Szybki start';

  @override
  String get quickStartCreateTitle => 'Solo lub ze znajomymi';

  @override
  String get quickStartCreateBody => 'Utwórz wycieczkę dla siebie lub grupy. Dodaj znajomych przez link lub kod QR i zaproś ich.';

  @override
  String get quickStartInviteTitle => 'Podróżujcie razem lub samodzielnie';

  @override
  String get quickStartInviteBody => 'Zaproś znajomych, aby dołączyli do Twojej podróży, lub rozpocznij własną, prywatną podróż.';

  @override
  String get quickStartExpenseTitle => 'Wydatki w wielu walutach';

  @override
  String get quickStartExpenseBody => 'Wybierz, kto zapłacił i jak podzielić. Inne waluty są przeliczane po kursie z dnia zakupu, nawet jeśli dodasz je później.';

  @override
  String get quickStartSettleTitle => 'Rozliczaj się łatwo';

  @override
  String get quickStartSettleBody => 'Zobacz, kto komu ile jest winien, zapłać w dogodny sposób i potwierdź to w aplikacji.';

  @override
  String get quickStartAnalyticsTitle => 'Budżet i wydatki';

  @override
  String get quickStartAnalyticsBody => 'Ustaw budżet wycieczki lub grupy i sprawdzaj wydatki według kategorii, wycieczek i dni.';

  @override
  String get quickStartMapTitle => 'Zachowaj swoje miejsca';

  @override
  String get quickStartMapBody => 'Dodaj odwiedzone miasta do swojej prywatnej mapy podróży. Widzisz ją tylko Ty.';

  @override
  String get quickStartLiveTitle => 'Znajdźcie się nawzajem';

  @override
  String get quickStartLiveBody => 'W wycieczkach grupowych udostępniaj swoją lokalizację na żywo przez wybrany czas. Widzą ją uczestnicy wycieczki, a Ty możesz zakończyć w dowolnej chwili.';

  @override
  String get quickStartNext => 'Dalej';

  @override
  String get quickStartBack => 'Powrót';

  @override
  String get quickStartSkip => 'Pomiń';

  @override
  String get quickStartCreateAction => 'Utwórz wycieczkę';

  @override
  String get quickStartClose => 'Zamknij „Szybki start”';

  @override
  String get quickStartSubtitle => 'Zobacz, jak działają wycieczki i wydatki';

  @override
  String quickStartStep(int step, int total) {
    return 'Krok $step z $total';
  }

  @override
  String get workspaceTripTotal => 'Suma za wycieczkę';

  @override
  String get workspacePersonalTotal => 'Łączna kwota wydatków';

  @override
  String get workspaceBalanceEven => 'Twoje saldo jest wyrównane';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Masz do zapłaty $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Masz do otrzymania $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Uczestnicy: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Wyszukiwanie wydatków';

  @override
  String get workspaceClearSearch => 'Czyste wyszukiwanie';

  @override
  String get workspaceSearchLoadedHint => 'Wyszukiwanie obejmuje załadowane wydatki. Załaduj więcej, aby uwzględnić starsze wydatki.';

  @override
  String get workspaceNoExpenseMatches => 'Brak pasujących wydatków';

  @override
  String get workspaceNoExpenseMatchesBody => 'Spróbuj wykonać inne wyszukiwanie lub wyczyść je, aby wyświetlić wszystkie załadowane wydatki.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Dodaj swój pierwszy wydatek, aby rozpocząć śledzenie swoich wydatków.';

  @override
  String get workspaceEmptyGroupExpenses => 'Dodaj swój pierwszy wspólny wydatek, aby zobaczyć udział każdego z uczestników.';

  @override
  String get workspaceLoadMoreExpenses => 'Załaduj więcej wydatków';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Pierwotna kwota: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Komentarze: $count';
  }

  @override
  String get workspaceExpenseActions => 'Czynności związane z wydatkami';

  @override
  String get workspaceLoadErrorTitle => 'Nie udało się załadować tej wycieczki';

  @override
  String get workspaceCachedWarning => 'Wyświetlanie zapisanych danych. Mogą one być nieaktualne.';

  @override
  String get workspaceActivityTab => 'Aktywność';

  @override
  String get workspaceLoadingTrip => 'Ładowanie wycieczki';

  @override
  String get workspaceRefreshFailed => 'Odświeżanie nie powiodło się';

  @override
  String get expenseDetailsTitle => 'Szczegóły wydatków';

  @override
  String get expenseQuickCategories => 'Szybkie kategorie';

  @override
  String get expenseReceiptRead => 'Potwierdzono odczytanie pokwitowania i zaktualizowano formularz.';

  @override
  String get expenseReceiptNoData => 'Załączono paragon. Nie znaleziono wyraźnej kwoty, daty ani nazwy sprzedawcy.';

  @override
  String get expenseReceiptScanFailed => 'Wybrano pokwitowanie. Nie udało się odczytać automatycznie; sprawdź pola ręcznie.';

  @override
  String get expenseReceiptOffline => 'Potwierdzenie zostanie przesłane po zapisaniu. Automatyczne odczytywanie wymaga połączenia z internetem.';

  @override
  String get expenseReadingReceipt => 'Odczytywanie paragonu…';

  @override
  String get expenseCommentsLoadFailed => 'Nie udało się załadować komentarzy. Spróbuj ponownie.';

  @override
  String get expenseReplyAction => 'Odpowiedz';

  @override
  String get expenseReplyHint => 'Napisz odpowiedź…';

  @override
  String expenseReplyTo(String name) {
    return 'Odpowiedz $name';
  }

  @override
  String get balanceEmptyBody => 'Salda pojawiają się po dodaniu wydatków.';

  @override
  String get balanceAfterPayments => 'Salda obejmują potwierdzone płatności.';

  @override
  String get balanceExpenseShare => 'Podział kosztów';

  @override
  String get balanceHistoryScope => 'Zaksięgowane wydatki i potwierdzone płatności. Lista ta może nie obejmować całej historii podróży.';

  @override
  String balancePaymentTo(String name) {
    return 'Płatność na rzecz $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Płatność od $name';
  }

  @override
  String get settlementEmptyActive => 'Przed rozpoczęciem ostatecznych rozliczeń zaznacz wszystkich jako gotowych.';

  @override
  String get settlementEmptyClosed => 'Dla tej wycieczki nie ma żadnych przelewów.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return 'Potwierdzono $count z $total przelewów';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count z $total członków gotowych';
  }

  @override
  String get settlementMemberReady => 'Gotowe';

  @override
  String get settlementMemberNotReady => 'Nie gotowy';

  @override
  String get settlementSuggested => 'Sugerowany przelew';

  @override
  String get activityLoadFailed => 'Nie udało się odświeżyć aktywności. Wszelkie widoczne wpisy mogą być nieaktualne.';

  @override
  String get activityMember => 'Uczestnik wycieczki';

  @override
  String get friendsEmptyBody => 'Znajdź znajomego po imieniu lub adresie e-mail albo skorzystaj z kodu QR.';

  @override
  String get friendsDeclineAction => 'Odrzuć';

  @override
  String get friendsLoading => 'Ładowanie znajomych';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Wspólne wycieczki: $count';
  }

  @override
  String get memberActivityScope => 'Na podstawie wprowadzonych wydatków; kwota ta może nie obejmować całej podróży.';

  @override
  String get sharedTripsLoadedLimit => 'Wyświetla maksymalnie 20 udostępnionych wycieczek.';

  @override
  String get memberRemoveTitle => 'Usunąć uczestnika?';

  @override
  String memberRemoveBody(String name) {
    return 'Usunąć $name z tej podróży? Jest to możliwe tylko wtedy, gdy osoba ta nie ma żadnych wydatków, rozliczeń ani sald.';
  }

  @override
  String get memberRemoveAction => 'Usuń z wycieczki';

  @override
  String memberRemoved(String name) {
    return '$name został usunięty z wycieczki.';
  }

  @override
  String get profilePaymentNotAdded => 'Jeszcze nie dodano';

  @override
  String get friendRelationshipLabel => 'Przyjaciel';

  @override
  String get sharedTripsEmptyBody => 'W tym miejscu pojawią się wycieczki, do których oboje dołączycie.';

  @override
  String get analyticsAllTrips => 'Wszystkie wycieczki';

  @override
  String get analyticsByTrip => 'W ramach wycieczki';

  @override
  String get analyticsYourSpending => 'Twoje wydatki';

  @override
  String get analyticsActiveArchived => 'Aktywne i zarchiwizowane wycieczki';

  @override
  String get analyticsTrips => 'Wycieczki';

  @override
  String get analyticsAveragePerTrip => 'Średnia na wycieczkę';

  @override
  String get analyticsPaidByMember => 'Opłata uiszczana przez uczestnika';

  @override
  String get analyticsYouPaid => 'Zapłaciłeś.';

  @override
  String get analyticsYouGetBack => 'Do otrzymania';

  @override
  String get analyticsYouOwe => 'Do zapłaty';

  @override
  String get analyticsParticipants => 'Uczestnicy';

  @override
  String get analyticsYourCategories => 'Twoje wydatki według kategorii';

  @override
  String get analyticsLargestShares => 'Moje największe udziały w wydatkach';

  @override
  String get analyticsLargestExpenses => 'Największe wydatki';

  @override
  String get analyticsSpendingByTrip => 'Twoje wydatki w podziale na wycieczki';

  @override
  String get analyticsEmptyTitle => 'Na razie nie ma żadnych wydatków';

  @override
  String get analyticsEmptyBody => 'Twoje wydatki pojawią się tutaj po dodaniu wydatków do podróży.';

  @override
  String get analyticsPeriodEmptyBody => 'Nie ma żadnych kosztów związanych z tym widokiem. Spróbuj wybrać inną wycieczkę lub okres.';

  @override
  String get analyticsLoadFailed => 'Nie udało się załadować pełnego raportu wydatków. Spróbuj ponownie.';

  @override
  String get analyticsLastLoaded => 'Wyświetlanie ostatniego pomyślnie załadowanego raportu.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków',
      many: '$count wydatków',
      few: '$count wydatki',
      one: '$count wydatek',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Opcje wycieczki';

  @override
  String get editTripAction => 'Edytuj wycieczkę';

  @override
  String get deleteTripAction => 'Usuń wycieczkę';

  @override
  String get inviteTripMembersAction => 'Zaproś uczestników';

  @override
  String get tripCoverPhoto => 'Zdjęcie w tle';

  @override
  String get tripInviteLaterHint => 'Możesz zapraszać osoby po utworzeniu wycieczki.';

  @override
  String get inviteClipboardFailed => 'Nie udało się uzyskać dostępu do schowka. Spróbuj ponownie.';

  @override
  String get friendInviteToTrip => 'Zaproś na wycieczkę';

  @override
  String get friendChooseTrip => 'Wybierz wycieczkę';

  @override
  String get friendNoInvitableTrips => 'Brak dostępnych wycieczek. Możesz zapraszać znajomych do aktywnych wycieczek grupowych, którymi zarządzasz, o ile nie są oni już członkami lub nie mają zaproszenia oczekującego na akceptację.';

  @override
  String get friendTripInviteSent => 'Zaproszenie wysłane.';

  @override
  String get friendTripUnavailable => 'Ta wycieczka nie jest już dostępna dla tej czynności. Odśwież stronę i spróbuj ponownie.';

  @override
  String get friendTripActionFailed => 'Nie udało się wykonać tej czynności. Spróbuj ponownie.';

  @override
  String get profileContactDescription => 'Masz problem, sugestię lub pytanie dotyczące Splyto? Napisz do nas — chętnie pomożemy.';

  @override
  String get profileContactEmailAction => 'Napisz wiadomość e-mail';

  @override
  String get profileContactEmailUnavailable => 'Nie udało się otworzyć aplikacji pocztowej. Skopiuj adres i napisz do nas z poziomu swojej aplikacji pocztowej.';

  @override
  String get profilePrivacyPolicy => 'Polityka prywatności';

  @override
  String get privacyLoadFailed => 'Nie udało się załadować polityki prywatności. Spróbuj ponownie.';

  @override
  String get addReceiptAction => 'Dodaj pokwitowanie';

  @override
  String get receiptPickFailed => 'Nie udało się załadować potwierdzenia. Spróbuj ponownie.';

  @override
  String get receiptPhotoAccessDenied => 'W Ustawieniach zezwól aplikacji Splyto na dostęp do aparatu lub biblioteki zdjęć, a następnie spróbuj ponownie.';

  @override
  String get receiptPhotoLabel => 'Zdjęcie paragonu';

  @override
  String get replaceReceiptAction => 'Zastąp potwierdzenie';

  @override
  String get removeReceiptAction => 'Usuń potwierdzenie';

  @override
  String get restoreReceiptAction => 'Przywróć poprzedni paragon';

  @override
  String get expenseSplitBetween => 'Podział na';

  @override
  String get expenseEditParticipants => 'Wybierz uczestników';

  @override
  String get expenseCustomSplit => 'Indywidualny podział kosztów';

  @override
  String expenseSplitAllocated(String amount) {
    return 'Cała kwota $amount podzielona';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Pozostała kwota do podziału: $amount';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount powyżej sumy';
  }

  @override
  String get profilePaymentSharingTitle => 'Udostępnij metody płatności w moich wycieczkach';

  @override
  String get profilePaymentSharingDescription => 'Zezwalaj zaakceptowanym uczestnikom podróży, które tworzę lub do których dołączam, na wyświetlanie moich metod płatności. Dotyczy to obecnych i przyszłych podróży. Możesz wyłączyć tę opcję w dowolnym momencie, aby zablokować dalszy dostęp.';

  @override
  String get memberPaymentDetailsNotShared => 'Metody płatności nie są udostępniane lub są obecnie niedostępne.';

  @override
  String get homeTripInvitations => 'Zaproszenia na wycieczkę';

  @override
  String get homeNoTripInvitations => 'Brak oczekujących zaproszeń na wycieczkę';

  @override
  String get homeInvitationsLoadFailed => 'Nie udało się załadować zaproszeń. Spróbuj ponownie.';

  @override
  String get homeInvitationResponseFailed => 'Nie udało się odpowiedzieć na zaproszenie. Spróbuj ponownie.';

  @override
  String get homeTripShareFailed => 'Nie udało się udostępnić wycieczki. Spróbuj ponownie.';

  @override
  String get settleStillToReceive => 'Jeszcze do otrzymania';

  @override
  String get settleStillToPay => 'Nadal do zapłacenia';

  @override
  String get settleEstimateCaption => 'Szacunki oparte są na bieżących wydatkach. Kwoty mogą ulec zmianie do momentu zakończenia podróży.';

  @override
  String get settleOutstandingCaption => 'Oczekiwanie na płatność lub potwierdzenie.';

  @override
  String get settleWaitingForYou => 'Czekamy, aż zaznaczysz, że jesteś gotowy.';

  @override
  String get settleWhoPaysWhom => 'Kto płaci komu';

  @override
  String get settlePreviewCaption => 'Podgląd · sfinalizowane po zakończeniu wycieczki';

  @override
  String get settleOpenPaymentCaption => 'Otwórz płatność, aby wyświetlić szczegóły i dostępne działania.';

  @override
  String get tripBudgetEnable => 'Ustal budżet';

  @override
  String get tripBudgetSoloHint => 'Opcjonalny cel wydatków na tę wycieczkę.';

  @override
  String get tripBudgetGroupHint => 'Jeden wspólny budżet dla całej grupy.';

  @override
  String get tripBudgetAmount => 'Kwota budżetu';

  @override
  String get tripBudgetInvalid => 'Wprowadź kwotę od 0,01 do 999999999,99, z maksymalnie dwoma miejscami po przecinku.';

  @override
  String get tripBudgetTitle => 'Budżet wycieczki';

  @override
  String get tripBudgetGroupTitle => 'Budżet grupy';

  @override
  String get tripBudgetRemaining => 'Pozostałe';

  @override
  String get tripBudgetOver => 'Przekroczenie budżetu';

  @override
  String get tripBudgetSpent => 'Wydane';

  @override
  String get tripBudgetLimit => 'Budżet';

  @override
  String get travelMapTitle => 'Moja mapa podróży';

  @override
  String get travelMapSubtitle => 'Odwiedzone miejsca – specjalnie dla Ciebie.';

  @override
  String get travelMapHere => 'Byłem tutaj';

  @override
  String get travelMapAdd => 'Dodaj miejsce';

  @override
  String get travelMapSearch => 'Wyszukaj miasto i kraj';

  @override
  String get travelMapSearchAction => 'Wyszukiwanie';

  @override
  String get travelMapSearchHint => 'Na przykład: Lizbona, Portugalia';

  @override
  String get travelMapEmpty => 'Twoje kolejne wspomnienie zaczyna się tutaj';

  @override
  String get travelMapEmptyBody => 'Dodaj miasto, które odwiedziłeś, lub zamelduj się w miejscu, w którym obecnie się znajdujesz.';

  @override
  String get travelMapConfirm => 'Zapisać tę wizytę?';

  @override
  String get travelMapConfirmBody => 'Sprawdź miasto i datę przed zapisaniem ich na swojej prywatnej mapie.';

  @override
  String get travelMapDate => 'Data wizyty';

  @override
  String get travelMapSave => 'Zapisz na mojej mapie';

  @override
  String get travelMapCancel => 'Anuluj';

  @override
  String get travelMapClose => 'Zamknij';

  @override
  String get travelMapNoResults => 'Nie znaleziono miasta. Spróbuj dodać kraj do wyszukiwania.';

  @override
  String get travelMapLookupError => 'Nie można znaleźć miasta. Sprawdź połączenie lub dodaj miejsce ręcznie.';

  @override
  String get travelMapDenied => 'Dostęp do lokalizacji jest wyłączony. Nadal można ręcznie dodać miasto.';

  @override
  String get travelMapDisabled => 'Włącz usługi lokalizacyjne lub dodaj miasto ręcznie.';

  @override
  String get travelMapError => 'Nie udało się załadować mapy podróży. Spróbuj ponownie.';

  @override
  String get travelMapSaveError => 'Nie udało się zapisać wizyty. Spróbuj ponownie.';

  @override
  String get travelMapUnavailable => 'Mapa podróży wymaga aktualizacji serwera.';

  @override
  String get travelMapOffline => 'Tryb offline · wyświetlanie zapisanych miejsc';

  @override
  String get travelMapRetry => 'Spróbuj ponownie';

  @override
  String get travelMapDelete => 'Usuń wizytę';

  @override
  String get travelMapDeleteConfirm => 'Chcesz usunąć tę wizytę ze swojej prywatnej mapy?';

  @override
  String get travelMapFit => 'Pokaż wszystkie miejsca';

  @override
  String get travelMapSaved => 'Odwiedź zapisane';

  @override
  String get travelMapVisited => 'Odwiedzone';

  @override
  String get travelMapLimit => 'Twoja mapa osiągnęła 1 000 odwiedzin. Usuń starą wizytę przed dodaniem kolejnej.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries krajów',
      many: '$countries krajów',
      few: '$countries kraje',
      one: '$countries kraj',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities miast',
      many: '$cities miast',
      few: '$cities miasta',
      one: '$cities miasto',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wizyt',
      many: '$count wizyt',
      few: '$count wizyty',
      one: '$count wizyta',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Miejsca docelowe (opcjonalnie)';

  @override
  String get travelAddDestination => 'Dodaj miejsce docelowe';

  @override
  String get travelRemoveDestination => 'Usuń miejsce docelowe';

  @override
  String get travelFromTrip => 'Z wycieczki';

  @override
  String get travelChooseTrip => 'Wybierz wycieczkę';

  @override
  String get travelNoTrips => 'Nie ma jeszcze żadnych wycieczek. Możesz ręcznie dodać miejsce.';

  @override
  String get travelAddToMap => 'Dodaj do mojej mapy';

  @override
  String get travelTripConfirm => 'Zapisuj tylko miejsca, które faktycznie odwiedziłeś. W ten sposób wzbogacasz swoją mapę o prywatne wspomnienia.';

  @override
  String get travelVisitTitle => 'Tytuł (opcjonalnie)';

  @override
  String get travelAddPhoto => 'Dodaj zdjęcie';

  @override
  String get travelChangePhoto => 'Zmień zdjęcie';

  @override
  String get travelRemovePhoto => 'Usuń zdjęcie';

  @override
  String get travelPhotoError => 'Nie udało się przygotować tego zdjęcia. Wybierz inne.';

  @override
  String get travelEditVisit => 'Edytuj wizytę';

  @override
  String get travelOpenTrip => 'Otwórz wycieczkę';

  @override
  String get travelPreviousVisit => 'Poprzednia wizyta';

  @override
  String get travelNextVisit => 'Następna wizyta';

  @override
  String get travelDuplicate => 'Ta wizyta jest już zaznaczona na Twojej mapie.';

  @override
  String get liveMapTitle => 'Mapa na żywo';

  @override
  String get liveShareTitle => 'Udostępnij moją lokalizację';

  @override
  String get liveConsent => 'Udostępniaj swoją dokładną lokalizację tylko zaakceptowanym uczestnikom tej podróży przez wybrany czas. Udostępnianie działa również w tle i możesz je zatrzymać w dowolnym momencie.';

  @override
  String get liveBackgroundNote => 'Aktualizacje mogą zostać wstrzymane w przypadku braku połączenia z Internetem lub przymusowego zamknięcia aplikacji. Zachowywana jest wyłącznie ostatnia lokalizacja; historia trasy nie jest rejestrowana.';

  @override
  String get liveStart => 'Rozpocznij udostępnianie';

  @override
  String get liveStop => 'Zatrzymaj udostępnianie';

  @override
  String get liveNotification => 'Twoja lokalizacja jest udostępniana uczestnikom wycieczki. Otwórz aplikację Splyto, aby zatrzymać udostępnianie.';

  @override
  String get livePermissionError => 'Zezwól na dostęp do lokalizacji w ustawieniach telefonu, aby udostępniać swoją lokalizację.';

  @override
  String get liveStartError => 'Nie udało się rozpocząć udostępniania. Sprawdź dostęp do lokalizacji, połączenie z Internetem oraz datę i godzinę w telefonie.';

  @override
  String get liveStopPending => 'Aktualizacje zostały wstrzymane. Czekamy na połączenie z internetem, aby usunąć Twoją ostatnią lokalizację; zniknie ona z mapy w ciągu 2 minut bez aktualizacji.';

  @override
  String get liveSharing => 'udostępnia lokalizację';

  @override
  String get liveUnavailable => 'Ta mapa na żywo jest niedostępna. Wróć do wycieczki i odśwież stronę.';

  @override
  String get liveMapLoadError => 'Nie udało się załadować mapy. Sprawdź połączenie i otwórz mapę ponownie.';

  @override
  String get liveLoadError => 'Nie udało się odświeżyć lokalizacji. Wyświetlane są tylko najnowsze aktualizacje.';

  @override
  String get liveFit => 'Pokaż wszystkich na mapie';

  @override
  String get liveEmpty => 'Na razie nikt nie udostępnia swojej aktualnej lokalizacji.';

  @override
  String get liveRecent => 'Właśnie zaktualizowano';

  @override
  String get liveLastKnown => 'Ostatnia aktualizacja';

  @override
  String get liveAccuracy => 'Dokładność';

  @override
  String get liveUntil => 'Udostępnianie do';

  @override
  String get liveOtherSession => 'Rozpoczęto w innej sesji. Możesz to zatrzymać tutaj.';

  @override
  String get liveUpdatesPaused => 'Aktualizacje wstrzymane. Sprawdź dostęp do lokalizacji i połączenie internetowe.';

  @override
  String get livePrivateUntilShared => 'Twoja lokalizacja pozostaje prywatna, dopóki nie zdecydujesz się jej udostępnić.';

  @override
  String get activityEventExpenseCreated => 'dodał(a) wydatek';

  @override
  String get activityEventExpenseUpdated => 'zaktualizował(a) wydatek';

  @override
  String get activityEventExpenseDeleted => 'usunął(ęła) wydatek';

  @override
  String get activityEventExpenseCommentAdded => 'skomentował(a) wydatek';

  @override
  String get activityEventTripCreated => 'utworzył(a) wycieczkę';

  @override
  String get activityEventTripUpdated => 'zaktualizował(a) szczegóły wycieczki';

  @override
  String get activityEventTripRenamed => 'zmienił(a) nazwę wycieczki';

  @override
  String get activityEventTripCurrencyChanged => 'zmienił(a) walutę wycieczki';

  @override
  String get activityEventTripPhotoChanged => 'zmienił(a) zdjęcie wycieczki';

  @override
  String get activityEventTripBudgetChanged => 'zmienił(a) budżet wycieczki';

  @override
  String get activityEventTripDestinationsChanged => 'zmienił(a) cele wycieczki';

  @override
  String get activityEventTripMembersAdded => 'dodał(a) uczestników';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'wysłał(a) zaproszenia: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'dołączył(a) do wycieczki';

  @override
  String get activityEventTripInvitationDeclined => 'odrzucił(a) zaproszenie na wycieczkę';

  @override
  String get activityEventTripInvitationRevoked => 'anulował(a) zaproszenie na wycieczkę';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'usunął(ęła) $name z wycieczki';
  }

  @override
  String get activityEventTripMemberLeft => 'opuścił(a) wycieczkę';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'zmienił(a) rolę $name na $role';
  }

  @override
  String get activityEventTripMemberReady => 'zgłosił(a) gotowość do rozliczenia';

  @override
  String get activityEventTripMemberNotReady => 'wycofał(a) gotowość do rozliczenia';

  @override
  String get activityEventTripAllMembersReady => 'Wszyscy uczestnicy są gotowi do rozliczenia';

  @override
  String get activityEventTripFinished => 'zakończył(a) wycieczkę';

  @override
  String get activityEventTripSettled => 'Wszystkie przelewy potwierdzone, wycieczka rozliczona';

  @override
  String get activityEventSettlementMarkedSent => 'oznaczył(a) przelew jako wysłany';

  @override
  String get activityEventSettlementConfirmed => 'potwierdził(a) przelew';

  @override
  String get activityEventSettlementSentCancelled => 'anulował(a) status „wysłane”';

  @override
  String get activityEventSettlementNotReceived => 'oznaczył(a) przelew jako nieotrzymany';

  @override
  String get activityEventSettlementReminderSent => 'wysłał(a) przypomnienie o rozliczeniu';

  @override
  String get activityEventPaymentMarkedSent => 'zarejestrował(a) płatność';

  @override
  String get activityEventPaymentRequested => 'poprosił(a) o płatność';

  @override
  String get activityEventPaymentRequestMarkedSent => 'oznaczył(a) żądaną płatność jako wysłaną';

  @override
  String get activityEventPaymentRequestCancelled => 'anulował(a) prośbę o płatność';

  @override
  String get activityEventPaymentRequestDeclined => 'odrzucił(a) prośbę o płatność';

  @override
  String get activityEventPaymentConfirmed => 'potwierdził(a) płatność';

  @override
  String get activityEventPaymentCancelled => 'anulował(a) zapis płatności';

  @override
  String get activityEventPaymentNotReceived => 'oznaczył(a) płatność jako nieotrzymaną';

  @override
  String get activityEventUnknown => 'wprowadził(a) zmianę';

  @override
  String get privacyEnglishFallback => 'Polityka prywatności jest obecnie dostępna w języku angielskim.';

  @override
  String get activityRoleAdmin => 'Administrator';

  @override
  String get accountDeleteTitle => 'Usuń konto';

  @override
  String get accountDeleteIntro => 'Potwierdź usunięcie przez e-mail. Po potwierdzeniu nie można go cofnąć.';

  @override
  String get accountDeleteConsequences => 'Usunięcie jest nieodwracalne. Twój profil zostanie zanonimizowany, a dostęp do konta zostanie cofnięty. Udostępnione zapisy dotyczące podróży i wydatków są przechowywane dla pozostałych uczestników.';

  @override
  String get accountDeleteReasonsTitle => 'Co mogliśmy zrobić lepiej?';

  @override
  String get accountDeleteReasonsHint => 'Powód (opcjonalnie)';

  @override
  String get accountDeleteReasonNotUsing => 'Nie potrzebuję już Splyto do moich podróży';

  @override
  String get accountDeleteReasonAnotherWay => 'Zarządzam wspólnymi wydatkami w inny sposób';

  @override
  String get accountDeleteReasonComplicated => 'Załatwienie spraw wymaga zbyt dużego wysiłku';

  @override
  String get accountDeleteReasonTechnical => 'Napotkałem błędy lub problemy techniczne';

  @override
  String get accountDeleteReasonPrivacy => 'Wolałbym usunąć dane mojego konta';

  @override
  String get accountDeleteReasonOther => 'Chcę usunąć konto z innego powodu';

  @override
  String get accountDeleteEmailStep => 'Kolejnym krokiem jest potwierdzenie za pośrednictwem poczty elektronicznej.';

  @override
  String get accountDeletePasswordHint => 'Wprowadź swoje aktualne hasło do Splyto, aby poprosić o e-mail z potwierdzeniem. Twoje konto jest nadal aktywne.';

  @override
  String get accountDeleteInboxTitle => 'Ostatni krok w skrzynce odbiorczej';

  @override
  String accountDeleteSentBody(String email) {
    return 'Link potwierdzający wysłano na $email.';
  }

  @override
  String get accountDeleteSentHint => 'Twoje konto pozostanie aktywne do czasu potwierdzenia usunięcia.';

  @override
  String get accountDeleteSending => 'Wysyłanie e-maila z potwierdzeniem';

  @override
  String get friendsShowMore => 'Pokaż więcej';
}
