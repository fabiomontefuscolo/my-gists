#!/bin/bash

SELF="${0}"

tiki_path=""

safe_user="root"
safe_group="root"

web_user="$(grep -Eo '^(apache|httpd|wwwrun|www-data)' /etc/passwd)"
web_group=""

if [ -n "${web_user}" ];
then
    web_group=$(id -g --name "${web_user}")
fi

while true; do
  case "$1" in
    --tiki-path )
        tiki_path="$2"
        shift 2
        ;;
    --safe-user )
        safe_user="$2"
        shift
        ;;
    --safe-group )
        safe_group="$2"
        shift
        ;;
    --web-user )
        web_user="$2"
        shift
        ;;
    --web-group )
        web_group="$2"
        shift
        ;;
    -- )
        shift
        break
        ;;
    * )
        break
        ;;
  esac
done

if [ -z "${tiki_path}" ];
then
    echo "${SELF} --tiki-path <tiki-path>" >&2
    exit 1
fi

if [ ! -r "${tiki_path}/lib/setup/twversion.class.php" ];
then
    echo "Tiki not detected at ${tiki_path}" >&2
    exit 1
fi

if [ -z "${web_user}" ] || [ -z "${web_group}" ];
then
    echo 'Can not figure out the user/group running Apache/PHP' >&2
    exit 1
fi

find "${tiki_path}" -type d -exec chmod 755 {} \;
chown -R "${safe_user}":"${safe_group}" "$tiki_path"

chown -R ${web_user}:${web_group} ${tiki_path}/dump
chown ${safe_user} dump
chmod 1775         dump
chown ${safe_user} dump/index.php
chown ${safe_user} dump/.htaccess

chown -R ${web_user}:${web_group} ${tiki_path}/img/trackers
chown ${safe_user} img/trackers
chmod 1775         img/trackers
chown ${safe_user} img/wiki/index.php

chown -R ${web_user}:${web_group} ${tiki_path}/img/wiki
chown ${safe_user} img/wiki
chmod 1775         img/wiki
chown ${safe_user} img/wiki/index.php
chown ${safe_user} img/wiki/README

chown -R ${web_user}:${web_group} ${tiki_path}/img/wiki_up
chown ${safe_user} img/wiki_up
chmod 1775         img/wiki_up
chown ${safe_user} img/wiki_up/index.php
chown ${safe_user} img/wiki_up/README

chown -R ${web_user}:${web_group} ${tiki_path}/modules/cache
chown ${safe_user} modules/cache
chmod 1775         modules/cache
chown ${safe_user} modules/cache/index.php
chown ${safe_user} modules/cache/README

chown -R ${web_user}:${web_group} ${tiki_path}/storage
chown ${safe_user} storage
chmod 1775         storage
chown ${safe_user} storage/index.php
chown ${safe_user} storage/.htaccess
chown ${safe_user} storage/public
chmod 1775         storage/public
chown ${safe_user} storage/public/index.php
chown ${safe_user} storage/public/.htaccess

chown -R ${web_user}:${web_group} ${tiki_path}/temp
chown ${safe_user} temp/
chmod 1775         temp/
chown ${safe_user} temp/index.php
chown ${safe_user} temp/.htaccess
chown ${safe_user} temp/web.config
chown ${safe_user} temp/README

chown ${safe_user} temp/public
chmod 1775         temp/public
chown ${safe_user} temp/public/index.php
chown ${safe_user} temp/public/.htaccess

chown ${safe_user} temp/templates_c
chmod 1775         temp/templates_c
chown ${safe_user} temp/templates_c/index.php

chown ${safe_user} temp/cache
chmod 1775         temp/cache
chown ${safe_user} temp/cache/index.php

chown ${safe_user} temp/mail_attachs
chmod 1775         temp/mail_attachs
chown ${safe_user} temp/mail_attachs/index.php
chown ${safe_user} temp/mail_attachs/README
