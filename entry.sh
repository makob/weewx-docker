#!/bin/sh

# python logger needs syslog
echo "$0: starting rsyslogd..."
rsyslogd &
. /root/pyvenv/bin/activate

echo "$0: updating database..."
weectl database update --yes

echo "$0: starting weewx..."
weewxd --exit /root/weewx-data/weewx.conf
RC=$?

echo "$0: weewx has terminated with error code ${RC}, bye"
deactivate
exit ${RC}
