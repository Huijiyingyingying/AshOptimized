SKIPUNZIP=0

config="/sdcard/Android/Optimized"

get_choose() {
	local choose
	local branch
	while :; do
		choose="$(getevent -qlc 1 | awk '{ print $3 }')"
		case "$choose" in
		KEY_VOLUMEUP)  branch="0" ;;
		KEY_VOLUMEDOWN)  branch="1" ;;
		*)  continue ;;
		esac
		echo "$branch"
		break
	done
}

Device="$(getprop ro.product.device)"
echo "Device: $Device"
echo "The installation may take 3-5 seconds."

mkdir $MODPATH/system

config_a="0"
[[ -d $config ]] || mkdir $config
[[ -e $config/config.conf ]] || cp -f $MODPATH/common/config/config.conf $config/config.conf || config_a="1"

mkdir -p $MODPATH/system/priv-app/MiuiPackageInstaller
cp -f $MODPATH/common/install/MiuiPackageInstaller.apk $MODPATH/system/priv-app/MiuiPackageInstaller/
set_perm_recursive $MODPATH/system/priv-app/MiuiPackageInstaller/MiuiPackageInstaller.apk 0 0 0755 0644
rm -rf /data/system/package_cache

setprop persist.vendor.gnss.hpLocSetUI 1

echo "0" > /sys/module/lowmemorykiller/parameters/enable_lmk
echo "0" > /sys/module/lowmemorykiller/parameters/debug_level

mkdir -p $MODPATH/system/media/theme/default
cp -f $MODPATH/common/install/com.miui.cloudservice $MODPATH/system/media/theme/default/
cp -f $MODPATH/common/install/framework-res $MODPATH/system/media/theme/default/
set_perm_recursive  $MODPATH/system/media/theme/default/com.miui.cloudservice  0  0  0644 u:object_r:system_file:s0
set_perm_recursive  $MODPATH/system/media/theme/default/framework-res  0  0  0644 u:object_r:system_file:s0

source $MODPATH/common/install/Ram_Optimized.sh

echo "--- 选择安装 RemoveThermal(移除温控) 功能"
echo "-- 音量键+: 安装"
echo "-- 音量键-: 不安装"
echo "--- 请选择(按 音量键+ 或 音量键-)"
echo " "
if [[ $(get_choose) == 0 ]]; then
  source $MODPATH/common/install/RemoveThermal.sh
fi

sleep 0.5

if [[ $config_a = "0" ]]; then
	echo "--- 选择更新 config.conf 文件"
	echo "-- 音量键+: 更新"
	echo "-- 音量键-: 不更新"
	echo "--- 请选择(按 音量键+ 或 音量键-)"
	echo " "
	if [[ $(get_choose) == 0 ]]; then
	  cp -f $MODPATH/common/config/config.conf $config/
	fi
fi

UselessProcess_list="system/bin/logd
system/etc/init/logd.rc
system/etc/init/bootlogoupdater
system/bin/mdnsd
system/etc/init/mdnsd.rc
system/etc/init/mobile_log_d
system/etc/init/dumpstate
system/bin/emdlogger1
system/etc/init/emdlogger1
system/bin/emdlogger3
system/etc/init/emdlogger3
system/bin/mdlogger
system/etc/init/mdlogger
system/vendor/etc/init/vendor.mediatek.hardware.log@1.0-service.rc
system/bin/connsyslogger
system/etc/init/connsyslogger"

for list in $UselessProcess_list; do
  touch $MODPATH/$list
done

REPLACE="
/system/app/systemAdSolution
/system/app/mab
/system/app/MSA
/system/app/MSA-CN-NO_INSTALL_PACKAGE
/system/app/AnalyticsCore
/system/app/CarrierDefaultApp
/system/app/talkback
/system/app/PrintSpooler
/system/app/PhotoTable
/system/app/BuiltInPrintService
/system/app/BasicDreams
/system/app/mid_test
/system/app/MiuiVpnSdkManager
/system/app/BookmarkProvider
/system/app/FidoAuthen
/system/app/FidoClient
/system/app/FidoCryptoService
/system/app/YouDaoEngine
/system/app/AutoTest
/system/app/AutoRegistration
/system/app/KSICibaEngine
/system/app/PrintRecommendationService
/system/app/SeempService
/system/app/com.miui.qr
/system/app/Traceur
/system/app/GPSLogSave
/system/app/SystemHelper
/system/app/Stk
/system/app/SYSOPT
/system/app/xdivert
/system/app/MiuiDaemon
/system/app/Qmmi
/system/app/QdcmFF
/system/app/Xman
/system/app/Yman
/system/app/seccamsample
/system/app/MiPlayClient
/system/app/greenguard
/system/app/QColor
/system/app/mab
/system/app/HybridAccessory/
/system/priv-app/MiRcs
/system/priv-app/MiGameCenterSDKService
/system/app/TranslationService
/system/priv-app/dpmserviceapp
/system/priv-app/EmergencyInfo
/system/priv-app/MIService
/system/priv-app/UserDictionaryProvider
/system/priv-app/ONS
/system/priv-app/MusicFX
/system/product/app/datastatusnotification
/system/product/app/PhotoTable
/system/product/app/QdcmFF
/system/product/app/talkback
/system/product/app/xdivert
/system/product/priv-app/dpmserviceapp
/system/product/priv-app/EmergencyInfo
/system/product/priv-app/seccamservice
/system/data-app
/system/vendor/data-app
/system/system_ext/app/PerformanceMode/
/system/system_ext/app/xdivert/
/system/system_ext/app/QdcmFF/
/system/system_ext/app/QColor/
/system/system_ext/priv-app/EmergencyInfo/
/vendor/app/GFManager/
/vendor/app/GFTest/
"

rm -rf $MODPATH/common/install

echo "Installation is complete."
echo "by 灰机嘤嘤嘤"
