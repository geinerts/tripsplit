import 'package:flutter/material.dart';

import '../../../../app/theme/app_design.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/splyto_illustration.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({
    super.key,
    required this.email,
    required this.onRequest,
  });

  final String email;
  final Future<void> Function(String password, List<String> reasons) onRequest;

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final _password = TextEditingController();
  final _errorKey = GlobalKey();
  final _reasons = <String>{};
  bool _sending = false;
  bool _sent = false;
  bool _needsPassword = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || _sent) return;
    if (_needsPassword && _password.text.isEmpty) {
      setState(() => _error = context.l10n.accountDeletePasswordHint);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onRequest(_password.text, List.unmodifiable(_reasons));
      if (!mounted) return;
      _password.clear();
      setState(() => _sent = true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        if (error.code == 'REAUTHENTICATION_REQUIRED') {
          _needsPassword = true;
          _error = context.l10n.accountDeletePasswordHint;
        } else {
          _error = context.l10n.profileEditCouldNotSendDeletionLinkTryAgain;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.profileEditCouldNotSendDeletionLinkTryAgain;
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        if (_error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final target = _errorKey.currentContext;
            if (mounted && target != null) {
              Scrollable.ensureVisible(
                target,
                alignment: 1,
                duration: const Duration(milliseconds: 180),
              );
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const cyan = Color(0xFF00BED4);
    const pink = Color(0xFFDD2684);
    final reasons = {
      'not_using': t.accountDeleteReasonNotUsing,
      'another_way': t.accountDeleteReasonAnotherWay,
      'too_complicated': t.accountDeleteReasonComplicated,
      'technical_issue': t.accountDeleteReasonTechnical,
      'privacy': t.accountDeleteReasonPrivacy,
      'other': t.accountDeleteReasonOther,
    };
    return PopScope(
      canPop: !_sending,
      child: AppFormScaffold(
        header: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: IconButton.filledTonal(
              style: IconButton.styleFrom(
                foregroundColor: cyan,
                backgroundColor: cyan.withValues(alpha: .10),
              ),
              tooltip: t.authClose,
              onPressed: _sending ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('account-delete-scroll'),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_sent) ...[
                      const SizedBox(height: 24),
                      const SplytoEmailSentIllustration(),
                      const SizedBox(height: 24),
                    ],
                    Semantics(
                      header: true,
                      child: Text(
                        _sent
                            ? t.accountDeleteInboxTitle
                            : t.accountDeleteTitle,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _sent
                          ? t.accountDeleteSentBody(widget.email)
                          : t.accountDeleteIntro,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (_sent) ...[
                      const SizedBox(height: 16),
                      Text(
                        t.accountDeleteSentHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (!_sent) ...[
                      const SizedBox(height: 28),
                      Text(
                        t.accountDeleteReasonsHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final reason in reasons.entries) ...[
                        CheckboxListTile(
                          activeColor: pink,
                          checkColor: Colors.white,
                          side: WidgetStateBorderSide.resolveWith(
                            (states) => BorderSide(
                              color: states.contains(WidgetState.selected)
                                  ? pink
                                  : cyan,
                              width: 1.8,
                            ),
                          ),
                          key: ValueKey('delete-reason-${reason.key}'),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(reason.value),
                          value: _reasons.contains(reason.key),
                          onChanged: _sending
                              ? null
                              : (selected) => setState(() {
                                  if (selected == true) {
                                    _reasons.add(reason.key);
                                  } else {
                                    _reasons.remove(reason.key);
                                  }
                                }),
                        ),
                        if (reason.key != 'other') const Divider(height: 1),
                      ],
                      if (_needsPassword) ...[
                        const SizedBox(height: 20),
                        TextField(
                          key: const ValueKey('account-delete-password'),
                          controller: _password,
                          enabled: !_sending,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            labelText: t.profileEditCurrentPassword,
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          key: _errorKey,
                          liveRegion: true,
                          child: Text(
                            _error!,
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    key: const ValueKey('account-delete-submit'),
                    onPressed: _sending
                        ? null
                        : _sent
                        ? () => Navigator.of(context).pop()
                        : _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: _sent
                          ? colors.primary
                          : AppDesign.destructiveColor(context),
                      foregroundColor: _sent
                          ? colors.onPrimary
                          : colors.onError,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _sending
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onSurfaceVariant,
                              semanticsLabel: t.accountDeleteSending,
                            ),
                          )
                        : Text(
                            _sent
                                ? t.profileEditBackProfile
                                : t.accountDeleteTitle,
                            textAlign: TextAlign.center,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
