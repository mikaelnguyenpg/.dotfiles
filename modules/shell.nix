# modules/tools.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ── Clipboard ─────────────────────────────────────────────────
    xclip # Copy to clipboard for X11
    wl-clipboard # Copy to clipboard for Wayland

    # ── Editor ────────────────────────────────────────────────────
    helix
    
    # ── Core CLI ──────────────────────────────────────────────────
    delta          # diff đẹp hơn
    jq             # xử lý JSON
    httpie         # curl thân thiện
    tldr           # hướng dẫn lệnh ngắn gọn
    lsd            # ls đẹp hơn
    xclip          # clipboard CLI for X11
    wl-clipboard   # clipboard CLI for Wayland
    duf            # disk usage đẹp hơn df
    ncdu           # disk usage interactive
    mise
    devbox

    # ── Fun / terminal eye-candy ──────────────────────────────────
    cmatrix        # matrix rain animation trên terminal
    cowsay         # in text với hình con bò (hoặc con vật khác) nói chuyện
    figlet         # tạo ASCII art text lớn từ string
    fortune        # in câu trích dẫn/câu đố ngẫu nhiên
    boxes          # vẽ khung hộp ASCII xung quanh text
    btop           # system monitor TUI: CPU/RAM/disk/network real-time, đẹp nhất
    gotop          # system monitor TUI viết bằng Go, nhẹ hơn btop
    gtop           # system monitor TUI viết bằng Node.js, style khác

    # ── Media CLI ─────────────────────────────────────────────────
    # cava           # audio visualizer
    # yt-dlp         # uncomment nếu cần

    # ── Screenshots ───────────────────────────────────────────────
  ];
  
  # ── Programs với config riêng ─────────────────────────────────
  programs = {
    cmus.enable         = true;
    lazygit.enable      = true;
    lf.enable           = true;
    neovim.enable       = true;
    ripgrep.enable      = true;
    vim.enable          = true;
    yazi.enable         = true;
    direnv = {
      enable            = true;
      nix-direnv.enable = true;
    };
  };

  # ── Services ─────────────────────────────────────────────────
}
