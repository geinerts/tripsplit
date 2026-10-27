# Trip media, invite preview and registration fixes

Status: locally implemented and tested on 2026-10-26. Not deployed by this change.
Addresses S-01, S-02 and S-03 from the 2026-10-25 bounded security audit.

## Cover attachment ownership (S-01)

New cover uploads and their thumbnails are renamed with an HMAC bound to the
server-selected trip, authenticated uploader and random upload path. The trip
update handler accepts a new image only when that binding matches and the file
exists. Editing the current trip already requires owner/admin permission.

An unchanged existing cover remains accepted, including legacy filenames and
covers predating signing-key rotation. Removing or replacing a cover, or deleting
a trip, only deletes the file and thumbnail when no trip references that path.
This also protects historic shared references. It does not make public trip covers
private, and does not infer ownership from a client-supplied filename alone.

No schema migration or mobile API change is required. Existing clients pass back
the opaque `image_path` returned by upload. An unattached upload made before this
deployment, or before signing-key rotation, must be uploaded again.

## Revoked invitation metadata (S-02)

The shared metadata resolver returns only a neutral name, empty image and empty
expiry for revoked, expired, invalid-expiry, inactive-trip, directed or unknown
invites. Only valid generic invites expose metadata. Both HTML and PNG consumers
guard the displayed metadata. Trip preview responses use `Cache-Control: no-store`
so future compliant caches cannot keep serving a valid preview after revocation.

Revocation cannot erase previews already copied by a messaging service, nor does
it revoke a previously known direct public image URL. Previously cached responses
can persist according to their original lifetime until expiry/purge.

## Registration verification (S-03)

Removed the `@example.test` auto-verification branch. New email/password accounts
follow the ordinary email verification policy regardless of domain. The reserved
domain cannot receive mail and provides no automatic authenticated session.
Existing guest registration behavior is unchanged.

No existing accounts or sessions are modified. Previously auto-verified test
accounts need a separate production inventory and remediation decision; this patch
does not silently remove accounts or data.

## Verification

Full local PHP suite: **441 tests, 3898 assertions**, passing on PHP 8.5.4.

```sh
RANDFILE=/private/tmp/splyto-openssl-test-random php api/vendor/bin/phpunit -c api/phpunit.xml --display-warnings
```

`TripMediaSecurityTest` runs the real update/delete handlers and upload binding
with a synthetic SQLite database and unique disposable files under `output/tests`.
Authentication, rate limits, schema capability and events are adapters; MySQL's
DELETE LIMIT syntax is adapted for SQLite. Tests cover foreign legacy/signed
attachments, another uploader, tampering, legitimate uploads and thumbnail rename,
unchanged legacy covers, removal/replacement/deletion with shared references, and
unreferenced cleanup. The preview fixture exercises the real metadata resolver,
including metadata changed after revocation and exact expiry.

`RegistrationSecurityTest` covers ordinary and mixed-case `EXAMPLE.TEST`
registration with both name-column and legacy schemas: verification stays pending,
no `me`/`auth` payload or session is issued, and the verification sender is invoked.
Mail, session issuance and events use local test adapters.

These tests perform no production requests, send no email and do not validate a
live deployment or native-device end-to-end behavior. Administrator MFA changes
remain deferred as requested.
