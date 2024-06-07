#!/bin/bash

# 检查是否以 root 身份运行
if [ "$(id -u)" -ne 0 ]; then
  echo "请以 root 身份运行此脚本。"
  exit 1
fi

# 获取系统内存大小（以MB为单位）
mem_size_mb=$(free -m | awk '/^Mem:/{print $2}')

# 计算交换分区大小（内存大小的两倍，并取 1024 的倍数）
swap_size_mb=$(( (mem_size_mb * 2 / 1024 + 1) * 1024 ))

# 定义交换文件路径
swap_file="/swapfile"

# 创建交换文件
fallocate -l ${swap_size_mb}M $swap_file

# 设置交换文件权限
chmod 600 $swap_file

# 设置交换分区
mkswap $swap_file

# 启用交换分区
swapon $swap_file

# 将交换分区信息添加到 /etc/fstab 以便开机自动挂载
echo "$swap_file none swap sw 0 0" >> /etc/fstab

# 验证交换分区是否已正确启用
swapon --show

# 显示当前的交换空间信息
free -h

echo "交换分区已成功添加并启用，大小为：${swap_size_mb}MB"
