{ pkgs, ... }:
let
  # Bật/tắt 1 mode của mako rồi báo trạng thái mới (thông báo này luôn hiện
  # vì đặt urgency critical — xem section bên dưới).
  notif-mode = pkgs.writeShellScriptBin "notif-mode" ''
    mode="''${1:-do-not-disturb}"
    ${pkgs.mako}/bin/makoctl mode -t "$mode" >/dev/null
    if ${pkgs.mako}/bin/makoctl mode | grep -qx "$mode"; then
      state="BẬT"
    else
      state="TẮT"
    fi
    ${pkgs.libnotify}/bin/notify-send -u critical -t 2000 -a notif-mode "Chế độ $mode: $state"
  '';
in {
  home.packages = [ notif-mode ];

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 6;
      font = "JetBrainsMono Nerd Font 11";

      # Section áp dụng theo thứ tự, section sau ghi đè section trước.
      # mute-signal: chỉ ẩn Signal ($mod+ALT+N)
      "app-name=Signal mode=mute-signal".invisible = 1;
      # do-not-disturb: ẩn tất cả ($mod+N) ...
      "mode=do-not-disturb".invisible = 1;
      # ... trừ thông báo khẩn (pin < 15%, báo đổi mode)
      "mode=do-not-disturb urgency=critical".invisible = 0;
    };
  };
}
