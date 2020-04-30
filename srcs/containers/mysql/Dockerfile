# OPERATING SYSTEM
FROM 		alpine

# COPY FILES
COPY		srcs/. /root/

# INSTALL PACKAGES
RUN 		apk upgrade && \
			apk add mysql mysql-client

# CONFIGRE MYSQL
RUN 		mkdir -p /run/mysqld && \
            mv /root/my.cnf /etc/mysql/my.cnf
VOLUME      ["/var/lib/mysql"]

# START SERVICE
CMD         mysql_install_db --user=root --skip-test-db && \
            touch text && \
            echo "flush privileges;" >> text && \
            echo "grant all privileges on *.* to 'root' identified by 'password' with grant option;" >> text && \
            echo "flush privileges;" >> text && \
            /usr/bin/mysqld --user=root --bootstrap < text && \
            rm -rf text && \
            /usr/bin/mysqld --user=root


