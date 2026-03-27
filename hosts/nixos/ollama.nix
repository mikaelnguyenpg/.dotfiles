# =============================================================================
# hosts/nixos/ollama.nix — Local AI Stack (Ollama + Open WebUI)
# =============================================================================
{ pkgs, lib, ... }: {

  # ─── Hardware Support (NVIDIA RTX 3070) ─────────────────────────────────────
  hardware.graphics.enable      = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.allowUnfree    = true;

  hardware.nvidia = {
    open                   = false; # Proprietary drivers for better CUDA stability
    modesetting.enable     = true;
    powerManagement.enable = true; # Critical for ASUS laptop sleep/wake
    nvidiaSettings         = true;
  };

  # ─── Storage & User Infrastructure ──────────────────────────────────────────
  # Redirect /var/lib/ollama to /mnt/build_cache to save Root partition space
  users.users.ollama = {
    isSystemUser = true;
    group        = "ollama";
    home         = "/var/lib/ollama";
  };
  users.groups.ollama = {};

  fileSystems."/var/lib/ollama" = {
    device  = "/mnt/build_cache/ollama";
    options = [ "bind" ];
    depends = [ "/mnt/build_cache" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/build_cache/ollama 0750 ollama ollama -"
  ];

  # ─── Ollama Service ─────────────────────────────────────────────────────────
  services.ollama = {
    enable      = true;
    package     = pkgs.ollama-cuda;
    loadModels  = [
      "llama3.2:3b"      # [2.0GB] Ultralight, extremely fast for daily tasks
      "gemma2:9b"        # [5.4GB] Google's best-in-class reasoning for 8GB VRAM
      "mistral:7b"       # [4.1GB] Reliable European model, great versatility
      # "mistral-nemo"   # [7.1GB] Mistral+NVIDIA collab, high-tier 12B model
      # "phi4"           # [9.1GB] Microsoft's logic powerhouse (spills to RAM)
    ];
  };

  # ─── Systemd Service Tuning ─────────────────────────────────────────────────
  systemd.services.ollama = {
    # Ensure hardware and storage are ready before starting
    after    = [ "mnt-build_cache.mount" "nvidia-persistenced.service" ];
    requires = [ "mnt-build_cache.mount" ];

    serviceConfig = {
      DynamicUser   = lib.mkForce false; # Using static user for consistent file ownership
      User          = "ollama";
      Group         = "ollama";
      ProtectHome   = lib.mkForce false; # Allow access to bind-mounted storage
      # ReadWritePaths = [ "/mnt/build_cache/ollama" ]; # Optional with bind-mount
    };
  };

  # ─── Open WebUI (Local ChatGPT Interface) ───────────────────────────────────
  services.open-webui = {
    enable       = true;
    host         = "127.0.0.1";
    port         = 8080;
    openFirewall = false;
  };

  # ─── System Environment ─────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # Real-time GPU monitoring (Essential for AI)
    ollama               # CLI for manual model management
  ];
}
