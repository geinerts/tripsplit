# Receipt image uploads

Receipt selections from Files, Photos and Camera pass through
`ReceiptImagePreparer` before upload. The original file is never overwritten.

- JPEG, PNG and WebP images up to 1,572,864 bytes pass through unchanged.
- Larger images are encoded as JPEG, trying quality 90/82 and progressively
  smaller dimensions (longest edge 4096 down to 1280). Each attempt starts from
  the original bytes, preserves proportions, and does not crop the image.
- HEIC/HEIF images are converted even when already small. Converted images have
  their orientation applied and EXIF metadata removed.
- Failed conversions are reported in the UI; oversized output is not uploaded.
- The existing API converts the accepted upload to WebP for storage.

The upload budget leaves headroom below the production PHP-FPM 2 MiB per-file
limit, checked on 2026-10-24. The API's separate 8 MiB allowance does not override
PHP's earlier request validation. No server settings were changed for this fix.

## Verification (2026-10-24)

- Receipt preparer and workspace widget suite: 124 tests passed.
- Targeted Dart analysis: no issues.
- iOS simulator Debug build succeeded with the native compression plugin.
- Native integration test on iPhone 17 Pro / iOS 26.3.1: generated 3024 × 4032
  image, 28,215,797 bytes, reduced to 1200 × 1600 / 1,055,705 bytes in 1,443 ms.
  Aspect ratio and coloured markers at opposite corners were preserved. This
  deliberately noisy fixture is a size/geometry check, not an OCR accuracy test.

Run `flutter test test/core/media/receipt_image_preparer_test.dart
test/features/workspace/workspace_redesign_test.dart` for unit/widget coverage.
The native test is `integration_test/receipt_image_preparer_test.dart`; its host
driver is `test_driver/integration_test.dart`.

If Flutter's device-specific Xcode destination selection fails, build with
`flutter build ios --simulator --debug --no-pub -t
integration_test/receipt_image_preparer_test.dart`, then run `flutter drive`
with `--use-application-binary=build/ios/iphonesimulator/Runner.app`, the target,
the driver and the booted simulator ID. Restore the normal `lib/main.dart`
target using `flutter build ios --config-only --release --no-pub --no-codesign
-t lib/main.dart` afterwards.

The TestFlight archive and version number were not updated by this change.
