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

# flatpak override --user com.google.Chrome --filesystem=/nix/store:ro
# flatpak override --user com.google.Chrome --filesystem=/run/current-system/sw/share/X11/fonts:ro

# fc-cache -f -v trong Flatpak sandbox

# rm -rf ~/.var/app/com.google.Chrome/cache/fontconfig/
# rm -rf ~/.var/app/com.google.Chrome/.cache/fontconfig/

# flatpak run --command=fc-cache com.google.Chrome -f
