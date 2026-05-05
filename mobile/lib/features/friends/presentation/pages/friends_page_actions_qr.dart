part of 'friends_page.dart';

const String _friendQrLogoAsset = 'assets/branding/launch_symbol_420.png';
const double _friendQrSize = 236;
const double _friendQrLogoSize = 69;
const Size _friendQrLogoClearSize = Size(58, 74);

extension _FriendsPageActionsQr on _FriendsPageState {
  Future<void> _openAddFriendActions(FriendsSnapshot snapshot) async {
    final choice = await showAppBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppActionSheetTile(
              icon: Icons.qr_code_scanner_rounded,
              title: context.l10n.friendsScanQr,
              subtitle: context.l10n.friendsScanAnotherUserToAddFriend,
              onTap: () => Navigator.of(sheetContext).pop('scan'),
            ),
            AppActionSheetTile(
              icon: Icons.qr_code_2_rounded,
              title: context.l10n.friendsMyQr,
              subtitle: context.l10n.friendsShowOrShareYourQrCode,
              onTap: () => Navigator.of(sheetContext).pop('mine'),
            ),
          ],
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }
    switch (choice) {
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
      AppPageRoute<String>(builder: (context) => const _FriendQrScannerPage()),
    );
    if (rawCode == null || !mounted) {
      return;
    }

    final target = _parseFriendInviteTargetFromQr(rawCode);
    final scannedUserId = target?.userId;
    if (target == null || scannedUserId == null || scannedUserId <= 0) {
      _showSnack(
        context.l10n.friendsQrCodeIsNotAValidFriendCode,
        isError: true,
      );
      return;
    }

    final selfUserId = await _resolveCurrentUserId();
    if (!mounted) {
      return;
    }
    if (selfUserId > 0 && scannedUserId == selfUserId) {
      _showSnack(context.l10n.friendsYouCannotAddYourself, isError: true);
      return;
    }

    FriendsSnapshot? snapshot = _snapshot;
    try {
      snapshot = await widget.controller.loadSnapshot(forceRefresh: true);
    } catch (_) {
      // The invite endpoint still validates relationship state server-side.
      // Keep the scanned flow usable if a refresh fails.
    }
    if (!mounted) {
      return;
    }

    FriendRequest? incomingRequest;
    String? inviteeName = target.displayName;
    if (snapshot != null) {
      inviteeName =
          _knownFriendInviteName(snapshot, scannedUserId) ?? inviteeName;
      final isAlreadyFriend = snapshot.friends.any(
        (f) => f.id == scannedUserId,
      );
      if (isAlreadyFriend) {
        _showSnack(context.l10n.friendsThisUserIsAlreadyInYourFriendsList);
        return;
      }
      for (final request in snapshot.pendingReceived) {
        if (request.user.id == scannedUserId) {
          incomingRequest = request;
          break;
        }
      }
      final isInviteAlreadySent = snapshot.pendingSent.any(
        (request) => request.user.id == scannedUserId,
      );
      if (isInviteAlreadySent) {
        _showSnack(context.l10n.friendsInviteToThisUserIsAlreadySent);
        return;
      }
    }

    final confirmed = await _showFriendInviteConfirmDialog(
      displayName: inviteeName,
      isAcceptingIncomingRequest: incomingRequest != null,
    );
    if (!mounted || !confirmed) {
      return;
    }

    try {
      if (incomingRequest != null) {
        await widget.controller.respondInvite(
          requestId: incomingRequest.requestId,
          accept: true,
        );
      } else {
        await widget.controller.sendInvite(userId: scannedUserId);
      }
      if (!mounted) {
        return;
      }
      _showSnack(
        incomingRequest != null
            ? context.l10n.friendsFriendAdded
            : context.l10n.friendsFriendRequestProcessed,
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
      _showSnack(context.l10n.friendsFailedToProcessFriendQr, isError: true);
    }
  }

  Future<void> _openMyFriendQr() async {
    final currentUser = await _resolveCurrentUser();
    if (!mounted) {
      return;
    }
    if (currentUser == null || currentUser.id <= 0) {
      _showSnack(
        context.l10n.friendsCouldNotLoadYourUserProfile,
        isError: true,
      );
      return;
    }

    final name = currentUser.displayName.trim().isEmpty
        ? currentUser.nickname.trim().isEmpty
              ? context.l10n.friendsMyProfile
              : currentUser.nickname.trim()
        : currentUser.displayName.trim();
    final payload = _buildFriendQrPayload(currentUser.id);

    await Navigator.of(context).push<void>(
      AppPageRoute<void>(
        builder: (context) => _MyFriendQrPage(
          displayName: name,
          payload: payload,
          avatarBytes: currentUser.avatarBytes,
          avatarUrl: currentUser.avatarUrl,
        ),
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
        displayName: _friendQrDisplayName(
          displayName: inMemory.displayName,
          firstName: inMemory.firstName,
          lastName: inMemory.lastName,
          nickname: inMemory.nickname,
        ),
        avatarBytes: widget.authController.avatarBytesFor(inMemory),
        avatarUrl: widget.authController.avatarUrlFor(
          inMemory,
          preferThumb: true,
        ),
      );
    }
    final cached = await widget.authController.readCachedCurrentUser();
    if (cached == null || cached.id <= 0) {
      return null;
    }
    return _FriendQrUserIdentity(
      id: cached.id,
      nickname: cached.nickname,
      displayName: _friendQrDisplayName(
        displayName: cached.displayName,
        firstName: cached.firstName,
        lastName: cached.lastName,
        nickname: cached.nickname,
      ),
      avatarBytes: widget.authController.avatarBytesFor(cached),
      avatarUrl: widget.authController.avatarUrlFor(cached, preferThumb: true),
    );
  }

  String _friendQrDisplayName({
    required String? displayName,
    required String? firstName,
    required String? lastName,
    required String nickname,
  }) {
    final explicit = (displayName ?? '').trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    final fullName = [
      (firstName ?? '').trim(),
      (lastName ?? '').trim(),
    ].where((part) => part.isNotEmpty).join(' ').trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return nickname.trim();
  }

  String _buildFriendQrPayload(int userId) {
    return Uri.https('splyto.eu', '/friend', <String, String>{
      'code': FriendLinkCodec.encode(userId),
    }).toString();
  }

  FriendDeepLinkTarget? _parseFriendInviteTargetFromQr(String rawValue) {
    final fromDeepLinkParser = InviteDeepLinkParser.extractFriendTargetFromRaw(
      rawValue,
    );
    if (fromDeepLinkParser != null && fromDeepLinkParser.userId > 0) {
      return fromDeepLinkParser;
    }

    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return null;
    }
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      final userId = int.tryParse(raw);
      return userId == null || userId <= 0
          ? null
          : FriendDeepLinkTarget(userId: userId);
    }

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final target = InviteDeepLinkParser.extractFriendTargetFromUri(uri);
      if (target != null && target.userId > 0) {
        return target;
      }
    }

    final queryMatch = RegExp(
      r'(?:^|[?&])(?:uid|user_id|friend|friend_id)=(\d+)(?:&|$)',
      caseSensitive: false,
    ).firstMatch(raw);
    final queryValue = (queryMatch?.group(1) ?? '').trim();
    if (RegExp(r'^\d+$').hasMatch(queryValue)) {
      final userId = int.tryParse(queryValue);
      return userId == null || userId <= 0
          ? null
          : FriendDeepLinkTarget(userId: userId);
    }

    if (raw.startsWith('{') && raw.endsWith('}')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final candidate = decoded['uid'] ?? decoded['user_id'];
          final code = (decoded['code'] ?? decoded['friend_code'])
              ?.toString()
              .trim();
          final codeUserId = FriendLinkCodec.decode(code ?? '');
          if (codeUserId != null) {
            return FriendDeepLinkTarget(userId: codeUserId);
          }
          final name = (decoded['name'] ?? decoded['display_name'])
              ?.toString()
              .trim();
          if (candidate is int && candidate > 0) {
            return FriendDeepLinkTarget(
              userId: candidate,
              displayName: name?.isEmpty == true ? null : name,
            );
          }
          if (candidate is String) {
            final normalized = candidate.trim();
            if (RegExp(r'^\d+$').hasMatch(normalized)) {
              final userId = int.tryParse(normalized);
              return userId == null || userId <= 0
                  ? null
                  : FriendDeepLinkTarget(
                      userId: userId,
                      displayName: name?.isEmpty == true ? null : name,
                    );
            }
          }
        }
      } catch (_) {
        // Ignore malformed JSON and continue.
      }
    }

    return null;
  }

  String? _knownFriendInviteName(FriendsSnapshot snapshot, int userId) {
    for (final friend in snapshot.friends) {
      if (friend.id == userId) {
        return friend.preferredName.trim();
      }
    }
    for (final request in <FriendRequest>[
      ...snapshot.pendingReceived,
      ...snapshot.pendingSent,
    ]) {
      if (request.user.id == userId) {
        return request.user.preferredName.trim();
      }
    }
    return null;
  }

  Future<bool> _showFriendInviteConfirmDialog({
    required String? displayName,
    required bool isAcceptingIncomingRequest,
  }) {
    final name = (displayName ?? '').trim().isEmpty
        ? context.l10n.friendsUser
        : displayName!.trim();
    return showAppConfirmationDialog(
      context: context,
      title: context.l10n.friendsConfirmAddFriendTitle(name),
      message: isAcceptingIncomingRequest
          ? context.l10n.friendsConfirmAcceptFriendRequestText(name)
          : context.l10n.friendsConfirmSendFriendInviteText(name),
      confirmLabel: isAcceptingIncomingRequest
          ? context.l10n.friendsAccept
          : context.l10n.friendsInviteAction,
      cancelLabel: context.l10n.cancelAction,
      icon: Icons.person_add_alt_1_rounded,
    );
  }
}

