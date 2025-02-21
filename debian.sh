#!/bin/bash

Warna teks

GREEN="\e[32m" YELLOW="\e[33m" CYAN="\e[36m" RESET="\e[0m"

Fungsi progres bar cepat

progress_bar() { local width=40 echo -ne "${YELLOW}[${RESET}" for ((i = 0; i < width; i++)); do sleep 0.02 echo -ne "${GREEN}█${RESET}" done echo -e "${YELLOW}] Done!${RESET}" }

Set agar tidak ada prompt interaktif

export DEBIAN_FRONTEND=noninteractive

Memperbarui sistem

echo -e "${YELLOW}Memperbarui sistem...${RESET}" progress_bar apt-get update -qq && apt-get upgrade -y -qq & wait

Instalasi paket secara paralel

echo -e "${YELLOW}Menginstal paket yang diperlukan...${RESET}" progress_bar ( apt-get install -y -qq apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring 
mariadb-server mariadb-client openssh-server wget unzip phpmyadmin ) & wait

Konfigurasi phpMyAdmin

cat <<EOF | debconf-set-selections phpmyadmin phpmyadmin/dbconfig-install boolean true phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2 phpmyadmin phpmyadmin/mysql/admin-pass password root123 phpmyadmin phpmyadmin/mysql/app-pass password root123 EOF

Mengaktifkan layanan

systemctl enable apache2 mariadb ssh systemctl start apache2 mariadb ssh

Konfigurasi SSH agar root bisa login

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config systemctl restart ssh

Input database WordPress

echo -e "${YELLOW}Masukkan nama database untuk WordPress:${RESET}" read wp_db echo -e "${YELLOW}Masukkan username MariaDB:${RESET}" read db_user echo -e "${YELLOW}Masukkan password MariaDB:${RESET}" read -s db_pass

Konfigurasi MariaDB

mysql -e "CREATE DATABASE $wp_db;" mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';" mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost';" mysql -e "FLUSH PRIVILEGES;"

Mengunduh dan memasang WordPress

cd /var/www/html wget -q https://wordpress.org/latest.tar.gz tar -xzf latest.tar.gz rm latest.tar.gz

Mengatur izin WordPress

chown -R www-data:www-data /var/www/html/wordpress chmod -R 777 /var/www/html/wordpress

Konfigurasi wp-config.php

cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php sed -i "s/database_name_here/$wp_db/" /var/www/html/wordpress/wp-config.php sed -i "s/username_here/$db_user/" /var/www/html/wordpress/wp-config.php sed -i "s/password_here/$db_pass/" /var/www/html/wordpress/wp-config.php

Menambahkan watermark unik

cat <<EOL >> /var/www/html/wordpress/wp-config.php

/* === Watermark by makan bang === / / Jalan-jalan naik delman Keliling kota hingga senja Kamu teman mengaku teman Bila ada maunya saja */ EOL

Merestart Apache

systemctl restart apache2

Menampilkan informasi akses

server_ip=$(hostname -I | awk '{print $1}') echo -e "${GREEN}==========================================${RESET}" echo -e "${GREEN}Instalasi selesai!${RESET}" echo -e "Akses phpMyAdmin di: ${CYAN}http://$server_ip/phpmyadmin${RESET}" echo -e "Akses WordPress di: ${CYAN}http://$server_ip/wordpress${RESET}" echo -e "${GREEN}==========================================${RESET}" echo -e "${CYAN}Nama pengguna MariaDB: $db_user${RESET}" echo -e "${CYAN}Password MariaDB: $db_pass${RESET}" echo -e "${CYAN}Nama database WordPress: $wp_db${RESET}" echo -e "${GREEN}==========================================${RESET}"

Kucing ASCII (lebih sederhana agar terbaca di Debian)

echo -e "${YELLOW}Terima kasih telah menggunakan skrip ini, makan bang!${RESET}" echo -e "${CYAN}" echo " /_/\  (='.'=)" echo " ( o.o )  Meow!" echo "  > ^ <" echo -e "${RESET}"
