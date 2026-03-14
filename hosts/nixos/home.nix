{ pkgs, inputs, ... }: {
  home.username = "codevibe";
  home.homeDirectory = "/home/codevibe";
  home.stateVersion = "25.11";
  home.packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

  imports = [
    ../../modules/apps.nix
    ../../modules/containers.nix
    ../../modules/editor.nix
    ../../modules/flatpak.nix
    ../../modules/git.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix
    ../../modules/tools.nix
  ];

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.userEmail = "mikaelnguyen.pg@gmail.com";
  programs.git.userName = "mikaelnguyenpg";

  programs.home-manager.enable = true;
}
