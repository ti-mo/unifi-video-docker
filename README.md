# UniFi Video Docker Image

This image aims to provide a stable, platform-agnostic way to run a UniFi Video controller.
Wire up the storage and run! Read the [Networking](#networking) section for information.

## Running

This is an example `docker run` command for running the image:

```
docker run \
    --name unifi-video \
    --cap-add DAC_READ_SEARCH \
    -p 7442:7442 \
    -p 7443:7443 \
    -p 7445:7445 \
    -p 7446:7446 \
    -p 7447:7447 \
    -p 7080:7080 \
    -p 6666:6666 \
    --tmpfs /unifi-tmpfs \
    -v <data-volume>:/unifi-video/data \
    -v <logs-volume>:/unifi-video/logs \
    -e TZ=Europe/Brussels \
    -e PUID=9000 \
    -e PGID=9001 \
    -e DEBUG=yes \
    tibs/unifi-video
```

- Mounting a tmpfs at `/unifi-tmpfs` (using `--tmpfs` or `--mount`) will make it serve
as a write buffer for incoming video. Ownership of the tmpfs is automatically corrected.
- `PUID` and `PGID` are the UID/GID the `unifi-video` service will run as inside the container.
*The user is responsible for making the data and log volumes writable for these UID/GIDs.*
- Set `DEBUG` to any value to enable `jsvc` startup debugging. Logs can be retrieved using `docker logs`.
- Default timezone is `Etc/UTC`. Set the `TZ` environment variable to customize.

## Networking

This service uses broadcast to automatically discover unmanaged cameras attached to the network.
Even though it's possible to associate each camera with the (bridged) controller manually,
using the port configuration above, this is a time-consuming process and probably not the
experience the user is looking for.

Running `--net=host` has security implications, so using a
[Docker `macvlan` network](https://docs.docker.com/engine/userguide/networking/get-started-macvlan)
is highly recommended. Running the UniFi Video controller inside the same broadcast domain
as the cameras (and any mobile clients) will yield the best user experience.

## Building

Check the `Makefile` for the variables used in building.
To build the image locally, run `$ make`.

Building and pushing the image can be done using `$ make all`.
