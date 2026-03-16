{ pkgs, inputs, ... }:
let
  constants = import ./constants.nix;
in {

  # ─── Imports ────────────────────────────────────────────────────────────────
  imports = [
    /etc/nixos/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ./vm.nix
    ./flatpak.nix
    ./storage.nix
  ];

  # ─── Home Manager ───────────────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs    = true;
    useUserPackages  = true;
    extraSpecialArgs = { inherit inputs constants; };
    users.${constants.username}.imports = [
      ./home.nix
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ];
  };

  # ─── System Packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    cacert    # ca-certificates
    curl
    gcc
    git
    gnumake   # make
    gnupg
    unzip
    wget
  ];

  # ─── Services ───────────────────────────────────────────────────────────────
  services.openssh.enable = true;

  # ─── Input Method ───────────────────────────────────────────────────────────
  i18n.inputMethod = {
    enable = true;
    type   = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-bamboo
        fcitx5-chewing
        fcitx5-gtk
        qt6Packages.fcitx5-qt
        qt6Packages.fcitx5-configtool
      ];
    };
  };

  # ─── Nix / Boot ─────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.configurationLimit = 5;

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  nix.settings.auto-optimise-store = true;
}
