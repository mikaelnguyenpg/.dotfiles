{ pkgs, inputs, ... }: {
  home.username = "codevibe";
  home.homeDirectory = "/home/codevibe";
  home.stateVersion = "25.11";
  home.packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../modules/dev/containers.nix
    ../../modules/cli/eza.nix
    ../../modules/cli/fzf.nix
    ../../modules/cli/git.nix
    ../../modules/cli/shell.nix
    ../../modules/cli/ssh.nix
    ../../modules/cli/starship.nix
    ../../modules/cli/zoxide.nix
    ../../modules/cli/zsh.nix
  ];

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.userEmail = "mikaelnguyen.pg@work.com";
  programs.git.userName = "mikaelnguyenpg";

  programs.home-manager.enable = true;
}
