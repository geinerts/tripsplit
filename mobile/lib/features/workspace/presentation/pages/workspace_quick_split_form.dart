part of 'workspace_page.dart';

/// Someone added by name gets a form id far above any account id.
const _nameOnlyIdBase = 2000000000;

/// Opens Add expense as a quick split, or edits [existing]. Returns the saved
/// quick split, or null when closed or moved to a trip with [onTargetChanged].
Future<QuickSplit?> showQuickSplitForm(
  BuildContext context, {
  required AuthController authController,
  required FriendsController friendsController,
  required WorkspaceController workspaceController,
  required Future<QuickSplit> Function(QuickSplitInput input) save,
  Future<QuickSplit> Function(int id, QuickSplitInput input)? update,
  QuickSplit? existing,
  ExpenseDraft? draft,
  String defaultCurrencyCode = AppCurrencyCatalog.defaultCode,
  Future<ExpenseTarget?> Function(BuildContext context)? pickTarget,
  void Function(ExpenseTarget target, ExpenseDraft draft)? onTargetChanged,
}) async {
  final me = authController.currentUser;
  final myId = me?.id ?? 0;
  if (myId <= 0) return null;
  final t = context.l10n;

  // Everyone the form knows, by form id: accounts by their id, names by
  // [_nameOnlyIdBase] + n.
  final known = <int, WorkspaceUser>{
    myId: WorkspaceUser(
      id: myId,
      nickname: t.youLabel,
      avatarUrl: me?.avatarUrl,
      avatarThumbUrl: me?.avatarThumbUrl,
    ),
  };
  final formIdByPerson = <int, int>{};
  var nextNameId = _nameOnlyIdBase;
  for (final person in existing?.people ?? const <QuickSplitPerson>[]) {
    final userId = person.userId;
    final formId = userId ?? ++nextNameId;
    formIdByPerson[person.id] = formId;
    if (formId == myId) continue;
    known[formId] = WorkspaceUser(
      id: formId,
      nickname: person.name,
      avatarThumbUrl: person.avatarThumbUrl,
    );
  }

  _ExpenseFormSeed? seed;
  if (existing != null) {
    final payer = existing.payer;
    final itemized = existing.splitMode == 'itemized';
    seed = _ExpenseFormSeed(
      isEdit: true,
      amount: existing.amount,
      currencyCode: existing.currencyCode,
      note: existing.note,
      category: existing.category,
      subcategory: existing.subcategory,
      date: existing.date,
      payerId: payer != null ? formIdByPerson[payer.id] : myId,
      participantIds: itemized
          ? const []
          : [
              for (final person in existing.people)
                if (person.amount > 0 || person.splitValue != null)
                  formIdByPerson[person.id]!,
            ],
      splitMode: existing.splitMode,
      splitValues: {
        for (final person in existing.people)
          if (person.splitValue != null)
            formIdByPerson[person.id]!: person.splitValue,
      },
      items: [
        for (final item in existing.items)
          ExpenseItem(
            name: item.name,
            amount: item.amount,
            participantIds: [
              for (final id in item.personIds)
                if (formIdByPerson[id] != null) formIdByPerson[id]!,
            ],
          ),
      ],
      extraAmount: existing.extraAmount,
      hasSavedReceipt: existing.receiptUrl != null,
    );
  } else if (draft != null) {
    seed = _ExpenseFormSeed(
      amount: draft.amount,
      currencyCode: draft.currencyCode,
      note: draft.note,
      category: draft.category,
      subcategory: draft.subcategory,
      date: draft.date,
      receipt: draft.receipt,
    );
  }

  final mutationId =
      'qs_${myId}_${DateTime.now().microsecondsSinceEpoch}_'
      '${math.Random().nextInt(1 << 30)}';
  QuickSplit? saved;
  int? currentAccountId() => authController.currentUser?.id;

  await _showExpenseFormPage(
    context,
    initialUsers: known.values.toList(),
    seed: seed,
    setup: _ExpenseFormSetup(
      currentUserId: myId,
      defaultCurrencyCode: existing?.currencyCode ?? defaultCurrencyCode,
      submitLabel: t.quickSplitSplitAction,
      subtitle: (formContext, currentDraft) => _ExpenseTargetChip(
        key: const ValueKey('expense-target'),
        quickSplit: true,
        label: formContext.l10n.quickSplitLabel,
        onTap: () async {
          if (pickTarget == null || onTargetChanged == null) return;
          FocusScope.of(formContext).unfocus();
          final target = await pickTarget(formContext);
          if (target == null || target.isQuickSplit || !formContext.mounted) {
            return;
          }
          final carried = currentDraft();
          Navigator.of(formContext).pop();
          onTargetChanged(target, carried);
        },
      ),
      payerChoices: (users) => users,
      uploadReceipt: (fileName, bytes) => workspaceController.uploadReceipt(
        payload: ReceiptUploadPayload(fileName: fileName, bytes: bytes),
      ),
      loadSavedReceipt: existing?.receiptUrl == null
          ? null
          : () async => Uri.tryParse(existing!.receiptUrl!),
      currentAccountId: currentAccountId,
      addPerson: (formContext, users) async {
        final person = await _pickQuickSplitPerson(
          formContext,
          friendsController: friendsController,
          taken: {for (final user in users) user.id},
          nextNameId: () => ++nextNameId,
        );
        if (person != null) known[person.id] = person;
        return person;
      },
    ),
    onSubmit: (formContext, form) async {
      final input = await _quickSplitInput(
        formContext,
        form: form,
        known: known,
        myId: myId,
        existing: existing,
        mutationId: mutationId,
        workspaceController: workspaceController,
      );
      if (!formContext.mounted || currentAccountId() != myId) return false;
      saved = existing != null && update != null
          ? await update(existing.id, input)
          : await save(input);
      return true;
    },
  );
  return saved;
}

