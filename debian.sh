#!/bin/bash

# Warna teks
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# Update dan upgrade sistem
echo -e "${YELLOW}Memperbarui sistem...${RESET}"
apt update -y && apt upgrade -y

# Instal Apache2, PHP, MariaDB, phpMyAdmin, SSH, dan WordPress
echo -e "${YELLOW}Menginstal Apache2, PHP, MariaDB, phpMyAdmin, SSH, dan WordPress...${RESET}"
apt install apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring mariadb-server mariadb-client openssh-server wget unzip -y

# Konfigurasi otomatis phpMyAdmin
echo -e "${BLUE}Mengonfigurasi phpMyAdmin secara otomatis...${RESET}"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root123" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root123" | debconf-set-selections

# Instal phpMyAdmin
apt install -y phpmyadmin

# Aktifkan dan mulai layanan
echo -e "${BLUE}Mengaktifkan layanan...${RESET}"
systemctl enable apache2 mariadb ssh
systemctl start apache2 mariadb ssh

# Konfigurasi SSH agar root bisa login
echo -e "${YELLOW}Mengaktifkan login root SSH...${RESET}"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Membuat database WordPress
echo -e "${YELLOW}Masukkan nama database untuk WordPress:${RESET}"
read wp_db
echo -e "${YELLOW}Masukkan username MariaDB:${RESET}"
read db_user
echo -e "${YELLOW}Masukkan password MariaDB:${RESET}"
read -s db_pass

echo -e "${BLUE}Mengonfigurasi MariaDB...${RESET}"
mysql -e "CREATE DATABASE $wp_db;"
mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Unduh dan pasang WordPress
echo -e "${BLUE}Mengunduh dan memasang WordPress...${RESET}"
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
rm latest.tar.gz

# Atur izin direktori WordPress
echo -e "${YELLOW}Mengatur izin direktori WordPress menjadi 777...${RESET}"
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 777 /var/www/html/wordpress

# Konfigurasi wp-config.php
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -i "s/database_name_here/$wp_db/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$db_user/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$db_pass/" /var/www/html/wordpress/wp-config.php

# Setel bahasa WordPress ke Indonesia
echo -e "${YELLOW}Menetapkan bahasa WordPress ke Indonesia...${RESET}"
sed -i "s/define('WPLANG', '');/define('WPLANG', 'id_ID');/" /var/www/html/wordpress/wp-config.php

# Tambahkan watermark unik
echo -e "${BLUE}Menambahkan watermark...${RESET}"
echo "/* === Watermark by Yudha === */" >> /var/www/html/wordpress/wp-config.php
echo "/* Skrip ini dibuat oleh Yudha, dilarang dicuri! */" >> /var/www/html/wordpress/wp-config.php

# Restart Apache2 untuk menerapkan konfigurasi
echo -e "${YELLOW}Merestart Apache2...${RESET}"
systemctl restart apache2

# Informasi Akses
echo -e "${GREEN}==========================================${RESET}"
echo -e "${GREEN}Instalasi selesai!${RESET}"
echo -e "Akses phpMyAdmin di: ${BLUE}http://<your_server_ip>/phpmyadmin${RESET}"
echo -e "Akses WordPress di: ${BLUE}http://<your_server_ip>/wordpress${RESET}"
echo -e "${YELLOW}Gantilah <your_server_ip> dengan alamat IP server Anda.${RESET}"
echo -e "${GREEN}==========================================${RESET}"
echo -e "${BLUE}Nama pengguna MariaDB: $db_user${RESET}"
echo -e "${BLUE}Password MariaDB: $db_pass${RESET}"
echo -e "${BLUE}Nama database WordPress: $wp_db${RESET}"
echo -e "${GREEN}==========================================${RESET}"
echo -e "${YELLOW}Terima kasih telah menggunakan skrip ini, Yudha!${RESET}"