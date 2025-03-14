#!/bin/bash

# Warna teks
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Fungsi progres bar cepat
progress_bar() {
    local width=40
    echo -ne "${YELLOW}[${RESET}"
    for ((i = 0; i < width; i++)); do
        sleep 0.02
        echo -ne "${GREEN}█${RESET}"
    done
    echo -e "${YELLOW}] Done!${RESET}"
}

# Set agar tidak ada prompt interaktif
export DEBIAN_FRONTEND=noninteractive

# Memperbarui sistem
echo -e "${YELLOW}Memperbarui sistem...${RESET}"
progress_bar
apt-get update -qq && apt-get upgrade -y -qq & wait

# Menginstal paket yang dibutuhkan
echo -e "${YELLOW}Menginstal paket yang diperlukan...${RESET}"
progress_bar
apt-get install -y -qq apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring \
mariadb-server mariadb-client openssh-server wget unzip phpmyadmin & wait

# Konfigurasi phpMyAdmin
echo -e "${YELLOW}Mengonfigurasi phpMyAdmin...${RESET}"
cat <<EOF | debconf-set-selections
phpmyadmin phpmyadmin/dbconfig-install boolean true
phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2
phpmyadmin phpmyadmin/mysql/admin-pass password root123
phpmyadmin phpmyadmin/mysql/app-pass password root123
EOF

# Membuat symlink phpMyAdmin agar dapat diakses dari web
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Mengaktifkan layanan
echo -e "${YELLOW}Mengaktifkan layanan Apache, MariaDB, dan SSH...${RESET}"
systemctl enable apache2 mariadb ssh
systemctl start apache2 mariadb ssh

# Mengaktifkan SSH untuk root
echo -e "${YELLOW}Mengaktifkan akses root via SSH...${RESET}"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Konfigurasi Database WordPress
echo -e "${YELLOW}Masukkan nama database untuk WordPress:${RESET}"
read wp_db
echo -e "${YELLOW}Masukkan username MariaDB:${RESET}"
read db_user
echo -e "${YELLOW}Masukkan password MariaDB:${RESET}"
read -s db_pass

echo -e "${YELLOW}Membuat database dan user di MariaDB...${RESET}"
mysql -e "CREATE DATABASE $wp_db;"
mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Mengunduh dan mengonfigurasi WordPress
echo -e "${YELLOW}Mengunduh dan memasang WordPress...${RESET}"
cd /var/www/html
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz

# Mengatur izin file WordPress menggunakan chmod 777
echo -e "${YELLOW}Mengatur izin akses WordPress...${RESET}"
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 777 /var/www/html/wordpress

# Mengonfigurasi wp-config.php
echo -e "${YELLOW}Mengatur konfigurasi WordPress...${RESET}"
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -i "s/database_name_here/$wp_db/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$db_user/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$db_pass/" /var/www/html/wordpress/wp-config.php

# Restart Apache
systemctl restart apache2

# Menampilkan informasi akses
server_ip=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}==========================================${RESET}"
echo -e "${GREEN}Instalasi selesai!${RESET}"
echo -e "Akses phpMyAdmin di: ${CYAN}http://$server_ip/phpmyadmin${RESET}"
echo -e "Akses WordPress di: ${CYAN}http://$server_ip/wordpress${RESET}"
echo -e "${GREEN}==========================================${RESET}"
echo -e "${CYAN}Nama pengguna MariaDB: $db_user${RESET}"
echo -e "${CYAN}Password MariaDB: $db_pass${RESET}"
echo -e "${CYAN}Nama database WordPress: $wp_db${RESET}"
echo -e "${GREEN}==========================================${RESET}"

# Kucing ASCII
echo -e "${YELLOW}Terima kasih telah menggunakan skrip ini!${RESET}"
echo -e "${CYAN}"
echo " /\_/\  (='.'=)"
echo " ( o.o )  Meow!"
echo "  > ^ <"
echo -e "${RESET}"