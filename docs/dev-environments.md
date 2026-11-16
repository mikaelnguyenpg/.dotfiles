# Môi trường dev: chọn công cụ nào, khi nào?

> devbox · Nix devShell · podman · compose · distrobox · lima · dev container · ansible · .sh
> Bản HTML cùng nội dung: `docs/dev-environments.html` (mở bằng browser).
> Cập nhật: 2026-11-16

---

## 1. Tóm gọn trong 1 câu

**Nix/home-manager cho cả máy · devbox cho công cụ của dự án · podman cho dịch vụ ·
distrobox khi bí · dev container khi làm theo team · ansible cho server ·
.sh chỉ để mồi (bootstrap) · lima gần như không cần trên Linux.**

---

## 2. Bức tranh tổng quan: 3 tầng

Các công cụ này **không thay thế nhau**. Chúng giải quyết những tầng khác nhau:

| Tầng | Câu hỏi | Công cụ |
|---|---|---|
| **A. Cả máy** | Máy (hoặc server) cài gì, cấu hình ra sao? | NixOS + home-manager, **ansible**, **.sh** |
| **B. Từng dự án** | Dự án X cần node/python/go phiên bản nào? | **devbox**, Nix devShell (`nix develop`), **dev container** |
| **C. Cô lập / dịch vụ** | Chạy Postgres, Redis, phần mềm "lạ", OS khác ở đâu? | **podman** (+ compose), **distrobox**, **lima** / VM |

Một dự án thực tế thường dùng **cả 3 tầng cùng lúc**, ví dụ:
NixOS (máy) → devbox (node 20 cho dự án) → podman compose (Postgres).

---

## 3. Thang cô lập (nhẹ → nặng)

```
.sh / ansible   devbox / nix    distrobox      dev container   podman         lima / VM
(cài thẳng      (đổi PATH,      (container     (container +    (container     (máy ảo,
 vào máy)        không cô lập)   dùng chung     IDE chạy bên    cô lập)        kernel riêng)
                                 $HOME, GPU)    trong)
nhẹ, nhanh, ít cô lập ─────────────────────────────────────────────→ nặng, chậm, cô lập mạnh
```

- **Càng sang phải**: càng an toàn, càng giống production, nhưng càng tốn ổ, RAM và thời gian khởi động.
- **Càng sang trái**: càng nhanh, dùng thẳng tài nguyên máy, nhưng dễ "lây" sang hệ thống.

---

## 4. Từng công cụ

### 4.1 Nix / NixOS + home-manager  *(tầng A, cả máy)*
- **Là gì**: mô tả **toàn bộ máy** bằng code (`~/.dotfiles`). Chạy `make nixos` thì máy khớp đúng với config.
- **Mạnh**: khai báo đầy đủ (bỏ dòng nào thì gói đó bị gỡ), rollback bằng generation, tái tạo máy y hệt.
- **Yếu**: học khó; binary tải về từ ngoài thường không chạy thẳng được (cần nix-ld / distrobox).
- **Dùng khi**: mọi thứ thuộc về **máy của bạn**: app, font, Hyprland, service hệ thống.

### 4.2 Ansible  *(tầng A, nhiều máy / server)*
- **Là gì**: viết **playbook YAML** mô tả trạng thái mong muốn, rồi Ansible **SSH vào máy** (không cần cài agent) để cài và cấu hình.
- **Mạnh**: quản lý **nhiều server cùng lúc**, idempotent (chạy lại nhiều lần vẫn ra cùng kết quả), hệ sinh thái module lớn (apt, systemd, user, file…), dùng được cho Ubuntu/Debian/RHEL.
- **Yếu**: không khai báo trọn vẹn: xoá một task khỏi playbook **không** gỡ thứ nó đã cài. Kết quả còn phụ thuộc trạng thái sẵn có của máy. Chậm hơn một script.
- **Dùng khi**: dựng hoặc cấu hình **VPS/server không chạy NixOS**, nhiều máy giống nhau, môi trường staging/prod, hoặc provisioning VM.
- **Không cần khi**: máy bạn đã là NixOS (Nix làm việc này tốt hơn).
- Trong repo: `vm/ansible/provision.yaml`.

### 4.3 Shell script `.sh`  *(tầng A, mồi ban đầu)*
- **Là gì**: một chuỗi lệnh `apt install …`, `curl … | sh`, `ln -s …`.
- **Mạnh**: không cần gì ngoài bash; nhanh để viết; chạy ở đâu cũng được.
- **Yếu**: **không idempotent** (chạy 2 lần dễ lỗi hoặc trùng), dễ lệch theo thời gian, khó gỡ, phụ thuộc distro.
- **Dùng khi**: **bootstrap** (cài Nix/ansible lần đầu), tác vụ nhỏ một lần, glue giữa các công cụ, CI đơn giản.
- **Tránh khi**: muốn quản lý lâu dài cả một máy. Khi đó chuyển sang Nix hoặc ansible.
- Trong repo: `bootstrap/{ubuntu,fedora,macos}.sh`, `scripts/*.sh`.

