{ pkgs, config, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        addKeysToAgent = "yes";   # tự add key vào ssh-agent khi dùng
      };
      # "github.com" = {
      #   hostname = "github.com";
      #   user     = "git";
      #   identityFile = "~/.ssh/id_ed25519";
      # };
      "github.com-mikael" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
      "github.com-michael" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_michael";
      };
      "gitlab.com-michael" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_michael";
      };
    };
  };
}
