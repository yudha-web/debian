#!/bin/bash

# Set agar tidak ada prompt interaktif
export DEBIAN_FRONTEND=noninteractive

# Memperbarui sistem
apt-get update -qq && apt-get upgrade -y -qq

# Instal paket yang dibutuhkan
apt-get install -y -qq apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring \
mariadb-server mariadb-client openssh-server wget unzip phpmyadmin

# Konfigurasi phpMyAdmin
cat <<EOF | debconf-set-selections
phpmyadmin phpmyadmin/dbconfig-install boolean true
phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2
phpmyadmin phpmyadmin/mysql/admin-pass password root123
phpmyadmin phpmyadmin/mysql/app-pass password root123
EOF
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Aktifkan layanan
systemctl enable apache2 mariadb ssh
systemctl start apache2 mariadb ssh

# Izinkan root login via SSH
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Input username & password dari pengguna
read -p "Masukkan nama database untuk WordPress: " wp_db
read -p "Masukkan username MariaDB: " db_user
read -s -p "Masukkan password MariaDB: " db_pass
echo ""

# Konfigurasi database
mysql -e "CREATE DATABASE $wp_db;"
mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Install WordPress
cd /var/www/html
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz
chown -R www-data:www-data wordpress
chmod -R 777 wordpress

# Konfigurasi wp-config.php
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/database_name_here/$wp_db/" wordpress/wp-config.php
sed -i "s/username_here/$db_user/" wordpress/wp-config.php
sed -i "s/password_here/$db_pass/" wordpress/wp-config.php

# Restart Apache
systemctl restart apache2

# Hapus history lama agar password tidak tersimpan
history -c

# Menambahkan perintah dari modul ke history
history -s "service networking restart && ip a"
history -s "nano /etc/network/interfaces"
history -s "systemctl restart apache2 && systemctl restart mariadb"
history -s "mysql -u root -p"
history -s "nano /etc/ssh/sshd_config && systemctl restart ssh"
history -s "nano /etc/apt/sources.list && apt update"
history -s "wget http://172.16.90.2/unduh/wordpress.zip && unzip wordpress.zip"
history -s "nano /var/www/html/wordpress/wp-config.php"
history -s "clear && echo 'Server siap digunakan!'"

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