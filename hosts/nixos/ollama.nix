# hosts/nixos/ollama.nix
{ pkgs, ... }: {

  # ─── Nvidia drivers ──────────────────────────────────────────────────────────
  hardware.graphics.enable      = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.allowUnfree    = true;

  hardware.nvidia = {
    open                   = false;        # dùng proprietary driver, không phải open kernel module
    modesetting.enable     = true;         # cần cho Wayland
    powerManagement.enable = true;         # quan trọng cho laptop ASUS
    nvidiaSettings         = true;
  };

  # ─── Ollama service ───────────────────────────────────────────────────────────
  services.ollama = {
    enable       = true;
    package      = pkgs.ollama-cuda;           # RTX 3070 dùng CUDA

    # RTX 3070 = SM86, có trong default cudaArches của nixpkgs
    # Không cần override cudaArches

    loadModels = [
      # Models phù hợp với 4GB VRAM + 32GB RAM
      "llama3.2:3b"       # 2GB VRAM — nhanh, đủ dùng hàng ngày
      # "qwen2.5-coder:7b"  # 4GB VRAM — code assistant tốt
    ];

    # Delay để chờ GPU online — fix bug GPU không được detect sau reboot
    # https://github.com/NixOS/nixpkgs/issues/487054
    # (thêm nếu gặp vấn đề GPU chỉ chạy trên CPU sau reboot)
  };

  # ─── Open WebUI — giao diện chat như ChatGPT ──────────────────────────────────
  services.open-webui = {
    enable       = true;
    host         = "127.0.0.1";      # chỉ local, không expose ra ngoài
    port         = 8080;
    openFirewall = false;
  };

  # ─── Fix: ollama khởi động trước GPU online ───────────────────────────────────
  # Uncomment nếu gặp bug GPU chạy trên CPU sau reboot
  # systemd.services.ollama = {
  #   after   = [ "nvidia-persistenced.service" ];
  #   requires = [ "nvidia-persistenced.service" ];
  # };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia   # monitor GPU usage real-time
    ollama                 # CLI: ollama run, ollama list...
  ];
}
