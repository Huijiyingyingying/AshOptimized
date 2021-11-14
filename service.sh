MODDIR=${0%/*}
sleep 60

config="/sdcard/Android/Optimized"
date="/system/bin/date"
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

stop tcpdump
stop cnss_diag
rm -rf /data/vendor/charge_logger/
rm -rf /data/vendor/wlan_logs/
setprop sys.miui.ndcd off

userdata=$(getprop dev.mnt.blk.data)
echo "0" > /sys/block/sda/queue/iostats
echo "0" > /sys/block/sdb/queue/iostats
echo "0" > /sys/block/sdc/queue/iostats
echo "0" > /sys/block/sdd/queue/iostats
echo "0" > /sys/block/sde/queue/iostats
echo "0" > /sys/block/sdf/queue/iostats
echo "0" > /sys/module/binder/parameters/debug_mask
echo "0" > /sys/module/binder_alloc/parameters/debug_mask
echo "0" > /sys/module/msm_show_resume_irq/parameters/debug_mask
echo "N" > /sys/kernel/debug/debug_enabled
echo "128" > /sys/block/sda/queue/read_ahead_kb
echo "36" > /sys/block/sda/queue/nr_requests
echo "128" > /sys/block/sde/queue/read_ahead_kb
echo "36" > /sys/block/sde/queue/nr_requests
echo "128" > /sys/block/${userdata}/queue/read_ahead_kb
echo "36" > /sys/block/${userdata}/queue/nr_requests
echo "128" > /sys/block/zram0/queue/read_ahead_kb
echo "36" > /sys/block/zram0/queue/nr_requests
echo "0" > /proc/sys/vm/page-cluster
echo "0" > /sys/module/subsystem_restart/parameters/enable_ramdumps
echo "off" > /proc/sys/kernel/printk_devkmsg
echo "3000" > /proc/sys/vm/dirty_expire_centisecs
echo "0" > /sys/fs/f2fs/${userdata}/iostat_enable
echo "0" > /proc/sys/kernel/sched_schedstats
echo "20" > /proc/sys/vm/stat_interval
echo "0" > /proc/sys/kernel/sched_autogroup_enabled

white_list() {
  if [ $1 = 0 ]; then
    pgrep -o $3 | while read pid; do
      renice -n -20 -p $pid
    done
  fi
  if [ $1 = 1 ]; then
    pgrep -f $3 | while read pid; do
      renice -n -20 -p $pid
    done
  fi
  if [ $2 = 1 ]; then
    pgrep -o $3 | while read pid; do
      echo $pid > /dev/cpuset/top-app/cgroup.procs
      echo $pid > /dev/stune/top-app/cgroup.procs
      chrt -f -p $pid 70
    done
  fi
}

white_list 0 1 "surfaceflinger"
white_list 0 1 "webview_zygote"
white_list 1 1 "android.hardware.graphics.composer@2.2-service"
white_list 1 1 "zygote"
white_list 1 1 "zygote64"
white_list 1 1 "com.android.systemui"
white_list 0 0 "system_server"
white_list 0 0 "vendor.qti.hardware.display.composer-service"
white_list 0 0 "com.android.permissioncontroller"
white_list 0 0 "com.miui.home"
white_list 0 0 "com.miui.freeform"
white_list 0 0 "com.google.android.webview:webview_service"

echo "1" > /dev/stune/foreground/schedtune.prefer_idle
echo "1" > /dev/stune/background/schedtune.prefer_idle
echo "1" > /dev/stune/rt/schedtune.prefer_idle
echo "20" > /dev/stune/rt/schedtune.boost
echo "20" > /dev/stune/top-app/schedtune.boost
echo "1" > /dev/stune/schedtune.prefer_idle
echo "1" > /dev/stune/top-app/schedtune.prefer_idle

echo "
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv4.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.lo.forwarding = 1
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
net.core.netdev_max_backlog = 100000
net.core.netdev_budget = 50000
net.core.netdev_budget_usecs = 5000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 67108864
net.core.wmem_default = 67108864
net.core.optmem_max = 65536
net.core.somaxconn = 10000
net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.tcp_keepalive_time = 8
net.ipv4.tcp_keepalive_intvl = 8
net.ipv4.tcp_keepalive_probes = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 8
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_autocorking = 0
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_max_syn_backlog = 30000
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_frto = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
vm.overcommit_memory = 1
kernel.pid_max=64000
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv4.neigh.default.gc_thresh2=4096
net.ipv4.neigh.default.gc_thresh1=2048
net.ipv6.neigh.default.gc_thresh3=8192
net.ipv6.neigh.default.gc_thresh2=4096
net.ipv6.neigh.default.gc_thresh1=2048
net.ipv4.tcp_max_syn_backlog = 262144
net.netfilter.nf_conntrack_max = 262144
net.nf_conntrack_max = 262144
" > /etc/sysctl.conf
chmod 777 /etc/sysctl.conf
sysctl -p
ip route | while read r; do
ip route change $r initcwnd 20;
done
ip route | while read r; do
ip route change $r initrwnd 20;
done

UselessProcess_list="logd
bootlogoupdater
mdnsd
mobile_log_d
dumpstate
emdlogger1
emdlogger3
mdlogger
aee.log-1-0
connsyslogger"

for list in $UselessProcess_list; do
  am kill $list
  killall -9 $list
  am kill $list.rc
  killall -9 $list.rc
done

#根除MIUI Analytics广告分析服务
# 清空文件夹
rm -rf /data/user/0/com.xiaomi.market/app_analytics/*
# 更改文件夹所有者为root
chown -R root:root /data/user/0/com.xiaomi.market/app_analytics/
# 文件夹权限改为000
chmod -R 000 /data/user/0/com.xiaomi.market/app_analytics/
# 卸载用户0 com.miui.analytics应用
pm uninstall --user 0 com.miui.analytics >/dev/null

[[ -e $MODDIR/data/battery_optimize ]] || touch $MODDIR/data/battery_optimize
echo 0 > $MODDIR/data/battery_optimize
[[ -e $MODDIR/data/charge_optimize ]] || touch $MODDIR/data/charge_optimize
echo 0 > $MODDIR/data/charge_optimize
[[ -e $MODDIR/data/process_optimize ]] || touch $MODDIR/data/process_optimize
echo 0 > $MODDIR/data/process_optimize

chown root:root $MODDIR/common/scripts/AshScripts.sh
chmod 777 $MODDIR/common/scripts/AshScripts.sh
nohup $MODDIR/common/scripts/AshScripts.sh &

sh $MODDIR/common/scripts/BatteryOptimize.sh &
sh $MODDIR/common/scripts/ChargeOptimize.sh &
sh $MODDIR/common/scripts/ProcessOptimize.sh &

MAGISK_TMP=$(magisk --path 2>/dev/null)
[[ -z $MAGISK_TMP ]] && MAGISK_TMP="/sbin"
alias crond="$MAGISK_TMP/.magisk/busybox/crond"
chmod -R 0777 $MODDIR
echo "SHELL=$MODDIR/bin/bash" > $MODDIR/cron.d/root
echo "* * * * * $MODDIR/bin/bash \"$MODDIR/common/scripts/Ash.sh\"" >> $MODDIR/cron.d/root
crond -c $MODDIR/cron.d

if [[ $(pgrep -f "AshOptimized/cron.d" | grep -v grep | wc -l) -ge 1 ]]; then
  log "Ash CrondScript is starting."
else
  log "Ash CrondScript isn't starting."
fi
