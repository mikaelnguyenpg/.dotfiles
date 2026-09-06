{ pkgs, ... }: {
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];

      "clock".format = "{:%H:%M  %d/%m/%Y}";
      "clock".tooltip-format = "{calendar}";
      "clock".calendar = {
       mode = "month";
       format = { today = "<b><u>{}</u></b>"; };
      };
      "battery".format = "{capacity}%  {icon}";
      "network".format-wifi = "{essid}  ";
      "network".on-click = "nm-connection-editor";
      "pulseaudio".format = "{volume}%  ";
      "pulseaudio".on-click = "pavucontrol";
    };
    style = ''
      * { font-family: "JetBrainsMono Nerd Font"; font-size: 13px; }
    '';
  };
}