/// Turns the form into a request. Throws [ApiException] with a message the
/// form shows when something is missing.
Future<QuickSplitInput> _quickSplitInput(
  BuildContext context, {
  required _ExpenseFormResult form,
  required Map<int, WorkspaceUser> known,
  required int myId,
  required QuickSplit? existing,
  required String mutationId,
  required WorkspaceController workspaceController,
}) async {
  final t = context.l10n;
  final payerId = form.paidBy ?? myId;
  final itemized = form.splitMode == 'itemized';
  final shareIds = itemized
      ? {for (final item in form.items) ...item.participantIds}
      : (form.participants.isEmpty
            ? known.keys.toSet()
            : form.participants.toSet());
  // The creator is always in it, also when they only paid or only watch.
  final involved = {myId, payerId, ...shareIds};
  if (involved.length < 2) {
    throw ApiException(t.quickSplitNeedTwoPeople);
  }
  String key(int id) => 'p$id';
  final people = [
    for (final id in known.keys)
      if (involved.contains(id))
        id >= _nameOnlyIdBase
            ? QuickSplitPersonInput(key: key(id), name: known[id]!.nickname)
            : QuickSplitPersonInput(key: key(id), userId: id),
  ];

  var receiptPath = form.preuploadedReceipt?.path;
  final bytes = form.receiptFileBytes;
  final fileName = form.receiptFileName;
  if (receiptPath == null &&
      bytes != null &&
      bytes.isNotEmpty &&
      fileName != null) {
    receiptPath = (await workspaceController.uploadReceipt(
      payload: ReceiptUploadPayload(fileName: fileName, bytes: bytes),
    )).path;
  }
  if (receiptPath == null && !form.removeReceipt) {
    receiptPath = existing?.receiptPath;
  }

  return QuickSplitInput(
    amount: form.amount,
    currencyCode: form.currencyCode,
    note: form.note,
    category: form.category,
    subcategory: form.subcategory,
    date: form.date,
    people: people,
    paidByKey: key(payerId),
    splitMode: form.splitMode,
    participantKeys: itemized
        ? const []
        : [
            for (final id in known.keys)
              if (shareIds.contains(id)) key(id),
          ],
    splitValues: {
      for (final value in form.splitValues) key(value.userId): value.value,
    },
    items: [
      for (final item in form.items)
        QuickSplitItemInput(
          name: item.name,
          amount: item.amount,
          peopleKeys: [for (final id in item.participantIds) key(id)],
        ),
    ],
    extraAmount: form.extraAmount,
    receiptPath: receiptPath,
    clientMutationId: existing == null ? mutationId : null,
  );
}

/// A friend, or a name for someone without the app.
Future<WorkspaceUser?> _pickQuickSplitPerson(
  BuildContext context, {
  required FriendsController friendsController,
  required Set<int> taken,
  required int Function() nextNameId,
}) {
  return showAppBottomSheet<WorkspaceUser>(
    context: context,
    builder: (sheetContext) => _QuickSplitPersonSheet(
      friendsController: friendsController,
      taken: taken,
      nextNameId: nextNameId,
    ),
  );
}

class _QuickSplitPersonSheet extends StatefulWidget {
  const _QuickSplitPersonSheet({
    required this.friendsController,
    required this.taken,
    required this.nextNameId,
  });

  final FriendsController friendsController;
  final Set<int> taken;
  final int Function() nextNameId;

  @override
  State<_QuickSplitPersonSheet> createState() => _QuickSplitPersonSheetState();
}

class _QuickSplitPersonSheetState extends State<_QuickSplitPersonSheet> {
  final _name = TextEditingController();
  List<FriendUser>? _friends;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = widget.friendsController.peekSnapshotCache(allowStale: true);
    if (cached != null) {
      _friends = cached.friends;
      return;
    }
    try {
      final snapshot = await widget.friendsController.loadSnapshot();
      if (!mounted) return;
      setState(() => _friends = snapshot.friends);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _addName() {
    final name = _name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      WorkspaceUser(
        id: widget.nextNameId(),
        nickname: name.length > 32 ? name.substring(0, 32) : name,
        isGuest: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final friends = (_friends ?? const <FriendUser>[])
        .where((friend) => !widget.taken.contains(friend.id))
        .toList(growable: false);
    return AppActionSheet(
      key: const ValueKey('quick-split-person-sheet'),
      title: t.quickSplitAddPersonTitle,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('quick-split-name'),
                  controller: _name,
                  maxLength: 32,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addName(),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: t.quickSplitNameHint,
                    counterText: '',
                    filled: false,
                    border: const UnderlineInputBorder(),
                    enabledBorder: const UnderlineInputBorder(),
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('quick-split-name-add'),
                onPressed: _name.text.trim().isEmpty ? null : _addName,
                child: Text(t.addAction),
              ),
            ],
          ),
        ),
        if (_friends == null && !_failed)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_failed)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t.quickSplitFriendsFailed),
          )
        else
          for (final friend in friends)
            ListTile(
              key: ValueKey('quick-split-friend-${friend.id}'),
              leading: _memberAvatarFor(
                context,
                name: friend.preferredName,
                avatarUrl: friend.avatarThumbUrl ?? friend.avatarUrl,
                size: 36,
              ),
              title: Text(friend.preferredName),
              onTap: () => Navigator.of(context).pop(
                WorkspaceUser(
                  id: friend.id,
                  nickname: friend.preferredName,
                  avatarUrl: friend.avatarUrl,
                  avatarThumbUrl: friend.avatarThumbUrl,
                ),
              ),
            ),
      ],
    );
  }
}
