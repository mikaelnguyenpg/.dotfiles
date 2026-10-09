# modules/cli/extras.nix — CLI/TUI bổ sung (tier full)
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ─── File manager ─────────────────────────────────────────────────────────────
    superfile

    # ─── Terminal browser / search ────────────────────────────────────────────────
    ddgr
    w3m
    # browsh

    # ─── System info ──────────────────────────────────────────────────────────────
    fastfetch

    # ─── Terminal workspace ───────────────────────────────────────────────────────
    tuios
    herdr
  ];
}
