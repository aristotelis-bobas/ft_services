# OPERATING SYSTEM
FROM 		alpine

# COPY FILES
COPY		srcs/. /root/

# INSTALL PACKAGES
RUN 		apk update && \
			apk add wget libc6-compat

# INSTALL GRAFANA
RUN         wget https://dl.grafana.com/oss/release/grafana-6.7.3.linux-amd64.tar.gz && \
            tar -zxvf grafana-6.7.3.linux-amd64.tar.gz && \
            rm -rf grafana-6.7.3.linux-amd64.tar.gz

# CONFIGURE GRAFANA
RUN         mv /root/grafana.ini /etc/grafana && \
            mv /root/datasource.yml /grafana-6.7.3/conf/provisioning/datasources && \
            mv /root/*.json /grafana-6.7.3/conf/provisioning/dashboards && \
            mv /root/dashboard.yml /grafana-6.7.3/conf/provisioning/dashboards 

# START SERVICE
CMD         cd grafana-6.7.3 && ./bin/grafana-server --config=/etc/grafana