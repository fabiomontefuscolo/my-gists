## Instalação dos pacotes do Ubuntu

```sh
apt-get install pv nginx-extras                                   \
    php-fpm php-gd php-mbstring php-cli php-mysql php-zip php-xml \
    mariadb-server mariadb-client
```

## Instalação do WP-CLI

```sh
curl -o /usr/local/bin/wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /usr/local/bin/wp
```

```sh
cat > /etc/cron.daily/wp-cli-update << EOF
#!/bin/bash
wp --allow-root cli update --stable --yes
EOF
chmod +x /etc/cron.daily/wp-cli-update
```


## Instalação do composer

```
curl -o /usr/local/bin/composer -L https://getcomposer.org/composer.phar
chmod +x /usr/local/bin/composer
```

```sh
cat > /etc/cron.daily/composer-update << EOF
#!/bin/bash
composer self-update --no-interaction --stable
EOF
chmod +x /etc/cron.daily/composer-update
```

## Instalação do projeto

```sh
cd /var/www/html
git clone git@gitlab.com:gitlabteam/theexample.git
```

```sh
mysql -e 'CREATE DATABASE `theexample.org`;'
mysql -e 'GRANT ALL PRIVILEGES ON `theexample.org`.* TO `theexample.org`@localhost IDENTIFIED BY "thedatabasepassword";'

scp root@xxx.xxx.xxx.xxx:theexample.sql.gz ~/theexample.sql.gz
zcat ~/theexample.sql.gz | pv | mysql theexample.org
```

```
rsync -avz root@xxx.xxx.xxx.xxx:/var/www/html/theexample.org/public_html/wp-content/uploads/ /var/www/html/theexample.org/web/app/uploads/
```

```sh
cd /var/www/html/theexample
composer install
cp .env.example .env
wp --allow-root package install aaemnnosttv/wp-cli-dotenv-command
wp --allow-root dotenv salts regenerate
wp --allow-root dotenv set DB_NAME theexample.org
wp --allow-root dotenv set DB_USER theexample.org
wp --allow-root dotenv set DB_PASSWORD thedatabasepassword
wp --allow-root dotenv set WP_ENV production
wp --allow-root dotenv set WP_HOME https://theexample.org
```

## Letsencrypt

```sh
curl -o /usr/local/bin/certbot -L https://dl.eff.org/certbot-auto
chmod +x /usr/local/bin/certbot
rsync -avz root@xxx.xxx.xxx.xxx:/etc/letsencrypt/ /etc/letsencrypt/
```

```sh
cat > /etc/cron.daily/letsencrypt-renew << \EOF
#!/bin/bash
certbot renew --post-hook "nginx -t && systemctl restart nginx"
EOF
chmod +x /etc/cron.daily/letsencrypt-renew
```

## Configuração do NGINX

```sh
cat > /etc/nginx/conf.d/common.conf << \EOF
fastcgi_cache_path /var/cache/nginx levels=1:2 keys_zone=php_cache:100m inactive=1d;
fastcgi_cache_key "$scheme$request_method$host$request_uri";

upstream php {
    server unix:/var/run/php/php7.2-fpm.sock;
}
EOF
```

```sh
cat > /etc/nginx/letsencrypt.conf << \EOF
location /.well-known/acme-challenge/ {
    allow all;
    root /usr/share/nginx/html;
    try_files $uri =404;
    break;
}
EOF
```

```sh
cat > /etc/nginx/theexample-redirections.conf << \EOF
location /premio-de-bike-ao-trabalho-sao-paulo {
    return 301 $scheme://$server_name/premio;
}
EOF
```

```sh
cat > /etc/nginx/sites-enabled/001-theexample.org << \EOF
server {
    listen 80;
    server_name theexample.org www.theexample.org;

    include letsencrypt.conf;
    include theexample-redirections.conf;

    location / {
        return 301 https://theexample.org$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name theexample.org www.theexample.org;

    ssl_certificate /etc/letsencrypt/live/theexample.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/theexample.org/privkey.pem;

    access_log   /var/log/nginx/theexample.org.access.log;
    error_log    /var/log/nginx/theexample.org.error.log;

    gzip on;
    gzip_disable "msie6";

    gzip_min_length 1100;
    gzip_buffers 16 8k;
    gzip_types
        text/plain
        text/css
        text/js
        text/javascript
        application/javascript
        application/x-javascript
        application/json;

    client_max_body_size 50m;

    root /var/www/html/theexample.org/web;
    index index.php index.html;

    set $no_cache 0;
    if ($request_uri ~* "/wp-admin") { set $no_cache 1; }
    if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in")  { set $no_cache 1; }

    include letsencrypt.conf;
    include theexample-redirections.conf;
    rewrite ^/wp-content(/.*)$ /app$1  last;

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        return 200 "User-agent: *\nDisallow: /wp-admin";
    }

    location ^~ /xmlrpc.php {
        deny all;
    }

    location ^~ /app/uploads/ {
        expires max;
    }

    location ^~ /status/ {
        stub_status on;
        allow 127.0.0.1;
        deny all;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include fastcgi.conf;

        fastcgi_pass_header "X-Accel-Redirect";
        fastcgi_pass_header "X-Accel-Expires";
        
        ##
        ## Sometime you need to force
        ##
        #fastcgi_hide_header "Set-Cookie";
        #fastcgi_ignore_headers "Cache-Control" "Expires" "Set-Cookie";
        
        fastcgi_cache php_cache;
        fastcgi_cache_background_update on;
        fastcgi_cache_bypass $no_cache;
        fastcgi_cache_lock on;
        fastcgi_cache_use_stale error timeout invalid_header updating;
        fastcgi_cache_valid 200 301 302 60m;
        fastcgi_cache_valid 404 1m;
        fastcgi_no_cache $no_cache;

        add_header X-Cache $upstream_cache_status;

        fastcgi_pass php;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found on;
    }
}
EOF
```
