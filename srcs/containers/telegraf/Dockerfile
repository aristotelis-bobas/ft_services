# OPERATING SYSTEM
FROM 		alpine

# COPY FILES
COPY		srcs/. /root/

# INSTALL PACKAGES
RUN 		apk update && \
			apk add wget


# INSTALL TELEGRAF
RUN			wget https://dl.influxdata.com/telegraf/releases/telegraf-1.14.2-static_linux_amd64.tar.gz && \
			tar -zxvf telegraf-1.14.2-static_linux_amd64.tar.gz && \
			rm -rf telegraf-1.14.2-static_linux_amd64.tar.gz && \
			chmod +x telegraf/* && \
			mv telegraf/telegraf /usr/bin && \
			mkdir etc/telegraf && \
			mv	root/telegraf.conf /etc/telegraf

# START SERVICE
CMD       	telegraf