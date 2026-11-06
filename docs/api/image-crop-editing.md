# Editing the crop of saved images

Status: approved by the owner on 2026-11-06 and implemented. Not yet deployed.

People can move the crop of a saved trip cover, profile photo or travel-map visit photo
without choosing the photo again. Receipts are out of scope.

## Why this needs the original

The server stores only the cropped result today, so the parts that were cut off no
longer exist. Editing needs the uncropped image and the current crop.

The `image_cropper` plugin returns only a finished file, not the rectangle the person
chose. It can start from a saved rectangle on iOS only. So these three flows move to a
small Flutter crop editor using SDK widgets, with no new dependency. It works the same
on iOS and Android, returns the rectangle and reopens at it. Receipts keep the plugin.

## Storage

- Originals live outside the web root in `TRIP_IMAGE_ORIGINALS_DIR`, proposed
  `/var/lib/splyto/image-originals`, so a web server mistake cannot expose them. Files
  use mode `0640`.
- Each original is re-encoded to WebP with a 2048-pixel maximum edge and no metadata,
  which removes EXIF data such as GPS coordinates. Expected size is under 1 MB per image.
- A JSON file beside each original holds its pixel size and crop. Nothing is added to
  the database, so no migration is needed.
- Displayed files, thumbnails and existing URLs work as they do today. A new crop writes
  a new file name, so Cloudflare cannot serve the previous crop.

## Crop format

`crop` is `{x, y, width, height}`, each a fraction from 0 to 1 of the original. The
server rejects a rectangle outside the image, an aspect ratio more than 1% from the
required one, or a result under 320 pixels wide.

| Image | Aspect ratio | Displayed result |
| --- | --- | --- |
| Trip cover | 16:9 | Stored as today |
| Profile photo | 1:1 | Stored as today |
| Travel visit photo | 16:9 | Visit row, 768-pixel maximum edge, as today |

## API

All changes are additions. Existing actions and fields keep working, so installed apps
are unaffected.

### Saving a new image

`upload_trip_image` and `upload_avatar` still take the cropped image as `trip_image` or
`avatar`, and now also accept two optional multipart fields:

- `source_image`: the uncropped file, under 8 MB.
- `crop`: the JSON rectangle. Required when `source_image` is sent.

The response adds `has_crop_source`. An invalid rectangle returns 400 before anything is
stored. If the directory isn't configured, or the original is over a PHP upload limit,
the upload still succeeds and the field is `false`. Without these fields the actions behave as before.

New action, POST `upload_travel_photo_source` (multipart `source_image`, `crop`, `id`):
`save_travel_place` keeps its 704 KiB JSON limit, which is too small for an original. The
app sends it after the visit is saved. If that fails the visit keeps its photo, which can
then only be zoomed.

Quotas and upload rate limits count the original's bytes.

### Opening the editor

GET `image_crop_source` with `kind` (`trip`, `avatar`, `travel`), plus `X-Trip-Id` for a
trip or `id` for a visit.

```json
{"ok": true, "image_base64": "...", "width": 2048, "height": 1365,
 "crop": {"x": 0.1, "y": 0.2, "width": 0.8, "height": 0.6},
 "has_original": true, "revision": "uploads/trips/...webp"}
```

Sent with `no-store` headers. Originals never appear in trip, member, invitation or
share payloads, and have no public URL.

### Saving a new crop

POST `update_image_crop` with `kind`, `crop`, `revision` (the value from
`image_crop_source`) and the same target fields. The server makes the new displayed image
from the original.

Returns the same payload as the matching upload, plus `me` for an avatar or `place` for
a visit. If the image changed in the meantime the server returns 409 with
`code: image_changed`, so two trip admins cannot overwrite each other.

## Who can do what

| Image | Open and edit |
| --- | --- |
| Trip cover | Only people with the `update_details` permission on that trip |
| Profile photo | Only the account owner |
| Visit photo | Only the visit owner |

Other trip members see only the cropped cover, as they do today. The admin panel gets no
access to originals.

## Images without an original

This covers images uploaded earlier, images from older app versions, and visit photos
copied from a trip.

- The saved image acts as the original, so the person can zoom in but not recover
  anything cut off earlier. `has_original` is `false` and the editor says so.
- The first edit keeps that image as the source, so zooming can be undone.
- A visit copied from a trip never receives the trip's original. Trip members who cannot
  edit the cover must not gain access to it through their own map.

## Deleting originals

The original and its JSON file are deleted with the image they belong to:

- when the image is replaced or removed,
- when a visit or trip is deleted,
- when an account is deleted,
- when an older app replaces the image, leaving no stale original behind.

If another trip still points to the same image path, deletion waits until nothing refers
to it, as `delete_unreferenced_trip_image` does today. `scripts/run_image_originals_cleanup.php`
removes originals older than 7 days that nothing refers to, such as covers uploaded but
never attached. It is a dry run unless given `--apply`; run it weekly from cron.

Routine backups include this directory and follow the existing 14-day retention, so a
deleted original can stay in a backup for up to 14 days.

## Privacy policy

Originals can show more than the person meant to display, so the policy must say that
Splyto keeps the uncropped version to allow later editing, that it is private, and when
it is deleted. This updates `privacy.html` and `mobile/assets/legal/privacy_{en,lv,es}.json`
before release.

## Deployment

1. Create the directory with the correct owner and add `TRIP_IMAGE_ORIGINALS_DIR` to the
   server's environment file. Without it, uploads and zooming work but no originals are kept.
2. Deploy the backend before the app. No database migration is needed.
   `scripts/backup_vps.sh` includes the directory once it is configured.
3. Add the weekly cleanup to cron.
4. Set PHP's `upload_max_filesize` to 8M and `post_max_size` to 12M, matching nginx's
   12M limit, since an upload can now carry both images. PHP's defaults of 2M and 8M
   would drop most originals.
5. Release an app build with the new editor.

## Tests

- Backend: permissions for each kind, foreign and missing targets, invalid rectangles,
  metadata removal, the 409 conflict, old-app uploads, every deletion path, and that no
  payload exposes an original.
- Mobile: the editor at 320 px and 200% text, reopening at the saved crop, zoom-only
  images, and failure and retry states.

Applying the crop to a real gallery photo, EXIF rotation included, needs a device.
