// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get homeFirstTrip => 'Ваша первая поездка';

  @override
  String get homeYourShareAllTrips => 'Ваша доля по всем поездкам';

  @override
  String get homeAllTime => 'За всё время';

  @override
  String get homeSolo => 'Один';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человека',
      many: '$count человек',
      few: '$count человека',
      one: '$count человек',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Действия с поездкой: $name';
  }

  @override
  String get homeNoActiveTrips => 'Нет активных поездок';

  @override
  String get homeNoArchivedTrips => 'Нет поездок в архиве';

  @override
  String get homeLoadingTrips => 'Загружаем ваши поездки';

  @override
  String get homeLoadErrorTitle => 'Не удалось загрузить поездки';

  @override
  String get homeLoadErrorBody => 'Повторите попытку через минуту.';

  @override
  String get homeOfflineTitle => 'Нет подключения';

  @override
  String get homeOfflineNoData => 'Ваши поездки пока недоступны на этом устройстве.';

  @override
  String get homeOfflineCached => 'Нет подключения. Показаны сохранённые поездки.';

  @override
  String get homeRefreshError => 'Не удалось обновить. Показаны ранее загруженные поездки.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Поделиться моими платёжными реквизитами с $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Только пока запрос ожидает оплаты. Отмена запроса закрывает доступ.';

  @override
  String get paymentDetailsUnavailable => 'Платёжные реквизиты недоступны. Подключитесь к интернету и проверьте, что запрос ещё открыт.';

  @override
  String get paymentDetailsRetry => 'Повторить';

  @override
  String get tripModeSolo => 'Только я';

  @override
  String get tripModeGroup => 'С другими';

  @override
  String get premiumFree => 'Бесплатно';

  @override
  String get premiumStatusUnavailable => 'Статус тарифа недоступен';

  @override
  String premiumGrantedUntil(String date) {
    return 'Premium предоставлен до $date';
  }

  @override
  String get premiumBillingNotActive => 'Нет активной подписки';

  @override
  String get premiumRefreshStatus => 'Обновить статус тарифа';

  @override
  String get accountSectionTitle => 'Аккаунт';

  @override
  String get activeStatus => 'Активна';

  @override
  String get activeTripPlural => 'активных поездок';

  @override
  String get activeTripSingle => 'активная поездка';

  @override
  String get activeTrips => 'Активные поездки';

  @override
  String get activitiesComingSoon => 'Раздел активности скоро появится.';

  @override
  String get addAction => 'Добавить';

  @override
  String get addExpenseTitle => 'Добавить расход';

  @override
  String get addExpensesAction => 'Добавить расходы';

  @override
  String get addMembersAction => 'Добавить участников';

  @override
  String get addTripMembersTitle => 'Пригласить участников поездки';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправлено приглашений: $count.',
      many: 'Отправлено приглашений: $count.',
      few: 'Отправлено приглашений: $count.',
      one: 'Отправлено приглашений: $count.',
    );
    return '$_temp0';
  }

  @override
  String get tripInvitationDeclined => 'Приглашение в поездку отклонено.';

  @override
  String get tripInviteAction => 'Пригласить';

  @override
  String get tripInvitationsPending => 'Ожидают ответа';

  @override
  String get tripInvitationsRetry => 'Приглашения недоступны. Повторить';

  @override
  String get tripInvitationRevoke => 'Отменить приглашение';

  @override
  String get tripInvitationRevokeFailed => 'Не удалось отменить приглашение. Повторите попытку.';

  @override
  String get tripInvitationBody => 'Вас пригласили в поездку. Откройте приглашение, чтобы ответить.';

  @override
  String get allCaughtUp => 'Новых уведомлений нет';

  @override
  String get allFilter => 'Все';

  @override
  String get allMembersLabel => 'Все участники';

  @override
  String get allPaymentsConfirmed => 'Все платежи подтверждены.';

  @override
  String get allTrips => 'Все поездки';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Сумма';

  @override
  String get amountMustBeGreaterThanZero => 'Сумма должна быть больше 0.';

  @override
  String get appearance => 'Оформление';

  @override
  String get archivedStatus => 'В архиве';

  @override
  String get authSubtitleLogin => 'Делите расходы в поездках с друзьями';

  @override
  String get authSubtitleRegister => 'Создайте аккаунт и начните делить расходы';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'подтверждено: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'ожидает: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'отправлено: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'предложено: $count';
  }

  @override
  String get cancelAction => 'Отмена';

  @override
  String get changeEmailWithPasswordHelper => 'Введите пароль, чтобы изменить эл. почту.';

  @override
  String get chooseReceiptFile => 'Выбрать файл чека';

  @override
  String get completeAccountSetupDescription => 'Укажите эл. почту и пароль, чтобы завершить настройку аккаунта.';

  @override
  String get completeAccountSetupTitle => 'Завершите настройку аккаунта';

  @override
  String get confirmReceivedAction => 'Подтвердить получение';

  @override
  String get confirmedAllSettlementsArchived => 'Все расчёты подтверждены. Поездка в архиве.';

  @override
  String get confirmedAsReceived => 'Получение подтверждено.';

  @override
  String get confirmedLabel => 'Подтверждено';

  @override
  String get couldNotOpenReceiptLink => 'Не удалось открыть ссылку на чек.';

  @override
  String get createAction => 'Создать';

  @override
  String get createFirstTripHint => 'Создайте первую поездку, чтобы начать.';

  @override
  String get createNewTripTitle => 'Новая поездка';

  @override
  String get createTripAction => 'Создать поездку';

  @override
  String get createTripFirst => 'Сначала создайте поездку.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date  -  Создал(а): $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Создатель поездки должен её завершить, чтобы началось подтверждение расчётов.';

  @override
  String currentEmailLabel(Object email) {
    return 'Текущая эл. почта: $email';
  }

  @override
  String get currentReceiptAttached => 'Текущий чек прикреплён.';

  @override
  String get dateFormatHint => 'ГГГГ-ММ-ДД';

  @override
  String get dateLabel => 'Дата';

  @override
  String get dateMustMatchFormat => 'Дата должна быть в формате ГГГГ-ММ-ДД.';

  @override
  String get dateUnknown => 'Дата неизвестна';

  @override
  String get deleteAction => 'Удалить';

  @override
  String get deleteExpenseConfirmQuestion => 'Удалить этот расход?';

  @override
  String get deleteExpenseTitle => 'Удалить расход';

  @override
  String get editExpenseConfirmTitle => 'Сохранить изменения расхода?';

  @override
  String get editExpenseConfirmText => 'Балансы всех участников поездки будут обновлены.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Напрямую объясняется расходами: $amount';
  }

  @override
  String get doneStatus => 'Готово';

  @override
  String get editAction => 'Изменить';

  @override
  String get editExpenseTitle => 'Изменить расход';

  @override
  String get emailAddressLabel => 'Адрес эл. почты';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'Эл. почта';

  @override
  String get emailRequired => 'Укажите эл. почту.';

  @override
  String get enterValidExactAmounts => 'Введите корректные суммы для всех участников.';

  @override
  String get enterValidPercentages => 'Введите корректные проценты для всех участников.';

  @override
  String get equalSplitLabel => 'Поровну';

  @override
  String exactAmountWithValue(Object value) {
    return 'Точно: $value';
  }

  @override
  String get exactAmountsLabel => 'Точные суммы';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Сумма точных долей должна равняться $amount.';
  }

  @override
  String get expenseAdded => 'Расход добавлен.';

  @override
  String get expenseBreakdownSubtitle => 'Как каждый расход влияет на этого участника.';

  @override
  String get expenseBreakdownTitle => 'Разбивка расходов';

  @override
  String get expenseDeleted => 'Расход удалён.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Расход №$id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Оплачено $paid  -  Должен $owes';
  }

  @override
  String get expenseReactionsTitle => 'Реакции';

  @override
  String get expenseCommentsTitle => 'Комментарии';

  @override
  String get expenseNoComments => 'Комментариев пока нет.';

  @override
  String get expenseAddCommentHint => 'Добавить комментарий...';

  @override
  String get expenseCommentSend => 'Отправить';

  @override
  String get expenseMentionNoMatches => 'Подходящих участников нет';

  @override
  String get expenseMentionMembersLabel => 'Участники поездки для упоминания';

  @override
  String get expenseDeleteCommentTitle => 'Удалить комментарий?';

  @override
  String get expenseUpdated => 'Расход обновлён.';

  @override
  String expenseWithId(Object id) {
    return 'Расход №$id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count расхода',
      many: '$count расходов',
      few: '$count расхода',
      one: '$count расход',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Расходы';

  @override
  String get failedToCreateTrip => 'Не удалось создать поездку.';

  @override
  String get failedToLoadUsersDirectory => 'Не удалось загрузить список пользователей.';

  @override
  String get filterSettlementByMemberSubtitle => 'Фильтр расчётов по участнику';

  @override
  String get finishSoloTripConfirmationText => 'Завершить поездку и переместить её в архив? Ваши расходы останутся доступны для просмотра.';

  @override
  String get soloTripArchived => 'Поездка завершена и перемещена в архив.';

  @override
  String get finishTripSyncPending => 'Перед завершением поездки синхронизируйте ожидающие изменения.';

  @override
  String get finishTripAction => 'Завершить поездку';

  @override
  String get finishTripConfirmationText => 'Завершить поездку и начать расчёты?';

  @override
  String get finishTripStartSettlementsAction => 'Завершить и начать расчёты';

  @override
  String get finishTripTitle => 'Завершить поездку';

  @override
  String forParticipants(Object participants) {
    return 'Для: $participants';
  }

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get profileSetPassword => 'Задать пароль';

  @override
  String get profileManagePassword => 'Задать или изменить пароль';

  @override
  String get profilePasswordByEmail => 'Задать пароль через эл. почту';

  @override
  String get passwordEmailBackToProfile => 'Назад в профиль';

  @override
  String get forgotPasswordSubtitle => 'Введите эл. почту, и мы отправим ссылку для сброса пароля.';

  @override
  String get forgotPasswordSuccessMessage => 'Если аккаунт с этой эл. почтой существует, мы отправили ссылку для сброса пароля.';

  @override
  String get passwordResetSentTitle => 'Проверьте почту';

  @override
  String get passwordResetSentHint => 'Ссылка действует 1 час. Если письма нет, проверьте папку «Спам».';

  @override
  String get forgotPasswordTitle => 'Сброс пароля';

  @override
  String get friendsProgressSubtitle => 'Каждый участник и статус его подтверждения.';

  @override
  String get friendsProgressTitle => 'Прогресс друзей';

  @override
  String get friendsSectionComingSoon => 'Раздел друзей скоро появится.';

  @override
  String fromDirection(Object name) {
    return 'От: $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from → $to';
  }

  @override
  String get generateTurnAction => 'Выбрать очередь';

  @override
  String get hasAccountQuestion => 'Уже есть аккаунт?';

  @override
  String helloUser(Object name) {
    return 'Привет, $name!';
  }

  @override
  String get iSentAction => 'Я отправил(а)';

  @override
  String get invalidEmailFormat => 'Неверный формат эл. почты.';

  @override
  String get languageAction => 'Язык';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageLatvian => 'Латышский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageSystemSubtitle => 'Использовать язык устройства';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Оставьте пустым, чтобы сохранить текущий пароль.';

  @override
  String get logInButton => 'Войти';

  @override
  String get logOutButton => 'Выйти';

  @override
  String get logoutFromDeviceQuestion => 'Выйти на этом устройстве?';

  @override
  String get logoutRevocationUnconfirmed => 'Вы вышли на этом устройстве. Не удалось подтвердить завершение сеанса на сервере.';

  @override
  String get markedAsSent => 'Отмечено как отправленное.';

  @override
  String get markSettlementSentConfirmTitle => 'Отметить перевод как отправленный?';

  @override
  String get markSettlementSentConfirmText => 'Используйте это только после реальной отправки платежа. Получателя попросят подтвердить.';

  @override
  String get settlementCancelSentAction => 'Отметить как не отправленный';

  @override
  String get settlementCancelSentConfirmTitle => 'Отменить статус отправки?';

  @override
  String get settlementCancelSentConfirmText => 'Перевод снова станет ожидающим, а получатель получит уведомление.';

  @override
  String get settlementSentCancelled => 'Перевод снова в ожидании.';

  @override
  String get settlementNotReceivedAction => 'Я этого не получил(а)';

  @override
  String get settlementNotReceivedConfirmTitle => 'Сообщить о неполучении?';

  @override
  String get settlementNotReceivedConfirmText => 'Перевод снова станет ожидающим, а плательщик получит уведомление.';

  @override
  String get settlementMarkedNotReceived => 'Отмечено как не полученное.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Подтвердить получение?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Подтверждайте только после поступления денег на ваш счёт. Это действие может завершить расчёт.';

  @override
  String get memberSummariesSubtitle => 'Текущий баланс обеих сторон.';

  @override
  String get memberSummariesTitle => 'Сводка по участникам';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'К оплате $total  -  подтверждено $confirmed  -  ожидает $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Примерная сумма платежа для каждого участника.';

  @override
  String get membersImpactTitle => 'Влияние на участников';

  @override
  String get membersIncludedInExpense => 'Включённые участники';

  @override
  String get membersLabel => 'Участники';

  @override
  String moreCount(Object count) {
    return 'Ещё +$count';
  }

  @override
  String get myFilter => 'Мои';

  @override
  String get myImpactTitle => 'Моё участие';

  @override
  String get firstNameHint => 'Ваше имя';

  @override
  String get firstNameLabel => 'Имя';

  @override
  String get firstNameLengthValidation => 'Имя должно содержать от 2 до 64 символов.';

  @override
  String get fullNameHelper => 'Укажите имя и фамилию в одном поле.';

  @override
  String get fullNameHint => 'например, Анна Иванова';

  @override
  String get fullNameLabel => 'Полное имя';

  @override
  String get fullNameValidation => 'Введите имя и фамилию (минимум по 2 символа).';

  @override
  String get lastNameHint => 'Ваша фамилия';

  @override
  String get lastNameLabel => 'Фамилия';

  @override
  String get lastNameLengthValidation => 'Фамилия должна содержать от 2 до 64 символов.';

  @override
  String get nameHint => 'Ваше имя';

  @override
  String get nameLabel => 'Имя';

  @override
  String get nameLengthValidation => 'Имя должно содержать минимум 2 символа.';

  @override
  String get navActivities => 'Аналитика';

  @override
  String get navAddTrip => 'Добавить поездку';

  @override
  String get navBalances => 'Балансы';

  @override
  String get navExpenses => 'Расходы';

  @override
  String get navFriends => 'Друзья';

  @override
  String get navHome => 'Главная';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navRandom => 'Жребий';

  @override
  String get netLabel => 'Итог';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get nicknameHint => 'Как вас будут видеть друзья';

  @override
  String get nicknameLabel => 'Псевдоним';

  @override
  String get nicknameLengthValidation => 'Псевдоним должен содержать минимум 2 символа.';

  @override
  String get noAccountQuestion => 'Ещё нет аккаунта?';

  @override
  String get noBalancesYet => 'Балансов пока нет.';

  @override
  String get noChangesToSave => 'Нет изменений для сохранения.';

  @override
  String get noDirectExpenseLink => 'Прямой связи с одним расходом нет. Этот расчёт основан на общем балансе поездки.';

  @override
  String get noExpenseImpactForMember => 'Расходы не влияют на этого участника.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'У $name пока нет расходов.';
  }

  @override
  String get noExpensesYet => 'Расходов пока нет.';

  @override
  String get noExtraUsersToAdd => 'Больше некого добавить.';

  @override
  String get noInternetDeleteQueued => 'Нет интернета. Удаление в очереди.';

  @override
  String get noInternetExpenseQueued => 'Нет интернета. Расход в очереди.';

  @override
  String get noInternetUpdateQueued => 'Нет интернета. Обновление в очереди.';

  @override
  String get noMatchingRows => 'Подходящих строк нет.';

  @override
  String get noMembersFound => 'Участники не найдены.';

  @override
  String get noNewMembersAdded => 'Эти люди уже участвуют или имеют ожидающие приглашения.';

  @override
  String get noNotePlaceholder => 'Без примечания';

  @override
  String get notificationsToday => 'Сегодня';

  @override
  String get notificationsEmptyBody => 'Здесь будут появляться новости о поездках, расходах и друзьях.';

  @override
  String get notificationsCached => 'Нет подключения — показаны сохранённые уведомления.';

  @override
  String get notificationsRefreshFailed => 'Не удалось обновить. Показаны ранее загруженные уведомления.';

  @override
  String get notificationsJustNow => 'Только что';

  @override
  String notificationsMinutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String notificationsHoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String get notificationsUnread => 'Непрочитанные';

  @override
  String get noNotificationsYet => 'Уведомлений пока нет.';

  @override
  String get noParticipantData => 'Нет данных об участниках.';

  @override
  String get noParticipantsSelected => 'Участники не выбраны.';

  @override
  String get noPaymentRowsInTrip => 'В этой поездке нет платежей.';

  @override
  String get noPaymentsNeeded => 'Платежи не нужны.';

  @override
  String get noPicksYet => 'Выборов пока нет.';

  @override
  String get noSettlementActivityForMember => 'У этого участника нет операций по расчётам.';

  @override
  String get noSettlementRowsYet => 'Расчётов пока нет.';

  @override
  String get noSettlements => 'Нет расчётов';

  @override
  String get noTransferNeededForFilter => 'Для выбранного фильтра переводы не нужны.';

  @override
  String get noTransferRowsToShow => 'Нет переводов для показа.';

  @override
  String get noTripDataLoaded => 'Данные поездки не загружены.';

  @override
  String get noTripsYet => 'Поездок пока нет.';

  @override
  String get noUsersFoundYet => 'Пользователи пока не найдены.';

  @override
  String get notSetValue => 'Не указано';

  @override
  String get notYetConfirmedTitle => 'Ещё не подтверждено';

  @override
  String get noteHint => 'Ужин, такси, билеты...';

  @override
  String get noteLabel => 'Примечание';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Примечание: не более $max символов.';
  }

  @override
  String get notificationFallbackTitle => 'Уведомление';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationFriendInviteTitle => 'Приглашение в друзья';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name приглашает вас в друзья.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Вы получили приглашение в друзья.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Приглашение принято';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name принимает ваше приглашение в друзья.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Ваше приглашение в друзья принято.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Приглашение отклонено';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name отклоняет ваше приглашение в друзья.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Ваше приглашение в друзья отклонено.';

  @override
  String get notificationTripAddedTitle => 'Добавление в поездку';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name добавляет вас в поездку «$trip».';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Вас добавили в поездку «$trip».';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Вас добавили в поездку.';

  @override
  String get notificationExpenseAddedTitle => 'Новый расход';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name: новый расход $amount в «$trip».';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name: новый расход $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Добавлен новый расход.';

  @override
  String get notificationCommentMentionTitle => 'Вас упомянули в комментарии';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name упоминает вас в комментарии к «$note».';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name упоминает вас в комментарии.';
  }

  @override
  String get notificationTripFinishedTitle => 'Поездка завершена';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name завершает «$trip». Расчёты готовы.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name завершает «$trip». Поездка в архиве.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return 'Поездка «$trip» завершена.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Статус поездки обновлён.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Участник готов';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name готов(а) к расчётам в «$trip».';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Участник готов к расчётам в «$trip».';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Участник готов к расчётам.';

  @override
  String get notificationTripReadyToSettleTitle => 'Все участники готовы';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Все участники «$trip» готовы. Можно начинать расчёты.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Все участники готовы. Можно начинать расчёты.';

  @override
  String get notificationSettlementReminderTitle => 'Напоминание о расчёте';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor напоминает $target отметить $amount как отправленное.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor напоминает $target подтвердить получение $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Вы получили напоминание о расчёте.';

  @override
  String get notificationPaymentReminderTitle => 'Напоминание о платеже';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Напоминание: отметьте $amount как отправленное для $target в «$trip».';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Напоминание: отметьте платёж как отправленный.';

  @override
  String get notificationConfirmationReminderTitle => 'Напоминание о подтверждении';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Напоминание: подтвердите получение $amount от $payer в «$trip».';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Напоминание: подтвердите получение платежа.';

  @override
  String get notificationSettlementSentTitle => 'Перевод отмечен как отправленный';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name отмечает, что отправил(а) вам $amount.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Перевод отмечен как отправленный.';

  @override
  String get notificationSettlementConfirmedTitle => 'Перевод подтверждён';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name подтверждает получение $amount от вас.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Перевод подтверждён.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ожидающего изменения',
      many: '$count ожидающих изменений',
      few: '$count ожидающих изменения',
      one: '$count ожидающее изменение',
    );
    return 'Офлайн-очередь: $_temp0';
  }

  @override
  String get syncAllSynced => 'Всё синхронизировано';

  @override
  String syncChangesWaiting(Object count) {
    return 'Ожидают синхронизации: $count';
  }

  @override
  String get syncFailedTapToRetry => 'Сбой синхронизации, нажмите для повтора';

  @override
  String get offlineQueueStatus => 'Офлайн-очередь';

  @override
  String get offlineStatus => 'Нет подключения';

  @override
  String get onlineStatus => 'В сети';

  @override
  String get onlyCreatorCanFinishTrip => 'Завершить поездку может только её создатель.';

  @override
  String get openLabel => 'Открыто';

  @override
  String get openReceiptAction => 'Открыть чек';

  @override
  String get openSettlements => 'Открытые расчёты';

  @override
  String get overviewTitle => 'Обзор';

  @override
  String get owesLabel => 'Должен';

  @override
  String get paidByLabel => 'Кто оплатил';

  @override
  String get paidLabel => 'Оплачено';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Оплачено $paid  -  Должен $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Участники (пусто = все)';

  @override
  String get participantsTitle => 'Участники';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordComplexityHelper => 'Используйте минимум 1 заглавную букву, 1 цифру и 1 символ.';

  @override
  String get passwordComplexityValidation => 'Пароль должен содержать 1 заглавную букву, 1 цифру и 1 символ.';

  @override
  String get passwordMinLength => 'Пароль должен содержать минимум 8 символов.';

  @override
  String get passwordMinLengthShort => 'Пароль должен содержать минимум 6 символов.';

  @override
  String get passwordResetComingSoon => 'Сброс пароля скоро появится.';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают.';

  @override
  String payerName(Object name) {
    return '$name (плательщик)';
  }

  @override
  String get pendingLabel => 'Ожидает';

  @override
  String get pendingPaymentsSubtitle => 'Платежи, ожидающие полного подтверждения.';

  @override
  String get percentLabel => 'Процент';

  @override
  String get percentSplitMustBe100 => 'Сумма процентов должна равняться ровно 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Проценты';

  @override
  String get pickAtLeastOneParticipant => 'Выберите хотя бы одного участника.';

  @override
  String get pickMembersGenerateTurn => 'Выберите участников и определите очередь.';

  @override
  String pickedCycleCompleted(Object name) {
    return 'Выбран(а) $name. Круг завершён.';
  }

  @override
  String pickedUser(Object name) {
    return 'Выбран(а) $name.';
  }

  @override
  String get profileRefreshCachedData => 'Не удалось обновить профиль. Показаны сохранённые данные.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileUpdated => 'Профиль обновлён.';

  @override
  String get uploadAvatarAction => 'Загрузить аватар';

  @override
  String get takePhotoAction => 'Сделать снимок';

  @override
  String get chooseFromLibraryAction => 'Выбрать из галереи';

  @override
  String get removeAvatarAction => 'Удалить аватар';

  @override
  String get avatarUpdatedMessage => 'Аватар обновлён.';

  @override
  String get avatarRemovedMessage => 'Аватар удалён.';

  @override
  String get avatarFileTooLarge => 'Файл аватара слишком большой (макс. 5 МБ).';

  @override
  String get avatarPickFailed => 'Не удалось загрузить изображение аватара.';

  @override
  String get queueAddExpense => 'Добавить расход';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'В очереди: добавить расход $amount';
  }

  @override
  String get queueDeleteExpense => 'Удалить расход';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'В очереди: удалить расход №$id';
  }

  @override
  String get queuePendingStatus => 'Очередь ожидает';

  @override
  String get queueUpdateExpense => 'Обновить расход';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'В очереди: обновить расход №$id';
  }

  @override
  String get queuedChange => 'Изменение в очереди';

  @override
  String queuedChangesTitle(Object count) {
    return 'Изменения в очереди ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'В очереди ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Круг $cycleNo, жребий $drawNo — осталось $remaining';
  }

  @override
  String get receiptFallbackName => 'чек';

  @override
  String get receiptLinkInvalid => 'Ссылка на чек недействительна.';

  @override
  String get receiptOptionalLabel => 'Чек (необязательно)';

  @override
  String get recentPicksTitle => 'Последние выборы';

  @override
  String get reloadProfile => 'Перезагрузить профиль';

  @override
  String get rememberMe => 'Запомнить меня';

  @override
  String get removeCurrentReceipt => 'Удалить текущий чек';

  @override
  String get repeatNewPasswordLabel => 'Повторите новый пароль';

  @override
  String get repeatPasswordLabel => 'Повторите пароль';

  @override
  String get requestFailedTryAgain => 'Запрос не выполнен. Повторите попытку.';

  @override
  String get retryAction => 'Повторить';

  @override
  String get rowsLabel => 'Строки';

  @override
  String get backToLoginAction => 'Назад ко входу';

  @override
  String get saveAction => 'Сохранить';

  @override
  String get saveCredentialsButton => 'Сохранить данные входа';

  @override
  String get saveProfileButton => 'Сохранить профиль';

  @override
  String get sendResetLinkButton => 'Отправить ссылку для сброса';

  @override
  String get searchUsersHint => 'Поиск людей по имени или эл. почте';

  @override
  String get selectedPeopleLabel => 'Выбранные люди';

  @override
  String get noSearchMatches => 'Подходящие пользователи не найдены.';

  @override
  String get savingButton => 'Сохранение...';

  @override
  String get selectAtLeastTwoMembers => 'Выберите минимум двух участников.';

  @override
  String get selectMembersHint => 'Выберите участников';

  @override
  String selectedFileLabel(Object name) {
    return 'Выбрано: $name';
  }

  @override
  String get selectedLabel => 'Выбрано';

  @override
  String get selectedUserFallback => 'Выбранный пользователь';

  @override
  String get settings => 'Настройки';

  @override
  String get settleUpAction => 'Рассчитаться';

  @override
  String get settledLabel => 'Рассчитано';

  @override
  String get settledStatus => 'Рассчитано';

  @override
  String get settlementActivitySubtitle => 'Переводы, связанные с этим участником.';

  @override
  String get settlementActivityTitle => 'Операции по расчётам';

  @override
  String get settlementCompletedTitle => 'Расчёт завершён';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return 'Подтверждено $confirmed из $total';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Расчётов: $count';
  }

  @override
  String get settlementImpactTitle => 'Влияние на расчёты';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Влияние на расчёты: $name';
  }

  @override
  String get settlementInProgress => 'Идут расчёты';

  @override
  String get settlementInProgressTitle => 'Идут расчёты';

  @override
  String get settlementLabel => 'Расчёт';

  @override
  String get settlementOverviewArchivedSubtitle => 'Поездка в архиве. Все расчёты завершены.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Отслеживайте подтверждения расчётов.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Предварительные переводы на момент завершения поездки.';

  @override
  String get settlementPreview => 'Предпросмотр расчётов';

  @override
  String get settlementPreviewTitle => 'Предпросмотр расчётов';

  @override
  String get settlementProgressTripArchived => 'Поездка в архиве';

  @override
  String settlementWithId(Object id) {
    return 'Расчёт №$id';
  }

  @override
  String get settlements => 'Расчёты';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Расчёты уже завершены.';

  @override
  String get settlementsDone => 'Расчёты завершены';

  @override
  String get settlingStatus => 'Расчёты';

  @override
  String get shareUnit => 'доля';

  @override
  String get sharesLabel => 'Доли';

  @override
  String get sharesMustBePositiveIntegers => 'Доли должны быть целыми положительными числами.';

  @override
  String sharesWithValue(Object value) {
    return 'Доли: $value';
  }

  @override
  String get showActiveTrips => 'Показать активные поездки';

  @override
  String get signUpButton => 'Зарегистрироваться';

  @override
  String get splitBreakdownSubtitle => 'Как делится расход';

  @override
  String get splitBreakdownTitle => 'Разбивка доли';

  @override
  String get splitHintEqual => 'Поровну между выбранными участниками.';

  @override
  String get splitHintExact => 'Введите точную сумму для каждого участника. Сумма должна совпадать с итогом.';

  @override
  String get splitHintPercent => 'Введите процент для каждого участника. Сумма должна быть 100%.';

  @override
  String get splitHintShares => 'Введите количество долей (1, 2, 3...). Расход делится пропорционально.';

  @override
  String get splitLabel => 'Деление';

  @override
  String splitLabelValue(Object value) {
    return 'Деление: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Поровну ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Точные суммы ($target)';
  }

  @override
  String get splitModeLabel => 'Способ деления';

  @override
  String splitModePercent(Object target) {
    return 'Проценты ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Доли ($target)';
  }

  @override
  String get statusConfirmed => 'Подтверждено';

  @override
  String get statusPending => 'Ожидает';

  @override
  String get statusSent => 'Отправлено';

  @override
  String get statusSuggested => 'Предложено';

  @override
  String statusWithValue(Object status) {
    return 'Статус: $status';
  }

  @override
  String get suggestedTransferDirections => 'Предлагаемые направления переводов';

  @override
  String get suggestedTransferFromExpense => 'Предлагаемый перевод по расходу';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предлагаемого перевода',
      many: '$count предлагаемых переводов',
      few: '$count предлагаемых перевода',
      one: '$count предлагаемый перевод',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Плательщик → получатель.';

  @override
  String get suggestedTransfersTitle => 'Предлагаемые переводы';

  @override
  String get summarySettledUp => 'Всё рассчитано';

  @override
  String get summaryYouAreOwed => 'Вам должны';

  @override
  String get summaryYouOwe => 'Вы должны';

  @override
  String get syncAction => 'Синхронизировать';

  @override
  String get syncNowAction => 'Синхронизировать сейчас';

  @override
  String get syncingStatus => 'Синхронизация';

  @override
  String get tapToViewDetails => 'Нажмите, чтобы посмотреть детали';

  @override
  String get themeModeDark => 'Тёмная';

  @override
  String get themeModeDarkSubtitle => 'Мягкая тёмная (не чисто чёрная)';

  @override
  String get themeModeLight => 'Светлая';

  @override
  String get themeModeSystem => 'Системная';

  @override
  String get themeModeSystemSubtitle => 'Как на устройстве';

  @override
  String toDirection(Object name) {
    return 'Кому: $name';
  }

  @override
  String get totalLabel => 'Итого';

  @override
  String get travelerFallbackName => 'Путешественник';

  @override
  String get tripAlreadyClosed => 'Поездка уже закрыта.';

  @override
  String get tripArchivedReadOnly => 'Поездка в архиве. Только просмотр.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Поездка закрыта. Изменять расходы нельзя.';

  @override
  String get tripClosedExpensesReadOnly => 'Поездка закрыта. Расходы доступны только для просмотра.';

  @override
  String get tripClosedRandomDisabled => 'Поездка закрыта. Жребий недоступен.';

  @override
  String tripCreated(Object name) {
    return 'Поездка «$name» создана.';
  }

  @override
  String get tripFinished => 'Поездка завершена.';

  @override
  String get tripFinishedCompleteSettlements => 'Поездка завершена. Завершите расчёты.';

  @override
  String get tripFinishedSettlementStarted => 'Поездка завершена. Расчёты начаты.';

  @override
  String get tripFullySettledArchived => 'Поездка полностью рассчитана и в архиве.';

  @override
  String get tripNameHint => 'Лыжи в Австрии';

  @override
  String get tripNameLabel => 'Название поездки';

  @override
  String get tripNameLengthValidation => 'Название поездки должно содержать минимум 2 символа.';

  @override
  String get tripSnapshotTitle => 'Сводка поездки';

  @override
  String get tripTitleShort => 'Поездка';

  @override
  String tripStatusWithValue(Object status) {
    return 'Статус поездки: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Поездка №$id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Непредвиденная ошибка при загрузке профиля';

  @override
  String get unexpectedErrorLoadingTripData => 'Непредвиденная ошибка при загрузке данных поездки';

  @override
  String get unexpectedErrorLoadingTrips => 'Непредвиденная ошибка при загрузке поездок';

  @override
  String get unexpectedErrorSavingChanges => 'Непредвиденная ошибка при сохранении изменений';

  @override
  String get unexpectedErrorSavingCredentials => 'Непредвиденная ошибка при сохранении данных входа';

  @override
  String get unexpectedErrorUpdatingProfile => 'Непредвиденная ошибка при обновлении профиля';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get unknownLabel => 'Неизвестно';

  @override
  String get unreadLabel => 'Не прочитано';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанного обновления',
      many: '$count непрочитанных обновлений',
      few: '$count непрочитанных обновления',
      one: '$count непрочитанное обновление',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Отсутствует аргумент маршрута поездки.';

  @override
  String userIdLabel(Object id) {
    return 'ID пользователя: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Оплачено $paid  -  Должен $owes  -  Итог $net';
  }

  @override
  String userWithId(Object id) {
    return 'Пользователь $id';
  }

  @override
  String get valueLabel => 'Значение';

  @override
  String get viewAllTrips => 'Все поездки';

  @override
  String get viewByPersonTitle => 'По людям';

  @override
  String get whoOwesWhatSubtitle => 'Кто заплатил и кто должен.';

  @override
  String get whoOwesWhatTitle => 'Кто кому должен';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Кто кому должен: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Расходы, из которых складывается этот перевод.';

  @override
  String get whyPaymentExistsTitle => 'Откуда этот платёж';

  @override
  String get youLabel => 'Вы';

  @override
  String get youSettledForExpense => 'Вы рассчитались за этот расход.';

  @override
  String youShouldPay(Object amount) {
    return 'Вам нужно заплатить $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Вам должны заплатить $amount';
  }

  @override
  String get yourShare => 'Ваша доля';

  @override
  String get yourTrips => 'Ваши поездки';

  @override
  String get authIntroSplitSmarter => 'Делите умнее.';

  @override
  String get authIntroTravelFree => 'Путешествуйте свободно.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Учитывайте общие расходы в разных валютах и рассчитывайтесь сразу, без неловких долгов.';

  @override
  String get authIntroPlanTogether => 'Планируйте вместе.';

  @override
  String get authIntroPayClearly => 'Платите прозрачно.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Создавайте поездки за секунды, добавляйте друзей, и каждый расход будет понятен всем.';

  @override
  String get authIntroSettleFast => 'Рассчитайтесь быстро.';

  @override
  String get authIntroStayFriends => 'Оставайтесь друзьями.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'От общего ужина до целой поездки: с Splyto балансы честные и без стресса.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Не удалось войти через Apple. Повторите попытку.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Не удалось войти через Google. Повторите попытку.';

  @override
  String get authIntroCreateAccount => 'Создайте аккаунт.';

  @override
  String get authIntroChooseSign => 'Выберите способ регистрации.';

  @override
  String get authIntroContinueGoogle => 'Продолжить с Google';

  @override
  String get authIntroContinueApple => 'Продолжить с Apple';

  @override
  String get authIntroBack => 'Назад';

  @override
  String get authIntroSplitSettled => 'Расчёт завершён';

  @override
  String get authIntroParis3Friends => 'Париж · 3 друга';

  @override
  String get authIntroGetStarted => 'Начать';

  @override
  String get authIntroAlreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get authIntroSignIn => 'Войти';

  @override
  String get authIntroSignUpWithEmail => 'Регистрация по эл. почте';

  @override
  String get authIntroOr => 'ИЛИ';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Вход через Google не вернул токен.';

  @override
  String get authAppleSignAvailableIosDevices => 'Вход через Apple доступен на устройствах iOS.';

  @override
  String get authAppleSignNotAvailableDevice => 'Вход через Apple недоступен на этом устройстве.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Вход через Apple не вернул токен.';

  @override
  String get authCancel => 'Отмена';

  @override
  String get authSendLink => 'Отправить ссылку';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'Эл. почта не подтверждена. Введите её, чтобы запросить ссылку для подтверждения.';

  @override
  String get authEmailNotVerified => 'Эл. почта не подтверждена';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Отправить ссылку для подтверждения на $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Ссылка для подтверждения отправлена. Проверьте почту.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Не удалось отправить ссылку для подтверждения. Повторите попытку.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Письмо для подтверждения отправлено. Подтвердите эл. почту перед входом.';

  @override
  String get authVerifyEmail => 'Подтвердите эл. почту';

  @override
  String get authEmailLabel => 'Эл. почта:';

  @override
  String get authClose => 'Закрыть';

  @override
  String get authResendLink => 'Отправить ссылку ещё раз';

  @override
  String get profileAppSettingsSectionTitle => 'НАСТРОЙКИ ПРИЛОЖЕНИЯ';

  @override
  String get profileEmailVerified => 'Подтверждена';

  @override
  String get profileEmailNotVerified => 'Не подтверждена';

  @override
  String get profileEmailSendVerification => 'Отправить ссылку';

  @override
  String get profileEmailVerificationSent => 'Письмо для подтверждения отправлено. Проверьте почту.';

  @override
  String get profileAccountSectionTitle => 'АККАУНТ';

  @override
  String get profileAccountSettings => 'Настройки аккаунта';

  @override
  String get profileChangePhoto => 'Изменить фото профиля';

  @override
  String get profileAppearance => 'Оформление';

  @override
  String get profileThemeDisplayMode => 'Тема и режим отображения';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileDisplayLanguage => 'Язык интерфейса';

  @override
  String get profileNotificationsSectionHeading => 'УВЕДОМЛЕНИЯ';

  @override
  String get profileAppBanners => 'Баннеры в приложении';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Показывать баннеры о новых уведомлениях в приложении';

  @override
  String get profilePushNotificationsTitle => 'Push-уведомления';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Уведомления на телефон о расходах, друзьях, поездках и расчётах';

  @override
  String get profileSupportSectionHeading => 'ПОДДЕРЖКА';

  @override
  String get profileContactUs => 'Связаться с нами';

  @override
  String get profileReportBugSuggestion => 'Сообщить об ошибке / предложение';

  @override
  String get profileRateSplyto => 'Оценить Splyto';

  @override
  String get profileLeaveStoreRating => 'Оставить оценку в магазине';

  @override
  String get profileSecuritySectionHeading => 'БЕЗОПАСНОСТЬ';

  @override
  String get profileAccountAndSecurity => 'Аккаунт и безопасность';

  @override
  String get profileHelpTitle => 'Помощь';

  @override
  String get profileChangePassword => 'Изменить пароль';

  @override
  String get profileUpdateAccountPassword => 'Обновить пароль аккаунта';

  @override
  String get profileDangerZoneSectionHeading => 'ОПАСНАЯ ЗОНА';

  @override
  String get profileManageAccountAccess => 'Управление доступом к аккаунту';

  @override
  String get profileMadeWithLabel => 'Сделано с';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Оценка в магазине будет подключена на следующем этапе.';

  @override
  String get profileFailedSaveNotificationSettings => 'Не удалось сохранить настройки уведомлений.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH-УВЕДОМЛЕНИЯ';

  @override
  String get profileInAppBannersSectionTitle => 'БАННЕРЫ В ПРИЛОЖЕНИИ';

  @override
  String get profileInAppTripMemberAddedTitle => 'Участник добавлен в поездку';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Автоматическое напоминание о расчёте';

  @override
  String get profileExpenseUpdates => 'Обновления расходов';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Баннеры о новых расходах в приложении';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Уведомления о новых расходах на телефон';

  @override
  String get profileFriendInvites => 'Приглашения в друзья';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Баннеры о запросах в друзья и ответах в приложении';

  @override
  String get profileFriendRequestResponseNotifications => 'Уведомления о запросах в друзья и ответах';

  @override
  String get profileTripUpdates => 'Обновления поездок';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Баннеры об этапах поездки и статусе участников в приложении';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Этапы поездки и изменения статуса участников';

  @override
  String get profileSettlementUpdates => 'Обновления расчётов';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Баннеры об отправленных и подтверждённых платежах в приложении';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Обновления об отправленных и подтверждённых платежах';

  @override
  String get profileScreenshotSizeMust8Mb => 'Размер снимка экрана не должен превышать 8 МБ';

  @override
  String get profileFeedbackSendTitle => 'Отправить отзыв';

  @override
  String get profileFeedbackTypeLabel => 'Тип';

  @override
  String get profileFeedbackTypeBug => 'Ошибка';

  @override
  String get profileFeedbackTypeSuggestion => 'Предложение';

  @override
  String get profileDescribeIssueSuggestion => 'Опишите проблему или предложение';

  @override
  String get profilePickingImage => 'Выбор изображения...';

  @override
  String get profileAttachScreenshot => 'Прикрепить снимок экрана';

  @override
  String get profileChangeScreenshot => 'Изменить снимок экрана';

  @override
  String get profileRemoveImage => 'Удалить изображение';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Совет: со снимком экрана мы разберёмся с ошибкой быстрее';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Перед отправкой добавьте описание или снимок экрана';

  @override
  String get profileSendAction => 'Отправить';

  @override
  String get profileThanksFeedbackSent => 'Спасибо! Отзыв отправлен';

  @override
  String get profileFailedSendFeedback => 'Не удалось отправить отзыв';

  @override
  String get profileCouldNotOpenWebsite => 'Не удалось открыть сайт.';

  @override
  String get profileOpenWebsiteQuestion => 'Открыть сайт?';

  @override
  String get profileOpenPortfolioAction => 'Открыть portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Этот формат изображения не поддерживается на устройстве. Выберите JPG или PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Для смены пароля нужна действующая эл. почта аккаунта. Если она отсутствует или неверна, обратитесь в поддержку.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Ссылка для удаления отправлена на вашу эл. почту.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Не удалось отправить ссылку для удаления. Повторите попытку.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Введите текущий пароль, чтобы изменить эл. почту.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Подтверждение отправлено на новый адрес. Уведомление о безопасности отправлено на текущий адрес.';

  @override
  String get profileEditOverviewCurrency => 'Валюта обзора';

  @override
  String get profileEditPaymentMethod => 'Способ оплаты';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Банковский перевод, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Введите пароль (необязательно для Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Отправить ссылку для удаления на эл. почту';

  @override
  String get profileEditBackProfile => 'Назад в профиль';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Перед сменой пароля укажите в профиле действующую эл. почту.';

  @override
  String get profileEditPasswordUpdated => 'Пароль обновлён.';

  @override
  String get profileEditFailedUpdatePassword => 'Не удалось обновить пароль.';

  @override
  String profileEditEmail(Object email) {
    return 'Аккаунт: $email';
  }

  @override
  String get profileEditPrimary => 'Основной';

  @override
  String get profileEditSearchCurrency => 'Поиск валюты';

  @override
  String get profileEditNoCurrenciesFound => 'Валюты не найдены';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Итоги обзора пересчитываются в эту валюту.';

  @override
  String get profileEditPaymentInfoUpdated => 'Платёжные данные обновлены.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Не удалось сохранить платёжные данные. Повторите попытку.';

  @override
  String get profileEditCurrentPassword => 'Текущий пароль';

  @override
  String get profileEditBankTransferIbanSwift => 'Банковский перевод (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'Ссылка paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Выберите способ оплаты';

  @override
  String get profileEditTapChange => 'Нажмите, чтобы изменить';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Для переводов в Великобритании код банка (sort code) содержит 6 цифр, а номер счёта 8 цифр.';

  @override
  String get profileEditPaymentInfo => 'Платёжные данные';

  @override
  String get profileEditSaveDetails => 'Сохранить данные';

  @override
  String get profileEditBankRegion => 'Регион банка';

  @override
  String get profileEditEurope => 'Европа';

  @override
  String get profileEditSortCode => 'Sort code';

  @override
  String get profileEditExample112233 => 'Пример: 112233';

  @override
  String get profileEditNumber => 'Номер счёта';

  @override
  String get profileEdit8Digits => '8 цифр';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Для переводов внутри Великобритании укажите sort code и номер счёта.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Пример: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 или 11 символов';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Имя владельца счёта берётся из полного имени в профиле.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username или username';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Великобритания';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Настроить аватар';

  @override
  String get imageCropperAdjustTripImage => 'Настроить изображение поездки';

  @override
  String get imageCropEditAction => 'Изменить кадрирование';

  @override
  String get imageCropZoomIn => 'Увеличить';

  @override
  String get imageCropZoomOut => 'Уменьшить';

  @override
  String get imageCropZoomOnly => 'Сохранена только обрезанная версия этого фото, поэтому его можно только увеличить.';

  @override
  String get imageCropLoadFailed => 'Не удалось открыть это фото.';

  @override
  String get imageCropSaveFailed => 'Не удалось сохранить новое кадрирование. Повторите попытку.';

  @override
  String get imageCropChanged => 'Это фото тем временем изменилось. Закройте экран и откройте его снова.';

  @override
  String get copyAction => 'Копировать';

  @override
  String get currencyNameEur => 'Евро';

  @override
  String get currencyNameGbp => 'Британский фунт стерлингов';

  @override
  String get currencyNameChf => 'Швейцарский франк';

  @override
  String get currencyNameNok => 'Норвежская крона';

  @override
  String get currencyNameSek => 'Шведская крона';

  @override
  String get currencyNameDkk => 'Датская крона';

  @override
  String get currencyNamePln => 'Польский злотый';

  @override
  String get currencyNameCzk => 'Чешская крона';

  @override
  String get currencyNameHuf => 'Венгерский форинт';

  @override
  String get currencyNameRon => 'Румынский лей';

  @override
  String get currencyNameBgn => 'Болгарский лев';

  @override
  String get currencyNameIsk => 'Исландская крона';

  @override
  String get currencyNameAll => 'Албанский лек';

  @override
  String get currencyNameBam => 'Конвертируемая марка Боснии и Герцеговины';

  @override
  String get currencyNameByn => 'Белорусский рубль';

  @override
  String get currencyNameMdl => 'Молдавский лей';

  @override
  String get currencyNameMkd => 'Македонский денар';

  @override
  String get currencyNameRsd => 'Сербский динар';

  @override
  String get currencyNameUah => 'Украинская гривна';

  @override
  String get currencyNameGel => 'Грузинский лари';

  @override
  String get currencyNameTry => 'Турецкая лира';

  @override
  String get currencyNameUsd => 'Доллар США';

  @override
  String get currencyNameJpy => 'Японская иена';

  @override
  String get currencyNameCny => 'Китайский юань';

  @override
  String get currencyNameCad => 'Канадский доллар';

  @override
  String get currencyNameAud => 'Австралийский доллар';

  @override
  String get currencyNameRub => 'Российский рубль';

  @override
  String get currencyNameMxn => 'Мексиканский песо';

  @override
  String get currencyNameBrl => 'Бразильский реал';

  @override
  String get currencyNameArs => 'Аргентинский песо';

  @override
  String get currencyNameClp => 'Чилийский песо';

  @override
  String get currencyNameCop => 'Колумбийский песо';

  @override
  String get currencyNamePen => 'Перуанский соль';

  @override
  String get currencyNameUyu => 'Уругвайский песо';

  @override
  String get currencyNameBob => 'Боливийский боливиано';

  @override
  String get currencyNamePyg => 'Парагвайский гуарани';

  @override
  String get currencyNameCrc => 'Костариканский колон';

  @override
  String get currencyNameDop => 'Доминиканский песо';

  @override
  String get currencyNameGtq => 'Гватемальский кетсаль';

  @override
  String get currencyNamePab => 'Панамский бальбоа';

  @override
  String get currencyNameHnl => 'Гондурасская лемпира';

  @override
  String get currencyNameNio => 'Никарагуанская кордоба';

  @override
  String get currencyNameJmd => 'Ямайский доллар';

  @override
  String get currencyNameBbd => 'Барбадосский доллар';

  @override
  String get currencyNameBsd => 'Багамский доллар';

  @override
  String get currencyNameTtd => 'Доллар Тринидада и Тобаго';

  @override
  String get currencyNameXcd => 'Восточно-карибский доллар';

  @override
  String get currencyNameBzd => 'Белизский доллар';

  @override
  String get currencyNameAwg => 'Арубанский флорин';

  @override
  String get currencyNameBmd => 'Бермудский доллар';

  @override
  String get currencyNameKyd => 'Доллар Каймановых островов';

  @override
  String get currencyNameKrw => 'Южнокорейская вона';

  @override
  String get currencyNameInr => 'Индийская рупия';

  @override
  String get currencyNameThb => 'Таиландский бат';

  @override
  String get currencyNameVnd => 'Вьетнамский донг';

  @override
  String get currencyNameIdr => 'Индонезийская рупия';

  @override
  String get currencyNameMyr => 'Малайзийский ринггит';

  @override
  String get currencyNameSgd => 'Сингапурский доллар';

  @override
  String get currencyNamePhp => 'Филиппинский песо';

  @override
  String get currencyNameHkd => 'Гонконгский доллар';

  @override
  String get currencyNameTwd => 'Новый тайваньский доллар';

  @override
  String get currencyNameLkr => 'Шри-ланкийская рупия';

  @override
  String get currencyNameNpr => 'Непальская рупия';

  @override
  String get currencyNameBdt => 'Бангладешская така';

  @override
  String get currencyNamePkr => 'Пакистанская рупия';

  @override
  String get currencyNameKhr => 'Камбоджийский риель';

  @override
  String get currencyNameLak => 'Лаосский кип';

  @override
  String get currencyNameMmk => 'Мьянманский кьят';

  @override
  String get currencyNameMnt => 'Монгольский тугрик';

  @override
  String get currencyNameMop => 'Патака Макао';

  @override
  String get currencyNameBnd => 'Брунейский доллар';

  @override
  String get currencyNameMvr => 'Мальдивская руфия';

  @override
  String get currencyNameBtn => 'Бутанский нгултрум';

  @override
  String get currencyNameKzt => 'Казахстанский тенге';

  @override
  String get currencyNameUzs => 'Узбекский сум';

  @override
  String get currencyNameKgs => 'Киргизский сом';

  @override
  String get currencyNameTjs => 'Таджикский сомони';

  @override
  String get currencyNameAzn => 'Азербайджанский манат';

  @override
  String get currencyNameAmd => 'Армянский драм';

  @override
  String get currencyNameAed => 'Дирхам ОАЭ';

  @override
  String get currencyNameSar => 'Саудовский риял';

  @override
  String get currencyNameQar => 'Катарский риал';

  @override
  String get currencyNameOmr => 'Оманский риал';

  @override
  String get currencyNameKwd => 'Кувейтский динар';

  @override
  String get currencyNameBhd => 'Бахрейнский динар';

  @override
  String get currencyNameJod => 'Иорданский динар';

  @override
  String get currencyNameIls => 'Новый израильский шекель';

  @override
  String get currencyNameLbp => 'Ливанский фунт';

  @override
  String get currencyNameIqd => 'Иракский динар';

  @override
  String get currencyNameZar => 'Южноафриканский рэнд';

  @override
  String get currencyNameEgp => 'Египетский фунт';

  @override
  String get currencyNameMad => 'Марокканский дирхам';

  @override
  String get currencyNameTnd => 'Тунисский динар';

  @override
  String get currencyNameDzd => 'Алжирский динар';

  @override
  String get currencyNameKes => 'Кенийский шиллинг';

  @override
  String get currencyNameTzs => 'Танзанийский шиллинг';

  @override
  String get currencyNameUgx => 'Угандийский шиллинг';

  @override
  String get currencyNameRwf => 'Франк Руанды';

  @override
  String get currencyNameEtb => 'Эфиопский быр';

  @override
  String get currencyNameGhs => 'Ганский седи';

  @override
  String get currencyNameNgn => 'Нигерийская найра';

  @override
  String get currencyNameXof => 'Франк КФА ВСЕАО';

  @override
  String get currencyNameXaf => 'Франк КФА ВЕАС';

  @override
  String get currencyNameMur => 'Маврикийская рупия';

  @override
  String get currencyNameScr => 'Сейшельская рупия';

  @override
  String get currencyNameNad => 'Доллар Намибии';

  @override
  String get currencyNameBwp => 'Ботсванская пула';

  @override
  String get currencyNameZmw => 'Замбийская квача';

  @override
  String get currencyNameMzn => 'Мозамбикский метикал';

  @override
  String get currencyNameAoa => 'Ангольская кванза';

  @override
  String get currencyNameMga => 'Малагасийский ариари';

  @override
  String get currencyNameCve => 'Эскудо Кабо-Верде';

  @override
  String get currencyNameGmd => 'Гамбийский даласи';

  @override
  String get currencyNameNzd => 'Новозеландский доллар';

  @override
  String get currencyNameFjd => 'Доллар Фиджи';

  @override
  String get currencyNameXpf => 'Французский тихоокеанский франк';

  @override
  String get currencyNameWst => 'Самоанская тала';

  @override
  String get currencyNameVuv => 'Вату Вануату';

  @override
  String get currencyNameTop => 'Тонганская паанга';

  @override
  String get currencyNamePgk => 'Кина Папуа — Новой Гвинеи';

  @override
  String get expenseCategoryFood => 'Еда';

  @override
  String get expenseCategoryGroceries => 'Продукты';

  @override
  String get expenseCategoryFuel => 'Топливо';

  @override
  String get expenseCategoryTransport => 'Транспорт';

  @override
  String get expenseCategoryAccommodation => 'Жильё';

  @override
  String get expenseCategoryActivities => 'Развлечения';

  @override
  String get expenseCategoryTickets => 'Билеты';

  @override
  String get expenseCategoryShopping => 'Покупки';

  @override
  String get expenseCategoryParty => 'Вечеринка';

  @override
  String get expenseCategoryParking => 'Парковка';

  @override
  String get expenseCategoryOther => 'Другое';

  @override
  String get shellTripAlreadyInListOpened => 'Поездка уже в вашем списке. Мы её открыли.';

  @override
  String get shellJoinedTripFromInviteLink => 'Вы присоединились к поездке по ссылке-приглашению.';

  @override
  String get shellFailedToOpenInviteLink => 'Не удалось открыть ссылку-приглашение.';

  @override
  String get shellFailedToOpenFriendLink => 'Не удалось открыть ссылку друга.';

  @override
  String get shellTripInviteTitle => 'Приглашение в поездку';

  @override
  String get shellNoAction => 'Нет';

  @override
  String get shellYesAction => 'Да';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Удалить поездку может только её создатель.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Удалять можно только активные поездки.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Удалить «$tripLabel»? Это возможно только до добавления расходов.';
  }

  @override
  String get shellTripDeleted => 'Поездка удалена.';

  @override
  String get shellFailedToDeleteTrip => 'Не удалось удалить поездку.';

  @override
  String get shellFailedToLoadNotifications => 'Не удалось загрузить уведомления.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Новое уведомление: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Не удалось обновить уведомления.';

  @override
  String get shellMarkAllAsReadAction => 'Отметить все как прочитанные';

  @override
  String get shellNewSection => 'Новые';

  @override
  String get shellEarlierSection => 'Ранее';

  @override
  String get shellShowMoreEarlierAction => 'Показать ещё';

  @override
  String get shellLoadingMore => 'Загрузка...';

  @override
  String get shellLoadMoreNotificationsAction => 'Загрузить ещё уведомления';

  @override
  String get shellTripNoLongerAvailable => 'Эта поездка больше недоступна.';

  @override
  String get shellFailedToOpenTrip => 'Не удалось открыть поездку.';

  @override
  String get shellYesterday => 'Вчера';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Вы уже участник поездки «$tripName». Открыть её?\n\nПриглашение от: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Присоединиться к поездке «$tripName»?\n\nПриглашение от: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Выбрано изображение: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Изображение поездки уже задано.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Поездка создана, но изображение не загрузилось.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Поездка создана, но изображение не загрузилось: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Присоединиться по приглашению';

  @override
  String get tripsTotalTrips => 'Всего поездок';

  @override
  String get tripsTotalSpent => 'Всего потрачено';

  @override
  String get tripsMixedCurrencies => 'Разные валюты';

  @override
  String get tripsShowActive => 'Показать активные';

  @override
  String get tripsSeeAll => 'Все';

  @override
  String get tripsGridView => 'Сетка';

  @override
  String get tripsListView => 'Список';

  @override
  String get tripsAddNewTrip => 'Добавить поездку';

  @override
  String get tripsLoadMore => 'Загрузить ещё';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Удалить «$arg1»? Это возможно только до добавления расходов.';
  }

  @override
  String get tripsTripDates => 'Даты поездки';

  @override
  String get tripsFrom => 'С';

  @override
  String get tripsSelectDate => 'Выберите дату';

  @override
  String get tripsTo => 'По';

  @override
  String get tripsMainCurrency => 'Основная валюта';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Выберите даты начала и окончания поездки.';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Дата окончания не может быть раньше даты начала.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Неверный формат периода поездки. Выберите даты ещё раз.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Вы уже участник этой поездки.';

  @override
  String get tripsJoinedTripSuccessfully => 'Вы присоединились к поездке.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Не удалось присоединиться к поездке по приглашению.';

  @override
  String get tripsJoinTrip => 'Присоединиться к поездке';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Вставьте ссылку-приглашение или код приглашения.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Введите действительную ссылку или код приглашения.';

  @override
  String get tripsClipboardIsEmpty => 'Буфер обмена пуст.';

  @override
  String get tripsPaste => 'Вставить';

  @override
  String get tripsJoin => 'Присоединиться';

  @override
  String get workspaceTripMembers => 'Участники поездки';

  @override
  String get workspaceFailedToLoadFriends => 'Не удалось загрузить друзей.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Не удалось создать ссылку-приглашение.';

  @override
  String get workspaceInviteLink => 'Ссылка-приглашение';

  @override
  String get workspaceGeneratingInviteLink => 'Создаём ссылку-приглашение...';

  @override
  String get workspaceInviteLinkUnavailable => 'Ссылка-приглашение недоступна.';

  @override
  String get workspaceCopyInviteLink => 'Скопировать ссылку-приглашение';

  @override
  String get workspaceInviteLinkCopied => 'Ссылка-приглашение скопирована.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Действует до: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Нет доступных друзей. Сначала добавьте друзей.';

  @override
  String get workspaceSettle => 'Рассчитаться';

  @override
  String get workspaceOwesToTheGroup => 'Должен группе';

  @override
  String get workspaceGetsBackFromGroup => 'Группа должна вернуть';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Показаны 4 участника с наибольшей разницей баланса.';

  @override
  String get workspaceOpenFlow => 'Подробнее';

  @override
  String get workspaceFriend => 'Друг';

  @override
  String get workspaceSettlementTransfer => 'Перевод для расчёта';

  @override
  String get workspaceCompleted => 'Завершено';

  @override
  String get workspaceWaitingForConfirmation => 'Ожидает подтверждения';

  @override
  String get workspaceWaitingForPayment => 'Ожидает оплаты';

  @override
  String get workspaceActionNeeded => 'Требуется действие';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Отметить как отправленные: $arg1. Подтвердить получение: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Готов к расчётам';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Все участники готовы. Можно начинать расчёты.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Ждём, пока все отметят готовность.';

  @override
  String get workspaceIMReady => 'Я готов(а)';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Подтвердите, что добавили все свои расходы.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Кнопка завершения станет доступна, когда все отметят готовность.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Группа должна вернуть';

  @override
  String get workspaceSettledWithTheGroup => 'Рассчитан(а) с группой';

  @override
  String get workspaceTotalPaid => 'Всего оплачено';

  @override
  String get workspaceTotalOwes => 'Всего должен';

  @override
  String get workspaceTransactionHistory => 'История операций';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'У этого участника пока нет операций.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Расчёты: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Перед началом расчётов все участники должны отметить готовность.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Вы отметили готовность к расчётам.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Отметка о готовности снята.';

  @override
  String get workspaceReminderSent => 'Напоминание отправлено.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Ссылка-приглашение или добавление из друзей';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Изменять поездку может только её создатель.';

  @override
  String get workspaceTripUpdated => 'Поездка обновлена.';

  @override
  String get workspaceFailedToUpdateTrip => 'Не удалось обновить поездку.';

  @override
  String get workspaceNoMembersSelectedYet => 'Участники пока не выбраны.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Нет интернета. Расход будет сохранён без изображения чека.';

  @override
  String get workspaceRandomPicker => 'Случайный выбор';

  @override
  String get workspaceCurrency => 'Валюта';

  @override
  String get workspaceCategory => 'Категория';

  @override
  String get workspaceCustomCategory => 'Своя категория';

  @override
  String get workspaceCategoryName => 'Название категории';

  @override
  String get workspaceApartmentRentParkingEtc => 'Аренда квартиры, парковка и т. д.';

  @override
  String get workspaceEnterACustomCategory => 'Введите свою категорию.';

  @override
  String get workspacePickAnExpenseCategory => 'Выберите категорию расхода.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Категория должна содержать минимум 2 символа.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Категория должна содержать не более 64 символов.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Сумма процентов должна быть 100%.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Доли всех участников должны быть больше 0.';

  @override
  String get workspaceTotalAmount => 'Общая сумма';

  @override
  String get workspaceOriginal => 'Исходная';

  @override
  String get workspaceTotalCost => 'Общая стоимость';

  @override
  String workspaceStarted(Object arg1) {
    return 'Начало: $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Окончание: $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Поездка в архиве';

  @override
  String get workspaceActiveTrip => 'Активная поездка';

  @override
  String get workspaceMemberProfile => 'Профиль участника';

  @override
  String get workspaceTripOwner => 'Владелец поездки';

  @override
  String get workspaceMember => 'Участник';

  @override
  String get workspaceReadyForSettlement => 'Готов к расчётам';

  @override
  String get workspaceNotReadyForSettlement => 'Не готов к расчётам';

  @override
  String get workspaceBankDetails => 'Банковские реквизиты';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN и реквизиты для выплат появятся здесь в следующем обновлении.';

  @override
  String get workspacePaymentDetails => 'Платёжные реквизиты';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Этот участник ещё не добавил реквизиты для выплат.';

  @override
  String get workspaceBankTransfer => 'Банковский перевод';

  @override
  String get workspaceHolder => 'Владелец';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Не удалось открыть платёжную ссылку.';

  @override
  String get workspaceTripActivity => 'Активность в поездке';

  @override
  String get workspacePaidExpenses => 'Оплаченные расходы';

  @override
  String get workspacePaidTotal => 'Всего оплачено';

  @override
  String get workspaceInvolvedIn => 'Участвует в';

  @override
  String get workspaceCurrentTrip => 'Текущая поездка';

  @override
  String get workspaceCommonTrips => 'Общие поездки';

  @override
  String get workspaceLoadingCommonTrips => 'Загружаем общие поездки...';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Общих поездок пока нет.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Не удалось загрузить все общие поездки. Показана текущая.';

  @override
  String get workspaceMembers => 'участников';

  @override
  String get workspaceExpense => 'Расход';

  @override
  String get workspacePaid => 'оплачено';

  @override
  String get workspaceLoadingMoreExpenses => 'Загружаем ещё расходы...';

  @override
  String get workspaceScrollDownToLoadMore => 'Прокрутите вниз, чтобы загрузить ещё';

  @override
  String get workspaceTripFinished => 'Поездка завершена';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Расчёты для этой поездки открыты.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Завершите поездку, чтобы начать расчёты.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1: перевод отмечен как отправленный.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Ждём, пока $arg1 отметит оплату.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1: получение платежа подтверждено.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Ждём подтверждения от $arg1.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Все расчёты поездки полностью завершены.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Итоговое состояние после подтверждения всех переводов.';

  @override
  String get workspaceSettlementFlow => 'Ход расчётов';

  @override
  String get workspaceActions => 'Действия';

  @override
  String get workspaceQuickPay => 'Быстрая оплата';

  @override
  String get workspacePayWithRevolut => 'Оплатить через Revolut';

  @override
  String get workspacePayWithPaypal => 'Оплатить через PayPal';

  @override
  String get workspacePayWithWise => 'Оплатить через Wise';

  @override
  String get workspaceTransferIsConfirmed => 'Перевод подтверждён.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Ждём, пока другой участник выполнит следующий шаг.';

  @override
  String get workspaceSendReminder => 'Отправить напоминание';

  @override
  String get workspaceInProgress => 'В процессе';

  @override
  String get workspaceTimeUnknown => 'Время неизвестно';

  @override
  String get workspaceRemind => 'Напомнить';

  @override
  String get workspaceYourPosition => 'Ваша позиция';

  @override
  String get workspaceRecentActivity => 'Недавняя активность';

  @override
  String get workspaceNoRecentActivityYet => 'Недавней активности пока нет.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Добавьте хотя бы одного участника, чтобы делить расходы.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Отметьте готовность к расчётам, когда добавите все свои расходы.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Участников, ещё не отметивших готовность: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Все участники готовы. Можно завершить поездку и начать расчёты.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Все участники готовы. Ждём, пока владелец поездки начнёт расчёты.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Идут расчёты: подтверждено $arg1 из $arg2.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Действий не требуется. Поездка рассчитана.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Сейчас действий не требуется.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Вам должны заплатить $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Вам нужно заплатить $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Сейчас у вас нет долгов в этой поездке.';

  @override
  String get workspaceUnknownTime => 'Неизвестное время';

  @override
  String get workspaceJustNow => 'Только что';

  @override
  String workspaceMinAgo(Object arg1) {
    return '$arg1 мин назад';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return '$arg1 ч назад';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return '$arg1 дн. назад';
  }

  @override
  String get friendsRemoveFriend => 'Удалить из друзей';

  @override
  String get friendsRemoveThisFriend => 'Удалить этого друга?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 будет удалён(а) из списка друзей. Позже можно добавить снова.';
  }

  @override
  String get friendsContinue => 'Продолжить';

  @override
  String get friendsFriendRemoved => 'Друг удалён.';

  @override
  String get friendsCouldNotRemoveFriend => 'Не удалось удалить друга.';

  @override
  String get friendsFriendProfile => 'Профиль друга';

  @override
  String get friendsMoreActions => 'Другие действия';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Этот друг ещё не добавил реквизиты для выплат.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Сейчас не удалось загрузить общие поездки.';

  @override
  String get friendsFinished => 'Завершена';

  @override
  String friendsTrip(Object arg1) {
    return 'Поездка №$arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Участников: $arg1';
  }

  @override
  String get friendsNoDate => 'Без даты';

  @override
  String get friendsIncomingRequests => 'ВХОДЯЩИЕ ЗАПРОСЫ';

  @override
  String get friendsSentInvites => 'ОТПРАВЛЕННЫЕ ПРИГЛАШЕНИЯ';

  @override
  String get friendsMyFriends => 'МОИ ДРУЗЬЯ';

  @override
  String get friendsRequests => 'Запросы';

  @override
  String get friendsIncoming => 'Входящие';

  @override
  String get friendsIncomingRequestSubtitle => 'хочет добавить вас в друзья';

  @override
  String get friendsOutgoingInviteSubtitle => 'Приглашение отправлено';

  @override
  String get friendsNoPendingActivity => 'Нет запросов в друзья';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Приглашение отправлено: $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Нет входящих запросов';

  @override
  String get friendsDecline => 'Отклонить';

  @override
  String get friendsAccept => 'Принять';

  @override
  String get friendsNoSentInvites => 'Нет отправленных приглашений';

  @override
  String get friendsNoFriendsYet => 'Друзей пока нет';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Прокрутите вниз, чтобы загрузить ещё друзей.';

  @override
  String get friendsUser => 'Пользователь';

  @override
  String get friendsSearchUsers => 'Поиск пользователей';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Найдите по имени или эл. почте и отправьте приглашение';

  @override
  String get friendsScanQr => 'Сканировать QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Отсканируйте код другого пользователя, чтобы добавить в друзья';

  @override
  String get friendsMyQr => 'Мой QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Покажите QR-код или поделитесь им';

  @override
  String get friendsScanFriendQrTitle => 'Сканировать QR друга';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Поместите QR-код друга в рамку';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Удерживайте QR-код в рамке';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Добавить $arg1 в друзья?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 получит ваш запрос в друзья.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Принять запрос в друзья от $arg1?';
  }

  @override
  String get friendsMyFriendQrTitle => 'Мой QR-код для друзей';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Отсканируйте этот QR-код или поделитесь ссылкой, чтобы добавить меня в Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Добавьте меня в Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Ссылка для добавления в друзья в Splyto';

  @override
  String get shareAction => 'Поделиться';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'Этот QR-код не является кодом друга.';

  @override
  String get friendsYouCannotAddYourself => 'Нельзя добавить самого себя.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Этот пользователь уже в вашем списке друзей.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Приглашение этому пользователю уже отправлено.';

  @override
  String get friendsFriendRequestProcessed => 'Запрос в друзья обработан.';

  @override
  String get friendsFailedToProcessFriendQr => 'Не удалось обработать QR-код друга.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Не удалось загрузить ваш профиль.';

  @override
  String get friendsMyProfile => 'Мой профиль';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Непредвиденная ошибка при загрузке друзей.';

  @override
  String get friendsFriendAdded => 'Друг добавлен.';

  @override
  String get friendsRequestDeclined => 'Запрос отклонён.';

  @override
  String get friendsFailedToUpdateRequest => 'Не удалось обновить запрос.';

  @override
  String get friendsCancelInvite => 'Отменить приглашение';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Отменить приглашение для $arg1?';
  }

  @override
  String get friendsKeep => 'Оставить';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Приглашение для $arg1 отменено.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Не удалось отменить приглашение.';

  @override
  String get analyticsOther => 'Другое';

  @override
  String get analyticsSelectATripForAnalytics => 'Выберите поездку для аналитики';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • участников: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Расходы по дням';

  @override
  String get analyticsMyDaily => 'Мои за день';

  @override
  String get analyticsGroupDaily => 'Группа за день';

  @override
  String get analyticsByMember => 'По участникам';

  @override
  String get analyticsShowLess => 'Свернуть';

  @override
  String get analyticsByCategory => 'По категориям';

  @override
  String get analyticsQuickInsights => 'Коротко о главном';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Самый большой расход: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Больше всех потратил(а): $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Самый дорогой день группы: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Без дат';

  @override
  String get friendsSearchFailedTryAgain => 'Поиск не удался. Повторите попытку.';

  @override
  String get friendsFailedToSendInvite => 'Не удалось отправить приглашение.';

  @override
  String get friendsAddFriend => 'Добавить друга';

  @override
  String get friendsSearchByNameOrEmail => 'Поиск по имени или эл. почте';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Для поиска введите минимум 2 символа.';

  @override
  String get friendsNoUsersFound => 'Пользователи не найдены';

  @override
  String get friendsInviteAction => 'Пригласить';

  @override
  String get workspacePaidForGroup => 'Оплачено за группу';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Оплачено за группу • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Доля расхода';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Доля расхода • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Имя владельца скопировано.';

  @override
  String get paymentIbanCopied => 'IBAN скопирован.';

  @override
  String get paymentSwiftCopied => 'SWIFT скопирован.';

  @override
  String get paymentRevtagCopied => 'Revtag скопирован.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Не удалось скопировать в буфер обмена.';

  @override
  String get paymentCopied => 'Скопировано.';

  @override
  String get paymentRequestAction => 'Запросить платёж';

  @override
  String get paymentRecordAction => 'Записать платёж';

  @override
  String get paymentRequestSheetTitle => 'Запросить платёж';

  @override
  String get paymentRecordSheetTitle => 'Записать платёж';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Попросите $arg1 оплатить сумму, которую вам сейчас должны.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Используйте это после оплаты $arg1 вне Splyto. Получатель подтвердит поступление.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Максимум $arg1';
  }

  @override
  String get paymentNoteHint => 'Банковский перевод, Revolut, наличные...';

  @override
  String get paymentAmountPositiveError => 'Сумма должна быть больше нуля.';

  @override
  String get paymentAmountTooHighError => 'Сумма не может превышать остаток долга.';

  @override
  String get paymentRequestCreated => 'Запрос на платёж отправлен.';

  @override
  String get paymentRecordedWaiting => 'Платёж записан. Ожидает подтверждения.';

  @override
  String get paymentConfirmTitle => 'Подтвердить платёж';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Подтвердите, что получили $arg1 от $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Платёж подтверждён.';

  @override
  String get paymentCancelRecordTitle => 'Отменить запись о платеже';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Отменить отметку о платеже $arg1 для $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Запись о платеже отменена.';

  @override
  String get paymentNotReceivedTitle => 'Платёж не получен';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Отметить платёж $arg1 от $arg2 как не полученный?';
  }

  @override
  String get paymentMarkedNotReceived => 'Платёж отмечен как не полученный.';

  @override
  String get paymentActivityTitle => 'Операции по платежам';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Открытых запросов на платёж: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Платежей ожидают подтверждения: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Записанные платежи';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 запрашивает платёж у $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 → $arg2: оплачено';
  }

  @override
  String get paymentRequestPendingStatus => 'Платёж запрошен';

  @override
  String get paymentAwaitingConfirmationStatus => 'Ожидает подтверждения';

  @override
  String get paymentReviewRequestAction => 'Посмотреть запрос';

  @override
  String get paymentViewDetailsAction => 'Детали платежа';

  @override
  String get paymentMarkPaidAction => 'Я оплатил(а)';

  @override
  String get paymentDeclineAction => 'Отклонить';

  @override
  String get paymentRequestReviewTitle => 'Запрос на платёж';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 запрашивает у вас $arg2. Оплатите вне Splyto, затем отметьте как оплаченное.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Отметить запрос как оплаченный?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Подтверждайте только после оплаты $arg1 для $arg2 вне Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Отмечено как оплаченное. Ожидает подтверждения.';

  @override
  String get paymentRequestCancelTitle => 'Отменить запрос на платёж?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Отменить ваш запрос на $arg1 к $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Запрос на платёж отменён.';

  @override
  String get paymentRequestDeclineTitle => 'Отклонить запрос на платёж?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Отклонить запрос на $arg1 от $arg2? Отправитель получит уведомление.';
  }

  @override
  String get paymentRequestDeclined => 'Запрос на платёж отклонён.';

  @override
  String get paymentPendingBeforeFinish => 'Перед итоговым расчётом закройте открытые запросы и неподтверждённые платежи.';

  @override
  String get paymentFinishBlockedByPending => 'Завершение станет доступно, когда все запросы и неподтверждённые платежи будут закрыты.';

  @override
  String get notificationPaymentRequestedTitle => 'Запрос на платёж';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 запрашивает у вас $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Вы получили запрос на платёж.';

  @override
  String get notificationPaymentRequestSentTitle => 'Запрошенный платёж отправлен';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 отмечает ваш запрос на $arg2 как оплаченный.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Ваш запрос на платёж отмечен как оплаченный.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Запрос на платёж отменён';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 отменяет запрос на платёж $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Запрос на платёж отменён.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Запрос на платёж отклонён';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 отклоняет ваш запрос на платёж $arg2.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Ваш запрос на платёж отклонён.';

  @override
  String get notificationPaymentSentTitle => 'Платёж отмечен как отправленный';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 отмечает $arg2 как оплаченное вам.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Платёж вам отмечен как отправленный.';

  @override
  String get notificationPaymentConfirmedTitle => 'Платёж подтверждён';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 подтверждает получение $arg2 от вас.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Ваш платёж подтверждён.';

  @override
  String get notificationPaymentCancelledTitle => 'Платёж отменён';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 отменяет отметку о платеже $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Отметка о платеже отменена.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Платёж не получен';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 отмечает платёж $arg2 как не полученный.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Платёж отмечен как не полученный.';

  @override
  String get quickStartTitle => 'Быстрый старт';

  @override
  String get quickStartCreateTitle => 'Одному или с друзьями';

  @override
  String get quickStartCreateBody => 'Создайте поездку для себя или группы. Добавляйте друзей по ссылке или QR-коду и приглашайте их.';

  @override
  String get quickStartInviteTitle => 'Вместе или в одиночку';

  @override
  String get quickStartInviteBody => 'Пригласите друзей в поездку или начните личную поездку самостоятельно.';

  @override
  String get quickStartExpenseTitle => 'Расходы в разных валютах';

  @override
  String get quickStartExpenseBody => 'Выберите, кто заплатил и как разделить. Другие валюты пересчитываются по курсу на дату покупки, даже если вы добавите расход позже.';

  @override
  String get quickStartSettleTitle => 'Рассчитывайтесь легко';

  @override
  String get quickStartSettleBody => 'Смотрите, кто кому должен, платите удобным способом и подтверждайте в приложении.';

  @override
  String get quickStartAnalyticsTitle => 'Бюджет и расходы';

  @override
  String get quickStartAnalyticsBody => 'Задайте бюджет для поездки или группы и смотрите расходы по категориям, поездкам и дням.';

  @override
  String get quickStartMapTitle => 'Сохраняйте свои места';

  @override
  String get quickStartMapBody => 'Добавляйте города, где вы были, на личную карту путешествий. Её видите только вы.';

  @override
  String get quickStartLiveTitle => 'Находите друг друга';

  @override
  String get quickStartLiveBody => 'В групповых поездках делитесь геопозицией на выбранное время. Её видят участники поездки, а остановить можно в любой момент.';

  @override
  String get quickStartNext => 'Далее';

  @override
  String get quickStartBack => 'Назад';

  @override
  String get quickStartSkip => 'Пропустить';

  @override
  String get quickStartCreateAction => 'Создать поездку';

  @override
  String get quickStartSignUpAction => 'Зарегистрироваться';

  @override
  String get quickStartClose => 'Закрыть быстрый старт';

  @override
  String get quickStartSubtitle => 'Как работают поездки и расходы';

  @override
  String quickStartStep(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get workspaceTripTotal => 'Итого за поездку';

  @override
  String get workspacePersonalTotal => 'Всего потрачено';

  @override
  String get workspaceBalanceEven => 'Ваш баланс на нуле';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Вы должны $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Вам вернут $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Участников: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Поиск расходов';

  @override
  String get workspaceClearSearch => 'Очистить поиск';

  @override
  String get workspaceSearchLoadedHint => 'Поиск идёт по загруженным расходам. Загрузите ещё, чтобы включить более старые.';

  @override
  String get workspaceNoExpenseMatches => 'Подходящих расходов нет';

  @override
  String get workspaceNoExpenseMatchesBody => 'Измените запрос или очистите его, чтобы увидеть все загруженные расходы.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Добавьте первый расход, чтобы начать учёт трат.';

  @override
  String get workspaceEmptyGroupExpenses => 'Добавьте первый общий расход, чтобы увидеть долю каждого.';

  @override
  String get workspaceLoadMoreExpenses => 'Загрузить ещё расходы';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Исходная сумма: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Комментариев: $count';
  }

  @override
  String get workspaceExpenseActions => 'Действия с расходом';

  @override
  String get workspaceLoadErrorTitle => 'Не удалось загрузить поездку';

  @override
  String get workspaceCachedWarning => 'Показаны сохранённые данные. Они могут быть устаревшими.';

  @override
  String get workspaceActivityTab => 'Активность';

  @override
  String get workspaceLoadingTrip => 'Загрузка поездки';

  @override
  String get workspaceRefreshFailed => 'Не удалось обновить';

  @override
  String get expenseDetailsTitle => 'Детали расхода';

  @override
  String get expenseQuickCategories => 'Быстрые категории';

  @override
  String get expenseReceiptRead => 'Чек распознан, форма обновлена.';

  @override
  String get expenseReceiptNoData => 'Чек прикреплён. Сумма, дата или продавец чётко не определены.';

  @override
  String get expenseReceiptScanFailed => 'Чек выбран. Автораспознавание не удалось, проверьте поля вручную.';

  @override
  String get expenseReceiptOffline => 'Чек загрузится при сохранении. Для автораспознавания нужно подключение.';

  @override
  String get expenseReadingReceipt => 'Распознаём чек…';

  @override
  String get expenseCommentsLoadFailed => 'Не удалось загрузить комментарии. Повторите попытку.';

  @override
  String get expenseReplyAction => 'Ответить';

  @override
  String get expenseReplyHint => 'Напишите ответ…';

  @override
  String expenseReplyTo(String name) {
    return 'Ответ для $name';
  }

  @override
  String get balanceEmptyBody => 'Балансы появятся после добавления расходов.';

  @override
  String get balanceAfterPayments => 'Балансы учитывают подтверждённые платежи.';

  @override
  String get balanceExpenseShare => 'Доля расхода';

  @override
  String get balanceHistoryScope => 'Загруженные расходы и подтверждённые платежи. В списке может быть не вся история поездки.';

  @override
  String balancePaymentTo(String name) {
    return 'Платёж для $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Платёж от $name';
  }

  @override
  String get settlementEmptyActive => 'Перед началом итоговых расчётов все должны отметить готовность.';

  @override
  String get settlementEmptyClosed => 'Для этой поездки переводов нет.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return 'Подтверждено переводов: $count из $total';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return 'Готовы участники: $count из $total';
  }

  @override
  String get settlementMemberReady => 'Готов';

  @override
  String get settlementMemberNotReady => 'Не готов';

  @override
  String get settlementSuggested => 'Предлагаемый перевод';

  @override
  String get activityLoadFailed => 'Не удалось обновить активность. Показанные записи могут быть устаревшими.';

  @override
  String get activityMember => 'Участник поездки';

  @override
  String get friendsEmptyBody => 'Найдите друга по имени или эл. почте либо используйте QR-код.';

  @override
  String get friendsDeclineAction => 'Отклонить';

  @override
  String get friendsLoading => 'Загрузка друзей';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Общих поездок: $count';
  }

  @override
  String get memberActivityScope => 'На основе загруженных расходов; возможно, это не вся поездка.';

  @override
  String get sharedTripsLoadedLimit => 'Показано до 20 общих поездок.';

  @override
  String get memberRemoveTitle => 'Удалить участника?';

  @override
  String memberRemoveBody(String name) {
    return 'Удалить $name из поездки? Это возможно, только если у участника нет расходов, расчётов и баланса.';
  }

  @override
  String get memberRemoveAction => 'Удалить из поездки';

  @override
  String memberRemoved(String name) {
    return '$name: удаление из поездки выполнено.';
  }

  @override
  String get profilePaymentNotAdded => 'Ещё не добавлено';

  @override
  String get friendRelationshipLabel => 'Друг';

  @override
  String get sharedTripsEmptyBody => 'Здесь появятся поездки, в которых вы оба участвуете.';

  @override
  String get analyticsAllTrips => 'Все поездки';

  @override
  String get analyticsByTrip => 'По поездкам';

  @override
  String get analyticsYourSpending => 'Ваши расходы';

  @override
  String get analyticsActiveArchived => 'Активные и архивные поездки';

  @override
  String get analyticsTrips => 'Поездки';

  @override
  String get analyticsAveragePerTrip => 'В среднем за поездку';

  @override
  String get analyticsPaidByMember => 'Оплачено участниками';

  @override
  String get analyticsYouPaid => 'Вы заплатили';

  @override
  String get analyticsYouGetBack => 'Вам вернут';

  @override
  String get analyticsYouOwe => 'Вы должны';

  @override
  String get analyticsParticipants => 'Участники';

  @override
  String get analyticsYourCategories => 'Ваши расходы по категориям';

  @override
  String get analyticsLargestShares => 'Ваши самые большие доли';

  @override
  String get analyticsLargestExpenses => 'Самые большие расходы';

  @override
  String get analyticsSpendingByTrip => 'Ваши расходы по поездкам';

  @override
  String get analyticsEmptyTitle => 'Расходов пока нет';

  @override
  String get analyticsEmptyBody => 'Ваши расходы появятся здесь, когда вы добавите их в поездку.';

  @override
  String get analyticsPeriodEmptyBody => 'Для этого вида нет расходов. Выберите другую поездку или период.';

  @override
  String get analyticsLoadFailed => 'Не удалось загрузить полный отчёт о расходах. Повторите попытку.';

  @override
  String get analyticsLastLoaded => 'Показан последний успешно загруженный отчёт.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count расхода',
      many: '$count расходов',
      few: '$count расхода',
      one: '$count расход',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Параметры поездки';

  @override
  String get editTripAction => 'Изменить поездку';

  @override
  String get deleteTripAction => 'Удалить поездку';

  @override
  String get inviteTripMembersAction => 'Пригласить участников';

  @override
  String get tripCoverPhoto => 'Обложка';

  @override
  String get tripInviteLaterHint => 'Пригласить людей можно после создания поездки.';

  @override
  String get inviteClipboardFailed => 'Нет доступа к буферу обмена. Повторите попытку.';

  @override
  String get friendInviteToTrip => 'Пригласить в поездку';

  @override
  String get friendChooseTrip => 'Выберите поездку';

  @override
  String get friendNoInvitableTrips => 'Нет доступных поездок. Друзей можно приглашать в активные групповые поездки, которыми вы управляете, если они ещё не участники и у них нет ожидающего приглашения.';

  @override
  String get friendTripInviteSent => 'Приглашение отправлено.';

  @override
  String get friendTripUnavailable => 'Эта поездка больше недоступна для этого действия. Обновите и повторите попытку.';

  @override
  String get friendTripActionFailed => 'Не удалось выполнить действие. Повторите попытку.';

  @override
  String get profileContactDescription => 'Есть проблема, предложение или вопрос о Splyto? Напишите нам — мы будем рады помочь.';

  @override
  String get profileContactEmailAction => 'Написать письмо';

  @override
  String get profileContactEmailUnavailable => 'Не удалось открыть почтовое приложение. Скопируйте адрес и напишите нам оттуда.';

  @override
  String get profilePrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyLoadFailed => 'Не удалось загрузить политику конфиденциальности. Повторите попытку.';

  @override
  String get addReceiptAction => 'Добавить чек';

  @override
  String get receiptPickFailed => 'Не удалось загрузить чек. Повторите попытку.';

  @override
  String get receiptPhotoAccessDenied => 'Разрешите Splyto доступ к камере или галерее в Настройках и повторите попытку.';

  @override
  String get receiptPhotoLabel => 'Фото чека';

  @override
  String get replaceReceiptAction => 'Заменить чек';

  @override
  String get removeReceiptAction => 'Удалить чек';

  @override
  String get restoreReceiptAction => 'Вернуть предыдущий чек';

  @override
  String get expenseSplitBetween => 'Разделить между';

  @override
  String get expenseEditParticipants => 'Выбрать участников';

  @override
  String get expenseCustomSplit => 'Своё деление';

  @override
  String get expenseAdjustmentsLabel => 'Корректировки';

  @override
  String get expenseAdjustmentFieldLabel => '+ или −';

  @override
  String get expenseAdjustmentsHint => 'Прибавьте или вычтите для каждого. Остаток делится поровну.';

  @override
  String get expenseAdjustmentsMustFit => 'Корректировки не могут превышать итог, и никто не может быть должен меньше нуля.';

  @override
  String get expenseItemsLabel => 'Позиции';

  @override
  String get expenseAddItem => 'Добавить позицию';

  @override
  String get expenseRemoveItem => 'Удалить позицию';

  @override
  String get expenseItemName => 'Позиция';

  @override
  String get expenseItemExtra => 'Налог или чаевые';

  @override
  String get expenseItemExtraHint => 'Делится пропорционально позициям каждого.';

  @override
  String get expenseItemsInvalid => 'У каждой позиции должны быть название, сумма и хотя бы один человек.';

  @override
  String expenseItemsTotal(String total) {
    return 'Итого по позициям: $total';
  }

  @override
  String expenseItemsMustMatchTotal(String total) {
    return 'Сумма позиций должна равняться $total.';
  }

  @override
  String get tripGuestAddAction => 'Добавить человека без приложения';

  @override
  String get tripGuestNameLabel => 'Имя';

  @override
  String get tripGuestAddHint => 'Приложение ему не нужно. Вы сами вводите, что он оплатил, и отмечаете его платежи.';

  @override
  String get tripGuestBadge => 'Без приложения';

  @override
  String get tripGuestRenameAction => 'Изменить имя';

  @override
  String tripGuestAdded(String name) {
    return '$name: добавлен(а)';
  }

  @override
  String expenseSplitAllocated(String amount) {
    return 'Распределено всё: $amount';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Осталось распределить: $amount';
  }

  @override
  String expenseSplitOver(String amount) {
    return 'Больше итога на $amount';
  }

  @override
  String get profilePaymentSharingTitle => 'Показывать способы оплаты в моих поездках';

  @override
  String get profilePaymentSharingDescription => 'Участники поездок, которые я создаю или к которым присоединяюсь, смогут видеть мои способы оплаты. Это касается текущих и будущих поездок. Отключите в любой момент, чтобы закрыть новый доступ.';

  @override
  String get memberPaymentDetailsNotShared => 'Способы оплаты не показаны или сейчас недоступны.';

  @override
  String get homeTripInvitations => 'Приглашения в поездки';

  @override
  String get homeNoTripInvitations => 'Нет ожидающих приглашений в поездки';

  @override
  String get homeInvitationsLoadFailed => 'Не удалось загрузить приглашения. Повторите попытку.';

  @override
  String get homeInvitationResponseFailed => 'Не удалось ответить на приглашение. Повторите попытку.';

  @override
  String get homeTripShareFailed => 'Не удалось поделиться поездкой. Повторите попытку.';

  @override
  String get settleStillToReceive => 'Ещё получить';

  @override
  String get settleStillToPay => 'Ещё заплатить';

  @override
  String get settleEstimateCaption => 'Оценка по текущим расходам. Суммы могут измениться до конца поездки.';

  @override
  String get settleOutstandingCaption => 'Ожидает оплаты или подтверждения.';

  @override
  String get settleWaitingForYou => 'Ждём, пока вы отметите готовность.';

  @override
  String get settleWhoPaysWhom => 'Кто кому платит';

  @override
  String get settlePreviewCaption => 'Предпросмотр · окончательно после завершения поездки';

  @override
  String get settleOpenPaymentCaption => 'Откройте платёж, чтобы увидеть детали и доступные действия.';

  @override
  String get tripBudgetEnable => 'Задать бюджет';

  @override
  String get tripBudgetSoloHint => 'Необязательная цель по расходам для этой поездки.';

  @override
  String get tripBudgetGroupHint => 'Один общий бюджет на всю группу.';

  @override
  String get tripBudgetAmount => 'Сумма бюджета';

  @override
  String get tripBudgetInvalid => 'Введите сумму от 0.01 до 999999999.99, не более двух знаков после запятой.';

  @override
  String get tripBudgetTitle => 'Бюджет поездки';

  @override
  String get tripBudgetGroupTitle => 'Бюджет группы';

  @override
  String get tripBudgetRemaining => 'Осталось';

  @override
  String get tripBudgetOver => 'Сверх бюджета';

  @override
  String get tripBudgetSpent => 'Потрачено';

  @override
  String get tripBudgetLimit => 'Бюджет';

  @override
  String get travelMapTitle => 'Моя карта путешествий';

  @override
  String get travelMapSubtitle => 'Места, где вы были. Только для вас.';

  @override
  String get travelMapHere => 'Я здесь был(а)';

  @override
  String get travelMapAdd => 'Добавить место';

  @override
  String get travelMapSearch => 'Поиск города и страны';

  @override
  String get travelMapSearchAction => 'Найти';

  @override
  String get travelMapSearchHint => 'Например, Лиссабон, Португалия';

  @override
  String get travelMapEmpty => 'Ваше следующее воспоминание начинается здесь';

  @override
  String get travelMapEmptyBody => 'Добавьте город, где вы были, или отметьтесь там, где находитесь сейчас.';

  @override
  String get travelMapConfirm => 'Сохранить это посещение?';

  @override
  String get travelMapConfirmBody => 'Проверьте город и дату перед сохранением на личной карте.';

  @override
  String get travelMapDate => 'Дата посещения';

  @override
  String get travelMapSave => 'Сохранить на моей карте';

  @override
  String get travelMapCancel => 'Отмена';

  @override
  String get travelMapClose => 'Закрыть';

  @override
  String get travelMapNoResults => 'Город не найден. Попробуйте добавить к запросу страну.';

  @override
  String get travelMapLookupError => 'Не удалось найти город. Проверьте подключение или добавьте место вручную.';

  @override
  String get travelMapDenied => 'Доступ к геопозиции выключен. Город можно добавить вручную.';

  @override
  String get travelMapDisabled => 'Включите службы геолокации или добавьте город вручную.';

  @override
  String get travelMapError => 'Не удалось загрузить карту путешествий. Повторите попытку.';

  @override
  String get travelMapSaveError => 'Не удалось сохранить посещение. Повторите попытку.';

  @override
  String get travelMapUnavailable => 'Для карты путешествий нужно обновление сервера.';

  @override
  String get travelMapOffline => 'Нет подключения · показаны сохранённые места';

  @override
  String get travelMapRetry => 'Повторить';

  @override
  String get travelMapDelete => 'Удалить посещение';

  @override
  String get travelMapDeleteConfirm => 'Удалить это посещение с личной карты?';

  @override
  String get travelMapFit => 'Показать все места';

  @override
  String get travelMapSaved => 'Посещение сохранено';

  @override
  String get travelMapVisited => 'Посещено';

  @override
  String get travelMapLimit => 'На карте уже 1000 посещений. Удалите старое, прежде чем добавить новое.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries страны',
      many: '$countries стран',
      few: '$countries страны',
      one: '$countries страна',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities города',
      many: '$cities городов',
      few: '$cities города',
      one: '$cities город',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count посещения',
      many: '$count посещений',
      few: '$count посещения',
      one: '$count посещение',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Направления (необязательно)';

  @override
  String get travelAddDestination => 'Добавить направление';

  @override
  String get travelRemoveDestination => 'Удалить направление';

  @override
  String get travelFromTrip => 'Из поездки';

  @override
  String get travelChooseTrip => 'Выберите поездку';

  @override
  String get travelNoTrips => 'Поездок пока нет. Место можно добавить вручную.';

  @override
  String get travelAddToMap => 'Добавить на мою карту';

  @override
  String get travelTripConfirm => 'Сохраняйте только места, где вы действительно были. На карту добавится личное воспоминание.';

  @override
  String get travelVisitTitle => 'Название (необязательно)';

  @override
  String get travelAddPhoto => 'Добавить фото';

  @override
  String get travelChangePhoto => 'Изменить фото';

  @override
  String get travelRemovePhoto => 'Удалить фото';

  @override
  String get travelPhotoError => 'Не удалось подготовить это фото. Выберите другое.';

  @override
  String get travelEditVisit => 'Изменить посещение';

  @override
  String get travelOpenTrip => 'Открыть поездку';

  @override
  String get travelPreviousVisit => 'Предыдущее посещение';

  @override
  String get travelNextVisit => 'Следующее посещение';

  @override
  String get travelDuplicate => 'Это посещение уже есть на вашей карте.';

  @override
  String get liveMapTitle => 'Живая карта';

  @override
  String get liveShareTitle => 'Поделиться геопозицией';

  @override
  String get liveConsent => 'Делитесь точной геопозицией только с принятыми участниками этой поездки на выбранное время. Передача продолжается в фоне, и её можно остановить в любой момент.';

  @override
  String get liveBackgroundNote => 'Обновления могут приостановиться без интернета или при принудительном закрытии приложения. Хранится только последняя геопозиция, история маршрута не записывается.';

  @override
  String get liveStart => 'Начать передачу';

  @override
  String get liveStop => 'Остановить передачу';

  @override
  String get liveNotification => 'Ваша геопозиция передаётся участникам поездки. Откройте Splyto, чтобы остановить.';

  @override
  String get livePermissionError => 'Включите доступ к геопозиции в настройках телефона, чтобы поделиться ею.';

  @override
  String get liveStartError => 'Не удалось начать передачу. Проверьте доступ к геопозиции, интернет, а также дату и время на телефоне.';

  @override
  String get liveStopPending => 'Обновления остановлены. Ждём интернет, чтобы удалить последнюю геопозицию; без обновлений она исчезнет с карты в течение 2 минут.';

  @override
  String get liveSharing => 'передаёт';

  @override
  String get liveUnavailable => 'Эта живая карта недоступна. Вернитесь в поездку и обновите её.';

  @override
  String get liveMapLoadError => 'Не удалось загрузить карту. Проверьте подключение и откройте карту снова.';

  @override
  String get liveLoadError => 'Не удалось обновить геопозиции. Показаны только недавние обновления.';

  @override
  String get liveFit => 'Показать всех';

  @override
  String get liveEmpty => 'Пока никто не передаёт недавнюю геопозицию.';

  @override
  String get liveRecent => 'Только что обновлено';

  @override
  String get liveLastKnown => 'Последнее обновление';

  @override
  String get liveAccuracy => 'Точность';

  @override
  String get liveUntil => 'Передача до';

  @override
  String get liveOtherSession => 'Начато в другом сеансе. Остановить можно здесь.';

  @override
  String get liveUpdatesPaused => 'Обновления приостановлены. Проверьте доступ к геопозиции и интернет.';

  @override
  String get livePrivateUntilShared => 'Ваша геопозиция остаётся личной, пока вы не решите ею поделиться.';

  @override
  String get activityEventExpenseCreated => 'добавляет расход';

  @override
  String get activityEventExpenseUpdated => 'изменяет расход';

  @override
  String get activityEventExpenseDeleted => 'удаляет расход';

  @override
  String get activityEventExpenseCommentAdded => 'комментирует расход';

  @override
  String get activityEventTripCreated => 'создаёт поездку';

  @override
  String get activityEventTripUpdated => 'изменяет данные поездки';

  @override
  String get activityEventTripRenamed => 'переименовывает поездку';

  @override
  String get activityEventTripCurrencyChanged => 'меняет валюту поездки';

  @override
  String get activityEventTripPhotoChanged => 'меняет фото поездки';

  @override
  String get activityEventTripBudgetChanged => 'меняет бюджет поездки';

  @override
  String get activityEventTripDestinationsChanged => 'меняет направления поездки';

  @override
  String get activityEventTripMembersAdded => 'добавляет участников';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'отправляет приглашения: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'присоединяется к поездке';

  @override
  String get activityEventTripInvitationDeclined => 'отклоняет приглашение в поездку';

  @override
  String get activityEventTripInvitationRevoked => 'отменяет приглашение в поездку';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'удаляет из поездки: $name';
  }

  @override
  String get activityEventTripMemberLeft => 'покидает поездку';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'меняет роль $name на $role';
  }

  @override
  String get activityEventTripMemberReady => 'отмечает готовность к расчётам';

  @override
  String get activityEventTripMemberNotReady => 'снимает отметку о готовности';

  @override
  String get activityEventTripAllMembersReady => 'Все участники готовы к расчётам';

  @override
  String get activityEventTripFinished => 'завершает поездку';

  @override
  String get activityEventTripSettled => 'Все переводы подтверждены, поездка рассчитана';

  @override
  String get activityEventSettlementMarkedSent => 'отмечает перевод как отправленный';

  @override
  String get activityEventSettlementConfirmed => 'подтверждает перевод';

  @override
  String get activityEventSettlementSentCancelled => 'отменяет статус отправки';

  @override
  String get activityEventSettlementNotReceived => 'отмечает перевод как не полученный';

  @override
  String get activityEventSettlementReminderSent => 'отправляет напоминание о расчёте';

  @override
  String get activityEventPaymentMarkedSent => 'записывает платёж';

  @override
  String get activityEventPaymentRequested => 'запрашивает платёж';

  @override
  String get activityEventPaymentRequestMarkedSent => 'отмечает запрошенный платёж как отправленный';

  @override
  String get activityEventPaymentRequestCancelled => 'отменяет запрос на платёж';

  @override
  String get activityEventPaymentRequestDeclined => 'отклоняет запрос на платёж';

  @override
  String get activityEventPaymentConfirmed => 'подтверждает платёж';

  @override
  String get activityEventPaymentCancelled => 'отменяет запись о платеже';

  @override
  String get activityEventPaymentNotReceived => 'отмечает платёж как не полученный';

  @override
  String get activityEventUnknown => 'вносит изменение';

  @override
  String get privacyEnglishFallback => 'Политика конфиденциальности сейчас доступна на английском языке.';

  @override
  String get activityRoleAdmin => 'Администратор';

  @override
  String get accountDeleteTitle => 'Удалить аккаунт';

  @override
  String get accountDeleteIntro => 'Подтвердите удаление по эл. почте. После подтверждения его нельзя отменить.';

  @override
  String get accountDeleteConsequences => 'Удаление необратимо. Ваш профиль будет обезличен, а доступ к аккаунту закрыт. Общие записи о поездках и расходах останутся у других участников.';

  @override
  String get accountDeleteReasonsTitle => 'Что мы могли бы сделать лучше?';

  @override
  String get accountDeleteReasonsHint => 'Причина (необязательно)';

  @override
  String get accountDeleteReasonNotUsing => 'Splyto мне больше не нужен для поездок';

  @override
  String get accountDeleteReasonAnotherWay => 'Я веду общие расходы другим способом';

  @override
  String get accountDeleteReasonComplicated => 'Всё требует слишком много усилий';

  @override
  String get accountDeleteReasonTechnical => 'Я столкнулся(-ась) с ошибками или техническими проблемами';

  @override
  String get accountDeleteReasonPrivacy => 'Я предпочитаю удалить свои данные аккаунта';

  @override
  String get accountDeleteReasonOther => 'Я ухожу по другой причине';

  @override
  String get accountDeleteEmailStep => 'Следующий шаг: подтверждение по эл. почте.';

  @override
  String get accountDeletePasswordHint => 'Введите текущий пароль Splyto, чтобы запросить письмо с подтверждением. Ваш аккаунт пока активен.';

  @override
  String get accountDeleteInboxTitle => 'Последний шаг в вашей почте';

  @override
  String accountDeleteSentBody(String email) {
    return 'Ссылка для подтверждения отправлена на $email.';
  }

  @override
  String get accountDeleteSentHint => 'Аккаунт остаётся активным, пока вы не подтвердите удаление.';

  @override
  String get accountDeleteSending => 'Отправляем письмо с подтверждением';

  @override
  String get friendsShowMore => 'Показать ещё';

  @override
  String get tripReportTitle => 'Отчёт о поездке';

  @override
  String get tripReportDetailedTitle => 'Подробный отчёт о поездке';

  @override
  String get tripReportDates => 'Даты';

  @override
  String get tripReportDestinations => 'Направления';

  @override
  String get tripReportTotalSpent => 'Всего потрачено';

  @override
  String get tripReportExpenses => 'Расходы';

  @override
  String get tripReportYouPaid => 'Вы заплатили';

  @override
  String get tripReportYourShare => 'Ваша доля';

  @override
  String get tripReportYourBalance => 'Ваш баланс';

  @override
  String get tripReportYourSettlements => 'Ваши расчёты';

  @override
  String tripReportYouPay(Object arg1) {
    return 'Вы платите: $arg1';
  }

  @override
  String tripReportPaysYou(Object arg1) {
    return '$arg1 платит вам';
  }

  @override
  String get tripReportStatus => 'Статус';

  @override
  String get tripReportStatusPending => 'Ожидает';

  @override
  String get tripReportStatusSent => 'Отправлено';

  @override
  String get tripReportStatusConfirmed => 'Подтверждено';

  @override
  String get tripReportNoSettlements => 'Вам рассчитываться не нужно.';

  @override
  String get tripReportByCategory => 'Расходы по категориям';

  @override
  String get tripReportCategory => 'Категория';

  @override
  String get tripReportAmount => 'Сумма';

  @override
  String get tripReportMembers => 'Участники';

  @override
  String get tripReportMember => 'Участник';

  @override
  String get tripReportPaid => 'Оплачено';

  @override
  String get tripReportShare => 'Доля';

  @override
  String get tripReportBalance => 'Баланс';

  @override
  String get tripReportAllExpenses => 'Все расходы';

  @override
  String get tripReportDate => 'Дата';

  @override
  String get tripReportDescription => 'Описание';

  @override
  String get tripReportPaidBy => 'Кто оплатил';

  @override
  String get tripReportOriginalAmount => 'Исходная сумма';

  @override
  String get tripReportCurrency => 'Валюта';

  @override
  String get tripReportRate => 'Курс';

  @override
  String get tripReportPayments => 'Платежи';

  @override
  String get tripReportFrom => 'От кого';

  @override
  String get tripReportTo => 'Кому';

  @override
  String get tripReportFooter => 'Создано в Splyto';

  @override
  String tripReportEmailSubject(Object arg1) {
    return 'Ваш отчёт о поездке: $arg1';
  }

  @override
  String get tripReportEmailTitle => 'Ваш отчёт о поездке готов';

  @override
  String tripReportEmailGreeting(Object arg1) {
    return 'Привет, $arg1!';
  }

  @override
  String tripReportEmailBody(Object arg1) {
    return 'Поездка «$arg1» завершена. Отчёт прикреплён в формате PDF.';
  }

  @override
  String get tripReportEmailOptOut => 'Эти письма можно отключить в разделе «Профиль», в пункте «Уведомления».';

  @override
  String get tripReportEmailSetting => 'Отчёт о поездке по эл. почте';

  @override
  String get tripReportEmailSettingSubtitle => 'Получайте сводку в PDF, когда поездка завершена.';

  @override
  String get tripExportAction => 'Экспортировать детали поездки';

  @override
  String get tripExportPdf => 'Подробный PDF';

  @override
  String get tripExportCsv => 'Таблица (CSV)';

  @override
  String get tripExportFailed => 'Не удалось создать экспорт. Повторите попытку.';

  @override
  String get yearSummaryTitle => 'Ваш год в путешествиях';

  @override
  String get yearSummarySubtitle => 'Ваши поездки, места и расходы за год.';

  @override
  String yearSummaryEmpty(Object arg1) {
    return 'В $arg1 году нет завершённых поездок.';
  }

  @override
  String get yearSummaryLoadFailed => 'Не удалось загрузить ваш год в путешествиях.';

  @override
  String get yearSummaryTrips => 'Поездки';

  @override
  String get yearSummaryDays => 'Дней в пути';

  @override
  String get yearSummaryCountries => 'Страны';

  @override
  String get yearSummaryCities => 'Города';

  @override
  String get yearSummarySpending => 'Ваши расходы';

  @override
  String get yearSummaryBiggestTrip => 'Самая большая поездка';

  @override
  String get yearSummaryTopCategory => 'Главная категория';

  @override
  String get yearSummaryTopCompanion => 'Больше всего поездок с';

  @override
  String yearSummaryTripsTogether(Object arg1) {
    return 'Совместных поездок: $arg1';
  }

  @override
  String get yearSummaryPartial => 'Некоторых сумм нет, потому что курс валюты был недоступен.';

  @override
  String get yearSummaryShare => 'Поделиться';

  @override
  String get yearSummaryShareFailed => 'Не удалось поделиться изображением.';

  @override
  String get yearSummaryRetry => 'Повторить';
}
