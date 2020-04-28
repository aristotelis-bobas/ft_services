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

# CONFIGURE USER AND DATABASE
RUN         mysql_install_db --user=root --verbose && \
            touch text && \
            echo "flush privileges;" >> text && \
            echo "grant all privileges on *.* to 'root' identified by 'password' with grant option;" >> text && \
            echo "flush privileges;" >> text && \
            /usr/bin/mysqld --user=root --bootstrap < text && \
            rm -rf text

# START SERVICE
CMD         /usr/bin/mysqld --user=root --console


