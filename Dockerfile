FROM alpine:3

ARG FRONTEND_TAG=1.0.0
ARG BACKEND_TAG=1.0.0

RUN apk add nginx \
        php7 php7-fpm php7-mbstring php7-gd php7-json php7-redis php7-igbinary \
        php7-iconv php7-openssl php7-zip php7-ldap php7-bcmath php7-xml \
        php7-curl php7-pdo php7-pdo_mysql php7-mysqlnd php7-session php7-phar \
        php7-fileinfo php7-tokenizer php7-dom php7-xmlwriter \
        nodejs npm git
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --quiet; \
    rm composer-setup.php; \
    mv composer.phar /usr/bin/composer
RUN mkdir /smoothwiki; \
    cd /smoothwiki; \
    git clone https://github.com/awonderful/smoothwiki-frontend.git --branch $FRONTEND_TAG --single-branch; \
    cd /smoothwiki/smoothwiki-frontend; \
    rm package-lock.json; \
    npm install; \
    npm run build; \
    cd /smoothwiki; \
    git clone https://github.com/awonderful/smoothwiki-backend.git --branch $BACKEND_TAG --single-branch; \
    cd /smoothwiki/smoothwiki-backend; \
    composer install; \
    cp .env.example .env; \
    sed -i 's/LOG_CHANNEL=.*$/LOG_CHANNEL=daily/' .env; \
    chown -R nobody:nobody /smoothwiki/smoothwiki-backend/storage; \
    chown -R nobody:nobody /smoothwiki/smoothwiki-backend/bootstrap/cache; \
    php artisan optimize:clear
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY entrypoint.sh /smoothwiki/
ENTRYPOINT /smoothwiki/entrypoint.sh
EXPOSE 80
VOLUME ["/smoothwiki/smoothwiki-backend/storage"]