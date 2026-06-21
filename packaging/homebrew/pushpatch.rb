# Homebrew formula template for the PushPatch CLI.
#
# Publish to a tap (e.g. pushpatch/homebrew-tap) and have the release workflow
# substitute the version + sha256 placeholders for each platform asset.
#
#   brew tap pushpatch/tap
#   brew install pushpatch
class Pushpatch < Formula
  desc "Self-hostable OTA update management CLI for Flutter apps"
  homepage "https://pushpatch.in"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/pushpatch/pushpatch_cli/releases/download/v#{version}/pushpatch-#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "REPLACE_WITH_AARCH64_DARWIN_SHA256"
    end
    on_intel do
      url "https://github.com/pushpatch/pushpatch_cli/releases/download/v#{version}/pushpatch-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "REPLACE_WITH_X86_64_DARWIN_SHA256"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/pushpatch/pushpatch_cli/releases/download/v#{version}/pushpatch-#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "REPLACE_WITH_X86_64_LINUX_SHA256"
    end
    on_arm do
      url "https://github.com/pushpatch/pushpatch_cli/releases/download/v#{version}/pushpatch-#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "REPLACE_WITH_AARCH64_LINUX_SHA256"
    end
  end

  def install
    bin.install "pushpatch"
  end

  test do
    assert_match "pushpatch #{version}", shell_output("#{bin}/pushpatch version")
  end
end
