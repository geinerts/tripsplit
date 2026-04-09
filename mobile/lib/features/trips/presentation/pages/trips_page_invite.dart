part of 'trips_page.dart';

extension _TripsPageInviteActions on _TripsPageState {
  Future<void> _onJoinTripPressed() async {
    if (_isMutating || _isLoading) {
      return;
    }

    final inviteToken = await _showJoinTripInviteDialog();
    if (inviteToken == null || !mounted) {
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      final preview = await widget.controller.previewTripInvite(
        inviteToken: inviteToken,
      );
      final joined = await widget.controller.joinTripInvite(
        inviteToken: inviteToken,
        previewNonce: preview.previewNonce,
      );
      await _loadTrips(forceRefresh: true);
      if (!mounted) {
        return;
      }
      final trip = _resolveJoinedTrip(joined.trip.id, fallback: joined.trip);
      _showSnack(
        joined.alreadyMember
            ? _plainLocalizedText(
                en: 'You are already a member of this trip.',
                lv: 'Tu jau esi šī ceļojuma dalībnieks.',
              )
            : _plainLocalizedText(
                en: 'Joined trip successfully.',
                lv: 'Veiksmīgi pievienojies ceļojumam.',
              ),
      );
      await _openWorkspace(trip);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(
        _plainLocalizedText(
          en: 'Failed to join trip from invite.',
          lv: 'Neizdevās pievienoties ceļojumam no ielūguma.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<String?> _showJoinTripInviteDialog() async {
    final inputController = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) {
          String? errorText;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final t = context.l10n;
              return AlertDialog(
                title: Text(
                  _plainLocalizedText(
                    en: 'Join trip',
                    lv: 'Pievienoties ceļojumam',
                  ),
                ),
                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _plainLocalizedText(
                          en: 'Paste invite link or invite token.',
                          lv: 'Ielīmē ielūguma saiti vai ielūguma tokenu.',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: inputController,
                        textInputAction: TextInputAction.done,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: _plainLocalizedText(
                            en: 'https://.../?invite=north-sea-abc123def4',
                            lv: 'https://.../?invite=north-sea-abc123def4',
                          ),
                          prefixIcon: const Icon(Icons.link_rounded),
                        ),
                        onChanged: (_) {
                          if (errorText == null) {
                            return;
                          }
                          setDialogState(() {
                            errorText = null;
                          });
                        },
                        onSubmitted: (_) {
                          final token = _extractInviteToken(
                            inputController.text,
                          );
                          if (token == null) {
                            setDialogState(() {
                              errorText = _plainLocalizedText(
                                en: 'Enter a valid invite link or token.',
                                lv: 'Ievadi derīgu ielūguma saiti vai tokenu.',
                              );
                            });
                            return;
                          }
                          Navigator.of(context).pop(token);
                        },
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final clipboard = await Clipboard.getData(
                            'text/plain',
                          );
                          if (!context.mounted) {
                            return;
                          }
                          final value = (clipboard?.text ?? '').trim();
                          if (value.isEmpty) {
                            setDialogState(() {
                              errorText = _plainLocalizedText(
                                en: 'Clipboard is empty.',
                                lv: 'Starpliktuve ir tukša.',
                              );
                            });
                            return;
                          }
                          setDialogState(() {
                            inputController.text = value;
                            errorText = null;
                          });
                        },
                        icon: const Icon(Icons.content_paste_rounded),
                        label: Text(
                          _plainLocalizedText(en: 'Paste', lv: 'Ielīmēt'),
                        ),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.cancelAction),
                  ),
                  FilledButton(
                    onPressed: () {
                      final token = _extractInviteToken(inputController.text);
                      if (token == null) {
                        setDialogState(() {
                          errorText = _plainLocalizedText(
                            en: 'Enter a valid invite link or token.',
                            lv: 'Ievadi derīgu ielūguma saiti vai tokenu.',
                          );
                        });
                        return;
                      }
                      Navigator.of(context).pop(token);
                    },
                    child: Text(
                      _plainLocalizedText(en: 'Join', lv: 'Pievienoties'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      inputController.dispose();
    }
  }

  String? _extractInviteToken(String rawInput) {
    return InviteDeepLinkParser.extractInviteCodeFromRaw(rawInput);
  }

  Trip _resolveJoinedTrip(int tripId, {required Trip fallback}) {
    for (final trip in _trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }
    return fallback;
  }
}
