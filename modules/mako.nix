{ pkgs, ... }: {
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 6;
      font = "JetBrainsMono Nerd Font 11";
    };
  };
}
