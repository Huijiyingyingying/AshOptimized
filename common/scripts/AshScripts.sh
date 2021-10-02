#!/system/bin/sh
config="/sdcard/Android/Optimized"
date="/system/bin/date"
mainfile="/data/adb/modules/AshOptimized"

log() {
  time=$($date "+%H:%M:%S")
  data=$($date "+%Y-%m-%d")
  txt=".txt"
  if [ ! -d $config/log ]; then
  	mkdir -p $config/log
  fi
  if [ ! -f $config/log/$data$txt ]; then
    touch $config/log/$data$txt
  fi
	echo "$time $1" >> $config/log/$data$txt
  number=0
  for i in $config/log/*; do
    number=`expr $number + 1`
  done
}

check_log() {
  if [[ $number -ge 31 ]]; then
    log "检测到log文件夹已有31个日志文件"
    find $config/log -mtime +29 -type f -name *.txt | xargs rm -rf
    log "已成功清除29天之前的日志..."
  fi
}

time_compare() {
  time1=$(date -d "$($date "+%Y-%m-%d") $($date "+%H:%M:%S")" +%s)
  if [[ $time1 -ge $1 ]]; then
    return 1
  else
    return 0
  fi
}

doze() {
  source $config/config.conf
  screen=`dumpsys window policy | grep "mInputRestricted"|cut -d= -f2`
  dumpsys deviceidle | grep -q Enabled=true
  check=$?
  if [[ $screen = true ]]; then
    if [[ $check = 1 ]]; then
      dumpsys deviceidle enable deep
      dumpsys deviceidle force-idle deep
      doze_deviceidle=1
      log "检测到屏幕为息屏状态,进入Doze深度息屏"
    fi
  else
    if [[ $check = 0 ]]; then
      dumpsys deviceidle disable all
      dumpsys deviceidle unforce
      doze_deviceidle=0
      log "检测到屏幕为亮屏状态,退出Doze深度息屏"
    fi
  fi
}

whitelist() {
  source $config/config.conf
  for Clean_up_the_list in $(dumpsys deviceidle whitelist|awk -F ',' '{print $2}')
  do
    dumpsys deviceidle whitelist -$Clean_up_the_list
  done
  log "已清空电池优化白名单"
  for Add_to_a_list in $whitelist_app
  do
    dumpsys deviceidle whitelist +$Add_to_a_list
    log "已添加 $Add_to_a_list 到电池优化白名单"
  done
}

fullpoweroff() {
  source $config/config.conf
  Power=$(cat $level)%
  [[ -f $Charging_control ]] && Status=`cat $Charging_control`
  [[ -f $Charging_control2 ]] && Status2=`cat $Charging_control2`
  if [[ $(cat $level) -ge $Power_Stop ]]; then
      if [[ $Status -eq 0 || $Status2 -eq 1 ]]; then
          if [[ -n $Set_a ]]; then
            Set_a=1
          elif [[ -z $Set_a ]]; then
            log "当前电量为$Power,$Power_Stop_Delay后自动断电"
            Set_c=1
            [[ -n $Power_Stop_Delay ]] && sleep $Power_Stop_Delay
            [[ -f $Charging_control ]] && echo 1 >$Charging_control
            [[ -f $Charging_control2 ]] && echo 0 >$Charging_control2
            Set_a=1
            unset Set_b Set_c
            log "当前电量为$Power,已停止充电"
          fi
      fi
  elif [[ $(cat $level) -le $Power_Restore ]]; then
      if [[ $Status -eq 1 || $Status2 -eq 0 ]]; then
          if [[ -n $Set_b ]]; then
              Set_b=1
          elif [[ -z $Set_b ]]; then
              [[ -f $Charging_control ]] && echo 0 >$Charging_control
              [[ -f $Charging_control2 ]] && echo 1 >$Charging_control2
              Set_b=1
              unset Set_a
              log "当前电量为$Power,已重新启用充电"
          fi
      fi
  fi
}

function topapp(){
	app=$(dumpsys window | grep mCurrentFocus | egrep -o "[^ ]*/[^\\}]+" | cut -d/ -f1 )
	echo "$app"
}

