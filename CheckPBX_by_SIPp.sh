#!/bin/bash

# Function initiate call by SIPp (Needed install one)

function call {
  /usr/bin/sipp \
  "$1" \
  -aa \
  -d 1s \
  -r 1 \
  -rp 1s \
  -sn uac \
  -l 1 \
  -m 1 \
  -trace_err \
  -i 172.16.1.247 \
  -rtp_echo \
  -s "$2" 
}

# call to pbx on DID 2451

call "172.17.5.10" "2451"

# if exit = 0 write to log 0, else check again and write 1 to log

if [ "${?}" -eq 0 ]; then
  echo "pbx ok"
  echo 0 > /var/log/zabbix/PBX.log
  chown zabbix. /var/log/zabbix/PBX.log
else
  echo "pbx error"
  result=1
  call "172.17.5.10" "2451"

  if [ "${?}" -eq 0 ]; then
      echo "pbx ok"
      echo 0 > /var/log/zabbix/PBX.log
      chown zabbix. /var/log/zabbix/PBX.log
  else
      echo "pbx error"
      result2=1
      if [ "${result}" == "${result2}" ]; then
          echo 1 > /var/log/zabbix/PBX.log
          chown zabbix. /var/log/zabbix/PBX.log
      else
          echo "pbx ok"
      fi
  fi
fi

sleep 5

# check another PBX (optional)

call "172.16.1.250" "100"

if [ "${?}" -eq 0 ]; then
  echo "pbx ok"
  echo 0 > /var/log/zabbix/Asterisk.log
  chown zabbix. /var/log/zabbix/Asterisk.log
else
  echo "pbx error"
  echo 1 > /var/log/zabbix/Asterisk.log
  chown zabbix. /var/log/zabbix/Asterisk.log
fi
