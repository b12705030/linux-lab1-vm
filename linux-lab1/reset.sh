#!/bin/bash

echo "🧹 Cleaning up previous practice state..."

if [ -f /tmp/cpu_loop_sim.pid ]; then
  sudo kill $(cat /tmp/cpu_loop_sim.pid) 2>/dev/null
  rm /tmp/cpu_loop_sim.pid
fi

if [ -f /tmp/renice_loop.pid ]; then
  sudo kill $(cat /tmp/renice_loop.pid) 2>/dev/null
  rm /tmp/renice_loop.pid
fi

sudo pkill -f watcher.sh

rm -f ~/logme_cron.txt /home/student/logme_cron.txt /var/log/watcher.log

crontab -r 2>/dev/null

sudo systemctl disable --now logme.timer 2>/dev/null
sudo rm -f /etc/systemd/system/logme.timer /etc/systemd/system/logme.service
sudo systemctl daemon-reload

echo "✅ Environment reset complete. You can now re-run: sudo /usr/local/bin/break_system.sh"
