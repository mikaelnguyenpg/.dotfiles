# =============================================================================
# hosts/nixos/vm.nix — Local AI Stack (Ollama + Open WebUI)
# =============================================================================
{ pkgs, constants, ... }:
let
  constants = import ./constants.nix;
in
{
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Muốn dùng lệnh 'docker' thay cho 'podman'

    # QUAN TRỌNG: Tạo symlink từ podman.sock sang /var/run/docker.sock
    dockerSocket.enable = true;

    # # Tùy chọn: Nếu muốn dùng default network giống docker
    # defaultNetwork.settings.dns_enabled = true;
  };

  # QUAN TRỌNG: Tạo symlink từ podman.sock sang /var/run/docker.sock
  environment.sessionVariables = {
    DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
  };

  programs.virt-manager.enable = true;

  users.users.${constants.username} = {
    extraGroups = [ "libvirtd" "kvm" "wheel" "podman" "video" "render" ];

    # Quan trọng: Cấp dải ID cho Podman (65536 IDs)
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };
}

# # Cách Test hệ thống sau khi Rebuild
# cat /etc/subuid | grep michael # Kiểm tra SubUID - Kết quả mong đợi: michael:100000:65536
# podman run --rm hello-world # Test Podman - Kết quả mong đợi: hiện chữ "Hello from Podman!"
# distrobox create --name test-box --image alpine
# distrobox enter test-box

# # 1. Xóa các cấu hình storage bị lỗi cũ
# podman system migrate
# # 2. Nếu vẫn lỗi, hãy thử dọn dẹp sạch (Cẩn thận: lệnh này xóa hết container hiện có)
# podman system prune --all --force