class _FriendQrUserIdentity {
  const _FriendQrUserIdentity({
    required this.id,
    required this.nickname,
    required this.displayName,
    this.avatarBytes,
    this.avatarUrl,
  });

  final int id;
  final String nickname;
  final String displayName;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
}

class _FriendQrScannerPage extends StatefulWidget {
  const _FriendQrScannerPage();

  @override
  State<_FriendQrScannerPage> createState() => _FriendQrScannerPageState();
}

class _FriendQrScannerPageState extends State<_FriendQrScannerPage> {
  static const double _scanFrameSize = 250;
  static const Duration _stableScanDelay = Duration(seconds: 1);

  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _handled = false;
  Size _scannerSize = Size.zero;
  Rect _scanWindow = Rect.zero;
  String? _candidateRaw;
  DateTime? _candidateSeenAt;

  @override
  void dispose() {
    unawaited(_controller.stop());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppPageScaffold(
      appBar: AppBar(title: Text(t.friendsScanFriendQrTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layoutSize = constraints.biggest;
          final availableFrameSize = math.max(
            120.0,
            math.min(layoutSize.width, layoutSize.height) - 48,
          );
          final frameSize = math.min(_scanFrameSize, availableFrameSize);
          final scanWindow = Rect.fromCenter(
            center: layoutSize.center(Offset.zero),
            width: frameSize,
            height: frameSize,
          );
          _scannerSize = layoutSize;
          _scanWindow = scanWindow;

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                scanWindow: scanWindow,
                scanWindowUpdateThreshold: 8,
                onDetect: _onDetect,
              ),
              IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: scanWindow,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
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
                      _candidateRaw == null
                          ? t.friendsPlaceFriendQrInsideFrame
                          : t.friendsHoldFriendQrInsideFrame,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) {
      return;
    }
    final now = DateTime.now();
    for (final barcode in capture.barcodes) {
      final raw = (barcode.rawValue ?? '').trim();
      if (raw.isEmpty) {
        continue;
      }
      if (!_isBarcodeInsideScanWindow(barcode, capture.size)) {
        continue;
      }
      if (_candidateRaw != raw) {
        _setScanCandidate(raw, now);
        return;
      }
      final seenAt = _candidateSeenAt;
      if (seenAt == null || now.difference(seenAt) < _stableScanDelay) {
        return;
      }
      _handled = true;
      unawaited(_controller.stop());
      Navigator.of(context).pop(raw);
      return;
    }
    _clearScanCandidate();
  }

  bool _isBarcodeInsideScanWindow(Barcode barcode, Size captureSize) {
    final scanWindow = _scanWindow;
    final scannerSize = _scannerSize;
    if (scanWindow.isEmpty || scannerSize.isEmpty) {
      return false;
    }

    final corners = barcode.corners;
    if (corners.length < 4 || captureSize.isEmpty) {
      // Native scanWindow still limits the camera result when corner metadata
      // is unavailable. We only apply strict client filtering when we can.
      return true;
    }

    final scale = math.max(
      scannerSize.width / captureSize.width,
      scannerSize.height / captureSize.height,
    );
    final horizontalPadding =
        (captureSize.width * scale - scannerSize.width) / 2;
    final verticalPadding =
        (captureSize.height * scale - scannerSize.height) / 2;
    final scaledCorners = <Offset>[
      for (final corner in corners)
        Offset(
          corner.dx * scale - horizontalPadding,
          corner.dy * scale - verticalPadding,
        ),
    ];
    final expandedWindow = scanWindow.inflate(3);
    return scaledCorners.every(expandedWindow.contains);
  }

  void _setScanCandidate(String raw, DateTime seenAt) {
    if (!mounted) {
      return;
    }
    setState(() {
      _candidateRaw = raw;
      _candidateSeenAt = seenAt;
    });
  }

  void _clearScanCandidate() {
    if (!mounted || _candidateRaw == null) {
      return;
    }
    setState(() {
      _candidateRaw = null;
      _candidateSeenAt = null;
    });
  }
}

class _MyFriendQrPage extends StatelessWidget {
  const _MyFriendQrPage({
    required this.displayName,
    required this.payload,
    this.avatarBytes,
    this.avatarUrl,
  });

