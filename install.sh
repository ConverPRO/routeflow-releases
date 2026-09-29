#!/bin/sh
# RouteFlow for OpenWrt — one-line installer.
#
#   wget -qO- https://raw.githubusercontent.com/ConverPRO/routeflow-releases/main/install.sh | sh
#
# Finds the release, verifies release.json with the RouteFlow signing key below,
# verifies the release installer against the signed manifest and runs it. The
# installer then verifies SHA256SUMS and every package the same way.
# Environment: ROUTEFLOW_TAG=vX.Y.Z (exact release) or ROUTEFLOW_CHANNEL=auto|stable|rc.
set -eu
REPO='ConverPRO/routeflow-releases'
PUBKEY='RWSedSS5dcQhoekrOiS4aykFkJHUh9oVg4pYqbRYBb8XsGPCY3A8DXX6'
CHANNEL="${ROUTEFLOW_CHANNEL:-auto}"
log(){ echo "[RouteFlow] $*"; }
die(){ echo "[RouteFlow] ERROR: $*" >&2; exit 1; }
fetch(){ if command -v curl >/dev/null 2>&1; then curl -fsSL --retry 2 --connect-timeout 15 "$1" -o "$2"; else wget -q -T 30 -O "$2" "$1"; fi; }
for c in usign jsonfilter sha256sum; do command -v "$c" >/dev/null 2>&1 || die "$c is required (standard on OpenWrt 24.10)"; done
command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || die 'wget or curl is required'
[ "$(id -u)" = 0 ] || die 'run as root'
TMP="$(mktemp -d /tmp/routeflow-bootstrap.XXXXXX)"; trap 'rm -rf "$TMP"' EXIT
api="https://api.github.com/repos/$REPO/releases"
tag="${ROUTEFLOW_TAG:-}"
if [ -z "$tag" ]; then
  case "$CHANNEL" in auto|stable) fetch "$api/latest" "$TMP/latest.json" 2>/dev/null && tag="$(jsonfilter -i "$TMP/latest.json" -e '@.tag_name' 2>/dev/null || true)" ;; rc) ;; *) die "unknown ROUTEFLOW_CHANNEL=$CHANNEL" ;; esac
  if [ -z "$tag" ] && [ "$CHANNEL" != stable ]; then
    fetch "$api?per_page=1" "$TMP/all.json" || die 'cannot reach GitHub API'
    tag="$(jsonfilter -i "$TMP/all.json" -e '@[0].tag_name' 2>/dev/null || true)"
  fi
fi
[ -n "$tag" ] || die "no RouteFlow release found (channel $CHANNEL)"
base="https://github.com/$REPO/releases/download/$tag"
log "release $tag"
fetch "$base/release.json" "$TMP/release.json" || die 'release.json download failed'
fetch "$base/release.json.sig" "$TMP/release.json.sig" || die 'release.json.sig download failed'
printf 'untrusted comment: RouteFlow release signing key\n%s\n' "$PUBKEY" > "$TMP/key.pub"
usign -V -q -p "$TMP/key.pub" -m "$TMP/release.json" -x "$TMP/release.json.sig" || die 'release.json signature verification FAILED'
log 'release.json signature OK'
j(){ jsonfilter -i "$TMP/release.json" -e "@.$1" 2>/dev/null || true; }
[ "$(j tag)" = "$tag" ] || die "signed manifest is for $(j tag), not $tag"
inst_sha="$(j installer_sha256)"; sums_sha="$(j sha256sums_sha256)"
[ -n "$inst_sha" ] && [ -n "$sums_sha" ] || die 'signed manifest lacks checksums'
fetch "$base/install.sh" "$TMP/install.sh" || die 'install.sh download failed'
[ "$(sha256sum "$TMP/install.sh" | awk '{print $1}')" = "$inst_sha" ] || die 'install.sh checksum mismatch'
log "installing RouteFlow $(j version)"
ROUTEFLOW_REPO="$REPO" ROUTEFLOW_TAG="$tag" ROUTEFLOW_SHA256SUMS_SHA256="$sums_sha" sh "$TMP/install.sh"
