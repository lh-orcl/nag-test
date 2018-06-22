FROM centos:6.9
MAINTAINER Luke Hutton <luke.hutton.oracle@gmail.com>

# Initally working from:
#       puguy83/docker-nagios
#       asonRivers/Docker-Nagios

ENV NAGIOS_HOME				/opt/nagios
ENV NAGIOS_USER				nagios
ENV NAGIOS_GROUP 			nagios
ENV NAGIOS_CMDUSER			nagioscmd
ENV NAGIOS_CMDGROUP			nagioscmd
ENV NAGIOSADMIN_USER		nagiosadmin
ENV NAGIOSADMIN_PASS		nagios
ENV APACHE_RUN_USER			nagios
ENV APACHE_RUN_GROUP		nagios
ENV NAGIOS_TIMEZONE			UTC

# Download repo to allow for "runit" install
RUN ( curl -s https://packagecloud.io/install/repositories/imeyer/runit/script.rpm.sh | bash )

RUN yum install -y \
	gcc \
	gd \
	gd-devel \
	glibc \
	glibc-common \
	httpd \
	php \
	perl \
	openssl \
	openssl-devel \
	net-snmp \
	mysql \
	mysql-server \
	mysql-devel \
	rsyslog \
	runit \
&& yum clean all \
&& rm -rf /var/cache/yum

# Check for existing users/groups and modify as required
RUN ( egrep -i $NAGIOS_GROUP /etc/group || groupadd $NAGIOS_GROUP )										&& \
	( egrep -i $NAGIOS_CMDGROUP /etc/group || groupadd $NAGIOS_CMDGROUP )
RUN ( id -u $NAGIOS_USER    || useradd --system -d $NAGIOS_HOME -g $NAGIOS_GROUP    $NAGIOS_USER    )	&& \
  ( id -u $NAGIOS_CMDUSER || useradd --system -d $NAGIOS_HOME -g $NAGIOS_CMDGROUP $NAGIOS_CMDUSER )	&& \
	( egrep -i apache /etc/passwd && usermod -a -G $NAGIOS_CMDUSER apache )

# Config, build, install Nagios
RUN cd /tmp																								&& \
	curl -O https://datapacket.dl.sourceforge.net/project/nagios/nagios-3.x/nagios-3.5.1/nagios-3.5.1.tar.gz && \
	tar -xvzf nagios-3.5.1.tar.gz																		&& \
	cd nagios																							&& \
	./configure --with-command-group=nagioscmd --enable-nanosleep --enable-event-broker--with-nagios-command-user=nagioscmd --with-nagios-user=$NAGIOS_USER --with-nagios-group=$NAGIOS_GROUP --prefix=$NAGIOS_HOME --exec-prefix=$NAGIOS_HOME && \
	make all	&& \
	make install 																						&& \
	make install-config																					&& \
	make install-commandmode																			&& \
	make install-webconf																				&& \
	make clean

# Set auth on Nagios site
RUN htpasswd -cb $NAGIOS_HOME/etc/htpasswd.user $NAGIOSADMIN_USER $NAGIOSADMIN_PASS

# Config, build, install Nagios Plugins
RUN cd /tmp																								&& \
	curl -O https://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz							&& \
	tar -xvzf nagios-plugins-1.5.tar.gz																	&& \
	cd nagios-plugins-1.5																				&& \
	./configure --with-nagios-user=$NAGIOS_USER --with-nagios-group=$NAGIOS_GROUP --prefix=$NAGIOS_HOME	&& \
	make																								&& \
	make install																						&& \
	make clean

# Clean /tmp to reduce image size
RUN rm -rf /tmp/*

# Set Apache ServerName (silence Apache warning)
RUN sed -i 's/\#ServerName www.example.com:80/ServerName localhost/g' /etc/httpd/conf/httpd.conf

# Custom config for monitoring local Nagios server (TEST)
RUN sed -i 's/check_load -w/check_load -r -w/g' /opt/nagios/etc/objects/commands.cfg
RUN sed -i 's/check_local_load!5.0,4.0,3.0!10.0,6.0,4.0/check_local_load!1.0,0.8,0.6!2.0,1.8,1.2/g' /opt/nagios/etc/objects/localhost.cfg

RUN sed -i 's/\#cfg_dir=\/opt\/nagios\/etc\/servers/cfg_dir=\/opt\/nagios\/etc\/servers/g' /opt/nagios/etc/nagios.cfg

# Set Nagios site as default
RUN mv /etc/httpd/conf.d/nagios.conf /etc/httpd/conf.d/00-nagios.conf

RUN echo "use_timezone=${NAGIOS_TIMEZONE}" >> ${NAGIOS_HOME}/etc/nagios.cfg

# Remove default syslog config
RUN rm -rf /etc/rsyslog.d /etc/rsyslog.conf

# Load resources (config files, startup scripts for each service)
ADD resources/ /
ADD resources/start_nagios /usr/local/bin/start_nagios

RUN chmod -R +x /opt/nagios/etc/
RUN chmod +x /usr/local/bin/start_nagios
RUN chmod -R +x /etc/service

EXPOSE 80

# Go!
CMD [ "/usr/local/bin/start_nagios" ]
