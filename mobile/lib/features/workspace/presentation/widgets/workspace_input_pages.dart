import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';

class WorkspaceInputPage extends StatelessWidget {
  const WorkspaceInputPage({
    super.key,
    required this.title,
    required this.children,
    required this.action,
    required this.onSubmit,
    this.canClose = true,
  });
  final String title, action;
  final bool canClose;
  final List<Widget> children;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) => AppFormScaffold(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 12),
          child: Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: canClose ? () => Navigator.pop(context) : null,
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: children,
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onSubmit, child: Text(action)),
          ),
        ),
      ],
    ),
  );
}

class EditExpenseCommentPage extends StatefulWidget {
  const EditExpenseCommentPage({super.key, required this.initial});
  final String initial;
  @override
  State<EditExpenseCommentPage> createState() => _EditExpenseCommentPageState();
}

class _EditExpenseCommentPageState extends State<EditExpenseCommentPage> {
  late final _text = TextEditingController(text: widget.initial);
  bool _submitted = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _text,
        builder: (context, value, _) => WorkspaceInputPage(
          title: context.l10n.editAction,
          action: context.l10n.saveAction,
          onSubmit:
              _submitted ||
                  value.text.trim().isEmpty ||
                  value.text.trim() == widget.initial.trim()
              ? null
              : () {
                  if (_submitted) return;
                  setState(() => _submitted = true);
                  Navigator.pop(context, value.text.trim());
                },
          children: [
            TextField(
              key: const ValueKey('comment-edit-input'),
              controller: _text,
              autofocus: true,
              maxLength: 280,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                filled: false,
                labelText: context.l10n.expenseCommentsTitle,
                hintText: context.l10n.expenseAddCommentHint,
              ),
            ),
          ],
        ),
      );
}

class TripPaymentDraft {
  const TripPaymentDraft(this.amount, this.note, this.sharePaymentDetails);
  final double amount;
  final String note;
  final bool sharePaymentDetails;
}

class TripPaymentComposerPage extends StatefulWidget {
  const TripPaymentComposerPage({
    super.key,
    required this.memberName,
    required this.maxAmount,
    required this.maxAmountLabel,
    required this.isRequest,
  });
  final String memberName, maxAmountLabel;
  final double maxAmount;
  final bool isRequest;
  @override
  State<TripPaymentComposerPage> createState() =>
      _TripPaymentComposerPageState();
}

class _TripPaymentComposerPageState extends State<TripPaymentComposerPage> {
  late final _amount = TextEditingController(
    text: widget.maxAmount.toStringAsFixed(2),
  );
  final _note = TextEditingController();
  bool _share = false, _submitted = false;
  String? _error;
  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted) return;
    final amount =
        double.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;
    final t = context.l10n;
    if (!amount.isFinite || amount <= 0) {
      setState(() => _error = t.paymentAmountPositiveError);
      return;
    }
    if (amount - widget.maxAmount > .005) {
      setState(() => _error = t.paymentAmountTooHighError);
      return;
    }
    setState(() => _submitted = true);
    Navigator.pop(
      context,
      TripPaymentDraft(amount, _note.text, widget.isRequest && _share),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return WorkspaceInputPage(
      title: widget.isRequest
          ? t.paymentRequestSheetTitle
          : t.paymentRecordSheetTitle,
      action: widget.isRequest
          ? t.paymentRequestAction
          : t.paymentMarkPaidAction,
      onSubmit: _submitted ? null : _submit,
      children: [
        Text(
          widget.isRequest
              ? t.paymentRequestSheetBody(widget.memberName)
              : t.paymentRecordSheetBody(widget.memberName),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        TextField(
          key: const ValueKey('payment-amount'),
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          decoration: InputDecoration(
            filled: false,
            labelText: t.amountLabel,
            helperText: t.paymentMaxAmount(widget.maxAmountLabel),
            helperMaxLines: 4,
            errorText: _error,
            errorMaxLines: 4,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          key: const ValueKey('payment-note'),
          controller: _note,
          maxLength: 120,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            filled: false,
            labelText: t.noteLabel,
            hintText: t.paymentNoteHint,
          ),
        ),
        if (widget.isRequest)
          CheckboxListTile(
            key: const ValueKey('payment-share-consent'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _share,
            title: Text(t.paymentShareDetailsConsent(widget.memberName)),
            subtitle: Text(t.paymentShareDetailsScope),
            onChanged: (v) => setState(() => _share = v == true),
          ),
      ],
    );
  }
}
