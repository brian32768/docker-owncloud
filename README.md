# ownCloud Docker Image

Deploy ownCloud easily.

## Build

````bash
docker build -t brian32768/owncloud:9.1 -f 9.1/Dockerfile .
docker build -t brian32768/owncloud:10.0 -f 10.0/Dockerfile .
````

VERSION 10 is not working for me yet, I get an error "composer autoloader not found"
and version 9.1 is working for me so I am sticking with it for now.

## Setup

The quickest way to get it up is:

```bash
docker run -d -p 80:80 pschmitt/owncloud
```

Then go to http://localhost/ and log in as `admin`, password: `changeme`.

## Environment variables

- `DB_TYPE`: Either `sqlite`, `mysql`, `pgsql` or `oci`. Default: `sqlite`
- `DB_HOST`: Database host. Default: `localhost`
- `DB_NAME`: Database name. Default: `owncloud`
- `DB_USER`: Database user. Default: `owncloud`
- `DB_PASS`: Database password. Default: `owncloud`
- `DB_TABLE_PREFIX`: Prefix for all database tables. Default: `oc_`
- `ADMIN_USER`: Username of the admin. Default: `admin`
- `ADMIN_PASS`: Password of the admin account. Default: `changeme`
- `DATA_DIR`: ownCloud data dir. Default: `/var/www/owncloud/data`
- `HTTPS_ENABLED`: Whether to enable HTTPS (`true` or `false`). Default: `false`
- `TIMEZONE`: Timezone. Default: `UTC`

## Database setup

The image currently supports linking against a MySQL or PostgreSQL container.
This container **MUST** be named `db` for this to work.

## Volumes

- `/var/www/owncloud/apps`: ownCloud's plugin/apps directory
- `/var/www/owncloud/config`: ownCloud's config directory
- `/var/www/owncloud/data`: ownCloud's data directory
- `/etc/ssl/certs/owncloud.crt`: SSL certificate. Required if `HTTPS_ENABLED` is
`true`.
- `/etc/ssl/private/owncloud.key`: SSL private key. Required if `HTTPS_ENABLED`
is `true`.
- `/var/log/nginx`: Nginx logs

## Systemd service file

```
[Unit]
Description=Dockerized ownCloud
After=docker.service docker-postgres.service
Requires=docker.service docker-postgres.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker kill owncloud
ExecStartPre=-/usr/bin/docker rm owncloud
ExecStartPre=/usr/bin/docker pull pschmitt/owncloud
ExecStart=/usr/bin/docker run --name=owncloud -h owncloud.example.com \
  -p 80:80 -p 443:443 \
  --link postgres:db \
  -e 'DB_NAME=owncloud' \
  -e 'DB_USER=owncloud' \
  -e 'DB_PASS=PassWord' \
  -e 'ADMIN_USER=admin' \
  -e 'ADMIN_PASS=admin' \
  -e 'TIMEZONE=Europe/Berlin' \
  -e 'HTTPS_ENABLED=true' \
  -v /srv/docker/owncloud/apps:/var/www/owncloud/apps \
  -v /srv/docker/owncloud/config:/var/www/owncloud/config \
  -v /srv/docker/owncloud/data:/var/www/owncloud/data \
  -v /srv/docker/owncloud/owncloud.crt:/etc/ssl/certs/owncloud.crt \
  -v /srv/docker/owncloud/owncloud.key:/etc/ssl/certs/owncloud.key \
  pschmitt/owncloud

[Install]
Alias=owncloud.service
WantedBy=multi-user.target
```

## Run occ commands

Provided `owncloud` is the name of your container:

```bash
docker exec -it owncloud occ help
```
