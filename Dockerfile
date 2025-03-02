FROM alpine:3.21

# Comma-separated list of plugins (URLs) to install
ARG INSTALL_PLUGINS="\
https://github.com/makob/weewx-mqtt-input/releases/download/1.0/weewx-mqtt-input-1.0.zip,\
https://github.com/matthewwall/weewx-mqtt/archive/master.zip"

WORKDIR /root

# Container-friendly rsyslog config to output to stdout/stderr
COPY rsyslog.conf /etc/rsyslog.conf

# Initial dependencies
RUN apk add --no-cache \
    python3 \
    rsyslog \
    mysql-client \
    openssh-client \
    rsync \
    py3-mysqlclient

# Python virtual environment
RUN python -m venv /root/pyvenv && \
    source /root/pyvenv/bin/activate && \
    pip install --upgrade pip

# Install WeeWX and dependencies
# ephem requires gcc so we use a virtual apk environment for that
RUN . /root/pyvenv/bin/activate && \
    apk add --no-cache --virtual .build-deps build-base python3-dev && \
    pip install wheel && \
    pip install paho-mqtt && \
    pip install ephem && \
    pip install weewx && \
    apk del .build-deps

# Copy simple entrypoint and set it
COPY entry.sh /root/entry.sh
ENTRYPOINT ["/root/entry.sh"]

# Make sure all users have access the default outputs
RUN mkdir /root/archive /root/public_html &&\
    chmod 777 /root/archive /root/public_html

# Setup symlink to weewx_data and prep default config
RUN syslogd & \
    . /root/pyvenv/bin/activate && \
    weectl station create --no-prompt --html-root=/root/public_html

# Install plugins. weectl (python logger) requires syslog.
# Remove backup config files afterwards.
RUN syslogd & \
    . /root/pyvenv/bin/activate && \
    if [ ! -z "${INSTALL_PLUGINS}" ]; then \
      OLDIFS=$IFS; \
      IFS=','; \
      for PLUGIN in ${INSTALL_PLUGINS}; do \
        weectl extension install --yes $PLUGIN ; \
      done; \
      IFS=$OLDIFS; \
    fi; \
    rm -f /root/weewx.conf.*

# Locally sourced plugins, for development. Copy zip files into "plugins-from-local". Files remain in image.
RUN . /root/pyvenv/bin/activate && \
    mkdir plugins-from-local && \
    find plugins-from-local -name '*.zip' -print0 | xargs -0 -r -n 1 weectl extension install --yes
