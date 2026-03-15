# modules/nixpkgs.nix
{ ... }: {
  nixpkgs.config = {
    # Tôi biết đây là phần mềm đóng, nhưng tôi vẫn muốn dùng nó
    allowUnfree = true;
    # Tôi biết gói này không an toàn, nhưng hãy cứ cho phép tôi cài nó để chạy WebStorm
    permittedInsecurePackages = [
      "qtwebengine-5.15.19"
    ];
  };
}
