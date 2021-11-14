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
