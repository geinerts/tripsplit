import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Keeps branded artwork transparent on dark surfaces without tinting its accents.
class SplytoIllustration extends StatelessWidget {
  const SplytoIllustration(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.excludeFromSemantics = true,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: width,
    height: height,
    fit: fit,
    excludeFromSemantics: excludeFromSemantics,
    colorMapper: Theme.of(context).brightness == Brightness.dark
        ? const _DarkIllustrationColors()
        : null,
  );
}

/// Branded artwork shown wherever the app reports that an email was sent
/// (password reset, email verification, account deletion confirmation).
class SplytoEmailSentIllustration extends StatelessWidget {
  const SplytoEmailSentIllustration({
    super.key,
    this.width = 144,
    this.height = 110,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SplytoIllustration(
    'assets/branding/splyto_empty_trip_invitations.svg',
    width: width,
    height: height,
  );
}

class _DarkIllustrationColors extends ColorMapper {
  const _DarkIllustrationColors();

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    // This pale cyan is reserved for the full-canvas trip-cover background.
    if (attributeName == 'fill' && color == const Color(0xFFEAF9FC)) {
      return Colors.transparent;
    }
    // Preserve fine navy outlines when the light backing is absent.
    if (attributeName == 'stroke' && color == const Color(0xFF253950)) {
      return const Color(0xFFB5CAD3);
    }
    return color;
  }
}
