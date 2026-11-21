part of 'workspace_page.dart';

/// What the expense form needs from the place that opened it: a trip, or a
/// quick split that has no trip.
class _ExpenseFormSetup {
  const _ExpenseFormSetup({
    required this.currentUserId,
    required this.defaultCurrencyCode,
    required this.subtitle,
    required this.payerChoices,
    required this.uploadReceipt,
    required this.currentAccountId,
    this.isSolo = false,
    this.soloOwnerId = 0,
    this.typeSources = const [],
    this.loadSavedReceipt,
    this.addPerson,
    this.submitLabel,
    this.scanReceipt,
  });

  final int currentUserId;
  final bool isSolo;

  /// The only participant of a personal trip.
  final int soloOwnerId;
  final String defaultCurrencyCode;

  /// Under the title: the trip name, or the Quick split switch. [draft] gives
  /// what was typed so far, to carry it over when switching.
  final Widget Function(BuildContext context, ExpenseDraft Function() draft)
  subtitle;

  /// Who may be picked as the payer; fewer than two means the payer is fixed.
  final List<WorkspaceUser> Function(List<WorkspaceUser> users) payerChoices;

  /// Earlier expenses whose own types are offered again.
  final Iterable<TripExpense> typeSources;
  final Future<UploadedReceiptData> Function(String fileName, Uint8List bytes)
  uploadReceipt;

  /// Opens the receipt that was saved before, or null without one.
  final Future<Uri?> Function()? loadSavedReceipt;

  /// The signed-in account, to drop results that arrive after a switch.
  final int? Function() currentAccountId;

  /// Adds someone to the split (quick split only). Null hides "+ Add".
  final Future<WorkspaceUser?> Function(
    BuildContext context,
    List<WorkspaceUser> users,
  )?
  addPerson;

  /// Replaces "Add" on the main button of a new expense.
  final String? submitLabel;

  /// Reads the uploaded receipt with AI; null hides "Fill from receipt".
  /// Only set where the account has `receipt_ai` (docs/api/receipt-scan.md).
  final Future<ReceiptScan> Function(String receiptPath, String requestId)?
  scanReceipt;
}

/// The values a form opens with: a saved expense, or a draft carried over.
class _ExpenseFormSeed {
  const _ExpenseFormSeed({
    this.isEdit = false,
    this.amount,
    this.currencyCode,
    this.note = '',
    this.category = '',
    this.subcategory,
    this.date,
    this.participantIds = const [],
    this.payerId,
    this.splitMode = 'equal',
    this.splitValues = const {},
    this.items = const [],
    this.extraAmount = 0,
    this.hasSavedReceipt = false,
    this.receipt,
  });

  factory _ExpenseFormSeed.fromExpense(TripExpense expense) => _ExpenseFormSeed(
    isEdit: true,
    amount: expense.originalAmount,
    currencyCode: expense.expenseCurrencyCode,
    note: expense.note,
    category: expense.category,
    subcategory: expense.subcategory,
    date: expense.expenseDate,
    participantIds: [for (final p in expense.participants) p.id],
    payerId: expense.paidById,
    splitMode: expense.splitMode,
    splitValues: _legacySplitMode(expense.splitMode)
        ? {for (final p in expense.participants) p.id: p.owedAmount}
        : {
            for (final p in expense.participants)
              p.id: p.splitValue ?? p.owedAmount,
          },
    items: expense.items,
    extraAmount: expense.extraAmount,
    hasSavedReceipt: expense.receiptUrl != null,
  );

  final bool isEdit;
  final double? amount;
  final String? currencyCode;
  final String note;
  final String category;
  final String? subcategory;
  final String? date;
  final List<int> participantIds;
  final int? payerId;
  final String splitMode;
  final Map<int, double?> splitValues;
  final List<ExpenseItem> items;
  final double extraAmount;
  final bool hasSavedReceipt;

  /// A receipt uploaded before the form opened, e.g. from a quick split.
  final UploadedReceiptData? receipt;
}

const _supportedSplitModes = <String>{
  'equal',
  'exact',
  'percent',
  'shares',
  'adjustment',
  'itemized',
};

bool _legacySplitMode(String mode) =>
    !_supportedSplitModes.contains(mode.trim().toLowerCase());

String _formatNumericInput(double value) {
  final rounded = value.abs() < 0.0000001 ? 0.0 : value;
  if ((rounded - rounded.roundToDouble()).abs() < 0.0000001) {
    return rounded.round().toString();
  }
  return rounded.toStringAsFixed(2);
}

/// A round photo, or initials when there is none.
Widget _memberAvatarFor(
  BuildContext context, {
  required String name,
  required String? avatarUrl,
  double size = 72,
}) {
  final colors = Theme.of(context).colorScheme;
  final fallback = Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: colors.primaryContainer,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      _initialsOf(name),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: colors.onPrimaryContainer,
        fontWeight: FontWeight.w600,
        fontSize: size * 0.38,
        letterSpacing: 0.2,
      ),
    ),
  );
  final url = (avatarUrl ?? '').trim();
  if (url.isEmpty) return fallback;
  return ClipOval(
    child: Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    ),
  );
}

String _initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.characters.first.toUpperCase();
  }
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

enum _ReceiptSource { camera, gallery, files }

