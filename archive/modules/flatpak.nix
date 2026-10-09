{ config, ... }:

{
  services.flatpak = {
    enable = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly"; # hoặc "daily"
    };

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Override permissions
    overrides = {
      global = {
        filesystems = {
          "/nix/store" = "ro";
        };
      };

      "org.gnome.Boxes" = {
        filesystems = {
          "/mnt/build_cache/gnome-boxes" = "create";
        };
      };
    };

    packages = builtins.filter
      (l: l != "" && builtins.match "^#.*" l == null)
      (builtins.filter builtins.isString
        (builtins.split "\n"
          (builtins.readFile ../flatpak-apps.txt)));
  };

  home.activation.setupBoxesStorage =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p /mnt/build_cache/gnome-boxes/images

      BOXES_IMAGES="$HOME/.var/app/org.gnome.Boxes/data/gnome-boxes/images"
      mkdir -p "$(dirname "$BOXES_IMAGES")"

      if [ ! -L "$BOXES_IMAGES" ]; then
        if [ -d "$BOXES_IMAGES" ]; then
          mv "$BOXES_IMAGES"/* /mnt/build_cache/gnome-boxes/images/ 2>/dev/null || true
          rmdir "$BOXES_IMAGES"
        fi
        ln -s /mnt/build_cache/gnome-boxes/images "$BOXES_IMAGES"
      fi
    '';
}

# # ── Flatpak Chrome Chinese Fonts ────────────────────────────────
# flatpak override --user com.google.Chrome --filesystem=/nix/store:ro
# flatpak override --user com.google.Chrome --filesystem=/run/current-system/sw/share/X11/fonts:ro

# fc-cache -f -v trong Flatpak sandbox

# rm -rf ~/.var/app/com.google.Chrome/cache/fontconfig/
# rm -rf ~/.var/app/com.google.Chrome/.cache/fontconfig/

# flatpak run --command=fc-cache com.google.Chrome -f


# # ── Flatpak Boxes images ─────────────────────────────────────────
# # 1. Dừng tất cả VM trong Boxes trước

# # 2. Tạo thư mục đích
# mkdir -p /mnt/build_cache/gnome-boxes/images

# # 3. Move data hiện tại
# mv ~/.var/app/org.gnome.Boxes/data/gnome-boxes/images/* \
#    /mnt/build_cache/gnome-boxes/images/ 2>/dev/null || true

# # 4. Xóa thư mục cũ, tạo symlink
# rmdir ~/.var/app/org.gnome.Boxes/data/gnome-boxes/images
# ln -s /mnt/build_cache/gnome-boxes/images \
#       ~/.var/app/org.gnome.Boxes/data/gnome-boxes/images

# # 5. Verify
# ls -la ~/.var/app/org.gnome.Boxes/data/gnome-boxes/images
# # phải thấy: images -> /mnt/build_cache/gnome-boxes/images

# # 6. Và cho phép Boxes Flatpak access path đó:
# flatpak override --user org.gnome.Boxes \
#   --filesystem=/mnt/build_cache/gnome-boxes:create

# # Bước 1: Gỡ bỏ các App và Runtimes (Lệnh CLI)
# flatpak uninstall --all
# flatpak uninstall --unused
# rm -rf ~/.local/share/flatpak
# sudo rm -rf /var/lib/flatpak
# # Bước 2: Xóa bỏ dữ liệu ứng dụng (Dọn rác trong $HOME)
# rm -rf ~/.var/app/*

