import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/trip.dart';
import '../models/trip_model.dart';

class TripsLocalStore {
  static const String _key = 'trips_list_cache_v1';

  Future<List<Trip>> readTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = (prefs.getString(_key) ?? '').trim();
    if (raw.isEmpty) {
      return const <Trip>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const <Trip>[];
      }
      final trips = <Trip>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        trips.add(TripModel.fromLegacyMap(item));
      }
      return List<Trip>.unmodifiable(trips);
    } catch (_) {
      return const <Trip>[];
    }
  }

  Future<void> writeTrips(List<Trip> trips) async {
    final payload = trips.map(_tripToMap).toList(growable: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(payload));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Map<String, dynamic> _tripToMap(Trip trip) {
    return <String, dynamic>{
      'id': trip.id,
      'name': trip.name,
      'currency_code': trip.currencyCode,
      'status': trip.status,
      'image_url': trip.imageUrl,
      'image_thumb_url': trip.imageThumbUrl,
      'members_count': trip.membersCount,
      'created_at': trip.createdAt,
      'created_by': trip.createdBy,
      'ended_at': trip.endedAt,
      'archived_at': trip.archivedAt,
      'settlements_total': trip.settlementsTotal,
      'settlements_confirmed': trip.settlementsConfirmed,
      'settlements_pending': trip.settlementsPending,
      'all_settled': trip.allSettled,
      'ready_to_settle': trip.readyToSettle,
      'total_amount_cents': trip.totalAmountCents,
      'my_paid_cents': trip.myPaidCents,
      'my_owed_cents': trip.myOwedCents,
      'my_balance_cents': trip.myBalanceCents,
    };
  }
}
