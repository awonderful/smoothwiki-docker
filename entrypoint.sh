#!/bin/sh
cd /smoothwiki/smoothwiki-backend
IFS='='
env | while read -r key value; do
  if [[ $key == ENV_* ]]; then
    realKey=`echo $key|sed 's/^ENV_//'`
    sed -i "s/$realKey=.*$/$realKey=$value/" .env
  fi
done
php artisan migrate
chown -R nobody:nobody /smoothwiki/smoothwiki-backend/storage
nohup php-fpm7 &
nginx -g "daemon off;"