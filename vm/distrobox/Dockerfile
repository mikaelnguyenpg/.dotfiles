FROM ubuntu:25.10

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------
# 1. Essential packages
# -------------------------
RUN apt update && apt upgrade -y && apt install -y \
    curl wget git zsh \
    build-essential pkg-config \
    ca-certificates unzip libssl-dev \
    lldb \
    software-properties-common \
    gnupg

# -------------------------
# 2. Create user (quan trọng cho distrobox)
# -------------------------
ARG USERNAME=michael
ARG USER_UID=1000
ARG USER_GID=1000

# RUN groupadd --gid $USER_GID $USERNAME \
#   && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
#   && apt install -y sudo \
#   && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# USER $USERNAME
WORKDIR /home/$USERNAME

# -------------------------
# 3. PATH
# -------------------------
ENV PATH="/home/$USERNAME/.local/bin:$PATH"

# -------------------------
# 4. Install mise
# -------------------------
RUN curl https://mise.run | sh

# add mise to shell
RUN echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

# -------------------------
# 5. Install runtimes via mise
# -------------------------
RUN ~/.local/bin/mise use -g \
    rust@latest \
    python@3.12 \
    node@20 \
    helix \
    neovim
# yazi lazygit

# -------------------------
# 6. Install CLI tools
# -------------------------

# -------------------------
# 7. Install VSCode
# -------------------------
RUN wget -qO vscode.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable && \
    apt-get install -y ./vscode.deb && rm vscode.deb

# -------------------------
# 8. Install Chrome
# -------------------------
RUN wget -qO chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./chrome.deb && rm chrome.deb

# -------------------------
# 9. Install Zed
# -------------------------
# RUN curl -L https://zed.dev/install.sh | sh

# export PATH="$HOME/.local/bin:$PATH"
# eval "$($HOME/.local/bin/mise activate zsh)"

# -------------------------
# 10. Default shell
# -------------------------
RUN chsh -s $(which zsh)

CMD ["zsh"]
