#!/bin/bash

Warna teks

GREEN="\e[32m" YELLOW="\e[33m" CYAN="\e[36m" RESET="\e[0m"

Memeriksa dan menginstal pv untuk progress bar

if ! command -v pv &> /dev/null; then echo -e "${YELLOW}Menginstal pv untuk progress bar...${RESET}" apt install -y pv fi

Memperbarui sistem

echo -e "${YELLOW}Memperbarui sistem...${RESET}" apt update -y | pv -lep -s 100 > /dev/null apt upgrade -y | pv -lep -s 100 > /dev/null

Menginstal paket yang diperlukan

echo -e "${YELLOW}Menginstal Apache2, PHP, MariaDB, phpMyAdmin, SSH, dan WordPress...${RESET}" echo -e "Harap tunggu..." apt install -y apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring 
mariadb-server mariadb-client openssh-server wget unzip | pv -lep -s 100 > /dev/null

Konfigurasi otomatis phpMyAdmin

echo -e "${CYAN}Mengonfigurasi phpMyAdmin secara otomatis...${RESET}" echo -e "${YELLOW}Masukkan password admin phpMyAdmin:${RESET}" read -s phpmyadmin_pass debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true" debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $phpmyadmin_pass" debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $phpmyadmin_pass"

Instal phpMyAdmin

apt install -y phpmyadmin | pv -lep -s 100 > /dev/null

Mengaktifkan dan memulai layanan

echo -e "${CYAN}Mengaktifkan layanan...${RESET}" systemctl enable apache2 mariadb ssh | pv -lep -s 100 > /dev/null systemctl start apache2 mariadb ssh | pv -lep -s 100 > /dev/null

Konfigurasi SSH agar root bisa login

echo -e "${YELLOW}Mengaktifkan login root SSH...${RESET}" sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config systemctl restart ssh

Membuat database WordPress

echo -e "${YELLOW}Masukkan nama database untuk WordPress:${RESET}" read wp_db echo -e "${YELLOW}Masukkan username MariaDB:${RESET}" read db_user echo -e "${YELLOW}Masukkan password MariaDB:${RESET}" read -s db_pass

Konfigurasi MariaDB

echo -e "${CYAN}Mengonfigurasi MariaDB...${RESET}" mysql -e "CREATE DATABASE $wp_db;" mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';" mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';" mysql -e "FLUSH PRIVILEGES;"

Mengunduh dan memasang WordPress

echo -e "${CYAN}Mengunduh dan memasang WordPress...${RESET}" cd /var/www/html wget https://wordpress.org/latest.tar.gz | pv -lep -s 100 > /dev/null tar -xvzf latest.tar.gz | pv -lep -s 100 > /dev/null rm latest.tar.gz

Mengatur izin direktori WordPress

echo -e "${YELLOW}Mengatur izin direktori WordPress...${RESET}" chown -R www-data:www-data /var/www/html/wordpress chmod -R 777 /var/www/html/wordpress

Mengonfigurasi wp-config.php

cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php sed -i "s/database_name_here/$wp_db/" /var/www/html/wordpress/wp-config.php sed -i "s/username_here/$db_user/" /var/www/html/wordpress/wp-config.php sed -i "s/password_here/$db_pass/" /var/www/html/wordpress/wp-config.php

Mengatur bahasa WordPress ke Indonesia secara otomatis

echo -e "${YELLOW}Mengatur bahasa WordPress ke Indonesia...${RESET}" wget -P /var/www/html/wordpress/wp-content/languages https://downloads.wordpress.org/translation/core/6.4/id_ID.zip | pv -lep -s 100 > /dev/null unzip /var/www/html/wordpress/wp-content/languages/id_ID.zip -d /var/www/html/wordpress/wp-content/languages | pv -lep -s 100 > /dev/null rm /var/www/html/wordpress/wp-content/languages/id_ID.zip chown -R www-data:www-data /var/www/html/wordpress/wp-content/languages

mysql -e "USE $wp_db; UPDATE wp_options SET option_value='id_ID' WHERE option_name='WPLANG';"

Menambahkan watermark unik

echo -e "${CYAN}Menambahkan watermark...${RESET}" cat <<EOL >> /var/www/html/wordpress/wp-config.php

/* === Watermark by makan bang === / / Rajin sekolah tiap hari, / / Tapi ngantuk pas pelajaran. / / PR lupa belum dikerjain, / / Senyum aja biar aman! */

EOL

Merestart Apache untuk menerapkan perubahan

echo -e "${YELLOW}Merestart Apache2...${RESET}" systemctl restart apache2 | pv -lep -s 100 > /dev/null

Mendapatkan IP server

server_ip=$(hostname -I | awk '{print $1}')

Informasi Akses

echo -e "${GREEN}==========================================${RESET}" echo -e "${GREEN}Instalasi selesai!${RESET}" echo -e "Akses phpMyAdmin di: ${CYAN}http://$server_ip/phpmyadmin${RESET}" echo -e "Akses WordPress di: ${CYAN}http://$server_ip/wordpress${RESET}" echo -e "${GREEN}==========================================${RESET}" echo -e "${CYAN}Nama pengguna MariaDB: $db_user${RESET}" echo -e "${CYAN}Password MariaDB: $db_pass${RESET}" echo -e "${CYAN}Nama database WordPress: $wp_db${RESET}" echo -e "${GREEN}==========================================${RESET}"

Kucing ASCII sedang makan

echo -e "${YELLOW}Terima kasih telah menggunakan skrip ini, makan bang!${RESET}" echo -e "${CYAN}" echo " /_/\   (=^･ω･^=) 🍗" echo "( o.o )   makan bang!" echo " > 🍣 <  " echo -e "${RESET}"

