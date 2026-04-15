# Trong distrobox container

# 1. Install locale package
sudo apt-get install -y locales

# 2. Generate locale
sudo locale-gen en_US.UTF-8

# 3. Set locale cho session hiện tại
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 4. Verify
ansible --version

cat >> ~/.zshrc << 'EOF'

# --- Locale fix ---
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF

# --- Install ansible (1 lần) ---
sudo apt install ansible

# Chạy playbook
# ansible-playbook provision.yml -K
# # -K để nhập sudo password khi cần

# # Dry run — xem sẽ làm gì mà không thực thi
# ansible-playbook provision.yml -K --check

# # Chỉ chạy 1 phần — dùng tags
# ansible-playbook provision.yml -K --tags mise
# ansible-playbook provision.yml -K --tags vscode
