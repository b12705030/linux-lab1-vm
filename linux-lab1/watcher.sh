#!/bin/bash

CPU_FLAG=0
RENICE_FLAG=0
CRON_FLAG=0
TIMER_FLAG=0

CPU_PID=$(cat /tmp/cpu_loop_sim.pid 2>/dev/null)
RENICE_PID=$(cat /tmp/renice_loop.pid 2>/dev/null)

while true; do
  if [[ $CPU_FLAG -eq 0 && -n "$CPU_PID" && ! $(ps -p "$CPU_PID" > /dev/null 2>&1) ]]; then
    echo "✅ 高 CPU process 已被 kill"
    CPU_FLAG=1
  fi

  if [[ $RENICE_FLAG -eq 0 ]]; then
    CURRENT_NICE=$(ps -o ni= -p "$RENICE_PID" 2>/dev/null | tr -d ' ')
    if [[ -z "$CURRENT_NICE" || "$CURRENT_NICE" -lt 15 ]]; then
      echo "✅ nice 行程已處理完畢"
      RENICE_FLAG=1
    fi
  fi

  if [[ $CRON_FLAG -eq 0 && -f "/home/student/logme_cron.txt" ]]; then
    if grep -q "student" /home/student/logme_cron.txt; then
      echo "✅ cron log 成功寫入"
      CRON_FLAG=1
    fi
  fi

  if [[ $TIMER_FLAG -eq 0 ]]; then
    if systemctl is-active --quiet logme.timer; then
      echo "✅ systemd.timer 已啟用"
      TIMER_FLAG=1
    fi
  fi

  if [[ $CPU_FLAG -eq 1 && $RENICE_FLAG -eq 1 && $CRON_FLAG -eq 1 && $TIMER_FLAG -eq 1 ]]; then
    echo "🎉 所有任務皆已完成！可以向老師炫耀了嘎嘎！"
    break
  fi

  sleep 5
done
