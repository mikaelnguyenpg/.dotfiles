#!/usr/bin/env bash
set -e

# ─── 1. System essentials ───────────────────────────────────────────────────
sudo apt update && sudo apt upgrade
sudo apt install -y \
  curl wget git zsh \
  build-essential pkg-config \
  ca-certificates unzip libssl-dev \
  xclip \
  lldb


# ─── Mise ───────────────────────────────────────────────────────────────────
if [ ! -f "$HOME/.local/bin/mise" ]; then
  curl https://mise.run | sh
fi

if ! grep -q "mise activate" ~/.zshrc; then
  cat >> ~/.zshrc << 'EOF'

export PATH="$HOME/.local/bin:$PATH"

if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$($HOME/.local/bin/mise activate zsh)"
fi
EOF
fi

mkdir -p ~/.config/mise
cat > ~/.config/mise/config.toml << 'MISE'
[settings]
trusted_config_paths = ["/data"]
MISE

mise use --global helix neovim ripgrep fd yazi lazygit python rust node
rustup component add rust-analyzer rust-src
cargo install --locked cargo-watch cargo-edit
rustup component list | grep installed


# ─── Devbox ──────────────────────────────────────────────────────────────────
if [ ! -f "/usr/local/bin/devbox" ]; then
    curl -fsSL https://get.jetify.com/devbox | bash
fi

# ─── Install Browsers ────────────────────────────────────────────────────────
if ! command -v code &> /dev/null; then
  wget -qO chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./chrome.deb && rm chrome.deb
fi


# ─── Install IDEs ────────────────────────────────────────────────────────────
if ! command -v code &> /dev/null; then
  wget -qO vscode.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable && \
    apt-get install -y ./vscode.deb && rm vscode.deb

if [ ! -f "$HOME/.local/bin/zed" ]; then
    curl -f https://zed.dev/install.sh | sh
fi

echo "✓ Provision complete"
