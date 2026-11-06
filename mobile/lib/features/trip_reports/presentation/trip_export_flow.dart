import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_components.dart';
import '../../../core/ui/app_sheet.dart';
import '../data/trip_reports_repository.dart';

/// Asks for a format, then fetches the file and opens the system share sheet.
Future<void> runTripExport(
  BuildContext context,
  TripReportsRepository repository, {
  required int tripId,
}) async {
  final t = context.l10n;
  final format = await showAppBottomSheet<TripExportFormat>(
    context: context,
    builder: (sheetContext) => AppActionSheet(
      key: const ValueKey('trip-export-sheet'),
      title: t.tripExportAction,
      children: [
        AppPlainActionTile(
          key: const ValueKey('trip-export-pdf'),
          icon: Icons.picture_as_pdf_outlined,
          title: t.tripExportPdf,
          onTap: () => Navigator.of(sheetContext).pop(TripExportFormat.pdf),
        ),
        AppPlainActionTile(
          key: const ValueKey('trip-export-csv'),
          icon: Icons.table_chart_outlined,
          title: t.tripExportCsv,
          onTap: () => Navigator.of(sheetContext).pop(TripExportFormat.csv),
        ),
      ],
    ),
  );
  if (format == null || !context.mounted) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  final messenger = ScaffoldMessenger.of(context);
  final locale = Localizations.localeOf(context).languageCode;
  final box = context.findRenderObject() as RenderBox?;
  final origin = box != null && box.hasSize
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
  final failure = t.tripExportFailed;

  var loaderOpen = true;
  void closeLoader() {
    if (loaderOpen) {
      loaderOpen = false;
      navigator.pop();
    }
  }

  // Not awaited: it stays up until the export finishes and closeLoader runs.
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
  );
  try {
    final file = await repository.exportTrip(
      tripId: tripId,
      format: format,
      locale: locale,
    );
    closeLoader();
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(file.bytes, mimeType: file.mimeType, name: file.name),
        ],
        fileNameOverrides: [file.name],
        sharePositionOrigin: origin,
      ),
    );
  } catch (_) {
    closeLoader();
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(failure)));
  }
}
