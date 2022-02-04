#!/bin/sh
cd /smoothwiki/smoothwiki-backend
php artisan key:generate

IFS='='
env | while read -r key value; do
  if [[ $key == ENV_* ]]; then
    realKey=`echo $key|sed 's/^ENV_//'`
    sed -i "s/$realKey=.*$/$realKey=$value/" .env
  fi
done

db_host=`cat /smoothwiki/smoothwiki-backend/.env|grep DB_HOST|cut -f2 -d=`
db_port=`cat /smoothwiki/smoothwiki-backend/.env|grep DB_PORT|cut -f2 -d=`
while ! nc -z $db_host $db_port; do
  echo 'waiting until mysql is ready!'
  sleep 5
done

php artisan migrate
chown -R nobody:nobody /smoothwiki/smoothwiki-backend/storage
nohup php-fpm7 &
nginx -g "daemon off;"