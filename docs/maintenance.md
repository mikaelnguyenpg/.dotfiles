# Bảo trì & dọn dẹp hệ thống

> Bản HTML: `docs/maintenance.html` · Liên quan: `docs/dev-environments.md`
> Cập nhật: 2026-11-16

---

## 1. Tóm gọn

- **Hằng ngày / hằng tuần**: không phải làm gì. Máy tự dọn và tự báo khi ổ sắp đầy.
- **Mỗi tháng ~5 phút**: `make health` → `make clean` → xem mục "cần tự quyết".
- **Khi xong một dự án / mỗi quý**: dọn những thứ có dữ liệu (DB, VM, distrobox, đồ cũ).
- **Khi nhận thông báo "Ổ … đã dùng 85%"**: làm ngay bước hằng tháng.

---

## 2. Nguyên tắc

1. **Chặn từ gốc**: giới hạn dung lượng ngay trong config để rác không phình.
2. **Máy tự dọn phần an toàn**: cache, log, image thừa (xoá không mất dữ liệu).
3. **Người tự quyết phần có dữ liệu**: volume DB, VM, distrobox, dự án cũ. Không để máy tự xoá.
4. **Theo ngưỡng, không chỉ theo lịch**: ổ vượt 85% thì máy báo.
5. **Lưu trữ thay vì xoá** khi còn lấn cấn: chuyển sang `/data/archive` (ổ 1TB, còn rộng).

---

## 3. Bản đồ ổ đĩa

| Phân vùng | Gắn vào | Chứa gì | Ai hay làm đầy |
|---|---|---|---|
| `nvme1n1p3` 238G | `/` | NixOS, `/nix/store`, `/home` | `~/.cache`, `~/.config` (Chrome, VS Code), `/nix/store`, VM Boxes, distrobox |
| `nvme0n1p2` 186G | `/mnt/build_cache`, `/var/lib/ollama` | **Podman** (image, container, volume), model ollama | Podman, model AI |
| `nvme0n1p1` 767G | `/data` | Dữ liệu, dự án, archive | Ít khi đầy |
| `nvme1n1p1` 1G | `/boot` | Kernel | Nix tự xoá kernel cũ khi GC |
| `nvme1n1p2` 238G | *(không gắn)* | Chưa rõ, có thể là OS cũ | Cân nhắc tận dụng |

> ⚠️ Podman **không** nằm trên `/`, mà nằm trên `/mnt/build_cache`
> (cấu hình trong `modules/dev/containers.nix`). Dọn podman làm trống ổ CACHE, không phải ổ `/`.

---

## 4. Đã tự động hoá (không cần làm gì)

| Cái gì | Cơ chế | Ở đâu trong config |
|---|---|---|
| Nix store | `nix.gc` hằng tuần, xoá generation >3 ngày | `hosts/nixos/system.nix` |
| File trùng trong Nix store | `auto-optimise-store` | `hosts/nixos/system.nix` |
| Log hệ thống (journal) | Giới hạn 500M, tự xoay vòng | `hosts/nixos/system.nix` (`services.journald.settings`) |
| Cache Chrome | Giới hạn 1GB | `modules/apps/browsers.nix` (`--disk-cache-size`) |
| Image podman `<none>` | Timer user `podman-prune-dangling` hằng tuần | `modules/dev/containers.nix` |
| Cảnh báo ổ đầy | Timer user `disk-alert` hằng ngày + 10' sau đăng nhập; ≥85% thì gửi thông báo | `modules/desktop/hypr-daemons.nix` |

Kiểm tra các timer:
```sh
systemctl --user list-timers disk-alert podman-prune-dangling
systemctl --user start disk-alert        # chạy thử ngay
journalctl --user -u podman-prune-dangling -n 20
```

---

## 5. Lịch bảo trì

| Tần suất | Việc | Lệnh | Ai |
|---|---|---|---|
| Hằng ngày | Kiểm tra ổ, ≥85% thì báo | *(timer `disk-alert`)* | 🤖 |
| Hằng tuần | Nix GC, journal, image `<none>` | *(tự động)* | 🤖 |
| **Hằng tháng** | Xem báo cáo, dọn cache và image | `make health` → `make clean` | 👤 5 phút |
| Hằng quý / xong dự án | Volume DB, distrobox, VM, `node_modules` dự án cũ, Downloads | xem mục 7 | 👤 tự quyết |
| Sau `make update` | Kiểm tra build còn chạy, generation cũ còn để rollback | `make nixos` | 👤 |

