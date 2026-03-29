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

---

### 4. Giải thích kiểu Feynman (Về việc "Mount" Partition ngoại)

Hãy tưởng tượng **NixOS** là văn phòng chính của Michael. Michael có một cái **Ổ cứng di động khổng lồ (`/data`)** đang cắm vào máy.

- Khi Michael chạy Lima với cấu hình `mounts` ở trên, Michael đang thực hiện một hành động: **Nối một dây cáp ảo** từ cái ổ cứng đó trực tiếp vào trong từng cái máy ảo (`rust-box` và `node-box`).
- Michael có thể dùng **Helix** trên NixOS để sửa code trong ổ cứng đó, và ngay lập tức nhảy vào `rust-env` để gõ `cargo build`. Cả hai bên đều nhìn thấy cùng một file dữ liệu, không cần copy đi đâu cả.
