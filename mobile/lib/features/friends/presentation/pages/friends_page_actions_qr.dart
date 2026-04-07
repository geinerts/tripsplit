part of 'friends_page.dart';

extension _FriendsPageActionsQr on _FriendsPageState {
  Future<void> _openAddFriendActions(FriendsSnapshot snapshot) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_rounded),
                title: Text(_txt(en: 'Search users', lv: 'Meklēt lietotājus')),
                subtitle: Text(
                  _txt(
                    en: 'Find by name or email and send invite',
                    lv: 'Meklē pēc vārda vai e-pasta un nosūti uzaicinājumu',
                  ),
                ),
                onTap: () => Navigator.of(sheetContext).pop('search'),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner_rounded),
                title: Text(_txt(en: 'Scan QR', lv: 'Skenēt QR')),
                subtitle: Text(
                  _txt(
                    en: 'Scan another user to add friend',
                    lv: 'Noskenē cita lietotāja QR, lai pievienotu draugu',
                  ),
                ),
                onTap: () => Navigator.of(sheetContext).pop('scan'),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_2_rounded),
                title: Text(_txt(en: 'My QR', lv: 'Mans QR')),
                subtitle: Text(
                  _txt(
                    en: 'Show or share your QR code',
                    lv: 'Parādi vai nošēro savu QR kodu',
                  ),
                ),
                onTap: () => Navigator.of(sheetContext).pop('mine'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }
    switch (choice) {
      case 'search':
        await _openAddFriendSheet(snapshot);
        break;
      case 'scan':
        await _openScanFriendQr();
        break;
      case 'mine':
        await _openMyFriendQr();
        break;
    }
  }

  Future<void> _openScanFriendQr() async {
    final rawCode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => const _FriendQrScannerPage(),
      ),
    );
    if (rawCode == null || !mounted) {
      return;
    }

    final scannedUserId = _parseFriendUserIdFromQr(rawCode);
    if (scannedUserId == null || scannedUserId <= 0) {
      _showSnack(
        _txt(
          en: 'QR code is not a valid friend code.',
          lv: 'QR kods nav derīgs drauga kods.',
        ),
        isError: true,
      );
      return;
    }

    final selfUserId = await _resolveCurrentUserId();
    if (!mounted) {
      return;
    }
    if (selfUserId > 0 && scannedUserId == selfUserId) {
      _showSnack(
        _txt(
          en: 'You cannot add yourself.',
          lv: 'Tu nevari pievienot pats sevi.',
        ),
        isError: true,
      );
      return;
    }

    final snapshot = _snapshot;
    if (snapshot != null) {
      final isAlreadyFriend = snapshot.friends.any(
        (f) => f.id == scannedUserId,
      );
      if (isAlreadyFriend) {
        _showSnack(
          _txt(
            en: 'This user is already in your friends list.',
            lv: 'Šis lietotājs jau ir tavā draugu sarakstā.',
          ),
        );
        return;
      }
      final isInviteAlreadySent = snapshot.pendingSent.any(
        (request) => request.user.id == scannedUserId,
      );
      if (isInviteAlreadySent) {
        _showSnack(
          _txt(
            en: 'Invite to this user is already sent.',
            lv: 'Uzaicinājums šim lietotājam jau ir nosūtīts.',
          ),
        );
        return;
      }
    }

    try {
      await widget.controller.sendInvite(userId: scannedUserId);
      if (!mounted) {
        return;
      }
      _showSnack(
        _txt(
          en: 'Friend request processed.',
          lv: 'Drauga pieprasījums apstrādāts.',
        ),
      );
      await _loadSnapshot(showLoader: false);
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
        _txt(
          en: 'Failed to process friend QR.',
          lv: 'Neizdevās apstrādāt drauga QR.',
        ),
        isError: true,
      );
    }
  }

  Future<void> _openMyFriendQr() async {
    final currentUser = await _resolveCurrentUser();
    if (!mounted) {
      return;
    }
    if (currentUser == null || currentUser.id <= 0) {
      _showSnack(
        _txt(
          en: 'Could not load your user profile.',
          lv: 'Neizdevās ielādēt tavu profilu.',
        ),
        isError: true,
      );
      return;
    }

    final payload = _buildFriendQrPayload(currentUser.id);
    final name = currentUser.nickname.trim().isEmpty
        ? _txt(en: 'My profile', lv: 'Mans profils')
        : currentUser.nickname.trim();

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => _MyFriendQrPage(nickname: name, payload: payload),
      ),
    );
  }

  Future<int> _resolveCurrentUserId() async {
    final inMemory = widget.authController.currentUser;
    if (inMemory != null && inMemory.id > 0) {
      return inMemory.id;
    }
    final cached = await widget.authController.readCachedCurrentUser();
    return cached?.id ?? 0;
  }

  Future<_FriendQrUserIdentity?> _resolveCurrentUser() async {
    final inMemory = widget.authController.currentUser;
    if (inMemory != null && inMemory.id > 0) {
      return _FriendQrUserIdentity(
        id: inMemory.id,
        nickname: inMemory.nickname,
      );
    }
    final cached = await widget.authController.readCachedCurrentUser();
    if (cached == null || cached.id <= 0) {
      return null;
    }
    return _FriendQrUserIdentity(id: cached.id, nickname: cached.nickname);
  }

  String _buildFriendQrPayload(int userId) {
    return Uri(
      scheme: 'tripsplit',
      host: 'friend',
      queryParameters: <String, String>{'uid': '$userId'},
    ).toString();
  }

  int? _parseFriendUserIdFromQr(String rawValue) {
    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return null;
    }
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      return int.tryParse(raw);
    }

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      for (final key in const <String>[
        'uid',
        'user_id',
        'friend',
        'friend_id',
      ]) {
        final candidate = (uri.queryParameters[key] ?? '').trim();
        if (RegExp(r'^\d+$').hasMatch(candidate)) {
          return int.tryParse(candidate);
        }
      }
    }

    final queryMatch = RegExp(
      r'(?:^|[?&])(?:uid|user_id|friend|friend_id)=(\d+)(?:&|$)',
      caseSensitive: false,
    ).firstMatch(raw);
    final queryValue = (queryMatch?.group(1) ?? '').trim();
    if (RegExp(r'^\d+$').hasMatch(queryValue)) {
      return int.tryParse(queryValue);
    }

    if (raw.startsWith('{') && raw.endsWith('}')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final candidate = decoded['uid'] ?? decoded['user_id'];
          if (candidate is int && candidate > 0) {
            return candidate;
          }
          if (candidate is String) {
            final normalized = candidate.trim();
            if (RegExp(r'^\d+$').hasMatch(normalized)) {
              return int.tryParse(normalized);
            }
          }
        }
      } catch (_) {
        // Ignore malformed JSON and continue.
      }
    }

    return null;
  }
}

