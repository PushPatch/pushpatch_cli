# PushPatch CLI

Command-line tool for managing **over-the-air (OTA) updates** for Flutter apps
against a self-hosted [PushPatch](https://pushpatch.in) server — releases,
patches, staged rollouts, channels and rollback.

> This repository hosts the **installers and release binaries** only. Download a
> prebuilt, hardened binary below — no build required.

## Install

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/install.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/install.ps1 | iex
```

The script detects your OS/architecture, downloads the matching archive from the
[Releases](https://github.com/PushPatch/pushpatch_cli/releases), verifies its
SHA-256, and installs the `pushpatch` binary.

### Package managers

```bash
# Homebrew (macOS / Linux)
brew install pushpatch/tap/pushpatch

# Chocolatey (Windows)
choco install pushpatch

# Winget (Windows)
winget install PushPatch.PushPatch
```

### Manual download

Grab the archive for your platform from the
[latest release](https://github.com/PushPatch/pushpatch_cli/releases/latest):

| Platform | Asset |
|----------|-------|
| macOS (Apple Silicon) | `pushpatch-<version>-aarch64-apple-darwin.tar.gz` |
| macOS (Intel) | `pushpatch-<version>-x86_64-apple-darwin.tar.gz` |
| Linux (x86_64) | `pushpatch-<version>-x86_64-unknown-linux-gnu.tar.gz` |
| Linux (arm64) | `pushpatch-<version>-aarch64-unknown-linux-gnu.tar.gz` |
| Windows (x86_64) | `pushpatch-<version>-x86_64-pc-windows-msvc.zip` |

Each archive has a `.sha256` sibling for verification:
```bash
shasum -a 256 -c pushpatch-<version>-<target>.tar.gz.sha256
```

## Quick start

```bash
pushpatch login                              # prompts for server URL + credentials
cd my_flutter_app
pushpatch init                               # writes shorebird.yaml + pubspec asset
pushpatch doctor                             # verify environment
pushpatch release android --flavor prod
pushpatch patch android --release-version 1.0.0+1 --channel beta
pushpatch patch list
pushpatch patch promote --number 3 --channel stable --rollout 25
pushpatch status
```

Run `pushpatch <command> --help` for full options. Keep the CLI up to date with
`pushpatch upgrade`.

## Uninstall

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/uninstall.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/PushPatch/pushpatch_cli/main/uninstall.ps1 | iex
```

This removes the `pushpatch` binary, clears stored credentials, and deletes the
`~/.pushpatch` config/cache directory. To keep your config, set
`PUSHPATCH_KEEP_CONFIG=1` (shell) or pass `-KeepConfig` (PowerShell).

If you installed via a package manager, uninstall there instead:

```bash
brew uninstall pushpatch                  # Homebrew
choco uninstall pushpatch                 # Chocolatey
winget uninstall PushPatch.PushPatch      # Winget
```

## Verifying a download

Binaries are stripped and hardened. To confirm integrity, compare the published
checksum against your download (the installer does this automatically):

```bash
pushpatch version    # prints the running binary's SHA-256 prefix
```

## License

MIT — see [LICENSE](LICENSE).
