import 'dart:typed_data';
import '../../../travel_map/presentation/travel_city_picker.dart';

import 'package:flutter/material.dart';
import '../../../../core/ui/splyto_illustration.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/currency/app_currency.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/media/app_image_cropper.dart';
import '../../../../core/ui/app_components.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_settings_widgets.dart';
import '../../../../core/ui/app_currency_picker.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_user.dart';

typedef TripImageDraft = ({Uint8List bytes, String fileName});

class TripFormDraft {
  const TripFormDraft({
    required this.name,
    required this.currencyCode,
    required this.tripMode,
    required this.memberIds,
    this.dateFrom,
    this.dateTo,
    this.image,
    this.removeImage = false,
    this.budgetCents,
    this.destinations = const [],
  });
  final String name, currencyCode, tripMode;
  final List<int> memberIds;
  final String? dateFrom, dateTo;
  final TripImageDraft? image;
  final bool removeImage;
  final int? budgetCents;
  final List<Map<String, dynamic>> destinations;
}

enum _ImageChoice { camera, library, remove }

/// Shared create/edit presentation; callers retain authorization and persistence.
class TripFormPage extends StatefulWidget {
  const TripFormPage({
    super.key,
    this.trip,
    this.loadFriends,
    this.budgetLoaded = false,
    this.budgetCents,
    required this.pickImage,
  });
  final Trip? trip;
  final bool budgetLoaded;
  final int? budgetCents;
  final Future<List<TripUser>> Function()? loadFriends;
  final Future<TripImageDraft?> Function(ImageSource source) pickImage;
  @override
  State<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
  late final _name = TextEditingController(
    text: widget.trip?.name.trim() ?? '',
  );
  String _mode = 'group', _currency = AppCurrencyCatalog.defaultCode;
  DateTime? _from, _to;
  TripImageDraft? _image;
  bool _removeImage = false, _picking = false, _loadingFriends = false;
  bool _submitted = false;
  final _budget = TextEditingController();
  bool _budgetEnabled = false, _budgetInvalid = false;
  bool _friendsFailed = false, _nameInvalid = false, _datesInvalid = false;
  List<TripUser> _friends = [];
  final _selected = <int>{};
  late final List<Map<String, dynamic>> _destinations = [
    ...?widget.trip?.destinations,
  ];
  bool get _editing => widget.trip != null;
  String get _existingImage => _removeImage
      ? ''
      : (widget.trip?.imageUrl ?? widget.trip?.imageThumbUrl ?? '').trim();

