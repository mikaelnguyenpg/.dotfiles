HOSTNAME := $(shell hostname)

detect:
	@uname | grep -q Darwin && make macos || true
	@[ -f /etc/nixos/configuration.nix ] && make nixos || true
	@uname | grep -q Linux && make ubuntu || true

ubuntu:
	nix run nixpkgs#home-manager -- switch --flake . # #$(USER)@$(HOSTNAME)
	bash scripts/ubuntu-extras.sh   # apt + flatpak ngoài Nix

macos:
	nix run nix-darwin -- switch --flake .#$(HOSTNAME)
	bash scripts/macos-extras.sh    # utm, extras

nixos:
	sudo nixos-rebuild switch --flake .#$(HOSTNAME) --impure

update:
	nix flake update && make detect
