#!/bin/bash

Warna teks

GREEN="\e[32m" YELLOW="\e[33m" CYAN="\e[36m" RESET="\e[0m"

Memperbarui sistem

echo -e "${YELLOW}Memperbarui sistem...${RESET}" apt update -y && apt upgrade -y

Menginstal paket yang diperlukan

echo -e "${YELLOW}Menginstal Apache2, PHP, MariaDB, phpMyAdmin, SSH, dan WordPress...${RESET}" apt install -y apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring 
mariadb-server mariadb-client openssh-server wget unzip

Konfigurasi otomatis phpMyAdmin

echo -e "${CYAN}Mengonfigurasi phpMyAdmin secara otomatis...${RESET}" debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true" debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password root123" debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password root123"

Instal phpMyAdmin

apt install -y phpmyadmin

Mengaktifkan dan memulai layanan

echo -e "${CYAN}Mengaktifkan layanan...${RESET}" systemctl enable apache2 mariadb ssh systemctl start apache2 mariadb ssh

Konfigurasi SSH agar root bisa login

echo -e "${YELLOW}Mengaktifkan login root SSH...${RESET}" sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config systemctl restart ssh

Membuat database WordPress

echo -e "${YELLOW}Masukkan nama database untuk WordPress:${RESET}" read wp_db echo -e "${YELLOW}Masukkan username MariaDB:${RESET}" read db_user echo -e "${YELLOW}Masukkan password MariaDB:${RESET}" read -s db_pass

Konfigurasi MariaDB

echo -e "${CYAN}Mengonfigurasi MariaDB...${RESET}" mysql -e "CREATE DATABASE $wp_db;" mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';" mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';" mysql -e "FLUSH PRIVILEGES;"

Mengunduh dan memasang WordPress

echo -e "${CYAN}Mengunduh dan memasang WordPress...${RESET}" cd /var/www/html wget https://wordpress.org/latest.tar.gz tar -xvzf latest.tar.gz rm latest.tar.gz

Mengatur izin direktori WordPress

echo -e "${YELLOW}Mengatur izin direktori WordPress...${RESET}" chown -R www-data:www-data /var/www/html/wordpress chmod -R 777 /var/www/html/wordpress

Mengonfigurasi wp-config.php

cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php sed -i "s/database_name_here/$wp_db/" /var/www/html/wordpress/wp-config.php sed -i "s/username_here/$db_user/" /var/www/html/wordpress/wp-config.php sed -i "s/password_here/$db_pass/" /var/www/html/wordpress/wp-config.php

Mengatur bahasa WordPress ke Indonesia

echo -e "${YELLOW}Menetapkan bahasa WordPress ke Indonesia...${RESET}" sed -i "s/define('WPLANG', '');/define('WPLANG', 'id_ID');/" /var/www/html/wordpress/wp-config.php

Menambahkan watermark unik

echo -e "${CYAN}Menambahkan watermark...${RESET}" cat <<EOL >> /var/www/html/wordpress/wp-config.php

/* === Watermark by makan bang === / / Skrip ini dibuat oleh makan bang, dilarang dicuri! */

EOL

Merestart Apache untuk menerapkan perubahan

echo -e "${YELLOW}Merestart Apache2...${RESET}" systemctl restart apache2

Mendapatkan IP server

server_ip=$(hostname -I | awk '{print $1}')

Informasi Akses

echo -e "${GREEN}==========================================${RESET}" echo -e "${GREEN}Instalasi selesai!${RESET}" echo -e "Akses phpMyAdmin di: ${CYAN}http://$server_ip/phpmyadmin${RESET}" echo -e "Akses WordPress di: ${CYAN}http://$server_ip/wordpress${RESET}" echo -e "${GREEN}==========================================${RESET}" echo -e "${CYAN}Nama pengguna MariaDB: $db_user${RESET}" echo -e "${CYAN}Password MariaDB: $db_pass${RESET}" echo -e "${CYAN}Nama database WordPress: $wp_db${RESET}" echo -e "${GREEN}==========================================${RESET}"

Kucing ASCII

echo -e "${YELLOW}Terima kasih telah menggunakan skrip ini, makan bang!${RESET}" echo -e "${CYAN}" echo " /_/\   (=^･ω･^=)" echo "( o.o )  Meow!" echo " > 🍣 <  " echo -e "${RESET}"

