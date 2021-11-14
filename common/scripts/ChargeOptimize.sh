#!/system/bin/sh
config="/sdcard/Android/Optimized"
date="/system/bin/date"
mainfile="/data/adb/modules/AshOptimized"

source $mainfile/bin/log.sh

Charging_control="/sys/class/power_supply/battery/input_suspend"
Charging_control2="/sys/class/power_supply/battery/charging_enabled"
level="/sys/class/power_supply/battery/capacity"
Status=0
Status2=1
unset Set_a Set_b Set_c

source $config/config.conf
Power=$(cat $level)%
[[ -f $Charging_control ]] && Status=`cat $Charging_control`
[[ -f $Charging_control2 ]] && Status2=`cat $Charging_control2`
if [[ $(cat $level) -ge $charge_optimize_stop ]]; then
    if [[ $Status -eq 0 || $Status2 -eq 1 ]]; then
        if [[ -n $Set_a ]]; then
          Set_a=1
        elif [[ -z $Set_a ]]; then
          log "当前电量为$Power,$charge_optimize_stop_delay后自动断电"
          Set_c=1
          [[ -n $charge_optimize_stop_delay ]] && sleep $charge_optimize_stop_delay
          [[ -f $Charging_control ]] && echo 1 >$Charging_control
          [[ -f $Charging_control2 ]] && echo 0 >$Charging_control2
          Set_a=1
          unset Set_b Set_c
          log "当前电量为$Power,已停止充电"
        fi
    fi
elif [[ $(cat $level) -le $charge_optimize_restore ]]; then
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

exit 0
