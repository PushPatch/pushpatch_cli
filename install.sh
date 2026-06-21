#!/usr/bin/env sh
# PushPatch CLI installer (macOS / Linux).
#
#   curl -fsSL https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/install.sh | sh
#
# Environment overrides:
#   PUSHPATCH_REPO     GitHub repo (default: PushPatch/pushpatch_cli)
#   PUSHPATCH_VERSION  Tag to install (default: latest)
#   PUSHPATCH_BIN_DIR  Install dir (default: /usr/local/bin or ~/.pushpatch/bin)
set -eu

REPO="${PUSHPATCH_REPO:-PushPatch/pushpatch_cli}"
VERSION="${PUSHPATCH_VERSION:-latest}"

say()  { printf '\033[36m→\033[0m %s\n' "$1"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$1"; }
die()  { printf '\033[31m✗\033[0m %s\n' "$1" >&2; exit 1; }

# --- detect platform -------------------------------------------------------
os="$(uname -s)"; arch="$(uname -m)"
case "$os" in
  Darwin) os_part="apple-darwin" ;;
  Linux)  os_part="unknown-linux-gnu" ;;
  *) die "unsupported OS: $os" ;;
esac
case "$arch" in
  x86_64|amd64) arch_part="x86_64" ;;
  arm64|aarch64) arch_part="aarch64" ;;
  *) die "unsupported architecture: $arch" ;;
esac
target="${arch_part}-${os_part}"
say "Detected target: $target"

# --- resolve version -------------------------------------------------------
if [ "$VERSION" = "latest" ]; then
  VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' | head -1 | cut -d '"' -f4)"
  [ -n "$VERSION" ] || die "could not resolve latest version"
fi
ver_num="${VERSION#v}"
say "Installing pushpatch ${ver_num}"

# --- download + verify -----------------------------------------------------
asset="pushpatch-${ver_num}-${target}.tar.gz"
base="https://github.com/${REPO}/releases/download/${VERSION}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

say "Downloading ${asset}"
curl -fsSL "${base}/${asset}" -o "${tmp}/${asset}" || die "download failed"

if curl -fsSL "${base}/${asset}.sha256" -o "${tmp}/${asset}.sha256" 2>/dev/null; then
  say "Verifying checksum"
  expected="$(cut -d ' ' -f1 < "${tmp}/${asset}.sha256")"
  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "${tmp}/${asset}" | cut -d ' ' -f1)"
  else
    actual="$(shasum -a 256 "${tmp}/${asset}" | cut -d ' ' -f1)"
  fi
  [ "$expected" = "$actual" ] || die "checksum mismatch (expected $expected, got $actual)"
  ok "Checksum verified"
else
  say "No checksum published — skipping verification"
fi

# --- install ---------------------------------------------------------------
tar -xzf "${tmp}/${asset}" -C "$tmp"
[ -f "${tmp}/pushpatch" ] || die "binary not found in archive"
chmod +x "${tmp}/pushpatch"

if [ -n "${PUSHPATCH_BIN_DIR:-}" ]; then
  bin_dir="$PUSHPATCH_BIN_DIR"
elif [ -w "/usr/local/bin" ]; then
  bin_dir="/usr/local/bin"
else
  bin_dir="${HOME}/.pushpatch/bin"
fi
mkdir -p "$bin_dir"
mv "${tmp}/pushpatch" "${bin_dir}/pushpatch"
ok "Installed to ${bin_dir}/pushpatch"

case ":${PATH}:" in
  *":${bin_dir}:"*) ;;
  *) printf '\033[33m!\033[0m Add %s to your PATH:\n    export PATH="%s:$PATH"\n' "$bin_dir" "$bin_dir" ;;
esac

"${bin_dir}/pushpatch" version || true
printf '\n🚀 PushPatch CLI installed\n'
