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
