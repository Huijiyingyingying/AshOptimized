#!/system/bin/sh
config="/sdcard/Android/Optimized"
date="/system/bin/date"
mainfile="/data/adb/modules/AshOptimized"

source $mainfile/bin/log.sh

level="/sys/class/power_supply/battery/capacity"

doze() {
  source $config/config.conf
  Power=$(cat $level)%
  screen=`dumpsys window policy | grep "mInputRestricted"|cut -d= -f2`
  dumpsys deviceidle | grep -q Enabled=true
  check=$?
  if [[ $screen = true ]]; then
    if [[ $check = 1 ]]; then
      dumpsys deviceidle enable deep
      dumpsys deviceidle force-idle deep
      doze_deviceidle=1
      log "检测到屏幕为息屏状态,进入Doze深度息屏(电量: $Power)"
    fi
  else
    if [[ $check = 0 ]]; then
      dumpsys deviceidle disable all
      dumpsys deviceidle unforce
      doze_deviceidle=0
      log "检测到屏幕为亮屏状态,退出Doze深度息屏(电量: $Power)"
    fi
  fi
}

log "AshScripts is starting."

source $config/config.conf

doze_deviceidle=0

until false; do
  doze
  sleep $doze_time
done
