# =============================================================================
# hosts/nixos/ollama.nix — Ollama configuration
# =============================================================================
{ pkgs, lib, ... }: {

  # === Nvidia drivers ==========================================================
  hardware.graphics.enable      = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.allowUnfree    = true;

  hardware.nvidia = {
    open                   = false;        # dùng proprietary driver, không phải open kernel module
    modesetting.enable     = true;         # cần cho Wayland
    powerManagement.enable = true;         # quan trọng cho laptop ASUS
    nvidiaSettings         = true;
  };

  # === Ollama service ===========================================================
  # ─── 1. Định nghĩa User tĩnh (Bắt buộc để ổn định quyền) ──────────────────
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    home = "/var/lib/ollama";
  };
  users.groups.ollama = {};

  # ─── 2. Cấu hình Bind Mount (Ánh xạ ổ đĩa) ────────────────────────────────
  # Cách này giúp lừa Systemd Sandbox, không cần nới lỏng ProtectHome quá nhiều
  fileSystems."/var/lib/ollama" = {
    device = "/mnt/build_cache/ollama";
    options = [ "bind" ];
    depends = [ "/mnt/build_cache" ]; # Đảm bảo ổ cache đã mount trước
  };

  # ─── 3. Tạo thư mục đích trên ổ cứng ─────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /mnt/build_cache/ollama 0750 ollama ollama -"
  ];

  services.ollama = {
    enable       = true;
    package      = pkgs.ollama-cuda;           # RTX 3070 dùng CUDA

    # RTX 3070 = SM86, có trong default cudaArches của nixpkgs
    # Không cần override cudaArches

    # ─── Load cac Model thong dung ───────────────────────────────────────
    loadModels = [
      # Models phù hợp với 8GB VRAM + 32GB RAM
      "llama3.2:3b"              # 2GB VRAM — nhanh, đủ dùng hàng ngày
      # "llama3.1:8b"            # 4.9GB VRAM — nhanh, đủ dùng hàng ngày
      "gemma2:9b"                # 4.9GB VRAM — nhanh, đủ dùng hàng ngày
      "mistral:7b"               # 4.4GB VRAM — nhanh, đủ dùng hàng ngày
      # "mistral-nemo:12b"       # 7.1GB VRAM — nhanh, đủ dùng hàng ngày
      # "phi4:14b"               # 9.1GB VRAM — nhanh, đủ dùng hàng ngày
    ];

    # Delay để chờ GPU online — fix bug GPU không được detect sau reboot
    # https://github.com/NixOS/nixpkgs/issues/487054
    # (thêm nếu gặp vấn đề GPU chỉ chạy trên CPU sau reboot)
  };

  # ─── Mở khóa quyền ghi cho Systemd ──────────────────────────────────────────
  # 2. Cấu hình Systemd để vượt qua lỗi NAMESPACE (Status 226)
  systemd.services.ollama = {
    # Chỉ chạy sau khi ổ đĩa đã mount
    after = [ "mnt-build_cache.mount" "nvidia-persistenced.service" ];
    requires = [ "mnt-build_cache.mount" ];

    serviceConfig = {
      DynamicUser = lib.mkForce false; # Tắt ID ngẫu nhiên
      User = "ollama";
      Group = "ollama";
    };
  };

  # === Open WebUI — giao diện chat như ChatGPT ==================================
  services.open-webui = {
    enable       = true;
    host         = "127.0.0.1";      # chỉ local, không expose ra ngoài
    port         = 8080;
    openFirewall = false;
  };

  # === Fix: ollama khởi động trước GPU online ===================================
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

# # 1. Tạo folder (nếu chưa có)
# sudo mkdir -p /mnt/build_cache/ollama

# # 2. Chuyển dữ liệu (nếu có)
# sudo cp -ra /var/lib/ollama/. /mnt/build_cache/ollama/

# # 3. GÁN QUYỀN (Lần này sẽ không lỗi nữa)
# sudo chown -R ollama:ollama /mnt/build_cache/ollama
# sudo chmod -R 750 /mnt/build_cache/ollama
