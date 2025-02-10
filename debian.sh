#!/bin/bash

# Update sistem dan install paket yang dibutuhkan
apt update && apt upgrade -y
apt install apache2 mariadb-server php php-mysql php-cli php-mbstring openssh-server phpmyadmin unzip wget -y

# Mengaktifkan dan memulai layanan
systemctl enable --now apache2 mariadb ssh

# Mengamankan MariaDB
mysql_secure_installation

# Konfigurasi phpMyAdmin
echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
systemctl restart apache2

# Mengaktifkan SSH root login
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Pesan selamat datang
echo -e "=============================\n        MAKAN DULU BOS\n=============================" > /etc/motd

# Instalasi WordPress
cd /var/www/html
wget https://wordpress.org/latest.zip
unzip latest.zip
rm latest.zip
mv wordpress/* .
rmdir wordpress
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Membuat Database WordPress
mysql -u root -p -e "CREATE DATABASE wordpress;"
mysql -u root -p -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'passwordwordpress';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Restart Apache
systemctl restart apache2

# Menampilkan informasi instalasi selesai
echo "====================================="
echo "Instalasi selesai!"
echo "Akses WordPress di: http://[IP_SERVER]"
echo "Akses phpMyAdmin di: http://[IP_SERVER]/phpmyadmin"
echo "Gunakan MySQL dengan perintah: mysql -u root -p"
echo "SSH root login sudah diaktifkan!"
echo "Silakan keluar dan login ulang untuk melihat watermark."
echo "====================================="
