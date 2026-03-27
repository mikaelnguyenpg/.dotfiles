# =============================================================================
# home.nix — Home-manager system configuration
# =============================================================================
{ pkgs, inputs, ... }:
let
  # --- CẤU HÌNH CONSTANTS Ở ĐÂY ---
  constants = import ./constants.nix;

  # --- CẤU HÌNH TIER Ở ĐÂY ---
  # Chọn: "minimal", "standard", hoặc "full"
  tier = "minimal";

  # 1. Nhóm module cơ bản (Luôn cài)
  baseModules = [
    ../../modules/eza.nix
    ../../modules/fzf.nix
    ../../modules/git.nix
    ../../modules/ssh.nix
    ../../modules/starship.nix
    ../../modules/shell.nix # File này sẽ tự lọc package bên trong
    ../../modules/zoxide.nix
    ../../modules/zsh.nix
  ];
  
  # 2. Nhóm module làm việc (Standard + Full)
  workModules = [
    ../../modules/containers.nix
    ../../modules/fonts.nix
    ../../modules/ide.nix
    ../../modules/ghostty.nix
    ../../modules/helix.nix
    ../../modules/lazyvim.nix
    ../../modules/tmux.nix
    ../../modules/zellij.nix
  ];

  # 3. Nhóm module đầy đủ (Chỉ Full)
  fullModules = [
    # ../../modules/flatpak.nix
    ../../modules/office.nix
    ../../modules/vscode.nix
    # ../../modules/nixGL.nix
    # ../../modules/ytdlp.nix
  ];
in {
  home.username = constants.username;
  home.homeDirectory = constants.homeDir;
  home.stateVersion = constants.stateVersion;
  home.packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

  imports = [
    ../../modules/containers.nix
    ../../modules/ide.nix
    ../../modules/flatpak.nix
    ../../modules/fonts.nix
    ../../modules/git.nix
    ../../modules/nixpkgs.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix
    ../../modules/shell.nix

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