  final String displayName;
  final String payload;
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppPageScaffold(
      appBar: AppBar(title: Text(t.friendsMyFriendQrTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppDesign.cardSurface(context),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppDesign.cardStroke(context)),
                  boxShadow: AppDesign.cardShadow(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FriendQrProfileImage(
                        displayName: displayName,
                        avatarBytes: avatarBytes,
                        avatarUrl: avatarUrl,
                      ),
                      const SizedBox(height: 18),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xFFE5E9E6)),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox.square(
                            dimension: _friendQrSize,
                            child: _FriendQrCodeView(
                              data: payload,
                              logoSize: _friendQrLogoSize,
                              logoClearArea: _friendQrLogoClearSize,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SelectableText(
                        payload,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppDesign.mutedColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: payload),
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t.paymentCopied)),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded),
                              label: Text(t.copyAction),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      '${t.friendsAddMeOnTripSplitFriends}\n$payload',
                                  subject: t.friendsTripSplitFriendCode,
                                ),
                              ),
                              icon: const Icon(Icons.share_rounded),
                              label: Text(t.shareAction),
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

class _FriendQrProfileImage extends StatelessWidget {
  const _FriendQrProfileImage({
    required this.displayName,
    this.avatarBytes,
    this.avatarUrl,
  });

