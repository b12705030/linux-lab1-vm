#!/bin/bash
set -e

echo "[1/5] 建立 student 帳號（如不存在）"
if id "student" &>/dev/null; then
    echo "  ✅ 帳號 student 已存在"
else
    sudo adduser student --gecos "" --disabled-password
    echo "student:student" | sudo chpasswd
    sudo usermod -aG sudo student
    echo "  ✅ 建立完成，密碼為 student"
fi

echo "[2/5] 將 lab 資料傳入 student 家目錄"
if [ ! -f /home/student/linux-lab1.zip ]; then
    sudo cp linux-lab1.zip /home/student/
    sudo chown student:student /home/student/linux-lab1.zip
    echo "  ✅ 複製成功"
else
    echo "  ⚠️  檔案已存在，略過複製"
fi

echo "[3/5] 解壓縮 zip，準備 Docker 建置"
sudo -u student bash -c "
    cd /home/student &&
    unzip -o linux-lab1.zip &&
    cd linux-lab1 &&
    docker build -t linux-lab1 .
"

echo "[4/5] 啟動 container（若未啟動）"
if docker ps -a --format '{{.Names}}' | grep -q '^labbox$'; then
    echo "  ⚠️ labbox container 已存在，請自行 docker start -ai labbox"
else
    sudo docker run --privileged -it --name labbox linux-lab1
fi

echo "[5/5] 所有準備完成，請使用 student 帳號進入 container 進行任務"
