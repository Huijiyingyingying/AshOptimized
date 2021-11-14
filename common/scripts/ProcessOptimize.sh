#!/system/bin/sh
config="/sdcard/Android/Optimized"
date="/system/bin/date"
mainfile="/data/adb/modules/AshOptimized"

source $mainfile/bin/log.sh

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

killprocess_pose="
com.tencent.mm:sandbox*
com.tencent.mm:exdevice*
com.tencent.mobileqq:tool*
com.tencent.mobileqq:qzone*
com.tencent.mm:tools*
com.tencent.mobileqq:TMAssistantDownloadSDKService*
com.tencent.mobileqq:mini*
com.tencent.mm:hotpot*
com.tencent.mobileqq:hotpot*
"

topapp
if test "$(topapp)" != "com.tencent.mm" -a "$(topapp)" != "com.tencent.mobileqq" ;then
  killapp
fi

exit 0
