#!/usr/bin/env bash

# send originate call to Asterisk for monitor DID 749912345678
ssh root@172.1.1.250 'asterisk -rx "channel originate SIP/MTT/749912345678 extension 330512432143214312342143"'

sleep 1

# grep this call from Audiocodes M1000 log
output="$(tail -99 /var/log/M1000.log | grep (Insert your !!!CallerID) | tail -1 | cut -d'|' -f56)"

sleep 1

echo "${output}" > /var/log/result_originate.log

sleep 1

# grep session_id of this call

session_id="$(tail -99 /var/log/M1000.log | grep (Insert your !!!CallerID) | tail -1 | cut -d'|' -f4)"

# find previos sessio_id
previos_session_id="$(cat /tmp/session_id)"

# check record output for NORMAL_CALL_CLEAR 
if [ "${output}" != 'NORMAL_CALL_CLEAR' ]; then
        echo 1 > /var/log/zabbix-agent/result_to_zabbix.log
        chown zabbix. /var/log/zabbix-agent/result_to_zabbix.log
else
        echo 0 > /var/log/zabbix-agent/result_to_zabbix.log
        chown zabbix. /var/log/zabbix-agent/result_to_zabbix.log
fi

sleep 1

# compare session_id, if it same then it is problem because new call didn't log  

if [ "${previos_session_id}" == "${sesion_id}" ]; then
        echo 1 > /var/log/zabbix-agent/result_to_zabbix.log
        chown zabbix. /var/log/zabbix-agent/result_to_zabbix.log
else
        echo 0 > /var/log/zabbix-agent/result_to_zabbix.log
        chown zabbix. /var/log/zabbix-agent/result_to_zabbix.log
fi

cat /var/log/zabbix-agent/result_to_zabbix.log
echo "${previos_session_id}"

echo ${session_id} > /tmp/session_id
echo "${session_id}"
