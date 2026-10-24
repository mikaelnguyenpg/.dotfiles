# =============================================================================
# hosts/nixos/power.nix — Pin yếu: ngưỡng & hành động khi pin cạn
# =============================================================================
# Pin chỉ còn ~72% dung lượng thiết kế (55/76 Wh) -> % tụt nhanh ở cuối, nên
# đặt ngưỡng cao hơn mặc định. Thông báo cho user do batsignal lo
# (modules/desktop/hypr-daemons.nix); file này lo hành động cuối cùng.
{ ... }: {
  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow      = 25;
    percentageCritical = 15;
    percentageAction   = 8;
    # Chưa có swap nên không hibernate/hybrid-sleep được (mặc định HybridSleep
    # sẽ thất bại -> tắt máy). Suspend giữ nguyên RAM, cắm sạc là làm tiếp.
    # TODO: khi có swapfile + resume thì đổi sang "Hibernate" (an toàn hơn).
    criticalPowerAction = "Suspend";
    allowRiskyCriticalPowerAction = true; # bắt buộc khi dùng "Suspend"
  };
}
