# modules/wayle.nix
# HyprPanel is archived (2026-04-27); upstream migrated to Wayle
# (https://wayle.app). Wayle's `services.wayle` home-manager module manages
# its own systemd user service, so no exec-once needed in hyprland.conf.
{ ... }: {
  services.wayle = {
    enable = true;
    autoInstallDependencies = true;
    settings = {
      # bar.layout phải là MẢNG các layout theo từng monitor (schema: BarLayout[]),
      # và tên module đúng theo BarModule enum (vd: "hyprland-workspaces", không phải "workspaces").
      bar.layout = [
        {
          left = [ "hyprland-workspaces" ];
          center = [ "clock" ];
          right = [ "media" "microphone" "volume" "network" "bluetooth" "battery" "dashboard" ];
        }
      ];
      modules = {
        clock.format = "%H:%M";
        # Default (loginctl lock-session / terminate-session) cần 1 trình lắng
        # nghe D-Bus signal từ logind mà Hyprland không có sẵn (GNOME thì có
        # gnome-shell làm việc này) nên bấm không có tác dụng. Đổi sang đúng
        # lệnh mà keybind $mod+SHIFT+L / $mod+SHIFT+E trong hyprland.conf đang
        # dùng và đã biết chắc hoạt động.
        dashboard = {
          dropdown-lock-command = "hyprlock";
          dropdown-logout-command = "hyprctl dispatch exit";
        };
      };
    };
  };
}
