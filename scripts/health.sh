#!/usr/bin/env bash
# scripts/health.sh — báo cáo dung lượng & rác hệ thống. CHỈ ĐỌC, không xoá gì.
# Chạy: make health   (xem docs/maintenance.md)
set -u

WARN=80   # % ổ: vàng
CRIT=90   # % ổ: đỏ

if [ -t 1 ]; then
  B=$'\e[1m'; D=$'\e[2m'; R=$'\e[31m'; Y=$'\e[33m'; G=$'\e[32m'; N=$'\e[0m'
else
  B=; D=; R=; Y=; G=; N=
fi
have() { command -v "$1" >/dev/null 2>&1; }
hdr()  { printf '\n%s== %s ==%s\n' "$B" "$1" "$N"; }
size() { local s; s=$(du -sh "$1" 2>/dev/null | cut -f1); echo "${s:-0}"; }
hints=()
hint() { hints+=("$1"); }

# ─── 1. Ổ đĩa ────────────────────────────────────────────────────────────────
hdr "Ổ đĩa"
for m in / /mnt/build_cache /data /boot; do
  mountpoint -q "$m" 2>/dev/null || [ "$m" = / ] || continue
  read -r used avail pct < <(df -h --output=used,avail,pcent "$m" | tail -1)
  p=${pct%\%}
  c=$G; [ "$p" -ge $WARN ] && c=$Y; [ "$p" -ge $CRIT ] && c=$R
  printf '  %-18s %s%4s%s  dùng %-6s còn %s\n' "$m" "$c" "$pct" "$N" "$used" "$avail"
  [ "$p" -ge $WARN ] && hint "Ổ $m đã $pct → chạy 'make clean' và xem các mục thủ công bên dưới"
done
printf '  %sPodman lưu ở /mnt/build_cache (không phải /)%s\n' "$D" "$N"

# ─── 2. Thư mục lớn trong home ──────────────────────────────────────────────
hdr "Top thư mục trong ~ (trên ổ /)"
du -xh --max-depth=1 "$HOME" 2>/dev/null | sort -rh | sed -n '2,11p' | sed 's/^/  /'

hdr "Cache (~/.cache)"
du -xh --max-depth=1 "$HOME/.cache" 2>/dev/null | sort -rh | sed -n '1,9p' | sed 's/^/  /'
for d in yarn google-chrome pnpm ms-playwright lima; do
  [ -d "$HOME/.cache/$d" ] || continue
  kb=$(du -sk "$HOME/.cache/$d" 2>/dev/null | cut -f1)
  [ "${kb:-0}" -gt 2097152 ] && hint "~/.cache/$d $(size "$HOME/.cache/$d") → make clean"
done

# ─── 3. Podman ──────────────────────────────────────────────────────────────
if have podman; then
  hdr "Podman"
  podman system df 2>/dev/null | sed 's/^/  /'
  ext=$(podman ps -aq --external 2>/dev/null | wc -l)
  dangling=$(podman images -qf dangling=true 2>/dev/null | wc -l)
  printf '  working-container (buildah/devcontainer): %s · image <none>: %s\n' "$ext" "$dangling"
  [ "$ext" -gt "$(podman ps -aq 2>/dev/null | wc -l)" ] && hint "Có working-container sót lại → make clean"
  [ "$dangling" -gt 0 ] && hint "$dangling image <none> → make clean"
  vols=$(podman volume ls -q 2>/dev/null | wc -l)
  [ "$vols" -gt 0 ] && hint "$vols volume podman (có thể chứa DB) → xem 'podman volume ls', tự quyết"
fi

# ─── 4. Môi trường ảo ───────────────────────────────────────────────────────
hdr "distrobox / lima / VM"
if have distrobox; then
  n=$(distrobox list 2>/dev/null | tail -n +2 | wc -l)
  printf '  distrobox: %s box   ~/.distrobox: %s\n' "$n" "$(size "$HOME/.distrobox")"
fi
if have limactl; then
  n=$(limactl list -q 2>/dev/null | wc -l)
  printf '  lima: %s VM   ~/.lima: %s\n' "$n" "$(size "$HOME/.lima")"
  [ "$n" -gt 0 ] && hint "lima có $n VM → 'limactl list', không dùng thì 'limactl delete'"
  [ "$n" -eq 0 ] && [ -d "$HOME/.cache/lima" ] && \
    hint "Không còn VM lima nhưng ~/.cache/lima $(size "$HOME/.cache/lima") → rm -rf ~/.cache/lima"
fi
[ -d "$HOME/.local/share/gnome-boxes" ] && \
  printf '  Boxes: %s\n' "$(size "$HOME/.local/share/gnome-boxes")"

# ─── 5. Hệ thống ────────────────────────────────────────────────────────────
hdr "Hệ thống"
printf '  journal: %s\n' "$(journalctl --disk-usage 2>/dev/null | grep -o '[0-9.]*[KMGT]' | head -1)"
gens=$(ls -d /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l)
printf '  NixOS generation: %s   (nix.gc tự dọn hằng tuần)\n' "$gens"
[ "$gens" -gt 10 ] && hint "$gens generation NixOS → sudo nix-collect-garbage --delete-older-than 7d"
printf '  /nix/store: %s\n' "$(du -sh /nix/store 2>/dev/null | cut -f1)"

# ─── 6. Downloads ───────────────────────────────────────────────────────────
if [ -d "$HOME/Downloads" ]; then
  hdr "Downloads"
  old=$(find "$HOME/Downloads" -maxdepth 1 -mindepth 1 -mtime +90 2>/dev/null | wc -l)
  printf '  %s   (%s mục cũ hơn 90 ngày)\n' "$(size "$HOME/Downloads")" "$old"
  [ "$old" -gt 20 ] && hint "~/Downloads có $old mục >90 ngày → xem lại / chuyển sang /data/archive"
fi

# ─── Gợi ý ──────────────────────────────────────────────────────────────────
hdr "Gợi ý"
if [ ${#hints[@]} -eq 0 ]; then
  printf '  %s✓ Mọi thứ ổn, chưa cần dọn.%s\n' "$G" "$N"
else
  for h in "${hints[@]}"; do printf '  %s•%s %s\n' "$Y" "$N" "$h"; done
fi
echo
