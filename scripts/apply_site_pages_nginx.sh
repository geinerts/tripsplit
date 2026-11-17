#!/usr/bin/env bash
# Turns on ops/nginx/site-pages.conf for splyto.eu: own 404 page, /privacy and
# /terms, redirects from the old .html addresses and from www, no nginx version.
#
# Run on the VPS after the repo is pulled:
#   sudo bash /var/www/splyto/scripts/apply_site_pages_nginx.sh
#
# It adds one include next to the existing private-upload-locations.conf
# include, keeps a backup, and restores it if `nginx -t` fails. Safe to run
# again: an existing include is left as it is.
set -euo pipefail

SNIPPET=/var/www/splyto/ops/nginx/site-pages.conf
ANCHOR=private-upload-locations.conf

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2
  exit 1
fi
if [[ ! -f "$SNIPPET" ]]; then
  echo "Missing $SNIPPET. Pull the repo first." >&2
  exit 1
fi

mapfile -t CONFIGS < <(grep -l "$ANCHOR" /etc/nginx/sites-enabled/* 2>/dev/null | xargs -r -n1 readlink -f | sort -u)
if [[ ${#CONFIGS[@]} -eq 0 ]]; then
  echo "No site in /etc/nginx/sites-enabled includes $ANCHOR. Nothing changed." >&2
  exit 1
fi

STAMP=$(date +%Y%m%d%H%M%S)
CHANGED=()
for CONF in "${CONFIGS[@]}"; do
  if grep -q "site-pages.conf" "$CONF"; then
    echo "Already included in $CONF"
    continue
  fi
  cp -p "$CONF" "$CONF.bak-site-pages-$STAMP"
  # Same indentation as the anchor line, right after it.
  sed -i -E "s#^([[:space:]]*)include[[:space:]]+[^;]*${ANCHOR};#&\n\1include ${SNIPPET};#" "$CONF"
  if ! grep -q "include ${SNIPPET};" "$CONF"; then
    cp -p "$CONF.bak-site-pages-$STAMP" "$CONF"
    echo "Could not add the include to $CONF. Nothing changed." >&2
    exit 1
  fi
  CHANGED+=("$CONF")
  echo "Added include to $CONF (backup: $CONF.bak-site-pages-$STAMP)"
done

restore() {
  for CONF in "${CHANGED[@]}"; do
    cp -p "$CONF.bak-site-pages-$STAMP" "$CONF"
  done
}

if ! nginx -t; then
  restore
  nginx -t || true
  echo "nginx -t failed; the previous configuration is back. Nothing was reloaded." >&2
  exit 1
fi
systemctl reload nginx
sleep 1

# Ask this server directly (not Cloudflare). Expected answers are fixed; any
# other answer puts the old configuration back.
# -k: the origin certificate may not name www; this only talks to itself.
ORIGIN=127.0.0.1
if [[ "$(curl -sk -o /dev/null -w '%{http_code}' --resolve splyto.eu:443:$ORIGIN https://splyto.eu/)" == "000" ]]; then
  ORIGIN=$(hostname -I | awk '{print $1}')
fi
RESOLVE=(-k --resolve "splyto.eu:443:$ORIGIN" --resolve "www.splyto.eu:443:$ORIGIN")
status() {
  curl -s -o /dev/null --max-redirs 0 -w '%{http_code} %{redirect_url}' "${RESOLVE[@]}" "$1"
}
FAILED=0
expect() {
  local got
  got=$(status "$1")
  printf '%-34s %-45s %s\n' "$1" "$got" "$([[ "$got" == "$2" ]] && echo ok || echo "EXPECTED: $2")"
  [[ "$got" == "$2" ]] || FAILED=1
}
echo "Checks against this server:"
expect https://splyto.eu/ "200 "
expect https://splyto.eu/privacy "200 "
expect https://splyto.eu/terms "200 "
expect https://splyto.eu/privacy.html "301 https://splyto.eu/privacy"
expect https://splyto.eu/terms.html "301 https://splyto.eu/terms"
expect https://splyto.eu/index.html "301 https://splyto.eu/"
expect https://splyto.eu/no-such-page "404 "
expect "https://splyto.eu/api/api.php?action=me" "401 "

# www may be served by another server block; then it is only reported.
WWW=$(status https://www.splyto.eu/privacy)
if [[ "$WWW" == "301 https://splyto.eu/privacy" ]]; then
  printf '%-34s %-45s ok\n' https://www.splyto.eu/privacy "$WWW"
else
  echo "Note: www.splyto.eu answered '$WWW'; it may need its own redirect."
fi

# The new pages must keep the security headers and show our 404 page.
if ! curl -sI "${RESOLVE[@]}" https://splyto.eu/privacy | grep -qi '^strict-transport-security'; then
  echo "/privacy is missing the security headers." >&2
  FAILED=1
fi
if ! curl -s "${RESOLVE[@]}" https://splyto.eu/no-such-page | grep -q 'Page not found'; then
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
