// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get homeFirstTrip => 'Ваша перша подорож';

  @override
  String get homeYourShareAllTrips => 'Твоя частка в усіх подорожах';

  @override
  String get homeAllTime => 'За весь час';

  @override
  String get homeSolo => 'Самостійно';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count осіб',
      many: '$count осіб',
      few: '$count особи',
      one: '$count особа',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Дії під час поїздки: $name';
  }

  @override
  String get homeNoActiveTrips => 'Немає активних подорожей';

  @override
  String get homeNoArchivedTrips => 'Немає подорожей в архіві';

  @override
  String get homeLoadingTrips => 'Завантаження ваших поїздок';

  @override
  String get homeLoadErrorTitle => 'Не вдалося завантажити ваші поїздки';

  @override
  String get homeLoadErrorBody => 'Будь ласка, спробуйте ще раз через хвилину.';

  @override
  String get homeOfflineTitle => 'Ви перебуваєте в режимі офлайн';

  @override
  String get homeOfflineNoData => 'Ваші поїздки ще не доступні на цьому пристрої.';

  @override
  String get homeOfflineCached => 'Офлайн. Відображення збережених поїздок.';

  @override
  String get homeRefreshError => 'Не вдалося оновити. Відображаються раніше завантажені поїздки.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Поділитися моїми збереженими платіжними реквізитами з $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Лише доти, доки цей запит очікує на оплату. Скасування запиту припиняє доступ.';

  @override
  String get paymentDetailsUnavailable => 'Реквізити платежу недоступні. Підключіться до Інтернету та перевірте, чи запит досі відкритий.';

  @override
  String get paymentDetailsRetry => 'Спробуйте ще раз';

  @override
  String get tripModeSolo => 'Лише я';

  @override
  String get tripModeGroup => 'З іншими';

  @override
  String get premiumFree => 'Безкоштовно';

  @override
  String get premiumStatusUnavailable => 'Статус плану недоступний';

  @override
  String premiumGrantedUntil(String date) {
    return 'Преміум-доступ надано до $date';
  }

  @override
  String get premiumBillingNotActive => 'Відсутність активної передплати';

  @override
  String get premiumRefreshStatus => 'Оновити статус плану';

  @override
  String get accountSectionTitle => 'Обліковий запис';

  @override
  String get activeStatus => 'Активний';

  @override
  String get activeTripPlural => 'активні поїздки';

  @override
  String get activeTripSingle => 'активна подорож';

  @override
  String get activeTrips => 'Активні поїздки';

  @override
  String get activitiesComingSoon => 'Розділ «Активності» з’явиться найближчим часом.';

  @override
  String get addAction => 'Додати';

  @override
  String get addExpenseTitle => 'Додати витрати';

  @override
  String get addExpensesAction => 'Додати витрати';

  @override
  String get addMembersAction => 'Додати учасників';

  @override
  String get addTripMembersTitle => 'Запрошуйте учасників поїздки';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count надісланих запрошень',
      many: '$count надісланих запрошень',
      few: '$count надіслані запрошення',
      one: '$count надіслане запрошення',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Запрошення на поїздку відхилено.';

  @override
  String get tripInviteAction => 'Запросити';

  @override
  String get tripInvitationsPending => 'Очікуємо на відповідь';

  @override
  String get tripInvitationsRetry => 'Запрошення недоступні. Спробуйте ще раз';

  @override
  String get tripInvitationRevoke => 'Скасувати запрошення';

  @override
  String get tripInvitationRevokeFailed => 'Не вдалося скасувати запрошення. Спробуйте ще раз.';

  @override
  String get tripInvitationBody => 'Вас запросили до поїздки. Відкрийте запрошення, щоб відповісти.';

  @override
  String get allCaughtUp => 'Усе переглянуто';

  @override
  String get allFilter => 'Усі';

  @override
  String get allMembersLabel => 'Усі учасники';

  @override
  String get allPaymentsConfirmed => 'Усі платежі підтверджуються.';

  @override
  String get allTrips => 'Усі поїздки';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Сума';

  @override
  String get amountMustBeGreaterThanZero => 'Сума повинна бути більшою за 0.';

  @override
  String get appearance => 'Зовнішній вигляд';

  @override
  String get archivedStatus => 'Архів';

  @override
  String get authSubtitleLogin => 'Розділяйте витрати на подорож із друзями';

  @override
  String get authSubtitleRegister => 'Створіть обліковий запис і почніть ділити витрати на поїздки';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'підтверджено: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'у процесі розгляду: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'надіслано: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'рекомендовано: $count';
  }

  @override
  String get cancelAction => 'Скасувати';

  @override
  String get changeEmailWithPasswordHelper => 'Введіть свій пароль, щоб змінити електронну адресу.';

  @override
  String get chooseReceiptFile => 'Виберіть файл квитанції';

  @override
  String get completeAccountSetupDescription => 'Вкажіть свою електронну адресу та пароль, щоб завершити реєстрацію облікового запису.';

  @override
  String get completeAccountSetupTitle => 'Завершіть налаштування облікового запису';

  @override
  String get confirmReceivedAction => 'Підтвердити отримання';

  @override
  String get confirmedAllSettlementsArchived => 'Усі розрахунки підтверджено. Подорож архівується.';

  @override
  String get confirmedAsReceived => 'Отримано та підтверджено.';

  @override
  String get confirmedLabel => 'Підтверджено';

  @override
  String get couldNotOpenReceiptLink => 'Не вдалося відкрити посилання на квитанцію.';

  @override
  String get createAction => 'Створити';

  @override
  String get createFirstTripHint => 'Створіть свою першу поїздку, щоб розпочати.';

  @override
  String get createNewTripTitle => 'Створити нову подорож';

  @override
  String get createTripAction => 'Створити поїздку';

  @override
  String get createTripFirst => 'Спочатку створіть поїздку.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Створено $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Організатор поїздки повинен завершити поїздку, щоб розпочати підтвердження розрахунків.';

  @override
  String currentEmailLabel(Object email) {
    return 'Поточна електронна адреса: $email';
  }

  @override
  String get currentReceiptAttached => 'Поточний квитанцію додано.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Дата';

  @override
  String get dateMustMatchFormat => 'Дата повинна відповідати формату YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Дата невідома';

  @override
  String get deleteAction => 'Видалити';

  @override
  String get deleteExpenseConfirmQuestion => 'Видалити цю витрату?';

  @override
  String get deleteExpenseTitle => 'Видалити витрати';

  @override
  String get editExpenseConfirmTitle => 'Зберегти зміни у витратах?';

  @override
  String get editExpenseConfirmText => 'Це оновить залишки на рахунках усіх учасників поїздки.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Пряме пояснення витрат: $amount';
  }

  @override
  String get doneStatus => 'Готово';

  @override
  String get editAction => 'Редагувати';

  @override
  String get editExpenseTitle => 'Редагування витрат';

  @override
  String get emailAddressLabel => 'Адреса електронної пошти';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'Веб-сайт';

  @override
  String get emailRequired => 'Електронна адреса є обов’язковою.';

  @override
  String get enterValidExactAmounts => 'Введіть дійсні точні суми для всіх учасників.';

  @override
  String get enterValidPercentages => 'Введіть дійсні відсотки для всіх учасників.';

  @override
  String get equalSplitLabel => 'Порівну';

  @override
  String exactAmountWithValue(Object value) {
    return 'Точно: $value';
  }

  @override
  String get exactAmountsLabel => 'Точні суми';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Точна сума розподілу повинна дорівнювати $amount.';
  }

  @override
  String get expenseAdded => 'Додано витрату.';

  @override
  String get expenseBreakdownSubtitle => 'Як кожна витрата впливає на цього учасника.';

  @override
  String get expenseBreakdownTitle => 'Розподіл витрат';

  @override
  String get expenseDeleted => 'Витрата видалена.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Витрата № $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Оплачено $paid  -  Заборгувано $owes';
  }

  @override
  String get expenseReactionsTitle => 'Реакції';

  @override
  String get expenseCommentsTitle => 'Коментарі';

  @override
  String get expenseNoComments => 'Поки що коментарів немає.';

  @override
  String get expenseAddCommentHint => 'Додати коментар...';

  @override
  String get expenseCommentSend => 'Надіслати';

  @override
  String get expenseDeleteCommentTitle => 'Видалити коментар?';

  @override
  String get expenseUpdated => 'Витрати оновлено.';

  @override
  String expenseWithId(Object id) {
    return 'Витрата № $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count витрат',
      many: '$count витрат',
      few: '$count витрати',
      one: '$count витрата',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Витрати';

  @override
  String get failedToCreateTrip => 'Не вдалося створити поїздку.';

  @override
  String get failedToLoadUsersDirectory => 'Не вдалося завантажити каталог користувачів.';

  @override
  String get filterSettlementByMemberSubtitle => 'Фільтруйте розрахунки за учасниками';

  @override
  String get finishSoloTripConfirmationText => 'Завершити цю поїздку та перемістити її до архіву? Ваші витрати залишаться доступними для перегляду.';

  @override
  String get soloTripArchived => 'Подорож завершена та архівується.';

  @override
  String get finishTripSyncPending => 'Синхронізуйте свої зміни, що очікують на затвердження, перед завершенням цієї подорожі.';

  @override
  String get finishTripAction => 'Завершити поїздку';

  @override
  String get finishTripConfirmationText => 'Завершити цю поїздку та розпочати розрахунки?';

  @override
  String get finishTripStartSettlementsAction => 'Завершення та початок розрахунків';

  @override
  String get finishTripTitle => 'Завершити поїздку';

  @override
  String forParticipants(Object participants) {
    return 'Для: $participants';
  }

  @override
  String get forgotPassword => 'Забули пароль?';

  @override
  String get profileSetPassword => 'Установити пароль';

  @override
  String get profileManagePassword => 'Установити або змінити пароль';

  @override
  String get profilePasswordByEmail => 'Встановити пароль електронною поштою';

  @override
  String get passwordEmailBackToProfile => 'Назад до профілю';

  @override
  String get forgotPasswordSubtitle => 'Введіть свою електронну адресу, і ми надішлемо посилання для скидання пароля.';

  @override
  String get forgotPasswordSuccessMessage => 'Якщо обліковий запис із цією електронною адресою вже існує, ми надіслали посилання для скидання пароля.';

  @override
  String get passwordResetSentTitle => 'Перевірте вхідні';

  @override
  String get passwordResetSentHint => 'Посилання дійсне 1 годину. Якщо ви не бачите листа, перевірте папку «Спам».';

  @override
  String get forgotPasswordTitle => 'Скинути пароль';

  @override
  String get friendsProgressSubtitle => 'Кожен учасник та його статус підтвердження.';

  @override
  String get friendsProgressTitle => 'Прогрес друзів';

  @override
  String get friendsSectionComingSoon => 'Розділ «Друзі» з’явиться незабаром.';

  @override
  String fromDirection(Object name) {
    return 'Від $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from до $to';
  }

  @override
  String get generateTurnAction => 'Обрати наступну людину жеребкуванням';

  @override
  String get hasAccountQuestion => 'У вас уже є обліковий запис?';

  @override
  String helloUser(Object name) {
    return 'Привіт, $name!';
  }

  @override
  String get iSentAction => 'Я надіслав';

  @override
  String get invalidEmailFormat => 'Неправильний формат електронної адреси.';

  @override
  String get languageAction => 'Мова';

  @override
  String get languageEnglish => 'Англійська';

  @override
  String get languageLatvian => 'Латвійська';

  @override
  String get languageSpanish => 'Іспанська';

  @override
  String get languageSystem => 'Системна';

  @override
  String get languageSystemSubtitle => 'Використовувати мову пристрою';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Залиште поле порожнім, щоб зберегти поточний пароль.';

  @override
  String get logInButton => 'Увійти';

  @override
  String get logOutButton => 'Вийти';

  @override
  String get logoutFromDeviceQuestion => 'Вийти з цього пристрою?';

  @override
  String get logoutRevocationUnconfirmed => 'Вийшли з облікового запису на цьому пристрої. Не вдалося підтвердити скасування сеансу на сервері.';

  @override
  String get markedAsSent => 'Позначено як надіслано.';

  @override
  String get markSettlementSentConfirmTitle => 'Позначити переказ як надісланий?';

  @override
  String get markSettlementSentConfirmText => 'Використовуйте цю функцію лише після того, як ви фактично надіслали платіж. Одержувача буде запропоновано підтвердити платіж.';

  @override
  String get settlementCancelSentAction => 'Позначити як не надіслане';

  @override
  String get settlementCancelSentConfirmTitle => 'Скасувати статус «відправлено»?';

  @override
  String get settlementCancelSentConfirmText => 'Це поверне переказ у статус «очікує на обробку» та сповістить одержувача.';

  @override
  String get settlementSentCancelled => 'Передача повернулася до статусу «очікує на затвердження».';

  @override
  String get settlementNotReceivedAction => 'Я цього не отримав';

  @override
  String get settlementNotReceivedConfirmTitle => 'Повідомити про неотриманий платіж?';

  @override
  String get settlementNotReceivedConfirmText => 'Це поверне переказ у статус «очікує на обробку» та повідомить про це платника.';

  @override
  String get settlementMarkedNotReceived => 'Позначено як «не отримано».';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Чи підтвердили отримання?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Підтверджуйте лише після того, як гроші з’являться на вашому рахунку. Ця дія може завершити розрахунок.';

  @override
  String get memberSummariesSubtitle => 'Поточний стан балансу для обох сторін.';

  @override
  String get memberSummariesTitle => 'Короткі відомості про учасників';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Оплатити $total  -  підтверджено $confirmed  -  очікує $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Орієнтовний вплив на оплату на одного учасника.';

  @override
  String get membersImpactTitle => 'Вплив учасників';

  @override
  String get membersIncludedInExpense => 'Учасники, що включені';

  @override
  String get membersLabel => 'Учасники';

  @override
  String moreCount(Object count) {
    return '+ ще $count';
  }

  @override
  String get myFilter => 'Мій';

  @override
  String get myImpactTitle => 'Мій вплив';

  @override
  String get firstNameHint => 'Ваше ім’я';

  @override
  String get firstNameLabel => 'Ім\'я';

  @override
  String get firstNameLengthValidation => 'Ім’я має містити від 2 до 64 символів.';

  @override
  String get fullNameHelper => 'Вкажіть ім’я та прізвище в одному полі.';

  @override
  String get fullNameHint => 'Наприклад: Анна Озоліна';

  @override
  String get fullNameLabel => 'Повне ім’я';

  @override
  String get fullNameValidation => 'Введіть ім’я та прізвище (щонайменше по 2 символи в кожному).';

  @override
  String get lastNameHint => 'Ваше прізвище';

  @override
  String get lastNameLabel => 'Ім\'я';

  @override
  String get lastNameLengthValidation => 'Прізвище має містити від 2 до 64 символів.';

  @override
  String get nameHint => 'Ваше ім’я';

  @override
  String get nameLabel => 'Ім\'я';

  @override
  String get nameLengthValidation => 'Ім’я має містити щонайменше 2 символи.';

  @override
  String get navActivities => 'Статистика';

  @override
  String get navAddTrip => 'Додати поїздку';

  @override
  String get navBalances => 'Баланси';

  @override
  String get navExpenses => 'Витрати';

  @override
  String get navFriends => 'Друзі';

  @override
  String get navHome => 'Головна';

  @override
  String get navProfile => 'Профіль';

  @override
  String get navRandom => 'Випадкове';

  @override
  String get netLabel => 'Чистий баланс';

  @override
  String get newPasswordLabel => 'Новий пароль';

  @override
  String get nicknameHint => 'Як вас бачитимуть друзі';

  @override
  String get nicknameLabel => 'Прізвисько';

  @override
  String get nicknameLengthValidation => 'Прізвисько має складатися щонайменше з 2 символів.';

  @override
  String get noAccountQuestion => 'Ще немає облікового запису?';

  @override
  String get noBalancesYet => 'Поки що немає балансів.';

  @override
  String get noChangesToSave => 'Зміни не збережено.';

  @override
  String get noDirectExpenseLink => 'Прямого посилання на окрему витрату не знайдено. Ця сума розраховується на основі загального балансу поїздки.';

  @override
  String get noExpenseImpactForMember => 'Цей учасник не несе жодних витрат.';

  @override
  String noExpensesByUserYet(Object name) {
    return '$name поки що не має витрат.';
  }

  @override
  String get noExpensesYet => 'Витрат поки що немає.';

  @override
  String get noExtraUsersToAdd => 'Не потрібно додавати додаткових користувачів.';

  @override
  String get noInternetDeleteQueued => 'Немає інтернету. Видалити з черги.';

  @override
  String get noInternetExpenseQueued => 'Немає інтернету. Витрати поставлені в чергу.';

  @override
  String get noInternetUpdateQueued => 'Відсутність інтернету. Оновлення в черзі.';

  @override
  String get noMatchingRows => 'Відповідних записів не знайдено.';

  @override
  String get noMembersFound => 'Учасників не знайдено.';

  @override
  String get noNewMembersAdded => 'Ці особи вже є учасниками або мають запрошення, що очікують на підтвердження.';

  @override
  String get noNotePlaceholder => 'Без приміток';

  @override
  String get notificationsToday => 'Сьогодні';

  @override
  String get notificationsEmptyBody => 'Тут з’являтимуться оновлення щодо поїздок, витрат та друзів.';

  @override
  String get notificationsCached => 'Офлайн — відображення збережених сповіщень.';

  @override
  String get notificationsRefreshFailed => 'Не вдалося оновити. Відображаються раніше завантажені сповіщення.';

  @override
  String get notificationsJustNow => 'Саме зараз';

  @override
  String notificationsMinutesAgo(int count) {
    return '$count хв тому';
  }

  @override
  String notificationsHoursAgo(int count) {
    return '$count год тому';
  }

  @override
  String get notificationsUnread => 'Непрочитано';

  @override
  String get noNotificationsYet => 'Поки що повідомлень немає.';

  @override
  String get noParticipantData => 'Дані учасників не збираються.';

  @override
  String get noParticipantsSelected => 'Учасники не обрані.';

  @override
  String get noPaymentRowsInTrip => 'У цій поїздці немає рядків про платежі.';

  @override
  String get noPaymentsNeeded => 'Платежі не потрібні.';

  @override
  String get noPicksYet => 'Поки що немає виборів.';

  @override
  String get noSettlementActivityForMember => 'Для цього учасника немає операцій з розрахунками.';

  @override
  String get noSettlementRowsYet => 'Поки що немає рядків щодо розрахунків.';

  @override
  String get noSettlements => 'Немає розрахунків';

  @override
  String get noTransferNeededForFilter => 'Для обраного фільтра переказ не потрібен.';

  @override
  String get noTransferRowsToShow => 'Немає переказів для відображення.';

  @override
  String get noTripDataLoaded => 'Дані про поїздку не завантажено.';

  @override
  String get noTripsYet => 'Поїздок ще немає.';

  @override
  String get noUsersFoundYet => 'Поки що користувачів не знайдено.';

  @override
  String get notSetValue => 'Не встановлено';

  @override
  String get notYetConfirmedTitle => 'Ще не підтверджено';

  @override
  String get noteHint => 'Вечеря, таксі, квитки...';

  @override
  String get noteLabel => 'Примітка';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Примітка має містити не більше $max символів.';
  }

  @override
  String get notificationFallbackTitle => 'Повідомлення';

  @override
  String get notificationsTitle => 'Повідомлення';

  @override
  String get notificationFriendInviteTitle => 'Запит у друзі';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name надіслав вам запрошення в друзі.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Ви отримали запрошення від друга.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Запрошення прийнято';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name прийняв ваше запрошення у друзі.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Ваше запрошення друга було прийнято.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Запрошення відхилено';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name відхилив ваше запрошення у друзі.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Ваше запрошення друга було відхилено.';

  @override
  String get notificationTripAddedTitle => 'Додано до поїздки';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name додав вас до поїздки «$trip».';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Вас додано до поїздки «$trip».';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Вас додано до поїздки.';

  @override
  String get notificationExpenseAddedTitle => 'Додано новий вид витрат';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name додав витрату на суму $amount у «$trip».';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name додав витрату на суму $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Було додано нову статтю витрат.';

  @override
  String get notificationTripFinishedTitle => 'Подорож завершено';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name завершив(ла) «$trip». Розрахунки готові.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name завершив(ла) «$trip». Подорож архівується.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '«$trip» завершено.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Статус поїздки оновлено.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Учасник позначений як готовий';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name готовий до участі в «$trip».';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Учасник готовий до участі в «$trip».';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Учасник готовий до розрахунку.';

  @override
  String get notificationTripReadyToSettleTitle => 'Усі учасники готові';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Усі учасники, позначені як «готові» у «$trip». Ви можете розпочати розрахунки.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Усі учасники готові. Ви можете розпочати розрахунки.';

  @override
  String get notificationSettlementReminderTitle => 'Нагадування про розрахунок';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor нагадав $target позначити $amount як відправлене.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor нагадав $target підтвердити отримання $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Ви отримали нагадування про розрахунок.';

  @override
  String get notificationPaymentReminderTitle => 'Нагадування про оплату';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Нагадування: будь ласка, позначте $amount як надіслане $target у «$trip».';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Нагадування: будь ласка, позначте платіж як відправлений.';

  @override
  String get notificationConfirmationReminderTitle => 'Нагадування про підтвердження';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Нагадування: будь ласка, підтвердьте отримання $amount від $payer у «$trip».';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Нагадування: будь ласка, підтвердьте отримання платежу.';

  @override
  String get notificationSettlementSentTitle => 'Переказ позначено як надісланий';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name позначив $amount як надісланий вам.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Переказ було позначено як надісланий.';

  @override
  String get notificationSettlementConfirmedTitle => 'Переказ підтверджено';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name підтвердив отримання від вас $amount.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Переказ підтверджено.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count змін в очікуванні',
      many: '$count змін в очікуванні',
      few: '$count зміни в очікуванні',
      one: '$count зміна в очікуванні',
    );
    return 'Черга офлайн: $_temp0';
  }

  @override
  String get syncAllSynced => 'Усе синхронізовано';

  @override
  String syncChangesWaiting(Object count) {
    return '$count очікують на синхронізацію';
  }

  @override
  String get syncFailedTapToRetry => 'Синхронізація не вдалася, натисніть, щоб спробувати ще раз';

  @override
  String get offlineQueueStatus => 'Черга в автономному режимі';

  @override
  String get offlineStatus => 'Офлайн';

  @override
  String get onlineStatus => 'Онлайн';

  @override
  String get onlyCreatorCanFinishTrip => 'Лише організатор поїздки може завершити поїздку.';

  @override
  String get openLabel => 'Відкрити';

  @override
  String get openReceiptAction => 'Відкрити чек';

  @override
  String get openSettlements => 'Відкрити розрахунки';

  @override
  String get overviewTitle => 'Огляд';

  @override
  String get owesLabel => 'Борг';

  @override
  String get paidByLabel => 'Оплачується';

  @override
  String get paidLabel => 'Платний';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Оплачено $paid  -  Заборгував $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Учасники (порожнє поле = усі учасники)';

  @override
  String get participantsTitle => 'Учасники';

  @override
  String get passwordLabel => 'Логін';

  @override
  String get passwordComplexityHelper => 'Використовуйте щонайменше 1 велику літеру, 1 цифру та 1 символ.';

  @override
  String get passwordComplexityValidation => 'Пароль повинен містити 1 велику літеру, 1 цифру та 1 символ.';

  @override
  String get passwordMinLength => 'Пароль повинен містити щонайменше 8 символів.';

  @override
  String get passwordMinLengthShort => 'Пароль повинен складатися щонайменше з 6 символів.';

  @override
  String get passwordResetComingSoon => 'Функція скидання пароля з’явиться найближчим часом.';

  @override
  String get passwordsDoNotMatch => 'Паролі не збігаються.';

  @override
  String payerName(Object name) {
    return '$name (платник)';
  }

  @override
  String get pendingLabel => 'Очікує';

  @override
  String get pendingPaymentsSubtitle => 'Платежі все ще очікують на повне підтвердження.';

  @override
  String get percentLabel => 'Відсоток';

  @override
  String get percentSplitMustBe100 => 'Сума відсотків розподілу повинна дорівнювати точно 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Відсотки';

  @override
  String get pickAtLeastOneParticipant => 'Оберіть принаймні одного учасника.';

  @override
  String get pickMembersGenerateTurn => 'Обери учасників і визнач наступну людину жеребкуванням.';

  @override
  String pickedCycleCompleted(Object name) {
    return 'Вибрано $name. Цикл завершено.';
  }

  @override
  String pickedUser(Object name) {
    return 'Вибрано $name.';
  }

  @override
  String get profileRefreshCachedData => 'Не вдалося оновити профіль. Відображаються дані з кешу.';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get profileUpdated => 'Профіль оновлено.';

  @override
  String get uploadAvatarAction => 'Завантажити аватар';

  @override
  String get takePhotoAction => 'Візьміть картину';

  @override
  String get chooseFromLibraryAction => 'Виберіть із бібліотеки';

  @override
  String get removeAvatarAction => 'Видалити аватар';

  @override
  String get avatarUpdatedMessage => 'Оновлено аватар.';

  @override
  String get avatarRemovedMessage => 'Аватар видалено.';

  @override
  String get avatarFileTooLarge => 'Файл аватара занадто великий (максимум 5 МБ).';

  @override
  String get avatarPickFailed => 'Не вдалося завантажити зображення аватара.';

  @override
  String get queueAddExpense => 'Додати витрати';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'У черзі: додати витрату $amount';
  }

  @override
  String get queueDeleteExpense => 'Видалити витрати';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'У черзі: видалити витрату № $id';
  }

  @override
  String get queuePendingStatus => 'У черзі на розгляд';

  @override
  String get queueUpdateExpense => 'Оновити витрати';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'У черзі: оновлення витрат №$id';
  }

  @override
  String get queuedChange => 'Зміни в черзі';

  @override
  String queuedChangesTitle(Object count) {
    return 'Зміни в черзі ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'У черзі ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Цикл $cycleNo, витяг $drawNo — залишилося $remaining';
  }

  @override
  String get receiptFallbackName => 'чек';

  @override
  String get receiptLinkInvalid => 'Посилання на квитанцію недійсне.';

  @override
  String get receiptOptionalLabel => 'Чек (необов’язково)';

  @override
  String get recentPicksTitle => 'Останні жеребкування';

  @override
  String get reloadProfile => 'Оновити профіль';

  @override
  String get rememberMe => 'Запам’ятати мене';

  @override
  String get removeCurrentReceipt => 'Видалити поточний квитанцію';

  @override
  String get repeatNewPasswordLabel => 'Повторіть новий пароль';

  @override
  String get repeatPasswordLabel => 'Повторіть пароль';

  @override
  String get requestFailedTryAgain => 'Запит не вдався. Спробуйте ще раз.';

  @override
  String get retryAction => 'Спробуйте ще раз';

  @override
  String get rowsLabel => 'Рядки';

  @override
  String get backToLoginAction => 'Повернутися до входу';

  @override
  String get saveAction => 'Зберегти';

  @override
  String get saveCredentialsButton => 'Збереження облікових даних';

  @override
  String get saveProfileButton => 'Зберегти профіль';

  @override
  String get sendResetLinkButton => 'Надіслати посилання для скидання';

  @override
  String get searchUsersHint => 'Пошук людей за іменем або електронною поштою';

  @override
  String get selectedPeopleLabel => 'Вибрані особи';

  @override
  String get noSearchMatches => 'Не знайдено відповідних користувачів.';

  @override
  String get savingButton => 'Зберігання...';

  @override
  String get selectAtLeastTwoMembers => 'Оберіть щонайменше двох учасників.';

  @override
  String get selectMembersHint => 'Вибрати учасників';

  @override
  String selectedFileLabel(Object name) {
    return 'Вибрано: $name';
  }

  @override
  String get selectedLabel => 'Вибрані';

  @override
  String get selectedUserFallback => 'Вибраний користувач';

  @override
  String get settings => 'Налаштування';

  @override
  String get settleUpAction => 'Розрахуватися';

  @override
  String get settledLabel => 'Розраховано';

  @override
  String get settledStatus => 'Розраховано';

  @override
  String get settlementActivitySubtitle => 'Перекази, пов’язані з цим учасником.';

  @override
  String get settlementActivityTitle => 'Розрахункова діяльність';

  @override
  String get settlementCompletedTitle => 'Розрахунок завершено';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total підтверджено';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Розрахунки: $count';
  }

  @override
  String get settlementImpactTitle => 'Вплив на розрахунки';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Вплив на врегулювання: $name';
  }

  @override
  String get settlementInProgress => 'Розрахунок триває';

  @override
  String get settlementInProgressTitle => 'Розрахунок триває';

  @override
  String get settlementLabel => 'Розрахунок';

  @override
  String get settlementOverviewArchivedSubtitle => 'Подорож архівується. Усі розрахунки завершено.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Відстежуйте підтвердження розрахунків.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Перегляд переказів після завершення поїздки.';

  @override
  String get settlementPreview => 'Попередній перегляд розрахунків';

  @override
  String get settlementPreviewTitle => 'Попередній перегляд розрахунків';

  @override
  String get settlementProgressTripArchived => 'Подорож архівується';

  @override
  String settlementWithId(Object id) {
    return 'Розрахунок № $id';
  }

  @override
  String get settlements => 'Розрахунки';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Розрахунки вже завершено.';

  @override
  String get settlementsDone => 'Розрахунки здійснено';

  @override
  String get settlingStatus => 'Розрахунки';

  @override
  String get shareUnit => 'частка';

  @override
  String get sharesLabel => 'Частки';

  @override
  String get sharesMustBePositiveIntegers => 'Кількість часток має бути додатним цілим числом.';

  @override
  String sharesWithValue(Object value) {
    return 'Частки: $value';
  }

  @override
  String get showActiveTrips => 'Показати активні поїздки';

  @override
  String get signUpButton => 'Зареєструватися';

  @override
  String get splitBreakdownSubtitle => 'Як розподіляються витрати';

  @override
  String get splitBreakdownTitle => 'Розбивка витрат';

  @override
  String get splitHintEqual => 'Розподіліть суму рівномірно між обраними учасниками.';

  @override
  String get splitHintExact => 'Введіть точну суму для кожного учасника. Сума повинна збігатися із загальною сумою.';

  @override
  String get splitHintPercent => 'Введіть відсоток для кожного учасника. Сума повинна становити 100%.';

  @override
  String get splitHintShares => 'Введіть кількість учасників, з якими ділитеся (1, 2, 3...). Вартість розподіляється пропорційно.';

  @override
  String get splitLabel => 'Розсилка';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Рівний розподіл ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Точні суми ($target)';
  }

  @override
  String get splitModeLabel => 'Режим «Split»';

  @override
  String splitModePercent(Object target) {
    return 'Відсотки ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Частки ($target)';
  }

  @override
  String get statusConfirmed => 'Підтверджено';

  @override
  String get statusPending => 'Очікує';

  @override
  String get statusSent => 'Сент';

  @override
  String get statusSuggested => 'Смоктати';

  @override
  String statusWithValue(Object status) {
    return 'Статус: $status';
  }

  @override
  String get suggestedTransferDirections => 'Запропоновані напрямки платежів';

  @override
  String get suggestedTransferFromExpense => 'Пропонований переказ з рахунку витрат';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запропонованих переказів',
      many: '$count запропонованих переказів',
      few: '$count запропоновані перекази',
      one: '$count запропонований переказ',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Очікувані рядки «платник» — «одержувач».';

  @override
  String get suggestedTransfersTitle => 'Рекомендовані перекази';

  @override
  String get summarySettledUp => 'Розраховано';

  @override
  String get summaryYouAreOwed => 'Тобі винні';

  @override
  String get summaryYouOwe => 'Твій борг';

  @override
  String get syncAction => 'Синхронізація';

  @override
  String get syncNowAction => 'Синхронізувати зараз';

  @override
  String get syncingStatus => 'Синхронізація';

  @override
  String get tapToViewDetails => 'Натисніть, щоб переглянути деталі';

  @override
  String get themeModeDark => 'Темна';

  @override
  String get themeModeDarkSubtitle => 'М’який темний (не чистий чорний)';

  @override
  String get themeModeLight => 'Світла';

  @override
  String get themeModeSystem => 'Системна';

  @override
  String get themeModeSystemSubtitle => 'Використовуйте зовнішній вигляд пристрою';

  @override
  String toDirection(Object name) {
    return 'До $name';
  }

  @override
  String get totalLabel => 'Разом';

  @override
  String get travelerFallbackName => 'Мандрівник';

  @override
  String get tripAlreadyClosed => 'Подорож уже завершена.';

  @override
  String get tripArchivedReadOnly => 'Подорож архівується. Режим «тільки для читання».';

  @override
  String get tripClosedExpenseEditingDisabled => 'Подорож завершена. Редагування витрат вимкнено.';

  @override
  String get tripClosedExpensesReadOnly => 'Подорож завершена. Витрати доступні лише для перегляду.';

  @override
  String get tripClosedRandomDisabled => 'Подорож завершена. Випадковий розіграш вимкнено.';

  @override
  String tripCreated(Object name) {
    return 'Подорож «$name» створено.';
  }

  @override
  String get tripFinished => 'Подорож завершено.';

  @override
  String get tripFinishedCompleteSettlements => 'Подорож завершена. Здійсніть розрахунки.';

  @override
  String get tripFinishedSettlementStarted => 'Подорож завершено. Розрахунок розпочато.';

  @override
  String get tripFullySettledArchived => 'Подорож повністю оплачена та архівується.';

  @override
  String get tripNameHint => 'Лижна поїздка до Австрії';

  @override
  String get tripNameLabel => 'Назва поїздки';

  @override
  String get tripNameLengthValidation => 'Назва поїздки повинна містити щонайменше 2 символи.';

  @override
  String get tripSnapshotTitle => 'Знімок поїздки';

  @override
  String get tripTitleShort => 'Подорож';

  @override
  String tripStatusWithValue(Object status) {
    return 'Статус поїздки: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Подорож № $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Сталася несподівана помилка під час завантаження профілю';

  @override
  String get unexpectedErrorLoadingTripData => 'Сталася несподівана помилка під час завантаження даних про поїздку';

  @override
  String get unexpectedErrorLoadingTrips => 'Несподівана помилка під час завантаження поїздок';

  @override
  String get unexpectedErrorSavingChanges => 'Несподівана помилка під час збереження змін';

  @override
  String get unexpectedErrorSavingCredentials => 'Несподівана помилка під час збереження облікових даних';

  @override
  String get unexpectedErrorUpdatingProfile => 'Несподівана помилка під час оновлення профілю';

  @override
  String get unknownError => 'Невідома помилка';

  @override
  String get unknownLabel => 'Невідомо';

  @override
  String get unreadLabel => 'Непрочитано';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитаних оновлень',
      many: '$count непрочитаних оновлень',
      few: '$count непрочитані оновлення',
      one: '$count непрочитане оновлення',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Відсутній аргумент маршруту поїздки.';

  @override
  String userIdLabel(Object id) {
    return 'Ідентифікатор користувача: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Оплачено $paid  -  Заборгувано $owes  -  Чисто $net';
  }

  @override
  String userWithId(Object id) {
    return 'Користувач $id';
  }

  @override
  String get valueLabel => 'Цінність';

  @override
  String get viewAllTrips => 'Переглянути всі поїздки';

  @override
  String get viewByPersonTitle => 'Перегляд за особою';

  @override
  String get whoOwesWhatSubtitle => 'Хто заплатив, а хто винен.';

  @override
  String get whoOwesWhatTitle => 'Хто кому що винен';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Хто кому винен: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Рядки витрат, що стосуються цього переказу.';

  @override
  String get whyPaymentExistsTitle => 'Навіщо існує цей платіж';

  @override
  String get youLabel => 'Ви';

  @override
  String get youSettledForExpense => 'Ти вже розрахувався за свою частку цієї витрати.';

  @override
  String youShouldPay(Object amount) {
    return 'Ви повинні платити $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Ви повинні отримувати $amount';
  }

  @override
  String get yourShare => 'Ваше повідомлення';

  @override
  String get yourTrips => 'Ваші поїздки';

  @override
  String get authIntroSplitSmarter => 'Розподіляйте витрати розумніше.';

  @override
  String get authIntroTravelFree => 'Подорожуйте вільно.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Відстежуйте спільні витрати в різних валютах і миттєво розраховуйтеся — без незручних боргових розписок.';

  @override
  String get authIntroPlanTogether => 'Плануйте разом.';

  @override
  String get authIntroPayClearly => 'Платіть чітко.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Створюйте поїздки за лічені секунди, додавайте друзів і забезпечуйте прозорість усіх витрат для всіх учасників.';

  @override
  String get authIntroSettleFast => 'Дійте швидко.';

  @override
  String get authIntroStayFriends => 'Залишаймося друзями.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Від спільних вечерь до повноцінних подорожей — Splyto забезпечує справедливий розподіл витрат і позбавляє вас стресу.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Не вдалося увійти через Apple. Спробуйте ще раз.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Не вдалося увійти через Google. Спробуйте ще раз.';

  @override
  String get authIntroCreateAccount => 'Створіть свій обліковий запис.';

  @override
  String get authIntroChooseSign => 'Оберіть спосіб реєстрації.';

  @override
  String get authIntroContinueGoogle => 'Продовжити з Google';

  @override
  String get authIntroContinueApple => 'Продовжити з Apple';

  @override
  String get authIntroBack => 'Назад';

  @override
  String get authIntroSplitSettled => 'Розподіл оплати';

  @override
  String get authIntroParis3Friends => 'Париж · 3 друзі';

  @override
  String get authIntroGetStarted => 'Почніть роботу';

  @override
  String get authIntroAlreadyHaveAccount => 'У вас уже є обліковий запис? ';

  @override
  String get authIntroSignIn => 'Увійти';

  @override
  String get authIntroSignUpWithEmail => 'Зареєструйтеся за допомогою електронної пошти';

  @override
  String get authIntroOr => 'АБО';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Вхід через Google не повернув ідентифікаційний токен.';

  @override
  String get authAppleSignAvailableIosDevices => 'На пристроях iOS доступний вхід через Apple.';

  @override
  String get authAppleSignNotAvailableDevice => 'Вхід через Apple на цьому пристрої недоступний.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Система входу Apple не повернула токен ідентифікації.';

  @override
  String get authCancel => 'Скасувати';

  @override
  String get authSendLink => 'Надіслати посилання';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'Електронна адреса не підтверджена. Введіть свою електронну адресу, щоб отримати посилання для підтвердження.';

  @override
  String get authEmailNotVerified => 'Електронна адреса не підтверджена';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Надіслати посилання для підтвердження на $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Надіслано посилання для підтвердження. Перевірте свою електронну пошту.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Не вдалося надіслати посилання для підтвердження. Спробуйте ще раз.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Надіслано електронний лист для підтвердження. Будь ласка, підтвердьте свою електронну адресу перед входом у систему.';

  @override
  String get authVerifyEmail => 'Підтвердьте свою електронну адресу';

  @override
  String get authEmailLabel => 'Електронна пошта:';

  @override
  String get authClose => 'Закрити';

  @override
  String get authResendLink => 'Надіслати посилання ще раз';

  @override
  String get profileAppSettingsSectionTitle => 'НАЛАШТУВАННЯ ДОДАТКА';

  @override
  String get profileAccountSettings => 'Налаштування облікового запису';

  @override
  String get profileChangePhoto => 'Змінити фото профілю';

  @override
  String get profileAppearance => 'Зовнішній вигляд';

  @override
  String get profileThemeDisplayMode => 'Тема та режим відображення';

  @override
  String get profileLanguage => 'Мова';

  @override
  String get profileDisplayLanguage => 'Мова інтерфейсу';

  @override
  String get profileNotificationsSectionHeading => 'ПОВІДОМЛЕННЯ';

  @override
  String get profileAppBanners => 'Банери в додатку';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Показувати нові банери сповіщень усередині додатка';

  @override
  String get profilePushNotificationsTitle => 'Push-повідомлення';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Телефонні сповіщення про витрати, друзів, поїздки та розрахунки';

  @override
  String get profileSupportSectionHeading => 'ПІДТРИМКА';

  @override
  String get profileContactUs => 'Зв’яжіться з нами';

  @override
  String get profileReportBugSuggestion => 'Повідомити про помилку / Надіслати пропозицію';

  @override
  String get profileRateSplyto => 'Оцініть Splyto';

  @override
  String get profileLeaveStoreRating => 'Залиште оцінку магазину';

  @override
  String get profileSecuritySectionHeading => 'БЕЗПЕКА';

  @override
  String get profileChangePassword => 'Змінити пароль';

  @override
  String get profileUpdateAccountPassword => 'Оновити пароль облікового запису';

  @override
  String get profileDangerZoneSectionHeading => 'ЗОНА НЕБЕЗПЕКИ';

  @override
  String get profileManageAccountAccess => 'Управління доступом до облікового запису';

  @override
  String get profileMadeWithLabel => 'Створено за допомогою';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Функція оцінки поїздки буде підключена на наступному етапі.';

  @override
  String get profileFailedSaveNotificationSettings => 'Не вдалося зберегти налаштування сповіщень.';

  @override
  String get profilePushNotificationsSectionTitle => 'ПОВІДОМЛЕННЯ PUSH';

  @override
  String get profileInAppBannersSectionTitle => 'БАНЕРИ В ДОДАТКУ';

  @override
  String get profileInAppTripMemberAddedTitle => 'Учасник доданий до поїздки';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Автоматичне нагадування про розрахунок';

  @override
  String get profileExpenseUpdates => 'Оновлення інформації про витрати';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Додано банери про витрати всередині додатка';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Повідомлення про додані витрати на телефон';

  @override
  String get profileFriendInvites => 'Запрошення від друзів';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Банери запитів на додавання в друзі та відповідей на них у додатку';

  @override
  String get profileFriendRequestResponseNotifications => 'Сповіщення про запити на додавання в друзі та відповіді на них';

  @override
  String get profileTripUpdates => 'Оновлення про поїздку';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Банери про життєвий цикл поїздки та статус учасників у додатку';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Життєвий цикл поїздки та зміни статусу учасників';

  @override
  String get profileSettlementUpdates => 'Оновлення щодо розрахунків';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Позначені банери про відправлення та підтвердження платежу всередині додатка';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Позначені як надіслані та підтверджені оновлення про платежі';

  @override
  String get profileScreenshotSizeMust8Mb => 'Розмір скріншоту не повинен перевищувати 8 МБ';

  @override
  String get profileFeedbackSendTitle => 'Надіслати відгук';

  @override
  String get profileFeedbackTypeLabel => 'Тип';

  @override
  String get profileFeedbackTypeBug => 'Помилка';

  @override
  String get profileFeedbackTypeSuggestion => 'Рекомендація';

  @override
  String get profileDescribeIssueSuggestion => 'Опишіть проблему або пропозицію';

  @override
  String get profilePickingImage => 'Вибір зображення...';

  @override
  String get profileAttachScreenshot => 'Додайте скріншот';

  @override
  String get profileChangeScreenshot => 'Змінити знімок екрана';

  @override
  String get profileRemoveImage => 'Видалити зображення';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Порада: додайте скріншот для швидшого аналізу помилок';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Перед надсиланням додайте деталі або вкладіть скріншот';

  @override
  String get profileSendAction => 'Надіслати';

  @override
  String get profileThanksFeedbackSent => 'Дякуємо! Відгук надіслано';

  @override
  String get profileFailedSendFeedback => 'Не вдалося надіслати відгук';

  @override
  String get profileCouldNotOpenWebsite => 'Не вдалося відкрити веб-сайт.';

  @override
  String get profileOpenWebsiteQuestion => 'Відкрити веб-сайт?';

  @override
  String get profileOpenPortfolioAction => 'Відкрийте portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Цей формат зображення не підтримується на цьому пристрої. Будь ласка, виберіть JPG або PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Для зміни пароля необхідна дійсна електронна адреса облікового запису. Зверніться до служби підтримки, якщо ваша електронна адреса відсутня або вказана неправильно.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Посилання на видалення надіслано на вашу електронну пошту.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Не вдалося надіслати посилання на видалення. Спробуйте ще раз.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Введіть поточний пароль, щоб змінити електронну адресу.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Підтвердження було надіслано на нову електронну адресу. Повідомлення про безпеку було надіслано на вашу поточну електронну адресу.';

  @override
  String get profileEditOverviewCurrency => 'Огляд валюти';

  @override
  String get profileEditPaymentMethod => 'Спосіб оплати';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Банківський переказ, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Введіть свій пароль (не обов’язково для Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Надіслати посилання на видалення на електронну пошту';

  @override
  String get profileEditBackProfile => 'Назад до профілю';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Перед зміною пароля вкажіть у профілі дійсну адресу електронної пошти.';

  @override
  String get profileEditPasswordUpdated => 'Оновлено пароль.';

  @override
  String get profileEditFailedUpdatePassword => 'Не вдалося оновити пароль.';

  @override
  String profileEditEmail(Object email) {
    return 'Обліковий запис: $email';
  }

  @override
  String get profileEditPrimary => 'Основне';

  @override
  String get profileEditSearchCurrency => 'Пошук валюти';

  @override
  String get profileEditNoCurrenciesFound => 'Валюти не знайдено';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Загальні суми в огляді перераховуються у цю валюту.';

  @override
  String get profileEditPaymentInfoUpdated => 'Інформація про платежі оновлена.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Не вдалося зберегти платіжну інформацію. Спробуйте ще раз.';

  @override
  String get profileEditCurrentPassword => 'Поточний пароль';

  @override
  String get profileEditBankTransferIbanSwift => 'Банківський переказ (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'посилання paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Оберіть спосіб оплати';

  @override
  String get profileEditTapChange => 'Натисніть, щоб змінити';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Для переказів у Великобританії код банку повинен складатися з 6 цифр, а номер рахунку — з 8 цифр.';

  @override
  String get profileEditPaymentInfo => 'Інформація про оплату';

  @override
  String get profileEditSaveDetails => 'Зберегти деталі';

  @override
  String get profileEditBankRegion => 'Банківський регіон';

  @override
  String get profileEditEurope => 'Європа';

  @override
  String get profileEditSortCode => 'Код банку';

  @override
  String get profileEditExample112233 => 'Приклад: 112233';

  @override
  String get profileEditNumber => 'Номер рахунку';

  @override
  String get profileEdit8Digits => '8 цифр';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Для внутрішніх переказів у Великій Британії використовуйте сорт-код + номер рахунку.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Приклад: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 або 11 символів';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Ім’я власника рахунку береться з повного імені в профілі.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username або ім’я користувача';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Велика Британія';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Налаштуйте аватар';

  @override
  String get imageCropperAdjustTripImage => 'Налаштуйте зображення поїздки';

  @override
  String get copyAction => 'Зареєструватися';

  @override
  String get currencyNameEur => 'Євро';

  @override
  String get currencyNameGbp => 'Британський фунт';

  @override
  String get currencyNameChf => 'Швейцарський франк';

  @override
  String get currencyNameNok => 'Норвезька крона';

  @override
  String get currencyNameSek => 'Шведська крона';

  @override
  String get currencyNameDkk => 'Данська крона';

  @override
  String get currencyNamePln => 'Польський злотий';

  @override
  String get currencyNameCzk => 'Чеська крона';

  @override
  String get currencyNameHuf => 'Угорський форинт';

  @override
  String get currencyNameRon => 'Румунський лей';

  @override
  String get currencyNameBgn => 'Болгарський лев';

  @override
  String get currencyNameIsk => 'Ісландська крона';

  @override
  String get currencyNameAll => 'Албанський лек';

  @override
  String get currencyNameBam => 'Боснія і Герцеговина Марк';

  @override
  String get currencyNameByn => 'Білоруський рубль';

  @override
  String get currencyNameMdl => 'Молдовський лей';

  @override
  String get currencyNameMkd => 'Македонський денар';

  @override
  String get currencyNameRsd => 'Сербський динар';

  @override
  String get currencyNameUah => 'Українська гривня';

  @override
  String get currencyNameGel => 'Грузинський ларі';

  @override
  String get currencyNameTry => 'Турецька ліра';

  @override
  String get currencyNameUsd => 'Долар США';

  @override
  String get currencyNameJpy => 'Японська ієна';

  @override
  String get currencyNameCny => 'Китайський юань';

  @override
  String get currencyNameCad => 'Канадський долар';

  @override
  String get currencyNameAud => 'Австралійський долар';

  @override
  String get expenseCategoryFood => 'Харчування';

  @override
  String get expenseCategoryGroceries => 'Продукти';

  @override
  String get expenseCategoryFuel => 'Пальне';

  @override
  String get expenseCategoryTransport => 'Транспорт';

  @override
  String get expenseCategoryAccommodation => 'Проживання';

  @override
  String get expenseCategoryActivities => 'Дозвілля';

  @override
  String get expenseCategoryTickets => 'Квитки';

  @override
  String get expenseCategoryShopping => 'Покупки';

  @override
  String get expenseCategoryParty => 'Вечірки';

  @override
  String get expenseCategoryParking => 'Паркування';

  @override
  String get expenseCategoryOther => 'Інше';

  @override
  String get shellTripAlreadyInListOpened => 'Подорож уже є у вашому списку. Ми відкрили її для вас.';

  @override
  String get shellJoinedTripFromInviteLink => 'Приєднався до поїздки за посиланням із запрошенням.';

  @override
  String get shellFailedToOpenInviteLink => 'Не вдалося відкрити посилання на запрошення.';

  @override
  String get shellFailedToOpenFriendLink => 'Не вдалося відкрити посилання друга.';

  @override
  String get shellTripInviteTitle => 'Запрошення на поїздку';

  @override
  String get shellNoAction => 'Ні';

  @override
  String get shellYesAction => 'Так';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Видалити цю подорож може лише її організатор.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Видалити можна лише активні поїздки.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Видалити «$tripLabel»? Це дозволено лише до додавання будь-яких витрат.';
  }

  @override
  String get shellTripDeleted => 'Подорож видалено.';

  @override
  String get shellFailedToDeleteTrip => 'Не вдалося видалити поїздку.';

  @override
  String get shellFailedToLoadNotifications => 'Не вдалося завантажити сповіщення.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Нове повідомлення: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Не вдалося оновити сповіщення.';

  @override
  String get shellMarkAllAsReadAction => 'Позначити все як прочитане';

  @override
  String get shellNewSection => 'Нове';

  @override
  String get shellEarlierSection => 'Раніше';

  @override
  String get shellShowMoreEarlierAction => 'Показати більше попередніх';

  @override
  String get shellLoadingMore => 'Завантажується ще...';

  @override
  String get shellLoadMoreNotificationsAction => 'Завантажити більше сповіщень';

  @override
  String get shellTripNoLongerAvailable => 'Ця поїздка більше не доступна.';

  @override
  String get shellFailedToOpenTrip => 'Не вдалося відкрити поїздку.';

  @override
  String get shellYesterday => 'Вчора';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Ви вже є учасником поїздки «$tripName». Відкрити цю поїздку зараз?\n\nЗапросив: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Чи хочете ви приєднатися до поїздки «$tripName»?\n\nЗапросив: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Вибране зображення: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Зображення поїздки вже встановлено.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Подорож створено, але завантаження зображення не вдалося.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Подорож створено, але завантаження зображення не вдалося: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Приєднатися до поїздки за запрошенням';

  @override
  String get tripsTotalTrips => 'Загальна кількість поїздок';

  @override
  String get tripsTotalSpent => 'Загальна сума витрат';

  @override
  String get tripsMixedCurrencies => 'Змішані валюти';

  @override
  String get tripsShowActive => 'Показати активні';

  @override
  String get tripsSeeAll => 'Переглянути все';

  @override
  String get tripsGridView => 'Вигляд у вигляді сітки';

  @override
  String get tripsListView => 'Перегляд у вигляді списку';

  @override
  String get tripsAddNewTrip => 'Додати нову поїздку';

  @override
  String get tripsLoadMore => 'Завантажити більше';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Видалити «$arg1»? Це дозволено лише до додавання будь-яких витрат.';
  }

  @override
  String get tripsTripDates => 'Дати поїздки';

  @override
  String get tripsFrom => 'Від';

  @override
  String get tripsSelectDate => 'Виберіть дату';

  @override
  String get tripsTo => 'До';

  @override
  String get tripsMainCurrency => 'Основна валюта';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Будь ласка, виберіть період поїздки (дати початку та закінчення).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Дата закінчення поїздки має бути не раніше дати початку.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Формат періоду поїздки є недійсним. Будь ласка, виберіть дати ще раз.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Ви вже є учасником цієї подорожі.';

  @override
  String get tripsJoinedTripSuccessfully => 'Ви успішно приєдналися до поїздки.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Не вдалося приєднатися до поїздки за запрошенням.';

  @override
  String get tripsJoinTrip => 'Приєднатися до поїздки';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Вставте посилання на запрошення або токен запрошення.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Введіть дійсне посилання на запрошення або токен.';

  @override
  String get tripsClipboardIsEmpty => 'Буфер обміну порожній.';

  @override
  String get tripsPaste => 'Вставити';

  @override
  String get tripsJoin => 'Приєднатися';

  @override
  String get workspaceTripMembers => 'Учасники поїздки';

  @override
  String get workspaceFailedToLoadFriends => 'Не вдалося завантажити друзів.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Не вдалося створити посилання на запрошення.';

  @override
  String get workspaceInviteLink => 'Посилання для запрошення';

  @override
  String get workspaceGeneratingInviteLink => 'Створюється посилання для запрошення...';

  @override
  String get workspaceInviteLinkUnavailable => 'Посилання для запрошення недоступне.';

  @override
  String get workspaceCopyInviteLink => 'Скопіювати посилання на запрошення';

  @override
  String get workspaceInviteLinkCopied => 'Посилання на запрошення скопійовано.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Термін дії: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Друзів немає. Спочатку додайте друзів.';

  @override
  String get workspaceSettle => 'Підсумок';

  @override
  String get workspaceOwesToTheGroup => 'Заборгованість перед групою';

  @override
  String get workspaceGetsBackFromGroup => 'Має отримати гроші від групи';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Показ 4 найкращих за різницею в балансі.';

  @override
  String get workspaceOpenFlow => 'Деталі';

  @override
  String get workspaceFriend => 'Друг';

  @override
  String get workspaceSettlementTransfer => 'Переказ коштів';

  @override
  String get workspaceCompleted => 'Завершено';

  @override
  String get workspaceWaitingForConfirmation => 'Очікування підтвердження';

  @override
  String get workspaceWaitingForPayment => 'Очікування платежу';

  @override
  String get workspaceActionNeeded => 'Необхідні дії';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Платежі, які потрібно позначити як надіслані: $arg1; підтвердити як отримані: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Готові до розрахунку';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Усі учасники готові. Ви можете розпочати розрахунки.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Очікування, поки всі позначать себе як готові.';

  @override
  String get workspaceIMReady => 'Я готовий';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Переконайтеся, що ви додали всі свої витрати.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Кнопка «Завершити» стає активною, коли всі позначать, що готові.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Має отримати гроші від групи';

  @override
  String get workspaceSettledWithTheGroup => 'Узгоджено з групою';

  @override
  String get workspaceTotalPaid => 'Загальна сума оплати';

  @override
  String get workspaceTotalOwes => 'Загальна сума заборгованості';

  @override
  String get workspaceTransactionHistory => 'Історія транзакцій';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Для цього учасника ще немає транзакцій.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Розрахунки: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Усі учасники повинні позначити себе як «готові» перед початком розрахунків.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Ви позначили себе як готового до розрахунку.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Позначку готовності до розрахунків знято.';

  @override
  String get workspaceReminderSent => 'Надіслано нагадування.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Посилання на запрошення або додавання з друзів';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Редагувати цю поїздку може лише її організатор.';

  @override
  String get workspaceTripUpdated => 'Подорож оновлено.';

  @override
  String get workspaceFailedToUpdateTrip => 'Не вдалося оновити поїздку.';

  @override
  String get workspaceNoMembersSelectedYet => 'Учасники ще не обрані.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Відсутність інтернету. Витрати будуть збережені без зображення квитанції.';

  @override
  String get workspaceRandomPicker => 'Випадковий вибір';

  @override
  String get workspaceCurrency => 'Валюта';

  @override
  String get workspaceCategory => 'Категорія';

  @override
  String get workspaceCustomCategory => 'Категорія «Налаштування»';

  @override
  String get workspaceCategoryName => 'Назва категорії';

  @override
  String get workspaceApartmentRentParkingEtc => 'Оренда квартири, паркування тощо.';

  @override
  String get workspaceEnterACustomCategory => 'Введіть власну категорію.';

  @override
  String get workspacePickAnExpenseCategory => 'Оберіть категорію витрат.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Категорія повинна містити щонайменше 2 символи.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Категорія повинна містити не більше 64 символів.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Сума відсоткових часток повинна становити 100%.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Кількість часток має бути більшою за 0 для кожного учасника.';

  @override
  String get workspaceTotalAmount => 'Загальна сума';

  @override
  String get workspaceOriginal => 'Оригінал';

  @override
  String get workspaceTotalCost => 'Загальна вартість';

  @override
  String workspaceStarted(Object arg1) {
    return 'Запущено $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Завершено $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Архів поїздки';

  @override
  String get workspaceActiveTrip => 'Активна подорож';

  @override
  String get workspaceMemberProfile => 'Профіль учасника';

  @override
  String get workspaceTripOwner => 'Організатор поїздки';

  @override
  String get workspaceMember => 'Учасник';

  @override
  String get workspaceReadyForSettlement => 'Готові до розрахунку';

  @override
  String get workspaceNotReadyForSettlement => 'Не готові до розрахунку';

  @override
  String get workspaceBankDetails => 'Банківські реквізити';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'Реквізити IBAN та реквізити для виплат будуть додані сюди в наступному оновленні.';

  @override
  String get workspacePaymentDetails => 'Реквізити платежу';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Цей учасник ще не додав реквізити для виплати.';

  @override
  String get workspaceBankTransfer => 'Банківський переказ';

  @override
  String get workspaceHolder => 'Власник';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Не вдалося відкрити посилання на оплату.';

  @override
  String get workspaceTripActivity => 'Активність у поїздці';

  @override
  String get workspacePaidExpenses => 'Оплачені витрати';

  @override
  String get workspacePaidTotal => 'Загальна сума до сплати';

  @override
  String get workspaceInvolvedIn => 'Залучені до';

  @override
  String get workspaceCurrentTrip => 'Поточна подорож';

  @override
  String get workspaceCommonTrips => 'Спільні подорожі';

  @override
  String get workspaceLoadingCommonTrips => 'Завантаження спільних подорожей…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Спільних подорожей поки не знайдено.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Не вдалося завантажити всі спільні подорожі. Показано поточну подорож.';

  @override
  String get workspaceMembers => 'учасники';

  @override
  String get workspaceExpense => 'Витрати';

  @override
  String get workspacePaid => 'оплачено';

  @override
  String get workspaceLoadingMoreExpenses => 'Завантажуються інші витрати...';

  @override
  String get workspaceScrollDownToLoadMore => 'Прокрутіть вниз, щоб завантажити більше';

  @override
  String get workspaceTripFinished => 'Подорож завершено';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Розрахунки для цієї поїздки розблоковано.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Завершіть поїздку, щоб розпочати розрахунки.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 позначив переказ як надісланий.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Очікуємо, поки $arg1 позначить платіж як оплачений.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 підтвердив отримання платежу.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Очікуємо на підтвердження від $arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Усі розрахунки за поїздку повністю завершені.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Кінцевий стан після підтвердження всіх переказів.';

  @override
  String get workspaceSettlementFlow => 'Процес розрахунків';

  @override
  String get workspaceActions => 'Дії';

  @override
  String get workspaceQuickPay => 'Швидка оплата';

  @override
  String get workspacePayWithRevolut => 'Оплата через Revolut';

  @override
  String get workspacePayWithPaypal => 'Оплата через PayPal';

  @override
  String get workspacePayWithWise => 'Оплата через Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Переказ підтверджено.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Очікування, поки інший учасник виконає наступний крок.';

  @override
  String get workspaceSendReminder => 'Надіслати нагадування';

  @override
  String get workspaceInProgress => 'У процесі';

  @override
  String get workspaceTimeUnknown => 'Час невідомий';

  @override
  String get workspaceRemind => 'Нагадування';

  @override
  String get workspaceYourPosition => 'Ваша позиція';

  @override
  String get workspaceRecentActivity => 'Останні дії';

  @override
  String get workspaceNoRecentActivityYet => 'Поки що немає останніх дій.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Додайте хоча б одного учасника, щоб почати розподіл витрат.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Позначте себе як готового до розрахунку після додавання всіх своїх витрат.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Учасники, які ще не позначили готовність: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Усі учасники готові. Ви можете завершити поїздку та розпочати розрахунки.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Усі учасники готові. Чекаємо, поки організатор поїздки розпочне розрахунки.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Розрахунок триває: $arg1/$arg2 підтверджено.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Дій, що очікують на виконання, немає. Ця поїздка завершена.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Наразі ніяких дій не потрібно.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Ви повинні отримати $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Ви повинні сплатити $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Наразі ви зареєстровані в цій поїздці.';

  @override
  String get workspaceUnknownTime => 'Невідомий час';

  @override
  String get workspaceJustNow => 'Саме зараз';

  @override
  String workspaceMinAgo(Object arg1) {
    return '$arg1 хв тому';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return '$arg1 год тому';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return '$arg1 дн. тому';
  }

  @override
  String get friendsRemoveFriend => 'Видалити друга';

  @override
  String get friendsRemoveThisFriend => 'Видалити цього друга?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 буде видалено зі списку ваших друзів. Ви зможете додати цю особу знову пізніше.';
  }

  @override
  String get friendsContinue => 'Продовжити';

  @override
  String get friendsFriendRemoved => 'Друг видалено.';

  @override
  String get friendsCouldNotRemoveFriend => 'Не вдалося видалити друга.';

  @override
  String get friendsFriendProfile => 'Профіль друга';

  @override
  String get friendsMoreActions => 'Більше дій';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Цей друг ще не додав реквізити для виплати.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Наразі не вдалося завантажити спільні подорожі.';

  @override
  String get friendsFinished => 'Завершено';

  @override
  String friendsTrip(Object arg1) {
    return 'Подорож № $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Учасники: $arg1';
  }

  @override
  String get friendsNoDate => 'Без дати';

  @override
  String get friendsIncomingRequests => 'ВХІДНІ ЗАПИТИ';

  @override
  String get friendsSentInvites => 'НАДІСЛАНІ ЗАПРОШЕННЯ';

  @override
  String get friendsMyFriends => 'МОЇ ДРУЗІ';

  @override
  String get friendsRequests => 'Запити';

  @override
  String get friendsIncoming => 'Вхідні повідомлення';

  @override
  String get friendsIncomingRequestSubtitle => 'хоче подружитися';

  @override
  String get friendsOutgoingInviteSubtitle => 'Запрошення надіслано';

  @override
  String get friendsNoPendingActivity => 'Жодних запитів на додавання в друзі';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Запрошення надіслано $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Відсутність вхідних запитів';

  @override
  String get friendsDecline => 'Відхилити';

  @override
  String get friendsAccept => 'Прийняти';

  @override
  String get friendsNoSentInvites => 'Не надсилайте запрошення';

  @override
  String get friendsNoFriendsYet => 'Поки що немає друзів';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Прокрутіть вниз, щоб завантажити більше друзів.';

  @override
  String get friendsUser => 'Користувач';

  @override
  String get friendsSearchUsers => 'Пошук користувачів';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Знайдіть за іменем або електронною адресою та надішліть запрошення';

  @override
  String get friendsScanQr => 'Відскануйте QR-код';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Відскануйте іншого користувача, щоб додати його в друзі';

  @override
  String get friendsMyQr => 'Мій QR-код';

  @override
  String get friendsShowOrShareYourQrCode => 'Покажіть або поділіться своїм QR-кодом';

  @override
  String get friendsScanFriendQrTitle => 'Відскануйте QR-код друга';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Розмістіть QR-код друга всередині рамки';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Тримайте QR-код у кадрі';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Додати $arg1 у друзі?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 отримає ваш запит на додавання в друзі.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Прийняти запит на дружбу від $arg1?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Відскануйте цей QR-код або поділіться посиланням, щоб додати мене в Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Додайте мене в Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Посилання на друга у Splyto';

  @override
  String get shareAction => 'Поділитися';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'QR-код не є дійсним кодом друга.';

  @override
  String get friendsYouCannotAddYourself => 'Ви не можете додати себе.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Цей користувач уже є у вашому списку друзів.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Запрошення цьому користувачеві вже надіслано.';

  @override
  String get friendsFriendRequestProcessed => 'Запит на додавання в друзі оброблено.';

  @override
  String get friendsFailedToProcessFriendQr => 'Не вдалося обробити QR-код друга.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Не вдалося завантажити ваш профіль користувача.';

  @override
  String get friendsMyProfile => 'Мій профіль';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Сталася несподівана помилка під час завантаження друзів.';

  @override
  String get friendsFriendAdded => 'Друг додано.';

  @override
  String get friendsRequestDeclined => 'Запит відхилено.';

  @override
  String get friendsFailedToUpdateRequest => 'Не вдалося оновити запит.';

  @override
  String get friendsCancelInvite => 'Скасувати запрошення';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Скасувати запрошення для $arg1?';
  }

  @override
  String get friendsKeep => 'Залишити';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Запрошення до $arg1 скасовано.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Не вдалося скасувати запрошення.';

  @override
  String get analyticsOther => 'Інше';

  @override
  String get analyticsSelectATripForAnalytics => 'Виберіть поїздку для аналітики';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Учасники: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Щоденні витрати';

  @override
  String get analyticsMyDaily => 'Мої щоденні витрати';

  @override
  String get analyticsGroupDaily => 'Щоденні витрати групи';

  @override
  String get analyticsByMember => 'За учасником';

  @override
  String get analyticsShowLess => 'Показати менше';

  @override
  String get analyticsByCategory => 'За категоріями';

  @override
  String get analyticsQuickInsights => 'Короткі висновки';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Найбільші витрати: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Найбільший витратник: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Найкращий день групи: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Без дат';

  @override
  String get friendsSearchFailedTryAgain => 'Пошук не вдався. Спробуйте ще раз.';

  @override
  String get friendsFailedToSendInvite => 'Не вдалося надіслати запрошення.';

  @override
  String get friendsAddFriend => 'Додати в друзі';

  @override
  String get friendsSearchByNameOrEmail => 'Пошук за іменем або електронною адресою';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Для пошуку введіть щонайменше 2 символи.';

  @override
  String get friendsNoUsersFound => 'Користувачів не знайдено';

  @override
  String get friendsInviteAction => 'Запросити';

  @override
  String get workspacePaidForGroup => 'Оплачено за групу';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Оплачено для групи • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Розподіл витрат';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Розподіл витрат • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Ім’я власника скопійовано.';

  @override
  String get paymentIbanCopied => 'IBAN скопійовано.';

  @override
  String get paymentSwiftCopied => 'Копія з SWIFT.';

  @override
  String get paymentRevtagCopied => 'Revtag скопійовано.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Не вдалося скопіювати в буфер обміну.';

  @override
  String get paymentCopied => 'Скопійовано.';

  @override
  String get paymentRequestAction => 'Запит на оплату';

  @override
  String get paymentRecordAction => 'Реєстрація платежу';

  @override
  String get paymentRequestSheetTitle => 'Запит на оплату';

  @override
  String get paymentRecordSheetTitle => 'Реєстрація платежу';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Попросіть $arg1 сплатити суму, яку він/вона наразі вам заборгував/заборгувала.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Використовуйте це після того, як ви сплатили $arg1 поза межами Splyto. Вони підтвердять його отримання.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Максимум $arg1';
  }

  @override
  String get paymentNoteHint => 'Банківський переказ, Revolut, готівка...';

  @override
  String get paymentAmountPositiveError => 'Сума повинна бути більшою за нуль.';

  @override
  String get paymentAmountTooHighError => 'Сума не може перевищувати залишок заборгованості.';

  @override
  String get paymentRequestCreated => 'Запит на оплату надіслано.';

  @override
  String get paymentRecordedWaiting => 'Платіж зареєстровано. Очікуємо на підтвердження.';

  @override
  String get paymentConfirmTitle => 'Підтвердження платежу';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Підтвердьте, що ви отримали $arg1 від $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Платіж підтверджено.';

  @override
  String get paymentCancelRecordTitle => 'Скасувати запис про платіж';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Скасувати запис твого платежу на суму $arg1 для $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Запис про платіж скасовано.';

  @override
  String get paymentNotReceivedTitle => 'Платіж не отримано';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Позначити платіж $arg1 від $arg2 як не отриманий?';
  }

  @override
  String get paymentMarkedNotReceived => 'Платіж позначено як не отриманий.';

  @override
  String get paymentActivityTitle => 'Платіжна діяльність';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Відкриті запити на оплату: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Платежі, що очікують підтвердження: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Зареєстровані платежі';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 запросив платіж від $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 сплатив кошти користувачу $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Запит на оплату';

  @override
  String get paymentAwaitingConfirmationStatus => 'Очікується підтвердження';

  @override
  String get paymentReviewRequestAction => 'Переглянути запит';

  @override
  String get paymentViewDetailsAction => 'Реквізити платежу';

  @override
  String get paymentMarkPaidAction => 'Я сплатив';

  @override
  String get paymentDeclineAction => 'Відхилити';

  @override
  String get paymentRequestReviewTitle => 'Запит на оплату';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 попросив у вас $arg2. Сплатіть поза межами Splyto, а потім позначте платіж як здійснений.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Позначити запит як оплачений?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Підтверджуй лише після того, як сплатиш суму $arg1 користувачу $arg2 поза межами Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Позначено як оплачене. Очікується підтвердження.';

  @override
  String get paymentRequestCancelTitle => 'Скасувати запит на оплату?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Скасувати ваш запит $arg1 до $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Запит на оплату скасовано.';

  @override
  String get paymentRequestDeclineTitle => 'Відхилити запит на оплату?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Відхилити запит на оплату суми $arg1 від $arg2? Ця людина отримає сповіщення.';
  }

  @override
  String get paymentRequestDeclined => 'Запит на оплату відхилено.';

  @override
  String get paymentPendingBeforeFinish => 'Вирішуйте відкриті запити на оплату та непідтверджені платежі до остаточного розрахунку.';

  @override
  String get paymentFinishBlockedByPending => 'Завершення розблоковується після вирішення питань щодо запитів на оплату та непідтверджених платежів.';

  @override
  String get notificationPaymentRequestedTitle => 'Запит на оплату';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 попросив у вас $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Ви отримали запит на оплату.';

  @override
  String get notificationPaymentRequestSentTitle => 'Запитаний платіж надіслано';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 позначив ваш запит на оплату $arg2 як оплачений.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Ваш запит на оплату було позначено як оплачений.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Запит на оплату скасовано';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 скасував запит на оплату $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Запит на оплату було скасовано.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Запит на оплату відхилено';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 відхилив ваш запит на оплату $arg2.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Ваш запит на оплату було відхилено.';

  @override
  String get notificationPaymentSentTitle => 'Платіж позначено як надісланий';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 позначив $arg2 як оплачений вам.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Платіж було позначено як надісланий вам.';

  @override
  String get notificationPaymentConfirmedTitle => 'Платіж підтверджено';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 підтвердив отримання $arg2 від вас.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Ваш платіж було підтверджено.';

  @override
  String get notificationPaymentCancelledTitle => 'Платіж скасовано';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 скасував позначку про оплату $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Позначка про платіж була скасована.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Платіж не отримано';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 позначив платіж $arg2 як не отриманий.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Платіж було позначено як не отриманий.';

  @override
  String get quickStartTitle => 'Швидкий старт';

  @override
  String get quickStartCreateTitle => 'Створити поїздку';

  @override
  String get quickStartCreateBody => 'Оберіть назву та валюту. Ведіть власні витрати або діліться витратами з групою.';

  @override
  String get quickStartInviteTitle => 'Подорожуйте разом або самостійно';

  @override
  String get quickStartInviteBody => 'Запрошуйте друзів долучитися до вашої подорожі або розпочніть особисту подорож самостійно.';

  @override
  String get quickStartExpenseTitle => 'Додайте свою першу витрату';

  @override
  String get quickStartExpenseBody => 'Введіть суму, виберіть, хто заплатив, і розділіть витрати. Ваші залишки на рахунках завжди актуальні.';

  @override
  String get quickStartNext => 'Далі';

  @override
  String get quickStartBack => 'Назад';

  @override
  String get quickStartSkip => 'Пропустити';

  @override
  String get quickStartCreateAction => 'Створити поїздку';

  @override
  String get quickStartClose => 'Закрити «Швидкий старт»';

  @override
  String get quickStartSubtitle => 'Дізнайтеся, як працюють поїздки та витрати';

  @override
  String quickStartStep(int step, int total) {
    return 'Крок $step із $total';
  }

  @override
  String get workspaceTripTotal => 'Загальна вартість поїздки';

  @override
  String get workspacePersonalTotal => 'Загальна сума витрат';

  @override
  String get workspaceBalanceEven => 'Твій баланс вирівняно';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Ти винен $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Тобі повернуть $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Учасники: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Пошук витрат';

  @override
  String get workspaceClearSearch => 'Чіткий пошук';

  @override
  String get workspaceSearchLoadedHint => 'Пошук охоплює завантажені витрати. Завантажте більше, щоб включити старіші витрати.';

  @override
  String get workspaceNoExpenseMatches => 'Немає відповідних витрат';

  @override
  String get workspaceNoExpenseMatchesBody => 'Спробуйте інший пошук або очистіть його, щоб переглянути всі завантажені витрати.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Додайте свою першу витрату, щоб почати відстежувати свої витрати.';

  @override
  String get workspaceEmptyGroupExpenses => 'Додайте свою першу спільну витрату, щоб побачити частку кожного учасника.';

  @override
  String get workspaceLoadMoreExpenses => 'Завантажити більше витрат';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Початкова сума: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Коментарі: $count';
  }

  @override
  String get workspaceExpenseActions => 'Дії, пов’язані з витратами';

  @override
  String get workspaceLoadErrorTitle => 'Не вдалося завантажити цю поїздку';

  @override
  String get workspaceCachedWarning => 'Відображення збережених даних. Вони можуть бути застарілими.';

  @override
  String get workspaceActivityTab => 'Активність';

  @override
  String get workspaceLoadingTrip => 'Завантаження поїздки';

  @override
  String get workspaceRefreshFailed => 'Оновлення не вдалося';

  @override
  String get expenseDetailsTitle => 'Деталі витрат';

  @override
  String get expenseQuickCategories => 'Короткі категорії';

  @override
  String get expenseReceiptRead => 'Квитанцію прочитано, форму оновлено.';

  @override
  String get expenseReceiptNoData => 'Квитанція додається. Не виявлено чіткої суми, дати або продавця.';

  @override
  String get expenseReceiptScanFailed => 'Вибрано квитанцію. Автоматичне зчитування не вдалося; перевірте поля вручну.';

  @override
  String get expenseReceiptOffline => 'Квитанція завантажиться під час збереження. Для автоматичного зчитування необхідне підключення до Інтернету.';

  @override
  String get expenseReadingReceipt => 'Зчитування чека…';

  @override
  String get expenseCommentsLoadFailed => 'Не вдалося завантажити коментарі. Спробуйте ще раз.';

  @override
  String get expenseReplyAction => 'Відповісти';

  @override
  String get expenseReplyHint => 'Напишіть відповідь…';

  @override
  String expenseReplyTo(String name) {
    return 'Відповісти $name';
  }

  @override
  String get balanceEmptyBody => 'Суми на рахунках відображаються після додавання витрат.';

  @override
  String get balanceAfterPayments => 'Залишки на рахунках включають підтверджені платежі.';

  @override
  String get balanceExpenseShare => 'Розподіл витрат';

  @override
  String get balanceHistoryScope => 'Завантажені витрати та підтверджені платежі. Цей перелік може не містити повну історію поїздки.';

  @override
  String balancePaymentTo(String name) {
    return 'Платіж на ім’я $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Платіж від $name';
  }

  @override
  String get settlementEmptyActive => 'Перед початком остаточних розрахунків позначте всіх як готових.';

  @override
  String get settlementEmptyClosed => 'Для цієї поїздки перекази не вказані.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count із $total переказів підтверджено';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count із $total учасників готові';
  }

  @override
  String get settlementMemberReady => 'Готово';

  @override
  String get settlementMemberNotReady => 'Не готово';

  @override
  String get settlementSuggested => 'Рекомендований переказ';

  @override
  String get activityLoadFailed => 'Не вдалося оновити активність. Будь-які видимі записи можуть бути застарілими.';

  @override
  String get activityMember => 'Учасник поїздки';

  @override
  String get friendsEmptyBody => 'Знайдіть друга за іменем або електронною адресою, або скористайтеся QR-кодом.';

  @override
  String get friendsDeclineAction => 'Відхилити';

  @override
  String get friendsLoading => 'Завантаження друзів';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Спільні поїздки: $count';
  }

  @override
  String get memberActivityScope => 'На основі завантажених витрат; це може не охоплювати всю подорож.';

  @override
  String get sharedTripsLoadedLimit => 'Відображається до 20 спільних поїздок.';

  @override
  String get memberRemoveTitle => 'Видалити учасника?';

  @override
  String memberRemoveBody(String name) {
    return 'Видалити $name з цієї поїздки? Це можливо лише в тому випадку, якщо у нього немає витрат, розрахунків або залишків на рахунку.';
  }

  @override
  String get memberRemoveAction => 'Видалити з поїздки';

  @override
  String memberRemoved(String name) {
    return '$name видалено з поїздки.';
  }

  @override
  String get profilePaymentNotAdded => 'Ще не додано';

  @override
  String get friendRelationshipLabel => 'Друг';

  @override
  String get sharedTripsEmptyBody => 'Подорожі, до яких ви обидва приєднаєтеся, з’являться тут.';

  @override
  String get analyticsAllTrips => 'Усі поїздки';

  @override
  String get analyticsByTrip => 'За поїздкою';

  @override
  String get analyticsYourSpending => 'Твої витрати';

  @override
  String get analyticsActiveArchived => 'Активні та архівні поїздки';

  @override
  String get analyticsTrips => 'Подорожі';

  @override
  String get analyticsAveragePerTrip => 'Середній показник за поїздку';

  @override
  String get analyticsPaidByMember => 'Оплата здійснюється учасником';

  @override
  String get analyticsYouPaid => 'Ви платите';

  @override
  String get analyticsYouGetBack => 'Тобі повернуть';

  @override
  String get analyticsYouOwe => 'Твій борг';

  @override
  String get analyticsParticipants => 'Учасники';

  @override
  String get analyticsYourCategories => 'Ваші витрати за категоріями';

  @override
  String get analyticsLargestShares => 'Мої найбільші частки витрат';

  @override
  String get analyticsLargestExpenses => 'Найбільші витрати';

  @override
  String get analyticsSpendingByTrip => 'Ваші витрати за поїздкою';

  @override
  String get analyticsEmptyTitle => 'Поки що витрат немає';

  @override
  String get analyticsEmptyBody => 'Ваші витрати з’являться тут, коли ви додасте витрати до поїздки.';

  @override
  String get analyticsPeriodEmptyBody => 'Для цього перегляду витрат немає. Спробуйте іншу поїздку або період.';

  @override
  String get analyticsLoadFailed => 'Не вдалося завантажити повний звіт про витрати. Спробуйте ще раз.';

  @override
  String get analyticsLastLoaded => 'Відображення останнього успішно завантаженого звіту.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count витрат',
      many: '$count витрат',
      few: '$count витрати',
      one: '$count витрата',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Параметри поїздки';

  @override
  String get editTripAction => 'Редагувати поїздку';

  @override
  String get deleteTripAction => 'Видалити поїздку';

  @override
  String get inviteTripMembersAction => 'Запрошувати учасників';

  @override
  String get tripCoverPhoto => 'Фото на обкладинці';

  @override
  String get tripInviteLaterHint => 'Ви можете запрошувати людей після створення поїздки.';

  @override
  String get inviteClipboardFailed => 'Не вдалося отримати доступ до буфера обміну. Спробуйте ще раз.';

  @override
  String get friendInviteToTrip => 'Запросити до поїздки';

  @override
  String get friendChooseTrip => 'Оберіть поїздку';

  @override
  String get friendNoInvitableTrips => 'Подорожей немає. Ви можете запрошувати друзів до активних групових подорожей, якими ви керуєте, якщо вони ще не є учасниками або не мають запрошення, що очікує на підтвердження.';

  @override
  String get friendTripInviteSent => 'Запрошення надіслано.';

  @override
  String get friendTripUnavailable => 'Ця поїздка більше не доступна для цієї дії. Оновіть сторінку та спробуйте ще раз.';

  @override
  String get friendTripActionFailed => 'Не вдалося виконати цю дію. Спробуйте ще раз.';

  @override
  String get profileContactDescription => 'Маєте проблему, пропозицію чи запитання щодо Splyto? Напишіть нам — ми з радістю допоможемо.';

  @override
  String get profileContactEmailAction => 'Напишіть електронного листа';

  @override
  String get profileContactEmailUnavailable => 'Не вдалося відкрити додаток електронної пошти. Скопіюйте адресу та напишіть нам із вашого додатка електронної пошти.';

  @override
  String get profilePrivacyPolicy => 'Політика конфіденційності';

  @override
  String get privacyLoadFailed => 'Не вдалося завантажити політику конфіденційності. Спробуйте ще раз.';

  @override
  String get addReceiptAction => 'Додати квитанцію';

  @override
  String get receiptPickFailed => 'Не вдалося завантажити квитанцію. Спробуйте ще раз.';

  @override
  String get receiptPhotoAccessDenied => 'Надайте Splyto доступ до камери або фотогалереї в налаштуваннях, а потім спробуйте ще раз.';

  @override
  String get receiptPhotoLabel => 'Фото чека';

  @override
  String get replaceReceiptAction => 'Замінити квитанцію';

  @override
  String get removeReceiptAction => 'Видалити квитанцію';

  @override
  String get restoreReceiptAction => 'Відновити попередню квитанцію';

  @override
  String get expenseSplitBetween => 'Розділіть між';

  @override
  String get expenseEditParticipants => 'Виберіть учасників';

  @override
  String get expenseCustomSplit => 'Індивідуальний розподіл витрат';

  @override
  String expenseSplitAllocated(String amount) {
    return 'Усю суму $amount розподілено';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Залишилося розділити $amount';
  }

  @override
  String expenseSplitOver(String amount) {
    return 'На $amount більше за загальну суму';
  }

  @override
  String get profilePaymentSharingTitle => 'Поділитися способами оплати з моїми поїздками';

  @override
  String get profilePaymentSharingDescription => 'Дозволити схваленим учасникам подорожей, які я створюю або до яких приєднуюся, бачити мої способи оплати. Це стосується поточних і майбутніх подорожей. Можна будь-коли вимкнути цей доступ, щоб припинити подальший перегляд.';

  @override
  String get memberPaymentDetailsNotShared => 'Інформація про способи оплати не передається або наразі недоступна.';

  @override
  String get homeTripInvitations => 'Запрошення на поїздку';

  @override
  String get homeNoTripInvitations => 'Немає очікуючих запрошень на поїздку';

  @override
  String get homeInvitationsLoadFailed => 'Не вдалося завантажити запрошення. Спробуйте ще раз.';

  @override
  String get homeInvitationResponseFailed => 'Не вдалося відповісти на запрошення. Спробуйте ще раз.';

  @override
  String get homeTripShareFailed => 'Не вдалося поділитися поїздкою. Спробуйте ще раз.';

  @override
  String get settleStillToReceive => 'Ще належить отримати';

  @override
  String get settleStillToPay => 'Ще потрібно сплатити';

  @override
  String get settleEstimateCaption => 'Оцінка базується на поточних витратах. Суми можуть змінюватися до закінчення поїздки.';

  @override
  String get settleOutstandingCaption => 'Очікується оплата або підтвердження.';

  @override
  String get settleWaitingForYou => 'Чекаємо, поки ви позначите, що готові.';

  @override
  String get settleWhoPaysWhom => 'Хто кому платить';

  @override
  String get settlePreviewCaption => 'Попередній перегляд · завершується після закінчення поїздки';

  @override
  String get settleOpenPaymentCaption => 'Відкрийте платіж, щоб переглянути деталі та доступні дії.';

  @override
  String get tripBudgetEnable => 'Встановіть бюджет';

  @override
  String get tripBudgetSoloHint => 'Необов’язкова ціль витрат для цієї подорожі.';

  @override
  String get tripBudgetGroupHint => 'Один спільний бюджет для всієї групи.';

  @override
  String get tripBudgetAmount => 'Сума бюджету';

  @override
  String get tripBudgetInvalid => 'Введіть суму від 0,01 до 999999999,99 з точністю до двох знаків після коми.';

  @override
  String get tripBudgetTitle => 'Бюджет поїздки';

  @override
  String get tripBudgetGroupTitle => 'Бюджет групи';

  @override
  String get tripBudgetRemaining => 'Решта';

  @override
  String get tripBudgetOver => 'Перевищення бюджету';

  @override
  String get tripBudgetSpent => 'Витрачено';

  @override
  String get tripBudgetLimit => 'Бюджет';

  @override
  String get travelMapTitle => 'Моя карта подорожі';

  @override
  String get travelMapSubtitle => 'Відвідані місця — спеціально для вас.';

  @override
  String get travelMapHere => 'Я вже тут';

  @override
  String get travelMapAdd => 'Додати місце';

  @override
  String get travelMapSearch => 'Пошук міста та країни';

  @override
  String get travelMapSearchAction => 'Пошук';

  @override
  String get travelMapSearchHint => 'Наприклад, Лісабон, Португалія';

  @override
  String get travelMapEmpty => 'Ваші наступні спогади починаються тут';

  @override
  String get travelMapEmptyBody => 'Додайте місто, яке ви відвідали, або позначте, де ви перебуваєте зараз.';

  @override
  String get travelMapConfirm => 'Зберегти цей візит?';

  @override
  String get travelMapConfirmBody => 'Перевірте місто та дату, перш ніж додавати їх до своєї приватної карти.';

  @override
  String get travelMapDate => 'Дата відвідування';

  @override
  String get travelMapSave => 'Зберегти на моїй карті';

  @override
  String get travelMapCancel => 'Скасувати';

  @override
  String get travelMapClose => 'Закрити';

  @override
  String get travelMapNoResults => 'Місто не знайдено. Спробуйте додати країну до пошуку.';

  @override
  String get travelMapLookupError => 'Не вдалося знайти місто. Перевірте з’єднання або додайте місце вручну.';

  @override
  String get travelMapDenied => 'Доступ до місцезнаходження вимкнено. Ви все одно можете вручну додати місто.';

  @override
  String get travelMapDisabled => 'Увімкніть служби визначення місцезнаходження або додайте місто вручну.';

  @override
  String get travelMapError => 'Не вдалося завантажити карту вашої подорожі. Спробуйте ще раз.';

  @override
  String get travelMapSaveError => 'Не вдалося зберегти візит. Спробуйте ще раз.';

  @override
  String get travelMapUnavailable => 'Карта подорожі потребує оновлення сервера.';

  @override
  String get travelMapOffline => 'Офлайн · відображення збережених місць';

  @override
  String get travelMapRetry => 'Спробуйте ще раз';

  @override
  String get travelMapDelete => 'Видалити візит';

  @override
  String get travelMapDeleteConfirm => 'Видалити цей візит із вашої приватної карти?';

  @override
  String get travelMapFit => 'Показати всі місця';

  @override
  String get travelMapSaved => 'Відвідати збережене';

  @override
  String get travelMapVisited => 'Відвідано';

  @override
  String get travelMapLimit => 'Ваша карта досягла 1 000 відвідувань. Видаліть старе відвідування, перш ніж додавати нове.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries країн',
      many: '$countries країн',
      few: '$countries країни',
      one: '$countries країна',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities міст',
      many: '$cities міст',
      few: '$cities міста',
      one: '$cities місто',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count відвідувань',
      many: '$count відвідувань',
      few: '$count відвідування',
      one: '$count відвідування',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Пункти призначення (необов’язково)';

  @override
  String get travelAddDestination => 'Додати пункт призначення';

  @override
  String get travelRemoveDestination => 'Видалити пункт призначення';

  @override
  String get travelFromTrip => 'З поїздки';

  @override
  String get travelChooseTrip => 'Оберіть поїздку';

  @override
  String get travelNoTrips => 'Подорожей поки що немає. Ви можете додати місце вручну.';

  @override
  String get travelAddToMap => 'Додати на мою карту';

  @override
  String get travelTripConfirm => 'Зберігайте лише ті місця, які ви насправді відвідали. Це додає особисті спогади до вашої карти.';

  @override
  String get travelVisitTitle => 'Заголовок (необов’язково)';

  @override
  String get travelAddPhoto => 'Додайте фото';

  @override
  String get travelChangePhoto => 'Змінити фото';

  @override
  String get travelRemovePhoto => 'Видалити фото';

  @override
  String get travelPhotoError => 'Не вдалося підготувати це фото. Будь ласка, виберіть інше.';

  @override
  String get travelEditVisit => 'Редагувати візит';

  @override
  String get travelOpenTrip => 'Відкрита подорож';

  @override
  String get travelPreviousVisit => 'Попереднє відвідування';

  @override
  String get travelNextVisit => 'Наступний візит';

  @override
  String get travelDuplicate => 'Ця поїздка вже позначена на вашій карті.';

  @override
  String get liveMapTitle => 'Карта в режимі реального часу';

  @override
  String get liveShareTitle => 'Поділитися моїм місцезнаходженням';

  @override
  String get liveConsent => 'Ділися своїм точним місцезнаходженням лише зі схваленими учасниками цієї подорожі протягом обраного тобою часу. Передавання триває у фоновому режимі, і його можна зупинити будь-коли.';

  @override
  String get liveBackgroundNote => 'Оновлення можуть призупинятися без інтернету або якщо ви примусово закриєте додаток. Зберігається лише останнє місцезнаходження; історія маршруту не записується.';

  @override
  String get liveStart => 'Почати обмін даними';

  @override
  String get liveStop => 'Припинити обмін даними';

  @override
  String get liveNotification => 'Ваше місцезнаходження передається учасникам вашої подорожі. Відкрийте Splyto, щоб припинити передачу даних.';

  @override
  String get livePermissionError => 'Дозволь доступ до геолокації в налаштуваннях телефону, щоб ділитися своїм місцезнаходженням.';

  @override
  String get liveStartError => 'Не вдалося розпочати обмін даними. Перевірте доступ до даних про місцезнаходження, підключення до Інтернету, а також дату та час на вашому телефоні.';

  @override
  String get liveStopPending => 'Оновлення зупинено. Очікується підключення до Інтернету для видалення вашого останнього місцезнаходження; воно зникне з карти протягом 2 хвилин без оновлень.';

  @override
  String get liveSharing => 'ділиться місцезнаходженням';

  @override
  String get liveUnavailable => 'Ця карта в режимі реального часу недоступна. Поверніться до поїздки та оновіть сторінку.';

  @override
  String get liveMapLoadError => 'Карту не вдалося завантажити. Перевірте з’єднання та спробуйте відкрити карту ще раз.';

  @override
  String get liveLoadError => 'Не вдалося оновити дані про місцезнаходження. Показано лише останні оновлення.';

  @override
  String get liveFit => 'Показати всіх на карті';

  @override
  String get liveEmpty => 'Наразі ніхто ще не ділиться даними про своє поточне місцезнаходження.';

  @override
  String get liveRecent => 'Щойно оновлено';

  @override
  String get liveLastKnown => 'Останнє оновлення';

  @override
  String get liveAccuracy => 'Точність';

  @override
  String get liveUntil => 'Поділитися до';

  @override
  String get liveOtherSession => 'Процес розпочато в іншому сеансі. Ви можете зупинити його тут.';

  @override
  String get liveUpdatesPaused => 'Оновлення призупинено. Перевірте доступ до місцезнаходження та інтернет-з’єднання.';

  @override
  String get livePrivateUntilShared => 'Ваше місцезнаходження залишається конфіденційним, доки ви не вирішите поділитися ним.';

  @override
  String get activityEventExpenseCreated => 'додано витрату';

  @override
  String get activityEventExpenseUpdated => 'оновлено витрати';

  @override
  String get activityEventExpenseDeleted => 'видалено витрату';

  @override
  String get activityEventExpenseCommentAdded => 'додано коментар до витрати';

  @override
  String get activityEventTripCreated => 'створив поїздку';

  @override
  String get activityEventTripUpdated => 'оновлені деталі поїздки';

  @override
  String get activityEventTripRenamed => 'змінено назву поїздки';

  @override
  String get activityEventTripCurrencyChanged => 'змінено валюту поїздки';

  @override
  String get activityEventTripPhotoChanged => 'змінено фото поїздки';

  @override
  String get activityEventTripBudgetChanged => 'змінено бюджет поїздки';

  @override
  String get activityEventTripDestinationsChanged => 'змінено напрямки поїздки';

  @override
  String get activityEventTripMembersAdded => 'додані учасники';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'Надіслано запрошень: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'приєднався до поїздки';

  @override
  String get activityEventTripInvitationDeclined => 'відхилив запрошення на поїздку';

  @override
  String get activityEventTripInvitationRevoked => 'скасував запрошення на поїздку';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'вилучено $name з поїздки';
  }

  @override
  String get activityEventTripMemberLeft => 'вийшов із поїздки';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'змінено роль $name на $role';
  }

  @override
  String get activityEventTripMemberReady => 'позначено як готове до розрахунку';

  @override
  String get activityEventTripMemberNotReady => 'позначено як «не готово»';

  @override
  String get activityEventTripAllMembersReady => 'Усі учасники готові до розрахунку';

  @override
  String get activityEventTripFinished => 'подорож завершено';

  @override
  String get activityEventTripSettled => 'Усі перекази підтверджено, поїздку розраховано';

  @override
  String get activityEventSettlementMarkedSent => 'позначив переказ як надісланий';

  @override
  String get activityEventSettlementConfirmed => 'підтверджено переказ';

  @override
  String get activityEventSettlementSentCancelled => 'статус «скасовано», «надіслано»';

  @override
  String get activityEventSettlementNotReceived => 'позначив переказ як не отриманий';

  @override
  String get activityEventSettlementReminderSent => 'надіслано нагадування про розрахунок';

  @override
  String get activityEventPaymentMarkedSent => 'зареєстрував платіж';

  @override
  String get activityEventPaymentRequested => 'запросив платіж';

  @override
  String get activityEventPaymentRequestMarkedSent => 'позначив запитуваний платіж як надісланий';

  @override
  String get activityEventPaymentRequestCancelled => 'скасовано запит на оплату';

  @override
  String get activityEventPaymentRequestDeclined => 'відхилив запит на оплату';

  @override
  String get activityEventPaymentConfirmed => 'підтвердив платіж';

  @override
  String get activityEventPaymentCancelled => 'скасовано запис про платіж';

  @override
  String get activityEventPaymentNotReceived => 'позначив платіж як не отриманий';

  @override
  String get activityEventUnknown => 'внесено зміну';

  @override
  String get privacyEnglishFallback => 'Політика конфіденційності наразі доступна англійською мовою.';

  @override
  String get activityRoleAdmin => 'Адміністратор';

  @override
  String get accountDeleteTitle => 'Видалити обліковий запис';

  @override
  String get accountDeleteIntro => 'Підтвердь видалення через електронну пошту. Після підтвердження його неможливо скасувати.';

  @override
  String get accountDeleteConsequences => 'Видалення є остаточним. Ваш профіль анонімізується, а доступ до облікового запису скасовується. Записи про спільні поїздки та витрати зберігаються для інших учасників.';

  @override
  String get accountDeleteReasonsTitle => 'Що ми могли б зробити краще?';

  @override
  String get accountDeleteReasonsHint => 'Причина (необов’язково)';

  @override
  String get accountDeleteReasonNotUsing => 'Мені більше не потрібен Splyto для моїх поїздок';

  @override
  String get accountDeleteReasonAnotherWay => 'Я керую спільними витратами іншим способом';

  @override
  String get accountDeleteReasonComplicated => 'Щоб щось зробити, потрібно докласти занадто багато зусиль';

  @override
  String get accountDeleteReasonTechnical => 'Я зіткнувся з помилками або технічними проблемами';

  @override
  String get accountDeleteReasonPrivacy => 'Я волів би видалити дані свого облікового запису';

  @override
  String get accountDeleteReasonOther => 'Хочу видалити обліковий запис з іншої причини';

  @override
  String get accountDeleteEmailStep => 'Наступним кроком є підтвердження електронною поштою.';

  @override
  String get accountDeletePasswordHint => 'Введіть свій поточний пароль Splyto, щоб отримати електронний лист із підтвердженням. Ваш обліковий запис досі активний.';

  @override
  String get accountDeleteInboxTitle => 'Останній крок у вашій поштовій скриньці';

  @override
  String accountDeleteSentBody(String email) {
    return 'Посилання для підтвердження надіслано на $email.';
  }

  @override
  String get accountDeleteSentHint => 'Твій обліковий запис залишається активним, доки ти не підтвердиш видалення.';

  @override
  String get accountDeleteSending => 'Надсилання електронного листа з підтвердженням';

  @override
  String get friendsShowMore => 'Показати більше';
}
