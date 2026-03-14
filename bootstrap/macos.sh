#!/usr/bin/env bash
set -e

# Xcode CLT — tương đương build-essential, gộp luôn curl/git/make
xcode-select --install
# Những thứ còn lại nếu cần (thường macOS đã có sẵn)
brew install wget unzip gnupg

# 1. Install Nix (Determinate Systems)
if ! command -v nix &>/dev/null; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 2. Clone repo nếu chưa có
DOTFILES="$HOME/.dotfiles"
[ -d "$DOTFILES" ] || git clone https://github.com/you/dotfiles "$DOTFILES"

# 3. Gọi Make
cd "$DOTFILES" && make detect
