### 3. Hướng dẫn vận hành (The Flow)

**Bước 1: Khởi tạo (Chỉ làm 1 lần)**
Mở terminal trên NixOS và chạy:

```bash
limactl start --name=rust-box ~/.dotfiles/lima/ubuntu-rust.yaml
limactl start --name=node-box ~/.dotfiles/lima/ubuntu-node.yaml
```

**Bước 2: Sử dụng (Hàng ngày)**
Michael nên thêm 2 alias này vào cấu hình Shell của mình để "dịch chuyển" tức thời:

```bash
alias rust-env="limactl shell rust-box"
alias node-env="limactl shell node-box"
```

