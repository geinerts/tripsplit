#!/usr/bin/env bash
# Turns on ops/nginx/site-pages.conf for splyto.eu: own 404 page, /privacy and
# /terms, redirects from the old .html addresses and from www, no nginx version.
#
# Run on the VPS after the repo is pulled:
#   sudo bash /var/www/splyto/scripts/apply_site_pages_nginx.sh
#
# Only the splyto.eu site file gets the include, right after its existing
# private-upload-locations.conf include. Backups go to
# /etc/nginx/site-pages-backups (never into sites-enabled, where nginx would
# load them). If `nginx -t` or a check fails, the old file is put back.
# Safe to run again.
set -euo pipefail

SNIPPET=/var/www/splyto/ops/nginx/site-pages.conf
ANCHOR=private-upload-locations.conf
BACKUPS=/etc/nginx/site-pages-backups

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2
  exit 1
fi
if [[ ! -f "$SNIPPET" ]]; then
  echo "Missing $SNIPPET. Pull the repo first." >&2
  exit 1
fi
mkdir -p "$BACKUPS"

# An earlier run of this script left backups inside sites-enabled; nginx loads
# every file there, so move them out.
shopt -s nullglob
for OLD in /etc/nginx/sites-enabled/*.bak-site-pages-*; do
  mv "$OLD" "$BACKUPS/"
  echo "Moved old backup out of sites-enabled: $(basename "$OLD")"
done
shopt -u nullglob

# The splyto.eu site, not ops.splyto.eu, which includes the same anchor.
CONF=""
for FILE in /etc/nginx/sites-enabled/*; do
  if grep -Eq "^[[:space:]]*server_name[^;]*[[:space:]]splyto\.eu([[:space:]]|;)" "$FILE" &&
     grep -q "$ANCHOR" "$FILE"; then
    CONF=$(readlink -f "$FILE")
    break
  fi
done
if [[ -z "$CONF" ]]; then
  echo "No splyto.eu site with $ANCHOR in /etc/nginx/sites-enabled. Nothing changed." >&2
  exit 1
fi

STAMP=$(date +%Y%m%d%H%M%S)
BACKUP="$BACKUPS/$(basename "$CONF").$STAMP"
CHANGED=0
if grep -q "site-pages.conf" "$CONF"; then
  echo "Already included in $CONF"
else
  cp -p "$CONF" "$BACKUP"
  # Same indentation as the anchor line, right after it (every server block of
  # this site that has the anchor, e.g. port 80 and 443).
  sed -i -E "s#^([[:space:]]*)include[[:space:]]+[^;]*${ANCHOR};#&\n\1include ${SNIPPET};#" "$CONF"
  if ! grep -q "include ${SNIPPET};" "$CONF"; then
    cp -p "$BACKUP" "$CONF"
    echo "Could not add the include to $CONF. Nothing changed." >&2
    exit 1
  fi
  CHANGED=1
  echo "Added include to $CONF (backup: $BACKUP)"
fi

restore() {
  if [[ $CHANGED -eq 1 ]]; then
    cp -p "$BACKUP" "$CONF"
  fi
}

if ! nginx -t; then
  restore
  nginx -t || true
  echo "nginx -t failed; the previous configuration is back. Nothing was reloaded." >&2
  exit 1
fi
systemctl reload nginx
sleep 2

# Check through the public address: the origin only answers Cloudflare, so a
# request straight to this machine gets 403. Pages here are not cached by
# Cloudflare; a query string makes sure of it.
BUST="check=$STAMP"
status() {
  curl -s -o /dev/null --max-redirs 0 -w '%{http_code} %{redirect_url}' "$1"
}
FAILED=0
expect() {
  local got
  got=$(status "$1")
  printf '%-48s %-52s %s\n' "$1" "$got" "$([[ "$got" == "$2" ]] && echo ok || echo "EXPECTED: $2")"
  [[ "$got" == "$2" ]] || FAILED=1
}
echo "Checks through splyto.eu:"
expect "https://splyto.eu/?$BUST" "200 "
expect "https://splyto.eu/privacy?$BUST" "200 "
expect "https://splyto.eu/terms?$BUST" "200 "
expect "https://splyto.eu/privacy.html?$BUST" "301 https://splyto.eu/privacy?$BUST"
expect "https://splyto.eu/terms.html?$BUST" "301 https://splyto.eu/terms?$BUST"
expect "https://splyto.eu/index.html?$BUST" "301 https://splyto.eu/?$BUST"
expect "https://splyto.eu/no-such-page-$STAMP" "404 "
expect "https://splyto.eu/api/api.php?action=me" "401 "

# www may be served by another server block; then it is only reported.
WWW=$(status "https://www.splyto.eu/privacy")
if [[ "$WWW" == "301 https://splyto.eu/privacy" ]]; then
  printf '%-48s %-52s ok\n' "https://www.splyto.eu/privacy" "$WWW"
else
  echo "Note: www.splyto.eu answered '$WWW'; it may need its own redirect."
fi

# The new pages must keep the security headers and show our 404 page.
if ! curl -sI "https://splyto.eu/privacy?$BUST" | grep -qi '^strict-transport-security'; then
  echo "/privacy is missing the security headers." >&2
  FAILED=1
fi
if ! curl -s "https://splyto.eu/no-such-page-$STAMP" | grep -q 'Page not found'; then
  echo "The 404 page is not the site's own page." >&2
  FAILED=1
fi

if [[ $FAILED -ne 0 ]]; then
  restore
  nginx -t && systemctl reload nginx
  echo "A check failed; the previous configuration is back and reloaded." >&2
  exit 1
fi
echo "All checks passed."
