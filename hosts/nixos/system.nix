# =============================================================================
# system.nix — NixOS system configuration
# =============================================================================
{ pkgs, inputs, lib, ... }:
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
    ./pritunl.nix
    ./hyprland.nix
  ];

  # ─── Home Manager ───────────────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs    = true;
    useUserPackages  = true;
    extraSpecialArgs = { inherit inputs constants; };
    users.${constants.username}.imports = [
      ./home.nix
    ];
    backupFileExtension = "backup";
  };

  # ─── System Packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
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

  environment.sessionVariables = {
   XCURSOR_THEME = "Adwaita";
   XCURSOR_SIZE = "24";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  };

  security.polkit.enable = true;

  # ─── Nix / Boot ─────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];

  # Ghi đè giá trị `true` mặc định trong /etc/nixos/configuration.nix (installer
  # tự sinh lúc cài NixOS). Lý do tắt: firmware ASUS bị bug ghi NVRAM (ENOSPC khi
  # switch qua version systemd-boot mới). Boot0000 "Linux Boot Manager" đã có sẵn
  # và đúng, tắt option này an toàn — NixOS vẫn update file /boot bình thường,
  # chỉ ngừng cố ghi/sửa EFI boot variable trong NVRAM mỗi lần rebuild.
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

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
