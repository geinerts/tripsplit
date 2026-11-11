import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/responsive.dart';
import '../../../../core/ui/user_profile_page.dart';
import '../../domain/entities/friend_user.dart';
import '../controllers/friends_controller.dart';
import '../widgets/friend_avatar.dart';

part 'friend_search_page_widgets.dart';

class FriendSearchPage extends StatefulWidget {
  const FriendSearchPage({
    super.key,
    required this.controller,
    required this.accountIsCurrent,
    required this.excludeIds,
    required this.onInvited,
    this.friends,
    this.onOpenFriend,
  });

  final FriendsController controller;
  final bool Function() accountIsCurrent;
  final Set<int> Function() excludeIds;
  final Future<void> Function() onInvited;

  /// Friends already loaded on the Friends page. The server search leaves
  /// them out (their IDs are excluded), so matches are found here and shown
  /// above everyone else with a Friend badge.
  final List<FriendUser> Function()? friends;
  final Future<void> Function(FriendUser friend)? onOpenFriend;

  @override
  State<FriendSearchPage> createState() => _FriendSearchPageState();
}

class _FriendSearchPageState extends State<FriendSearchPage> {
  static const _pageSize = 10;
  final _textController = TextEditingController();
  final _sending = <int>{};
  final _invited = <int>{};
  final _scrollController = ScrollController();
  Timer? _debounce;
  int _generation = 0;
  String _query = '';
  List<FriendUser> _results = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _denied = false;
  String? _error;

  bool get _active => mounted && widget.accountIsCurrent();

  List<FriendUser> get _friendMatches {
    if (_denied || _query.length < 2) return const [];
    final query = foldForSearch(_query);
    final seen = <int>{};
    return [
      for (final friend in widget.friends?.call() ?? const <FriendUser>[])
        if ((foldForSearch(friend.preferredName).contains(query) ||
                foldForSearch(friend.nickname).contains(query)) &&
            seen.add(friend.id))
          friend,
    ];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _changeQuery(String value) {
    _debounce?.cancel();
    _generation++;
    setState(() {
      _query = value.trim();
      _results = [];
      _hasMore = false;
      _error = null;
      _loadingMore = false;
      _loading = _query.length >= 2 && !_denied;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    if (!_loading) return;
    _debounce = Timer(const Duration(milliseconds: 280), () => _search());
  }

  Future<void> _search({bool more = false}) async {
    if (!_active || _denied || _query.length < 2 || _loadingMore) return;
    final generation = ++_generation;
    final excluded = {
      ...widget.excludeIds(),
      ..._invited,
      if (more) ..._results.map((user) => user.id),
    };
    setState(() {
      _loading = !more;
      _loadingMore = more;
      _error = null;
    });
    try {
      // One extra result tells us whether another batch exists. The existing
      // API excludes previously displayed IDs, so no offset contract is needed.
      final users = await widget.controller.searchUsers(
        query: _query,
        limit: _pageSize + 1,
        excludeIds: excluded.toList(growable: false),
      );
      if (!_active || generation != _generation) return;
      final seen = {...excluded};
      final unique = users.where((user) => seen.add(user.id)).toList();
      setState(() {
        _results = [
          if (more) ..._results,
          ...unique.take(_pageSize),
        ].where((user) => !_invited.contains(user.id)).toList();
        _hasMore = unique.length > _pageSize;
      });
    } catch (error) {
      if (!_active || generation != _generation) return;
      setState(() {
        _error = error is ApiException
            ? error.message
            : context.l10n.friendsSearchFailedTryAgain;
        if (error is ApiException &&
            ([401, 403, 404].contains(error.statusCode) ||
                error.code == 'account_changed')) {
          _denied = true;
          _results = [];
          _hasMore = false;
        }
      });
    } finally {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = _loadingMore = false;
          if (!widget.accountIsCurrent()) {
            _results = [];
            _hasMore = false;
            _denied = true;
          }
        });
      }
    }
  }

  Future<void> _sendInvite(FriendUser user) async {
    if (!_active ||
        _denied ||
        _sending.contains(user.id) ||
        _invited.contains(user.id)) {
      return;
    }
    setState(() => _sending.add(user.id));
    try {
      await widget.controller.sendInvite(userId: user.id);
      if (!mounted || !_active) return;
      setState(() {
        _invited.add(user.id);
        _results.removeWhere((candidate) => candidate.id == user.id);
      });
      _showSnack(context.l10n.friendsInviteSentTo(user.preferredName));
      await widget.onInvited();
    } catch (error) {
      if (!mounted || !_active) return;
      _showSnack(
        error is ApiException
            ? error.message
            : context.l10n.friendsFailedToSendInvite,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _sending.remove(user.id));
    }
  }

  Future<void> _openFriend(
    Future<void> Function(FriendUser friend) open,
    FriendUser friend,
  ) async {
    await open(friend);
    // The friend may have been removed in the profile sheet.
    if (mounted) setState(() {});
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context).colorScheme.errorContainer
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => _buildSearchPage(context);
}

/// Lower-cases [value] and drops common Latin diacritics, so "berz" finds
/// "Bērziņa" and "sirs" finds "Širšs".
String foldForSearch(String value) {
  const from =
      'āáàâäãåąăčćçďđēéèêëėęěģğīíìîïįķĺļľłņńñňōóòôöõőøŗřšśşșťţțūúùûüůűųýÿžźż';
  const to =
      'aaaaaaaaacccddeeeeeeeeggiiiiiikllllnnnnoooooooorrsssstttuuuuuuuuyyzzz';
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index < 0 ? char : to[index]);
  }
  return buffer.toString();
}
