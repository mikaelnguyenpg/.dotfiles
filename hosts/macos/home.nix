{ pkgs, inputs, ... }: {
  home.username = "codevibe";
  home.homeDirectory = "/home/codevibe";
  home.stateVersion = "25.11";
  home.packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../modules/containers.nix
    ../../modules/eza.nix
    ../../modules/fzf.nix
    ../../modules/git.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix
    ../../modules/starship.nix
    ../../modules/zoxide.nix
    ../../modules/zsh.nix
  ];

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.userEmail = "mikaelnguyen.pg@work.com";
  programs.git.userName = "mikaelnguyenpg";

  programs.home-manager.enable = true;
}