  @override
  void initState() {
    super.initState();
    _currency = widget.trip?.currencyCode ?? _currency;
    _mode = widget.trip?.tripMode ?? _mode;
    final budget = widget.budgetLoaded
        ? widget.budgetCents
        : widget.trip?.budgetCents;
    _budgetEnabled = budget != null;
    if (budget != null) {
      _budget.text =
          '${budget ~/ 100}.${(budget % 100).toString().padLeft(2, '0')}';
    }
    if (!_editing) _loadFriends();
  }

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    if (_loadingFriends || widget.loadFriends == null) return;
    setState(() {
      _loadingFriends = true;
      _friendsFailed = false;
    });
    try {
      final friends = await widget.loadFriends!();
      if (!mounted) return;
      setState(() => _friends = friends);
    } catch (_) {
      if (mounted) setState(() => _friendsFailed = true);
    } finally {
      if (mounted) setState(() => _loadingFriends = false);
    }
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final t = context.l10n;
      final choice = await showAppPlatformActionSheet<_ImageChoice>(
        context: context,
        cancelLabel: t.cancelAction,
        actions: [
          AppPlatformAction(
            value: _ImageChoice.camera,
            icon: Icons.photo_camera_outlined,
            title: t.takePhotoAction,
          ),
          AppPlatformAction(
            value: _ImageChoice.library,
            icon: Icons.photo_library_outlined,
            title: t.chooseFromLibraryAction,
          ),
          if (_image != null || _existingImage.isNotEmpty)
            AppPlatformAction(
              value: _ImageChoice.remove,
              icon: Icons.delete_outline,
              title: t.profileRemoveImage,
              destructive: true,
            ),
        ],
      );
      if (!mounted || choice == null) return;
      if (choice == _ImageChoice.remove) {
        setState(() {
          _image = null;
          _removeImage = true;
        });
        return;
      }
      final image = await widget.pickImage(
        choice == _ImageChoice.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );
      if (!mounted || image == null) return;
      setState(() {
        _image = image;
        _removeImage = false;
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _pickDate(bool start) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final first = start ? DateTime(2020) : (_from ?? DateTime(2020));
    var initial = start ? (_from ?? _to ?? today) : (_to ?? _from ?? today);
    if (initial.isBefore(first)) initial = first;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100, 12, 31),
    );
    if (!mounted || date == null) return;
    setState(() {
      if (start) {
        _from = date;
        if (_to != null && _to!.isBefore(date)) _to = date;
      } else {
        _to = date;
      }
      _datesInvalid = false;
    });
  }

  Future<void> _pickCurrency() async {
    final picked = await showAppCurrencyPicker(
      context: context,
      selectedCode: _currency,
      title: context.l10n.tripsMainCurrency,
      searchKey: const ValueKey('trip-currency-search'),
    );
    if (mounted && picked != null) setState(() => _currency = picked);
  }

  void _submit() {
    if (_picking || _submitted) return;
    final name = _name.text.trim();
    final rawBudget = _budget.text.trim().replaceAll(',', '.');
    int? budgetCents;
    if (_budgetEnabled &&
        RegExp(r'^\d{1,9}(?:\.\d{1,2})?$').hasMatch(rawBudget)) {
      final parts = rawBudget.split('.');
      budgetCents =
          int.parse(parts[0]) * 100 +
          int.parse(parts.length == 1 ? '0' : parts[1].padRight(2, '0'));
    }
    setState(() {
      _nameInvalid = name.length < 2 || name.length > 120;
      _budgetInvalid =
          _budgetEnabled &&
          (budgetCents == null ||
              budgetCents <= 0 ||
              budgetCents > 99999999999);
      _datesInvalid =
          !_editing && (_from == null || _to == null || _to!.isBefore(_from!));
    });
    if (_nameInvalid || _datesInvalid || _budgetInvalid) return;
    setState(() => _submitted = true);
    String? iso(DateTime? value) => value == null
        ? null
        : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    Navigator.pop(
      context,
      TripFormDraft(
        name: name,
        currencyCode: _currency,
        tripMode: _mode,
        memberIds: _mode == 'solo' ? [] : (_selected.toList()..sort()),
        dateFrom: iso(_from),
        dateTo: iso(_to),
        image: _image,
        removeImage: _removeImage,
        budgetCents: _budgetEnabled ? budgetCents : null,
        destinations: List.of(_destinations),
      ),
    );
  }

  Widget _cover() {
    final colors = Theme.of(context).colorScheme;
    Widget placeholder() => SplytoIllustration(
      'assets/branding/splyto_trip_cover_large.svg',
      fit: BoxFit.cover,
    );
    final preview = _image != null
        ? Image.memory(
            _image!.bytes,
            key: const ValueKey('trip-cover-photo'),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => placeholder(),
          )
        : _existingImage.isNotEmpty
        ? Image.network(
            _existingImage,
            key: const ValueKey('trip-cover-photo'),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => placeholder(),
          )
        : placeholder();
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: constraints.maxWidth >= 600 ? 360 : constraints.maxWidth,
          child: Semantics(
            button: true,
            label: context.l10n.tripCoverPhoto,
            child: Material(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('trip-cover-picker'),
                onTap: _picking ? null : _pickImage,
                child: AspectRatio(
                  aspectRatio: AppImageCropper.tripAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ExcludeSemantics(child: preview),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: _picking
                                ? const SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.photo_camera_outlined,
                                    size: 24,
                                  ),
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    String dateLabel(DateTime? date) => date == null
        ? t.tripsSelectDate
        : MaterialLocalizations.of(context).formatMediumDate(date);
    return AppFormScaffold(
      key: ValueKey(_editing ? 'edit-trip-form' : 'create-trip-form'),
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _editing ? t.editTripAction : t.createNewTripTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_editing) ...[
                  Row(
                    children: [
                      for (final mode in ['group', 'solo'])
                        Expanded(
                          child: Semantics(
                            selected: _mode == mode,
                            child: InkWell(
                              key: ValueKey('trip-mode-$mode'),
                              onTap: () => setState(() {
                                _mode = mode;
                                if (mode == 'solo') _selected.clear();
                              }),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 48,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: _mode == mode ? 2 : 1,
                                      color: _mode == mode
                                          ? colors.primary
                                          : colors.outlineVariant,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  mode == 'group'
                                      ? t.tripModeGroup
                                      : t.tripModeSolo,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _mode == mode
                                        ? colors.primary
                                        : colors.onSurfaceVariant,
                                    fontWeight: _mode == mode
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use available safe width, not a device name. Keep the same tree
          // when folding so text fields retain focus and selection.
          final wide = constraints.maxWidth >= 680;
          final contentWidth = constraints.maxWidth - 40;
          final coverWidth = wide ? (contentWidth - 28) * .4 : contentWidth;
          final fieldsWidth = wide
              ? contentWidth - coverWidth - 28
              : contentWidth;
          return Column(
            mainAxisSize: wide ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Flexible(
                fit: wide ? FlexFit.loose : FlexFit.tight,
                child: SingleChildScrollView(
                  key: const ValueKey('trip-form-scroll'),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Flex(
                    direction: wide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: coverWidth, child: _cover()),
                      SizedBox(width: wide ? 28 : 0, height: wide ? 0 : 16),
                      SizedBox(
                        width: fieldsWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              key: const ValueKey('trip-form-name'),
                              controller: _name,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: t.tripNameLabel,
                                filled: false,
                                hintText: t.tripNameHint,
                                errorMaxLines: 4,
                                errorText: _nameInvalid
                                    ? t.tripNameLengthValidation
                                    : null,
                              ),
                              onChanged: (_) {
                                if (_nameInvalid) {
                                  setState(() => _nameInvalid = false);
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t.travelTripDestinations,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            for (final place in _destinations)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.place_outlined),
                                title: Text(place['city'] as String),
                                subtitle: Text(place['country'] as String),
                                trailing: IconButton(
                                  tooltip: t.travelRemoveDestination,
                                  icon: const Icon(Icons.close),
                                  onPressed: () => setState(
                                    () => _destinations.remove(place),
                                  ),
                                ),
                              ),
                            TextButton.icon(
                              key: const ValueKey('trip-add-destination'),
                              icon: const Icon(Icons.add_location_alt_outlined),
                              label: Text(t.travelAddDestination),
                              onPressed: _destinations.length >= 20
                                  ? null
                                  : () async {
                                      final place = await pickTravelCity(
                                        context,
                                      );
                                      if (!mounted || place == null) return;
                                      if (_destinations.any(
                                        (d) =>
                                            d['city'] == place.city &&
                                            d['region'] == place.region &&
                                            d['country_code'] ==
                                                place.countryCode,
                                      )) {
                                        return;
                                      }
                                      setState(
                                        () => _destinations.add(place.toJson()),
                                      );
                                    },
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile.adaptive(
                              key: const ValueKey('trip-budget-toggle'),
                              contentPadding: EdgeInsets.zero,
                              title: Text(t.tripBudgetEnable),
                              subtitle: Text(
                                _mode == 'solo'
                                    ? t.tripBudgetSoloHint
                                    : t.tripBudgetGroupHint,
                              ),
                              value: _budgetEnabled,
                              onChanged: (value) => setState(() {
                                _budgetEnabled = value;
                                _budgetInvalid = false;
                              }),
                            ),
                            if (_budgetEnabled) ...[
                              TextField(
                                key: const ValueKey('trip-budget-amount'),
                                controller: _budget,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: t.tripBudgetAmount,
                                  suffixText: _currency,
                                  errorMaxLines: 3,
                                  errorText: _budgetInvalid
                                      ? t.tripBudgetInvalid
                                      : null,
                                ),
                                onChanged: (_) {
                                  if (_budgetInvalid) {
                                    setState(() => _budgetInvalid = false);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (!_editing) ...[
                              AppSettingsRow(
                                key: const ValueKey('trip-date-from'),
                                title: t.tripsFrom,
                                value: dateLabel(_from),
                                icon: Icons.calendar_today_outlined,
                                onTap: () => _pickDate(true),
                              ),
                              const Divider(height: 1),
                              AppSettingsRow(
                                key: const ValueKey('trip-date-to'),
                                title: t.tripsTo,
                                value: dateLabel(_to),
                                icon: Icons.event_outlined,
                                onTap: () => _pickDate(false),
                              ),
                              const Divider(height: 1),
                              AppSettingsRow(
                                key: const ValueKey('trip-currency'),
                                title: t.tripsMainCurrency,
                                value: _currency,
                                icon: Icons.payments_outlined,
                                onTap: _pickCurrency,
                              ),
                              const Divider(height: 1),
                              if (_mode == 'group') ...[
                                const SizedBox(height: 20),
                                Text(
                                  t.selectedPeopleLabel,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                if (_loadingFriends)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: LinearProgressIndicator(),
                                  ),
                                if (_friendsFailed) ...[
                                  Text(
                                    t.workspaceFailedToLoadFriends,
                                    style: TextStyle(color: colors.error),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: _loadFriends,
                                      icon: const Icon(Icons.refresh),
                                      label: Text(t.retryAction),
                                    ),
                                  ),
                                ] else if (!_loadingFriends && _friends.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      t.tripInviteLaterHint,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                for (final friend in _friends) ...[
                                  CheckboxListTile(
                                    key: ValueKey('trip-friend-${friend.id}'),
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: _selected.contains(friend.id),
                                    title: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              colors.primaryContainer,
                                          foregroundColor:
                                              colors.onPrimaryContainer,
                                          child: ClipOval(
                                            child:
                                                (friend.avatarThumbUrl ??
                                                        friend.avatarUrl ??
                                                        '')
                                                    .isEmpty
                                                ? Text(
                                                    friend.nickname
                                                            .trim()
                                                            .isEmpty
                                                        ? '?'
                                                        : friend.nickname
                                                              .trim()
                                                              .characters
                                                              .first
                                                              .toUpperCase(),
                                                  )
                                                : Image.network(
                                                    friend.avatarThumbUrl ??
                                                        friend.avatarUrl!,
                                                    width: 36,
                                                    height: 36,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) =>
                                                        Text(
                                                          friend.nickname
                                                                  .trim()
                                                                  .isEmpty
                                                              ? '?'
                                                              : friend.nickname
                                                                    .trim()
                                                                    .characters
                                                                    .first
                                                                    .toUpperCase(),
                                                        ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(friend.nickname)),
                                      ],
                                    ),
                                    onChanged: (value) => setState(() {
                                      if (value == true) {
                                        _selected.add(friend.id);
                                      } else {
                                        _selected.remove(friend.id);
                                      }
                                    }),
                                  ),
                                  const Divider(height: 1),
                                ],
                              ],
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: fieldsWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_datesInvalid)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              t.tripsPleaseSelectTripPeriodFromAndToDates,
                              style: TextStyle(color: colors.error),
                            ),
                          ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const ValueKey('trip-form-submit'),
                              onPressed: _picking || _submitted
                                  ? null
                                  : _submit,
                              child: Text(
                                _editing ? t.saveAction : t.createAction,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
