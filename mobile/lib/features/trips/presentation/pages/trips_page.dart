import '../widgets/join_trip_invite_page.dart';
import '../widgets/trip_form_page.dart';
import 'dart:async';
import 'dart:ui' show ImageByteFormat, instantiateImageCodec;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/splyto_illustration.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/currency/app_currency.dart';
import '../../../../core/media/app_image_cropper.dart';
import '../../../../core/perf/perf_monitor.dart';
import '../../../../core/ui/app_bottom_nav_bar.dart';
import '../../../../core/ui/app_components.dart';
import '../../../../core/ui/app_formatters.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_sheet.dart';
import '../../../../core/ui/app_skeleton.dart';
import '../../../../core/ui/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_user.dart';
import '../controllers/trips_controller.dart';

part 'trips_page_actions.dart';
part 'trips_page_dialogs.dart';
part 'trips_page_dialogs_edit.dart';
part 'trips_page_dialogs_helpers.dart';
part 'trips_page_invite.dart';
part 'trips_page_widgets.dart';
part 'trips_page_widgets_cards.dart';
part 'trips_page_widgets_navigation.dart';
part 'trips_page_support.dart';

class TripsPageCommandController extends ChangeNotifier {
  int _openCreateTripRequestCount = 0;
  int _refreshRequestCount = 0;

  int get openCreateTripRequestCount => _openCreateTripRequestCount;
  int get refreshRequestCount => _refreshRequestCount;

  void requestOpenCreateTrip() {
    _openCreateTripRequestCount += 1;
    notifyListeners();
  }

  void requestRefresh() {
    _refreshRequestCount += 1;
    notifyListeners();
  }
}

typedef TripsPageOpenTripCallback =
    void Function(Trip trip, {bool openAddExpense});

class TripsPage extends StatefulWidget {
  const TripsPage({
    super.key,
    required this.controller,
    required this.authController,
    required this.friendsController,
    this.openCreateTripOnStart = false,
    this.showInlineHeader = true,
    this.showBottomNav = true,
    this.commandController,
    this.onTripOpened,
    this.onServerTripsState,
    this.onInteractionStateChanged,
  });

  final TripsController controller;
  final AuthController authController;
  final FriendsController friendsController;
  final bool openCreateTripOnStart;
  final bool showInlineHeader;
  final bool showBottomNav;
  final TripsPageCommandController? commandController;
  final TripsPageOpenTripCallback? onTripOpened;

  /// null: loading/failed; true: successful server response with zero trips.
  final ValueChanged<bool?>? onServerTripsState;
  final ValueChanged<bool>? onInteractionStateChanged;

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _hasLoaded = false;
  bool _mayUseCache = true;
  bool _isOffline = false;
  bool _isMutating = false;
  bool _showArchived = false;
  bool _hasChosenFilter = false;
  int _loadGeneration = 0;
  bool _openCreateAfterLoad = false;
  bool _isCreateTripDialogOpen = false;
  bool _isJoiningTrip = false;
  int _handledCreateTripRequestCount = 0;
  int _handledRefreshRequestCount = 0;
  String? _errorText;
  String? _refreshError;
  List<Trip> _trips = const <Trip>[];

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
    _notifyInteractionState();
  }

  void _notifyInteractionState() {
    if (!mounted) return;
    widget.onInteractionStateChanged?.call(
      _isMutating || _isCreateTripDialogOpen || _isJoiningTrip,
    );
  }

  @override
  void initState() {
    super.initState();
    _openCreateAfterLoad = widget.openCreateTripOnStart;
    _bindCommandController(widget.commandController);
    _loadTrips();
  }

  @override
  void didUpdateWidget(covariant TripsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commandController != widget.commandController) {
      _unbindCommandController(oldWidget.commandController);
      _bindCommandController(widget.commandController);
    }
  }

  @override
  void dispose() {
    _unbindCommandController(widget.commandController);
    super.dispose();
  }

  void _bindCommandController(TripsPageCommandController? controller) {
    if (controller == null) {
      return;
    }
    _handledCreateTripRequestCount = controller.openCreateTripRequestCount;
    _handledRefreshRequestCount = controller.refreshRequestCount;
    controller.addListener(_onCommandControllerChanged);
  }

  void _unbindCommandController(TripsPageCommandController? controller) {
    controller?.removeListener(_onCommandControllerChanged);
  }

  void _onCommandControllerChanged() {
    final controller = widget.commandController;
    if (controller == null) {
      return;
    }
    final createTripRequestCount = controller.openCreateTripRequestCount;
    if (createTripRequestCount != _handledCreateTripRequestCount) {
      _handledCreateTripRequestCount = createTripRequestCount;
      if (_isLoading) {
        _openCreateAfterLoad = true;
      } else {
        unawaited(_openCreateTripDialog());
      }
    }

    final refreshRequestCount = controller.refreshRequestCount;
    if (refreshRequestCount != _handledRefreshRequestCount) {
      _handledRefreshRequestCount = refreshRequestCount;
      unawaited(_loadTrips());
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleTrips = _trips
        .where((trip) => _showArchived ? trip.isArchived : !trip.isArchived)
        .toList(growable: false);
    return AppPageScaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.responsive.pageMaxWidth,
            ),
            child: RefreshIndicator(
              onRefresh: _loadTrips,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (widget.showInlineHeader)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDesign.pagePadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _buildTopHeader(context),
                      ),
                    ),
                  if (_isLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildLoadingState(context),
                    )
                  else if (_errorText != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(context),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 2,
                            child: _isRefreshing
                                ? const LinearProgressIndicator()
                                : null,
                          ),
                          if (_refreshError != null)
                            _buildRefreshNotice(context),
                        ],
                      ),
                    ),
                    if (_trips.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyTripsState(context),
                      )
                    else ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryCard(context, allTrips: _trips),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              _buildTripsSectionHeader(context),
                              _buildTripFilters(context),
                            ],
                          ),
                        ),
                      ),
                      if (visibleTrips.isEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.all(32),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_showArchived) ...[
                                  const SplytoIllustration(
                                    'assets/branding/splyto_empty_trips.svg',
                                    width: 180,
                                    height: 150,
                                    excludeFromSemantics: true,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                Text(
                                  _showArchived
                                      ? context.l10n.homeNoArchivedTrips
                                      : context.l10n.homeNoActiveTrips,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList.builder(
                            itemCount: visibleTrips.length,
                            itemBuilder: (context, index) =>
                                _buildTripCard(context, visibleTrips[index]),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? _buildBottomNav(context)
          : null,
    );
  }
}
