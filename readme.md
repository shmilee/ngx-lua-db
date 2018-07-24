Intro
=====

Use nginx, lua to store and get data from redis, mysql.

docker image
============

[mynginx](https://github.com/shmilee/web-in-docker/blob/master/dockerfiles/readme.md#build-packages) + lua + mariadb(mysql) + redis

### build image

* change repository url in Dockerfile for mynginx

```
cd ./docker-nld/
docker build --force-rm --no-cache --rm -t shmilee/nld:$(date +%y%m%d) .
docker tag shmilee/nld:$(date +%y%m%d) shmilee/nld:using
```

### initialize the MariaDB data volume

```
MYSQL_VOLUME='mysql'
MYSQL_IMAGE='shmilee/nld:using'
MOUNT_ARG="type=volume,src=$MYSQL_VOLUME,dst=/var/lib/mysql"
# first, create a volume
docker volume create $MYSQL_VOLUME
# then use volume with docker image
docker run --rm --mount $MOUNT_ARG $MYSQL_IMAGE \
    bash -c 'mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql'
container_id=$(docker run --rm -d --mount $MOUNT_ARG $MYSQL_IMAGE \
    bash -c 'mysqld_safe --pid-file=/run/mysqld/mysqld.pid;')
docker exec -i -t $container_id mysql_secure_installation
docker stop $container_id
```

### run nld container

```
./deploy-run.sh
```

### example-cc

initialize database

```
SQL_INIT=$PWD'/example-cc/cc-db-init.sql'
container_id=$(docker run --rm -d -v $SQL_INIT:/db-init.sql \
    --mount $MOUNT_ARG $MYSQL_IMAGE \
    bash -c 'mysqld_safe --pid-file=/run/mysqld/mysqld.pid;')
docker exec -i -t $container_id  mysql -uroot -hlocalhost -p
# prompt, MariaDB [(none)]> source /db-init.sql;
docker stop $container_id
```

run

```
chmod +x ./example-cc/deploy-script
./deploy-run.sh ./example-cc/deploy-script
```
