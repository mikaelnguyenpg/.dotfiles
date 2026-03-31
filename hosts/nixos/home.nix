# =============================================================================
# home.nix — Home-manager system configuration
# =============================================================================
{ pkgs, inputs, constants, lib, ... }:
let
  # --- CẤU HÌNH TIER Ở ĐÂY ---
  # Chọn: "minimal", "standard", hoặc "full"
  tier = "full";

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
    ../../modules/helix.nix
    ../../modules/lazyvim.nix
    ../../modules/tmux.nix
    ../../modules/zellij.nix
  ];

  # 3. Nhóm module đầy đủ (Chỉ Full)
  fullModules = [
    ../../modules/ghostty.nix
    ../../modules/ide.nix
    ../../modules/office.nix
    # ../../modules/vscode.nix
    # ../../modules/ytdlp.nix
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
  programs.git.userEmail = constants.gitEmail;
  programs.git.userName = constants.gitName;

  programs.home-manager.enable = true;
}
