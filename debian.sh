#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    echo "Harap jalankan script ini sebagai root!"
    exit 1
fi

echo "============================"
echo "   INSTALLASI DEBIAN SERVER "
echo "============================"

# Set agar instalasi berjalan tanpa prompt
export DEBIAN_FRONTEND=noninteractive

# Meminta pengguna memasukkan password root MySQL dan password WordPress
echo -n "Masukkan password root MySQL: "
read -s MYSQL_ROOT_PASSWORD
echo
echo -n "Masukkan password untuk user WordPress: "
read -s WP_PASSWORD
echo

# Meminta pengguna memasukkan username untuk WordPress
echo -n "Masukkan username untuk user WordPress: "
read WP_USER
echo

# Install paket yang diperlukan
echo "[1] Installing essential packages..."
apt update && apt upgrade -y
apt install -y wget curl git unzip sudo ufw htop net-tools apache2 mariadb-server php php-mysql php-cli php-mbstring php-curl php-xml openssh-server openssh-sftp-server

# Setting SSH agar bisa login sebagai root
echo "[2] Configuring SSH to allow root login..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Download dan ekstrak WordPress
echo "[3] Downloading and extracting WordPress..."
wget http://172.16.90.2/unduh/wordpress.zip -P /tmp/
unzip /tmp/wordpress.zip -d /var/www/html/
rm /tmp/wordpress.zip

# Ubah hak akses direktori WordPress
echo "[4] Setting permissions for WordPress..."
chmod -R 777 /var/www/html/wordpress
chown -R www-data:www-data /var/www/html/wordpress

# Konfigurasi MariaDB (mengatur password root MySQL dan membuat database WordPress)
echo "[5] Configuring MariaDB..."
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE dbwordpress;
CREATE USER '$WP_USER'@'localhost' IDENTIFIED BY '$WP_PASSWORD';
GRANT ALL PRIVILEGES ON dbwordpress.* TO '$WP_USER'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Menampilkan informasi akhir
echo "============================"
echo "   INSTALLASI SELESAI! "
echo "============================"
echo "🌐 Akses WordPress: http://$(hostname -I | awk '{print $1}')/wordpress"
echo "🔑 Login phpMyAdmin: root / $MYSQL_ROOT_PASSWORD"
echo "🗄️  Database WordPress: dbwordpress (User: $WP_USER / Password: $WP_PASSWORD)"
echo "============================"

# Tambahkan Tulisan ASCII "MAKAN" di Terminal
echo -e "\e[1;32m"
echo "███    ███  █████  ██   ██  █████  ███    ██"
echo "████  ████ ██   ██ ██   ██ ██   ██ ████   ██"
echo "██ ████ ██ ███████ ███████ ███████ ██ ██  ██"
echo "██  ██  ██ ██   ██ ██   ██ ██   ██ ██  ██ ██"
echo "██      ██ ██   ██ ██   ██ ██   ██ ██   ████"
echo "============================================"
echo "🎉 Instalasi selesai! Terima kasih telah menggunakan script ini!"
echo "📌 by makan dulu bang 🍽️"
echo "============================================"
