{ pkgs, ... }: {
  home.username = "codevibe";
  home.homeDirectory = "/home/codevibe";
  home.stateVersion = "25.11";

  imports = [
    ../../modules/apps.nix
    ../../modules/containers.nix
    ../../modules/editor.nix
    ../../modules/git.nix
    ../../modules/shell.nix
    ../../modules/tools.nix
  ];

  # Agenix decrypt key vào đúng chỗ
  age.secrets.ssh-personal = {
    file = ../../secrets/ssh-personal.age;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  # Chỗ này là config RIÊNG của máy ubuntu-work
  # ví dụ: git email công việc khác với máy cá nhân
  programs.git.userEmail = "mikaelnguyen.pg@gmail.com";
  programs.git.userName = "mikaelnguyenpg";

  programs.home-manager.enable = true;
}
