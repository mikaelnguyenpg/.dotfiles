{ config, pkgs, lib, nixGL, ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    # QUAN TRỌNG: Bảo Ghostty dùng bản đã wrap nixGL thay vì bản gốc
    package = config.lib.nixGL.wrap pkgs.ghostty; 

    settings = {
       # --- Giao diện ---
       theme = "TokyoNight"; # Hoặc tên bất kỳ bạn tìm thấy trong ghostty +list-themes
       background-opacity = 0.85;
       background-blur-radius = 20;
  
       # --- Font chữ ---
       font-family = "JetBrainsMono Nerd Font";
       font-size = 12;
  
       # --- Cursor ---
       cursor-style = "block";
       cursor-style-blink = true;
  
       # --- Cửa sổ ---
       window-decoration = false;
       window-height = 40;
       window-width = 120;
       window-padding-x = 10;
       window-padding-y = 10;
       copy-on-select = true;
  
       # --- Lệnh khởi chạy ---
       command = "${pkgs.zsh}/bin/zsh --login";
  
       # --- Phím tắt ---
       keybind = [
         "ctrl+shift+t=new_tab"
         "ctrl+shift+w=close_surface"
      ];
    };
  };
}
