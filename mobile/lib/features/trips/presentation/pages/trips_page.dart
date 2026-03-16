import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/perf/perf_monitor.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/ui/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_user.dart';
import '../controllers/trips_controller.dart';

part 'trips_page_actions.dart';
part 'trips_page_dialogs.dart';
part 'trips_page_dialogs_edit.dart';
part 'trips_page_dialogs_helpers.dart';
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
    this.openCreateTripOnStart = false,
    this.showInlineHeader = true,
    this.showBottomNav = true,
    this.commandController,
    this.onTripOpened,
  });

  final TripsController controller;
  final AuthController authController;
  final bool openCreateTripOnStart;
  final bool showInlineHeader;
  final bool showBottomNav;
  final TripsPageCommandController? commandController;
  final TripsPageOpenTripCallback? onTripOpened;

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  static const int _maxTripImageBytes = 8 * 1024 * 1024;

  bool _isLoading = true;
  bool _isMutating = false;
  bool _showAllTrips = false;
  bool _openCreateAfterLoad = false;
  int _handledCreateTripRequestCount = 0;
  int _handledRefreshRequestCount = 0;
  String? _errorText;
  List<Trip> _trips = const <Trip>[];

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
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
    final responsive = context.responsive;
    final activeTrips = _trips
        .where((trip) => trip.isActive)
        .toList(growable: false);
    final archivedTrips = _trips
        .where((trip) => trip.isArchived)
        .toList(growable: false);
    final visibleTrips = _showAllTrips ? _trips : activeTrips;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Builder(
            builder: (context) {
              if (_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_errorText != null) {
                return _buildErrorState(context);
              }

              return RefreshIndicator(
                onRefresh: _loadTrips,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: responsive.pageMaxWidth,
                          minHeight: constraints.maxHeight,
                        ),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            responsive.pageHorizontalPadding,
                            12,
                            responsive.pageHorizontalPadding,
                            18,
                          ),
                          children: [
                            if (widget.showInlineHeader) ...[
                              _buildTopHeader(context),
                              const SizedBox(height: 12),
                            ],
                            _buildSummaryCard(
                              context,
                              allTrips: _trips,
                            ),
                            const SizedBox(height: 18),
                            _buildTripsHeader(
                              context,
                              currentCount: activeTrips.length,
                              archivedCount: archivedTrips.length,
                            ),
                            const SizedBox(height: 10),
                            if (visibleTrips.isEmpty)
                              _buildEmptyTripsState(context)
                            else
                              _buildTripsCollection(context, visibleTrips),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? _buildBottomNav(context)
          : null,
    );
  }
}