---

## 6. Quy trình hằng tháng (~5 phút)

```sh
cd ~/.dotfiles
make health            # 1. Xem báo cáo (chỉ đọc, ~4 giây)
make clean ARGS=-n     # 2. Xem trước sẽ dọn gì
make clean             # 3. Dọn (hỏi y/N); Chrome nên tắt trước
```

**`make health`** in ra:
- % dùng của `/`, `/mnt/build_cache`, `/data`, `/boot` (vàng ≥80%, đỏ ≥90%)
- top thư mục trong `~` và `~/.cache`
- podman: image, container, volume, working-container sót lại
- distrobox, lima, Boxes
- journal, số generation NixOS, kích thước `/nix/store`
- `~/Downloads` và số mục cũ >90 ngày
- **Gợi ý** cụ thể nên làm gì

**`make clean`** chỉ dọn phần an toàn:
- working-container của buildah/devcontainer, image podman không container nào dùng
- cache pnpm, npm, yarn, uv, thumbnails
- cache Chrome (tự bỏ qua nếu Chrome đang mở)
- cuối cùng **liệt kê** những thứ cần tự quyết (không xoá)

Tham số: `ARGS=-n` (xem trước), `ARGS=-y` (không hỏi).
Script: `scripts/health.sh`, `scripts/clean.sh`.

---

## 7. Cần tự quyết (có dữ liệu)

| Thứ | Xem | Dọn |
|---|---|---|
| Volume podman (DB…) | `podman volume ls` | `podman volume rm <tên>` hoặc `podman volume prune --all -f` ⚠️ **phải có `--all`** |
| distrobox | `distrobox list` | `distrobox rm <box>` + `rm -rf ~/.distrobox/<box>` |
| lima VM | `limactl list` | `limactl delete --force <vm>` + `rm -rf ~/.cache/lima` |
| VM Boxes | mở Boxes | xoá trong Boxes |
| `node_modules` dự án cũ | `du -sh /data/**/node_modules` | `rm -rf` hoặc archive cả dự án |
| `~/Downloads` | `make health` | chuyển sang `/data/archive` |
| Model ollama | `ollama list` | `ollama rm <model>` |
| Generation NixOS (gấp) | `ls /nix/var/nix/profiles/` | `sudo nix-collect-garbage --delete-older-than 7d` |

---

## 8. Các lệnh xem nhanh

```sh
df -h / /mnt/build_cache /data
du -xh --max-depth=1 ~ ~/.cache ~/.local/share 2>/dev/null | sort -rh | head -20
podman system df
podman ps -a --external          # cả working-container ẩn
journalctl --disk-usage
lsblk -f
```

---

## 9. Bẫy đã gặp

- **`podman volume prune` không xoá gì**: podman bản mới (6.x) mặc định chỉ xoá volume vô danh, cần `--all`.
- **Image `<none>` không prune được**: có working-container của buildah/devcontainer giữ lại, không hiện trong `podman ps -a`. Phải dùng `podman ps -a --external` rồi `podman rm -f`.
- **`yarn cache clean` báo command not found**: máy không cài yarn global; xoá thẳng `~/.cache/yarn`.
- **`podman system prune -a` xoá luôn các box distrobox** (là container đang tắt). Dùng `podman image prune -a` thay thế.
- **`docker` trên máy này = podman** (symlink).
- **Xoá `~/.cache/google-chrome` an toàn**: mật khẩu, bookmark, lịch sử nằm ở `~/.config/google-chrome`.
- **Log journal**: chỉ để tra lỗi; xoá log cũ không ảnh hưởng máy.

---

## 10. Nhật ký

| Ngày | Việc | Kết quả |
|---|---|---|
| 2026-11-14…16 | Dọn lần đầu: podman, distrobox, VM Win11, lima, cache Chrome/pnpm/yarn, journal | `/`: 168G (76%) → 89G (41%) |
| 2026-11-16 | Thêm giới hạn journal 500M, cache Chrome 1GB, timer dọn podman, cảnh báo ổ đầy, `make health`/`make clean` | |
