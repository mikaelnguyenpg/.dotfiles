# modules/home/user.nix — thông tin user, lấy từ hosts/<host>/constants.nix
# (truyền vào qua extraSpecialArgs.constants)
{ pkgs, inputs, constants, ... }: {
  home.username      = constants.username;
  home.homeDirectory = constants.homeDir;
  home.stateVersion  = constants.stateVersion;

  programs.git.settings.user.email = constants.gitEmail;
  programs.git.settings.user.name  = constants.gitName;

  programs.home-manager.enable = true;
  home.packages = [ inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
