#!/bin/sh

# python logger needs syslog
echo "$0: starting rsyslogd..."
rsyslogd &

# now start weewx in virtual environment
if [ "${WEEWX_USER}" != "" ]; then
    echo "$0: starting weewx as user '${WEEWX_USER}'..."
    su ${WEEWX_USER} -c 'weewxd -x /home/weewx/weewx.conf'
    RC=$?
else
    echo "$0: starting weewx as root..."    
    weewxd --exit /home/weewx/weewx.conf
    RC=$?
fi
   
echo "$0: weewx has terminated with error code ${RC}, bye"
exit ${RC}
