HOSTNAME := $(shell hostname)

detect:
	@uname | grep -q Darwin && make macos || true
	@[ -f /etc/nixos/configuration.nix ] && make nixos || true
	@uname | grep -q Linux && make ubuntu || true

ubuntu:
	nix run nixpkgs#home-manager -- switch --flake .#michael@$(HOSTNAME)
	bash scripts/ubuntu-extras.sh   # apt + flatpak ngoài Nix

macos:
	nix run nix-darwin -- switch --flake .#macos
	bash scripts/macos-extras.sh    # utm, extras

nixos:
	sudo nixos-rebuild switch --flake .#nixos --impure

update:
	# nix flake update && make detect
	sudo nix flake update
