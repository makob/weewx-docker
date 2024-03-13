# weewx-docker
A Dockerfile for the WeeWX weather station.

## Installing the image

You can get this directly from Docker Hub with

```
docker pull makobdk/weewx5:latest
```

## Running the image

Please run this via docker-compose:

```
UID=`id -u' GID=`id -g` USER=`whoami` docker-compose up
```

Set the UID, GID and USER variables to whatever is appropriate for
your system.

You can use the `weewx5.service` file as a systemd user unit file.
Please check that the paths are correct.

Do have a look at the `docker-compose.yml` file to see what volumes
are mapped in (there are quite a lot of them).

You can copy out the default configuration once the container is
running with
`docker cp <CONTAINER_ID>:/home/weewx/weewx.conf default-weewx.conf`
so you don't start completely from scratch.

Note that if you don't map in the `public_html`, `archive` and
`weewx.conf` volumes, WeeWX will use the default configuration which
is basically to run in simulator mode.

The `passwd` volume map is needed for rsync; rsync requires the
current user to have an entry in /etc/passwd. Redirect
`getent passwd $USER`
to a file and mount that if you want to expose a more limited set of
users to the container.

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

Note that the Dockerfile patches WeeWX to output log messages to the
console.

There's also a `make push` target for pushing the image to Docker Hub,
although that will only work if you have access to my repository.
