FROM	debian:buster
#패키지 설치
RUN		apt-get update && apt-get -y install \
		wget \
		nginx \
		openssl \
		php7.3-fpm \
		mariadb-server \
		php-mysql
#wget을 이용한 Wordpress와 phpmyadmin설치
RUN		wget https://wordpress.org/latest.tar.gz \
		&& tar -zxvf latest.tar.gz \
		&& rm latest.tar.gz \
		&& mv wordpress/ /var/www/html/ \
		&& chown -R www-data:www-data /var/www/html/wordpress \
		&& wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
		&& tar -zxvf phpMyAdmin-5.0.2-all-languages.tar.gz \
		&& rm phpMyAdmin-5.0.2-all-languages.tar.gz \
		&& mv phpMyAdmin-5.0.2-all-languages phpmyadmin \
		&& mv phpmyadmin /var/www/html \
#ssl 인증서 및 개인키 생성
		&& openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Lee/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt \
		&& mv localhost.dev.crt etc/ssl/certs/ \
		&& mv localhost.dev.key etc/ssl/private/ \
		&& chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key \
#MariaDB(mysql) 계정생성
		&& service mysql start \
		&& mysql -u root \
		&& echo "create database wordpress;" | mysql -u root --skip-password \
		&& echo "CREATE USER 'hanwoori'@'localhost'IDENTIFIED BY '1234';" | mysql -u root --skip-password \
		&& echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'hanwoori'@'localhost'WITH GRANT OPTION; " | mysql -u root --skip-password

COPY 	./srcs/wp-config.php /var/www/html/wordpress/
COPY	./srcs/config.inc.php /var/www/html/phpmyadmin/
COPY	./srcs/default /etc/nginx/sites-available/
COPY	./srcs/run.sh ./

EXPOSE	80 443

CMD		sh run.sh