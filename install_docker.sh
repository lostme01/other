#!/bin/bash

# 更新现有包列表
sudo apt-get update

# 安装一些必需的包
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

# 添加Docker的官方GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置Docker稳定版仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新apt包索引，并且仅安装最新版本的Docker Engine和containerd
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# 验证安装
sudo docker run --rm hello-world

# 下载最新版的docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 给docker-compose赋予可执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 输出docker-compose版本信息以证实正确安装 
docker-compose --version
