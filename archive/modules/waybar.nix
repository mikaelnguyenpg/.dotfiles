{ pkgs, ... }: {
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "disk" "battery" "tray" "clock" ];

      "clock".format = "{:%H:%M}";
      "clock".tooltip-format = "{calendar}";
      "clock".calendar = {
       mode = "month";
       format = { today = "<b><u>{}</u></b>"; };
      };
      "cpu".format = "CPU: {usage}%";
      "cpu".interval = 5;
      "memory".format = "Mem: {used:0.2f}GiB";
      "memory".interval = 5;
      "disk".format = "Disk: {used}";
      "disk".path = "/";
      "disk".interval = 30;
      "battery".format = "{capacity}%  {icon}";
      "network".format-wifi = "Online";
      "network".format-ethernet = "Online";
      "network".format-disconnected = "Offline";
      "network".on-click = "nm-connection-editor";
      "pulseaudio".format = "{volume}%  ";
      "pulseaudio".on-click = "pavucontrol";
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.75);
        border-radius: 12px;
        margin: 6px 10px;
        color: #cdd6f4;
      }

      #workspaces {
        background: transparent;
        margin: 4px 0 4px 8px;
        padding: 0 4px;
      }

      #workspaces button {
        color: #6c7086;
        padding: 0 6px;
        margin: 0 1px;
        border-radius: 8px;
        background: transparent;
      }

      #workspaces button.active {
        color: #1e1e2e;
        background: #cba6f7;
        font-weight: bold;
      }

      #workspaces button:hover {
        background: #313244;
        color: #cdd6f4;
      }

      #pulseaudio,
      #network,
      #cpu,
      #memory,
      #disk,
      #battery,
      #tray,
      #clock {
        padding: 0 10px;
        margin: 4px 3px;
        border-radius: 8px;
        background: #313244;
        color: #cdd6f4;
      }

      #network { color: #89b4fa; }
      #cpu { color: #a6e3a1; }
      #memory { color: #cba6f7; }
      #disk { color: #fab387; }
      #battery { color: #f9e2af; }
      #battery.warning { color: #f38ba8; }
      #pulseaudio { color: #f5c2e7; }

      #clock {
        color: #94e2d5;
        margin-right: 8px;
        font-weight: bold;
      }

      #tray {
        margin-right: 8px;
      }
    '';
  };
}
