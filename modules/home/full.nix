# modules/home/full.nix — module tier full dùng chung cho mọi host Linux
# App chỉ dành cho 1 host (vd. browsers/communication trên NixOS) thì import ở host đó.
{ ... }: {
  imports = [
    ../cli/carbonyl.nix
    ../dev/ai.nix
    ../dev/ide.nix
    ../dev/vscode.nix
    ../apps/design.nix
    ../apps/ghostty.nix
  ];
}
