# LSAP Lab 1 — 建置一個處於待補救狀態的 Linux VM container

本專案提供一個教學用的 Linux Lab 環境（搭配 VirtualBox + Docker）

## 檔案內容

- `linux-lab1.zip`：lab 程式碼壓縮包
- `setup.sh`：自動建置與啟動 container
- `README.md`：本說明文件

## 建置步驟

**所需檔案：linux-lab1.zip 跟 setup.sh**

1. 在 VirtualBox 建立新 VM（依照 LSAP 要求）
2. 設定網路：新增一張 Host-only 網卡（enp0s8）
    1. 網路連線方式：Host-only Adapter
    2. 名稱：選 `vboxnet0`
3. 登入 VM，建立 `student` 帳號：
    
    ```bash
    sudo adduser student
    sudo usermod -aG sudo student
    # 密碼設定：student
    ```
    
4. 安裝必要工具（docker, unzip, zip）：
    
    ```bash
    sudo apt update
    sudo apt install docker.io unzip zip -y
    sudo systemctl enable --now docker
    ```
    
    <aside>
    ⚠️
    
    若有遇到 `containerd.io : Conflicts: containerd` 錯誤
    代表系統上已經有安裝某個版本的 `containerd`，但 `docker.io` 需要不同版本，所以出現衝突。
    
    解決方法：
    
    1. 清掉舊的衝突殘留
        
        ```bash
        sudo apt remove docker docker-engine docker.io containerd runc
        sudo apt autoremove -y
        ```
        
    2. 重新設定 Docker 官方安裝
        
        ```bash
        # 安裝必要工具
        sudo apt update
        sudo apt install ca-certificates curl gnupg lsb-release -y
        
        # 新增 Docker 的 GPG 金鑰
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
          sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # 新增 Docker 官方的 repository（確認你的 Ubuntu 是 noble）
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
          https://download.docker.com/linux/ubuntu noble stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # 更新來源清單
        sudo apt update
        ```
        
    3. 安裝 Docker 官方版
        
        ```bash
        sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        ```
        
    4. 驗證 Docker 正常
        
        ```bash
        docker --version
        docker run hello-world
        ```
        
    5. 讓 student 帳號可以用 docker
        
        ```bash
        sudo usermod -aG docker student
        ```
        
    </aside>
    
5. 設定固定 IP（學生連線用）：為了讓學生每次都可以用 `ssh student@192.168.56.101` 這種固定指令連線，不用查 IP。
    1. 查一下你的 Host-only 網卡名稱：輸入 `ip a`，找到 enp0s8 下的那組 IP
    2. 設定 Netplan 固定 IP：
        1. 開啟 Netplan 設定檔
            
            ```bash
            sudo nano /etc/netplan/01-netcfg.yaml
            ```
            
        2. 貼入以下設定，儲存並離開（`Ctrl+O` → `Enter` → `Ctrl+X`）
            
            ```bash
            network:
              version: 2
              ethernets:
                enp0s8:
                  dhcp4: no
                  addresses:
                    - 192.168.56.101/24
            ```
            
        3. 套用設定
            
            ```bash
            sudo netplan apply
            ```
            
    3. 到 Host 端測試連線
        
        ```bash
        ping 192.168.56.101
        ssh student@192.168.56.101
        ```
        
6. 把 `linux-lab1.zip` 和 `setup.sh` 放進 VM 的 `/home/student/`。在 Host 端輸入：
    
    ```bash
    scp linux-lab1.zip setup.sh student@192.168.56.101:/home/student/
    ```
    
7. 讓 `student` 擁有這些檔案的權限
    
    ```bash
    sudo chown student:student /home/student/*
    ```
    
    若 setup.sh 沒有執行權限請先加
    
    ```bash
    chmod +x setup.sh
    ```
    
8. 打包成 `.ova` 檔：關機 → VirtualBox → File → Export Appliance → 匯出為 linux-lab1-final.ova
