import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.revolutMeLink,
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
  final String? revolutMeLink;
  final String paypalTitle;
  final String? paypalMeLink;
  final String openLinkFailedText;
  final ValueChanged<String>? onErrorMessage;

  @override
  Widget build(BuildContext context) {
    final iban = (bankIban ?? '').trim();
    final bic = (bankBic ?? '').trim();
    final revolut = (revolutHandle ?? '').trim();
    final revolutMeRaw = (revolutMeLink ?? '').trim();
    final revolutMeUri = _revolutMeUriOrNull(revolutMeRaw);
    final revolutMeDisplay = _revolutDisplayLabel(revolutMeRaw, revolutMeUri);
    final paypalRaw = (paypalMeLink ?? '').trim();
    final paypalUri = _paypalUriOrNull(paypalRaw);
    final paypalDisplay = _paypalDisplayLabel(paypalRaw, paypalUri);
    final holder = bankHolderName.trim();
    final hasBank = iban.isNotEmpty || bic.isNotEmpty;
    final hasRevolut = revolut.isNotEmpty || revolutMeRaw.isNotEmpty;
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
                detailLines: [
                  _PaymentDetailLine(
                    text: '$bankHolderLabel: $holder',
                    copyValue: holder,
                    copySuccessText: _localizedText(
                      context,
                      en: 'Holder name copied.',
                      lv: 'Turētāja vārds nokopēts.',
                    ),
                  ),
                  if (iban.isNotEmpty)
                    _PaymentDetailLine(
                      text: 'IBAN: $iban',
                      copyValue: iban,
                      copySuccessText: _localizedText(
                        context,
                        en: 'IBAN copied.',
                        lv: 'IBAN nokopēts.',
                      ),
                    ),
                  if (bic.isNotEmpty)
                    _PaymentDetailLine(
                      text: 'SWIFT: $bic',
                      copyValue: bic,
                      copySuccessText: _localizedText(
                        context,
                        en: 'SWIFT copied.',
                        lv: 'SWIFT nokopēts.',
                      ),
                    ),
                ],
                onCopyLine: (line) => _copyDetailToClipboard(context, line),
              ),
            if (hasBank && (hasRevolut || hasPaypal)) const SizedBox(height: 8),
            if (hasRevolut)
              _PaymentMethodTile(
                leading: const _PaymentBrandLogo(
                  assetPath: 'assets/branding/revolut_logo.svg',
                  semanticsLabel: 'Revolut',
                ),
                title: revolutTitle,
                detailLines: [
                  if (revolutMeRaw.isNotEmpty)
                    _PaymentDetailLine(text: revolutMeDisplay)
                  else
                    _PaymentDetailLine(
                      text: revolut,
                      copyValue: revolut,
                      copySuccessText: _localizedText(
                        context,
                        en: 'Revtag copied.',
                        lv: 'Revtag nokopēts.',
                      ),
                    ),
                ],
                trailing: revolutMeUri == null
                    ? null
                    : Icon(
                        Icons.open_in_new_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                onTap: revolutMeUri == null
                    ? null
                    : () => _openExternalPaymentLink(context, revolutMeUri),
                onCopyLine: (line) => _copyDetailToClipboard(context, line),
              ),
            if (hasRevolut && hasPaypal) const SizedBox(height: 8),
            if (hasPaypal)
              _PaymentMethodTile(
                leading: const _PaymentBrandLogo(
                  assetPath: 'assets/branding/paypal_me_logo.svg',
                  semanticsLabel: 'PayPal.me',
                ),
                title: paypalTitle,
                detailLines: [_PaymentDetailLine(text: paypalDisplay)],
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

  Uri? _revolutMeUriOrNull(String rawValue) {
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
    final host = uri.host.toLowerCase().trim();
    if (host.isEmpty) {
      return null;
    }
    if (host != 'revolut.me' && host != 'www.revolut.me') {
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

  String _revolutDisplayLabel(String rawValue, Uri? uri) {
    if (uri == null) {
      return rawValue;
    }
    final host = uri.host.toLowerCase();
    if (host == 'revolut.me' || host == 'www.revolut.me') {
      final segments = uri.pathSegments
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (segments.isEmpty) {
        return 'revolut.me';
      }
      return 'revolut.me/${segments.first}';
    }
    return uri.toString();
  }

  String _localizedText(
    BuildContext context, {
    required String en,
    required String lv,
  }) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return lang == 'lv' ? lv : en;
  }

  Future<void> _copyDetailToClipboard(
    BuildContext context,
    _PaymentDetailLine line,
  ) async {
    final value = (line.copyValue ?? '').trim();
    if (value.isEmpty) {
      return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: value));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      final message = _localizedText(
        context,
        en: 'Could not copy to clipboard.',
        lv: 'Neizdevās nokopēt starpliktuvē.',
      );
      final onError = onErrorMessage;
      if (onError != null) {
        onError(message);
        return;
      }
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    final successText = (line.copySuccessText ?? '').trim().isNotEmpty
        ? line.copySuccessText!.trim()
        : _localizedText(context, en: 'Copied.', lv: 'Nokopēts.');
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(successText), behavior: SnackBarBehavior.floating),
    );
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
    required this.detailLines,
    this.trailing,
    this.onTap,
    this.onCopyLine,
  });

  final Widget leading;
  final String title;
  final List<_PaymentDetailLine> detailLines;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ValueChanged<_PaymentDetailLine>? onCopyLine;

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
                for (var i = 0; i < detailLines.length; i++) ...[
                  _PaymentLineRow(line: detailLines[i], onCopyLine: onCopyLine),
                  if (i < detailLines.length - 1) const SizedBox(height: 2),
                ],
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

class _PaymentDetailLine {
  const _PaymentDetailLine({
    required this.text,
    this.copyValue,
    this.copySuccessText,
  });

  final String text;
  final String? copyValue;
  final String? copySuccessText;
}

class _PaymentLineRow extends StatelessWidget {
  const _PaymentLineRow({required this.line, this.onCopyLine});

  final _PaymentDetailLine line;
  final ValueChanged<_PaymentDetailLine>? onCopyLine;

  @override
  Widget build(BuildContext context) {
    final copyValue = (line.copyValue ?? '').trim();
    final canCopy = copyValue.isNotEmpty && onCopyLine != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            line.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppDesign.mutedColor(context),
            ),
          ),
        ),
        if (canCopy)
          IconButton(
            onPressed: () => onCopyLine?.call(line),
            icon: Icon(
              Icons.content_copy_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            padding: EdgeInsets.zero,
            splashRadius: 18,
            visualDensity: VisualDensity.compact,
            tooltip: 'Copy',
          ),
      ],
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
