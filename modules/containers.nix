{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    lima
    podman-compose
    distrobox        # Linux only, macOS sẽ ignore nếu không có
    lazydocker
    # docker compat wrapper — tạo symlink docker → podman
    (pkgs.runCommand "docker-compat" {} ''
      mkdir -p $out/bin
      ln -s ${pkgs.podman}/bin/podman $out/bin/docker
      ln -s ${pkgs.podman-compose}/bin/podman-compose $out/bin/docker-compose
    '')
  ];

  xdg.configFile."containers/policy.json".text = builtins.toJSON {
    default = [{ type = "insecureAcceptAnything"; }];
  };

  xdg.configFile."containers/registries.conf".text = ''
    [registries.search]
    registries = ["docker.io", "ghcr.io", "quay.io"]
  '';

  # ── Chuyển podman storage sang /mnt/build_cache ───────────────────────────
  xdg.configFile."containers/storage.conf".text = ''
    [storage]
    driver    = "overlay"
    graphRoot = "/mnt/build_cache/containers/storage"
    runRoot   = "/run/user/1000/containers"

    [storage.options]
    size = ""
  '';

  # home.activation.setupPodmanStorage =
  #   config.lib.dag.entryAfter [ "writeBoundary" ] ''
  #     mkdir -p /mnt/build_cache/containers/storage
  #     mkdir -p /mnt/build_cache/containers/cache

  #     # ── storage ────────────────────────────────────────────────────
  #     STORAGE="$HOME/.local/share/containers/storage"
  #     if [ ! -L "$STORAGE" ]; then
  #       if [ -d "$STORAGE" ]; then
  #         echo "Copying podman storage to /mnt/build_cache..."
  #         cp -a "$STORAGE/." /mnt/build_cache/containers/storage/
  #         rm -rf "$STORAGE"
  #       fi
  #       ln -s /mnt/build_cache/containers/storage "$STORAGE"
  #       echo "podman storage symlink created"
  #     fi

  #     # ── cache ──────────────────────────────────────────────────────
  #     CACHE="$HOME/.local/share/containers/cache"
  #     if [ ! -L "$CACHE" ]; then
  #       if [ -d "$CACHE" ]; then
  #         cp -a "$CACHE/." /mnt/build_cache/containers/cache/ 2>/dev/null || true
  #         rm -rf "$CACHE"
  #       fi
  #       ln -s /mnt/build_cache/containers/cache "$CACHE"
  #       echo "podman cache symlink created"
  #     fi
  #   '';

  home.activation.setupPodmanStorage =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p /mnt/build_cache/containers/storage
      mkdir -p /mnt/build_cache/containers/cache

      # Chỉ tạo symlink — KHÔNG copy, KHÔNG mv
      # Migration thủ công đã làm trước rồi
      STORAGE="$HOME/.local/share/containers/storage"
      if [ ! -L "$STORAGE" ] && [ ! -e "$STORAGE" ]; then
        mkdir -p "$(dirname "$STORAGE")"
        ln -s /mnt/build_cache/containers/storage "$STORAGE"
      fi

      CACHE="$HOME/.local/share/containers/cache"
      if [ ! -L "$CACHE" ] && [ ! -e "$CACHE" ]; then
        mkdir -p "$(dirname "$CACHE")"
        ln -s /mnt/build_cache/containers/cache "$CACHE"
      fi
    '';

  services.podman.enable = true;
}

# # ── Podman images ────────────────────────────────
# # 1. Dừng tất cả containers
# podman stop --all

# # 2. Tạo thư mục đích
# mkdir -p /mnt/build_cache/containers/storage
# mkdir -p /mnt/build_cache/containers/cache

# # 3. Copy với sudo để vượt qua permission
# sudo cp -a ~/.local/share/containers/storage/. \
#           /mnt/build_cache/containers/storage/

# sudo cp -a ~/.local/share/containers/cache/. \
#           /mnt/build_cache/containers/cache/ 2>/dev/null || true

# # 4. Xóa thư mục cũ và tạo symlink
# rm -rf ~/.local/share/containers/storage
# rm -rf ~/.local/share/containers/cache

# ln -s /mnt/build_cache/containers/storage \
#       ~/.local/share/containers/storage

# ln -s /mnt/build_cache/containers/cache \
#       ~/.local/share/containers/cache

# # 5. Verify
# ls -la ~/.local/share/containers/
# podman info | grep graphRoot
