SKIPUNZIP=0

config="/sdcard/Android/Optimized"

echo $(cat $MODPATH/UPDATE.md)

mkdir $MODPATH/system

[[ -d $config ]] || mkdir $config
[[ -d $config/data ]] || mkdir $config/data
[[ -e $config/config.conf ]] || cp -f $MODPATH/common/config/config.conf $config/config.conf

stop tcpdump
stop cnss_diag
rm -rf /data/vendor/wlan_logs/*
setprop sys.miui.ndcd off


function remove_thermal() {
 echo "exit 0" > $1
 chmod 7777 $1
}
#Replace Main
mkdir -p ${MODPATH}/system/etc
mkdir -p ${MODPATH}/system/vendor/etc
mkdir -p ${MODPATH}/system/vendor/lib
mkdir -p ${MODPATH}/system/vendor/lib64
mkdir -p ${MODPATH}/system/bin
mkdir -p ${MODPATH}/system/vendor/bin
mkdir -p ${MODPATH}/system/vendor/lib64/hw
mkdir -p ${MODPATH}/system/vendor/lib/hw
mkdir -p ${MODPATH}/system/lib64
#hisilicon Thermal_file
if [ -e /system/etc/thermald.xml ] ; then
remove_thermal $MODPATH/system/etc/thermald.xml
remove_thermal $MODPATH/system/etc/thermald_performance.xml
remove_thermal $MODPATH/system/etc/thermald_performance_qcoff.xml
remove_thermal $MODPATH/system/etc/thermald_qcoff.xml
fi
#qualcomm_thermal_lib
if [ -e /system/bin/thermal-engine ] ; then
 remove_thermal $MODPATH/system/bin/thermal-engine
fi
if [ -e /system/vendor/bin/thermal-engine ] ; then
 remove_thermal $MODPATH/system/vendor/bin/thermal-engine
fi
if [ -e /system/bin/thermald ] ; then
remove_thermal $MODPATH/system/bin/thermald
remove_thermal $MODPATH/system/vendor/bin/thermald
fi
if [ -e /system/bin/thermalserviced ] ; then
remove_thermal $MODPATH/system/bin/thermalserviced
remove_thermal $MODPATH/system/vendor/bin/thermalserviced
fi
if [ -e /system/vendor/lib/libthermalioctl.so ] ; then
remove_thermal $MODPATH/system/vendor/lib/libthermalioctl.so
remove_thermal $MODPATH/system/vendor/lib/libthermalclient.so
remove_thermal $MODPATH/system/vendor/lib64/libthermalioctl.so
remove_thermal $MODPATH/system/vendor/lib64/libthermalclient.so
fi
if [ -e /system/vendor/etc/perf/perfboostconfig.xml ] ; then
remove_thermal $MODPATH/system/vendor/etc/perf/perfboostconfig.xml
fi
for tso in $(ls /system/vendor/lib/hw/thermal.*.so /system/vendor/lib64/hw/thermal.*.so)
do
  remove_thermal ${MODPATH}${tso}
done
for tconf in $(ls /system/etc/thermal-engine*.conf /system/vendor/etc/thermal-engine*.conf)
do
  remove_thermal ${MODPATH}${tconf}
done
for tdconf in $(ls /system/etc/thermald-*.conf /system/vendor/etc/thermald-*.conf)
do
  remove_thermal ${MODPATH}${tdconf}
done
for mtk_conf in $(ls /system/etc/thermald-*.conf /system/vendor/etc/thermal-*.conf)
do
  remove_thermal ${MODPATH}${mtk_conf}
done

#MediaTek Thermal_file (For Redmi & Xiaomi)
if [ -d /system/etc/.tp/ ] ; then
mkremove_thermal $MODPATH/system/etc/.tp/.replace
fi
if [ -d /system/vendor/etc/.tp/ ] ; then
mkremove_thermal $MODPATH/system/vendor/etc/.tp/.replace
fi
if [ -d /system/etc/.tp0/ ] ; then
mkdir -p $MODPATH/system/etc/.tp0/
for mtt in $(ls /system/etc/.tp0/thermal.*.xml)
do
  remove_thermal ${MODPATH}${mtt}
done
fi
if [ -e /system/lib64/libthermalcallback.so ] ; then
remove_thermal $MODPATH/system/lib64/libthermalcallback.so
remove_thermal $MODPATH/system/lib64/libthermalservice.so
fi
if [ -e /system/bin/thermalserviced ] ; then
mkdir -p ${MODPATH}/system/bin
remove_thermal $MODPATH/system/bin/thermalserviced
fi

chmod -R 7777 $MODPATH/

if [ -d /data/vendor/thermal/ ] ; then
 chmod -R 7777 /data/vendor/thermal/
 rm -rf /data/vendor/thermal/config
 remove_thermal /data/vendor/thermal/config
 chmod 0000 /data/vendor/thermal/config
fi


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

echo "Installation is complete."
