// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accountSectionTitle => 'Cuenta';

  @override
  String get activeStatus => 'Activo';

  @override
  String get activeTripPlural => 'viajes activos';

  @override
  String get activeTripSingle => 'viaje activo';

  @override
  String get activeTrips => 'Viajes activos';

  @override
  String get activitiesComingSoon => 'Próximamente sección de actividades.';

  @override
  String get addAction => 'Agregar';

  @override
  String get addExpenseTitle => 'Agregar gasto';

  @override
  String get addExpensesAction => 'Agregar gastos';

  @override
  String get addMembersAction => 'Agregar miembros';

  @override
  String get addTripMembersTitle => 'Agregar miembros de viaje';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros agregados.',
      one: '$count miembro agregado.',
    );
    return '$_temp0';
  }

  @override
  String get allCaughtUp => 'todos atrapados';

  @override
  String get allFilter => 'Todo';

  @override
  String get allMembersLabel => 'Todos los miembros';

  @override
  String get allPaymentsConfirmed => 'Todos los pagos están confirmados.';

  @override
  String get allTrips => 'Todos los viajes';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Cantidad';

  @override
  String get amountMustBeGreaterThanZero => 'La cantidad debe ser mayor que 0.';

  @override
  String get appearance => 'Apariencia';

  @override
  String get archivedStatus => 'Archivado';

  @override
  String get authSubtitleLogin => 'Dividir los gastos de viaje con amigos.';

  @override
  String get authSubtitleRegister => 'Crea una cuenta y comienza a dividir viajes';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'confirmado: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'pendiente: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'enviado: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'sugerido: $count';
  }

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get changeEmailWithPasswordHelper => 'Ingrese su contraseña para cambiar el correo electrónico.';

  @override
  String get chooseReceiptFile => 'Elija el archivo de recibo';

  @override
  String get completeAccountSetupDescription => 'Configure su correo electrónico y contraseña para completar su cuenta.';

  @override
  String get completeAccountSetupTitle => 'Configuración completa de la cuenta';

  @override
  String get confirmReceivedAction => 'Confirmar recibido';

  @override
  String get confirmedAllSettlementsArchived => 'Todos los acuerdos confirmados. Viaje archivado.';

  @override
  String get confirmedAsReceived => 'Confirmado como recibido.';

  @override
  String get confirmedLabel => 'Confirmado';

  @override
  String get couldNotOpenReceiptLink => 'No se pudo abrir el enlace del recibo.';

  @override
  String get createAction => 'Crear';

  @override
  String get createFirstTripHint => 'Crea tu primer viaje para comenzar.';

  @override
  String get createNewTripTitle => 'Crear nuevo viaje';

  @override
  String get createTripAction => 'Crear viaje';

  @override
  String get createTripFirst => 'Primero crea un viaje.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date - Creado por $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'El creador del viaje debe finalizarlo para comenzar la confirmación de la liquidación.';

  @override
  String currentEmailLabel(Object email) {
    return 'Correo electrónico actual: $email';
  }

  @override
  String get currentReceiptAttached => 'Se adjunta recibo actual.';

  @override
  String get dateFormatHint => 'AAAA-MM-DD';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get dateMustMatchFormat => 'La fecha debe coincidir con AAAA-MM-DD.';

  @override
  String get dateUnknown => 'Fecha desconocida';

  @override
  String get deleteAction => 'Borrar';

  @override
  String get deleteExpenseConfirmQuestion => '¿Eliminar este gasto?';

  @override
  String get deleteExpenseTitle => 'Eliminar gasto';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Explicado directamente por gastos: $amount';
  }

  @override
  String get doneStatus => 'Hecho';

  @override
  String get editAction => 'Editar';

  @override
  String get editExpenseTitle => 'Editar gasto';

  @override
  String get emailAddressLabel => 'Dirección de correo electrónico';

  @override
  String get emailHint => 'tu@ejemplo.com';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailRequired => 'Se requiere correo electrónico.';

  @override
  String get enterValidExactAmounts => 'Ingrese cantidades exactas válidas para todos los participantes.';

  @override
  String get enterValidPercentages => 'Introduzca porcentajes válidos para todos los participantes.';

  @override
  String get equalSplitLabel => 'División igual';

  @override
  String exactAmountWithValue(Object value) {
    return 'Exacto: $value';
  }

  @override
  String get exactAmountsLabel => 'Cantidades exactas';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'La división exacta debe sumar $amount.';
  }

  @override
  String get expenseAdded => 'Gasto añadido.';

  @override
  String get expenseBreakdownSubtitle => 'Cómo este miembro se ve afectado por cada gasto.';

  @override
  String get expenseBreakdownTitle => 'Desglose de gastos';

  @override
  String get expenseDeleted => 'Gasto eliminado.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Gasto #$id - $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date - Pagado $paid - Debe $owes';
  }

  @override
  String get expenseUpdated => 'Gastos actualizados.';

  @override
  String expenseWithId(Object id) {
    return 'Gasto #$id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos',
      one: '$count gasto',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Gastos';

  @override
  String get failedToCreateTrip => 'No se pudo crear el viaje.';

  @override
  String get failedToLoadUsersDirectory => 'No se pudo cargar el directorio de usuarios.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrar liquidaciones por miembro';

  @override
  String get finishTripAction => 'Terminar viaje';

  @override
  String get finishTripConfirmationText => '¿Terminar este viaje y empezar a establecer asentamientos?';

  @override
  String get finishTripStartSettlementsAction => 'Finalizar e iniciar asentamientos.';

  @override
  String get finishTripTitle => 'Terminar viaje';

  @override
  String forParticipants(Object participants) {
    return 'Para: $participants';
  }

  @override
  String get forgotPassword => '¿Has olvidado tu contraseña?';

  @override
  String get forgotPasswordSubtitle => 'Ingrese su correo electrónico y le enviaremos un enlace para restablecer su contraseña.';

  @override
  String get forgotPasswordSuccessMessage => 'Si existe una cuenta con este correo electrónico, le hemos enviado un enlace para restablecer la contraseña.';

  @override
  String get forgotPasswordTitle => 'Restablecer contraseña';

  @override
  String get friendsProgressSubtitle => 'Cada miembro y su estado de confirmación.';

  @override
  String get friendsProgressTitle => 'Progreso de amigos';

  @override
  String get friendsSectionComingSoon => 'Próximamente sección de amigos.';

  @override
  String fromDirection(Object name) {
    return 'Desde $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from a $to';
  }

  @override
  String get generateTurnAction => 'generar turno';

  @override
  String get hasAccountQuestion => '¿Ya tienes una cuenta?';

  @override
  String helloUser(Object name) {
    return 'Hola, $name!';
  }

  @override
  String get iSentAction => 'yo envié';

  @override
  String get invalidEmailFormat => 'Formato de correo electrónico no válido.';

  @override
  String get languageAction => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageLatvian => 'Letón';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageSystemSubtitle => 'Usar el idioma del dispositivo';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Déjelo vacío para mantener la contraseña actual.';

  @override
  String get logInButton => 'Acceso';

  @override
  String get logOutButton => 'Finalizar la sesión';

  @override
  String get logoutFromDeviceQuestion => '¿Cerrar sesión en este dispositivo?';

  @override
  String get markedAsSent => 'Marcado como enviado.';

  @override
  String get memberSummariesSubtitle => 'Estado de equilibrio actual para ambas partes.';

  @override
  String get memberSummariesTitle => 'Resúmenes de miembros';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Para pagar $total - confirmado $confirmed - esperando $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Impacto estimado del pago por miembro.';

  @override
  String get membersImpactTitle => 'Impacto de los miembros';

  @override
  String get membersIncludedInExpense => 'Miembros incluidos';

  @override
  String get membersLabel => 'Miembros';

  @override
  String moreCount(Object count) {
    return '+$count más';
  }

  @override
  String get myFilter => 'Mi';

  @override
  String get myImpactTitle => 'mi impacto';

  @override
  String get firstNameHint => 'tu nombre';

  @override
  String get firstNameLabel => 'Nombre de pila';

  @override
  String get firstNameLengthValidation => 'El nombre debe tener entre 2 y 64 caracteres.';

  @override
  String get fullNameHelper => 'Utilice nombre y apellido en un campo.';

  @override
  String get fullNameHint => 'p.ej. Anna Ozolina';

  @override
  String get fullNameLabel => 'nombre completo';

  @override
  String get fullNameValidation => 'Ingrese el nombre y apellido (al menos 2 caracteres cada uno).';

  @override
  String get lastNameHint => 'tu apellido';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get lastNameLengthValidation => 'El apellido debe tener entre 2 y 64 caracteres.';

  @override
  String get nameHint => 'Su nombre';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameLengthValidation => 'El nombre debe tener al menos 2 caracteres.';

  @override
  String get navActivities => 'Analítica';

  @override
  String get navAddTrip => 'Añadir viaje';

  @override
  String get navBalances => 'Saldos';

  @override
  String get navExpenses => 'Gastos';

  @override
  String get navFriends => 'Amigos';

  @override
  String get navHome => 'Hogar';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navRandom => 'Aleatorio';

  @override
  String get netLabel => 'Neto';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get nicknameHint => 'como te veran tus amigos';

  @override
  String get nicknameLabel => 'Apodo';

  @override
  String get nicknameLengthValidation => 'El apodo debe tener al menos 2 caracteres.';

  @override
  String get noAccountQuestion => '¿Aún no tienes cuenta?';

  @override
  String get noBalancesYet => 'Aún no hay saldos.';

  @override
  String get noChangesToSave => 'No hay cambios para guardar.';

  @override
  String get noDirectExpenseLink => 'No se encontró ningún enlace directo de gasto único. Esta liquidación se calcula a partir del saldo total del viaje.';

  @override
  String get noExpenseImpactForMember => 'No hay impacto en los gastos para este miembro.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Aún no hay gastos para $name.';
  }

  @override
  String get noExpensesYet => 'Aún no hay gastos.';

  @override
  String get noExtraUsersToAdd => 'No hay usuarios adicionales para agregar.';

  @override
  String get noInternetDeleteQueued => 'Sin internet. Eliminar en cola.';

  @override
  String get noInternetExpenseQueued => 'Sin internet. Gastos en cola.';

  @override
  String get noInternetUpdateQueued => 'Sin internet. Actualización en cola.';

  @override
  String get noMatchingRows => 'No hay filas coincidentes.';

  @override
  String get noMembersFound => 'No se encontraron miembros.';

  @override
  String get noNewMembersAdded => 'No se agregaron nuevos miembros.';

  @override
  String get noNotePlaceholder => 'Sin nota';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones.';

  @override
  String get noParticipantData => 'Sin datos de participantes.';

  @override
  String get noParticipantsSelected => 'No se seleccionó ningún participante.';

  @override
  String get noPaymentRowsInTrip => 'No hay filas de pago en este viaje.';

  @override
  String get noPaymentsNeeded => 'No se necesitan pagos.';

  @override
  String get noPicksYet => 'Aún no hay selecciones.';

  @override
  String get noSettlementActivityForMember => 'No hay actividad de liquidación para este miembro.';

  @override
  String get noSettlementRowsYet => 'Aún no hay disputas por acuerdos.';

  @override
  String get noSettlements => 'Sin asentamientos';

  @override
  String get noTransferNeededForFilter => 'No se necesita transferencia para el filtro seleccionado.';

  @override
  String get noTransferRowsToShow => 'No hay filas de transferencia para mostrar.';

  @override
  String get noTripDataLoaded => 'No se cargaron datos de viaje.';

  @override
  String get noTripsYet => 'Aún no hay viajes.';

  @override
  String get noUsersFoundYet => 'Aún no se han encontrado usuarios.';

  @override
  String get notSetValue => 'No establecido';

  @override
  String get notYetConfirmedTitle => 'Aún no confirmado';

  @override
  String get noteHint => 'Cena, taxi, entradas...';

  @override
  String get noteLabel => 'Nota';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'La nota debe tener como máximo $max caracteres.';
  }

  @override
  String get notificationFallbackTitle => 'Notificación';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationFriendInviteTitle => 'Invitación de amistad';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name te envió una invitación de amistad.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Recibiste una invitación de amistad.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Invitación aceptada';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name aceptó tu invitación de amistad.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Tu invitación de amistad fue aceptada.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Invitación rechazada';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name rechazó tu invitación de amistad.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Tu invitación de amistad fue rechazada.';

  @override
  String get notificationTripAddedTitle => 'Añadido al viaje';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name te añadió al viaje \"$trip\".';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Fuiste añadido al viaje \"$trip\".';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Fuiste añadido a un viaje.';

  @override
  String get notificationExpenseAddedTitle => 'Nuevo gasto añadido';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name añadió un gasto de $amount en \"$trip\".';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name añadió un gasto de $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Se añadió un nuevo gasto.';

  @override
  String get notificationTripFinishedTitle => 'Viaje finalizado';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name finalizó \"$trip\". Las liquidaciones están listas.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name finalizó \"$trip\". El viaje está archivado.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '\"$trip\" fue finalizado.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Se actualizó el estado del viaje.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Miembro marcado como listo';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name está listo para liquidar en \"$trip\".';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Un miembro está listo para liquidar en \"$trip\".';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Un miembro está listo para liquidar.';

  @override
  String get notificationTripReadyToSettleTitle => 'Todos los miembros están listos';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Todos los miembros se marcaron como listos en \"$trip\". Puedes iniciar las liquidaciones.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Todos los miembros están listos. Puedes iniciar las liquidaciones.';

  @override
  String get notificationSettlementReminderTitle => 'Recordatorio de liquidación';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor recordó a $target marcar $amount como enviado.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor recordó a $target confirmar la recepción de $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Recibiste un recordatorio de liquidación.';

  @override
  String get notificationPaymentReminderTitle => 'Recordatorio de pago';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Recordatorio: marca $amount como enviado a $target en \"$trip\".';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Recordatorio: marca el pago como enviado.';

  @override
  String get notificationConfirmationReminderTitle => 'Recordatorio de confirmación';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Recordatorio: confirma la recepción de $amount de $payer en \"$trip\".';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Recordatorio: confirma la recepción del pago.';

  @override
  String get notificationSettlementSentTitle => 'Transferencia marcada como enviada';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name marcó $amount como enviado para ti.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Se marcó una transferencia como enviada.';

  @override
  String get notificationSettlementConfirmedTitle => 'Transferencia confirmada';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name confirmó haber recibido $amount de ti.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Se confirmó una transferencia.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios pendientes',
      one: '$count cambio pendiente',
    );
    return 'Cola sin conexión: $_temp0';
  }

  @override
  String get offlineQueueStatus => 'Cola sin conexión';

  @override
  String get offlineStatus => 'Desconectado';

  @override
  String get onlineStatus => 'En línea';

  @override
  String get onlyCreatorCanFinishTrip => 'Sólo el creador del viaje puede finalizar el viaje.';

  @override
  String get openLabel => 'Abierto';

  @override
  String get openReceiptAction => 'recibo abierto';

  @override
  String get openSettlements => 'Asentamientos abiertos';

  @override
  String get overviewTitle => 'Descripción general';

  @override
  String get owesLabel => 'debe';

  @override
  String get paidByLabel => 'Pagado por';

  @override
  String get paidLabel => 'Pagado';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Pagado $paid - Debe $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Participantes (vacío = todos los miembros)';

  @override
  String get participantsTitle => 'Participantes';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordComplexityHelper => 'Utilice al menos 1 letra mayúscula, 1 número y 1 símbolo.';

  @override
  String get passwordComplexityValidation => 'La contraseña debe incluir 1 letra mayúscula, 1 número y 1 símbolo.';

  @override
  String get passwordMinLength => 'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get passwordMinLengthShort => 'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get passwordResetComingSoon => 'Próximamente se restablecerá la contraseña.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String payerName(Object name) {
    return '$name (pagador)';
  }

  @override
  String get pendingLabel => 'Pendiente';

  @override
  String get pendingPaymentsSubtitle => 'Los pagos aún esperan confirmación completa.';

  @override
  String get percentLabel => 'Por ciento';

  @override
  String get percentSplitMustBe100 => 'La división porcentual debe sumar exactamente 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Porcentajes';

  @override
  String get pickAtLeastOneParticipant => 'Elija al menos un participante.';

  @override
  String get pickMembersGenerateTurn => 'Elige miembros y genera un turno.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name eligió. Ciclo completado.';
  }

  @override
  String pickedUser(Object name) {
    return '$name eligió.';
  }

  @override
  String get profileRefreshCachedData => 'No se pudo actualizar el perfil. Mostrando datos almacenados en caché.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileUpdated => 'Perfil actualizado.';

  @override
  String get uploadAvatarAction => 'Subir avatar';

  @override
  String get takePhotoAction => 'tomar una foto';

  @override
  String get chooseFromLibraryAction => 'Elija de la biblioteca';

  @override
  String get removeAvatarAction => 'Eliminar avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar actualizado.';

  @override
  String get avatarRemovedMessage => 'Avatar eliminado.';

  @override
  String get avatarFileTooLarge => 'El archivo de avatar es demasiado grande (máximo 5 MB).';

  @override
  String get avatarPickFailed => 'No se pudo cargar la imagen de avatar.';

  @override
  String get queueAddExpense => 'Agregar gasto';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'En cola: agregar gasto $amount';
  }

  @override
  String get queueDeleteExpense => 'Eliminar gasto';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'En cola: eliminar gasto #$id';
  }

  @override
  String get queuePendingStatus => 'Cola pendiente';

  @override
  String get queueUpdateExpense => 'Gasto de actualización';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'En cola: actualizar gasto #$id';
  }

  @override
  String get queuedChange => 'cambio en cola';

  @override
  String queuedChangesTitle(Object count) {
    return 'Cambios en cola ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'En cola ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Ciclo $cycleNo, dibuja $drawNo - $remaining a la izquierda';
  }

  @override
  String get receiptFallbackName => 'recibo';

  @override
  String get receiptLinkInvalid => 'El enlace del recibo no es válido.';

  @override
  String get receiptOptionalLabel => 'Recibo (opcional)';

  @override
  String get recentPicksTitle => 'Selecciones recientes';

  @override
  String get reloadProfile => 'Recargar perfil';

  @override
  String get rememberMe => 'Acuérdate de mí';

  @override
  String get removeCurrentReceipt => 'Eliminar recibo actual';

  @override
  String get repeatNewPasswordLabel => 'Repetir nueva contraseña';

  @override
  String get repeatPasswordLabel => 'Repita la contraseña';

  @override
  String get requestFailedTryAgain => 'La solicitud falló. Intentar otra vez.';

  @override
  String get retryAction => 'Rever';

  @override
  String get rowsLabel => 'Filas';

  @override
  String get backToLoginAction => 'Volver a iniciar sesión';

  @override
  String get saveAction => 'Ahorrar';

  @override
  String get saveCredentialsButton => 'Guardar credenciales';

  @override
  String get saveProfileButton => 'Guardar perfil';

  @override
  String get sendResetLinkButton => 'Enviar enlace de reinicio';

  @override
  String get searchUsersHint => 'Buscar personas por nombre o correo electrónico';

  @override
  String get selectedPeopleLabel => 'personas seleccionadas';

  @override
  String get noSearchMatches => 'No se encontraron usuarios coincidentes.';

  @override
  String get savingButton => 'Ahorro...';

  @override
  String get selectAtLeastTwoMembers => 'Seleccione al menos dos miembros.';

  @override
  String get selectMembersHint => 'Seleccionar miembros';

  @override
  String selectedFileLabel(Object name) {
    return 'Seleccionado: $name';
  }

  @override
  String get selectedLabel => 'Seleccionado';

  @override
  String get selectedUserFallback => 'Usuario seleccionado';

  @override
  String get settings => 'Ajustes';

  @override
  String get settleUpAction => 'Saldar cuentas';

  @override
  String get settledLabel => 'Establecido';

  @override
  String get settledStatus => 'Establecido';

  @override
  String get settlementActivitySubtitle => 'Transferencias vinculadas a este miembro.';

  @override
  String get settlementActivityTitle => 'Actividad de liquidación';

  @override
  String get settlementCompletedTitle => 'Liquidación completada';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed/$total confirmado';
  }

  @override
  String settlementCountLabel(Object count) {
    return '$count asentamientos';
  }

  @override
  String get settlementImpactTitle => 'Impacto del asentamiento';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Impacto de la liquidación: $name';
  }

  @override
  String get settlementInProgress => 'Liquidación en curso';

  @override
  String get settlementInProgressTitle => 'Liquidación en curso';

  @override
  String get settlementLabel => 'Asentamiento';

  @override
  String get settlementOverviewArchivedSubtitle => 'Viaje archivado. Todos los asentamientos completados.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Seguimiento de confirmaciones de liquidación.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Vista previa de traslados para cuando finalice el viaje.';

  @override
  String get settlementPreview => 'Vista previa de la liquidación';

  @override
  String get settlementPreviewTitle => 'Vista previa de la liquidación';

  @override
  String get settlementProgressTripArchived => 'Viaje archivado';

  @override
  String settlementWithId(Object id) {
    return 'Acuerdo #$id';
  }

  @override
  String get settlements => 'Asentamientos';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Liquidaciones ya completadas.';

  @override
  String get settlementsDone => 'Liquidaciones realizadas';

  @override
  String get settlingStatus => 'Asentamiento';

  @override
  String get shareUnit => 'compartir';

  @override
  String get sharesLabel => 'Acciones';

  @override
  String get sharesMustBePositiveIntegers => 'Las acciones deben ser números enteros positivos.';

  @override
  String sharesWithValue(Object value) {
    return 'Comparte: $value';
  }

  @override
  String get showActiveTrips => 'Mostrar viajes activos';

  @override
  String get signUpButton => 'Inscribirse';

  @override
  String get splitBreakdownSubtitle => 'Cómo se divide el gasto';

  @override
  String get splitBreakdownTitle => 'Desglose dividido';

  @override
  String get splitHintEqual => 'Dividir en partes iguales entre los participantes seleccionados.';

  @override
  String get splitHintExact => 'Ingrese el monto exacto para cada participante. La suma debe coincidir con el total.';

  @override
  String get splitHintPercent => 'Ingrese el porcentaje para cada participante. La suma debe ser 100%.';

  @override
  String get splitHintShares => 'Introduzca las unidades de participación (1, 2, 3...). El costo se divide proporcionalmente.';

  @override
  String get splitLabel => 'Dividir';

  @override
  String splitLabelValue(Object value) {
    return 'Dividir: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'División igual ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Importes exactos ($target)';
  }

  @override
  String get splitModeLabel => 'Modo dividido';

  @override
  String splitModePercent(Object target) {
    return 'Porcentajes ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Acciones ($target)';
  }

  @override
  String get statusConfirmed => 'Confirmado';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusSent => 'Enviado';

  @override
  String get statusSuggested => 'sugerido';

  @override
  String statusWithValue(Object status) {
    return 'Estado: $status';
  }

  @override
  String get suggestedTransferDirections => 'Direcciones de transferencia sugeridas';

  @override
  String get suggestedTransferFromExpense => 'Transferencia sugerida de gasto';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas de transferencia sugeridas',
      one: '$count fila de transferencia sugerida',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Pagador esperado -> filas del receptor.';

  @override
  String get suggestedTransfersTitle => 'Transferencias sugeridas';

  @override
  String get summarySettledUp => 'resuelto';

  @override
  String get summaryYouAreOwed => 'te deben';

  @override
  String get summaryYouOwe => 'tu debes';

  @override
  String get syncAction => 'Sincronizar';

  @override
  String get syncNowAction => 'Sincronizar ahora';

  @override
  String get syncingStatus => 'Sincronización';

  @override
  String get tapToViewDetails => 'Toca para ver detalles';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeDarkSubtitle => 'Oscuro suave (no negro puro)';

  @override
  String get themeModeLight => 'Luz';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeSystemSubtitle => 'Usar la apariencia del dispositivo';

  @override
  String toDirection(Object name) {
    return 'A $name';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get travelerFallbackName => 'Viajero';

  @override
  String get tripAlreadyClosed => 'Viaje ya cerrado.';

  @override
  String get tripArchivedReadOnly => 'El viaje está archivado. Modo de solo lectura.';

  @override
  String get tripClosedExpenseEditingDisabled => 'El viaje está cerrado. La edición de gastos está deshabilitada.';

  @override
  String get tripClosedExpensesReadOnly => 'El viaje está cerrado. Los gastos son de solo lectura.';

  @override
  String get tripClosedRandomDisabled => 'El viaje está cerrado. El sorteo aleatorio está deshabilitado.';

  @override
  String tripCreated(Object name) {
    return 'Viaje \"$name\" creado.';
  }

  @override
  String get tripFinished => 'Viaje terminado.';

  @override
  String get tripFinishedCompleteSettlements => 'El viaje ha terminado. Liquidaciones completas.';

  @override
  String get tripFinishedSettlementStarted => 'Viaje terminado. Se inició el asentamiento.';

  @override
  String get tripFullySettledArchived => 'Viaje totalmente liquidado y archivado.';

  @override
  String get tripNameHint => 'viaje de esquí a austria';

  @override
  String get tripNameLabel => 'Nombre del viaje';

  @override
  String get tripNameLengthValidation => 'El nombre del viaje debe tener al menos 2 caracteres.';

  @override
  String get tripSnapshotTitle => 'Instantánea del viaje';

  @override
  String get tripTitleShort => 'Viaje';

  @override
  String tripStatusWithValue(Object status) {
    return 'Estado del viaje: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Viaje #$id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Error inesperado al cargar el perfil';

  @override
  String get unexpectedErrorLoadingTripData => 'Error inesperado al cargar los datos del viaje';

  @override
  String get unexpectedErrorLoadingTrips => 'Errores inesperados al cargar viajes';

  @override
  String get unexpectedErrorSavingChanges => 'Error inesperado al guardar cambios';

  @override
  String get unexpectedErrorSavingCredentials => 'Error inesperado al guardar credenciales';

  @override
  String get unexpectedErrorUpdatingProfile => 'Error inesperado al actualizar el perfil';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get unknownLabel => 'Desconocido';

  @override
  String get unreadLabel => 'No leído';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actualizaciones sin leer',
      one: '$count actualización sin leer',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Falta el argumento de la ruta del viaje.';

  @override
  String userIdLabel(Object id) {
    return 'ID de usuario: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Pagado $paid - Debe $owes - Neto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Usuario $id';
  }

  @override
  String get valueLabel => 'Valor';

  @override
  String get viewAllTrips => 'Ver todos los viajes';

  @override
  String get viewByPersonTitle => 'Ver por persona';

  @override
  String get whoOwesWhatSubtitle => 'Quién pagó y quién debe.';

  @override
  String get whoOwesWhatTitle => 'quien debe que';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Quién debe qué: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Filas de gastos que contribuyen a esta transferencia.';

  @override
  String get whyPaymentExistsTitle => '¿Por qué existe este pago?';

  @override
  String get youLabel => 'Tú';

  @override
  String get youSettledForExpense => 'Te conformaste con este gasto.';

  @override
  String youShouldPay(Object amount) {
    return 'Deberías pagar $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Deberías recibir $amount';
  }

  @override
  String get yourShare => 'tu parte';

  @override
  String get yourTrips => 'Tus viajes';

  @override
  String get authIntroSplitSmarter => 'Divida de forma más inteligente.';

  @override
  String get authIntroTravelFree => 'Viaja gratis.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Realice un seguimiento de los costos compartidos entre monedas y liquide al instante, sin pagarés incómodos.';

  @override
  String get authIntroPlanTogether => 'Planifiquen juntos.';

  @override
  String get authIntroPayClearly => 'Pague claramente.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Crea viajes en segundos, agrega amigos y mantén todos los gastos transparentes para todos.';

  @override
  String get authIntroSettleFast => 'Resolver rápido.';

  @override
  String get authIntroStayFriends => 'Sigan siendo amigos.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Desde cenas compartidas hasta viajes completos, Splyto mantiene un saldo justo y libre de estrés.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Error al iniciar sesión en Apple. Por favor inténtalo de nuevo.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Error al iniciar sesión en Google. Por favor inténtalo de nuevo.';

  @override
  String get authIntroCreateAccount => 'Crea tu cuenta.';

  @override
  String get authIntroChooseSign => 'Elige cómo quieres registrarte.';

  @override
  String get authIntroContinueGoogle => 'Continuar con Google';

  @override
  String get authIntroContinueApple => 'Continuar con Apple';

  @override
  String get authIntroBack => 'Atrás';

  @override
  String get authIntroSplitSettled => 'División resuelta';

  @override
  String get authIntroParis3Friends => 'París · 3 amigos';

  @override
  String get authIntroGetStarted => 'empezar';

  @override
  String get authIntroAlreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get authIntroSignIn => 'Iniciar sesión';

  @override
  String get authIntroSignUpWithEmail => 'Regístrese con correo electrónico';

  @override
  String get authIntroOr => 'O';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'El inicio de sesión de Google no devolvió un token de identificación.';

  @override
  String get authAppleSignAvailableIosDevices => 'El inicio de sesión de Apple está disponible en dispositivos iOS.';

  @override
  String get authAppleSignNotAvailableDevice => 'El inicio de sesión de Apple no está disponible en este dispositivo.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'El inicio de sesión de Apple no devolvió un token de identidad.';

  @override
  String get authAccountDeactivatedEnterEmailRequestReactivationLink => 'La cuenta está desactivada. Ingrese su correo electrónico para solicitar un enlace de reactivación.';

  @override
  String get authAccountDeactivated => 'La cuenta esta desactivada';

  @override
  String authSendReactivationLinkEmail(Object email) {
    return '¿Enviar un enlace de reactivación a $email?';
  }

  @override
  String get authCancel => 'Cancelar';

  @override
  String get authSendLink => 'Enviar enlace';

  @override
  String get authReactivationLinkSentCheckEmail => 'Enlace de reactivación enviado. Revisa tu correo electrónico.';

  @override
  String get authCouldNotSendReactivationLinkPleaseTryAgain => 'No se pudo enviar el enlace de reactivación. Por favor inténtalo de nuevo.';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'El correo electrónico no está verificado. Ingrese su correo electrónico para solicitar el enlace de verificación.';

  @override
  String get authEmailNotVerified => 'Correo electrónico no verificado';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return '¿Enviar enlace de verificación a $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Enlace de verificación enviado. Revisa tu correo electrónico.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'No se pudo enviar el enlace de verificación. Por favor inténtalo de nuevo.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Correo electrónico de verificación enviado. Por favor verifique su correo electrónico antes de iniciar sesión.';

  @override
  String get authVerifyEmail => 'Verifica tu correo electrónico';

  @override
  String get authEmailLabel => 'Correo electrónico:';

  @override
  String get authClose => 'Cerca';

  @override
  String get authResendLink => 'Reenviar enlace';

  @override
  String get profileAppSettingsSectionTitle => 'CONFIGURACIÓN DE LA APLICACIÓN';

  @override
  String get profileAppearance => 'Apariencia';

  @override
  String get profileThemeDisplayMode => 'Tema y modo de visualización';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileDisplayLanguage => 'Idioma de visualización';

  @override
  String get profileNotificationsSectionHeading => 'NOTIFICACIONES';

  @override
  String get profileAppBanners => 'Banners en la aplicación';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Mostrar nuevos banners de notificación dentro de la aplicación';

  @override
  String get profilePushNotificationsTitle => 'Notificaciones push';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Notificaciones telefónicas de gastos, amigos, viajes y liquidaciones.';

  @override
  String get profileSupportSectionHeading => 'APOYO';

  @override
  String get profileContactUs => 'Contáctenos';

  @override
  String get profileReportBugSuggestion => 'Informar error/sugerencia';

  @override
  String get profileRateSplyto => 'Califica Splyto';

  @override
  String get profileLeaveStoreRating => 'Deja una calificación de tienda';

  @override
  String get profileSecuritySectionHeading => 'SEGURIDAD';

  @override
  String get profileChangePassword => 'Cambiar la contraseña';

  @override
  String get profileUpdateAccountPassword => 'Actualizar contraseña de cuenta';

  @override
  String get profileDangerZoneSectionHeading => 'ZONA DE PELIGRO';

  @override
  String get profileDeactivateAccount => 'Desactivar cuenta';

  @override
  String get profileManageAccountAccess => 'Administrar el acceso a la cuenta';

  @override
  String get profileMadeWithLabel => 'Hecho con';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'La acción de calificación de la tienda se conectará en el siguiente paso.';

  @override
  String get profileFailedSaveNotificationSettings => 'No se pudo guardar la configuración de notificaciones.';

  @override
  String get profilePushNotificationsSectionTitle => 'NOTIFICACIONES PUSH';

  @override
  String get profileInAppBannersSectionTitle => 'BANNERS EN LA APLICACIÓN';

  @override
  String get profileExpenseUpdates => 'Actualizaciones de gastos';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Banners dentro de la app cuando se añade un gasto';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Notificaciones de gastos añadidos al teléfono';

  @override
  String get profileFriendInvites => 'Invitaciones de amigos';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Banners dentro de la app sobre solicitudes y respuestas de amistad';

  @override
  String get profileFriendRequestResponseNotifications => 'Notificaciones de solicitud y respuesta de amistad.';

  @override
  String get profileTripUpdates => 'Actualizaciones de viaje';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Banners dentro de la app sobre el estado del viaje y de los miembros';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Cambios en el ciclo de vida del viaje y el estado de los miembros';

  @override
  String get profileSettlementUpdates => 'Actualizaciones de liquidación';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Banners dentro de la app sobre pagos marcados como enviados y confirmados';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Actualizaciones de pago marcadas enviadas y confirmadas';

  @override
  String get profileScreenshotSizeMust8Mb => 'El tamaño de la captura de pantalla debe ser de hasta 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Enviar comentarios';

  @override
  String get profileFeedbackTypeLabel => 'Tipo';

  @override
  String get profileFeedbackTypeBug => 'Bicho';

  @override
  String get profileFeedbackTypeSuggestion => 'Sugerencia';

  @override
  String get profileDescribeIssueSuggestion => 'Describir problema o sugerencia';

  @override
  String get profilePickingImage => 'Eligiendo imagen...';

  @override
  String get profileAttachScreenshot => 'Adjuntar captura de pantalla';

  @override
  String get profileChangeScreenshot => 'Cambiar captura de pantalla';

  @override
  String get profileRemoveImage => 'Quitar imagen';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Consejo: adjunte una captura de pantalla para una clasificación de errores más rápida';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Agregue detalles o adjunte captura de pantalla antes de enviar';

  @override
  String get profileSendAction => 'Enviar';

  @override
  String get profileThanksFeedbackSent => '¡Gracias! Comentarios enviados';

  @override
  String get profileFailedSendFeedback => 'No se pudo enviar comentarios';

  @override
  String get profileCouldNotOpenWebsite => 'No se pudo abrir el sitio web.';

  @override
  String get profileOpenWebsiteQuestion => '¿Abrir sitio web?';

  @override
  String get profileOpenPortfolioAction => 'Abrir portafolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Este formato de imagen no es compatible con este dispositivo. Elija JPG o PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Establezca un correo electrónico válido en Editar perfil antes de cambiar la contraseña.';

  @override
  String get profileEditDeactivatedReactivationLinkEmailRestoreAccess => 'Cuenta desactivada. Utilice el enlace de reactivación del correo electrónico para restaurar el acceso.';

  @override
  String get profileEditCouldNotDeactivateTryAgain => 'No se pudo desactivar la cuenta. Por favor inténtalo de nuevo.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Enlace de eliminación enviado a su correo electrónico.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'No se pudo enviar el enlace de eliminación. Por favor inténtalo de nuevo.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Ingrese la contraseña actual para cambiar el correo electrónico.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'La verificación fue enviada al nuevo correo electrónico. El aviso de seguridad fue enviado a su correo electrónico actual.';

  @override
  String get profileEditCouldNotStartEmailChangeRightNowTry => 'No se pudo iniciar el cambio de correo electrónico en este momento. Por favor inténtalo de nuevo.';

  @override
  String get profileEditOverviewCurrency => 'Moneda general';

  @override
  String get profileEditPaymentMethod => 'Método de pago';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Transferencia bancaria, Revolut, PayPal.me';

  @override
  String get profileEditDeactivateAccessRequestEmailLinkPermanentlyDeletePassword => 'Puede desactivar el acceso a la cuenta o solicitar un enlace de correo electrónico para eliminar permanentemente la cuenta. La contraseña es opcional para las cuentas de Google/Apple.';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Ingrese su contraseña (opcional para Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Enviar enlace de eliminación al correo electrónico';

  @override
  String get profileEditBackProfile => 'Volver al perfil';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Establezca un correo electrónico válido en el perfil antes de cambiar la contraseña.';

  @override
  String get profileEditPasswordUpdated => 'Contraseña actualizada.';

  @override
  String get profileEditFailedUpdatePassword => 'No se pudo actualizar la contraseña.';

  @override
  String profileEditEmail(Object email) {
    return 'Cuenta: $email';
  }

  @override
  String get profileEditPrimary => 'Primario';

  @override
  String get profileEditSearchCurrency => 'Buscar moneda';

  @override
  String get profileEditNoCurrenciesFound => 'No se encontraron monedas';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Los totales del resumen se convierten a esta moneda.';

  @override
  String get profileEditPaymentInfoUpdated => 'Información de pago actualizada.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'No se pudo guardar la información de pago. Por favor inténtalo de nuevo.';

  @override
  String get profileEditCurrentPassword => 'Contraseña actual';

  @override
  String get profileEditBankTransferIbanSwift => 'Transferencia bancaria (IBAN/SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN+SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag/revolut.me';

  @override
  String get profileEditPaypalMeLink => 'enlace paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Elige el método de pago';

  @override
  String get profileEditTapChange => 'Toca para cambiar';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Para transferencias al Reino Unido, el código de clasificación debe tener 6 dígitos y el número de cuenta 8 dígitos.';

  @override
  String get profileEditPaymentInfo => 'Información de pago';

  @override
  String get profileEditSaveDetails => 'Guardar detalles';

  @override
  String get profileEditBankRegion => 'Región bancaria';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'ordenar código';

  @override
  String get profileEditExample112233 => 'Ejemplo: 112233';

  @override
  String get profileEditNumber => 'Número de cuenta';

  @override
  String get profileEdit8Digits => '8 dígitos';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Para transferencias nacionales en el Reino Unido, utilice el código de clasificación + número de cuenta.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Ejemplo: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 u 11 caracteres';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'El nombre del titular de la cuenta se toma del nombre completo del perfil.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/nombredeusuario';

  @override
  String get profileEditRevtag => 'etiqueta rev';

  @override
  String get profileEditUsername => '@nombre de usuario';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/nombredeusuario o nombre de usuario';

  @override
  String get shellTripAlreadyInListOpened => 'Viaje ya en tu lista. Lo abrí para ti.';

  @override
  String get shellJoinedTripFromInviteLink => 'Viaje unido desde el enlace de invitación.';

  @override
  String get shellFailedToOpenInviteLink => 'No se pudo abrir el enlace de invitación.';

  @override
  String get shellTripInviteTitle => 'invitación de viaje';

  @override
  String get shellNoAction => 'No';

  @override
  String get shellYesAction => 'Sí';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Sólo el creador del viaje puede eliminar este viaje.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Sólo se pueden eliminar los viajes activos.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return '¿Eliminar \"$tripLabel\"? Esto se permite sólo antes de que se agreguen los gastos.';
  }

  @override
  String get shellTripDeleted => 'Viaje eliminado.';

  @override
  String get shellFailedToDeleteTrip => 'No se pudo eliminar el viaje.';

  @override
  String get shellFailedToLoadNotifications => 'No se pudieron cargar las notificaciones.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nueva notificación: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'No se pudieron actualizar las notificaciones.';

  @override
  String get shellMarkAllAsReadAction => 'Marcar todo como leído';

  @override
  String get shellNewSection => 'Nuevo';

  @override
  String get shellEarlierSection => 'Más temprano';

  @override
  String get shellShowMoreEarlierAction => 'Mostrar más antes';

  @override
  String get shellLoadingMore => 'Cargando más...';

  @override
  String get shellLoadMoreNotificationsAction => 'Cargar más notificaciones';

  @override
  String get shellTripNoLongerAvailable => 'Este viaje ya no está disponible.';

  @override
  String get shellFailedToOpenTrip => 'No se pudo abrir el viaje.';

  @override
  String get shellYesterday => 'Ayer';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Ya eres miembro de \"$tripName\". ¿Abrir este viaje ahora?\n\nInvitado por: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return '¿Quieres unirte al viaje \"$tripName\"?\n\nInvitado por: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Imagen seleccionada: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'La imagen del viaje ya está establecida.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Viaje creado, pero la carga de la imagen falló.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Viaje creado, pero la carga de la imagen falló: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Unirse al viaje mediante invitación';

  @override
  String get tripsTotalTrips => 'Total de viajes';

  @override
  String get tripsTotalSpent => 'Gasto total';

  @override
  String get tripsMixedCurrencies => 'Monedas mixtas';

  @override
  String get tripsShowActive => 'Mostrar activos';

  @override
  String get tripsSeeAll => 'Ver todo';

  @override
  String get tripsAddNewTrip => 'Añadir viaje';

  @override
  String get tripsLoadMore => 'Cargar más';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return '¿Eliminar \"$arg1\"? Esto solo está permitido antes de añadir cualquier gasto.';
  }

  @override
  String get tripsTripDates => 'Fechas del viaje';

  @override
  String get tripsFrom => 'Desde';

  @override
  String get tripsSelectDate => 'Seleccionar fecha';

  @override
  String get tripsTo => 'Hasta';

  @override
  String get tripsMainCurrency => 'Moneda principal';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Selecciona el período del viaje (fechas de inicio y fin).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'La fecha de fin del viaje debe ser igual o posterior a la fecha de inicio.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'El formato del período del viaje no es válido. Selecciona las fechas de nuevo.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Ya eres miembro de este viaje.';

  @override
  String get tripsJoinedTripSuccessfully => 'Te uniste al viaje correctamente.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'No se pudo unir al viaje desde la invitación.';

  @override
  String get tripsJoinTrip => 'Unirse al viaje';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Pega un enlace de invitación o un token de invitación.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Introduce un enlace o token de invitación válido.';

  @override
  String get tripsClipboardIsEmpty => 'El portapapeles está vacío.';

  @override
  String get tripsPaste => 'Pegar';

  @override
  String get tripsJoin => 'Unirse';

  @override
  String get workspaceTripMembers => 'Miembros del viaje';

  @override
  String get workspaceFailedToLoadFriends => 'No se pudieron cargar los amigos.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'No se pudo generar el enlace de invitación.';

  @override
  String get workspaceInviteLink => 'Enlace de invitación';

  @override
  String get workspaceGeneratingInviteLink => 'Generando enlace de invitación...';

  @override
  String get workspaceInviteLinkUnavailable => 'Enlace de invitación no disponible.';

  @override
  String get workspaceCopyInviteLink => 'Copiar enlace de invitación';

  @override
  String get workspaceInviteLinkCopied => 'Enlace de invitación copiado.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Caduca: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'No hay amigos disponibles. Añade amigos primero.';

  @override
  String get workspaceSettle => 'Liquidar';

  @override
  String get workspaceOwesToTheGroup => 'Debe al grupo';

  @override
  String get workspaceGetsBackFromGroup => 'Recibe del grupo';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Mostrando los 4 principales por diferencia de saldo.';

  @override
  String get workspaceOpenFlow => 'Flujo abierto';

  @override
  String get workspaceFriend => 'Amigo';

  @override
  String get workspaceSettlementTransfer => 'Transferencia de liquidación';

  @override
  String get workspaceCompleted => 'Completado';

  @override
  String get workspaceWaitingForConfirmation => 'Esperando confirmación';

  @override
  String get workspaceWaitingForPayment => 'Esperando pago';

  @override
  String get workspaceActionNeeded => 'Acción necesaria';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return '$arg1 pago(s) por marcar como enviados, $arg2 por confirmar como recibidos.';
  }

  @override
  String get workspaceReadyToSettle => 'Listo para liquidar';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Todos los miembros están listos. Puedes iniciar las liquidaciones.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Esperando a que todos se marquen como listos.';

  @override
  String get workspaceIMReady => 'Estoy listo';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Confirma que has añadido todos tus gastos.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'El botón Finalizar se desbloquea cuando todos se marcan como listos.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Recibe del grupo';

  @override
  String get workspaceSettledWithTheGroup => 'Liquidado con el grupo';

  @override
  String get workspaceTotalPaid => 'Total pagado';

  @override
  String get workspaceTotalOwes => 'Deuda total';

  @override
  String get workspaceTransactionHistory => 'Historial de transacciones';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Aún no hay transacciones para este miembro.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Liquidaciones: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Todos los miembros deben marcarse como listos antes de iniciar las liquidaciones.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Te marcaste como listo para liquidar.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Se eliminó la marca de listo para liquidar.';

  @override
  String get workspaceReminderSent => 'Recordatorio enviado.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Enlace de invitación o añadir desde amigos';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Solo el creador del viaje puede editar este viaje.';

  @override
  String get workspaceTripUpdated => 'Viaje actualizado.';

  @override
  String get workspaceFailedToUpdateTrip => 'No se pudo actualizar el viaje.';

  @override
  String get workspaceNoMembersSelectedYet => 'Aún no hay miembros seleccionados.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Sin conexión. El gasto se guardará sin imagen del recibo.';

  @override
  String get workspaceRandomPicker => 'Selector aleatorio';

  @override
  String get workspaceCurrency => 'Moneda';

  @override
  String get workspaceCategory => 'Categoría';

  @override
  String get workspaceCustomCategory => 'Categoría personalizada';

  @override
  String get workspaceCategoryName => 'Nombre de la categoría';

  @override
  String get workspaceApartmentRentParkingEtc => 'Alquiler del apartamento, aparcamiento, etc.';

  @override
  String get workspaceEnterACustomCategory => 'Introduce una categoría personalizada.';

  @override
  String get workspacePickAnExpenseCategory => 'Elige una categoría de gasto.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'La categoría debe tener al menos 2 caracteres.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'La categoría puede tener hasta 64 caracteres.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'El reparto porcentual debe sumar 100 %.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Las participaciones deben ser mayores que 0 para todos los participantes.';

  @override
  String get workspaceTotalAmount => 'Importe total';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Costo total';

  @override
  String workspaceStarted(Object arg1) {
    return 'Iniciado $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Finalizado $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Viaje archivado';

  @override
  String get workspaceActiveTrip => 'Viaje activo';

  @override
  String get workspaceMemberProfile => 'Perfil del miembro';

  @override
  String get workspaceTripOwner => 'Propietario del viaje';

  @override
  String get workspaceMember => 'Miembro';

  @override
  String get workspaceReadyForSettlement => 'Listo para la liquidación';

  @override
  String get workspaceNotReadyForSettlement => 'No listo para la liquidación';

  @override
  String get workspaceBankDetails => 'Datos bancarios';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'El IBAN y los datos de cobro se añadirán aquí en una próxima actualización.';

  @override
  String get workspacePaymentDetails => 'Datos de pago';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Este miembro aún no ha añadido los datos de cobro.';

  @override
  String get workspaceBankTransfer => 'Transferencia bancaria';

  @override
  String get workspaceHolder => 'Titular';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'No se pudo abrir el enlace de pago.';

  @override
  String get workspaceTripActivity => 'Actividad del viaje';

  @override
  String get workspacePaidExpenses => 'Gastos pagados';

  @override
  String get workspacePaidTotal => 'Total pagado';

  @override
  String get workspaceInvolvedIn => 'Participa en';

  @override
  String get workspaceCurrentTrip => 'Viaje actual';

  @override
  String get workspaceCommonTrips => 'Viajes en común';

  @override
  String get workspaceLoadingCommonTrips => 'Cargando viajes en común...';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Aún no se encontraron viajes en común.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'No se pudieron cargar todos los viajes en común. Mostrando el actual.';

  @override
  String get workspaceMembers => 'miembros';

  @override
  String get workspaceExpense => 'Gasto';

  @override
  String get workspacePaid => 'pagado';

  @override
  String get workspaceLoadingMoreExpenses => 'Cargando más gastos...';

  @override
  String get workspaceScrollDownToLoadMore => 'Desplázate hacia abajo para cargar más';

  @override
  String get workspaceTripFinished => 'Viaje finalizado';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Las liquidaciones están habilitadas para este viaje.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Finaliza el viaje para iniciar las liquidaciones.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 marcó la transferencia como enviada.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Esperando a que $arg1 marque como pagado.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 confirmó la recepción del pago.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Esperando a que $arg1 confirme.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Todas las liquidaciones del viaje están completamente finalizadas.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Estado final después de confirmar todas las transferencias.';

  @override
  String get workspaceSettlementFlow => 'Flujo de liquidación';

  @override
  String get workspaceActions => 'Acciones';

  @override
  String get workspaceTransferIsConfirmed => 'La transferencia está confirmada.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Esperando a que el otro miembro complete el siguiente paso.';

  @override
  String get workspaceSendReminder => 'Enviar recordatorio';

  @override
  String get workspaceInProgress => 'En curso';

  @override
  String get workspaceTimeUnknown => 'Hora desconocida';

  @override
  String get workspaceRemind => 'Recordar';

  @override
  String get workspaceYourPosition => 'Tu posición';

  @override
  String get workspaceRecentActivity => 'Actividad reciente';

  @override
  String get workspaceNoRecentActivityYet => 'Aún no hay actividad reciente.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Añade al menos un miembro para empezar a dividir gastos.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Márcate como listo para liquidar después de añadir todos tus gastos.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Esperando a que $arg1 miembro(s) se marquen como listos.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Todos los miembros están listos. Puedes finalizar el viaje e iniciar las liquidaciones.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Todos los miembros están listos. Esperando a que el propietario del viaje inicie las liquidaciones.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Liquidación en curso: $arg1/$arg2 confirmadas.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'No hay acciones pendientes. Este viaje está liquidado.';

  @override
  String get workspaceNoActionsNeededRightNow => 'No se requieren acciones en este momento.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Debes recibir $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Debes pagar $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Actualmente estás liquidado en este viaje.';

  @override
  String get workspaceUnknownTime => 'Hora desconocida';

  @override
  String get workspaceJustNow => 'Ahora mismo';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'hace $arg1 min';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'hace $arg1 h';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'hace $arg1 d';
  }

  @override
  String get friendsRemoveFriend => 'Eliminar amigo';

  @override
  String get friendsRemoveThisFriend => '¿Eliminar a este amigo?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 será eliminado de tu lista de amigos. Puedes volver a añadirlo más tarde.';
  }

  @override
  String get friendsContinue => 'Continuar';

  @override
  String get friendsFriendRemoved => 'Amigo eliminado.';

  @override
  String get friendsCouldNotRemoveFriend => 'No se pudo eliminar al amigo.';

  @override
  String get friendsFriendProfile => 'Perfil del amigo';

  @override
  String get friendsMoreActions => 'Más acciones';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Este amigo aún no ha añadido los datos de cobro.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'No se pudieron cargar los viajes en común en este momento.';

  @override
  String get friendsFinished => 'Finalizado';

  @override
  String friendsTrip(Object arg1) {
    return 'Viaje #$arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return '$arg1 miembros';
  }

  @override
  String get friendsNoDate => 'Sin fecha';

  @override
  String get friendsIncomingRequests => 'SOLICITUDES ENTRANTES';

  @override
  String get friendsSentInvites => 'INVITACIONES ENVIADAS';

  @override
  String get friendsMyFriends => 'MIS AMIGOS';

  @override
  String get friendsIncoming => 'Entrantes';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Invitación enviada a $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'No hay solicitudes entrantes';

  @override
  String get friendsDecline => 'Rechazar';

  @override
  String get friendsAccept => 'Aceptar';

  @override
  String get friendsNoSentInvites => 'No hay invitaciones enviadas';

  @override
  String get friendsNoFriendsYet => 'Aún no tienes amigos';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Desplázate hacia abajo para cargar más amigos.';

  @override
  String get friendsUser => 'Usuario';

  @override
  String get friendsSearchUsers => 'Buscar usuarios';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Busca por nombre o correo y envía una invitación';

  @override
  String get friendsScanQr => 'Escanear QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Escanea a otro usuario para añadirlo como amigo';

  @override
  String get friendsMyQr => 'Mi QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Muestra o comparte tu código QR';

  @override
  String get friendsScanFriendQrTitle => 'Escanear QR de amigo';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Coloca el código QR de tu amigo dentro del marco';

  @override
  String get friendsMyFriendQrTitle => 'Mi QR de amigo';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Abre Amigos > Escanear QR en otro teléfono y escanea este código.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Añádeme en amigos de TripSplit.';

  @override
  String get friendsTripSplitFriendCode => 'Código de amigo de TripSplit';

  @override
  String get shareAction => 'Compartir';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'El código QR no es un código de amigo válido.';

  @override
  String get friendsYouCannotAddYourself => 'No puedes añadirte a ti mismo.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Este usuario ya está en tu lista de amigos.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'La invitación a este usuario ya fue enviada.';

  @override
  String get friendsFriendRequestProcessed => 'Solicitud de amistad procesada.';

  @override
  String get friendsFailedToProcessFriendQr => 'No se pudo procesar el QR del amigo.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'No se pudo cargar tu perfil de usuario.';

  @override
  String get friendsMyProfile => 'Mi perfil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Error inesperado al cargar amigos.';

  @override
  String get friendsFriendAdded => 'Amigo añadido.';

  @override
  String get friendsRequestDeclined => 'Solicitud rechazada.';

  @override
  String get friendsFailedToUpdateRequest => 'No se pudo actualizar la solicitud.';

  @override
  String get friendsCancelInvite => 'Cancelar invitación';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return '¿Cancelar invitación a $arg1?';
  }

  @override
  String get friendsKeep => 'Mantener';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Invitación a $arg1 cancelada.';
  }

  @override
  String get friendsFailedToCancelInvite => 'No se pudo cancelar la invitación.';

  @override
  String get analyticsOther => 'Otros';

  @override
  String get analyticsSelectATripForAnalytics => 'Selecciona un viaje para ver analíticas';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • $arg2 miembros • $arg3 • $arg4';
  }

  @override
  String get analyticsMyDaily => 'Mi gasto diario';

  @override
  String get analyticsGroupDaily => 'Diario del grupo';

  @override
  String get analyticsByMember => 'Por miembro';

  @override
  String get analyticsShowLess => 'Mostrar menos';

  @override
  String get analyticsByCategory => 'Por categoría';

  @override
  String get analyticsQuickInsights => 'Resumen rápido';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Mayor gasto: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Mayor gastador: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Día de mayor gasto del grupo: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Sin fechas';

  @override
  String get friendsSearchFailedTryAgain => 'La búsqueda falló. Inténtalo de nuevo.';

  @override
  String get friendsFailedToSendInvite => 'No se pudo enviar la invitación.';

  @override
  String get friendsAddFriend => 'Añadir amigo';

  @override
  String get friendsSearchByNameOrEmail => 'Buscar por nombre o correo electrónico';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Escribe al menos 2 caracteres para buscar.';

  @override
  String get friendsNoUsersFound => 'No se encontraron usuarios';

  @override
  String get friendsInviteAction => 'Invitar';

  @override
  String get workspacePaidForGroup => 'Pagado para el grupo';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Pagado para el grupo • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Parte del gasto';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Parte del gasto • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Nombre del titular copiado.';

  @override
  String get paymentIbanCopied => 'IBAN copiado.';

  @override
  String get paymentSwiftCopied => 'SWIFT copiado.';

  @override
  String get paymentRevtagCopied => 'Revtag copiado.';

  @override
  String get paymentCouldNotCopyToClipboard => 'No se pudo copiar al portapapeles.';

  @override
  String get paymentCopied => 'Copiado.';
}
