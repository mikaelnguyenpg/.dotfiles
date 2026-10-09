# modules/home/tiers.nix — danh sách profile theo tier (dùng chung cho mọi host)
#
#   imports = import ../../modules/home/tiers.nix { inherit lib tier; } ++ [ ... ];
#
#   minimal  : base                 (identity + CLI cốt lõi)
#   standard : base + work          (+ dev tools, editor, multiplexer)
#   full     : base + work + full   (+ IDE, GUI apps dùng chung)
{ lib, tier }:

assert lib.assertOneOf "tier" tier [ "minimal" "standard" "full" ];

[ ./base.nix ]
++ lib.optionals (tier == "standard" || tier == "full") [ ./work.nix ]
++ lib.optionals (tier == "full") [ ./full.nix ]
