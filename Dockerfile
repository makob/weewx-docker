FROM alpine:3.19

# Comma-separated list of plugins (URLs) to install
ARG INSTALL_PLUGINS="\
https://github.com/makob/weewx-mqtt-input/releases/download/0.6/weewx-mqtt-input-0.6.zip,\
https://github.com/matthewwall/weewx-mqtt/archive/master.zip"

WORKDIR /home/weewx

# Container-friendly rsyslog config to output to stdout/stderr
COPY rsyslog.conf /etc/rsyslog.conf

# Install WeeWX and dependencies
# ephem requires gcc so we use a virtual apk environment for that
RUN apk add --no-cache \
        rsyslog \
	mysql-client \
	openssh-client \
	rsync \
	python3 \
	py3-pip \
	py3-wheel \
	py3-paho-mqtt \
	py3-pymysql && \
    apk add --no-cache --virtual .build-deps build-base python3-dev && \
    pip install --break-system-packages ephem && \
    pip install --break-system-packages weewx && \
    apk del .build-deps

# Copy simple entrypoint and set it
COPY entry.sh /home/weewx/entry.sh
ENTRYPOINT ["/home/weewx/entry.sh"]

# Make sure all users have access the default outputs
RUN mkdir /home/weewx/archive /home/weewx/public_html &&\
    chmod 777 /home/weewx/archive /home/weewx/public_html

# Setup symlink to weewx_data and prep default config
RUN WD=$(find /usr/lib -name weewx_data) && \
    ln -s ${WD} weewx_data && \
    echo "WEEWX_ROOT=/home/weewx/weewx_data" > weewx.conf && \
    cat weewx_data/weewx.conf >> weewx.conf && \
    chmod 666 weewx.conf

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

# Locally sourced plugins, for development. Copy zip files into "plugins-from-local". Files remain in image.
RUN mkdir plugins-from-local && \
    find plugins-from-local -name '*.zip' -print0 | xargs -0 -r -n 1 weectl extension install --yes
