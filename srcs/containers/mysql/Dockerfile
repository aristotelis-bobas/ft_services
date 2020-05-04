# OPERATING SYSTEM
FROM 		alpine

# COPY FILES
COPY		srcs/. /root/

# INSTALL PACKAGES
RUN 		apk update && \
			apk add mysql mysql-client

# CONFIGRE MYSQL
RUN 		mkdir -p /run/mysqld && \
            mv /root/my.cnf /etc/mysql/my.cnf

# START SERVICE
CMD         mysql_install_db --user=root --skip-test-db --datadir="/var/lib/mysql" && \
            touch text && \
            echo "create database if not exists wordpress;" >> text && \
            echo "create database if not exists grafana;" >> text && \
            echo "flush privileges;" >> text && \
            echo "grant all privileges on *.* to 'root'@'%' identified by 'password' with grant option;" >> text && \
            echo "flush privileges;" >> text && \
            /usr/bin/mysqld --user=root --bootstrap < text && \
            rm -rf text && \
            /usr/bin/mysqld --user=root