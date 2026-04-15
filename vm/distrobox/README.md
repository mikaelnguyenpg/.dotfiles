# Distrobox

## Usage

### Tạo box

```bash
distrobox create \
 --name box-01 \
 --image ubuntu:25.10 \
 --home ~/.distrobox/"$name" \
 --volume /data:/data:rw \
 --init-hooks "ln -sf /data/20_Workspaces \$HOME/20_Workspaces"
```

### Provision

`distrobox enter box-01 -- bash ~/.dotfiles/distrobox/provision.sh`

### Verify

```bash
distrobox enter box-01
mise --version
ls ~/20_Workspaces
mise trust # (Optional) trust mise.toml
mise current # check activated tools
mise install # install tools
```
