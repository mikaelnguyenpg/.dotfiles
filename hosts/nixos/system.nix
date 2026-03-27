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
    ./vm.nix
    ./mount.nix
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
        fcitx5-bamboo                     # bamboo
        fcitx5-chewing                    # chewing
        qt6Packages.fcitx5-chinese-addons # pinyin
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
