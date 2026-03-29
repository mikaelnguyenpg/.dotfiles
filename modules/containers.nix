# modules/containers.nix
{ pkgs, config, ... }:

let
  # docker → podman compat symlinks
  dockerCompat = pkgs.runCommand "docker-compat" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.podman}/bin/podman          $out/bin/docker
    ln -s ${pkgs.podman-compose}/bin/podman-compose $out/bin/docker-compose
  '';

  buildCache = "/mnt/build_cache/containers";
in {

  # ─── Packages ───────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    lima
    podman-compose
    distrobox
    lazydocker
    dockerCompat
  ];

  # ─── Podman config ──────────────────────────────────────────────────────────
  xdg.configFile = {
    "containers/policy.json".text = builtins.toJSON {
      default = [{ type = "insecureAcceptAnything"; }];
    };

    "containers/registries.conf".text = ''
      [registries.search]
      registries = ["docker.io", "ghcr.io", "quay.io"]
    '';

    "containers/storage.conf".text = ''
      [storage]
      driver    = "overlay"
      graphRoot = "${buildCache}/storage"
      runRoot   = "/run/user/1000/containers"

      [storage.options]
      size = ""
    '';

    # ─── Distrobox config ────────────────────────────────────────────────────
    "distrobox/distrobox.conf".text = ''
      DBX_CONTAINER_HOME_PREFIX=$HOME/.distrobox
    '';
  };

  # ─── Podman storage → /mnt/build_cache ──────────────────────────────────────
  home.activation.setupPodmanStorage =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${buildCache}/storage
      mkdir -p ${buildCache}/cache

      _symlink() {
        local target="$1" link="$2"
        if [ ! -L "$link" ] && [ ! -e "$link" ]; then
          mkdir -p "$(dirname "$link")"
          ln -s "$target" "$link"
        fi
      }

      _symlink "${buildCache}/storage" "$HOME/.local/share/containers/storage"
      _symlink "${buildCache}/cache"   "$HOME/.local/share/containers/cache"
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
