FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y git php php-mbstring php-curl php-sqlite3 composer php-tokenizer phpunit php-codecoverage php-phar-io-manifest
RUN git clone https://github.com/fkooman/php-remote-storage.git && \
cd /php-remote-storage && composer install
FROM debian:bullseye-slim
ENV version="1.0.5"
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y apache2 php php-mbstring php-curl libapache2-mod-xsendfile php-sqlite3 
COPY --from=0 /php-remote-storage /var/www/php-remote-storage
RUN cd /var/www/php-remote-storage && cp config/server.yaml.example config/server.yaml
RUN cd /var/www && mkdir data && chown www-data.www-data data && \
openssl genrsa -out /etc/ssl/private/storage.local.key 2048 && \
chmod 600 /etc/ssl/private/storage.local.key && \
openssl req -subj "/CN=storage.local" -sha256 -new -x509 -key /etc/ssl/private/storage.local.key -out /etc/ssl/certs/storage.local.crt && \
cp /var/www/php-remote-storage/contrib/storage.local.conf.ubuntu /etc/apache2/sites-available/storage.local.conf && \
a2enmod rewrite && \
a2enmod headers && \
a2enmod ssl && \
a2ensite default-ssl && \
a2ensite storage.local
CMD apachectl start
EXPOSE 80 443
