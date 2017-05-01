#!/bin/bash

UPTIME=0
INTERVAL_NOTIFY=25
NOTIFY_STAT=0

while [[ true ]]; do
  UPTIME=$(echo $(awk '{print $1}' /proc/uptime) / 60 | bc)
  if ((UP >= (NOTIFY_STAT + INTERVAL_NOTIFY))); then
    notify_send "Uptime Report" "You've been up for ${UPTIME}m"
    NOTIFY_STAT=$((NOTIFY_STAT+INTERVAL_NOTIFY))
  fi
  sleep 60
done
