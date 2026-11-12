# modules/dev/ai.nix
{ pkgs, lib, ... }:
let
  # TẠM THỜI (2026-11): nixpkgs @ f4a03c0 build aichat với RUSTONIG_SYSTEM_LIBONIG
  # nhưng package quên khai báo oniguruma -> "Unable to find oniguruma in pkg-config".
  # Chỉ thêm khi còn thiếu, nixpkgs sửa rồi thì tự thành no-op -> xoá được.
  aichat =
    if lib.elem pkgs.oniguruma (pkgs.aichat.buildInputs or [ ]) then pkgs.aichat
    else pkgs.aichat.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.oniguruma ];
    });
in {
  home.packages = with pkgs; [
    claude-code
    aichat
    # mods
    # tgpt
  ];
}
