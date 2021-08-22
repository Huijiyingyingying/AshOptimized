MODDIR=${0%/*}

chown root:root $MODDIR/common/scripts/AshScripts.sh
chmod 777 $MODDIR/common/scripts/AshScripts.sh
nohup $MODDIR/common/scripts/AshScripts.sh &

stop tcpdump
stop cnss_diag
rm -rf /data/vendor/charge_logger/
rm -rf /data/vendor/wlan_logs/

# 禁用sda主数据分区读写统计
echo "0" > /sys/block/sda/queue/iostats
# 禁用sde次要数据分区读写统计
echo "0" > /sys/block/sde/queue/iostats
# 禁用binder活页夹日志输出
echo "0" > /sys/module/binder/parameters/debug_mask
# 禁用binder活页夹分配器日志输出
echo "0" > /sys/module/binder_alloc/parameters/debug_mask
# 更改磁盘预读为128k sda主分区
echo "128" > /sys/block/sda/queue/read_ahead_kb
# 更改磁盘预读为128k sde次要分区
echo "128" > /sys/block/sde/queue/read_ahead_kb
# 更改磁盘NR分配块 sda主分区
echo "36" > /sys/block/sda/queue/nr_requests
# 更改磁盘NR分配块 sde次要分区
echo "36" > /sys/block/sde/queue/nr_requests
# 更改虚拟内存page集群数量
echo "0" > /proc/sys/vm/page-cluster
# 更改虚拟内存更新间隔, 减少性能抖动
echo "20" > /proc/sys/vm/stat_interval

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
    echo $pid > /dev/cpuset/top-app/cgroup.procs
    echo $pid > /dev/stune/top-app/cgroup.procs
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

echo "2" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "0" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "2" > /proc/sys/net/ipv4/tcp_keepalive_probes
echo "2" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "0" > /proc/sys/net/ipv4/tcp_timestamps
echo "3" > /proc/sys/net/ipv4/tcp_fastopen
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
echo "1048576" > /proc/sys/net/core/rmem_default
echo "1048576" > /proc/sys/net/core/wmem_default
ip route | while read r; do
ip route change $r initcwnd 20;
done
ip route | while read r; do
ip route change $r initrwnd 40;
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
