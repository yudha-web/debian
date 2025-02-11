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

# Update & Upgrade sistem
echo "[1] Updating system..."
apt update && apt upgrade -y

# Install paket yang diperlukan
echo "[2] Installing essential packages..."
apt install -y wget curl git unzip tar sudo ufw htop net-tools apache2 mariadb-server php php-mysql php-cli php-mbstring openssh-server phpmyadmin

# Setting SSH agar bisa login sebagai root
echo "[3] Configuring SSH to allow root login..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Konfigurasi phpMyAdmin (otomatis memilih Apache2 dan "Yes" pada konfigurasi database)
echo "[4] Configuring phpMyAdmin..."
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
apt install -y phpmyadmin

# Konfigurasi MariaDB (mengatur password root MySQL dan membuat database WordPress)
echo "[5] Configuring MariaDB..."
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'rootpassword';
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Instalasi WordPress
echo "[6] Installing WordPress..."
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz
mv wordpress/* .
rmdir wordpress
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Download dan Pasang Template WordPress Otomatis
echo "[7] Installing WordPress Template..."
cd /var/www/html/wp-content/themes
wget https://downloads.wordpress.org/theme/astra.latest.zip
unzip astra.latest.zip
rm astra.latest.zip

# Tambahkan Watermark "makan" di Halaman WordPress
echo "[8] Adding Watermark to WordPress..."
echo "<div style='position:fixed;bottom:10px;right:10px;color:red;font-size:14px;'>makan</div>" >> /var/www/html/wp-content/themes/astra/footer.php

# Restart layanan untuk menerapkan konfigurasi
echo "[9] Restarting services..."
systemctl restart apache2
systemctl restart mariadb

# Menampilkan informasi akhir
echo "============================"
echo "   INSTALLASI SELESAI! "
echo "============================"
echo "🌐 Akses WordPress: http://$(hostname -I | awk '{print $1}')/"
echo "🛠️  Akses phpMyAdmin: http://$(hostname -I | awk '{print $1}')/phpmyadmin"
echo "🔑 Login phpMyAdmin: root / rootpassword"
echo "🗄️  Database WordPress: wordpress (User: wpuser / Password: wppassword)"
echo "🎨 Template WordPress: Astra (aktifkan di dashboard WordPress)"
echo "📌 Watermark: 'makan' ditambahkan ke footer WordPress"
echo "============================"

# Tambahkan Watermark di Terminal
echo -e "\e[1;32m"
echo "████████╗███████╗██████╗ ██╗███╗   ███╗ █████╗  ██████╗ ███████╗"
echo "╚══██╔══╝██╔════╝██╔══██╗██║████╗ ████║██╔══██╗██╔════╝ ██╔════╝"
echo "   ██║   █████╗  ██████╔╝██║██╔████╔██║███████║██║  ███╗█████╗  "
echo "   ██║   ██╔══╝  ██╔═══╝ ██║██║╚██╔╝██║██╔══██║██║   ██║██╔══╝  "
echo "   ██║   ███████╗██║     ██║██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗"
echo "   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
echo "============================"
echo "🎉 Instalasi selesai! Terima kasih telah menggunakan script ini! 🎉"
echo "============================"
