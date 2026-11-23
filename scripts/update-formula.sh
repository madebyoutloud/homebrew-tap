#!/bin/sh
# Points a formula at a new release: rewrites its url (which carries the
# version) and sha256, and a version line if the formula has one.
#
#   scripts/update-formula.sh outloud 2.1.0             # downloads from cli.outloud.dev
#   scripts/update-formula.sh outloud 2.1.0 cli.tgz     # hashes a tarball you already have
#
# Without a tarball it downloads the release from https://cli.outloud.dev with
# HOMEBREW_OUTLOUD_TOKEN or the token install.sh saved to
# ${XDG_CONFIG_HOME:-~/.config}/outloud/token.
set -eu

DIST_URL='https://cli.outloud.dev'

fail() {
  printf 'update-formula: %s\n' "$*" >&2
  exit 1
}

[ $# -eq 2 ] || [ $# -eq 3 ] || fail "usage: $0 outloud <version> [tarball]"
name=$1
version=${2#v}
tarball=${3:-}

case "$name" in
  outloud) key=cli ;;
  *) fail "unknown formula: $name, use outloud" ;;
esac

case "$version" in
  '' | *[!0-9A-Za-z.+-]*) fail "not a version: $version" ;;
esac

root=$(cd "$(dirname "$0")/.." && pwd)
formula="$root/Formula/$name.rb"
[ -f "$formula" ] || fail "no formula at $formula"

work=$(mktemp -d "${TMPDIR:-/tmp}/update-formula.XXXXXX")
trap 'rm -rf "$work"' EXIT

if [ -n "$tarball" ]; then
  [ -f "$tarball" ] || fail "no tarball at $tarball"
else
  token=${HOMEBREW_OUTLOUD_TOKEN:-}
  token_file="${XDG_CONFIG_HOME:-$HOME/.config}/outloud/token"
  if [ -z "$token" ] && [ -f "$token_file" ]; then token=$(tr -d ' \r\n' <"$token_file"); fi
  [ -n "$token" ] || fail "no token: set HOMEBREW_OUTLOUD_TOKEN or sign in with curl -fsSL $DIST_URL/install.sh | sh, or pass a tarball"

  tarball="$work/$name.tgz"
  auth="$work/auth"
  # the token goes in a file, so it isn't in the process list
  (umask 077 && printf 'Authorization: Bearer %s\n' "$token" >"$auth")
  # no --location: the service never redirects
  status=$(curl -sS -H "@$auth" -o "$tarball" -w '%{http_code}' "$DIST_URL/$key/$version.tgz") ||
    fail "couldn't download $DIST_URL/$key/$version.tgz"
  rm -f "$auth"
  [ "$status" = 200 ] || fail "$DIST_URL/$key/$version.tgz answered HTTP $status"
fi

# the tarball must be the release it's named for
packed=$(tar -xzOf "$tarball" package/package.json 2>/dev/null | sed -nE 's/^  "version": "([^"]+)".*/\1/p' | head -n 1)
[ "$packed" = "$version" ] || fail "the tarball holds version ${packed:-unknown}, not $version"

if command -v sha256sum >/dev/null 2>&1; then
  sha256=$(sha256sum "$tarball" | cut -d' ' -f1)
else
  sha256=$(shasum -a 256 "$tarball" | cut -d' ' -f1)
fi
url="$DIST_URL/$key/$version.tgz"

# portable in-place edit (BSD and GNU sed)
sed -E \
  -e "s|^(  url \")[^\"]*(\",)\$|\\1$url\\2|" \
  -e "s|^(  sha256 \")[0-9a-f]*(\")\$|\\1$sha256\\2|" \
  -e "s|^(  version \")[^\"]*(\")\$|\\1$version\\2|" \
  "$formula" >"$work/formula.rb"

grep -qF "url \"$url\"" "$work/formula.rb" || fail "couldn't rewrite the url in $formula"
grep -qF "sha256 \"$sha256\"" "$work/formula.rb" || fail "couldn't rewrite the sha256 in $formula"
cat "$work/formula.rb" >"$formula"

printf '%s %s\nsha256 %s\n' "$name" "$version" "$sha256"
