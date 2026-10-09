# archive/

Các file `.nix` không còn được import nhưng giữ lại để tham khảo / dùng lại.
Cấu trúc thư mục giữ nguyên như vị trí cũ (vd. `archive/modules/waybar.nix` ← `modules/waybar.nix`).

Không file nào trong đây được build. Muốn dùng lại thì `git mv` về chỗ cũ và thêm vào `imports`.
Lưu ý: đường dẫn tương đối bên trong file (vd. `../foo.nix`) có thể cần sửa lại.

| File | Lý do archive |
| --- | --- |
| `modules/waybar.nix` | Đã thay bằng wayle (`modules/wayle.nix`) |
| `modules/input.nix` | Config fcitx5, chưa được import |
| `modules/flatpak.nix` | Cần input `nix-flatpak` (đang comment trong `flake.nix`) |
| `modules/nixGL.nix.bak` | Bản backup cũ của `modules/nixGL.nix` |
| `hosts/nixos/fonts.nix` | Chưa được import trong `hosts/nixos/system.nix` |
| `hosts/nixos/flatpak.nix` | Chưa được import trong `hosts/nixos/system.nix` |
