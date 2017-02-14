#!/bin/bash
set -m
set -e

##

mongodb_cmd="mongod --storageEngine $STORAGE_ENGINE"
#cmd="$mongodb_cmd --httpinterface --rest --master"
cmd="$mongodb_cmd --master"
if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth"
fi

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

##

echo "starting mongodb"
chown -R mongodb /data/configdb /data/db
exec gosu mongodb $cmd &

##

if [ ! -f /data/db/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

##

fg

