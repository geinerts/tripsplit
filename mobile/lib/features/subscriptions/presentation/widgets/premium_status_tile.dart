import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/premium_access.dart';

class PremiumStatusTile extends StatefulWidget {
  const PremiumStatusTile({super.key, this.access, this.onRefresh});
  final PremiumAccess? access;
  final VoidCallback? onRefresh;

  @override
  State<PremiumStatusTile> createState() => _PremiumStatusTileState();
}

class _PremiumStatusTileState extends State<PremiumStatusTile>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleExpiry();
  }

  void _scheduleExpiry() {
    _timer?.cancel();
    final access = widget.access;
    if (access != null && access.isFresh) {
      _timer = Timer(access.remainingFreshness, () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(covariant PremiumStatusTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleExpiry();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleExpiry();
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final access = widget.access;
    final known = access != null && access.isFresh && access.plan != 'unknown';
    final premium = known && access.isPremium;
    final l10n = context.l10n;
    final label = premium
        ? 'Premium'
        : known
        ? l10n.premiumFree
        : l10n.premiumStatusUnavailable;
    final subtitle = premium
        ? l10n.premiumGrantedUntil(
            MaterialLocalizations.of(
              context,
            ).formatMediumDate(access.expiresAt!.toLocal()),
          )
        : known
        ? l10n.premiumBillingNotActive
        : l10n.premiumRefreshStatus;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(
            premium ? Icons.verified_outlined : Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onRefresh,
            tooltip: l10n.premiumRefreshStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
