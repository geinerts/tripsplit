import 'dart:async';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/locale/app_locale_controller.dart';
import '../../../../app/locale/app_locale_scope.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../app/theme/theme_mode_scope.dart';
import '../../../../core/currency/app_currency.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/media/app_image_cropper.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/ui/app_bottom_nav_bar.dart';
import '../../../../core/ui/app_components.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_sheet.dart';
import '../../../../core/ui/responsive.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/notification_preferences.dart';
import '../controllers/auth_controller.dart';

part 'profile_page_actions.dart';
part 'profile_page_edit.dart';
part 'profile_page_in_app_notifications.dart';
part 'profile_page_navigation.dart';
part 'profile_page_push_notifications.dart';
part 'profile_page_settings.dart';
part 'profile_page_widgets.dart';

class ProfilePageCommandController extends ChangeNotifier {
  int _refreshRequestCount = 0;
  int _closeEditModeRequestCount = 0;

  int get refreshRequestCount => _refreshRequestCount;
  int get closeEditModeRequestCount => _closeEditModeRequestCount;

  void requestRefresh() {
    _refreshRequestCount += 1;
    notifyListeners();
  }

  void requestCloseEditMode() {
    _closeEditModeRequestCount += 1;
    notifyListeners();
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.controller,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.onProfileChanged,
    this.onEditModeChanged,
    this.commandController,
  });

  final AuthController controller;
  final bool showAppBar;
  final bool showBottomNav;
  final VoidCallback? onProfileChanged;
  final ValueChanged<bool>? onEditModeChanged;
  final ProfilePageCommandController? commandController;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const int _maxAvatarBytes = 5 * 1024 * 1024;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSendingFeedback = false;
  bool _isEditMode = false;
  bool _isChangePasswordPage = false;
  String? _errorText;
  String? _editErrorText;
  AuthUser? _user;
  Uint8List? _avatarBytes;
  String _initialFullName = '';
  String? _initialEmail;
  String _initialBankIban = '';
  String _initialBankBic = '';
  String _initialBankCountryCode = '';
  String _initialBankAccountNumber = '';
  String _initialBankSortCode = '';
  String _initialRevolutHandle = '';
  String _initialRevolutMeLink = '';
  String _initialPaypalMeLink = '';
  String _initialWisePayLink = '';
  String _initialPreferredCurrencyCode = AppCurrencyCatalog.defaultCode;
  String _draftFullName = '';
  String _draftEmail = '';
  String _draftBankIban = '';
  String _draftBankBic = '';
  String _draftBankCountryCode = '';
  String _draftBankAccountNumber = '';
  String _draftBankSortCode = '';
  String _draftRevolutHandle = '';
  String _draftRevolutMeLink = '';
  String _draftPaypalMeLink = '';
  String _draftWisePayLink = '';
  String _draftPreferredCurrencyCode = AppCurrencyCatalog.defaultCode;
  String _draftPassword = '';
  String _draftRepeatPassword = '';
  String _deactivateDraftPassword = '';
  bool _isDeactivateAccountPage = false;
  bool _inAppExpenseUpdatesEnabled = true;
  bool _inAppFriendInvitesEnabled = true;
  bool _inAppTripUpdatesEnabled = true;
  bool _inAppSettlementUpdatesEnabled = true;
  bool get _inAppNotificationsEnabled =>
      _inAppExpenseUpdatesEnabled ||
      _inAppFriendInvitesEnabled ||
      _inAppTripUpdatesEnabled ||
      _inAppSettlementUpdatesEnabled;
  bool _pushExpenseUpdatesEnabled = true;
  bool _pushFriendInvitesEnabled = true;
  bool _pushTripUpdatesEnabled = true;
  bool _pushSettlementUpdatesEnabled = true;
  bool get _pushNotificationsEnabled =>
      _pushExpenseUpdatesEnabled ||
      _pushFriendInvitesEnabled ||
      _pushTripUpdatesEnabled ||
      _pushSettlementUpdatesEnabled;
  _ProfileEditField? _activeEditField;
  int _editSession = 0;
  int _handledRefreshRequestCount = 0;
  int _handledCloseEditModeRequestCount = 0;
  String _appVersionLabel = '—';

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
  }

  @override
  void initState() {
    super.initState();
    _bindCommandController(widget.commandController);
    widget.onEditModeChanged?.call(false);
    unawaited(_loadAppVersion());
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commandController != widget.commandController) {
      _unbindCommandController(oldWidget.commandController);
      _bindCommandController(widget.commandController);
    }
    if (oldWidget.onEditModeChanged != widget.onEditModeChanged) {
      widget.onEditModeChanged?.call(_isEditMode);
    }
  }

  @override
  void dispose() {
    widget.onEditModeChanged?.call(false);
    _unbindCommandController(widget.commandController);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileScaffold(context);
  }
}

enum _ProfileEditField { fullName, email, preferredCurrency }
