import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../trips/domain/entities/trip.dart';
import '../data/travel_places_repository.dart';
import '../data/travel_photo_picker.dart';
import 'travel_visit_photo.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/errors/api_exception.dart';
import '../data/travel_location_service.dart';
import '../domain/travel_place.dart';

class TravelPlaceSheet extends StatefulWidget {
  const TravelPlaceSheet({
    super.key,
    required this.locations,
    required this.save,
    required this.isCurrent,
    this.initial,
    this.existing,
    this.trip,
    this.repository,
    this.pickPhoto = pickTravelPhoto,
  });
  final TravelLocationService locations;
  final PlaceCandidate? initial;
  final TravelPlace? existing;
  final Trip? trip;
  final TravelPlacesRepository? repository;
  final Future<Uint8List?> Function() pickPhoto;
  final Future<TravelPlace> Function(PlaceCandidate, String, VisitDetails) save;
  final bool Function() isCurrent;
  @override
  State<TravelPlaceSheet> createState() => _TravelPlaceSheetState();
}

class _TravelPlaceSheetState extends State<TravelPlaceSheet> {
  final _query = TextEditingController();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  Uint8List? _photo;
  bool _picking = false, _removePhoto = false;
  @override
  void initState() {
    super.initState();
    final raw = widget.existing?.visitedOn ?? widget.trip?.dateFrom;
    final date = raw == null ? null : DateTime.tryParse(raw);
    if (date != null && !date.isAfter(DateTime.now()) && date.year >= 1900) {
      _date = DateUtils.dateOnly(date);
    }
  }

  Future<void> _pickPhoto() async {
    if (_picking || _saving) return;
    setState(() => _picking = true);
    try {
      final photo = await widget.pickPhoto();
      if (!mounted || !widget.isCurrent()) return;
      if (photo != null) {
        setState(() {
          _photo = photo;
          _removePhoto = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.travelPhotoError);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  late PlaceCandidate? _candidate = widget.initial;
  List<PlaceCandidate> _results = [];
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  bool _searching = false, _saving = false, _searched = false;
  String? _error;
  int _generation = 0;
  @override
  void dispose() {
    _generation++;
    _query.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_saving || _query.text.trim().length < 2 || !widget.isCurrent()) return;
    FocusScope.of(context).unfocus();
    final generation = ++_generation;
    setState(() {
      _searching = true;
      _error = null;
      _candidate = null;
      _results = [];
    });
    try {
      final results = await widget.locations.search(_query.text.trim());
      if (!mounted || generation != _generation || !widget.isCurrent()) return;
      setState(() {
        _results = results;
        _searched = true;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _error = context.l10n.travelMapLookupError);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _save() async {
    final candidate = _candidate;
    if (candidate == null || _saving || _picking || !widget.isCurrent()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await widget.save(
        candidate,
        DateFormat('yyyy-MM-dd').format(_date),
        VisitDetails(
          id: widget.existing?.id,
          tripId: widget.trip?.id,
          title: _title.text.trim(),
          photo: _photo,
          removePhoto: _removePhoto,
        ),
      );
      if (!mounted || !widget.isCurrent()) return;
      Navigator.of(context).pop(saved);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              error is ApiException && error.code == 'duplicate_travel_visit'
              ? context.l10n.travelDuplicate
              : error is ApiException && error.code == 'travel_map_limit'
              ? context.l10n.travelMapLimit
              : context.l10n.travelMapSaveError,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n, colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_saving,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.existing != null
                            ? t.travelEditVisit
                            : widget.initial == null
                            ? t.travelMapAdd
                            : t.travelMapConfirm,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: t.travelMapClose,
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (widget.trip != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      widget.trip!.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (widget.initial == null) ...[
                  const SizedBox(height: 8),
                  TextField(
                    key: const ValueKey('travel-place-search'),
                    controller: _query,
                    enabled: !_saving,
                    maxLength: 200,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      labelText: t.travelMapSearch,
                      hintText: t.travelMapSearchHint,
                      counterText: '',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (_) {
                      _generation++;
                      setState(() {
                        _candidate = null;
                        _results = [];
                        _searching = false;
                        _searched = false;
                        _error = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const ValueKey('travel-place-search-submit'),
                    onPressed: _saving || _searching ? null : _search,
                    icon: _searching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(t.travelMapSearchAction),
                  ),
                  for (final result in _results)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(result.city),
                      subtitle: Text(result.subtitle),
                      trailing: Icon(
                        identical(_candidate, result)
                            ? Icons.check_circle
                            : Icons.chevron_right,
                        color: identical(_candidate, result)
                            ? colors.primary
                            : null,
                      ),
                      onTap: _saving
                          ? null
                          : () => setState(() => _candidate = result),
                    ),
                  if (_searched && _results.isEmpty && !_searching)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(t.travelMapNoResults),
                    ),
                ],
                if (_candidate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _candidate!.city,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                _candidate!.subtitle,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.trip == null
                        ? t.travelMapConfirmBody
                        : t.travelTripConfirm,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  ListTile(
                    key: const ValueKey('travel-visit-date'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(t.travelMapDate),
                    subtitle: Text(
                      DateFormat.yMMMd(
                        Localizations.localeOf(context).toString(),
                      ).format(_date),
                    ),
                    onTap: _saving
                        ? null
                        : () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null && mounted) {
                              setState(() => _date = date);
                            }
                          },
                  ),
                ],
                if (_candidate != null) ...[
                  TextField(
                    key: const ValueKey('travel-visit-title'),
                    controller: _title,
                    enabled: !_saving,
                    maxLength: 120,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: t.travelVisitTitle,
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_removePhoto) ...[
                    if (_photo != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _photo!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (widget.existing?.hasPhoto == true &&
                        widget.repository != null)
                      TravelVisitPhoto(
                        place: widget.existing!,
                        repository: widget.repository!,
                        height: 110,
                      )
                    else if (widget.existing == null &&
                        (widget.trip?.imageThumbUrl ?? widget.trip?.imageUrl) !=
                            null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          (widget.trip!.imageThumbUrl ??
                              widget.trip!.imageUrl)!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                  ],
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        key: const ValueKey('travel-visit-photo'),
                        onPressed: _saving || _picking ? null : _pickPhoto,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          _photo != null || widget.existing?.hasPhoto == true
                              ? t.travelChangePhoto
                              : t.travelAddPhoto,
                        ),
                      ),
                      if (!_removePhoto &&
                          (_photo != null ||
                              widget.existing?.hasPhoto == true ||
                              (widget.existing == null &&
                                  widget.trip?.imageUrl != null)))
                        TextButton(
                          onPressed: _saving || _picking
                              ? null
                              : () => setState(() {
                                  _photo = null;
                                  _removePhoto = true;
                                }),
                          child: Text(t.travelRemovePhoto),
                        ),
                    ],
                  ),
                  if (_picking) const LinearProgressIndicator(),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(_error!, style: TextStyle(color: colors.error)),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const ValueKey('travel-place-save'),
                  onPressed: _candidate == null || _saving || _picking
                      ? null
                      : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_location_alt_outlined),
                  label: Text(t.travelMapSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
