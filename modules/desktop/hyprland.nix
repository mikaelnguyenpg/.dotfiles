# modules/desktop/hyprland.nix
{ pkgs, ... }: {
  dconf.settings = {
   "org/gnome/desktop/interface" = {
     cursor-theme = "Adwaita";
     cursor-size = 24;
   };
  };

  # Hyprland >= 0.57 chỉ đọc config Lua (hyprland.conf bị bỏ qua, nếu không có
  # hyprland.lua nó tự sinh config mặc định -> mất hết keybind).
  # Bản hyprlang cũ để tham khảo: archive/hyprland-hyprlang.conf
  home.file.".config/hypr/hyprland.lua".source = ./hyprland.lua;
}
