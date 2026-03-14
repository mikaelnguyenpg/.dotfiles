{ pkgs, ... }: {
  home.username = "codevibe";
  home.homeDirectory = "/home/codevibe";
  home.stateVersion = "25.11";

  imports = [
    ../../modules/shell.nix
    ../../modules/git.nix
    ../../modules/tools.nix
    ../../modules/containers.nix
    ../../modules/editor.nix
  ];

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.userEmail = "you@company.com";
}