### 4.4 devbox  *(tầng B, công cụ của dự án)*
- **Là gì**: file `devbox.json` liệt kê gói, lấy từ **Nix**. Chạy `devbox shell` (hoặc dùng direnv) để có đúng phiên bản. **Không có container**, chỉ đổi `PATH`.
- **Mạnh**: siêu nhẹ, khởi động tức thì, chạy native nên nhanh; có `devbox services` (Postgres, Redis… chạy native không cần container); dễ hơn viết flake.
- **Yếu**: không cô lập (tiến trình chạy trên máy thật), chỉ dùng được gói có trong nixpkgs.
- **Dùng khi**: **lựa chọn đầu tiên** cho toolchain dự án trên NixOS và macOS.
- Lệnh: `devbox init` · `devbox add nodejs@20 postgresql` · `devbox shell` · `devbox services up`.

### 4.5 Nix devShell (`flake.nix` + `nix develop`)  *(tầng B, giống devbox)*
- **Là gì**: devbox nhưng viết bằng Nix thuần.
- **Mạnh**: linh hoạt tối đa (overlay, patch, build package riêng), không cần thêm công cụ.
- **Yếu**: phải biết ngôn ngữ Nix; team không quen Nix sẽ khó đọc.
- **Dùng khi**: cần tuỳ biến mà devbox không làm được, hoặc repo vốn đã là flake.

### 4.6 podman (+ `podman compose`)  *(tầng C, dịch vụ)*
- **Là gì**: chạy **container OCI** (giống Docker, không cần daemon, rootless). Trên máy này `docker` = podman (symlink trong `modules/dev/containers.nix`).
- **Mạnh**: cô lập tiến trình, mạng và ổ đĩa; chạy đúng image production; `compose.yaml` dựng nhiều dịch vụ một lúc.
- **Yếu**: tốn ổ (image, volume), cần dọn định kỳ; mạng và quyền rootless đôi khi rắc rối.
- **Dùng khi**: chạy **dịch vụ** (Postgres, Redis, MinIO, Kafka…), test Dockerfile, giống prod.
- Lệnh: `podman compose up -d` · `podman ps -a` · `podman system df`.

### 4.7 distrobox  *(tầng C, "distro khác" trong terminal)*
- **Là gì**: lớp bọc trên podman. Tạo container Ubuntu/Arch/Fedora nhưng **dùng chung `$HOME`, màn hình, GPU, âm thanh** với máy thật. Cảm giác như mở một terminal của distro khác.
- **Mạnh**: chạy được `.deb`, AUR, binary FHS, installer độc quyền; export app ra menu (`distrobox-export`).
- **Yếu**: **ít cô lập** (chung `$HOME`, nên phần mềm trong box có thể ghi đè dotfiles); dễ quên rồi tích rác (từng chiếm 18G trên máy này).
- **Dùng khi**: phần mềm **không chịu chạy trên NixOS** và cần nhanh. Dùng xong thì `distrobox rm`.
- Trong repo: `vm/distrobox/`.

### 4.8 Dev container (`.devcontainer/devcontainer.json`)  *(tầng B + C, chuẩn cho team)*
- **Là gì**: một **chuẩn mở** (containers.dev) mô tả container dev cho dự án, gồm image hoặc Dockerfile, "features", extension VS Code, port, lệnh `postCreateCommand`. **IDE chạy bên trong container**. Cần podman/docker ở dưới.
- **Mạnh**: cả team (Windows/macOS/Linux) có **môi trường giống hệt nhau**; người mới clone repo là chạy được; hợp với GitHub Codespaces và DevPod.
- **Yếu**: nặng (mỗi dự án một image, kèm volume `node_modules`…); build chậm; **để lại rác** (image `<none>`, buildah working-container, volume, tất cả từng gặp trên máy này); file watcher và hiệu năng ổ đĩa đôi khi kém.
- **Dùng khi**: **dự án team đã có sẵn `.devcontainer`**, hoặc cần onboarding nhanh cho người không dùng Nix.
- **Trên NixOS**: VS Code cần `"dev.containers.dockerPath": "podman"`.

### 4.9 lima / VM (Boxes, virt-manager)  *(tầng C, máy ảo)*
- **Là gì**: **máy ảo** thật (qemu), có kernel riêng. lima là CLI cho VM Linux; Boxes và virt-manager có giao diện.
- **Mạnh**: cô lập mạnh nhất; kernel riêng; systemd đầy đủ; chạy được OS khác (Windows).
- **Yếu**: nặng nhất (RAM, ổ 10–30G mỗi VM), khởi động chậm.
- **Dùng khi**: test kernel module hoặc systemd thật, mô phỏng server đầy đủ (kết hợp ansible), chạy Windows. **lima chủ yếu dành cho macOS**; trên Linux hiếm khi cần.
- Trong repo: `vm/lima/ubuntu.yaml`.

---

## 5. Bảng so sánh tổng

