FROM centos:6.9
MAINTAINER Luke Hutton <luke.hutton.oracle@gmail.com>

ENV HOLDING_ENV       my_env

RUN yum install -y \
yum clean all                       && \
rm -rf /var/cache/yum

# config, build, install Nagios NRPE
RUN cd /tmp                                                                  																&& \
git clone https://github.com/NagiosEnterprises/nsca.git -b $NRPE_BRANCH  																		&& \
cd nrpe                                                                  																		&& \
./configure                                   																															\
    --with-ssl=/usr/bin/openssl               																															\
    --with-ssl-lib=/usr/lib/x86_64-linux-gnu 																																&& \
make check_nrpe                                                         																		&& \
cp src/check_nrpe ${NAGIOS_HOME}/libexec/                                																		&& \
make clean
