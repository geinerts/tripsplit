import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../data/travel_location_service.dart';
import '../domain/travel_place.dart';

Future<PlaceCandidate?> pickTravelCity(
  BuildContext context, {
  TravelLocationService? locations,
}) => showModalBottomSheet<PlaceCandidate>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) =>
      _CityPicker(locations: locations ?? NativeTravelLocationService()),
);

class _CityPicker extends StatefulWidget {
  const _CityPicker({required this.locations});
  final TravelLocationService locations;
  @override
  State<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<_CityPicker> {
  final _query = TextEditingController();
  List<PlaceCandidate> _results = [];
  bool _busy = false;
  String? _error;
  int _generation = 0;
  @override
  void dispose() {
    _generation++;
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_busy || _query.text.trim().length < 2) return;
    FocusScope.of(context).unfocus();
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      _results = [];
    });
    try {
      final results = await widget.locations.search(_query.text.trim());
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = results;
        if (results.isEmpty) _error = context.l10n.travelMapNoResults;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _error = context.l10n.travelMapLookupError);
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
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
                      t.travelMapSearch,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: t.travelMapClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              TextField(
                key: const ValueKey('destination-search'),
                controller: _query,
                maxLength: 200,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: t.travelMapSearchHint,
                  counterText: '',
                ),
                onSubmitted: (_) => _search(),
                onChanged: (_) {
                  _generation++;
                  setState(() {
                    _results = [];
                    _busy = false;
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _search,
                child: Text(t.travelMapSearchAction),
              ),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!),
                ),
              for (final place in _results)
                ListTile(
                  title: Text(place.city),
                  subtitle: Text(place.subtitle),
                  trailing: const Icon(Icons.add_location_alt_outlined),
                  onTap: () => Navigator.pop(context, place),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
