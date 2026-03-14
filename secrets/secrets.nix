# secrets/secrets.nix
let
  ubuntu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfwcwFNrx0JYfKfQLFMc1G6rBKzpiy6n06GQvbTVZlP";  # paste host key ở đây
  # macos = "ssh-ed25519 AAAAC3Nzb...";  # thêm khi có máy mac
in {
  "ssh-personal.age".publicKeys = [ ubuntu ];
}

# ssh-keygen -t ed25519 -C "mikaelnguyen.pg@gmail.com"
# cat ~/.ssh/id_ed25519.pub
# ssh -T git@github.com
# 
# cd ~/.dotfiles/secrets
# nix shell github:ryantm/agenix
# cat ~/.ssh/id_ed25519
# EDITOR=hx agenix -e ssh-personal.age
