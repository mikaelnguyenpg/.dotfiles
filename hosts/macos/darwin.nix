# =============================================================================
# darwin.nix — MacOS system configuration
# =============================================================================
{ pkgs, inputs, ... }:
let
  constants = import ./constants.nix;
in {
  nixpkgs.hostPlatform = constants.system;

  # nix-darwin mới bắt buộc khai báo user chính (dùng cho homebrew, system.defaults)
  system.primaryUser = constants.username;
  users.users.${constants.username}.home = constants.homeDir;

  # Homebrew casks = GUI apps (thay Flatpak)
  homebrew = {
    enable = true;
    casks = [
      "utm"           # GUI VM
      "wezterm"       # terminal (nếu không dùng bản Nix)
    ];
    brews = [];       # CLI qua brew, thường để trống vì Nix làm tốt hơn
  };

  # macOS system defaults
  system.defaults = {
    dock.autohide = true;
    finder.ShowPathbar = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
  };

  # Fonts
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  # home-manager tích hợp vào nix-darwin
  home-manager = {
    extraSpecialArgs = { inherit inputs constants; };
    users.${constants.username} = import ./home.nix;
  };

  system.stateVersion = 4;
}
