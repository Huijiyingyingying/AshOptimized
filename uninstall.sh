
echo 0 > /sys/class/power_supply/battery/input_suspend
echo 1 > /sys/class/power_supply/battery/charging_enabled

rm -rf /data/system/package_cache
