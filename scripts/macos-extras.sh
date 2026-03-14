#!/usr/bin/env bash
# macos-extras.sh
# Cài những thứ KHÔNG quản lý được qua home-manager trên macOS:
#   - Homebrew (nếu chưa có, dù nix-darwin có thể quản lý brew)
#   - brew casks: GUI apps (UTM, thay Flatpak)
#   - lima: Linux distro environment
#   - podman machine: Linux VM nhẹ để chạy container
#   - macOS system settings
#
# Idempotent: chạy nhiều lần không bị lỗi

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

log()  { echo -e "${BOLD}==>${RESET} $1"; }
ok()   { echo -e "${GREEN}  ✓${RESET} $1"; }
skip() { echo -e "${YELLOW}  ~${RESET} $1 (already done)"; }

# ─── 1. Homebrew ─────────────────────────────────────────────────────────────
# Nếu dùng nix-darwin với homebrew.enable = true thì section này tự động
# Để ở đây làm fallback nếu chạy standalone (không qua darwin-rebuild)

log "Checking Homebrew..."
if command -v brew &>/dev/null; then
  skip "homebrew already installed"
else
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "homebrew installed"
fi

# ─── 2. Brew casks: GUI apps ─────────────────────────────────────────────────
# Nếu đã khai báo trong darwin.nix homebrew.casks thì bỏ qua section này
# Để ở đây làm fallback / reference

CASKS=(
  utm          # GUI VM (thay QEMU/KVM + virt-manager trên Linux)
)

log "Installing brew casks..."
for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    skip "$cask"
  else
    brew install --cask "$cask" && ok "$cask"
  fi
done

# ─── 3. Lima: Linux distro environment ───────────────────────────────────────
# Lima = lightweight Linux VM trên macOS
# Tương đương distrobox trên Linux

log "Checking lima..."
if command -v limactl &>/dev/null; then
  skip "lima already installed (via Nix home-manager)"
else
  brew install lima && ok "lima installed"
fi

# Tạo default Ubuntu instance nếu chưa có
if limactl list 2>/dev/null | grep -q "^default"; then
  skip "lima default instance already exists"
else
  log "Creating lima default instance (Ubuntu)..."
  limactl start --name=default template://ubuntu && ok "lima default created"
fi

# ─── 4. Podman machine ───────────────────────────────────────────────────────
# macOS không có Linux kernel → podman cần VM nhẹ để chạy container
# podman binary được quản lý bởi home-manager (modules/containers.nix)
# nhưng 'podman machine' cần khởi tạo một lần

log "Checking podman machine..."
if command -v podman &>/dev/null; then
  if podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
    skip "podman machine already initialized"
  else
    log "Initializing podman machine..."
    podman machine init && ok "podman machine initialized"
    podman machine start && ok "podman machine started"
    # Auto-start khi login
    podman machine start --help | grep -q "\-\-now" || true
  fi
else
  echo "  ! podman not found — make sure home-manager switch ran first"
fi

# ─── 5. macOS system settings ────────────────────────────────────────────────
# Nếu đã khai báo trong darwin.nix system.defaults thì bỏ qua
# Để ở đây làm fallback / reference

log "Applying macOS system settings..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
ok "dock settings"

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"  # list view
ok "finder settings"

# Keyboard
defaults write -g ApplePressAndHoldEnabled -bool false   # key repeat thay vì accent menu
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
ok "keyboard settings"

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"
ok "screenshot settings"

# Restart Dock để apply
killall Dock 2>/dev/null || true

# ─── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}macos-extras.sh done.${RESET}"
echo ""
echo "Notes:"
echo "  - UTM: mở từ Applications để tạo GUI VM"
echo "  - lima: 'limactl shell default' để vào Ubuntu environment"
echo "  - podman: 'podman run hello-world' để verify"
echo "  - Một số macOS settings cần logout/login để có hiệu lực"
