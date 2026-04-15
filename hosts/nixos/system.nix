# =============================================================================
# system.nix — NixOS system configuration
# =============================================================================
{ pkgs, inputs, ... }:
let
  constants = import ./constants.nix;
in {

  # ─── Imports ────────────────────────────────────────────────────────────────
  imports = [
    /etc/nixos/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ./mount.nix
    ./vm.nix
    ./keyboard.nix
    ./ollama.nix
  ];

  # ─── Home Manager ───────────────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs    = true;
    useUserPackages  = true;
    extraSpecialArgs = { inherit inputs constants; };
    users.${constants.username}.imports = [
      ./home.nix
    ];
  };

  # ─── System Packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    cacert            # ca-certificates
    curl
    gcc
    git
    gnumake           # make
    gnupg
    unzip
    wget
    flameshot         # Screenshot + annotate
    crow-translate    # GUI translate (Google/Yandex), tray icon
    # goldendict-ng   # Popup: copy → auto dịch (StarDict)
  ];

  # ─── Services ───────────────────────────────────────────────────────────────
  services.dbus.enable = true;
  services.openssh.enable = true;
  programs.dconf.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ─── Nix / Boot ─────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.configurationLimit = 3;

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 3d";
  };

  nix.settings.auto-optimise-store = true;

  # ─── Nix-ld ─────────────────────────────────────────────────────────────────
  # to let external plugin/extension(of Cursor/VSCode/...) can run
  programs.nix-ld.enable = true;
}

# programs.zsh.shellAliases = {
#   rebuild-system            = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
#   rebuild-home-first-time   = "nix run home-manager/master -- switch --flake /etc/nixos#michael";
#   rebuild-home              = "home-manager switch --flake /etc/nixos#michael --impure";
#   rebuild-all               = "sudo nixos-rebuild switch --flake /etc/nixos#nixos && home-manager switch --flake /etc/nixos#michael";
# };
#
# sudo nix-collect-garbage -d
