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

  # Fcitx5 input method
  fcitx5                 # core engine: nhận keystroke → xử lý → trả text
  fcitx5-bamboo          # plugin tiếng Việt (VNI/Telex/VIQR)
  fcitx5-chewing         # plugin tiếng Trung phồn thể
  fcitx5-frontend-gtk4   # bridge fcitx5 ↔ GTK4 apps (Firefox, GNOME apps)
  fcitx5-frontend-gtk3   # bridge fcitx5 ↔ GTK3 apps (apps cũ hơn)
  fcitx5-frontend-qt5    # bridge fcitx5 ↔ Qt5 apps
  fcitx5-config-qt       # GUI config tool: add ngôn ngữ, đổi phím tắt
  im-config              # set fcitx5 làm default input method trên Ubuntu
)

log "Installing apt packages..."
for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    skip "$pkg"
  else
    sudo apt-get install -y "$pkg" && ok "$pkg"
  fi
done

# Set fcitx5 ngay sau khi install xong
log "Setting fcitx5 as default input method..."
im-config -n fcitx5 && ok "fcitx5 set as default"

# ─── 2. KVM: thêm user vào group ─────────────────────────────────────────────

log "Configuring KVM groups..."
for group in kvm libvirt libvirt-qemu libvirtd; do
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

# Enable linger — user services chạy kể cả khi chưa login
if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
  sudo loginctl enable-linger "$USER" && ok "linger enabled"
else
  skip "linger already enabled"
fi

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

# ─── 7. storage: mount points ----─────────────────────────────────────────────
log "Configuring storage mount points..."

# Tạo mount points
sudo mkdir -p /data
sudo mkdir -p /mnt/build_cache
ok "mount points created"

# Thêm vào fstab nếu chưa có
FSTAB_DATA="UUID=b9ef6f32-d3c1-4356-8c0d-8e6ef137a830  /data  ext4  defaults  0  2"
FSTAB_CACHE="UUID=0097bbe4-2b94-411c-8286-f7e29cc833a0  /mnt/build_cache  ext4  defaults  0  2"
FSTAB_SWAP="/mnt/build_cache/swapfile  none  swap  sw  0  0"

if grep -q "b9ef6f32" /etc/fstab; then
  skip "fstab /data already configured"
else
  echo "$FSTAB_DATA" | sudo tee -a /etc/fstab && ok "fstab /data added"
fi

if grep -q "0097bbe4" /etc/fstab; then
  skip "fstab /mnt/build_cache already configured"
else
  echo "$FSTAB_CACHE" | sudo tee -a /etc/fstab && ok "fstab /mnt/build_cache added"
fi

# Mount
sudo mount -a && ok "partitions mounted"

# Swap
if [ ! -f /mnt/build_cache/swapfile ]; then
  sudo fallocate -l 50G /mnt/build_cache/swapfile
  sudo chmod 600 /mnt/build_cache/swapfile
  sudo mkswap /mnt/build_cache/swapfile
  sudo swapon /mnt/build_cache/swapfile
  ok "swapfile created"
else
  skip "swapfile already exists"
fi

if grep -q "swapfile" /etc/fstab; then
  skip "fstab swap already configured"
else
  echo "$FSTAB_SWAP" | sudo tee -a /etc/fstab && ok "fstab swap added"
fi

# Ownership
sudo chown -R "$USER:$USER" /data
sudo chown -R "$USER:$USER" /mnt/build_cache
ok "ownership configured"

# ─── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}ubuntu-extras.sh done.${RESET}"
echo ""
echo "Notes:"
echo "  - Logout/login để group changes (kvm, libvirt) có hiệu lực"
echo "  - Chạy 'podman run hello-world' để verify podman rootless"
echo "  - Chạy 'virt-manager' để mở GUI VM manager"
