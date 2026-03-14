#!/usr/bin/env bash
# ubuntu-extras.sh
# Cài những thứ KHÔNG quản lý được qua Nix trên Ubuntu:
#   - apt: system-level deps (libvirtd, KVM, flatpak portal)
#   - flatpak: GUI apps
#   - podman: cần thêm subuid/subgid cho rootless
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

# ─── 1. APT: system-level dependencies ───────────────────────────────────────

log "Updating apt..."
sudo apt-get update -qq

APT_PACKAGES=(
  # QEMU / KVM / libvirt
  qemu-kvm               # QEMU là phần mềm giả lập phần cứng, KVM là kernel module của Linux cho phép QEMU chạy trực tiếp trên CPU thật thay vì giả lập hoàn toàn
  libvirt-daemon-system  # Lớp quản lý ở giữa, cung cấp API thống nhất để tạo/xoá/start/stop VM mà không cần nhớ hàng chục option của QEMU
  libvirt-clients        # Bộ CLI tools để tương tác với libvirtd
  virt-manager           # GUI desktop app để quản lý VM
  bridge-utils           # Cần thiết khi muốn VM có IP riêng trên cùng mạng LAN với host (thay vì NAT)
  virtinst               # cung cấp lệnh virt-install để tạo VM từ command line, không cần mở GUI

  # Flatpak portal (cần để GUI apps hoạt động đúng)
  flatpak
  xdg-desktop-portal     # "cổng" cho phép app trong sandbox giao tiếp có kiểm soát với system bên ngoài
  xdg-desktop-portal-gtk # quyết định file dialog trông như thế nào, theme có khớp với desktop không

  # Podman rootless support
  uidmap
  slirp4netns            # Container vẫn có internet, vẫn map được port, nhưng không cần root.
  fuse-overlayfs         # Container dùng overlay filesystem để layer các image lên nhau
)

log "Installing apt packages..."
for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    skip "$pkg"
  else
    sudo apt-get install -y "$pkg" && ok "$pkg"
  fi
done

# ─── 2. KVM: thêm user vào group ─────────────────────────────────────────────

log "Configuring KVM groups..."
for group in kvm libvirt libvirt-qemu; do
  if getent group "$group" &>/dev/null; then
    if groups "$USER" | grep -q "$group"; then
      skip "user in group $group"
    else
      sudo usermod -aG "$group" "$USER" && ok "added $USER to $group"
    fi
  fi
done

# ─── 3. Podman: rootless subuid/subgid ───────────────────────────────────────

log "Configuring podman rootless..."

if grep -q "^$USER:" /etc/subuid 2>/dev/null; then
  skip "subuid already configured"
else
  sudo usermod --add-subuids 100000-165535 "$USER" && ok "subuid configured"
fi

if grep -q "^$USER:" /etc/subgid 2>/dev/null; then
  skip "subgid already configured"
else
  sudo usermod --add-subgids 100000-165535 "$USER" && ok "subgid configured"
fi

# Enable podman socket cho user (để distrobox dùng)
if systemctl --user is-enabled podman.socket &>/dev/null; then
  skip "podman.socket already enabled"
else
  systemctl --user enable --now podman.socket && ok "podman.socket enabled"
fi

# ─── 4. Flatpak: thêm Flathub remote ─────────────────────────────────────────

log "Configuring Flatpak..."
if flatpak remote-list | grep -q "flathub"; then
  skip "flathub remote already added"
else
  flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo && ok "flathub added"
fi

# ─── 5. Flatpak: install GUI apps ────────────────────────────────────────────
# Thêm/bớt app tại đây tuỳ nhu cầu

FLATPAK_APPS=(
  # Productivity
  org.gnome.Boxes              # GUI VM manager (alternative cho virt-manager)

  # Media
  org.videolan.VLC

  # Dev tools
  com.mattjakeman.ExtensionManager   # GNOME extension manager

  md.obsidian.Obsidian
  com.google.Chrome
  io.httpie.Httpie        # GUI version
  com.obsproject.Studio
  org.signal.Signal
)

log "Installing Flatpak apps..."
for app in "${FLATPAK_APPS[@]}"; do
  if flatpak list --app | grep -q "$app"; then
    skip "$app"
  else
    flatpak install -y flathub "$app" && ok "$app"
  fi
done

# ─── 6. libvirtd: enable service ─────────────────────────────────────────────

log "Enabling libvirtd..."
if systemctl is-enabled libvirtd &>/dev/null; then
  skip "libvirtd already enabled"
else
  sudo systemctl enable --now libvirtd && ok "libvirtd enabled"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}ubuntu-extras.sh done.${RESET}"
echo ""
echo "Notes:"
echo "  - Logout/login để group changes (kvm, libvirt) có hiệu lực"
echo "  - Chạy 'podman run hello-world' để verify podman rootless"
echo "  - Chạy 'virt-manager' để mở GUI VM manager"
