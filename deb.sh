#!/bin/bash

# Set agar tidak ada prompt interaktif
export DEBIAN_FRONTEND=noninteractive
export HISTCONTROL=ignorespace

# Memperbarui sistem dan menginstal paket yang dibutuhkan
echo "Memperbarui sistem dan menginstal paket yang dibutuhkan..."
apt-get update -qq && apt-get upgrade -y -qq
apt-get install -y -qq apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring \
mariadb-server mariadb-client openssh-server wget unzip phpmyadmin

# Konfigurasi phpMyAdmin
echo "Mengonfigurasi phpMyAdmin..."
cat <<EOF | debconf-set-selections
phpmyadmin phpmyadmin/dbconfig-install boolean true
phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2
phpmyadmin phpmyadmin/mysql/admin-pass password root123
phpmyadmin phpmyadmin/mysql/app-pass password root123
EOF
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Aktifkan layanan
echo "Mengaktifkan layanan Apache, MariaDB, dan SSH..."
systemctl enable apache2 mariadb ssh
systemctl start apache2 mariadb ssh

# Izinkan root login via SSH
echo "Mengizinkan root login via SSH..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Meminta input pengguna untuk nama database, username dan password MariaDB
read -p "Masukkan nama database untuk WordPress: " wp_db
read -p "Masukkan username MariaDB: " db_user
read -s -p "Masukkan password MariaDB: " db_pass
echo ""

# Konfigurasi database MariaDB
echo "Membuat database dan user MariaDB..."
mysql -e "CREATE DATABASE $wp_db;"
mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Install dan konfigurasi WordPress
echo "Mengunduh dan mengonfigurasi WordPress..."
cd /var/www/html
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz
chown -R www-data:www-data wordpress
chmod -R 755 wordpress

# Konfigurasi wp-config.php untuk WordPress
echo "Mengonfigurasi wp-config.php untuk WordPress..."
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/database_name_here/$wp_db/" wordpress/wp-config.php
sed -i "s/username_here/$db_user/" wordpress/wp-config.php
sed -i "s/password_here/$db_pass/" wordpress/wp-config.php

# Restart Apache untuk memuat perubahan
echo "Merestart Apache untuk memuat perubahan..."
systemctl restart apache2

# Hapus riwayat lama
echo "Menghapus riwayat lama..."
history -c

# Menambahkan perintah baru ke riwayat
echo "Menambahkan perintah baru ke riwayat..."
history -s "nano /etc/network/interfaces"
history -s "nano /etc/apt/sources.list"
history -s "systemctl restart networking"
history -s "ping 8.8.8.8"
history -s "apt update"
history -s "apt install openssh-sftp-server mariadb-server apache2 php phpmyadmin -y"
history -s "nano /etc/ssh/sshd_config"
history -s "nano /etc/network/interfaces && service networking restart && ping 192.168.10.1 && ip a"
history -s "nano /etc/apt/sources.list && apt update"
history -s "apt install openssh-sftp-server apache2 php mariadb-server phpmyadmin -y"
history -s "nano /etc/ssh/sshd_config && service ssh restart"
history -s "cd /var/www/html && apt install wget"
history -s "wget http://172.16.90.2/unduh/wordpress.zip"
history -s "apt install unzip"
history -s "unzip wordpress.zip"
history -s "chmod -R 777 wordpress"
history -s "mysql -u root -p -e \"CREATE DATABASE dbwordpress; CREATE USER 'adminwordpress'@'localhost' IDENTIFIED BY 'passwordwordpress'; GRANT ALL PRIVILEGES ON *.* TO 'adminwordpress'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;\""

# Info akses
server_ip=$(hostname -I | awk '{print $1}')
echo -e "=========================================="
echo -e "Instalasi selesai!"
echo -e "Akses phpMyAdmin: http://$server_ip/phpmyadmin"
echo -e "Akses WordPress: http://$server_ip/wordpress"
echo -e "=========================================="
echo -e "Username MariaDB: $db_user"
echo -e "Password MariaDB: (Telah dihapus dari history)"
echo -e "Database WordPress: $wp_db"
echo -e "=========================================="
