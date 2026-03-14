{ pkgs, config, inputs, ... }: {
  imports = [ 
    # Import cấu hình cũ của hệ thống
    # ./configuration.nix
    /etc/nixos/configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

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
        inputs.agenix.homeManagerModules.default # Aginex cho user
      ];
    };
  };

  # Các thiết lập "thêm vào" của bạn ở đây
  environment.systemPackages = with pkgs; [ 
    wl-clipboard
    xclip
  ];

  # Nếu configuration.nix cũ đã có users.users.codevibe, 
  # thì khai báo ở đây sẽ bổ sung thêm (ví dụ thêm group)
  users.users.codevibe = {
    extraGroups = [ "libvirtd" "kvm" ]; 
  };
}
