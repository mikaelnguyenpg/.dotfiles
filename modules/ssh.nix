{ pkgs, config, ... }: {
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";   # tự add key vào ssh-agent khi dùng
      };
      "github.com" = {
        hostname = "github.com";
        user     = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
