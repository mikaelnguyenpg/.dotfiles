# =============================================================================
# home.nix — Home-manager system configuration
# =============================================================================
{ pkgs, inputs, constants, lib, ... }:
let
  # --- CẤU HÌNH TIER Ở ĐÂY ---
  # Chọn: "minimal", "standard", hoặc "full"
  tier = "full";

  # Host-specific modules that are enabled only for the full tier.
  fullModules = [
    ../../modules/carbonyl.nix
    ../../modules/ghostty.nix
    ../../modules/ide.nix
    ../../modules/office.nix
    ../../modules/vscode.nix
    # ../../modules/ytdlp.nix
  ];

  # Desktop modules are independent from the CLI tier.
  hyprModules = [
    ../../modules/hyprland.nix
    ../../modules/wayle.nix
    ../../modules/rofi.nix
    ../../modules/mako.nix
    ../../modules/hypr-daemons.nix
  ];
in {
  home.username = constants.username;
  home.homeDirectory = constants.homeDir;
  home.stateVersion = constants.stateVersion;
  home.packages = [ inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # Hợp nhất các module dựa trên Tier
  imports = [ ../../modules/home/base.nix ]
    ++ (lib.optionals (tier == "standard" || tier == "full") [ ../../modules/home/work.nix ])
    ++ (lib.optionals (tier == "full") fullModules)
    ++ hyprModules;

  # Truyền biến tier xuống các module con (như shell.nix) nếu cần lọc sâu hơn
  # Chúng ta dùng "specialArgs" hoặc gán trực tiếp vào config
  # Nhưng đơn giản nhất là dùng _module.args
  _module.args = { inherit tier; };

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.settings.user.email = constants.gitEmail;
  programs.git.settings.user.name = constants.gitName;

  programs.home-manager.enable = true;

  # Tự restart các systemd --user service bị đổi sau khi switch, khỏi cần
  # logout/login lại (áp dụng cho wayle, hypridle, hyprpaper, ...)
  systemd.user.startServices = "sd-switch";
}
