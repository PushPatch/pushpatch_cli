#!/usr/bin/env sh
# PushPatch CLI uninstaller (macOS / Linux).
#
#   curl -fsSL https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/uninstall.sh | sh
#
# Removes the binary, config/cache (~/.pushpatch), and the keychain credentials.
# Set PUSHPATCH_KEEP_CONFIG=1 to keep ~/.pushpatch.
set -eu

say()  { printf '\033[36m→\033[0m %s\n' "$1"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '\033[33m!\033[0m %s\n' "$1"; }

# --- 1. clear stored credentials (best-effort) -----------------------------
if command -v pushpatch >/dev/null 2>&1; then
  say "Clearing stored credentials"
  pushpatch logout >/dev/null 2>&1 || true
fi
# macOS: also remove the keychain item directly in case logout didn't run.
if command -v security >/dev/null 2>&1; then
  while security delete-generic-password -s dev.pushpatch.cli >/dev/null 2>&1; do :; done
fi

# --- 2. remove the binary --------------------------------------------------
removed=0
for p in \
  /usr/local/bin/pushpatch \
  "${HOME}/.pushpatch/bin/pushpatch" \
  "${PUSHPATCH_BIN_DIR:-/nonexistent}/pushpatch"
do
  if [ -f "$p" ]; then
    if [ -w "$p" ] || [ -w "$(dirname "$p")" ]; then
      rm -f "$p" && ok "Removed $p" && removed=1
    else
      sudo rm -f "$p" && ok "Removed $p (sudo)" && removed=1
    fi
  fi
done
# Anything else still on PATH?
if command -v pushpatch >/dev/null 2>&1; then
  warn "Another 'pushpatch' is still on PATH at: $(command -v pushpatch)"
  warn "If installed via a package manager, remove it with:"
  warn "  brew uninstall pushpatch   (Homebrew)"
elif [ "$removed" -eq 0 ]; then
  warn "No pushpatch binary found in the standard locations"
fi

# --- 3. remove config & cache ----------------------------------------------
if [ "${PUSHPATCH_KEEP_CONFIG:-0}" = "1" ]; then
  say "Keeping ${HOME}/.pushpatch (PUSHPATCH_KEEP_CONFIG=1)"
elif [ -d "${HOME}/.pushpatch" ]; then
  rm -rf "${HOME}/.pushpatch" && ok "Removed ${HOME}/.pushpatch"
fi

# --- 4. PATH note ----------------------------------------------------------
case ":${PATH}:" in
  *":${HOME}/.pushpatch/bin:"*)
    warn "Remove ${HOME}/.pushpatch/bin from your PATH in ~/.zshrc or ~/.bashrc"
    ;;
esac

printf '\n✓ PushPatch CLI uninstalled\n'
