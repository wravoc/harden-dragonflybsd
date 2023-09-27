#!/usr/local/bin/zsh

# Quadhelion Engineering
# ⨌ ☉ ℏ
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
# https://got.quadhelion.engineering
# License: QHELP-OME-NC-ND-NAI
# License URL: https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html

# Primary Target: Dragonfly BSD 6.4

# Bold Terminal Color set
# Change 1 to 0 for normal font face
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
magenta='\033[1;35m'
cyan='\033[1;36m'
white='\033[0;37m'
red='\033[1;31m'
end='\033[0m'

# Begin
ifconfig_check=$(ifconfig -lu | awk '{ print $2 }')
router_check=$(ifconfig wlan0 | grep status | awk '{ print $2 }')

if [ $ifconfig_check = "wlan0" ] && [ $router_check = "associated" ]; then
	wifi_status="${green}Connected${end}"
	ip_address=$(curl -s ip.envs.net)
	dns_server=$(grep -m1 nameserver /etc/resolv.conf | awk '{ print $2 }')
else
	wifi_status="${magenta}Disconnected${end}"
fi

echo "                                                                        Dragonfly Status"
echo "                          ||.|..|...|..|.||----------------------------------------------------------------------||.|..|...|..|.||"
echo
echo "                                                                  ${white}\uF1EB${end}     $wifi_status"
echo "                                                                        $ip_address"
echo "                                                                        $dns_server"
echo

# Get system info
battery_percentage=$(sysctl hw.acpi.battery.life | awk '{ print $2 }')
battery_time=$(sysctl hw.acpi.battery.time | awk '{ print $2 }')
declare -i battery_life=$battery_time-11
cpu_current_clock=$(sysctl hw.acpi.cpu.px_global | awk '{ print $2 }')
cpu_speed=$(echo "scale=2; $cpu_current_clock/1000" | bc)
power_type=$(sysctl hw.acpi.acline | awk '{ print $2 }')
wifi_check=$(ifconfig -lu | awk '{ print $2 }')
cpu_temp=$(sysctl dev.amdtemp.0.core0.sensor0 | awk '{ print $2 }' | cut -c -2)
cpu_temp_max=$(sysctl hw.sensors.die0.temp0 | awk '{ print $2 }')
cpu_idle=$(top -b | grep -m1 CPU | awk '{ print $11 }' | cut -c -3)
declare -i cpu_utilization=100-$cpu_idle
free_memory=$(top -b | grep -m1 Memory | awk '{ print +$12 }')
hard_drive_filled=$(df / | awk '{ print $5 }' | tail -1)
celsius="C"

if [ $power_type -eq 1 ]; then
	echo "                                                                  ${white}\xE2\x9A\xA1${end}   $magenta Adapter $end"
else
	echo "                                                                  ${white}\xE2\x9A\xA1${end}   $cyan Battery $end"
fi

echo

if [ $battery_percentage -ge 65 ] && [ $power_type -ne 1 ]; then
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $green ${battery_percentage}%${end}"
	echo "                                                                        ${battery_life}mins"
elif [ $battery_percentage -ge 65 ] && [ $power_type -eq 1 ]; then
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $green ${battery_percentage}%${end}"
elif [ $battery_percentage -lt 65 ] && [ $battery_percentage -ge 25 ] && [ $power_type -ne 1 ]; then
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $yellow ${battery_percentage}%${end}"
	echo "                                                                        ${battery_life}mins"
elif [ $battery_percentage -lt 65 ] && [ $battery_percentage -ge 25 ] && [ $power_type -eq 1 ]; then
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $yellow ${battery_percentage}%${end}"
elif [ $battery_percentage -lt 25 ] && [ $power_type -ne 1 ]; then
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $red ${battery_percentage}%${end}"
	echo "                                                                        ${battery_life}mins"
elif [ $battery_percentage -lt 25 ] && [ $power_type -eq 1 ]; then
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $red ${battery_percentage}%${end}"
elif [ $battery_percentage -le 10 ] || [ $battery_life -le 10 ] && [ $power_type -ne 1 ]; then
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $red ${battery_percentage}%${end}"
	echo "                                                                        ${battery_life}mins ${red}\xE2\x8C\x9B${end}"
elif [ $battery_percentage -le 10 ] || [ $battery_life -le 10 ] && [ $power_type -eq 1 ]; then
	echo -en '\a' >/dev/ttyv0
	echo -en '\a' >/dev/ttyv0
	echo "                                                                  ${white}\xF0\x9F\x94\x8B${end}   $red ${battery_percentage}%${end}"
fi

echo
echo "                                                                  ${white}\xF0\x9F\x96\xA5${end}     ${cpu_speed} GHz"

if [ $cpu_temp -le 85 ]; then
	echo "                                                                        ${cpu_temp}\xC2\xB0${celsius}"
else
	echo -en '\a' >/dev/ttyv0
	echo -en '\a' >/dev/ttyv0
	echo "                                                                        ${cpu_temp}\xC2\xB0${celsius} ${red}\xF0\x9F\x8C\xA1${end}"
fi

echo "                                                                        ${cpu_utilization}%"
echo "                                                                        ${free_memory} MB"
echo
echo "                                                                  ${white}\xF0\x9F\x96\xB4${end}     ${hard_drive_filled}"
echo
echo "                          ||.|..|...|..|.||----------------------------------------------------------------------||.|..|...|..|.||"
