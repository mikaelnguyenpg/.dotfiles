# modules/apps/productivity.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ─── Notes ────────────────────────────────────────────────────────────────────
    obsidian
    notepad-next

    # ─── Office ───────────────────────────────────────────────────────────────────
    libreoffice

    # ─── Task / Focus ─────────────────────────────────────────────────────────────
    super-productivity
  ];
}
