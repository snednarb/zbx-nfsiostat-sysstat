#!/bin/bash
##################################
# Zabbix monitoring script for nfs
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922     VV      initial creation
#  20221103     BS      modernize for Zabbix 4.0+
##################################

# Zabbix requested parameter
MOUNT_POINT="$1"

NFS_IO_STAT_CMD=$(nfsiostat "$MOUNT_POINT" 2>/dev/null)
EXIT_CODE=$?
NFS_IO_STAT_CMD=$(echo "$NFS_IO_STAT_CMD" | sed "1,4d" | grep -v read | grep -v write | awk '{print}' ORS=' ')

JSON_BUFFER="{ \"mountpoint\":\"$MOUNT_POINT\", \"error\":\""

if [[ -z "$MOUNT_POINT" ]]; then
  # Missing required parameter
  JSON_BUFFER+="Required parameter not provided\""
elif [[ "$EXIT_CODE" == "127" ]]; then
  # Command not found
  JSON_BUFFER+="Command nfsiostat not found\""
elif [[ -z "$NFS_IO_STAT_CMD" ]]; then
  # nfiostat output empty
  JSON_BUFFER+="Failed to fetch counters from nfsiostat\""
else
  JSON_BUFFER+="\", "
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"ops_sec\":\"" $1 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"rpc_backlog\":\"" $2 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"read_ops_sec\":\"" $3 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"read_kB_sec\":\"" $4 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"read_kB_op\":\"" $5 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"read_retrans\":\"" $6 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"read_RTT\":\"" $8 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"read_exe\":\"" $9 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"write_ops_sec\":\"" $10 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"write_kB_sec\":\"" $11 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"write_kB_op\":\"" $12 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"write_retrans\":\"" $13 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"write_RTT\":\"" $15 "\", "}')
  JSON_BUFFER+=$(echo "$NFS_IO_STAT_CMD" | awk '{print "\"write_exe\":\"" $16 "\""}')
fi

JSON_BUFFER+=" }"
echo "$JSON_BUFFER"

exit 0