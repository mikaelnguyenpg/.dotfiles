# modules/tools.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
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

    # ── Fun / terminal eye-candy ──────────────────────────────────
    cmatrix
    cowsay
    figlet
    fortune
    boxes
    btop
    gotop
    gtop

    # ── Media CLI ─────────────────────────────────────────────────
    cava           # audio visualizer
    yt-dlp       # uncomment nếu cần

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