| | Tầng | Cô lập | Tốc độ | Tốn ổ | Khai báo/tái tạo | Hợp cho team | Hợp cho server |
|---|---|---|---|---|---|---|---|
| NixOS / home-manager | A | – | ⚡⚡⚡ | trung bình | ✅✅✅ | khó | NixOS only |
| ansible | A | – | ⚡ | – | ✅✅ | ✅ | ✅✅✅ |
| .sh | A | – | ⚡⚡⚡ | – | ❌ | ✅ (đơn giản) | ⚠️ |
| devbox | B | ❌ | ⚡⚡⚡ | thấp | ✅✅✅ | ✅✅ | – |
| Nix devShell | B | ❌ | ⚡⚡⚡ | thấp | ✅✅✅ | ✅ (nếu biết Nix) | – |
| dev container | B+C | ✅✅ | ⚡ | cao | ✅✅ | ✅✅✅ | – |
| podman / compose | C | ✅✅ | ⚡⚡ | trung bình–cao | ✅✅ | ✅✅✅ | ✅✅ |
| distrobox | C | ✅ (chung $HOME) | ⚡⚡ | trung bình | ⚠️ | ❌ | ❌ |
| lima / VM | C | ✅✅✅ | ⚡ | rất cao | ✅ | ⚠️ | test |

---

## 6. Cây quyết định

```
Cần cài/cấu hình cho...
│
├─ CẢ MÁY của mình (NixOS)          → Nix / home-manager (~/.dotfiles)
├─ SERVER / VPS không phải NixOS    → ansible   (lần đầu cài ansible bằng .sh)
├─ Máy mới, chỉ cần chạy 1 lần      → .sh (bootstrap)
│
├─ Một DỰ ÁN cần toolchain (node, python, go...)
│     ├─ Repo đã có .devcontainer & làm theo team?  → dev container
│     ├─ Cần tuỳ biến Nix sâu?                       → nix develop (flake)
│     └─ Còn lại                                     → devbox  ⭐
│
├─ Cần DỊCH VỤ (Postgres, Redis, ...)
│     ├─ Dự án cá nhân, muốn nhẹ                     → devbox services
│     └─ Giống prod / nhiều service / team          → podman compose ⭐
│
├─ Phần mềm KHÔNG CHẠY trên NixOS (.deb, AUR, binary lạ)
│     ├─ Có trong nixpkgs không? → có thì cài bằng Nix
│     ├─ Binary đơn lẻ?          → thử nix-ld (đã bật) / steam-run
│     └─ Vẫn không được          → distrobox (dùng xong rm)
│
└─ Cần KERNEL riêng / OS khác / mô phỏng server thật
      ├─ Windows, app có GUI     → Boxes / virt-manager
      └─ Linux server + ansible  → lima hoặc VM
```

---

## 7. Workflow gợi ý cho máy này

### 7.1 Dự án cá nhân (vd `tastelife_02`, `feed-clone`)
```
repo/
├─ devbox.json      # node, pnpm, psql CLI...
├─ .envrc           # "eval $(devbox generate direnv --print-envrc)" → cd vào là có môi trường
└─ compose.yaml     # postgres, redis  →  podman compose up -d
```
1. `cd repo`: direnv tự kích hoạt devbox.
2. `podman compose up -d`: bật DB.
3. Code bằng helix hoặc VS Code **chạy native** (nhanh, không qua container).
4. Xong việc: `podman compose down`. Dự án bỏ hẳn: `podman compose down -v` (xoá luôn volume).

### 7.2 Dự án team có sẵn `.devcontainer`
- Mở bằng VS Code, chọn "Reopen in Container" (backend podman).
- Hoặc **đọc** `devcontainer.json` rồi dựng lại bằng devbox + compose để chạy native (nhanh hơn, ít rác hơn).
- Định kỳ dọn rác devcontainer (xem mục 8).

### 7.3 Server / VPS
- Lần đầu: `.sh` cài ansible → `ansible-playbook -i host, vm/ansible/provision.yaml`.
- Muốn thử playbook trước: dựng VM lima hoặc Boxes, chạy playbook vào VM.

### 7.4 Gặp phần mềm "khó" trên NixOS
- nixpkgs → nix-ld → distrobox (theo thứ tự). Dùng xong distrobox thì `distrobox rm <box>` và xoá `~/.distrobox/<box>`.

---

## 8. Dọn dẹp

Đã tách sang tài liệu riêng: **`docs/maintenance.md`** (lịch bảo trì, `make health` / `make clean`,
những gì đã tự động hoá, những gì cần tự quyết, các bẫy đã gặp).

---

## 9. Hiểu lầm hay gặp

- **"distrobox an toàn như container"**: sai. Nó chung `$HOME` với máy thật.
- **"dev container = Docker"**: dev container là **một chuẩn mô tả**; Docker/podman chỉ là thứ chạy bên dưới.
- **"ansible thay được Nix"**: chỉ một phần. Ansible không gỡ thứ đã bỏ khỏi playbook và không rollback được.
- **"devbox là container"**: không. Nó chỉ đổi `PATH` sang gói Nix.
- **"`docker` trên máy này là Docker"**: không, đó là podman qua symlink.
- **"`podman volume prune` xoá hết volume"**: podman bản mới (6.x trên máy này) mặc định chỉ xoá volume vô danh; cần `--all`.
