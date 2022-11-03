#!/bin/bash
[[ "$1" != "" ]] && TYPE=$1 || TYPE=nfs

nfs_mounts=($(findmnt -lo target -n -t $TYPE | cut -f2 -d':'))
echo -n "{\"data\":["
for nfs_mount in ${nfs_mounts[@]}
do
    echo -n "{\"{#MOUNT_POINT}\":\"$nfs_mount\"},"
done | sed 's/,$//'
# Added sed in the end of for loop, because old zabbix doesn't accept json with trailing commas

echo "]}"
