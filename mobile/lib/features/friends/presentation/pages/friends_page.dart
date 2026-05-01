import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_design.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/perf/perf_monitor.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/ui/app_components.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_sheet.dart';
import '../../../../core/ui/responsive.dart';
import '../../../../core/ui/user_profile_payment_section.dart';
import '../../../../core/ui/user_profile_page.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/friends_section_page.dart';
import '../../domain/entities/friend_user.dart';
import '../../domain/entities/friends_snapshot.dart';
import '../../../workspace/domain/entities/workspace_shared_trip.dart';
import '../../../workspace/presentation/controllers/workspace_controller.dart';
import '../controllers/friends_controller.dart';

part 'friends_page_actions_core.dart';
part 'friends_page_actions_search.dart';
part 'friends_page_actions_relationships.dart';
part 'friends_page_actions_qr.dart';
part 'friends_page_profile.dart';
part 'friends_page_widgets.dart';
part 'friends_page_components.dart';

class FriendsPageCommandController extends ChangeNotifier {
  int _refreshRequestCount = 0;

  int get refreshRequestCount => _refreshRequestCount;

  void requestRefresh() {
    _refreshRequestCount += 1;
    notifyListeners();
  }
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
    required this.controller,
    required this.authController,
    required this.workspaceController,
    this.commandController,
  });

  final FriendsController controller;
  final AuthController authController;
  final WorkspaceController workspaceController;
  final FriendsPageCommandController? commandController;

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  static const int _pageLimit = 25;
  static const String _sectionFriends = 'friends';
  static const String _sectionPendingSent = 'pending_sent';
  static const String _sectionPendingReceived = 'pending_received';

  bool _isLoading = true;
  bool _isLoadingMoreFriends = false;
  bool _isLoadingMorePendingReceived = false;
  String? _errorText;
  FriendsSnapshot? _snapshot;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _friendSearchQuery = '';
  Timer? _friendSearchDebounce;
  bool _isSearchingUsers = false;
  String? _friendSearchError;
  List<FriendUser> _friendSearchResults = const <FriendUser>[];
  final Set<int> _inlineInviteLoading = <int>{};
  int _friendsTotalCount = 0;
  int _pendingReceivedTotalCount = 0;
  bool _friendsHasMore = false;
  String? _friendsNextCursor;
  int? _friendsNextOffset;
  bool _pendingReceivedHasMore = false;
  String? _pendingReceivedNextCursor;
  int? _pendingReceivedNextOffset;
  final ScrollController _scrollController = ScrollController();
  final Set<int> _respondLoading = <int>{};
  int _handledRefreshRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _bindCommandController(widget.commandController);
    unawaited(_loadSnapshot(showLoader: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant FriendsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commandController != widget.commandController) {
      _unbindCommandController(oldWidget.commandController);
      _bindCommandController(widget.commandController);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _friendSearchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _unbindCommandController(widget.commandController);
    super.dispose();
  }

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
  }

  @override
  Widget build(BuildContext context) {
    return _buildFriendsScaffold(context);
  }
}