class _FriendQrUserIdentity {
  const _FriendQrUserIdentity({required this.id, required this.nickname});

  final int id;
  final String nickname;
}

class _FriendQrScannerPage extends StatefulWidget {
  const _FriendQrScannerPage();

  @override
  State<_FriendQrScannerPage> createState() => _FriendQrScannerPageState();
}

class _FriendQrScannerPageState extends State<_FriendQrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _handled = false;

  @override
  void dispose() {
    unawaited(_controller.stop());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLv =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'lv';
    return Scaffold(
      appBar: AppBar(title: Text(isLv ? 'Skenēt drauga QR' : 'Scan Friend QR')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
              ),
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLv
                      ? 'Novieto drauga QR kodu rāmī'
                      : 'Place friend QR code inside the frame',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final raw = (barcode.rawValue ?? '').trim();
      if (raw.isEmpty) {
        continue;
      }
      _handled = true;
      unawaited(_controller.stop());
      Navigator.of(context).pop(raw);
      return;
    }
  }
}

class _MyFriendQrPage extends StatelessWidget {
  const _MyFriendQrPage({required this.nickname, required this.payload});

  final String nickname;
  final String payload;

  @override
  Widget build(BuildContext context) {
    final isLv =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'lv';
    return Scaffold(
      appBar: AppBar(title: Text(isLv ? 'Mans drauga QR' : 'My Friend QR')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppDesign.cardSurface(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppDesign.cardStroke(context)),
                  boxShadow: AppDesign.cardShadow(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLv
                            ? 'Atver Friends > Scan QR otrā telefonā un noskenē šo kodu.'
                            : 'Open Friends > Scan QR on another phone and scan this code.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: QrImageView(
                          data: payload,
                          size: 236,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF222222),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        payload,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => SharePlus.instance.share(
                                ShareParams(
                                  text: isLv
                                      ? 'Pievieno mani TripSplit draugos.\n$payload'
                                      : 'Add me on TripSplit friends.\n$payload',
                                  subject: isLv
                                      ? 'TripSplit drauga kods'
                                      : 'TripSplit friend code',
                                ),
                              ),
                              icon: const Icon(Icons.share_rounded),
                              label: Text(isLv ? 'Nošērot' : 'Share'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
