# OPERATING SYSTEM
FROM 		alpine

# COPY FILES
COPY		srcs/. /root/

# INSTALL PACKAGES
RUN 		apk upgrade && \
			apk add nginx openssl openssh openrc

# CONFIGURE SSL
RUN 		openssl req -newkey rsa:2048 -nodes -x509 -days 365 \
            -subj '/C=NL/L=Amsterdam/O=Codam/OU=42/CN=abobas' \
            -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt

# CONFIGURE SSH
RUN         echo 'root:password' | chpasswd && \
            ssh-keygen -A && \
            mv /root/sshd_config /etc/ssh && \
            openrc && \
            touch /run/openrc/softlevel && \
            rc-update add sshd

# CONFIGURE NGINX
RUN 		mv /root/nginx.conf /etc/nginx && \
            mkdir -p /run/nginx && \
            mv  /root/index.html /var/www/localhost/htdocs

# START SERVICE
CMD         /etc/init.d/sshd start && \
            nginx -g 'daemon off;'