{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";   # tự add key vào ssh-agent khi dùng

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user     = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
