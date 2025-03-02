# weewx-docker

A Dockerfile for the WeeWX (version 5) weather station.

## Installing the image

You can get this directly from Docker Hub with
```
docker pull makobdk/weewx5:latest
```

## Running the image

Please run this via docker compose, i.e.
```
docker compose up
```
Do have a look at the `docker-compose.yml` file to see what volumes
are mapped in (there are quite a lot of them).

You can copy out the default configuration once the container is
running with
`docker cp <CONTAINER_ID>:/home/weewx/weewx.conf default-weewx.conf`
so you don't start completely from scratch.

Make sure you set `WEEWX_ROOT = /home/weewx/weewx_data` in `weewx.conf`.

## docker volumes

The example `docker-compose.yml` maps in quite a lot of stuff:

`/etc/localtime:/etc/localtime:ro` and `/etc/timezone:/etc/timezone:ro`
: Map in the host's local time and timezone; both read-ony

`/home/${USER}/weewx/passwd:/etc/passwd:ro` and `/home/${USER}/weewx/group:/etc/group:ro`
: These files are needed for rsync: rsync requires the current user to have an entry in /etc/passwd and /etc/group. To generate minimal files for this, use `getent passwd $USER > passwd` and `getent group $USER > group`. Also, please make sure you set the docker environment variable `WEEWX_USER`.

`/home/${USER}/weewx/archive:/home/weewx/archive`
: WeeWX database file if you don't use e.g. MySQL

`/home/${USER}/weewx/weewx.conf:/home/weewx/weewx.conf`
: The WeeWX configuration file

`/home/${USER}/weewx/html:/home/weewx/public_html`
: The WeeWX HTML output directory

`/home/${USER}/.ssh:/home/weewx/.ssh` and `/home/${USER}/.ssh:/root/.ssh`
: Map in the SSH keys. You probably want to do something like this if you use rsync.

Note that if you don't map in the `public_html`, `archive` and
`weewx.conf` volumes, WeeWX will use the default configuration which
is basically to run in simulator mode.

## Building the image

Because I'm lazy, the provided Makefile can help you build the image:
```
make build
```
Adjust the `INSTALL_PLUGINS="<url>,<url>,..."` variable in
`Dockerfile` to specify a comma-separated list of WeeWX plugins to
install within the Docker image.

The default `INSTALL_PLUGINS` is set to install the
following plugins:

* [weewx-mqtt](https://github.com/matthewwall/weewx-mqtt/)
* [weewx-mqtt-input](https://github.com/makob/weewx-mqtt-input)

## Other stuff

You can use the systemd `weewx5.service` user unit file as a starting
point. Please check that the paths are correct.

There's also examples on how to get the nginx webserver to expose
the generated HTML files.
