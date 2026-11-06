// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get homeFirstTrip => 'A sua primeira viagem';

  @override
  String get homeYourShareAllTrips => 'A tua parte em todas as viagens';

  @override
  String get homeAllTime => 'Todo o período';

  @override
  String get homeSolo => 'A solo';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '$count pessoa',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Ações da viagem: $name';
  }

  @override
  String get homeNoActiveTrips => 'Sem viagens ativas';

  @override
  String get homeNoArchivedTrips => 'Sem viagens arquivadas';

  @override
  String get homeLoadingTrips => 'A carregar as suas viagens';

  @override
  String get homeLoadErrorTitle => 'Não foi possível carregar as suas viagens';

  @override
  String get homeLoadErrorBody => 'Por favor, tente novamente daqui a pouco.';

  @override
  String get homeOfflineTitle => 'Está offline';

  @override
  String get homeOfflineNoData => 'As suas viagens ainda não estão disponíveis neste dispositivo.';

  @override
  String get homeOfflineCached => 'Offline. A apresentar viagens guardadas.';

  @override
  String get homeRefreshError => 'Não foi possível atualizar. A apresentar viagens carregadas anteriormente.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Partilhar os meus dados de pagamento guardados com $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Apenas enquanto este pedido estiver a aguardar pagamento. O cancelamento do pedido encerra o acesso.';

  @override
  String get paymentDetailsUnavailable => 'Os detalhes de pagamento não estão disponíveis. Ligue-se à Internet e verifique se o pedido ainda está em aberto.';

  @override
  String get paymentDetailsRetry => 'Tente novamente';

  @override
  String get tripModeSolo => 'Só eu';

  @override
  String get tripModeGroup => 'Com outras pessoas';

  @override
  String get premiumFree => 'Gratuito';

  @override
  String get premiumStatusUnavailable => 'Estado do plano indisponível';

  @override
  String premiumGrantedUntil(String date) {
    return 'Acesso Premium concedido até $date';
  }

  @override
  String get premiumBillingNotActive => 'Sem subscrição ativa';

  @override
  String get premiumRefreshStatus => 'Atualizar o estado do plano';

  @override
  String get accountSectionTitle => 'Conta';

  @override
  String get activeStatus => 'Ativo';

  @override
  String get activeTripPlural => 'viagens ativas';

  @override
  String get activeTripSingle => 'viagem ativa';

  @override
  String get activeTrips => 'Viagens ativas';

  @override
  String get activitiesComingSoon => 'A secção de atividades estará disponível em breve.';

  @override
  String get addAction => 'Adicionar';

  @override
  String get addExpenseTitle => 'Adicionar despesa';

  @override
  String get addExpensesAction => 'Adicionar despesas';

  @override
  String get addMembersAction => 'Adicionar membros';

  @override
  String get addTripMembersTitle => 'Convidar membros da viagem';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count convites enviados',
      one: '$count convite enviado',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Convite para a viagem recusado.';

  @override
  String get tripInviteAction => 'Convidar';

  @override
  String get tripInvitationsPending => 'A aguardar resposta';

  @override
  String get tripInvitationsRetry => 'Convites indisponíveis. Tente novamente';

  @override
  String get tripInvitationRevoke => 'Cancelar convite';

  @override
  String get tripInvitationRevokeFailed => 'Não foi possível cancelar o convite. Tente novamente.';

  @override
  String get tripInvitationBody => 'Foste convidado para uma viagem. Abre o convite para responder.';

  @override
  String get allCaughtUp => 'Tudo em dia';

  @override
  String get allFilter => 'Todos';

  @override
  String get allMembersLabel => 'Todos os membros';

  @override
  String get allPaymentsConfirmed => 'Todos os pagamentos são confirmados.';

  @override
  String get allTrips => 'Todas as viagens';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Montante';

  @override
  String get amountMustBeGreaterThanZero => 'O montante deve ser superior a 0.';

  @override
  String get appearance => 'Aparência';

  @override
  String get archivedStatus => 'Arquivado';

  @override
  String get authSubtitleLogin => 'Divida as despesas de viagem com os amigos';

  @override
  String get authSubtitleRegister => 'Crie uma conta e comece a dividir as viagens';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'confirmado: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'pendente: $count';
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
  String get changeEmailWithPasswordHelper => 'Introduza a sua palavra-passe para alterar o e-mail.';

  @override
  String get chooseReceiptFile => 'Escolha o ficheiro de recibo';

  @override
  String get completeAccountSetupDescription => 'Defina o seu e-mail e palavra-passe para concluir a criação da sua conta.';

  @override
  String get completeAccountSetupTitle => 'Concluir a configuração da conta';

  @override
  String get confirmReceivedAction => 'Confirmar receção';

  @override
  String get confirmedAllSettlementsArchived => 'Todas as liquidações confirmadas. Viagem arquivada.';

  @override
  String get confirmedAsReceived => 'Recebido e confirmado.';

  @override
  String get confirmedLabel => 'Confirmado';

  @override
  String get couldNotOpenReceiptLink => 'Não foi possível abrir o link do recibo.';

  @override
  String get createAction => 'Criar';

  @override
  String get createFirstTripHint => 'Cria a tua primeira viagem para começares.';

  @override
  String get createNewTripTitle => 'Criar nova viagem';

  @override
  String get createTripAction => 'Criar viagem';

  @override
  String get createTripFirst => 'Crie primeiro uma viagem.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Criado por $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'O criador da viagem deve concluir a viagem para iniciar a confirmação da liquidação.';

  @override
  String currentEmailLabel(Object email) {
    return 'E-mail atual: $email';
  }

  @override
  String get currentReceiptAttached => 'O recibo atual encontra-se em anexo.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Data';

  @override
  String get dateMustMatchFormat => 'A data deve estar no formato YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Data desconhecida';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get deleteExpenseConfirmQuestion => 'Apagar esta despesa?';

  @override
  String get deleteExpenseTitle => 'Eliminar despesa';

  @override
  String get editExpenseConfirmTitle => 'Guardar alterações nas despesas?';

  @override
  String get editExpenseConfirmText => 'Isto atualizará os saldos de todos os participantes da viagem.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Explicado diretamente pelas despesas: $amount';
  }

  @override
  String get doneStatus => 'Concluído';

  @override
  String get editAction => 'Editar';

  @override
  String get editExpenseTitle => 'Editar despesas';

  @override
  String get emailAddressLabel => 'Endereço de e-mail';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'E- mail';

  @override
  String get emailRequired => 'É necessário um endereço de e-mail.';

  @override
  String get enterValidExactAmounts => 'Introduza montantes válidos e exatos para todos os participantes.';

  @override
  String get enterValidPercentages => 'Introduza percentagens válidas para todos os participantes.';

  @override
  String get equalSplitLabel => 'Divisão igual';

  @override
  String exactAmountWithValue(Object value) {
    return 'Exato: $value';
  }

  @override
  String get exactAmountsLabel => 'Montantes exatos';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'A divisão exata deve totalizar $amount.';
  }

  @override
  String get expenseAdded => 'Despesa adicionada.';

  @override
  String get expenseBreakdownSubtitle => 'Como este membro é afetado por cada despesa.';

  @override
  String get expenseBreakdownTitle => 'Discriminação de despesas';

  @override
  String get expenseDeleted => 'Despesa eliminada.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Despesa n.º $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Pago $paid  -  A dever $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reações';

  @override
  String get expenseCommentsTitle => 'Comentários';

  @override
  String get expenseNoComments => 'Ainda não há comentários.';

  @override
  String get expenseAddCommentHint => 'Adicionar um comentário...';

  @override
  String get expenseCommentSend => 'Enviar';

  @override
  String get expenseMentionNoMatches => 'Nenhum membro corresponde';

  @override
  String get expenseMentionMembersLabel => 'Membros da viagem a mencionar';

  @override
  String get expenseDeleteCommentTitle => 'Apagar comentário?';

  @override
  String get expenseUpdated => 'Despesa atualizada.';

  @override
  String expenseWithId(Object id) {
    return 'Despesa n.º $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count despesas',
      one: '$count despesa',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Despesas';

  @override
  String get failedToCreateTrip => 'Não foi possível criar a viagem.';

  @override
  String get failedToLoadUsersDirectory => 'Não foi possível carregar o diretório de utilizadores.';

  @override
  String get filterSettlementByMemberSubtitle => 'Filtrar liquidações por membro';

  @override
  String get finishSoloTripConfirmationText => 'Quer encerrar esta viagem e movê-la para o seu arquivo? As suas despesas continuarão disponíveis para consulta.';

  @override
  String get soloTripArchived => 'Viagem concluída e arquivada.';

  @override
  String get finishTripSyncPending => 'Sincronize as suas alterações pendentes antes de concluir esta viagem.';

  @override
  String get finishTripAction => 'Concluir a viagem';

  @override
  String get finishTripConfirmationText => 'Concluir esta viagem e iniciar as liquidações?';

  @override
  String get finishTripStartSettlementsAction => 'Concluir e iniciar liquidações';

  @override
  String get finishTripTitle => 'Concluir a viagem';

  @override
  String forParticipants(Object participants) {
    return 'Para: $participants';
  }

  @override
  String get forgotPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get profileSetPassword => 'Definir palavra-passe';

  @override
  String get profileManagePassword => 'Definir ou alterar palavra-passe';

  @override
  String get profilePasswordByEmail => 'Definir palavra-passe por e-mail';

  @override
  String get passwordEmailBackToProfile => 'Voltar ao perfil';

  @override
  String get forgotPasswordSubtitle => 'Introduza o seu e-mail e enviar-lhe-emos um link para redefinir a palavra-passe.';

  @override
  String get forgotPasswordSuccessMessage => 'Se existir uma conta com este endereço de e-mail, enviámos-lhe um link para redefinir a palavra-passe.';

  @override
  String get passwordResetSentTitle => 'Verifique a sua caixa de entrada';

  @override
  String get passwordResetSentHint => 'A ligação é válida durante 1 hora. Se não vir o e-mail, verifique a pasta de spam.';

  @override
  String get forgotPasswordTitle => 'Reiniciar palavra-passe';

  @override
  String get friendsProgressSubtitle => 'Cada membro e o seu estado de confirmação.';

  @override
  String get friendsProgressTitle => 'Progresso dos amigos';

  @override
  String get friendsSectionComingSoon => 'A secção «Amigos» estará disponível em breve.';

  @override
  String fromDirection(Object name) {
    return 'De $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from a $to';
  }

  @override
  String get generateTurnAction => 'Sortear a próxima pessoa';

  @override
  String get hasAccountQuestion => 'Já tem uma conta?';

  @override
  String helloUser(Object name) {
    return 'Olá, $name!';
  }

  @override
  String get iSentAction => 'Enviei';

  @override
  String get invalidEmailFormat => 'Formato de e-mail inválido.';

  @override
  String get languageAction => 'Idioma';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageLatvian => 'Letão';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageSystemSubtitle => 'Usar o idioma do dispositivo';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Deixe em branco para manter a palavra-passe atual.';

  @override
  String get logInButton => 'Iniciar sessão';

  @override
  String get logOutButton => 'Terminar sessão';

  @override
  String get logoutFromDeviceQuestion => 'Sair deste dispositivo?';

  @override
  String get logoutRevocationUnconfirmed => 'Saiu da sua conta neste dispositivo. Não foi possível confirmar a revogação da sessão no servidor.';

  @override
  String get markedAsSent => 'Marcado como enviado.';

  @override
  String get markSettlementSentConfirmTitle => 'Marcar a transferência como enviada?';

  @override
  String get markSettlementSentConfirmText => 'Utilize esta funcionalidade apenas depois de ter efetivamente enviado o pagamento. Será solicitada uma confirmação ao destinatário.';

  @override
  String get settlementCancelSentAction => 'Marcar como não enviado';

  @override
  String get settlementCancelSentConfirmTitle => 'Cancelar o estado «enviado»?';

  @override
  String get settlementCancelSentConfirmText => 'Isto fará com que a transferência volte ao estado «pendente» e notificará o destinatário.';

  @override
  String get settlementSentCancelled => 'A transferência voltou ao estado «pendente».';

  @override
  String get settlementNotReceivedAction => 'Não recebi isto';

  @override
  String get settlementNotReceivedConfirmTitle => 'Comunicar que não recebeste o pagamento?';

  @override
  String get settlementNotReceivedConfirmText => 'Isto fará com que a transferência volte ao estado «pendente» e notificará o pagador.';

  @override
  String get settlementMarkedNotReceived => 'Marcado como não recebido.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Confirmado o recebimento?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Confirme apenas depois de o dinheiro estar visível na sua conta. Esta ação pode concluir a liquidação.';

  @override
  String get memberSummariesSubtitle => 'Saldo atual para ambas as partes.';

  @override
  String get memberSummariesTitle => 'Resumos dos membros';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Para pagar $total  -  confirmado $confirmed  -  em espera $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Impacto estimado do pagamento por membro.';

  @override
  String get membersImpactTitle => 'Impacto dos membros';

  @override
  String get membersIncludedInExpense => 'Membros incluídos';

  @override
  String get membersLabel => 'Membros';

  @override
  String moreCount(Object count) {
    return '+ $count mais';
  }

  @override
  String get myFilter => 'O meu';

  @override
  String get myImpactTitle => 'O meu impacto';

  @override
  String get firstNameHint => 'O seu primeiro nome';

  @override
  String get firstNameLabel => 'Nome próprio';

  @override
  String get firstNameLengthValidation => 'O nome próprio deve ter entre 2 e 64 caracteres.';

  @override
  String get fullNameHelper => 'Utilize o nome e o apelido num único campo.';

  @override
  String get fullNameHint => 'por exemplo, Anna Ozolina';

  @override
  String get fullNameLabel => 'Nome completo';

  @override
  String get fullNameValidation => 'Introduza o nome e o apelido (pelo menos 2 caracteres cada).';

  @override
  String get lastNameHint => 'O seu apelido';

  @override
  String get lastNameLabel => 'Apelido';

  @override
  String get lastNameLengthValidation => 'O apelido deve ter entre 2 e 64 caracteres.';

  @override
  String get nameHint => 'O seu nome';

  @override
  String get nameLabel => 'Nome';

  @override
  String get nameLengthValidation => 'O nome deve ter, pelo menos, 2 caracteres.';

  @override
  String get navActivities => 'Estatísticas';

  @override
  String get navAddTrip => 'Adicionar viagem';

  @override
  String get navBalances => 'Saldos';

  @override
  String get navExpenses => 'Despesas';

  @override
  String get navFriends => 'Amigos';

  @override
  String get navHome => 'Início';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navRandom => 'Aleatório';

  @override
  String get netLabel => 'Saldo líquido';

  @override
  String get newPasswordLabel => 'Nova senha';

  @override
  String get nicknameHint => 'Como os amigos o verão';

  @override
  String get nicknameLabel => 'Apelido';

  @override
  String get nicknameLengthValidation => 'O apelido deve ter, pelo menos, 2 caracteres.';

  @override
  String get noAccountQuestion => 'Ainda não tem conta?';

  @override
  String get noBalancesYet => 'Ainda não há saldos.';

  @override
  String get noChangesToSave => 'Não há alterações para guardar.';

  @override
  String get noDirectExpenseLink => 'Não foi encontrado nenhum link direto para uma despesa específica. Este acerto é calculado a partir do saldo total da viagem.';

  @override
  String get noExpenseImpactForMember => 'Não há impacto nas despesas para este membro.';

  @override
  String noExpensesByUserYet(Object name) {
    return 'Ainda não há despesas para $name.';
  }

  @override
  String get noExpensesYet => 'Ainda não há despesas.';

  @override
  String get noExtraUsersToAdd => 'Não é necessário adicionar utilizadores adicionais.';

  @override
  String get noInternetDeleteQueued => 'Sem ligação à Internet. Eliminar da fila.';

  @override
  String get noInternetExpenseQueued => 'Sem ligação à Internet. Despesa em fila.';

  @override
  String get noInternetUpdateQueued => 'Sem ligação à Internet. Atualização em fila.';

  @override
  String get noMatchingRows => 'Não foram encontradas linhas correspondentes.';

  @override
  String get noMembersFound => 'Não foram encontrados membros.';

  @override
  String get noNewMembersAdded => 'Estas pessoas já são membros ou têm convites pendentes.';

  @override
  String get noNotePlaceholder => 'Sem notas';

  @override
  String get notificationsToday => 'Hoje';

  @override
  String get notificationsEmptyBody => 'As atualizações sobre viagens, despesas e amigos aparecerão aqui.';

  @override
  String get notificationsCached => 'Offline — exibição de notificações guardadas.';

  @override
  String get notificationsRefreshFailed => 'Não foi possível atualizar. São apresentadas as notificações carregadas anteriormente.';

  @override
  String get notificationsJustNow => 'Agora mesmo';

  @override
  String notificationsMinutesAgo(int count) {
    return 'Há $count min';
  }

  @override
  String notificationsHoursAgo(int count) {
    return 'Há $count h';
  }

  @override
  String get notificationsUnread => 'Não lido';

  @override
  String get noNotificationsYet => 'Ainda não há notificações.';

  @override
  String get noParticipantData => 'Não há dados dos participantes.';

  @override
  String get noParticipantsSelected => 'Não foram selecionados participantes.';

  @override
  String get noPaymentRowsInTrip => 'Não há registos de pagamento nesta viagem.';

  @override
  String get noPaymentsNeeded => 'Não são necessários pagamentos.';

  @override
  String get noPicksYet => 'Ainda não há escolhas.';

  @override
  String get noSettlementActivityForMember => 'Não há atividade de liquidação para este membro.';

  @override
  String get noSettlementRowsYet => 'Ainda não existem linhas de liquidação.';

  @override
  String get noSettlements => 'Sem acertos de contas';

  @override
  String get noTransferNeededForFilter => 'Não é necessária qualquer transferência para o filtro selecionado.';

  @override
  String get noTransferRowsToShow => 'Não há linhas de transferência para apresentar.';

  @override
  String get noTripDataLoaded => 'Não foram carregados dados da viagem.';

  @override
  String get noTripsYet => 'Ainda não há viagens.';

  @override
  String get noUsersFoundYet => 'Ainda não foram encontrados utilizadores.';

  @override
  String get notSetValue => 'Não definido';

  @override
  String get notYetConfirmedTitle => 'Ainda não confirmado';

  @override
  String get noteHint => 'Jantar, táxi, bilhetes...';

  @override
  String get noteLabel => 'Nota';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'A nota deve ter, no máximo, $max caracteres.';
  }

  @override
  String get notificationFallbackTitle => 'Notificação';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationFriendInviteTitle => 'Pedido de amizade';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name enviou-lhe um convite de amizade.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Recebeste um convite de amizade.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Convite aceite';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name aceitou o teu convite de amizade.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'O teu convite de amizade foi aceite.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Convite recusado';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name recusou o teu convite de amizade.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'O teu convite de amizade foi recusado.';

  @override
  String get notificationTripAddedTitle => 'Adicionado à viagem';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name adicionou-te à viagem «$trip».';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Foste adicionado à viagem «$trip».';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Foste adicionado a uma viagem.';

  @override
  String get notificationExpenseAddedTitle => 'Nova despesa adicionada';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name adicionou uma despesa de $amount na «$trip».';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name adicionou uma despesa de $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Foi adicionada uma nova despesa.';

  @override
  String get notificationCommentMentionTitle => 'Foste mencionado num comentário';

  @override
  String notificationCommentMentionBody(Object name, Object note) {
    return '$name mencionou-te num comentário sobre «$note».';
  }

  @override
  String notificationCommentMentionBodyGeneric(Object name) {
    return '$name mencionou-te num comentário.';
  }

  @override
  String get notificationTripFinishedTitle => 'Viagem concluída';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name concluiu a «$trip». As liquidações estão prontas.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name concluiu a «$trip». A viagem foi arquivada.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '«$trip» foi concluída.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'O estado da viagem foi atualizado.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Membro marcado como pronto';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name está pronto para participar na «$trip».';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Um membro está pronto para participar na «$trip».';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Um membro está pronto para efetuar o pagamento.';

  @override
  String get notificationTripReadyToSettleTitle => 'Todos os membros estão prontos';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Todos os membros estão marcados como prontos em «$trip». Pode iniciar as liquidações.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Todos os membros estão prontos. Pode iniciar as liquidações.';

  @override
  String get notificationSettlementReminderTitle => 'Lembrete de liquidação';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor lembrou $target de marcar $amount como enviado.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor lembrou $target de confirmar a receção de $amount.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Recebeste um lembrete de liquidação.';

  @override
  String get notificationPaymentReminderTitle => 'Lembrete de pagamento';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Lembrete: por favor, marque $amount como enviado para $target em «$trip».';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Lembrete: por favor, marque o pagamento como enviado.';

  @override
  String get notificationConfirmationReminderTitle => 'Lembrete de confirmação';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Lembrete: por favor, confirme a receção de $amount de $payer na «$trip».';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Lembrete: por favor, confirme a receção do pagamento.';

  @override
  String get notificationSettlementSentTitle => 'Transferência marcada como enviada';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name marcou $amount como enviado para si.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Uma transferência foi marcada como enviada.';

  @override
  String get notificationSettlementConfirmedTitle => 'Transferência confirmada';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name confirmou a receção de $amount de si.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Foi confirmada uma transferência.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações pendentes',
      one: '$count alteração pendente',
    );
    return 'Fila offline: $_temp0';
  }

  @override
  String get syncAllSynced => 'Tudo sincronizado';

  @override
  String syncChangesWaiting(Object count) {
    return '$count à espera de sincronização';
  }

  @override
  String get syncFailedTapToRetry => 'Falha na sincronização, toque para tentar novamente';

  @override
  String get offlineQueueStatus => 'Fila offline';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Online';

  @override
  String get onlyCreatorCanFinishTrip => 'Apenas o criador da viagem pode concluir a viagem.';

  @override
  String get openLabel => 'Abrir';

  @override
  String get openReceiptAction => 'Abrir recibo';

  @override
  String get openSettlements => 'Abrir acertos de contas';

  @override
  String get overviewTitle => 'Visão geral';

  @override
  String get owesLabel => 'Tem a pagar';

  @override
  String get paidByLabel => 'Pago por';

  @override
  String get paidLabel => 'Pago';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Pago $paid -  A deve $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Participantes (vazio = todos os membros)';

  @override
  String get participantsTitle => 'Participantes';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get passwordComplexityHelper => 'Utilize, pelo menos, 1 letra maiúscula, 1 número e 1 símbolo.';

  @override
  String get passwordComplexityValidation => 'A palavra-passe deve incluir 1 letra maiúscula, 1 número e 1 símbolo.';

  @override
  String get passwordMinLength => 'A palavra-passe deve ter, pelo menos, 8 caracteres.';

  @override
  String get passwordMinLengthShort => 'A palavra-passe deve ter, pelo menos, 6 caracteres.';

  @override
  String get passwordResetComingSoon => 'A reposição da palavra-passe estará disponível em breve.';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe não coincidem.';

  @override
  String payerName(Object name) {
    return '$name (pagador)';
  }

  @override
  String get pendingLabel => 'Pendente';

  @override
  String get pendingPaymentsSubtitle => 'Pagamentos ainda à espera de confirmação total.';

  @override
  String get percentLabel => 'Porcentagem';

  @override
  String get percentSplitMustBe100 => 'A divisão em percentagens deve totalizar exatamente 100%.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Percentagens';

  @override
  String get pickAtLeastOneParticipant => 'Escolha pelo menos um participante.';

  @override
  String get pickMembersGenerateTurn => 'Escolhe os participantes e sorteia a próxima pessoa.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name selecionado. Ciclo concluído.';
  }

  @override
  String pickedUser(Object name) {
    return '$name selecionado.';
  }

  @override
  String get profileRefreshCachedData => 'Não foi possível atualizar o perfil. A apresentar dados em cache.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileUpdated => 'Perfil atualizado.';

  @override
  String get uploadAvatarAction => 'Carregar avatar';

  @override
  String get takePhotoAction => 'Tira uma fotografia.';

  @override
  String get chooseFromLibraryAction => 'Escolha na Biblioteca';

  @override
  String get removeAvatarAction => 'Remover avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar atualizado.';

  @override
  String get avatarRemovedMessage => 'Avatar removido.';

  @override
  String get avatarFileTooLarge => 'O ficheiro do avatar é demasiado grande (máx. 5 MB).';

  @override
  String get avatarPickFailed => 'Não foi possível carregar a imagem do avatar.';

  @override
  String get queueAddExpense => 'Adicionar despesa';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'Em fila: adicionar despesa $amount';
  }

  @override
  String get queueDeleteExpense => 'Eliminar despesa';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'Em fila: eliminar despesa n.º $id';
  }

  @override
  String get queuePendingStatus => 'Fila pendente';

  @override
  String get queueUpdateExpense => 'Atualizar despesas';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'Em fila: atualizar despesa n.º $id';
  }

  @override
  String get queuedChange => 'Alteração em fila';

  @override
  String queuedChangesTitle(Object count) {
    return 'Alterações em fila ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'Em fila ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Ciclo $cycleNo, desenho $drawNo - restam $remaining';
  }

  @override
  String get receiptFallbackName => 'recibo';

  @override
  String get receiptLinkInvalid => 'O link do recibo é inválido.';

  @override
  String get receiptOptionalLabel => 'Recibo (opcional)';

  @override
  String get recentPicksTitle => 'Últimos sorteios';

  @override
  String get reloadProfile => 'Atualizar perfil';

  @override
  String get rememberMe => 'Lembrar-me';

  @override
  String get removeCurrentReceipt => 'Remover o recibo atual';

  @override
  String get repeatNewPasswordLabel => 'Repita a nova palavra-passe';

  @override
  String get repeatPasswordLabel => 'Repita a palavra-passe';

  @override
  String get requestFailedTryAgain => 'A solicitação falhou. Tente novamente.';

  @override
  String get retryAction => 'Tentar novamente';

  @override
  String get rowsLabel => 'Linhas';

  @override
  String get backToLoginAction => 'Voltar ao início de sessão';

  @override
  String get saveAction => 'Guardar';

  @override
  String get saveCredentialsButton => 'Guardar credenciais';

  @override
  String get saveProfileButton => 'Guardar perfil';

  @override
  String get sendResetLinkButton => 'Enviar link de redefinição';

  @override
  String get searchUsersHint => 'Pesquise pessoas por nome ou e-mail';

  @override
  String get selectedPeopleLabel => 'Pessoas selecionadas';

  @override
  String get noSearchMatches => 'Não foram encontrados utilizadores correspondentes.';

  @override
  String get savingButton => 'A guardar...';

  @override
  String get selectAtLeastTwoMembers => 'Selecione pelo menos dois membros.';

  @override
  String get selectMembersHint => 'Selecionar membros';

  @override
  String selectedFileLabel(Object name) {
    return 'Selecionado: $name';
  }

  @override
  String get selectedLabel => 'Seleccionado';

  @override
  String get selectedUserFallback => 'Utilizador selecionado';

  @override
  String get settings => 'Definições';

  @override
  String get settleUpAction => 'Acertar contas';

  @override
  String get settledLabel => 'Saldado';

  @override
  String get settledStatus => 'Saldado';

  @override
  String get settlementActivitySubtitle => 'Transferências associadas a este membro.';

  @override
  String get settlementActivityTitle => 'Atividade de liquidação';

  @override
  String get settlementCompletedTitle => 'Liquidação concluída';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed/$total confirmado';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Acertos de contas: $count';
  }

  @override
  String get settlementImpactTitle => 'Impacto na liquidação';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Impacto na liquidação: $name';
  }

  @override
  String get settlementInProgress => 'Liquidação em curso';

  @override
  String get settlementInProgressTitle => 'Liquidação em curso';

  @override
  String get settlementLabel => 'Acerto de contas';

  @override
  String get settlementOverviewArchivedSubtitle => 'Viagem arquivada. Todas as liquidações concluídas.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Acompanhe as confirmações de liquidação.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Visualize as transferências para quando a viagem terminar.';

  @override
  String get settlementPreview => 'Pré-visualização da liquidação';

  @override
  String get settlementPreviewTitle => 'Pré-visualização da liquidação';

  @override
  String get settlementProgressTripArchived => 'Viagem arquivada';

  @override
  String settlementWithId(Object id) {
    return 'Liquidação n.º $id';
  }

  @override
  String get settlements => 'Acertos de contas';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Liquidações já concluídas.';

  @override
  String get settlementsDone => 'Liquidações efetuadas';

  @override
  String get settlingStatus => 'Liquidação';

  @override
  String get shareUnit => 'parte';

  @override
  String get sharesLabel => 'Partes';

  @override
  String get sharesMustBePositiveIntegers => 'O número de partes deve ser um inteiro positivo.';

  @override
  String sharesWithValue(Object value) {
    return 'Partes: $value';
  }

  @override
  String get showActiveTrips => 'Mostrar viagens ativas';

  @override
  String get signUpButton => 'Registar';

  @override
  String get splitBreakdownSubtitle => 'Como é repartida a despesa';

  @override
  String get splitBreakdownTitle => 'Discriminação da divisão';

  @override
  String get splitHintEqual => 'Divida igualmente entre os participantes selecionados.';

  @override
  String get splitHintExact => 'Introduza o montante exato para cada participante. A soma deve corresponder ao total.';

  @override
  String get splitHintPercent => 'Introduza a percentagem para cada participante. A soma deve ser 100%.';

  @override
  String get splitHintShares => 'Introduza as unidades de partilha (1, 2, 3...). O custo é dividido proporcionalmente.';

  @override
  String get splitLabel => 'Dividir';

  @override
  String splitLabelValue(Object value) {
    return 'Divisão: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Divisão igualitária ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Montantes exatos ($target)';
  }

  @override
  String get splitModeLabel => 'Modo de divisão';

  @override
  String splitModePercent(Object target) {
    return 'Percentagens ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Partes ($target)';
  }

  @override
  String get statusConfirmed => 'Confirmado';

  @override
  String get statusPending => 'Pendente';

  @override
  String get statusSent => 'Enviado';

  @override
  String get statusSuggested => 'Sugerido';

  @override
  String statusWithValue(Object status) {
    return 'Estado: $status';
  }

  @override
  String get suggestedTransferDirections => 'Sentidos dos pagamentos sugeridos';

  @override
  String get suggestedTransferFromExpense => 'Transferência sugerida a partir de despesas';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transferências sugeridas',
      one: '$count transferência sugerida',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Linhas esperadas: pagador -> destinatário.';

  @override
  String get suggestedTransfersTitle => 'Transferências sugeridas';

  @override
  String get summarySettledUp => 'Saldado';

  @override
  String get summaryYouAreOwed => 'Têm de te pagar';

  @override
  String get summaryYouOwe => 'Tens a pagar';

  @override
  String get syncAction => 'Sincronizar';

  @override
  String get syncNowAction => 'Sincronizar agora';

  @override
  String get syncingStatus => 'Sincronização';

  @override
  String get tapToViewDetails => 'Toque para ver os detalhes';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get themeModeDarkSubtitle => 'Preto suave (não preto puro)';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeSystemSubtitle => 'Utilize a aparência do dispositivo';

  @override
  String toDirection(Object name) {
    return 'Para $name';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String get travelerFallbackName => 'Viajante';

  @override
  String get tripAlreadyClosed => 'Viagem já encerrada.';

  @override
  String get tripArchivedReadOnly => 'A viagem é arquivada. Modo de leitura apenas.';

  @override
  String get tripClosedExpenseEditingDisabled => 'A viagem está encerrada. A edição de despesas está desativada.';

  @override
  String get tripClosedExpensesReadOnly => 'A viagem está encerrada. As despesas são de leitura apenas.';

  @override
  String get tripClosedRandomDisabled => 'A viagem está encerrada. O sorteio aleatório está desativado.';

  @override
  String tripCreated(Object name) {
    return 'Viagem «$name» criada.';
  }

  @override
  String get tripFinished => 'Viagem concluída.';

  @override
  String get tripFinishedCompleteSettlements => 'A viagem terminou. Conclua as liquidações.';

  @override
  String get tripFinishedSettlementStarted => 'Viagem concluída. Liquidação iniciada.';

  @override
  String get tripFullySettledArchived => 'Viagem totalmente liquidada e arquivada.';

  @override
  String get tripNameHint => 'Viagem de esqui à Áustria';

  @override
  String get tripNameLabel => 'Nome da viagem';

  @override
  String get tripNameLengthValidation => 'O nome da viagem deve ter, pelo menos, 2 caracteres.';

  @override
  String get tripSnapshotTitle => 'Resumo da viagem';

  @override
  String get tripTitleShort => 'Viagem';

  @override
  String tripStatusWithValue(Object status) {
    return 'Estado da viagem: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Viagem n.º $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Erro inesperado ao carregar o perfil';

  @override
  String get unexpectedErrorLoadingTripData => 'Erro inesperado ao carregar os dados da viagem';

  @override
  String get unexpectedErrorLoadingTrips => 'Erro inesperado ao carregar viagens';

  @override
  String get unexpectedErrorSavingChanges => 'Erro inesperado ao guardar as alterações';

  @override
  String get unexpectedErrorSavingCredentials => 'Erro inesperado ao guardar credenciais';

  @override
  String get unexpectedErrorUpdatingProfile => 'Erro inesperado ao atualizar o perfil';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get unknownLabel => 'Desconhecido';

  @override
  String get unreadLabel => 'Não lido';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atualizações não lidas',
      one: '$count atualização não lida',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Falta o argumento da rota da viagem.';

  @override
  String userIdLabel(Object id) {
    return 'ID do utilizador: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Pago $paid  -  A dever $owes  -  Líquido $net';
  }

  @override
  String userWithId(Object id) {
    return 'Utilizador $id';
  }

  @override
  String get valueLabel => 'Valor';

  @override
  String get viewAllTrips => 'Ver todas as viagens';

  @override
  String get viewByPersonTitle => 'Ver por pessoa';

  @override
  String get whoOwesWhatSubtitle => 'Quem pagou e quem deve.';

  @override
  String get whoOwesWhatTitle => 'Quem deve o quê';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Quem deve o quê: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Linhas de despesas que contribuem para esta transferência.';

  @override
  String get whyPaymentExistsTitle => 'Por que razão este pagamento existe';

  @override
  String get youLabel => 'Você';

  @override
  String get youSettledForExpense => 'Já saldaste a tua parte desta despesa.';

  @override
  String youShouldPay(Object amount) {
    return 'Devias pagar. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Deve receber $amount';
  }

  @override
  String get yourShare => 'A sua parte';

  @override
  String get yourTrips => 'As suas viagens';

  @override
  String get authIntroSplitSmarter => 'Divida de forma mais inteligente.';

  @override
  String get authIntroTravelFree => 'Viaja em liberdade.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Acompanhe os custos partilhados em várias moedas e faça a liquidação instantaneamente — sem promissórias embaraçosas.';

  @override
  String get authIntroPlanTogether => 'Planear em conjunto.';

  @override
  String get authIntroPayClearly => 'Pague de forma clara.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Crie viagens em segundos, adicione amigos e mantenha todas as despesas transparentes para todos.';

  @override
  String get authIntroSettleFast => 'Resolva rapidamente.';

  @override
  String get authIntroStayFriends => 'Continuemos amigos.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Desde jantares partilhados a viagens completas, o Splyto mantém os saldos justos e sem stress.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Falha no início de sessão da Apple. Por favor, tente novamente.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Falha no início de sessão do Google. Por favor, tente novamente.';

  @override
  String get authIntroCreateAccount => 'Crie a sua conta.';

  @override
  String get authIntroChooseSign => 'Escolha como pretende inscrever-se.';

  @override
  String get authIntroContinueGoogle => 'Continuar com o Google';

  @override
  String get authIntroContinueApple => 'Continuar com a Apple';

  @override
  String get authIntroBack => 'Voltar';

  @override
  String get authIntroSplitSettled => 'Divisão de custos concluída';

  @override
  String get authIntroParis3Friends => 'Paris · 3 amigos';

  @override
  String get authIntroGetStarted => 'Começar';

  @override
  String get authIntroAlreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get authIntroSignIn => 'Iniciar sessão';

  @override
  String get authIntroSignUpWithEmail => 'Registe-se com o e-mail';

  @override
  String get authIntroOr => 'OU';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'O início de sessão do Google não devolveu um token de identificação.';

  @override
  String get authAppleSignAvailableIosDevices => 'O início de sessão com a Apple está disponível em dispositivos iOS.';

  @override
  String get authAppleSignNotAvailableDevice => 'O início de sessão da Apple não está disponível neste dispositivo.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'O início de sessão da Apple não devolveu um token de identidade.';

  @override
  String get authCancel => 'Cancelar';

  @override
  String get authSendLink => 'Enviar link';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'O e-mail não está verificado. Introduza o seu e-mail para solicitar o link de verificação.';

  @override
  String get authEmailNotVerified => 'E-mail não verificado';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Enviar link de verificação para $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Link de verificação enviado. Verifique o seu e-mail.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Não foi possível enviar o link de verificação. Por favor, tente novamente.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'E-mail de verificação enviado. Por favor, verifique o seu e-mail antes de iniciar sessão.';

  @override
  String get authVerifyEmail => 'Verifique o seu e-mail';

  @override
  String get authEmailLabel => 'E-mail:';

  @override
  String get authClose => 'Fechar';

  @override
  String get authResendLink => 'Reenviar link';

  @override
  String get profileAppSettingsSectionTitle => 'CONFIGURAÇÕES DA APLICAÇÃO';

  @override
  String get profileAccountSettings => 'Definições da conta';

  @override
  String get profileChangePhoto => 'Alterar foto de perfil';

  @override
  String get profileAppearance => 'Aparência';

  @override
  String get profileThemeDisplayMode => 'Tema e modo de visualização';

  @override
  String get profileLanguage => 'Língua';

  @override
  String get profileDisplayLanguage => 'Idioma de visualização';

  @override
  String get profileNotificationsSectionHeading => 'NOTIFICAÇÕES';

  @override
  String get profileAppBanners => 'Banners na aplicação';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Mostrar novos banners de notificação dentro da aplicação';

  @override
  String get profilePushNotificationsTitle => 'Notificações push';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Notificações no telemóvel sobre despesas, amigos, viagens e liquidações';

  @override
  String get profileSupportSectionHeading => 'SUPORTE';

  @override
  String get profileContactUs => 'Contacte-nos';

  @override
  String get profileReportBugSuggestion => 'Reportar bug / Sugestão';

  @override
  String get profileRateSplyto => 'Avalie o Splyto';

  @override
  String get profileLeaveStoreRating => 'Deixe uma avaliação da loja';

  @override
  String get profileSecuritySectionHeading => 'SEGURANÇA';

  @override
  String get profileAccountAndSecurity => 'Conta e segurança';

  @override
  String get profileHelpTitle => 'Ajuda';

  @override
  String get profileChangePassword => 'Alterar palavra-passe';

  @override
  String get profileUpdateAccountPassword => 'Atualizar a palavra-passe da conta';

  @override
  String get profileDangerZoneSectionHeading => 'ZONA DE PERIGO';

  @override
  String get profileManageAccountAccess => 'Gerir o acesso à conta';

  @override
  String get profileMadeWithLabel => 'Criado com';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'A ação de avaliação da loja será associada no próximo passo.';

  @override
  String get profileFailedSaveNotificationSettings => 'Não foi possível guardar as definições de notificações.';

  @override
  String get profilePushNotificationsSectionTitle => 'NOTIFICAÇÕES PUSH';

  @override
  String get profileInAppBannersSectionTitle => 'BANNERS NA APLICAÇÃO';

  @override
  String get profileInAppTripMemberAddedTitle => 'Membro adicionado à viagem';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Lembrete automático de liquidação';

  @override
  String get profileExpenseUpdates => 'Atualizações de despesas';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Foram adicionados banners de despesas no interior da aplicação';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Notificações de despesas adicionadas ao telemóvel';

  @override
  String get profileFriendInvites => 'Convites de amigos';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Banners de pedidos de amizade e respostas dentro da aplicação';

  @override
  String get profileFriendRequestResponseNotifications => 'Notificações de pedidos de amizade e respostas';

  @override
  String get profileTripUpdates => 'Atualizações da viagem';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Banners sobre o ciclo de vida da viagem e o estado dos membros dentro da aplicação';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Ciclo de vida da viagem e alterações no estatuto dos membros';

  @override
  String get profileSettlementUpdates => 'Atualizações sobre a liquidação';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Banners de pagamento marcados como enviados e confirmados dentro da aplicação';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Atualizações de pagamentos marcadas como enviadas e confirmadas';

  @override
  String get profileScreenshotSizeMust8Mb => 'O tamanho das capturas de ecrã não deve exceder os 8 MB';

  @override
  String get profileFeedbackSendTitle => 'Enviar feedback';

  @override
  String get profileFeedbackTypeLabel => 'Tipo';

  @override
  String get profileFeedbackTypeBug => 'Erro';

  @override
  String get profileFeedbackTypeSuggestion => 'Sugestão';

  @override
  String get profileDescribeIssueSuggestion => 'Descreva o problema ou a sugestão';

  @override
  String get profilePickingImage => 'A selecionar imagem...';

  @override
  String get profileAttachScreenshot => 'Anexar captura de ecrã';

  @override
  String get profileChangeScreenshot => 'Alterar captura de ecrã';

  @override
  String get profileRemoveImage => 'Remover imagem';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Dica: anexe uma captura de ecrã para uma triagem mais rápida de erros';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Adicione detalhes ou anexe uma captura de ecrã antes de enviar';

  @override
  String get profileSendAction => 'Enviar';

  @override
  String get profileThanksFeedbackSent => 'Obrigado! Feedback enviado';

  @override
  String get profileFailedSendFeedback => 'Falha ao enviar feedback';

  @override
  String get profileCouldNotOpenWebsite => 'Não foi possível abrir o site.';

  @override
  String get profileOpenWebsiteQuestion => 'Abrir o site?';

  @override
  String get profileOpenPortfolioAction => 'Aceda a portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Este formato de imagem não é suportado neste dispositivo. Por favor, escolha JPG ou PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'É necessário um endereço de e-mail válido da conta para alterar a sua palavra-passe. Contacte o apoio ao cliente se o seu e-mail estiver em falta ou estiver incorreto.';

  @override
  String get profileEditDeletionLinkSentEmail => 'O link de eliminação foi enviado para o seu e-mail.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Não foi possível enviar o link de eliminação. Por favor, tente novamente.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Introduza a palavra-passe atual para alterar o e-mail.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Foi enviada uma mensagem de verificação para o novo endereço de e-mail. Foi enviado um aviso de segurança para o seu endereço de e-mail atual.';

  @override
  String get profileEditOverviewCurrency => 'Visão geral da moeda';

  @override
  String get profileEditPaymentMethod => 'Método de pagamento';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Transferência bancária, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Introduza a sua palavra-passe (opcional para Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Enviar link de eliminação por e-mail';

  @override
  String get profileEditBackProfile => 'Voltar ao perfil';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Defina um endereço de e-mail válido no perfil antes de alterar a palavra-passe.';

  @override
  String get profileEditPasswordUpdated => 'Palavra-passe atualizada.';

  @override
  String get profileEditFailedUpdatePassword => 'Falha na atualização da palavra-passe.';

  @override
  String profileEditEmail(Object email) {
    return 'Conta: $email';
  }

  @override
  String get profileEditPrimary => 'Principal';

  @override
  String get profileEditSearchCurrency => 'Pesquisar moeda';

  @override
  String get profileEditNoCurrenciesFound => 'Não foram encontradas moedas';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Os totais da visão geral são convertidos para esta moeda.';

  @override
  String get profileEditPaymentInfoUpdated => 'Informações de pagamento atualizadas.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Não foi possível guardar as informações de pagamento. Por favor, tente novamente.';

  @override
  String get profileEditCurrentPassword => 'Palavra-passe atual';

  @override
  String get profileEditBankTransferIbanSwift => 'Transferência bancária (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'link paypal.me';

  @override
  String get profileEditChoosePaymentMethod => 'Escolha o método de pagamento';

  @override
  String get profileEditTapChange => 'Toque para alterar';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Para transferências no Reino Unido, o código da agência deve ter 6 dígitos e o número de conta 8 dígitos.';

  @override
  String get profileEditPaymentInfo => 'Informações de pagamento';

  @override
  String get profileEditSaveDetails => 'Guardar detalhes';

  @override
  String get profileEditBankRegion => 'Região bancária';

  @override
  String get profileEditEurope => 'Europa';

  @override
  String get profileEditSortCode => 'Código de identificação bancária';

  @override
  String get profileEditExample112233 => 'Exemplo: 112233';

  @override
  String get profileEditNumber => 'Número de conta';

  @override
  String get profileEdit8Digits => '8 dígitos';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Para transferências domésticas no Reino Unido, utilize o código de classificação + número de conta.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Exemplo: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 ou 11 caracteres';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'O nome do titular da conta é retirado do nome completo do perfil.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username ou nome de utilizador';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Reino Unido';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Ajustar avatar';

  @override
  String get imageCropperAdjustTripImage => 'Ajustar a imagem da viagem';

  @override
  String get copyAction => 'Copiar';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Libra esterlina';

  @override
  String get currencyNameChf => 'Franco suíço';

  @override
  String get currencyNameNok => 'Coroa norueguesa';

  @override
  String get currencyNameSek => 'Coroa sueca';

  @override
  String get currencyNameDkk => 'Coroa dinamarquesa';

  @override
  String get currencyNamePln => 'Zloty polaco';

  @override
  String get currencyNameCzk => 'Corona checa';

  @override
  String get currencyNameHuf => 'Forint húngaro';

  @override
  String get currencyNameRon => 'Leu romeno';

  @override
  String get currencyNameBgn => 'Lev búlgaro';

  @override
  String get currencyNameIsk => 'Coroa islandesa';

  @override
  String get currencyNameAll => 'Lek albanês';

  @override
  String get currencyNameBam => 'Marca da Bósnia-Herzegovina';

  @override
  String get currencyNameByn => 'Rublo bielorrusso';

  @override
  String get currencyNameMdl => 'Leu moldavo';

  @override
  String get currencyNameMkd => 'Denar macedónio';

  @override
  String get currencyNameRsd => 'Dinar sérvio';

  @override
  String get currencyNameUah => 'Hryvnia ucraniana';

  @override
  String get currencyNameGel => 'Lari georgiano';

  @override
  String get currencyNameTry => 'Lira turca';

  @override
  String get currencyNameUsd => 'Dólar americano';

  @override
  String get currencyNameJpy => 'Iene japonês';

  @override
  String get currencyNameCny => 'Yuan chinês';

  @override
  String get currencyNameCad => 'Dólar canadiano';

  @override
  String get currencyNameAud => 'Dólar australiano';

  @override
  String get expenseCategoryFood => 'Refeições';

  @override
  String get expenseCategoryGroceries => 'Supermercado';

  @override
  String get expenseCategoryFuel => 'Combustível';

  @override
  String get expenseCategoryTransport => 'Transportes';

  @override
  String get expenseCategoryAccommodation => 'Alojamento';

  @override
  String get expenseCategoryActivities => 'Atividades';

  @override
  String get expenseCategoryTickets => 'Bilhetes';

  @override
  String get expenseCategoryShopping => 'Compras';

  @override
  String get expenseCategoryParty => 'Festa';

  @override
  String get expenseCategoryParking => 'Estacionamento';

  @override
  String get expenseCategoryOther => 'Outros';

  @override
  String get shellTripAlreadyInListOpened => 'A viagem já está na sua lista. Abrimos-a para si.';

  @override
  String get shellJoinedTripFromInviteLink => 'Juntou-se à viagem a partir de um link de convite.';

  @override
  String get shellFailedToOpenInviteLink => 'Não foi possível abrir o link de convite.';

  @override
  String get shellFailedToOpenFriendLink => 'Não foi possível abrir o link do amigo.';

  @override
  String get shellTripInviteTitle => 'Convite para a viagem';

  @override
  String get shellNoAction => 'Não';

  @override
  String get shellYesAction => 'Sim';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Apenas o criador da viagem pode eliminar esta viagem.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Apenas as viagens ativas podem ser eliminadas.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Apagar «$tripLabel»? Isto só é permitido antes de serem adicionadas quaisquer despesas.';
  }

  @override
  String get shellTripDeleted => 'Viagem eliminada.';

  @override
  String get shellFailedToDeleteTrip => 'Não foi possível eliminar a viagem.';

  @override
  String get shellFailedToLoadNotifications => 'Falha ao carregar as notificações.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Nova notificação: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Falha na atualização das notificações.';

  @override
  String get shellMarkAllAsReadAction => 'Marcar tudo como lido';

  @override
  String get shellNewSection => 'Novo';

  @override
  String get shellEarlierSection => 'Anterior';

  @override
  String get shellShowMoreEarlierAction => 'Mostrar mais anteriors';

  @override
  String get shellLoadingMore => 'A carregar mais...';

  @override
  String get shellLoadMoreNotificationsAction => 'Carregar mais notificações';

  @override
  String get shellTripNoLongerAvailable => 'Esta viagem já não está disponível.';

  @override
  String get shellFailedToOpenTrip => 'Não foi possível abrir a viagem.';

  @override
  String get shellYesterday => 'Ontem';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Já é membro da «$tripName». Deseja abrir esta viagem agora?\n\nConvidado por: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Queres juntar-te à viagem «$tripName»?\n\nConvidado por: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Imagem selecionada: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Imagem da viagem já definida.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Viagem criada, mas falha na publicação da imagem.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Viagem criada, mas falha no envio da imagem: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Juntar-se à viagem através de um convite';

  @override
  String get tripsTotalTrips => 'Total de viagens';

  @override
  String get tripsTotalSpent => 'Total gasto';

  @override
  String get tripsMixedCurrencies => 'Moedas mistas';

  @override
  String get tripsShowActive => 'Mostrar ativo';

  @override
  String get tripsSeeAll => 'Ver tudo';

  @override
  String get tripsGridView => 'Visualização em grelha';

  @override
  String get tripsListView => 'Visualização em lista';

  @override
  String get tripsAddNewTrip => 'Adicionar nova viagem';

  @override
  String get tripsLoadMore => 'Carregar mais';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Apagar «$arg1»? Isto só é permitido antes de serem adicionadas quaisquer despesas.';
  }

  @override
  String get tripsTripDates => 'Datas da viagem';

  @override
  String get tripsFrom => 'De';

  @override
  String get tripsSelectDate => 'Selecionar data';

  @override
  String get tripsTo => 'Para';

  @override
  String get tripsMainCurrency => 'Moeda principal';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Selecione o período da viagem (datas de início e fim).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'A data de fim da viagem deve ser igual ou posterior à data de início.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'O formato do período da viagem não é válido. Por favor, selecione novamente as datas.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Já é membro desta viagem.';

  @override
  String get tripsJoinedTripSuccessfully => 'Juntou-se à viagem com sucesso.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Não foi possível aderir à viagem a partir do convite.';

  @override
  String get tripsJoinTrip => 'Juntar-se à viagem';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Cole o link de convite ou o token de convite.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Introduza um link de convite ou token válido.';

  @override
  String get tripsClipboardIsEmpty => 'A área de transferência está vazia.';

  @override
  String get tripsPaste => 'Colar';

  @override
  String get tripsJoin => 'Juntar-se';

  @override
  String get workspaceTripMembers => 'Membros da viagem';

  @override
  String get workspaceFailedToLoadFriends => 'Não foi possível carregar os amigos.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Não foi possível gerar o link de convite.';

  @override
  String get workspaceInviteLink => 'Link de convite';

  @override
  String get workspaceGeneratingInviteLink => 'A gerar o link de convite...';

  @override
  String get workspaceInviteLinkUnavailable => 'Link de convite indisponível.';

  @override
  String get workspaceCopyInviteLink => 'Copiar link de convite';

  @override
  String get workspaceInviteLinkCopied => 'Link de convite copiado.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Expira: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Não há amigos disponíveis. Adicione amigos primeiro.';

  @override
  String get workspaceSettle => 'Liquidar';

  @override
  String get workspaceOwesToTheGroup => 'Devido ao grupo';

  @override
  String get workspaceGetsBackFromGroup => 'Tem dinheiro a receber do grupo';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Apresentação dos 4 primeiros por diferença de saldo.';

  @override
  String get workspaceOpenFlow => 'Detalhes';

  @override
  String get workspaceFriend => 'Amigo';

  @override
  String get workspaceSettlementTransfer => 'Transferência de liquidação';

  @override
  String get workspaceCompleted => 'Concluído';

  @override
  String get workspaceWaitingForConfirmation => 'À espera de confirmação';

  @override
  String get workspaceWaitingForPayment => 'À espera de pagamento';

  @override
  String get workspaceActionNeeded => 'Ação necessária';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Pagamentos a marcar como enviados: $arg1; a confirmar como recebidos: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Pronto para liquidar';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Todos os membros estão prontos. Pode iniciar as liquidações.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'À espera que todos indiquem que estão prontos.';

  @override
  String get workspaceIMReady => 'Estou pronto';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Confirme se adicionou todas as suas despesas.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'O botão «Concluir» é desbloqueado assim que todos se marcarem como prontos.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Tem dinheiro a receber do grupo';

  @override
  String get workspaceSettledWithTheGroup => 'Acordado com o grupo';

  @override
  String get workspaceTotalPaid => 'Total pago';

  @override
  String get workspaceTotalOwes => 'Total a pagar';

  @override
  String get workspaceTransactionHistory => 'Histórico de transações';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Ainda não há transações para este membro.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Liquidações: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Todos os membros devem indicar que estão prontos antes de iniciar as liquidações.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Marcou-se como pronto para efetuar o pagamento.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'A marca «Pronto para liquidação» foi removida.';

  @override
  String get workspaceReminderSent => 'Lembrete enviado.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Link de convite ou adicionar a partir da lista de amigos';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Apenas o criador da viagem pode editar esta viagem.';

  @override
  String get workspaceTripUpdated => 'Viagem atualizada.';

  @override
  String get workspaceFailedToUpdateTrip => 'Falha na atualização da viagem.';

  @override
  String get workspaceNoMembersSelectedYet => 'Ainda não foram selecionados membros.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Sem ligação à Internet. A despesa será guardada sem a imagem do recibo.';

  @override
  String get workspaceRandomPicker => 'Sorteio';

  @override
  String get workspaceCurrency => 'Moeda';

  @override
  String get workspaceCategory => 'Categoria';

  @override
  String get workspaceCustomCategory => 'Categoria personalizada';

  @override
  String get workspaceCategoryName => 'Nome da categoria';

  @override
  String get workspaceApartmentRentParkingEtc => 'Renda do apartamento, estacionamento, etc.';

  @override
  String get workspaceEnterACustomCategory => 'Introduza uma categoria personalizada.';

  @override
  String get workspacePickAnExpenseCategory => 'Escolha uma categoria de despesas.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'A categoria deve ter, pelo menos, 2 caracteres.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'A categoria deve ter até 64 caracteres.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'A divisão percentual deve totalizar 100%.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'O número de partes deve ser superior a 0 para cada participante.';

  @override
  String get workspaceTotalAmount => 'Montante total';

  @override
  String get workspaceOriginal => 'Original';

  @override
  String get workspaceTotalCost => 'Custo total';

  @override
  String workspaceStarted(Object arg1) {
    return 'Iniciado $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return '$arg1 concluído';
  }

  @override
  String get workspaceArchivedTrip => 'Viagem arquivada';

  @override
  String get workspaceActiveTrip => 'Viagem ativa';

  @override
  String get workspaceMemberProfile => 'Perfil do membro';

  @override
  String get workspaceTripOwner => 'Organizador da viagem';

  @override
  String get workspaceMember => 'Membro';

  @override
  String get workspaceReadyForSettlement => 'Pronto para liquidação';

  @override
  String get workspaceNotReadyForSettlement => 'Ainda não está pronto para a liquidação';

  @override
  String get workspaceBankDetails => 'Dados bancários';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'O IBAN e os detalhes de pagamento serão adicionados aqui numa próxima atualização.';

  @override
  String get workspacePaymentDetails => 'Detalhes de pagamento';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Este membro ainda não adicionou detalhes de pagamento.';

  @override
  String get workspaceBankTransfer => 'Transferência bancária';

  @override
  String get workspaceHolder => 'Titular';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Não foi possível abrir o link de pagamento.';

  @override
  String get workspaceTripActivity => 'Atividade da viagem';

  @override
  String get workspacePaidExpenses => 'Despesas pagas';

  @override
  String get workspacePaidTotal => 'Total pago';

  @override
  String get workspaceInvolvedIn => 'Envolvido em';

  @override
  String get workspaceCurrentTrip => 'Viagem atual';

  @override
  String get workspaceCommonTrips => 'Viagens em comum';

  @override
  String get workspaceLoadingCommonTrips => 'A carregar viagens em comum…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Ainda não há viagens em comum.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Não foi possível carregar todas as viagens em comum. É apresentada a viagem atual.';

  @override
  String get workspaceMembers => 'membros';

  @override
  String get workspaceExpense => 'Despesas';

  @override
  String get workspacePaid => 'pago';

  @override
  String get workspaceLoadingMoreExpenses => 'A carregar mais despesas...';

  @override
  String get workspaceScrollDownToLoadMore => 'Deslize para baixo para carregar mais';

  @override
  String get workspaceTripFinished => 'Viagem concluída';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'As liquidações estão desbloqueadas para esta viagem.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Conclua a viagem para iniciar as liquidações.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 marcou a transferência como enviada.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'À espera que $arg1 marque como pago.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 confirmou a receção do pagamento.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'À espera que $arg1 confirme.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Todas as liquidações da viagem estão totalmente concluídas.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Estado final após a confirmação de todas as transferências.';

  @override
  String get workspaceSettlementFlow => 'Fluxo de liquidação';

  @override
  String get workspaceActions => 'Ações';

  @override
  String get workspaceQuickPay => 'Pagamento rápido';

  @override
  String get workspacePayWithRevolut => 'Pagar com o Revolut';

  @override
  String get workspacePayWithPaypal => 'Pagar com PayPal';

  @override
  String get workspacePayWithWise => 'Pague com o Wise';

  @override
  String get workspaceTransferIsConfirmed => 'A transferência está confirmada.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'À espera que o outro membro conclua o próximo passo.';

  @override
  String get workspaceSendReminder => 'Enviar lembrete';

  @override
  String get workspaceInProgress => 'Em curso';

  @override
  String get workspaceTimeUnknown => 'Hora desconhecida';

  @override
  String get workspaceRemind => 'Lembrete';

  @override
  String get workspaceYourPosition => 'A sua posição';

  @override
  String get workspaceRecentActivity => 'Atividade recente';

  @override
  String get workspaceNoRecentActivityYet => 'Ainda não há atividade recente.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Adicione pelo menos um membro para começar a dividir as despesas.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Marque-se como pronto para efetuar a liquidação depois de adicionar todas as suas despesas.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Participantes ainda não prontos: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Todos os membros estão prontos. Pode concluir a viagem e iniciar as liquidações.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Todos os membros estão prontos. À espera que o organizador da viagem inicie as liquidações.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Liquidação em curso: $arg1/$arg2 confirmados.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Não há ações pendentes. Esta viagem está concluída.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Não é necessário realizar nenhuma ação neste momento.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Deve receber $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Deve pagar a $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'De momento, está inscrito nesta viagem.';

  @override
  String get workspaceUnknownTime => 'Hora desconhecida';

  @override
  String get workspaceJustNow => 'Agora mesmo';

  @override
  String workspaceMinAgo(Object arg1) {
    return 'Há $arg1 min';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return 'Há $arg1 h';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return 'Há $arg1 d';
  }

  @override
  String get friendsRemoveFriend => 'Remover amigo';

  @override
  String get friendsRemoveThisFriend => 'Remover este amigo?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 será removido da sua lista de amigos. Pode adicioná-lo novamente mais tarde.';
  }

  @override
  String get friendsContinue => 'Continuar';

  @override
  String get friendsFriendRemoved => 'Amigo removido.';

  @override
  String get friendsCouldNotRemoveFriend => 'Não foi possível remover o amigo.';

  @override
  String get friendsFriendProfile => 'Perfil do amigo';

  @override
  String get friendsMoreActions => 'Mais ações';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Este amigo ainda não adicionou os detalhes de pagamento.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Não foi possível carregar as viagens em comum agora.';

  @override
  String get friendsFinished => 'Concluído';

  @override
  String friendsTrip(Object arg1) {
    return 'Viagem n.º $arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Membros: $arg1';
  }

  @override
  String get friendsNoDate => 'Sem data';

  @override
  String get friendsIncomingRequests => 'PEDIDOS RECEBIDOS';

  @override
  String get friendsSentInvites => 'CONVITES ENVIADOS';

  @override
  String get friendsMyFriends => 'OS MEUS AMIGOS';

  @override
  String get friendsRequests => 'Pedidos';

  @override
  String get friendsIncoming => 'Mensagens recebidas';

  @override
  String get friendsIncomingRequestSubtitle => 'quer ser amigo';

  @override
  String get friendsOutgoingInviteSubtitle => 'Convite enviado';

  @override
  String get friendsNoPendingActivity => 'Sem pedidos de amizade';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Convite enviado para $arg1.';
  }

  @override
  String get friendsNoIncomingRequests => 'Sem pedidos recebidos';

  @override
  String get friendsDecline => 'Recusar';

  @override
  String get friendsAccept => 'Aceitar';

  @override
  String get friendsNoSentInvites => 'Não foram enviados convites';

  @override
  String get friendsNoFriendsYet => 'Ainda não tem amigos';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Deslize para baixo para carregar mais amigos.';

  @override
  String get friendsUser => 'Utilizador';

  @override
  String get friendsSearchUsers => 'Pesquisar utilizadores';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Pesquise por nome ou e-mail e envie um convite';

  @override
  String get friendsScanQr => 'Digitalizar o QR';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Digitalize outro utilizador para adicionar como amigo';

  @override
  String get friendsMyQr => 'O meu QR';

  @override
  String get friendsShowOrShareYourQrCode => 'Mostrar ou partilhar o seu código QR';

  @override
  String get friendsScanFriendQrTitle => 'Digitalizar o QR de um amigo';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Coloque o código QR do amigo dentro da moldura';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Mantenha o QR dentro do enquadramento';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Adicionar $arg1 como amigo?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 receberá o teu pedido de amizade.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Aceitar o pedido de amizade de $arg1?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Digitalize este QR ou partilhe o link para me adicionar no Splyto.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Adicione-me no Splyto.';

  @override
  String get friendsTripSplitFriendCode => 'Link de amigo do Splyto';

  @override
  String get shareAction => 'Partilhar';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'O código QR não é um código de amigo válido.';

  @override
  String get friendsYouCannotAddYourself => 'Não se pode adicionar a si próprio.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Este utilizador já está na sua lista de amigos.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'O convite para este utilizador já foi enviado.';

  @override
  String get friendsFriendRequestProcessed => 'Pedido de amizade processado.';

  @override
  String get friendsFailedToProcessFriendQr => 'Falha ao processar o QR do amigo.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Não foi possível carregar o seu perfil de utilizador.';

  @override
  String get friendsMyProfile => 'O meu perfil';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Erro inesperado ao carregar amigos.';

  @override
  String get friendsFriendAdded => 'Amigo adicionado.';

  @override
  String get friendsRequestDeclined => 'Pedido recusado.';

  @override
  String get friendsFailedToUpdateRequest => 'Falha na atualização do pedido.';

  @override
  String get friendsCancelInvite => 'Cancelar convite';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Cancelar o convite para $arg1?';
  }

  @override
  String get friendsKeep => 'Manter';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Convite para $arg1 cancelado.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Não foi possível cancelar o convite.';

  @override
  String get analyticsOther => 'Outros';

  @override
  String get analyticsSelectATripForAnalytics => 'Selecione uma viagem para análise';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Membros: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Despesas diárias';

  @override
  String get analyticsMyDaily => 'As minhas despesas diárias';

  @override
  String get analyticsGroupDaily => 'Despesas diárias do grupo';

  @override
  String get analyticsByMember => 'Por participante';

  @override
  String get analyticsShowLess => 'Mostrar menos';

  @override
  String get analyticsByCategory => 'Por categoria';

  @override
  String get analyticsQuickInsights => 'Visão geral rápida';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Maior despesa: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Maior gastador: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Dia de maior número de participantes no grupo: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Sem datas';

  @override
  String get friendsSearchFailedTryAgain => 'A pesquisa falhou. Tente novamente.';

  @override
  String get friendsFailedToSendInvite => 'Falha ao enviar o convite.';

  @override
  String get friendsAddFriend => 'Adicionar amigo';

  @override
  String get friendsSearchByNameOrEmail => 'Pesquisar por nome ou e-mail';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Digite pelo menos 2 caracteres para pesquisar.';

  @override
  String get friendsNoUsersFound => 'Não foram encontrados utilizadores';

  @override
  String get friendsInviteAction => 'Convidar';

  @override
  String get workspacePaidForGroup => 'Pagamento para o grupo';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Pago para o grupo • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Partilha de despesas';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Partilha de despesas • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Nome do titular copiado.';

  @override
  String get paymentIbanCopied => 'IBAN copiado.';

  @override
  String get paymentSwiftCopied => 'SWIFT copiado.';

  @override
  String get paymentRevtagCopied => 'Revtag copiado.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Não foi possível copiar para a área de transferência.';

  @override
  String get paymentCopied => 'Copiado.';

  @override
  String get paymentRequestAction => 'Solicitar pagamento';

  @override
  String get paymentRecordAction => 'Registar pagamento';

  @override
  String get paymentRequestSheetTitle => 'Solicitar pagamento';

  @override
  String get paymentRecordSheetTitle => 'Registar pagamento';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Pede a $arg1 que pague um montante que te deve atualmente.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Usa esta opção depois de pagares a $arg1 fora do Splyto. Essa pessoa confirmará a receção do pagamento.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Máximo $arg1';
  }

  @override
  String get paymentNoteHint => 'Transferência bancária, Revolut, dinheiro...';

  @override
  String get paymentAmountPositiveError => 'O montante deve ser superior a zero.';

  @override
  String get paymentAmountTooHighError => 'O montante não pode ser superior ao saldo em dívida.';

  @override
  String get paymentRequestCreated => 'Pedido de pagamento enviado.';

  @override
  String get paymentRecordedWaiting => 'Pagamento registado. À espera de confirmação.';

  @override
  String get paymentConfirmTitle => 'Confirmar pagamento';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Confirma que recebeste $arg1 de $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Pagamento confirmado.';

  @override
  String get paymentCancelRecordTitle => 'Cancelar registo de pagamento';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Cancelar o registo do teu pagamento de $arg1 a $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Registo de pagamento cancelado.';

  @override
  String get paymentNotReceivedTitle => 'Pagamento não recebido';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Marcar o pagamento $arg1 de $arg2 como não recebido?';
  }

  @override
  String get paymentMarkedNotReceived => 'Pagamento marcado como não recebido.';

  @override
  String get paymentActivityTitle => 'Atividade de pagamento';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Pedidos de pagamento pendentes: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Pagamentos à espera de confirmação: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Pagamentos registados';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 solicitou um pagamento a $arg2';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 pagou a $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Pagamento solicitado';

  @override
  String get paymentAwaitingConfirmationStatus => 'A aguardar confirmação';

  @override
  String get paymentReviewRequestAction => 'Pedido de revisão';

  @override
  String get paymentViewDetailsAction => 'Detalhes de pagamento';

  @override
  String get paymentMarkPaidAction => 'Já paguei';

  @override
  String get paymentDeclineAction => 'Recusar';

  @override
  String get paymentRequestReviewTitle => 'Pedido de pagamento';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 pediu-te $arg2. Paga fora do Splyto e depois marca o pagamento como efetuado.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Marcar o pedido como pago?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Confirma apenas depois de pagares $arg1 a $arg2 fora do Splyto.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Marcado como pago. À espera de confirmação.';

  @override
  String get paymentRequestCancelTitle => 'Cancelar pedido de pagamento?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Cancelar o teu pedido de pagamento de $arg1 a $arg2?';
  }

  @override
  String get paymentRequestCancelled => 'Pedido de pagamento cancelado.';

  @override
  String get paymentRequestDeclineTitle => 'Recusar o pedido de pagamento?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Recusar o pedido de pagamento de $arg1 enviado por $arg2? A pessoa será notificada.';
  }

  @override
  String get paymentRequestDeclined => 'Pedido de pagamento recusado.';

  @override
  String get paymentPendingBeforeFinish => 'Resolva os pedidos de pagamento pendentes e os pagamentos não confirmados antes da liquidação final.';

  @override
  String get paymentFinishBlockedByPending => 'A conclusão é desbloqueada após a resolução dos pedidos de pagamento e dos pagamentos não confirmados.';

  @override
  String get notificationPaymentRequestedTitle => 'Pagamento solicitado';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 solicitou-lhe $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Recebeste um pedido de pagamento.';

  @override
  String get notificationPaymentRequestSentTitle => 'Pagamento solicitado enviado';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 marcou o seu pedido de pagamento $arg2 como pago.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'O seu pedido de pagamento foi marcado como pago.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Pedido de pagamento cancelado';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 cancelou o pedido de pagamento $arg2.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Um pedido de pagamento foi cancelado.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Pedido de pagamento recusado';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 recusou o seu pedido de pagamento $arg2.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'O seu pedido de pagamento foi recusado.';

  @override
  String get notificationPaymentSentTitle => 'Pagamento marcado como enviado';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 marcou $arg2 como pago a si.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Foi marcado um pagamento como enviado para si.';

  @override
  String get notificationPaymentConfirmedTitle => 'Pagamento confirmado';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 confirmou a receção de $arg2 da sua parte.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'O seu pagamento foi confirmado.';

  @override
  String get notificationPaymentCancelledTitle => 'Pagamento cancelado';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 cancelou a marca de pagamento $arg2.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Uma marca de pagamento foi cancelada.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Pagamento não recebido';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 marcou o pagamento $arg2 como não recebido.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Um pagamento foi marcado como não recebido.';

  @override
  String get quickStartTitle => 'Início rápido';

  @override
  String get quickStartCreateTitle => 'Sozinho ou com amigos';

  @override
  String get quickStartCreateBody => 'Crie uma viagem para si ou para um grupo. Adicione amigos com uma ligação ou código QR e convide-os.';

  @override
  String get quickStartInviteTitle => 'Viajar em grupo ou sozinho';

  @override
  String get quickStartInviteBody => 'Convide amigos para partilhar a sua viagem ou inicie uma viagem pessoal por conta própria.';

  @override
  String get quickStartExpenseTitle => 'Despesas em várias moedas';

  @override
  String get quickStartExpenseBody => 'Escolha quem pagou e como dividir. As outras moedas são convertidas à taxa da data de compra, mesmo que as adicione mais tarde.';

  @override
  String get quickStartSettleTitle => 'Acerte contas facilmente';

  @override
  String get quickStartSettleBody => 'Veja quem deve a quem, pague como preferir e confirme na app.';

  @override
  String get quickStartAnalyticsTitle => 'Orçamento e despesas';

  @override
  String get quickStartAnalyticsBody => 'Defina um orçamento para a sua viagem ou grupo e veja as despesas por categoria, viagem e dia.';

  @override
  String get quickStartMapTitle => 'Guarde os seus lugares';

  @override
  String get quickStartMapBody => 'Adicione as cidades que visitou ao seu mapa de viagem privado. Só você o pode ver.';

  @override
  String get quickStartLiveTitle => 'Encontrem-se';

  @override
  String get quickStartLiveBody => 'Nas viagens em grupo, partilhe a sua localização em tempo real durante o tempo que escolher. Os membros da viagem podem vê-la e pode parar a qualquer momento.';

  @override
  String get quickStartNext => 'Seguinte';

  @override
  String get quickStartBack => 'Voltar';

  @override
  String get quickStartSkip => 'Ignorar';

  @override
  String get quickStartCreateAction => 'Criar viagem';

  @override
  String get quickStartClose => 'Fechar o Guia de Início Rápido';

  @override
  String get quickStartSubtitle => 'Veja como funcionam as viagens e as despesas';

  @override
  String quickStartStep(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String get workspaceTripTotal => 'Total da viagem';

  @override
  String get workspacePersonalTotal => 'Total gasto';

  @override
  String get workspaceBalanceEven => 'O teu saldo está equilibrado';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Tens a pagar $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Tens a receber $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Membros: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Pesquisar despesas';

  @override
  String get workspaceClearSearch => 'Pesquisa clara';

  @override
  String get workspaceSearchLoadedHint => 'A pesquisa abrange as despesas carregadas. Carregue mais para incluir despesas mais antigas.';

  @override
  String get workspaceNoExpenseMatches => 'Nenhuma despesa corresponde à pesquisa';

  @override
  String get workspaceNoExpenseMatchesBody => 'Tente outra pesquisa ou limpe o campo para ver todas as despesas carregadas.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Adicione a sua primeira despesa para começar a controlar os seus gastos.';

  @override
  String get workspaceEmptyGroupExpenses => 'Adicione a sua primeira despesa partilhada para ver a parte de cada um.';

  @override
  String get workspaceLoadMoreExpenses => 'Carregar mais despesas';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Montante original: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Comentários: $count';
  }

  @override
  String get workspaceExpenseActions => 'Ações relacionadas com despesas';

  @override
  String get workspaceLoadErrorTitle => 'Não foi possível carregar esta viagem';

  @override
  String get workspaceCachedWarning => 'Apresentação de dados guardados. Estes podem estar desatualizados.';

  @override
  String get workspaceActivityTab => 'Atividade';

  @override
  String get workspaceLoadingTrip => 'A carregar viagem';

  @override
  String get workspaceRefreshFailed => 'Atualização falhada';

  @override
  String get expenseDetailsTitle => 'Detalhes das despesas';

  @override
  String get expenseQuickCategories => 'Categorias rápidas';

  @override
  String get expenseReceiptRead => 'Recibo lido e formulário atualizado.';

  @override
  String get expenseReceiptNoData => 'Recibo em anexo. Não foi encontrado qualquer montante, data ou comerciante claro.';

  @override
  String get expenseReceiptScanFailed => 'Recibo selecionado. Falha na leitura automática; verifique os campos manualmente.';

  @override
  String get expenseReceiptOffline => 'O recibo será carregado quando guardar. A leitura automática requer uma ligação à Internet.';

  @override
  String get expenseReadingReceipt => 'A ler o recibo…';

  @override
  String get expenseCommentsLoadFailed => 'Não foi possível carregar os comentários. Tente novamente.';

  @override
  String get expenseReplyAction => 'Responder';

  @override
  String get expenseReplyHint => 'Escreva uma resposta…';

  @override
  String expenseReplyTo(String name) {
    return 'Responder a $name';
  }

  @override
  String get balanceEmptyBody => 'Os saldos aparecem após a adição das despesas.';

  @override
  String get balanceAfterPayments => 'Os saldos incluem pagamentos confirmados.';

  @override
  String get balanceExpenseShare => 'Partilha de despesas';

  @override
  String get balanceHistoryScope => 'Despesas registadas e pagamentos confirmados. Esta lista pode não incluir todo o histórico da viagem.';

  @override
  String balancePaymentTo(String name) {
    return 'Pagamento a $name';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Pagamento de $name';
  }

  @override
  String get settlementEmptyActive => 'Marque todos como «prontos» antes de iniciar as liquidações finais.';

  @override
  String get settlementEmptyClosed => 'Não há transferências listadas para esta viagem.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count de $total transferências confirmadas';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count de $total membros prontos';
  }

  @override
  String get settlementMemberReady => 'Pronto';

  @override
  String get settlementMemberNotReady => 'Ainda não está pronto';

  @override
  String get settlementSuggested => 'Transferência sugerida';

  @override
  String get activityLoadFailed => 'Não foi possível atualizar a atividade. Quaisquer entradas visíveis podem estar desatualizadas.';

  @override
  String get activityMember => 'Membro da viagem';

  @override
  String get friendsEmptyBody => 'Encontre um amigo pelo nome ou e-mail, ou utilize um código QR.';

  @override
  String get friendsDeclineAction => 'Recusar';

  @override
  String get friendsLoading => 'A carregar amigos';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Viagens partilhadas: $count';
  }

  @override
  String get memberActivityScope => 'Com base nas despesas introduzidas; isto pode não cobrir toda a viagem.';

  @override
  String get sharedTripsLoadedLimit => 'Exibição de até 20 viagens partilhadas.';

  @override
  String get memberRemoveTitle => 'Remover membro?';

  @override
  String memberRemoveBody(String name) {
    return 'Remover $name desta viagem? Isto só é possível se não tiverem despesas, liquidações ou saldos.';
  }

  @override
  String get memberRemoveAction => 'Remover da viagem';

  @override
  String memberRemoved(String name) {
    return '$name removido da viagem.';
  }

  @override
  String get profilePaymentNotAdded => 'Ainda não adicionado';

  @override
  String get friendRelationshipLabel => 'Amigo';

  @override
  String get sharedTripsEmptyBody => 'As viagens em que ambos participarem aparecerão aqui.';

  @override
  String get analyticsAllTrips => 'Todas as viagens';

  @override
  String get analyticsByTrip => 'Por viagem';

  @override
  String get analyticsYourSpending => 'As tuas despesas';

  @override
  String get analyticsActiveArchived => 'Viagens ativas e arquivadas';

  @override
  String get analyticsTrips => 'Viagens';

  @override
  String get analyticsAveragePerTrip => 'Média por viagem';

  @override
  String get analyticsPaidByMember => 'Pago pelo membro';

  @override
  String get analyticsYouPaid => 'Pagaste.';

  @override
  String get analyticsYouGetBack => 'Tens a receber';

  @override
  String get analyticsYouOwe => 'Tens a pagar';

  @override
  String get analyticsParticipants => 'Participantes';

  @override
  String get analyticsYourCategories => 'As suas despesas por categoria';

  @override
  String get analyticsLargestShares => 'As minhas maiores partes das despesas';

  @override
  String get analyticsLargestExpenses => 'Despesas mais elevadas';

  @override
  String get analyticsSpendingByTrip => 'As suas despesas por viagem';

  @override
  String get analyticsEmptyTitle => 'Ainda não houve despesas';

  @override
  String get analyticsEmptyBody => 'As suas despesas aparecerão aqui quando adicionar despesas a uma viagem.';

  @override
  String get analyticsPeriodEmptyBody => 'Não há despesas associadas a esta visualização. Experimente outra viagem ou período.';

  @override
  String get analyticsLoadFailed => 'Não foi possível carregar o relatório completo de despesas. Por favor, tente novamente.';

  @override
  String get analyticsLastLoaded => 'Apresentação do último relatório carregado com sucesso.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count despesas',
      one: '$count despesa',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Opções de viagem';

  @override
  String get editTripAction => 'Editar viagem';

  @override
  String get deleteTripAction => 'Eliminar viagem';

  @override
  String get inviteTripMembersAction => 'Convidar membros';

  @override
  String get tripCoverPhoto => 'Foto de capa';

  @override
  String get tripInviteLaterHint => 'Pode convidar pessoas depois de criar a viagem.';

  @override
  String get inviteClipboardFailed => 'Não foi possível aceder à área de transferência. Tente novamente.';

  @override
  String get friendInviteToTrip => 'Convidar para a viagem';

  @override
  String get friendChooseTrip => 'Escolha uma viagem';

  @override
  String get friendNoInvitableTrips => 'Não há viagens disponíveis. Pode convidar amigos para viagens de grupo ativas que gere, a menos que já sejam membros ou tenham um convite pendente.';

  @override
  String get friendTripInviteSent => 'Convite enviado.';

  @override
  String get friendTripUnavailable => 'Esta viagem já não está disponível para esta ação. Atualize a página e tente novamente.';

  @override
  String get friendTripActionFailed => 'Não foi possível concluir esta ação. Tente novamente.';

  @override
  String get profileContactDescription => 'Tem algum problema, sugestão ou dúvida sobre o Splyto? Envie-nos um e-mail — teremos todo o gosto em ajudar.';

  @override
  String get profileContactEmailAction => 'Escreva um e-mail';

  @override
  String get profileContactEmailUnavailable => 'Não foi possível abrir uma aplicação de e-mail. Copie o endereço e escreva-nos a partir da sua aplicação de e-mail.';

  @override
  String get profilePrivacyPolicy => 'Política de privacidade';

  @override
  String get privacyLoadFailed => 'Não foi possível carregar a política de privacidade. Por favor, tente novamente.';

  @override
  String get addReceiptAction => 'Adicionar recibo';

  @override
  String get receiptPickFailed => 'Não foi possível carregar o recibo. Por favor, tente novamente.';

  @override
  String get receiptPhotoAccessDenied => 'Permita o acesso à câmara ou à biblioteca de fotografias para o Splyto em «Definições» e, em seguida, tente novamente.';

  @override
  String get receiptPhotoLabel => 'Fotografia do recibo';

  @override
  String get replaceReceiptAction => 'Substituir recibo';

  @override
  String get removeReceiptAction => 'Remover recibo';

  @override
  String get restoreReceiptAction => 'Restaurar recibo anterior';

  @override
  String get expenseSplitBetween => 'Divisão entre';

  @override
  String get expenseEditParticipants => 'Escolha os participantes';

  @override
  String get expenseCustomSplit => 'Divisão personalizada';

  @override
  String expenseSplitAllocated(String amount) {
    return 'Os $amount estão distribuídos';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return '$amount restante para dividir';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount acima do total';
  }

  @override
  String get profilePaymentSharingTitle => 'Partilhar métodos de pagamento com as minhas viagens';

  @override
  String get profilePaymentSharingDescription => 'Permitir que os participantes aceites nas viagens que crio ou às quais me junto vejam os meus métodos de pagamento. Esta opção aplica-se às viagens atuais e futuras. Podes desativá-la a qualquer momento para impedir novos acessos.';

  @override
  String get memberPaymentDetailsNotShared => 'Os métodos de pagamento não são partilhados ou estão atualmente indisponíveis.';

  @override
  String get homeTripInvitations => 'Convites para viagens';

  @override
  String get homeNoTripInvitations => 'Não há convites de viagem pendentes';

  @override
  String get homeInvitationsLoadFailed => 'Não foi possível carregar os convites. Por favor, tente novamente.';

  @override
  String get homeInvitationResponseFailed => 'Não foi possível responder ao convite. Por favor, tente novamente.';

  @override
  String get homeTripShareFailed => 'Não foi possível partilhar a viagem. Por favor, tente novamente.';

  @override
  String get settleStillToReceive => 'Ainda por receber';

  @override
  String get settleStillToPay => 'Ainda por pagar';

  @override
  String get settleEstimateCaption => 'Estimativa baseada nas despesas atuais. Os montantes podem sofrer alterações até ao final da viagem.';

  @override
  String get settleOutstandingCaption => 'A aguardar pagamento ou confirmação.';

  @override
  String get settleWaitingForYou => 'Estamos à espera que marque que está pronto.';

  @override
  String get settleWhoPaysWhom => 'Quem paga a quem';

  @override
  String get settlePreviewCaption => 'Pré-visualização · finalizada quando a viagem terminar';

  @override
  String get settleOpenPaymentCaption => 'Abra um pagamento para ver os detalhes e as ações disponíveis.';

  @override
  String get tripBudgetEnable => 'Defina um orçamento';

  @override
  String get tripBudgetSoloHint => 'Meta de despesas opcional para esta viagem.';

  @override
  String get tripBudgetGroupHint => 'Um orçamento partilhado para todo o grupo.';

  @override
  String get tripBudgetAmount => 'Montante do orçamento';

  @override
  String get tripBudgetInvalid => 'Introduza um montante entre 0,01 e 999999999,99, com até duas casas decimais.';

  @override
  String get tripBudgetTitle => 'Orçamento da viagem';

  @override
  String get tripBudgetGroupTitle => 'Orçamento do grupo';

  @override
  String get tripBudgetRemaining => 'Restante';

  @override
  String get tripBudgetOver => 'Excesso de orçamento';

  @override
  String get tripBudgetSpent => 'Gastado';

  @override
  String get tripBudgetLimit => 'Orçamento';

  @override
  String get travelMapTitle => 'O meu mapa de viagem';

  @override
  String get travelMapSubtitle => 'Locais visitados, só para si.';

  @override
  String get travelMapHere => 'Já estive aqui';

  @override
  String get travelMapAdd => 'Adicionar local';

  @override
  String get travelMapSearch => 'Pesquisar cidade e país';

  @override
  String get travelMapSearchAction => 'Pesquisar';

  @override
  String get travelMapSearchHint => 'Por exemplo, Lisboa, Portugal';

  @override
  String get travelMapEmpty => 'A tua próxima memória começa aqui';

  @override
  String get travelMapEmptyBody => 'Adicione uma cidade que já tenha visitado ou faça check-in no local onde se encontra agora.';

  @override
  String get travelMapConfirm => 'Guardar esta visita?';

  @override
  String get travelMapConfirmBody => 'Verifique a cidade e a data antes de as guardar no seu mapa privado.';

  @override
  String get travelMapDate => 'Data da visita';

  @override
  String get travelMapSave => 'Guardar no meu mapa';

  @override
  String get travelMapCancel => 'Cancelar';

  @override
  String get travelMapClose => 'Fechar';

  @override
  String get travelMapNoResults => 'Não foi encontrada nenhuma cidade. Tente adicionar o país à sua pesquisa.';

  @override
  String get travelMapLookupError => 'Não foi possível encontrar a cidade. Verifique a sua ligação ou adicione um local manualmente.';

  @override
  String get travelMapDenied => 'O acesso à localização está desativado. Ainda assim, pode adicionar uma cidade manualmente.';

  @override
  String get travelMapDisabled => 'Ative os serviços de localização ou adicione uma cidade manualmente.';

  @override
  String get travelMapError => 'Não foi possível carregar o seu mapa de viagem. Por favor, tente novamente.';

  @override
  String get travelMapSaveError => 'Não foi possível guardar a visita. Por favor, tente novamente.';

  @override
  String get travelMapUnavailable => 'O mapa de viagem necessita de uma atualização do servidor.';

  @override
  String get travelMapOffline => 'Offline · a mostrar locais guardados';

  @override
  String get travelMapRetry => 'Tentar novamente';

  @override
  String get travelMapDelete => 'Remover visita';

  @override
  String get travelMapDeleteConfirm => 'Quer remover esta visita do seu mapa privado?';

  @override
  String get travelMapFit => 'Mostrar todos os locais';

  @override
  String get travelMapSaved => 'Visita guardada';

  @override
  String get travelMapVisited => 'Visitado';

  @override
  String get travelMapLimit => 'O seu mapa atingiu 1 000 visitas. Elimine uma visita antiga antes de adicionar outra.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries países',
      one: '$countries país',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities cidades',
      one: '$cities cidade',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visitas',
      one: '$count visita',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Destinos (opcional)';

  @override
  String get travelAddDestination => 'Adicionar destino';

  @override
  String get travelRemoveDestination => 'Remover destino';

  @override
  String get travelFromTrip => 'A partir de uma viagem';

  @override
  String get travelChooseTrip => 'Escolha uma viagem';

  @override
  String get travelNoTrips => 'Ainda não há viagens disponíveis. Pode adicionar um local manualmente.';

  @override
  String get travelAddToMap => 'Adicionar ao meu mapa';

  @override
  String get travelTripConfirm => 'Guarde apenas os locais que visitou efetivamente. Isto acrescenta uma memória privada ao seu mapa.';

  @override
  String get travelVisitTitle => 'Título (opcional)';

  @override
  String get travelAddPhoto => 'Adicionar uma fotografia';

  @override
  String get travelChangePhoto => 'Alterar foto';

  @override
  String get travelRemovePhoto => 'Remover foto';

  @override
  String get travelPhotoError => 'Não foi possível preparar esta fotografia. Por favor, escolha outra.';

  @override
  String get travelEditVisit => 'Editar visita';

  @override
  String get travelOpenTrip => 'Viagem aberta';

  @override
  String get travelPreviousVisit => 'Visita anterior';

  @override
  String get travelNextVisit => 'Próxima visita';

  @override
  String get travelDuplicate => 'Esta visita já se encontra no seu mapa.';

  @override
  String get liveMapTitle => 'Mapa em tempo real';

  @override
  String get liveShareTitle => 'Partilhar a minha localização';

  @override
  String get liveConsent => 'Partilha a tua localização exata apenas com os participantes aceites nesta viagem, durante o período que escolheres. A partilha continua em segundo plano e podes pará-la a qualquer momento.';

  @override
  String get liveBackgroundNote => 'As atualizações podem ser interrompidas sem ligação à Internet ou se fechar a aplicação à força. Apenas a localização mais recente é mantida; não é registado qualquer histórico de percursos.';

  @override
  String get liveStart => 'Começar a partilhar';

  @override
  String get liveStop => 'Parar de partilhar';

  @override
  String get liveNotification => 'A sua localização está a ser partilhada com a sua viagem. Abra a Splyto para interromper a partilha.';

  @override
  String get livePermissionError => 'Ativa o acesso à localização nas definições do telemóvel para partilhares a tua localização.';

  @override
  String get liveStartError => 'Não foi possível iniciar a partilha. Verifique o acesso à localização, a ligação à Internet e a data e hora do seu telemóvel.';

  @override
  String get liveStopPending => 'As atualizações foram interrompidas. À espera de ligação à Internet para remover a sua última localização; esta desaparecerá do mapa no prazo de 2 minutos sem atualizações.';

  @override
  String get liveSharing => 'a partilhar a localização';

  @override
  String get liveUnavailable => 'Este mapa em tempo real não está disponível. Volte à viagem e atualize a página.';

  @override
  String get liveMapLoadError => 'Não foi possível carregar o mapa. Verifique a sua ligação e volte a abrir o mapa.';

  @override
  String get liveLoadError => 'Não foi possível atualizar as localizações. Apenas são apresentadas as atualizações recentes.';

  @override
  String get liveFit => 'Mostrar todos no mapa';

  @override
  String get liveEmpty => 'Ainda ninguém está a partilhar uma localização recente.';

  @override
  String get liveRecent => 'Acabámos de atualizar';

  @override
  String get liveLastKnown => 'Última atualização';

  @override
  String get liveAccuracy => 'Precisão';

  @override
  String get liveUntil => 'Partilha até';

  @override
  String get liveOtherSession => 'Iniciado noutra sessão. Pode interromper aqui.';

  @override
  String get liveUpdatesPaused => 'Atualizações em pausa. Verifique o acesso à localização e à Internet.';

  @override
  String get livePrivateUntilShared => 'A sua localização permanece privada até que opte por a partilhar.';

  @override
  String get activityEventExpenseCreated => 'adicionou uma despesa';

  @override
  String get activityEventExpenseUpdated => 'atualizou uma despesa';

  @override
  String get activityEventExpenseDeleted => 'eliminou uma despesa';

  @override
  String get activityEventExpenseCommentAdded => 'comentou uma despesa';

  @override
  String get activityEventTripCreated => 'criou a viagem';

  @override
  String get activityEventTripUpdated => 'atualizou os detalhes da viagem';

  @override
  String get activityEventTripRenamed => 'mudou o nome da viagem';

  @override
  String get activityEventTripCurrencyChanged => 'alterou a moeda da viagem';

  @override
  String get activityEventTripPhotoChanged => 'alterou a foto da viagem';

  @override
  String get activityEventTripBudgetChanged => 'alterou o orçamento da viagem';

  @override
  String get activityEventTripDestinationsChanged => 'alterou os destinos da viagem';

  @override
  String get activityEventTripMembersAdded => 'adicionou membros';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'enviou convites: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'juntou-se à viagem';

  @override
  String get activityEventTripInvitationDeclined => 'recusou o convite para a viagem';

  @override
  String get activityEventTripInvitationRevoked => 'cancelou um convite para a viagem';

  @override
  String activityEventTripMemberRemoved(String name) {
    return 'removeu $name da viagem';
  }

  @override
  String get activityEventTripMemberLeft => 'saiu da viagem';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return 'alterou a função de $name para $role';
  }

  @override
  String get activityEventTripMemberReady => 'indicou disponibilidade para liquidar';

  @override
  String get activityEventTripMemberNotReady => 'retirou a disponibilidade para liquidar';

  @override
  String get activityEventTripAllMembersReady => 'Todos os membros estão prontos para efetuar o pagamento';

  @override
  String get activityEventTripFinished => 'concluiu a viagem';

  @override
  String get activityEventTripSettled => 'Todas as transferências foram confirmadas, a viagem está saldada';

  @override
  String get activityEventSettlementMarkedSent => 'marcou uma transferência como enviada';

  @override
  String get activityEventSettlementConfirmed => 'confirmou uma transferência';

  @override
  String get activityEventSettlementSentCancelled => 'cancelou o estado «enviado»';

  @override
  String get activityEventSettlementNotReceived => 'marcou uma transferência como não recebida';

  @override
  String get activityEventSettlementReminderSent => 'enviou um lembrete de liquidação';

  @override
  String get activityEventPaymentMarkedSent => 'registou um pagamento';

  @override
  String get activityEventPaymentRequested => 'solicitou um pagamento';

  @override
  String get activityEventPaymentRequestMarkedSent => 'marcou um pagamento solicitado como enviado';

  @override
  String get activityEventPaymentRequestCancelled => 'cancelou um pedido de pagamento';

  @override
  String get activityEventPaymentRequestDeclined => 'recusou um pedido de pagamento';

  @override
  String get activityEventPaymentConfirmed => 'confirmou um pagamento';

  @override
  String get activityEventPaymentCancelled => 'cancelou um registo de pagamento';

  @override
  String get activityEventPaymentNotReceived => 'marcou um pagamento como não recebido';

  @override
  String get activityEventUnknown => 'fez uma alteração';

  @override
  String get privacyEnglishFallback => 'A política de privacidade está atualmente disponível em inglês.';

  @override
  String get activityRoleAdmin => 'Admin';

  @override
  String get accountDeleteTitle => 'Eliminar conta';

  @override
  String get accountDeleteIntro => 'Confirma a eliminação por e-mail. Após a confirmação, não pode ser anulada.';

  @override
  String get accountDeleteConsequences => 'A eliminação é permanente. O teu perfil é anonimizado e o acesso à conta é removido. Os registos partilhados de viagens e despesas são mantidos para os outros membros.';

  @override
  String get accountDeleteReasonsTitle => 'O que poderíamos ter feito melhor?';

  @override
  String get accountDeleteReasonsHint => 'Motivo (opcional)';

  @override
  String get accountDeleteReasonNotUsing => 'Já não preciso do Splyto para as minhas viagens';

  @override
  String get accountDeleteReasonAnotherWay => 'Giro as despesas partilhadas de outra forma';

  @override
  String get accountDeleteReasonComplicated => 'É preciso demasiado esforço para fazer as coisas';

  @override
  String get accountDeleteReasonTechnical => 'Encontrei erros ou problemas técnicos';

  @override
  String get accountDeleteReasonPrivacy => 'Prefiro remover os dados da minha conta';

  @override
  String get accountDeleteReasonOther => 'Quero eliminar a conta por outro motivo';

  @override
  String get accountDeleteEmailStep => 'O próximo passo é a confirmação por e-mail.';

  @override
  String get accountDeletePasswordHint => 'Introduz a tua palavra-passe atual do Splyto para pedir o e-mail de confirmação. A tua conta continua ativa.';

  @override
  String get accountDeleteInboxTitle => 'Um último passo na tua caixa de entrada';

  @override
  String accountDeleteSentBody(String email) {
    return 'Ligação de confirmação enviada para $email.';
  }

  @override
  String get accountDeleteSentHint => 'A tua conta mantém-se ativa até confirmares a eliminação.';

  @override
  String get accountDeleteSending => 'Envio de e-mail de confirmação';

  @override
  String get friendsShowMore => 'Mostrar mais';
}
