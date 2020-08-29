# weewx-docker
A Dockerfile for the WeeWX weather station.

## Running the image

Please run this as a non-root user. For example

```
docker run -u `id -u`:`id -g` \
       --net=host \
       -v ~/weewx_user_files:/var/user \
       -v /etc/localtime:/etc/localtime \
       -v /etc/timezone:/etc/timezone
       weewx4
```

will map in the local directory `~/weewx_user_files` as the user
directory where WeeWX will store all user-modifiable files (sqlite
archive, public_html and weewx.conf). If the user directory contents
are missing, they will be auto-generated/created. The contents
must be (at least):

```# tree ~/weewx_user_files
.
├── archive/			# sqlite database
├── public_html/		# generated HTML output
├── ssh/			# symlinked from /home/weewx/.ssh
└── weewx.conf			# the WeeWX config file
```

If you want to use rsync (with ssh) to upload files you should add the
necessary ssh keys to the ssh directory (e.g. `id_rsa.pub`).

## Building the image

Because I'm lazy, the provided Makefile can help you build the image:

```
make
```

Use the `--build-arg INSTALL_PLUGINS="<urls>"` to specify a
comma-separated list of WeeWX plugins to install within the Docker
image.

The default `INSTALL_PLUGINS` is set to install the
following plugins:

* [weewx-mqtt](https://github.com/matthewwall/weewx-mqtt/)
* [weewx-mqtt-input](https://github.com/makob/weewx-mqtt-input)

Note that the Dockerfile patches WeeWX to output log messages to the
console. It also modifies the default configuration to store various
files in /var/user, to which you should bind a volume.
