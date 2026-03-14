{ pkgs, ... }: {
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "hx";
    };
  };
}
