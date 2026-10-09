# modules/home/desktop.nix — Hyprland desktop, độc lập với tier CLI
{ ... }: {
  imports = [
    ../desktop/hyprland.nix
    ../desktop/wayle.nix
    ../desktop/rofi.nix
    ../desktop/mako.nix
    ../desktop/hypr-daemons.nix
  ];
}
