#!/bin/bash
example_script="${1:-./example-xx/xx_script}"

sudo rm -rv ./deploy/
mkdir -pv ./deploy/{etc,log}
cp -rv ./etc ./deploy/
sudo chown root:root ./deploy/etc/monitrc
sudo chmod 600 ./deploy/etc/monitrc

mkdir  -pv ./deploy/etc/lualib/
cp -rv ./lua_module/lua-resty-mysql/lib/resty ./deploy/etc/lualib/
cp -rv ./lua_module/lua-resty-redis/lib/resty ./deploy/etc/lualib/

MYSQL_VOLUME='mysql'
MOUNT_ARG="type=volume,src=$MYSQL_VOLUME,dst=/var/lib/mysql"
if ! which docker 2>&1 >/dev/null; then
    echo 'lost command docker!'
    exit 2
fi
if docker info 2>&1 | grep 'Is the docker daemon running?' >/dev/null; then
    echo 'Is the docker daemon running?'
    exit 4
fi
if ! docker volume inspect $MYSQL_VOLUME 2>&1 >/dev/null; then
    echo "lost docker volume $MYSQL_VOLUME!"
    exit 6
fi

# hook script
if [ -x "$example_script" ]; then
    "$example_script"
    if [[ $? != 0 ]]; then
        echo "WARN: Failed to run $example_script!"
    fi
fi

cd ./deploy/
if [[ $? == 0 ]]; then
    exec docker run --rm -p 80:80 \
        -v $PWD/etc:/srv/etc:ro \
        -v $PWD/log:/srv/log:rw \
        --mount $MOUNT_ARG \
        --name nld_server shmilee/nld:using
fi