function killapp(){
for i in $killprocess_pose;do
		pgrep -f "$i" | while read PID;do
		test "$(topapp)" = "com.tencent.mm" && break
		test "$(topapp)" = "com.tencent.mobileqq" && break
		kill -9 "$PID"
    log "强制结束 $i"
	done
done
}

killprocess() {
  topapp
  if test "$(topapp)" != "com.tencent.mm" -a "$(topapp)" != "com.tencent.mobileqq" ;then
    killapp
  fi
}


[[ -e $config/config.conf ]] || cp -f $mainfile/common/config/config.conf $config/config.conf
[[ -d $config/data ]] || mkdir $config/data
[[ -e $config/data/doze.conf ]] || touch $config/data/doze.conf && echo "0" > $config/data/doze.conf
[[ -e $config/data/whitelist.conf ]] || touch $config/data/whitelist.conf && echo "0" > $config/data/whitelist.conf
[[ -e $config/data/fullpoweroff.conf ]] || touch $config/data/fullpoweroff.conf && echo "0" > $config/data/fullpoweroff.conf
[[ -e $config/data/killprocess.conf ]] || touch $config/data/killprocess.conf && echo "0" > $config/data/killprocess.conf
source $config/config.conf
check_log

doze_deviceidle=0

Charging_control="/sys/class/power_supply/battery/input_suspend"
Charging_control2="/sys/class/power_supply/battery/charging_enabled"
level="/sys/class/power_supply/battery/capacity"
Status=0
Status2=1
unset Set_a Set_b Set_c

killprocess_pose="
com.tencent.mm:sandbox*
com.tencent.mm:exdevice*
com.tencent.mobileqq:tool*
com.tencent.mobileqq:qzone*
com.tencent.mm:tools*
com.tencent.mobileqq:TMAssistantDownloadSDKService*
com.tencent.mobileqq:mini*
com.tencent.mm:hotpot*
com.tencent.mobileqq:hotpot*"

log "AshScripts is starting."

until false; do
  time_start=$(date -d "$($date "+%Y-%m-%d") $($date "+%H:%M:%S")" +%s)
  source $config/config.conf
  check_log

  local_time=`cat $config/data/doze.conf`
  time_compare $local_time
  if [[ $? = 1 ]]; then
    doze &
    time1=$(date -d "$($date "+%Y-%m-%d") $($date "+%H:%M:%S")" +%s)
    time2=`expr $time1 + $doze_time`
    echo "$time2" > $config/data/doze.conf
  fi

  local_time=`cat $config/data/whitelist.conf`
  time_compare $local_time
  if [[ $? = 1 && $doze_deviceidle = 0 ]]; then
    whitelist &
    time1=$(date -d "$($date "+%Y-%m-%d") $($date "+%H:%M:%S")" +%s)
    time2=`expr $time1 + $whitelist_time`
    echo "$time2" > $config/data/whitelist.conf
  fi

  local_time=`cat $config/data/fullpoweroff.conf`
  time_compare $local_time
  if [[ $? = 1 && -z $Set_c ]]; then
      fullpoweroff &
    time1=$(date -d "$($date "+%Y-%m-%d") $($date "+%H:%M:%S")" +%s)
    time2=`expr $time1 + $power_time`
    echo "$time2" > $config/data/fullpoweroff.conf
  fi

  local_time=`cat $config/data/killprocess.conf`
  time_compare $local_time
  if [[ $? = 1 && $doze_deviceidle = 0 ]]; then
    killprocess &
    time1=$(date -d "$($date "+%Y-%m-%d") $($date "+%H:%M:%S")" +%s)
    time2=`expr $time1 + $killprocess_time`
    echo "$time2" > $config/data/killprocess.conf
  fi

  time_end=$(date -d "$($date "+%Y-%m-%d") $($date "+%H:%M:%S")" +%s)
  time_1=`expr $time_end - $time_start`
  if [[ $time_1 -lt 10 ]]; then
    time_2=10
    time_3=`expr $time_2 - $time_1`
    sleep $time_3
  fi

done
