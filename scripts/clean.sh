#!/usr/bin/env bash
# scripts/clean.sh — dọn các thứ AN TOÀN (cache, image thừa). Không đụng dữ liệu:
# volume DB, distrobox, VM, Downloads chỉ được LIỆT KÊ để tự quyết.
# Chạy: make clean        (hỏi xác nhận trước)
#       make clean ARGS=-n  (chỉ xem sẽ làm gì)
#       make clean ARGS=-y  (không hỏi)
#       make clean ARGS=--chrome  (dọn thêm cache Chrome — mặc định KHÔNG dọn,
#                                  vì đã có trần trong browsers.nix)
#       Gộp được: make clean ARGS="-n --chrome"
# Xem docs/maintenance.md
set -u

DRY=0; YES=0; CHROME=0
for a in "$@"; do
  case "$a" in
    -n|--dry-run) DRY=1 ;;
    -y|--yes)     YES=1 ;;
    --chrome)     CHROME=1 ;;
    *) echo "Dùng: $0 [-n|--dry-run] [-y|--yes] [--chrome]"; exit 2 ;;
  esac
done

if [ -t 1 ]; then B=$'\e[1m'; D=$'\e[2m'; Y=$'\e[33m'; G=$'\e[32m'; N=$'\e[0m'; else B=; D=; Y=; G=; N=; fi
have() { command -v "$1" >/dev/null 2>&1; }
step() { printf '\n%s▶ %s%s\n' "$B" "$1" "$N"; }
run()  { printf '  %s$ %s%s\n' "$D" "$*" "$N"; [ $DRY -eq 1 ] || eval "$@"; }
free_root() { df -h --output=avail / | tail -1 | tr -d ' '; }
free_cache() { df -h --output=avail /mnt/build_cache 2>/dev/null | tail -1 | tr -d ' '; }

echo "${B}Sẽ dọn:${N} image/working-container podman thừa, cache pnpm/npm/yarn/uv/thumbnails$([ $CHROME -eq 1 ] && echo ', cache Chrome (nếu Chrome đang tắt)')."
echo "${B}Không đụng:${N} volume, distrobox, VM, Downloads, mật khẩu/bookmark Chrome."
if [ $DRY -eq 0 ] && [ $YES -eq 0 ]; then
  read -r -p "Tiếp tục? [y/N] " ans
  [[ "$ans" =~ ^[yY]$ ]] || { echo "Huỷ."; exit 0; }
fi
before_root=$(free_root); before_cache=$(free_cache)

# ─── Podman (nằm trên /mnt/build_cache) ─────────────────────────────────────
if have podman; then
  step "Podman"
  # Working-container của buildah/devcontainer build dở (không hiện trong ps -a).
  # Bỏ qua container của podman thật (distrobox...) — chỉ xoá loại "external".
  mapfile -t own < <(podman ps -aq 2>/dev/null)
  mapfile -t ext < <(podman ps -aq --external 2>/dev/null)
  for id in "${ext[@]}"; do
    [[ " ${own[*]} " == *" $id "* ]] && continue
    run "podman rm -f $id >/dev/null"
  done
  # Image không container nào dùng (box distrobox vẫn giữ image của nó).
  run "podman image prune -af"
fi

# ─── Cache ngôn ngữ ─────────────────────────────────────────────────────────
step "Cache JS / Python"
have pnpm && run "pnpm store prune"
have npm  && run "npm cache clean --force 2>/dev/null"
[ -d "$HOME/.cache/yarn" ] && run "rm -rf '$HOME/.cache/yarn'"
have uv   && run "uv cache prune"

step "Cache khác"
[ -d "$HOME/.cache/thumbnails" ] && run "rm -rf '$HOME/.cache/thumbnails'"
if [ $CHROME -eq 0 ]; then
  echo "  ${D}Cache Chrome: bỏ qua (thêm ARGS=--chrome nếu muốn dọn)${N}"
elif [ -d "$HOME/.cache/google-chrome" ]; then
  if pgrep -x chrome >/dev/null 2>&1 || pgrep -f '/google-chrome' >/dev/null 2>&1; then
    echo "  ${Y}Chrome đang mở → bỏ qua cache Chrome (tắt Chrome rồi chạy lại).${N}"
  else
    run "rm -rf '$HOME/.cache/google-chrome'"
  fi
fi

# ─── Kết quả ────────────────────────────────────────────────────────────────
if [ $DRY -eq 0 ]; then
  printf '\n%s✓ Xong.%s  / còn trống: %s → %s' "$G" "$N" "$before_root" "$(free_root)"
  [ -n "$before_cache" ] && printf '   /mnt/build_cache: %s → %s' "$before_cache" "$(free_cache)"
  echo
else
  printf '\n%s(dry-run: chưa xoá gì)%s\n' "$Y" "$N"
fi

# ─── Thủ công: chỉ liệt kê, tự quyết ────────────────────────────────────────
step "Cần TỰ QUYẾT (script không xoá)"
if have podman; then
  n=$(podman volume ls -q 2>/dev/null | wc -l)
  [ "$n" -gt 0 ] && echo "  • $n volume podman (có thể là DB):  podman volume ls  →  podman volume rm <tên> | podman volume prune --all"
fi
have distrobox && [ "$(distrobox list 2>/dev/null | tail -n +2 | wc -l)" -gt 0 ] && \
  echo "  • distrobox:  distrobox list  →  distrobox rm <box> && rm -rf ~/.distrobox/<box>"
have limactl && [ "$(limactl list -q 2>/dev/null | wc -l)" -gt 0 ] && \
  echo "  • lima VM:  limactl list  →  limactl delete --force <vm> && rm -rf ~/.cache/lima"
[ -d "$HOME/Downloads" ] && \
  echo "  • Downloads >90 ngày: $(find "$HOME/Downloads" -maxdepth 1 -mindepth 1 -mtime +90 | wc -l) mục  →  chuyển sang /data/archive"
echo "  • Nix (tự chạy hằng tuần, chỉ cần khi gấp):  sudo nix-collect-garbage --delete-older-than 7d"
echo