  final String displayName;
  final Uint8List? avatarBytes;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(displayName);
    final normalizedUrl = (avatarUrl ?? '').trim();
    final imageCacheSize = (64 * MediaQuery.devicePixelRatioOf(context))
        .round();

    Widget child;
    if (avatarBytes != null && avatarBytes!.isNotEmpty) {
      child = Image.memory(
        avatarBytes!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else if (normalizedUrl.isNotEmpty) {
      child = Image.network(
        normalizedUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        cacheWidth: imageCacheSize,
        cacheHeight: imageCacheSize,
        errorBuilder: (context, error, stackTrace) =>
            _fallback(context, initials),
      );
    } else {
      child = _fallback(context, initials);
    }

    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppDesign.cardStroke(context).withValues(alpha: 0.9),
        ),
        boxShadow: AppDesign.avatarShadow(context),
      ),
      child: ClipOval(child: child),
    );
  }

  Widget _fallback(BuildContext context, String initials) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.72),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: AppDesign.darkForeground,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          height: 1,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _FriendQrCodeView extends StatelessWidget {
  const _FriendQrCodeView({
    required this.data,
    required this.logoSize,
    required this.logoClearArea,
  });

  final String data;
  final double logoSize;
  final Size logoClearArea;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size.square(_friendQrSize),
          painter: _FriendQrPatternPainter(
            data: data,
            logoClearArea: logoClearArea,
          ),
        ),
        _FriendQrLogoOverlay(size: logoSize),
      ],
    );
  }
}

