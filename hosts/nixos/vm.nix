# =============================================================================
# hosts/nixos/vm.nix — Local AI Stack (Ollama + Open WebUI)
# =============================================================================
{ pkgs, constants, ... }:
let
  constants = import ./constants.nix;
in
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  users.users.${constants.username} = {
    extraGroups = [ "libvirtd" "kvm" ];
  };
}
