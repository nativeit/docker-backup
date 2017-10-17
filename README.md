docker-backup
=============
Fork from: https://github.com/boombatower/docker-backup

My approach is to create a light image using *Alpine*.
Respecting the original documentation but skipping S3 option, the following:

Simple utility for backing up a Docker data container.

other solutions
---------------
There are a number of existing solutions available which typically operate in a
similar fashion.

- `docker inspect` (api call) to determine volumes provided by a container
- access container volumes using `--volumes-from` or `/var/lib/docker/vfs/dir`
- store container description (from inspect) and volumes
- restore using container description to re-create data container before
  restoring files

The above approach results in a fairly sizable tool mostly due to unuseful
complexity which unfortunately also restricts flexibility.

advantages
----------
Unlike other solutions this tool opperates entirely from within the container
in which it resides. There is no communication with Docker API or storage of
data container description. This results in a number of advantages and provides
increased flexibility as described below.

- does not break on Docker API change or container description format
- restore into container using different image
- merge backups into single data container
- simplicity allows for easy customization and expansion
  - does not act like a daemon to allow scheduling via typical system tools
  - separates base backup from remote storage
- does not require bind mounting the docker socket nor `/var/lib/docker/vfs/dir`

assumptions
-----------
This tool assumes that the data container it is to operate on exists. In the
event of a catastrophic failure this means the data container must be
initialized before this tool can restore the data into it.

Typically that will look something like the following.
```sh
$ docker run --name data-container -v /some/volume boombatower/opensuse /bin/true
```

usage
-----
```
backup.sh backup|restore [filename]
- filename: backup.tar.xz
Environment variables:
- optional: TAR_OPTS
```

Backups are placed in the `/backup` directory which is exposed as a volume so
that other containers may access the tarballs after they are created. The
backup can either be transported directly from the container to remote storage
or using Docker bind mount can be extracted onto the host.

To dump backup archive from `data-container` into current directory:
```sh
$ docker run --rm \
  --volumes-from data-container \
  -v $(pwd):/backup \
  piscue/docker-backup backup
```

To restore:
```sh
$ docker run --rm \
  --volumes-from data-container \
  -v $(pwd):/backup \
  piscue/docker-backup restore
```

To use a date based file name and add `--verbose` flag to tar command:
```sh
$ docker run --rm \
  --volumes-from data-container \
  -v $(pwd):/backup \
  -e TAR_OPTS="--verbose" \
  piscue/docker-backup backup "$(date +%F_%R).tar.xz"
```

One interesting option would be to remove the `--rm` flag a simply let the
backup containers persist as they will provide a backup until they are removed.
Using other tools the containers could be perged at desired intervals. Since
this image exposes `/backup` as a volume the backup container could be accessed
via `--volumes-from` for the restore script.


systemd scheduling
------------------
If you are using CoreOS or similar it can be convenient to schedule the backups
using systemd and include them in your cloud-config. An example timer and
backup service are provided in [doc directory](doc).

docker registry
---------------
The Docker registry repositories can be found at:
- https://registry.hub.docker.com/u/piscue/docker-backup
