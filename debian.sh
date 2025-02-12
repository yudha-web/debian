#!/bin/bash

# Update dan upgrade sistem
echo "Memperbarui sistem..."
apt update -y && apt upgrade -y

# Instal Apache2, PHP, MariaDB, phpMyAdmin, dan SSH
echo "Menginstal Apache2, PHP, MariaDB, phpMyAdmin, dan SSH..."
apt install apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring mariadb-server mariadb-client phpmyadmin openssh-server -y

# Aktifkan dan mulai layanan
echo "Mengaktifkan dan memulai layanan..."
systemctl enable apache2 mariadb ssh
systemctl start apache2 mariadb ssh

# Meminta nama pengguna dan password MariaDB
echo "Masukkan nama pengguna MariaDB:"
read db_user
echo "Masukkan password untuk pengguna $db_user:"
read -s db_pass

# Konfigurasi MariaDB (menggunakan nama pengguna dan password yang dimasukkan)
echo "Mengonfigurasi MariaDB..."
mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Konfigurasi phpMyAdmin (menyiapkan file konfigurasi untuk Apache2)
echo "Mengonfigurasi phpMyAdmin di Apache2..."
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Mengonfigurasi file config.inc.php untuk phpMyAdmin
echo "Mengonfigurasi file phpMyAdmin config.inc.php..."
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

# Menambahkan pengaturan database otomatis pada file config.inc.php
echo "\$cfg['Servers'][\$i]['auth_type'] = 'config';" >> /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['user'] = '$db_user';" >> /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['password'] = '$db_pass';" >> /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['host'] = 'localhost';" >> /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['AllowNoPassword'] = FALSE;" >> /usr/share/phpmyadmin/config.inc.php

# Restart Apache2 untuk menerapkan konfigurasi
echo "Merestart Apache2..."
systemctl restart apache2

# Informasi Akses
echo "Instalasi selesai!"
echo "Akses phpMyAdmin di http://<your_server_ip>/phpmyadmin"
echo "Gantilah <your_server_ip> dengan alamat IP server Anda."
echo ""
echo "Terima kasih telah menggunakan script ini!"
echo "Nama pengguna MariaDB: $db_user"
echo "Password MariaDB: $db_pass"
echo ""
echo "Watermark: makan"
