#!/bin/bash

bash -c '
count=0
while true; do
  :
  count=$((count + 1))
  if (( count % 500000 == 0 )); then
    echo "[CPU LOAD] still running..."
    sleep 0.1
  fi
  if (( count == 3000000 )); then
    echo "[CPU WARNING] Usage approaching 10%"
  fi
done
' > /dev/null &

CPU_PID=$!
echo $CPU_PID > /tmp/cpu_loop_sim.pid

bash -c 'trap "echo SIGTERM received, shutting down" TERM; sleep 500' &
bash -c 'trap "echo SIGHUP received, reloading..." HUP; sleep 500' &
bash -c 'trap "echo SIGINT ignored" INT; while true; do sleep 1; done' &

for i in {1..5}; do
  bash -c 'sleep 600' &
done

nice -n 15 bash -c 'for ((i=0;i<100000000;i++)); do echo -n > /dev/null; done' &

RENICE_PID=$!
echo $RENICE_PID > /tmp/renice_loop.pid

# 顯示任務總覽
/usr/local/bin/status.sh
