#!/bin/bash
set -x

EXECUTABLE=/opt/pivx/bin/pivxd
DIR=$HOME/.pivx
FILENAME=pivx.conf
FILE=$DIR/$FILENAME

# create directory and config file if it does not exist yet
if [ ! -e "$FILE" ]; then
    mkdir -p $DIR

    echo "Creating $FILENAME"

    # Seed a random password for JSON RPC server
    cat <<EOF > $FILE
printtoconsole=${PRINTTOCONSOLE:-1}
rpcbind=127.0.0.1
rpcallowip=10.0.0.0/8
rpcallowip=172.16.0.0/12
rpcallowip=192.168.0.0/16
server=1
rpcuser=${RPCUSER:-pivxrpc}
rpcpassword=${RPCPASS:-`dd if=/dev/urandom bs=33 count=1 2>/dev/null | base64`}
logtimestamps=1
maxconnections=256
masternode=1
externalip=34.66.53.90
masternodeprivkey=${MASTERNODEPRIVKEY:-fakekey}
EOF


#daemon=1
#logtimestamps=1
#maxconnections=256
#masternode=1
#externalip=34.66.53.90
#masternodeprivkey=${MASTERNODEPRIVKEY:-fakekey}

fi

cat $FILE
ls -lah $DIR/

echo $DIR
df -h

echo "Initialization completed successfully"

exec $EXECUTABLE

#while true; do sleep 10000; done