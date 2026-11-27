import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';

/// The Home card that announces the year summary during its season.
class YearSummaryHomeBanner extends StatelessWidget {
  const YearSummaryHomeBanner({
    super.key,
    required this.year,
    required this.onOpen,
  });

  final int year;
  final VoidCallback onOpen;

  static const _ink = Color(0xFF0B1B3A);
  static const _mint = Color(0xFFA6F0CC);

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final card = Material(
      color: _ink,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const ValueKey('year-summary-home-banner'),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mint.withValues(alpha: .14),
                  border: Border.all(color: _mint.withValues(alpha: .5)),
                ),
                child: const Icon(Icons.public, color: _mint, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.yearSummaryBannerNew,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: _mint,
                      ),
                    ),
                    Text(
                      t.yearSummaryBannerTitle('$year'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      t.yearSummaryBannerBody,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFC7D8FF),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
    // The space above belongs to the card, so a hidden card leaves no gap.
    return Padding(padding: const EdgeInsets.only(top: 16), child: card);
  }
}
