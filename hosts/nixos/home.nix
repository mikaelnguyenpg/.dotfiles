{ pkgs, inputs, constants, ... }: {
  home.username = constants.username;
  home.homeDirectory = constants.homeDir;
  home.stateVersion = constants.stateVersion;
  home.packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

  imports = [
    ../../modules/containers.nix
    ../../modules/editor.nix
    ../../modules/flatpak.nix
    ../../modules/fonts.nix
    ../../modules/git.nix
    ../../modules/nixpkgs.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix
    ../../modules/tools.nix

    ../../modules/eza.nix
    # ../../modules/flatpak.nix
    ../../modules/fzf.nix
    ../../modules/git.nix
    ../../modules/ghostty.nix
    ../../modules/helix.nix
    ../../modules/lazyvim.nix
    # ../../modules/nixGL.nix
    ../../modules/starship.nix
    ../../modules/tmux.nix
    ../../modules/vscode.nix
    # ../../modules/ytdlp.nix
    ../../modules/zoxide.nix
    ../../modules/zsh.nix
    ../../modules/zellij.nix
  ];

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.userEmail = constants.gitEmail;
  programs.git.userName = constants.gitName;

  programs.home-manager.enable = true;
}
