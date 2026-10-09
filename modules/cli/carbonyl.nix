{ config, pkgs, lib, ... }:

let
  # Carbonyl chưa có trong nixpkgs. Binary release (Chromium 2023) bị crash (SIGTRAP)
  # khi chạy trên glibc mới của NixOS -> chạy qua image chính thức bằng podman.
  # Cần podman (đã bật trong hosts/nixos/vm.nix).
  carbonyl = pkgs.writeShellScriptBin "carbonyl" ''
    exec podman run --rm -it \
      -e TERM -e COLORTERM \
      docker.io/fathyb/carbonyl "$@"
  '';
in
{
  home.packages = [ carbonyl ];
}
