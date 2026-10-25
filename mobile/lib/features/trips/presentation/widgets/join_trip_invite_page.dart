import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/deeplink/invite_deep_link_controller.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';

class JoinTripInvitePage extends StatefulWidget {
  const JoinTripInvitePage({super.key});
  @override
  State<JoinTripInvitePage> createState() => _JoinTripInvitePageState();
}

class _JoinTripInvitePageState extends State<JoinTripInvitePage> {
  final _input = TextEditingController();
  String? _error;
  bool _pasting = false, _submitted = false;
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted) return;
    String? token;
    try {
      token = InviteDeepLinkParser.extractInviteCodeFromRaw(_input.text);
    } on FormatException {
      /* Malformed pasted URLs are validation failures. */
    } on ArgumentError {
      // URI query decoding also rejects incomplete percent escapes this way.
    }
    if (token == null) {
      setState(() => _error = context.l10n.tripsEnterAValidInviteLinkOrToken);
      return;
    }
    setState(() => _submitted = true);
    Navigator.pop(context, token);
  }

  Future<void> _paste() async {
    if (_pasting) return;
    setState(() => _pasting = true);
    try {
      final value = (await Clipboard.getData('text/plain'))?.text?.trim() ?? '';
      if (!mounted || _submitted) return;
      setState(() {
        if (value.isEmpty) {
          _error = context.l10n.tripsClipboardIsEmpty;
        } else {
          _input.text = value;
          _error = null;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.inviteClipboardFailed);
    } finally {
      if (mounted) setState(() => _pasting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppFormScaffold(
      key: const ValueKey('join-trip-page'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 12),
            child: Row(
              children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: _submitted ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.tripsJoinTrip,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(
                  t.tripsPasteInviteLinkOrInviteToken,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  key: const ValueKey('join-trip-input'),
                  controller: _input,
                  textInputAction: TextInputAction.done,
                  minLines: 1,
                  maxLines: 4,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    filled: false,
                    hintText: t.tripsHttpsInviteNorthSeaAbc123def4,
                    errorText: _error,
                    errorMaxLines: 5,
                    prefixIcon: const Icon(Icons.link),
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _pasting || _submitted ? null : _paste,
                    icon: const Icon(Icons.content_paste_outlined),
                    label: Text(t.tripsPaste),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('join-trip-submit'),
                onPressed: _submitted ? null : _submit,
                child: Text(t.tripsJoin),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
