# =============================================================================
# pritunl.nix — Pritunl VPN Client system configuration
# =============================================================================
{ pkgs, ... }:

{
  # 1. Cài đặt package GUI và CLI của Pritunl
  environment.systemPackages = with pkgs; [
    pritunl-client
  ];

  # 2. Báo systemd load file .service đi kèm trong package
  systemd.packages = [ pkgs.pritunl-client ];

  # 3. Cho phép background service tự động khởi chạy cùng hệ điều hành
  systemd.targets.multi-user.wants = [ "pritunl-client.service" ];
}
