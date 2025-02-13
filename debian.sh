#!/bin/bash

# ========== WATERMARK ========== #
echo "===================================="
echo "      🚀 Instalasi WordPress       "
echo "        Dibuat oleh Yudha          "
echo "===================================="
sleep 2

# Update dan upgrade sistem
echo "🔄 Memperbarui sistem... (by Yudha)"
apt update -y && apt upgrade -y

# Instal layanan yang dibutuhkan
echo "🔧 Menginstal layanan... (by Yudha)"
apt install apache2 php libapache2-mod-php php-mysql php-cli php-zip php-xml php-mbstring mariadb-server mariadb-client phpmyadmin openssh-server wget unzip -y

# Aktifkan dan mulai layanan
echo "✅ Mengaktifkan layanan... (by Yudha)"
systemctl enable apache2 mariadb ssh
systemctl start apache2 mariadb ssh

# Konfigurasi SSH agar root bisa login
echo "🔑 Mengaktifkan root login via SSH... (by Yudha)"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Konfigurasi MariaDB dengan password root
echo "🔐 Mengamankan MariaDB... (by Yudha)"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root_password';"
mysql -e "FLUSH PRIVILEGES;"

# Meminta username dan password MariaDB dari pengguna
read -p "📌 Masukkan nama pengguna MariaDB (Enter untuk default: yudha_admin): " db_user
db_user=${db_user:-yudha_admin}
read -s -p "📌 Masukkan password untuk pengguna MariaDB (Enter untuk default: yudha_pass): " db_pass
db_pass=${db_pass:-yudha_pass}
echo ""

# Konfigurasi MariaDB
echo "🛠️ Mengonfigurasi MariaDB... (by Yudha)"
mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Konfigurasi phpMyAdmin
echo "🌐 Mengonfigurasi phpMyAdmin di Apache2... (by Yudha)"
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
sed -i "s/\$cfg'Servers'\$i'auth_type' = 'cookie';/\$cfg'Servers'\$i'auth_type' = 'config';/" /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['user'] = '$db_user';" >> /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['password'] = '$db_pass';" >> /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['host'] = 'localhost';" >> /usr/share/phpmyadmin/config.inc.php

# Unduh dan pasang WordPress
echo "⬇️ Mengunduh dan memasang WordPress... (by Yudha)"
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
rm latest.tar.gz

# Atur izin direktori WordPress menjadi 777
echo "🔓 Mengatur izin direktori WordPress menjadi 777... (by Yudha)"
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 777 /var/www/html/wordpress

# Meminta nama database untuk WordPress dari pengguna
read -p "📌 Masukkan nama database untuk WordPress (Enter untuk default: yudha_wp): " wp_db
wp_db=${wp_db:-yudha_wp}

# Konfigurasi database WordPress
mysql -e "CREATE DATABASE $wp_db;"
mysql -e "GRANT ALL PRIVILEGES ON $wp_db.* TO '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -e "FLUSH PRIVILEGES;"

# Konfigurasi WordPress
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sed -i "s/database_name_here/$wp_db/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$db_user/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$db_pass/" /var/www/html/wordpress/wp-config.php
sed -i "s/define('WPLANG', '');/define('WPLANG', 'id_ID');/" /var/www/html/wordpress/wp-config.php

# Tambahkan watermark dalam wp-config.php
echo "🖋️ Menambahkan watermark pada WordPress... (by Yudha)"
echo "# ===================================" >> /var/www/html/wordpress/wp-config.php
echo "# 🚀 Script ini dibuat oleh Yudha 🚀 " >> /var/www/html/wordpress/wp-config.php
echo "# Jangan hapus watermark ini!        " >> /var/www/html/wordpress/wp-config.php
echo "# ===================================" >> /var/www/html/wordpress/wp-config.php

# Restart Apache2
echo "🔄 Merestart Apache2... (by Yudha)"
systemctl restart apache2

# Menampilkan informasi akses dengan watermark
server_ip=$(hostname -I | awk '{print $1}')
echo "===================================="
echo " ✅ Instalasi Selesai! (by Yudha) ✅ "
echo "===================================="
echo "🌍 Akses phpMyAdmin di: http://$server_ip/phpmyadmin"
echo "🌍 Akses WordPress di: http://$server_ip/wordpress"
echo "🔑 Nama pengguna MariaDB: $db_user"
echo "🔑 Nama database WordPress: $wp_db"
echo "🔑 Password MariaDB: (disimpan aman)"
echo "🔑 Login SSH root: ssh root@$server_ip"
echo "===================================="
echo " 🚀 Script ini dibuat oleh Yudha 🚀 "
echo " 🎯 Jangan hapus watermark ini! 🎯 "
echo "===================================="