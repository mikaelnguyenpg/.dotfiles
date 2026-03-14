{ pkgs, ... }: {
  services.podman = {               # ← đây là home-manager module
    enable = true;                  # enable podman service + socket
  };

  home.packages = with pkgs; [
    podman-compose
    distrobox        # Linux only, macOS sẽ ignore nếu không có
    # docker compat wrapper — tạo symlink docker → podman
    (pkgs.runCommand "docker-compat" {} ''
      mkdir -p $out/bin
      ln -s ${pkgs.podman}/bin/podman $out/bin/docker
      ln -s ${pkgs.podman-compose}/bin/podman-compose $out/bin/docker-compose
    '')
  ];

  # xdg.configFile."containers/registries.conf".text = ''
  #   [registries.search]
  #   registries = ["docker.io", "ghcr.io", "quay.io"]
  # '';
}
