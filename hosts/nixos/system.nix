{ pkgs, config, inputs, ... }: {
  imports = [ 
    # Import cấu hình cũ của hệ thống
    /etc/nixos/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ./vm.nix
    ./flatpak.nix
  ];

  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh = {
    enable = true;
  };

  # Cấu hình Home Manager ngay trong system
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.codevibe = {
      imports = [ 
        ./home.nix 
      ];
    };
  };

  # Các thiết lập "thêm vào" của bạn ở đây
  environment.systemPackages = with pkgs; [ 
    curl
    git
    wget
    unzip
    gcc
    gnumake        # make
    gnupg
    cacert         # ca-certificates
  ];

  # fcitx5 system-level — NixOS quản lý hoàn toàn
  i18n.inputMethod = {
    enable = true;
    type   = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;   # bắt buộc cho Wayland
      addons = with pkgs; [
        fcitx5-bamboo
        fcitx5-chewing
        fcitx5-gtk
        qt6Packages.fcitx5-qt
        qt6Packages.fcitx5-configtool
      ];
    };
  };
}
