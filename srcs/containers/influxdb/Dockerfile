# OPERATING SYSTEM
FROM 		alpine

# INSTALL PACKAGES
RUN 		apk update && \
			apk add influxdb wget

# START SERVICE
CMD         influxd run -config /etc/influxdb.conf
