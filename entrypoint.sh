#!/bin/ash
USERDIR=/var/user
set -e

# Entrypoint file for WeeWX. The purpose is to populate the 'user
# directory' with default files in case they do not exist.

if [ ! -d ${USERDIR} ];
then
    echo "error: ${USERDIR} does not exist"
fi

# Copy files from weewx. If anything we copied/create.
STOP=0
if [ ! -f ${USERDIR}/weewx.conf ];
then
    echo "created file 'weewx.conf'"
    cp /home/weewx/weewx.conf ${USERDIR}
    STOP=1
fi
for DIR in public_html archive ssh;
do
    if [ ! -d ${USERDIR}/${DIR} ];
    then
	mkdir ${USERDIR}/${DIR}
	echo "created directory '${DIR}'"
	STOP=1
    fi
done
if [ ${STOP} == 1 ];
then
    echo "stop: please check all files before continuing"
    exit 1
fi

# Run
/home/weewx/bin/weewxd ${USERDIR}/weewx.conf
