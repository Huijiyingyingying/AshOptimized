#!/system/bin/sh
config="/sdcard/Android/Optimized"
date="/system/bin/date"
mainfile="/data/adb/modules/AshOptimized"

source $mainfile/bin/log.sh

source $config/config.conf
for Clean_up_the_list in $(dumpsys deviceidle whitelist|awk -F ',' '{print $2}')
do
  dumpsys deviceidle whitelist -$Clean_up_the_list
done
log "已清空电池优化白名单"
for Add_to_a_list in $battery_optimize_app
do
  dumpsys deviceidle whitelist +$Add_to_a_list
  log "已添加 $Add_to_a_list 到电池优化白名单"
done

exit 0
