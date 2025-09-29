#!/usr/bin/env bash

outfile="rmq_log.csv"
queue_regex=".*"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --outfile) outfile="$2"; shift 2;;
    --queue-regex) queue_regex="$2"; shift 2;;
    *) exit 1;;
  esac
done

if [ ! -f "$outfile" ]; then
  echo "ts,node,vhost,alarms,total_queues,total_msgs,total_ready,total_unacked,total_consumers,load1,load5,load15" >> "$outfile"
fi

timestamp="$(date -Iseconds)"
node="$(rabbitmq-diagnostics status 2>/dev/null | awk -F"'" '/Node/{print $2; exit}')"
alarms="$(rabbitmq-diagnostics alarms -q 2>/dev/null | tr -d '\n' | sed 's/,/;/g')"
read load1 load5 load15 _ < /proc/loadavg

mapfile -t vhosts < <(rabbitmqctl -q list_vhosts 2>/dev/null || echo "/")
if [ ${#vhosts[@]} -eq 0 ]; then vhosts=("/"); fi

for vhost in "${vhosts[@]}"; do
  mapfile -t queues < <(rabbitmqctl -q list_queues -p "$vhost" name messages messages_ready messages_unacknowledged consumers 2>/dev/null | grep -E "$queue_regex" || true)

  total_queues=${#queues[@]}
  total_msgs=0
  total_ready=0
  total_unacked=0
  total_consumers=0

  for q in "${queues[@]}"; do
    set -- $q
    total_msgs=$((total_msgs + ${2:-0}))
    total_ready=$((total_ready + ${3:-0}))
    total_unacked=$((total_unacked + ${4:-0}))
    total_consumers=$((total_consumers + ${5:-0}))
  done

  echo "$timestamp,$node,\"$vhost\",\"$alarms\",$total_queues,$total_msgs,$total_ready,$total_unacked,$total_consumers,$load1,$load5,$load15" >> "$outfile"
done

echo "snapshot salvo em $outfile"
