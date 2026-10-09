{ ... }: {
  imports = [
    ../dev/containers.nix
    ../core/fonts.nix
    ../dev/helix.nix
    ../dev/lazyvim.nix
    ../cli/tmux.nix
    ../cli/zellij.nix
  ];
}