/// Take a photo, pick one or pick a file, then crop it. Null when cancelled,
/// failed (a snack says why) or the account changed meanwhile.
Future<_PickedFile?> _pickReceiptPhoto(
  BuildContext pickerContext, {
  required int? Function() currentAccountId,
}) async {
  final t = pickerContext.l10n;
  final account = currentAccountId();
  bool stillHere() => pickerContext.mounted && account == currentAccountId();
  void fail(String message) {
    if (!pickerContext.mounted) return;
    ScaffoldMessenger.maybeOf(
      pickerContext,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  // Receipt photos are used as taken: no crop screen. The native crop
  // screen sometimes did not open right after the camera on iOS and left the
  // form waiting forever; receipts and AI reading don't need cropping.
  Future<_PickedFile?> prepare(String fileName, Uint8List bytes) async {
    try {
      final prepared = await ReceiptImagePreparer.prepare(
        bytes: bytes,
        fileName: fileName,
      );
      if (!stillHere()) return null;
      return _PickedFile(fileName: prepared.fileName, bytes: prepared.bytes);
    } catch (_) {
      fail(t.receiptPickFailed);
      return null;
    }
  }

  try {
    final source = await showAppPlatformActionSheet<_ReceiptSource>(
      context: pickerContext,
      title: t.addReceiptAction,
      cancelLabel: t.cancelAction,
      actions: [
        AppPlatformAction(
          value: _ReceiptSource.camera,
          icon: Icons.photo_camera_outlined,
          title: t.takePhotoAction,
        ),
        AppPlatformAction(
          value: _ReceiptSource.gallery,
          icon: Icons.photo_library_outlined,
          title: t.chooseFromLibraryAction,
        ),
        AppPlatformAction(
          value: _ReceiptSource.files,
          icon: Icons.folder_open_outlined,
          title: t.chooseReceiptFile,
        ),
      ],
    );
    if (!stillHere() || source == null) return null;
    if (source == _ReceiptSource.files) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>[
          'jpg',
          'jpeg',
          'png',
          'webp',
          'heic',
          'heif',
          'hif',
        ],
        withData: true,
      );
      if (!stillHere() || result == null || result.files.isEmpty) return null;
      final file = result.files.first;
      final name = file.name.trim().isEmpty
          ? t.receiptFallbackName
          : file.name.trim();
      var bytes = file.bytes;
      final path = file.path;
      if ((bytes == null || bytes.isEmpty) &&
          path != null &&
          path.trim().isNotEmpty) {
        bytes = await File(path).readAsBytes();
      }
      if (!stillHere() || bytes == null || bytes.isEmpty) return null;
      return prepare(name, bytes);
    }
    final photo = await ImagePicker().pickImage(
      source: source == _ReceiptSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 94,
      maxWidth: 4096,
      maxHeight: 4096,
      requestFullMetadata: false,
    );
    if (!stillHere() || photo == null) return null;
    final bytes = await photo.readAsBytes();
    if (!stillHere() || bytes.isEmpty) return null;
    return prepare(
      photo.name.trim().isEmpty ? 'receipt.jpg' : photo.name,
      bytes,
    );
  } on PlatformException catch (error) {
    final code = error.code.toLowerCase();
    fail(
      code.contains('access_denied') || code.contains('access_restricted')
          ? t.receiptPhotoAccessDenied
          : t.receiptPickFailed,
    );
  } catch (_) {
    fail(t.receiptPickFailed);
  }
  return null;
}

/// The camera button next to the amount. A dot shows a receipt is attached.
class _ExpenseReceiptButton extends StatelessWidget {
  const _ExpenseReceiptButton({
    required this.onPressed,
    required this.hasReceipt,
    required this.busy,
  });

  final VoidCallback? onPressed;
  final bool hasReceipt;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: context.l10n.receiptButtonTooltip,
      child: Semantics(
        button: true,
        label: context.l10n.receiptButtonTooltip,
        excludeSemantics: true,
        child: Material(
          key: const ValueKey('receipt-add'),
          color: AppDesign.isDark(context)
              ? AppDesign.darkSurface
              : AppDesign.lightSurfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colors.primary.withValues(alpha: .35)),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Badge(
                        isLabelVisible: hasReceipt,
                        smallSize: 8,
                        backgroundColor: colors.primary,
                        child: Icon(
                          Icons.photo_camera_outlined,
                          color: colors.primary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "+" under Split between, for adding someone to a quick split.
class _ExpenseAddPersonButton extends StatelessWidget {
  const _ExpenseAddPersonButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = context.l10n.quickSplitAddPerson;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('expense-add-person'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppDesign.mutedColor(context)),
                  ),
                  child: Icon(Icons.add_rounded, color: colors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "⚡ Quick split ▾" or "Trip name ▾" under the form title.
class _ExpenseTargetChip extends StatelessWidget {
  const _ExpenseTargetChip({
    super.key,
    required this.label,
    required this.onTap,
    this.quickSplit = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool quickSplit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
    );
    return Semantics(
      button: true,
      label: '$label, ${context.l10n.expenseTargetChange}',
      excludeSemantics: true,
      child: Material(
        color: colors.primary.withValues(alpha: .1),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quickSplit) ...[
                  Icon(Icons.bolt_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: style,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
