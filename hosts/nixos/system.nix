{ pkgs, config, ... }: {
  imports = [ ./hardware-configuration.nix ];  # tự generate khi install NixOS

  # Bootloader
  boot.loader.systemd-boot.enable = true;

  # Networking
  networking.hostName = "nixos-desktop";
  networking.networkmanager.enable = true;

  # System packages (khác với home packages)
  environment.systemPackages = with pkgs; [ git vim ];

  # Flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # QEMU/KVM + libvirt
  virtualisation.libvirtd.enable = true;
  users.users.yourname.extraGroups = [ "libvirtd" "kvm" ];

  # Docker (nếu vẫn cần song song podman)
  # virtualisation.docker.enable = true;

  # home-manager tích hợp vào NixOS
  home-manager.users.yourname = import ./home.nix;
}
