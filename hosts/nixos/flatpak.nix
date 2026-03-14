{ config, pkgs, ... }:

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

    packages = [
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
    ];
  };
}
