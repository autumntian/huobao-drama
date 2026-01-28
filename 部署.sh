#!/bin/bash

# 本地操作：提交代码
echo "=== 本地：添加文件到暂存区 ==="
git add *

echo "=== 本地：提交代码 ==="
git commit -m "保存"

echo "=== 本地：推送到远程仓库 ==="
git push

# 远程操作：部署
echo "=== 远程：连接服务器并部署 ==="
ssh root@aliyun -p 7022 << 'EOF'
cd /root/coding/huobao-drama
echo "=== 远程：拉取最新代码 ==="
git pull
echo "=== 远程：构建 Docker 镜像 ==="
docker compose build
echo "=== 远程：启动容器 ==="
docker-compose up -d
echo "=== 部署完成 ==="
EOF

echo "=== 全部完成 ==="