class _FriendQrPatternPainter extends CustomPainter {
  _FriendQrPatternPainter({required this.data, required this.logoClearArea})
    : _qrImage = QrImage(
        QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.H),
      );

  static const Color _ink = Color(0xFF050A07);

  final String data;
  final Size logoClearArea;
  final QrImage _qrImage;

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = _qrImage.moduleCount;
    final contentSize = math.min(size.width, size.height);
    final cell = contentSize / moduleCount;
    final origin = Offset(
      (size.width - contentSize) / 2,
      (size.height - contentSize) / 2,
    );
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final logoClearRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: logoClearArea.width,
      height: logoClearArea.height,
    ).inflate(cell * 0.3);

    for (var row = 0; row < moduleCount; row += 1) {
      for (var col = 0; col < moduleCount; col += 1) {
        if (!_qrImage.isDark(row, col) ||
            _isFinderModule(row, col, moduleCount)) {
          continue;
        }

        final rect = Rect.fromLTWH(
          origin.dx + col * cell,
          origin.dy + row * cell,
          cell,
          cell,
        );
        if (rect.overlaps(logoClearRect)) {
          continue;
        }

        _drawDiamond(canvas, rect.center, cell * 0.43, paint);
      }
    }

    _drawFinder(canvas, origin, cell, paint);
    _drawFinder(
      canvas,
      origin + Offset((moduleCount - 7) * cell, 0),
      cell,
      paint,
    );
    _drawFinder(
      canvas,
      origin + Offset(0, (moduleCount - 7) * cell),
      cell,
      paint,
    );
  }

  static bool _isFinderModule(int row, int col, int moduleCount) {
    final inTop = row >= 0 && row < 7;
    final inLeft = col >= 0 && col < 7;
    final inRight = col >= moduleCount - 7 && col < moduleCount;
    final inBottom = row >= moduleCount - 7 && row < moduleCount;
    return (inTop && inLeft) || (inTop && inRight) || (inBottom && inLeft);
  }

  static void _drawDiamond(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void _drawFinder(
    Canvas canvas,
    Offset topLeft,
    double cell,
    Paint paint,
  ) {
    final outer = Rect.fromLTWH(topLeft.dx, topLeft.dy, cell * 7, cell * 7);
    final inner = outer.deflate(cell * 1.05);
    final core = outer.deflate(cell * 2.2);
    final cutoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawRRect(
      RRect.fromRectAndRadius(outer, Radius.circular(cell * 2.0)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, Radius.circular(cell * 1.25)),
      cutoutPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(core, Radius.circular(cell * 0.35)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FriendQrPatternPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.logoClearArea != logoClearArea;
  }
}

class _FriendQrLogoOverlay extends StatelessWidget {
  const _FriendQrLogoOverlay({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  _friendQrLogoAsset,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Image.asset(
              _friendQrLogoAsset,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ],
        ),
      ),
    );
  }
}
