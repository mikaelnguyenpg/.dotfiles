# modules/fonts.nix
{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Terminal Nerd fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.comic-shanns-mono
    nerd-fonts.symbols-only
    # Chinese fonts
    noto-fonts
    noto-fonts-cjk-sans     # Font Sans-serif tiếng Trung/Nhật/Hàn cực chuẩn của Google
    noto-fonts-cjk-serif    # Font Serif tiếng Trung/Nhật/Hàn
    wqy_zenhei              # WenQuanYi (Font tiếng Trung rất phổ biến trên Linux)
  ];
}
