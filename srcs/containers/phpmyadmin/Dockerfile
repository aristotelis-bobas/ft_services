# OPERATING SYSTEM
FROM 		alpine

# COPY FILES
COPY		srcs/. /root/

# INSTALL PACKAGES
RUN 		apk upgrade && \
			apk add wget php7 php7-fpm php7-opcache php7-gd php7-mysqli php7-zlib php7-curl php7-mbstring php7-json php7-session

# CONFIGURE PHPMYADMIN DASHBOARD
RUN 		wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz && \
            tar xzfv phpMyAdmin-5.0.1-english.tar.gz && \
            mv phpMyAdmin-5.0.1-english /www && \
			rm -rf phpMyAdmin-5.0.1-english.tar.gz && \
            mv /root/config.inc.php /www

# START SERVICE
CMD         php -S 0.0.0.0:5000 -t /www/