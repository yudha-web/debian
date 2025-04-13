#!/bin/bash

# Warna teks
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Nonaktifkan prompt interaktif
export DEBIAN_FRONTEND=noninteractive

# Update & upgrade sistem
echo -e "${YELLOW}Update sistem...${RESET}"
apt-get update -qq && apt-get upgrade -y -qq

# Install paket utama
echo -e "${YELLOW}Install Apache, PHP, MariaDB, dll...${RESET}"
apt-get install -y -qq apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring \
mariadb-server mariadb-client openssh-server wget unzip phpmyadmin

# Konfigurasi phpMyAdmin otomatis
echo -e "${YELLOW}Konfigurasi phpMyAdmin...${RESET}"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root123" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root123" | debconf-set-selections

# Symlink phpMyAdmin ke /var/www/html
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Enable & start layanan
systemctl enable apache2 mariadb ssh
systemctl start apache2 mariadb ssh

# Aktifkan login root via SSH
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Input user
read -p "Nama database WordPress: " wp_db
read -p "Username MariaDB: " db_user
read -s -p "Password MariaDB: " db_pass
echo ""

# Setup database
mysql -e "CREATE DATABASE $wp_db;"
mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Download dan ekstrak WordPress
cd /var/www/html
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz

# Atur hak akses
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# Setup wp-config.php
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/database_name_here/$wp_db/" wordpress/wp-config.php
sed -i "s/username_here/$db_user/" wordpress/wp-config.php
sed -i "s/password_here/$db_pass/" wordpress/wp-config.php

# Restart Apache
systemctl restart apache2

# Tampilkan hasil
server_ip=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}==========================================${RESET}"
echo -e "phpMyAdmin: ${CYAN}http://$server_ip/phpmyadmin${RESET}"
echo -e "WordPress:  ${CYAN}http://$server_ip/wordpress${RESET}"
echo -e "${GREEN}Database: $wp_db | User: $db_user${RESET}"
echo -e "${GREEN}==========================================${RESET}"