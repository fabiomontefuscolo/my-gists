#!/bin/bash
version="20.x"
domain="$1";
db_host="localhost"

if [ -z "$domain" ];
then
    echo "A domain name is needed" >&2
    exit 1
fi

tikiwiki_repo="https://gitlab.com/tikiwiki/tiki.git"
instance_root="/var/www/virtual/${domain}"
instance_html="/var/www/virtual/${domain}/html"
instance_conf="/var/www/virtual/${domain}/conf"
instance_logs="/var/www/virtual/${domain}/logs"
instance_data="/var/www/virtual/${domain}/data"

mkdir -p -m 0755 $instance_root
mkdir -p -m 0755 $instance_html
mkdir -p -m 0755 $instance_conf
mkdir -p -m 2775 $instance_logs

mkdir -p -m 0775 $instance_data
mkdir -p -m 0775 $instance_data/FileGalleries
mkdir -p -m 0775 $instance_data/WikiAttachments
mkdir -p -m 0775 $instance_data/TrackerAttachments
mkdir -p -m 0775 $instance_data/UserFiles
mkdir -p -m 0775 $instance_data/Galleries
mkdir -p -m 0775 $instance_data/Batch
 
tiki_db_host="localhost"
tiki_db_user="${domain%%.*}"
tiki_db_pass=$(openssl rand -hex 8)
tiki_db_name="$domain"
root_db_pass=''

{ \
    echo "<?php"; \
    echo "    \$db_tiki        = 'mysqli';"; \
    echo "    \$dbversion_tiki = '$version';"; \
    echo "    \$host_tiki      = '$tiki_db_host';"; \
    echo "    \$user_tiki      = '$tiki_db_user';"; \
    echo "    \$pass_tiki      = '$tiki_db_pass';"; \
    echo "    \$dbs_tiki       = '$tiki_db_name';"; \
    echo "    \$client_charset = 'utf8mb4';"; \
    echo "    \$system_configuration_file = dirname(__FILE__) . '/local.ini';"; \
    echo "    \$system_configuration_identifier = 'tikiwiki'"; \
} > "$instance_conf/local.php";

{ \
    echo "[tikiwiki]"
    echo "preference.feature_file_galleries_batch = y"; \
    echo "preference.fgal_use_db = n"; \
    echo "preference.gal_use_db = n"; \
    echo "preference.t_use_db = n"; \
    echo "preference.uf_use_db = n"; \
    echo "preference.w_use_db = n"; \
    echo "preference.fgal_batch_dir = $instance_data/Batch"; \
    echo "preference.fgal_use_dir = $instance_data/FileGalleries"; \
    echo "preference.gal_use_dir = $instance_data/Galleries"; \
    echo "preference.t_use_dir = $instance_data/TrackerAttachments"; \
    echo "preference.uf_use_dir = $instance_data/UserFiles"; \
    echo "preference.w_use_dir = $instance_data/WikiAttachments"; \
} > "$instance_conf/local.ini";

mysql -uroot -p"${root_db_pass}" -h"${tiki_db_host}" <<EOF
    CREATE DATABASE IF NOT EXISTS \`${tiki_db_name}\`;
    GRANT ALL PRIVILEGES ON \`${tiki_db_name}\`.* TO \`${tiki_db_user}\`@\`%\` IDENTIFIED BY '${tiki_db_pass}';
EOF

if [ ! -e "${instance_html}" ] || [ -z "$(ls ${instance_html})" ];
then
    git clone --branch="${version}" --depth=1 --no-single-branch "${tikiwiki_repo}" "${instance_html}"
fi

echo '<?php include(__DIR__ . "/../../conf/local.php");' > "${instance_html}/db/local.php";
chown -R apache ${instance_html}/dump
chown -R apache ${instance_html}/img/wiki
chown -R apache ${instance_html}/img/wiki_up
chown -R apache ${instance_html}/modules/cache
chown -R apache ${instance_html}/temp
chown -R apache ${instance_html}/data

cd "${instance_html}"
composer install -d "vendor_bundled" --prefer-dist --no-dev
php console.php database:install
php console.php index:rebuild
php console.php cache:clear