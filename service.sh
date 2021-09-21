MODDIR=${0%/*}

chown root:root $MODDIR/common/scripts/AshScripts.sh
chmod 777 $MODDIR/common/scripts/AshScripts.sh
nohup $MODDIR/common/scripts/AshScripts.sh &

stop tcpdump
stop cnss_diag
rm -rf /data/vendor/charge_logger/
rm -rf /data/vendor/wlan_logs/
setprop sys.miui.ndcd off

# 禁用磁盘I/O统计 (UFS)
echo "0" > /sys/block/sda/queue/iostats
echo "0" > /sys/block/sdb/queue/iostats
echo "0" > /sys/block/sdc/queue/iostats
echo "0" > /sys/block/sdd/queue/iostats
echo "0" > /sys/block/sde/queue/iostats
echo "0" > /sys/block/sdf/queue/iostats
# 禁用binder调试
echo "0" > /sys/module/binder/parameters/debug_mask
echo "0" > /sys/module/binder_alloc/parameters/debug_mask
# 禁用内核调试
echo "0" > /sys/module/msm_show_resume_irq/parameters/debug_mask
echo "N" > /sys/kernel/debug/debug_enabled
# 数据分区I/O控制器优化
echo "128" > /sys/block/sda/queue/read_ahead_kb
echo "36" > /sys/block/sda/queue/nr_requests
echo "128" > /sys/block/sde/queue/read_ahead_kb
echo "36" > /sys/block/sde/queue/nr_requests
echo "128" > /sys/block/dm-5/queue/read_ahead_kb
echo "36" > /sys/block/dm-5/queue/nr_requests
# ZRAM分区参数调整
echo "128" > /sys/block/zram0/queue/read_ahead_kb
echo "36" > /sys/block/zram0/queue/nr_requests
# 调整虚拟空间页面集群
echo "0" > /proc/sys/vm/page-cluster
# 禁用不必要的转储
echo "0" > /sys/module/subsystem_restart/parameters/enable_ramdumps
# 禁用用户空间向dmesg写入日志
echo "off" > /proc/sys/kernel/printk_devkmsg
# 禁用sched_autogroup
echo "0" > /proc/sys/kernel/sched_autogroup_enabled
# 调整脏页写回策略时间
echo "3000" > /proc/sys/vm/dirty_expire_centisecs
# 禁用f2fs I/O数据收集统计
echo "0" > /sys/fs/f2fs/dm-5/iostat_enable
# 禁用调度统计
echo "0" > /proc/sys/kernel/sched_schedstats
# 调整虚拟内存统计间隔 (默认为1, 也就是1秒)
echo "20" > /proc/sys/vm/stat_interval
# 禁用用户空间向dmesg写入日志
echo "off" > /proc/sys/kernel/printk_devkmsg
# cfq-iosched调整
echo "16" > /sys/block/sda/queue/iosched/quantum
echo "1" > /sys/block/sda/queue/iosched/back_seek_penalty
# OOM杀手转储任务
echo "0" > /proc/sys/vm/oom_dump_tasks

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
