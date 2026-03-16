{ ... }:

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
    };

    packages = builtins.filter
      (l: l != "" && builtins.match "^#.*" l == null)
      (builtins.filter builtins.isString
        (builtins.split "\n"
          (builtins.readFile ../flatpak-apps.txt)));
  };
}
