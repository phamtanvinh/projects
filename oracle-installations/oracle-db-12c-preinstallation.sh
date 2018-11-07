#!/bin/bash

NETWORK_DEVICE='eth1'
STORAGE_DEVICE='sdb1'
IP_ADDR="$(ip addr show $NETWORK_DEVICE | grep -Po 'inet \K[\d.]+')"
HOST_NAME='orcl12c'
HOST_FILE='/etc/hosts'
DATA_DIR='/data'


# Check mount storage
if [[ $(df -hT | grep '/dev/sdb1') ]]; then
  echo "Check storageSTORAGE_DEVICE ... OK"
else
  echo 'Mounting storage...'
  mount "/dev/$STORAGE_DEVICE" "$DATA_DIR" && echo 'Mount ... OK' || echo "Mount ... Fail"
fi

# Check host
if [[ $(grep "$IP_ADDR" "$HOST_FILE") ]]; then
   echo "OK"
else
   echo "$IP_ADDR $HOST_NAME $HOST_NAME" >> "$HOST_FILE"
fi


