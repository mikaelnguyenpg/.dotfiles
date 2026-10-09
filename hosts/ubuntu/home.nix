# =============================================================================
# home.nix — Home-manager system configuration
# =============================================================================
{ pkgs, inputs, lib, ... }:
let
  # --- CẤU HÌNH CONSTANTS Ở ĐÂY ---
  constants = import ./constants.nix;

  # --- CẤU HÌNH TIER Ở ĐÂY ---
  # Chọn: "minimal", "standard", hoặc "full"
  tier = "full";

  # 1. Nhóm module cơ bản (Luôn cài)
  baseModules = [
    ../../modules/cli/eza.nix
    ../../modules/cli/fzf.nix
    ../../modules/cli/git.nix
    ../../modules/cli/ssh.nix
    ../../modules/cli/starship.nix
    ../../modules/cli/shell.nix # File này sẽ tự lọc package bên trong
    ../../modules/cli/zoxide.nix
    ../../modules/cli/zsh.nix
  ];
  
  # 2. Nhóm module làm việc (Standard + Full)
  workModules = [
    ../../modules/dev/containers.nix
    ../../modules/core/fonts.nix
    ../../modules/dev/helix.nix
    ../../modules/dev/lazyvim.nix
    ../../modules/core/nixpkgs.nix
    ../../modules/cli/tmux.nix
    ../../modules/cli/zellij.nix
  ];

  # 3. Nhóm module đầy đủ (Chỉ Full)
  fullModules = [
    ../../modules/cli/carbonyl.nix
    ../../modules/apps/ghostty.nix
    ../../modules/dev/ide.nix
    ../../modules/core/nixGL.nix
    ../../modules/dev/vscode.nix
    # ../../modules/cli/ytdlp.nix
  ];
in {
  home.username = constants.username;
  home.homeDirectory = constants.homeDir;
  home.stateVersion = constants.stateVersion;
  home.packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

  # Hợp nhất các module dựa trên Tier
  imports = baseModules
    ++ (lib.optionals (tier == "standard" || tier == "full") workModules)
    ++ (lib.optionals (tier == "full") fullModules);

  # Truyền biến tier xuống các module con (như shell.nix) nếu cần lọc sâu hơn
  # Chúng ta dùng "specialArgs" hoặc gán trực tiếp vào config
  # Nhưng đơn giản nhất là dùng _module.args
  _module.args = { inherit tier; };

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.settings.user.email = constants.gitEmail;
  programs.git.settings.user.name = constants.gitName;

  programs.home-manager.enable = true;
}
