# weewx-docker
A Dockerfile for the WeeWX weather station.

## Installing the image

You can get this directly from Docker Hub with

```
docker pull makobdk/weewx4:latest
```

## Running the image

Please run this as a non-root user. For example

```
/usr/bin/docker run --rm --net=host \
  -u 1000:1000 \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/passwd:/etc/passwd:ro \
  -v /run/mysqld/mysqld.sock:/run/mysqld/mysqld.sock \
  -v /home/user/.ssh:/home/weewx/.ssh \
  -v /home/user/archive:/home/weewx/archive \
  -v /home/user/public_html:/home/weewx/public_html \
  -v /home/user/weewx.conf:/home/weewx/weewx.conf \
  weewx4
```

Replace the `1000:1000` and `user` with the appropriate username/ids
for your system.

Alternatively, if you use systemd on your host system have a look at
the `weewx4.service`. This is intended as a user service file.

You can copy out the default configuration once the container is
running with `docker cp <CONTAINER_ID>:/home/weewx/weewx.conf
default-weewx.conf` so you don't start completely from scratch.

Note that if you don't map in the `public_html`, `archive` and
`weewx.conf` volumes, WeeWX will use the default configuration which
is basically to run in simulator mode.

The `passwd` volume map is needed for rsync; rsync requires the
current user to have an entry in /etc/passwd. Use `getent passwd
$USER` if you want expose a more limited set of users to the
container.

Finally, the `mysqld.sock` volume mapping is needed when WeeWX is told
to connect to a localhost MySQL server which apparently is interpreted
as 'use a unix socket'.

## Building the image

Because I'm lazy, the provided Makefile can help you build the image:

```
make build
```

Use the `--build-arg INSTALL_PLUGINS="<urls>"` to specify a
comma-separated list of WeeWX plugins to install within the Docker
image.

The default `INSTALL_PLUGINS` is set to install the
following plugins:

* [weewx-mqtt](https://github.com/matthewwall/weewx-mqtt/)
* [weewx-mqtt-input](https://github.com/makob/weewx-mqtt-input)

Note that the Dockerfile patches WeeWX to output log messages to the
console.

There's also a `make push` target for pushing the image to Docker Hub,
although that will only work if you have access to my repository.
