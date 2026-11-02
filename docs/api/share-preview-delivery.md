# Share preview delivery — 2 November 2026

Goal: reduce preview transfer/encoding cost while preserving 1200×630 dimensions
and the existing invite validity checks. This cannot control WhatsApp's local
thumbnail/loading/cache behavior, and does not establish its root cause.

`share-image.php` retains PNG by default for existing links/cached HTML. For
`type=trip` or `type=invite`, optional `format=jpeg` selects a baseline JPEG at
quality 90. The updated invite page advertises this URL and matching Open Graph
MIME type. Friend/QR previews remain lossless PNG. Preview URL versions change to
trip5/myqr5 for newly fetched metadata; this cannot force-refresh existing chats.

PNG output drops the unnecessary alpha channel on an opaque canvas; JPEG uses
the same opaque canvas. Both include Content-Length. No public/static cache of
trip images is introduced: every image request still validates the invite and
trip output remains no-store. Revoked, expired, archived and directed invitations
still receive generic imagery. No invitation tokens appear in benchmark output.

Changes require backend/landing-page deployment; no mobile build change required.

## Local validation

- Five PHPUnit tests / 55 assertions pass: lossless PNG pixel comparison,
  dimensions, baseline JPEG, Open Graph MIME escaping, and trip media/invitation
  validity regressions. Changed PHP files pass lint and diff whitespace checks.
- Generic public friend image read (no user token): 51,382 bytes, approximately
  0.42s total in one request. This is not a measurement of the reported user's link.
- Local RGB PNG re-encoding: 51,382 → 46,395 bytes (9.7% smaller).
- Local photographic test cover (existing marketing artwork, not the real Greece
  trip): 541,081 → 115,156 bytes (78.7% smaller), same 1200×630 dimensions. One-run
  encoding times approximately 117ms PNG / 7ms JPEG; not a server benchmark.
- Fixtures/measurements: `output/design/share-preview-delivery/`.
- Not deployed. WhatsApp on-device before/after behavior remains unverified;
  already sent link cards may keep a cached preview despite the new image version.
