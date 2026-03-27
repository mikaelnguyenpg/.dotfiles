# =============================================================================
# hosts/ubuntu/ollama.nix ─ Local AI Stack (Ollama + Open WebUI)
# Firstly: install nvidia-driver
#   sudo ubuntu-drivers install
#   or
#   sudo apt install nvidia-driver-580
# =============================================================================
{ pkgs, ... }: {

  home.packages = with pkgs; [
    ollama-cuda      # Package Ollama có hỗ trợ CUDA
    nvtopPackages.nvidia
  ];

  # ─── Biến môi trường để dùng chung Model ───────────────────────────────────
  home.sessionVariables = {
    OLLAMA_MODELS = "/mnt/build_cache/ollama/models";
  };

  # ─── Chạy Ollama như một Background Service trên Ubuntu ───────────────────
  systemd.user.services.ollama = {
    Unit = {
      Description = "Ollama Service (Shared Storage)";
      After = [ "graphical-session.target" ];
    };

    Service = {
      # Quan trọng: Trỏ trực tiếp tới folder model ở /mnt
      Environment = "OLLAMA_MODELS=/mnt/build_cache/ollama/models";
      
      # Trên Ubuntu, đôi khi cần trỏ thư viện CUDA thủ công nếu Ollama không thấy GPU
      # Environment = "LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/nvidia/current";

      ExecStart = "${pkgs.ollama-cuda}/bin/ollama serve";
      Restart   = "always";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
