import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/auth/account_data_session.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../workspace/domain/entities/workspace_user.dart';
import '../data/live_location_device.dart';
import '../domain/live_location.dart';
import 'live_location_controller.dart';

class LiveMapPage extends StatefulWidget {
  const LiveMapPage({
    super.key,
    required this.tripId,
    required this.tripName,
    required this.controller,
    this.users = const [],
    this.showTiles = true,
  });
  final int tripId;
  final String tripName;
  final LiveLocationController controller;
  final List<WorkspaceUser> users;
  final bool showTiles;
  @override
  State<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends State<LiveMapPage> with WidgetsBindingObserver {
  final _map = MapController();
  late final AccountDataLease _lease;
  Timer? _poll;
  LiveMapSnapshot? _snapshot;
  DateTime? _received;
  Object? _error;
  bool _loading = false,
      _ready = false,
      _fitted = false,
      _foreground = true,
      _closed = false;
  int? _selected;
  @override
  void initState() {
    super.initState();
    _lease = widget.controller.account.capture();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_changed);
    unawaited(_load());
    _poll = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_foreground) unawaited(_load());
    });
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) unawaited(_load());
  }

  DateTime get _serverNow =>
      (_snapshot?.serverTime ?? DateTime.now().toUtc()).add(
        _received == null
            ? Duration.zero
            : DateTime.now().difference(_received!),
      );
  List<LiveMember> get _members => _lease.isCurrent
      ? (_snapshot?.members ?? [])
            .where((m) => m.visibleAt(_serverNow))
            .toList()
      : [];
  Future<void> _load() async {
    if (_loading || !_lease.isCurrent || _closed) return;
    _loading = true;
    try {
      final data = await widget.controller.repository.load(widget.tripId);
      if (!mounted || !_lease.isCurrent) return;
      setState(() {
        _snapshot = data;
        _received = DateTime.now();
        _error = null;
      });
      if (_ready && !_fitted && _members.isNotEmpty) _fit();
    } catch (error) {
      if (!mounted) return;
      final closed =
          error is ApiException &&
          [401, 403, 404, 409].contains(error.statusCode);
      setState(() {
        _error = error;
        if (closed) {
          _snapshot = null;
          _closed = true;
        }
      });
      if (closed && widget.controller.sharing(widget.tripId) != null) {
        unawaited(widget.controller.stop(widget.tripId));
      }
    } finally {
      _loading = false;
    }
  }

  void _fit() {
    final members = _members;
    if (!_ready || members.isEmpty) return;
    _fitted = true;
    if (members.length == 1) {
      _map.move(members.first.point, 15);
    } else {
      _map.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(members.map((m) => m.point).toList()),
          padding: const EdgeInsets.all(64),
          maxZoom: 16,
        ),
      );
    }
  }

  Future<void> _share() async {
    var minutes = 60;
    final t = context.l10n;
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.liveShareTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(t.liveConsent),
                  const SizedBox(height: 12),
                  Text(
                    t.liveBackgroundNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in const {
                        15: '15 min',
                        60: '1 h',
                        240: '4 h',
                        480: '8 h',
                      }.entries)
                        ChoiceChip(
                          label: Text(item.value),
                          selected: minutes == item.key,
                          onSelected: (_) => setSheet(() => minutes = item.key),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('live-confirm'),
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.location_on_outlined),
                      label: Text(t.liveStart),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (accepted != true || !mounted || !_lease.isCurrent) return;
    try {
      await widget.controller.start(
        widget.tripId,
        minutes,
        title: 'Splyto · ${t.liveMapTitle}',
        text: t.liveNotification,
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is LiveLocationPermissionError
                ? t.livePermissionError
                : t.liveStartError,
          ),
        ),
      );
    }
  }

  Future<void> _stop() async {
    final stopped = await widget.controller.stop(widget.tripId);
    if (!mounted) return;
    if (stopped) {
      setState(() {
        _snapshot = null;
        _selected = null;
      });
      await _load();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.liveStopPending)));
    }
  }

  Widget _avatar(LiveMember member, {double radius = 22}) {
    final users = widget.users.where((u) => u.id == member.userId);
    final url = users.isEmpty
        ? null
        : users.first.avatarThumbUrl ?? users.first.avatarUrl;
    final fallback = Center(
      child: Text(
        member.name.isEmpty ? '?' : member.name.characters.first.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * .8),
      ),
    );
    return CircleAvatar(
      radius: radius,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: url == null
              ? fallback
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stack) => fallback,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n,
        colors = Theme.of(context).colorScheme,
        controller = widget.controller;
    final share = controller.sharing(widget.tripId), members = _members;
    final selected = members.where((m) => m.userId == _selected).firstOrNull;
    final expires = share?.expiresAt ?? _snapshot?.ownExpiresAt;
    final active =
        expires != null &&
        (share != null
            ? expires.isAfter(DateTime.now())
            : expires.isAfter(_serverNow));
    final stopping = controller.stopping(widget.tripId);
    return Scaffold(
      appBar: AppBar(title: Text(t.liveMapTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scrolling =
                constraints.maxHeight < 600 ||
                MediaQuery.textScalerOf(context).scale(16) > 23;
            Widget mapArea(Widget child) => scrolling
                ? SizedBox(
                    height: (constraints.maxHeight * .65).clamp(280.0, 600.0),
                    child: child,
                  )
                : Expanded(child: child);
            final content = Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tripName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${members.length} · ${t.liveSharing}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null || !_lease.isCurrent)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _closed || !_lease.isCurrent
                                ? t.liveUnavailable
                                : t.liveLoadError,
                          ),
                        ),
                        if (!_closed && _lease.isCurrent)
                          IconButton(
                            onPressed: () => _load(),
                            icon: const Icon(Icons.refresh),
                            tooltip: t.paymentDetailsRetry,
                          ),
                      ],
                    ),
                  ),
                mapArea(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _map,
                            options: MapOptions(
                              initialCenter: const LatLng(48, 9),
                              initialZoom: 3,
                              minZoom: 2,
                              maxZoom: 18,
                              interactionOptions: const InteractionOptions(
                                flags:
                                    InteractiveFlag.all &
                                    ~InteractiveFlag.rotate,
                              ),
                              onMapReady: () {
                                _ready = true;
                                if (_members.isNotEmpty) _fit();
                              },
                              onTap: (_, point) =>
                                  setState(() => _selected = null),
                            ),
                            children: [
                              if (widget.showTiles)
                                TileLayer(
                                  urlTemplate: const String.fromEnvironment(
                                    'LIVE_MAP_TILE_URL',
                                    defaultValue:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  ),
                                  userAgentPackageName: 'eu.splyto.app',
                                  maxNativeZoom: 19,
                                  tileProvider: NetworkTileProvider(
                                    headers: {
                                      'User-Agent':
                                          'Splyto/1.0 (+https://splyto.eu; info@splyto.eu)',
                                    },
                                  ),
                                ),
                              if (selected != null)
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: selected.point,
                                      radius: selected.accuracy.clamp(5, 2000),
                                      useRadiusInMeter: true,
                                      color: colors.primary.withValues(
                                        alpha: .12,
                                      ),
                                      borderColor: colors.primary.withValues(
                                        alpha: .4,
                                      ),
                                      borderStrokeWidth: 1,
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  for (final member in members)
                                    Marker(
                                      point: member.point,
                                      width: 56,
                                      height: 56,
                                      child: Semantics(
                                        label: member.name,
                                        button: true,
                                        child: GestureDetector(
                                          key: ValueKey(
                                            'live-member-${member.userId}',
                                          ),
                                          onTap: () => setState(
                                            () => _selected = member.userId,
                                          ),
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    _serverNow
                                                            .difference(
                                                              member.observedAt,
                                                            )
                                                            .inSeconds <
                                                        30
                                                    ? colors.primary
                                                    : colors.outline,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                              child: _avatar(member),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: IconButton.filledTonal(
                              onPressed: members.isEmpty ? null : _fit,
                              icon: const Icon(Icons.center_focus_strong),
                              tooltip: t.liveFit,
                            ),
                          ),
                          if (members.isEmpty)
                            Positioned(
                              left: 16,
                              right: 68,
                              top: 16,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: _loading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Text(t.liveEmpty),
                                ),
                              ),
                            ),
                          Positioned(
                            right: 4,
                            bottom: 0,
                            child: Material(
                              color: colors.surface.withValues(alpha: .92),
                              child: InkWell(
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    'https://www.openstreetmap.org/copyright',
                                  ),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    '© OpenStreetMap contributors',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (selected != null)
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 36,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      _avatar(selected),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selected.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                            Text(
                                              '${_serverNow.difference(selected.observedAt).inSeconds < 30 ? t.liveRecent : t.liveLastKnown} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(selected.observedAt.toLocal()))}',
                                            ),
                                            Text(
                                              '${t.liveAccuracy} ±${selected.accuracy.round()} m',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            setState(() => _selected = null),
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (active) ...[
                        Text(
                          stopping
                              ? t.liveStopPending
                              : '${t.liveUntil} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(expires.toLocal()))}',
                          textAlign: TextAlign.center,
                        ),
                        if (share == null)
                          Text(
                            t.liveOtherSession,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (controller.errors.containsKey(widget.tripId) &&
                            !stopping)
                          Text(
                            t.liveUpdatesPaused,
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          key: const ValueKey('live-stop'),
                          onPressed: _stop,
                          icon: const Icon(Icons.location_off_outlined),
                          label: Text(t.liveStop),
                        ),
                      ] else ...[
                        Text(
                          t.livePrivateUntilShared,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          key: const ValueKey('live-share'),
                          onPressed:
                              _closed ||
                                  !_lease.isCurrent ||
                                  controller.busy(widget.tripId)
                              ? null
                              : _share,
                          icon: controller.busy(widget.tripId)
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(t.liveShareTitle),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
            return scrolling ? SingleChildScrollView(child: content) : content;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_changed);
    _poll?.cancel();
    _map.dispose();
    super.dispose();
  }
}
