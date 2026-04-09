import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_design.dart';
import 'user_profile_page.dart';

class UserProfilePaymentDetailsSection extends StatelessWidget {
  const UserProfilePaymentDetailsSection({
    super.key,
    required this.sectionTitle,
    required this.emptyText,
    required this.bankTransferTitle,
    required this.bankHolderLabel,
    required this.bankHolderName,
    this.bankIban,
    this.bankBic,
    required this.revolutTitle,
    this.revolutHandle,
    required this.paypalTitle,
    this.paypalMeLink,
    required this.openLinkFailedText,
    this.onErrorMessage,
  });

  final String sectionTitle;
  final String emptyText;
  final String bankTransferTitle;
  final String bankHolderLabel;
  final String bankHolderName;
  final String? bankIban;
  final String? bankBic;
  final String revolutTitle;
  final String? revolutHandle;
  final String paypalTitle;
  final String? paypalMeLink;
  final String openLinkFailedText;
  final ValueChanged<String>? onErrorMessage;

  @override
  Widget build(BuildContext context) {
    final iban = (bankIban ?? '').trim();
    final bic = (bankBic ?? '').trim();
    final revolut = (revolutHandle ?? '').trim();
    final paypalRaw = (paypalMeLink ?? '').trim();
    final paypalUri = _paypalUriOrNull(paypalRaw);
    final paypalDisplay = _paypalDisplayLabel(paypalRaw, paypalUri);
    final holder = bankHolderName.trim();
    final hasBank = iban.isNotEmpty || bic.isNotEmpty;
    final hasRevolut = revolut.isNotEmpty;
    final hasPaypal = paypalRaw.isNotEmpty;
    final hasAny = hasBank || hasRevolut || hasPaypal;

    return UserProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                sectionTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasAny)
            Text(
              emptyText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppDesign.mutedColor(context),
              ),
            )
          else ...[
            if (hasBank)
              _PaymentMethodTile(
                leading: Icon(
                  Icons.account_balance_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: bankTransferTitle,
                subtitleLines: [
                  '$bankHolderLabel: $holder',
                  if (iban.isNotEmpty) 'IBAN: $iban',
                  if (bic.isNotEmpty) 'SWIFT: $bic',
                ],
              ),
            if (hasBank && (hasRevolut || hasPaypal)) const SizedBox(height: 8),
            if (hasRevolut)
              _PaymentMethodTile(
                leading: const _PaymentBrandLogo(
                  assetPath: 'assets/branding/revolut_logo.svg',
                  semanticsLabel: 'Revolut',
                ),
                title: revolutTitle,
                subtitleLines: [revolut],
              ),
            if (hasRevolut && hasPaypal) const SizedBox(height: 8),
            if (hasPaypal)
              _PaymentMethodTile(
                leading: const _PaymentBrandLogo(
                  assetPath: 'assets/branding/paypal_me_logo.svg',
                  semanticsLabel: 'PayPal.me',
                ),
                title: paypalTitle,
                subtitleLines: [paypalDisplay],
                trailing: paypalUri == null
                    ? null
                    : Icon(
                        Icons.open_in_new_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                onTap: paypalUri == null
                    ? null
                    : () => _openExternalPaymentLink(context, paypalUri),
              ),
          ],
        ],
      ),
    );
  }

  Uri? _paypalUriOrNull(String rawValue) {
    final raw = rawValue.trim();
    if (raw.isEmpty) {
      return null;
    }
    final candidate = raw.contains('://') ? raw : 'https://$raw';
    final uri = Uri.tryParse(candidate);
    if (uri == null) {
      return null;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }
    if ((uri.host).trim().isEmpty) {
      return null;
    }
    return uri;
  }

  String _paypalDisplayLabel(String rawValue, Uri? uri) {
    if (uri == null) {
      return rawValue;
    }
    final host = uri.host.toLowerCase();
    if (host == 'paypal.me' || host == 'www.paypal.me') {
      final segments = uri.pathSegments
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (segments.isEmpty) {
        return 'paypal.me';
      }
      return 'paypal.me/${segments.first}';
    }
    return uri.toString();
  }

  Future<void> _openExternalPaymentLink(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final onError = onErrorMessage;
    if (onError != null) {
      onError(openLinkFailedText);
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(openLinkFailedText),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.leading,
    required this.title,
    required this.subtitleLines,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final List<String> subtitleLines;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        border: Border.all(color: AppDesign.cardStroke(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SizedBox(
              width: 26,
              height: 26,
              child: Center(child: leading),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                for (final line in subtitleLines)
                  Text(
                    line,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppDesign.mutedColor(context),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _PaymentBrandLogo extends StatelessWidget {
  const _PaymentBrandLogo({
    required this.assetPath,
    required this.semanticsLabel,
  });

  final String assetPath;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
