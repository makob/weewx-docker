FROM alpine:latest

# Comma-separated list of plugins (URLs) to install
ARG INSTALL_PLUGINS="\
https://github.com/makob/weewx-mqtt-input/releases/download/0.6/weewx-mqtt-input-0.6.zip"

# TODO: It looks like this plugin isn't quite ready for weewx5 ?
# https://github.com/matthewwall/weewx-mqtt/archive/master.zip,\

ENTRYPOINT ["/home/weewx/bin/weewxd", "-x"]
WORKDIR /home/weewx

# Install WeeWX and dependencies
# ephem requires gcc so we use a virtual apk environment for that
RUN apk add --no-cache \
        rsyslog \
	mysql-client \
	openssh-client \
	rsync \
	python3 \
	py3-configobj \
	py3-cheetah \
	py3-pip \
	py3-wheel \
	py3-mysqlclient \
	py3-pillow \
	py3-paho-mqtt &&\
    apk add --no-cache --virtual .build-deps build-base python3-dev &&\
    pip3 install ephem &&\
    apk del .build-deps &&\
    pip3 install weewx

# Container-friendly rsyslog config to output to stdout/stderr
COPY rsyslog.conf /etc/rsyslog.conf

# Copy default config file to /home/weewx/weewx.conf
RUN find /usr/lib -name weewx.conf ! -path \*/util/\* -exec cp {} . \;

# Make sure non-root has access the default outputs
RUN mkdir /home/weewx/archive /home/weewx/public_html &&\
    chmod 777 /home/weewx/archive /home/weewx/public_html &&\
    touch /home/weewx/weewx.conf &&\
    chmod 666 /home/weewx/weewx.conf

# Install plugins. weectl (python logger) requires syslog.
# Remove backup config files afterwards.
RUN syslogd & \
    if [ ! -z "${INSTALL_PLUGINS}" ]; then \
      OLDIFS=$IFS; \
      IFS=','; \
      for PLUGIN in ${INSTALL_PLUGINS}; do \
        weectl extension install --yes $PLUGIN ; \
      done; \
      IFS=$OLDIFS; \
    fi; \
    rm -f /home/weewx/weewx.conf.*
