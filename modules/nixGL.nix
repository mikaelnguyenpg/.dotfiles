# modules/nixGL.nix
{ config, pkgs, nixgl, ... }:

{
  # Cấu hình nixGL cho Non-NixOS (Ubuntu)
  targets.genericLinux.enable = true;

  # Cấu hình wrapper
  nixGL = {
    packages = nixgl.packages.${pkgs.system};
    # Before install Nvidia-driver
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    # After install Nvidia-driver
    # defaultWrapper = "nvidia";
    # installScripts = [ "nvidia" ];
  };
}
