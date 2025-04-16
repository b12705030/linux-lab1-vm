#!/bin/bash

echo "🎯 任務進度總覽："
echo

completed=0
total=4

# 高 CPU 判斷
if [ -f /tmp/cpu_loop_sim.pid ] && ps -p $(cat /tmp/cpu_loop_sim.pid) > /dev/null 2>&1; then
  echo "❌ 高 CPU process 還存在"
else
  echo "✅ 高 CPU process 已被 kill"
  ((completed++))
fi

# nice 判斷
if [ -f /tmp/renice_loop.pid ]; then
  NI=$(ps -o ni= -p $(cat /tmp/renice_loop.pid) 2>/dev/null | xargs)
  if [[ "$NI" == "" ]]; then
    echo "✅ nice 行程已處理完畢"
    ((completed++))
  elif [[ "$NI" -lt 15 ]]; then
    echo "✅ nice 行程已處理完畢"
    ((completed++))
  else
    echo "❌ nice 行程仍在執行且未調整"
  fi
else
  echo "✅ nice 行程已處理完畢"
  ((completed++))
fi

# cron 判斷
if [ -f /home/student/logme_cron.txt ]; then
  if grep -q "student" /home/student/logme_cron.txt; then
    echo "✅ cron log 已寫入"
    ((completed++))
  else
    echo "❌ cron log 尚未寫入"
  fi
else
  echo "❌ cron log 尚未寫入"
fi

# timer 判斷
if systemctl is-active --quiet logme.timer 2>/dev/null; then
  echo "✅ systemd.timer 已啟用"
  ((completed++))
else
  echo "❌ systemd.timer 尚未啟用"
fi

echo
echo "📊 目前完成進度：$completed / $total ✅"

if [ "$completed" -eq "$total" ]; then
  echo "🎉 所有任務皆已完成！!！"
fi

echo
