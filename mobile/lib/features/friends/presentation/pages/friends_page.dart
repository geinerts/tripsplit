import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/perf/perf_monitor.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/ui/responsive.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/friends_section_page.dart';
import '../../domain/entities/friend_user.dart';
import '../../domain/entities/friends_snapshot.dart';
import '../controllers/friends_controller.dart';

part 'friends_page_actions_core.dart';
part 'friends_page_actions_search.dart';
part 'friends_page_actions_relationships.dart';
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
    this.commandController,
  });

  final FriendsController controller;
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
  bool _isSearching = false;
  bool _isLoadingMoreFriends = false;
  bool _isLoadingMorePendingSent = false;
  bool _isLoadingMorePendingReceived = false;
  String? _errorText;
  FriendsSnapshot? _snapshot;
  List<FriendUser> _searchResults = const <FriendUser>[];
  int _friendsTotalCount = 0;
  int _pendingSentTotalCount = 0;
  int _pendingReceivedTotalCount = 0;
  bool _friendsHasMore = false;
  String? _friendsNextCursor;
  int? _friendsNextOffset;
  bool _pendingSentHasMore = false;
  String? _pendingSentNextCursor;
  int? _pendingSentNextOffset;
  bool _pendingReceivedHasMore = false;
  String? _pendingReceivedNextCursor;
  int? _pendingReceivedNextOffset;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<int> _inviteLoading = <int>{};
  final Set<int> _respondLoading = <int>{};
  final Set<int> _cancelLoading = <int>{};
  final Set<int> _removeLoading = <int>{};
  Timer? _searchDebounce;
  int _handledRefreshRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _bindCommandController(widget.commandController);
    unawaited(_loadSnapshot(showLoader: true));
    _searchController.addListener(_onSearchChanged);
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
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
