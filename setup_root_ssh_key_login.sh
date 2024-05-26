#!/bin/bash

# 检查是否以root用户运行
if [ "$EUID" -ne 0 ]; then
  echo "请以root用户运行此脚本。"
  exit 1
fi

# 提示用户输入公钥
read -p "请输入您的公钥: " user_pubkey

# 检查公钥是否为空
if [ -z "$user_pubkey" ]; then
  echo "公钥不能为空。"
  exit 1
fi

# 使用正则表达式验证公钥格式
if ! [[ "$user_pubkey" =~ ^ssh-(rsa|dss|ed25519|ecdsa) ]]; then
  echo "无效的公钥格式。"
  exit 1
fi

# 确保.ssh目录存在
mkdir -p /root/.ssh

# 清空authorized_keys文件并写入新的公钥
echo "$user_pubkey" > /root/.ssh/authorized_keys

# 设置正确的权限
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

# 修改sshd_config文件以确保允许root用户使用密钥登录并禁用其他登录方式
sshd_config_file="/etc/ssh/sshd_config"

# 备份原始sshd_config文件
if [ ! -f ${sshd_config_file}.bak ]; then
  cp $sshd_config_file ${sshd_config_file}.bak
  echo "已备份原始sshd_config文件到 ${sshd_config_file}.bak"
fi

# 确保PermitRootLogin设置为prohibit-password或yes
if grep -q "^PermitRootLogin" $sshd_config_file; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/' $sshd_config_file
else
    echo "PermitRootLogin prohibit-password" >> $sshd_config_file
fi

# 确保PasswordAuthentication设置为no
if grep -q "^PasswordAuthentication" $sshd_config_file; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' $sshd_config_file
else
    echo "PasswordAuthentication no" >> $sshd_config_file
fi

# 确保ChallengeResponseAuthentication设置为no
if grep -q "^ChallengeResponseAuthentication" $sshd_config_file; then
    sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' $sshd_config_file
else
    echo "ChallengeResponseAuthentication no" >> $sshd_config_file
fi

# 确保PubkeyAuthentication设置为yes
if grep -q "^PubkeyAuthentication" $sshd_config_file; then
    sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' $sshd_config_file
else
    echo "PubkeyAuthentication yes" >> $sshd_config_file
fi

# 禁用GSSAPIAuthentication
if grep -q "^GSSAPIAuthentication" $sshd_config_file; then
    sed -i 's/^GSSAPIAuthentication.*/GSSAPIAuthentication no/' $sshd_config_file
else
    echo "GSSAPIAuthentication no" >> $sshd_config_file
fi

# 禁用UsePAM
if grep -q "^UsePAM" $sshd_config_file; then
    sed -i 's/^UsePAM.*/UsePAM no/' $sshd_config_file
else
    echo "UsePAM no" >> $sshd_config_file
fi

# 移除sshd_config.d和ssh_config.d目录中的所有文件
rm -rf /etc/ssh/sshd_config.d/*
rm -rf /etc/ssh/ssh_config.d/*

# 重启sshd服务以应用更改
systemctl restart sshd

if [ $? -eq 0 ]; then
  echo "sshd服务已成功重启。"
  echo "修改完成。现在可以使用密钥登录root用户。"
else
  echo "重启sshd服务失败，请检查配置。"
fi
