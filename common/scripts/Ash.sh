#!/system/bin/sh
config="/sdcard/Android/Optimized"
date="/system/bin/date"
mainfile="/data/adb/modules/AshOptimized"

State_battery_optimize=$(cat "$mainfile/data/battery_optimize")
State_charge_optimize=$(cat "$mainfile/data/charge_optimize")
State_process_optimize=$(cat "$mainfile/data/process_optimize")

source $config/config.conf

if [[ $number -ge 31 ]]; then
  log "检测到log文件夹已有31个日志文件"
  find $config/log -mtime +29 -type f -name *.txt | xargs rm -rf
  log "已成功清除29天之前的日志..."
fi

BatteryOptimize() {
  State=`expr $State_battery_optimize + 1`
  if [[ $State -ge $battery_optimize_time ]]; then
    echo 0 > $mainfile/data/battery_optimize
    sh $mainfile/common/scripts/BatteryOptimize.sh &
  else
    echo $State > $mainfile/data/battery_optimize
  fi
}

ChargeOptimize() {
  State=`expr $State_charge_optimize + 1`
  if [[ $State -ge $charge_optimize_time ]]; then
    echo 0 > $mainfile/data/charge_optimize
    ps -fe|grep ChargeOptimize |grep -v grep
    if [ $? -ne 0 ]; then
      sh $mainfile/common/scripts/ChargeOptimize.sh &
    fi
  else
    echo $State > $mainfile/data/charge_optimize
  fi
}

ProcessOptimize() {
  State=`expr $State_process_optimize + 1`
  if [[ $State -ge $process_optimize_time ]]; then
    echo 0 > $mainfile/data/process_optimize
    sh $mainfile/common/scripts/ProcessOptimize.sh &
  else
    echo $State > $mainfile/data/process_optimize
  fi
}

if [[ $battery_enable = "true" ]]; then
  BatteryOptimize
fi

if [[ $charge_enable = "true" ]]; then
  ChargeOptimize
fi

if [[ $process_enable = "true" ]]; then
  ProcessOptimize
fi

exit 0
