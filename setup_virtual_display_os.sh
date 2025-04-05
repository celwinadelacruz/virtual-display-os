#!/bin/bash

echo "🚀 Starting setup for Virtual Display OS..."

# Step 1: Update and install basics
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip net-tools software-properties-common

# Step 2: Install NVIDIA drivers (adjust version if needed)
echo "🖥 Installing NVIDIA drivers..."
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt update
sudo apt install -y nvidia-driver-535 nvidia-cuda-toolkit

# Step 3: Install Wine for Windows games
echo "🍷 Installing Wine..."
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
wget -nc https://dl.winehq.org/wine-builds/winehq.key -O /etc/apt/keyrings/winehq-archive.key
sudo apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
sudo apt update
sudo apt install -y --install-recommends winehq-stable

# Step 4: Install Xvfb (virtual display server)
echo "🖼 Installing Xvfb..."
sudo apt install -y xvfb x11-utils

# Step 5: Install Sunshine (stream server)
echo "☀️ Installing Sunshine..."
sudo snap install sunshine

# Step 6: Create user-friendly directories
mkdir -p ~/virtual_display/apps
mkdir -p ~/virtual_display/logs

# Step 7: Create systemd service for demo app (replace with your game path)
cat <<EOF | sudo tee /etc/systemd/system/virtual-app.service
[Unit]
Description=Launch Virtual App on Headless Display
After=network.target

[Service]
ExecStart=/usr/bin/xvfb-run --auto-servernum --server-args='-screen 0 1280x720x24' wine notepad.exe
WorkingDirectory=/home/$USER/virtual_display/apps
StandardOutput=append:/home/$USER/virtual_display/logs/app.log
StandardError=append:/home/$USER/virtual_display/logs/app-error.log
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# Step 8: Enable & start the service
sudo systemctl daemon-reexec
sudo systemctl enable virtual-app
sudo systemctl start virtual-app

echo "✅ Setup complete!"
echo "You can access your app output via Sunshine + Moonlight or web-streamer soon."
