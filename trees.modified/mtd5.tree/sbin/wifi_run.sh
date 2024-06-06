#! /bin/sh
### BEGIN INIT INFO
# File:				wifi_run.sh	
# Provides:         manage wifi station and smartlink
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description:start wifi run at station or smartlink
# Author:			
# Email: 			
# Date:				2012-8-8
### END INIT INFO

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin
MODE=$1
cfgfile="/etc/jffs2/anyka_cfg.ini"
TEST_MODE=0

play_please_config_net()
{
	echo "play please config wifi tone"
	#ccli -t --f "/usr/share/anyka_please_config_net.aac"
}

play_get_config_info()
{
	echo "play get wifi config tone"
	#ccli -t --f "/usr/share/anyka_camera_get_config.aac"
}

play_wifi_connecting()
{
	echo "play wifi connecting tone"
	#ccli -t --f "usr/share/anyka_wifi_connecting.aac"

}

play_password_err()
{
	echo "play password error tone"
	#ccli -t --f "usr/share/anyka_password_err.aac"
}

play_afresh_net_config()
{
	echo "play please afresh config net tone"
	#ccli -t --f "/usr/share/anyka_afresh_net_config.aac"
}

connect_failed_wait_reset()
{
	echo "red blue led blink, waiting for user reset"

}

using_static_ip()
{
	ipaddress=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/^ipaddr/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	
	netmask=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/^netmask/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`
	gateway=`awk 'BEGIN {FS="="}/\[ethernet\]/{a=1} a==1&&$1~/^gateway/{gsub(/\"/,"",$2);gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`

	ifconfig wlan0 $ipaddress netmask $netmask
	route add default gw $gateway
	#sleep 1
}


station_install()
{
	### remove all wifi driver
	/usr/sbin/wifi_driver.sh uninstall	

	## install station driver
	/usr/sbin/wifi_driver.sh station
	i=0
	###### wait until the wifi driver insmod finished.
	while [ $i -lt 30 ]
	do
		if [ -d "/sys/class/net/wlan0" ];then
			ifconfig wlan0 up
			break
		else
			sleep 1
			i=`expr $i + 1`
		fi
	done
	
	if [ $i -eq 30 ];then
		echo "wifi driver install error, exit"
		return 1
	fi

	echo "wifi driver install OK"
	return 0
}

wpa_start()
{
	/usr/sbin/wifi_station.sh start
}

station_connect()
{	
	pid=`pgrep wpa_supplicant`
	if [ -z "$pid" ];then
		echo "the wpa_supplicant init failed, exit start wifi"
		return 1
	fi

	play_wifi_connecting

	/usr/sbin/wifi_station.sh connect
	ret=$?
	echo "wifi connect return val: $ret"
	if [ $ret -eq 0 ];then
		if [ -d "/sys/class/net/eth0" ]
		then
			ifconfig eth0 down
			ifconfig eth0 up
		fi
		echo "wifi connected!"
		return 0
	else
		echo "[station connect] wifi station connect failed"
	fi

	return $ret
}

station_start()
{
	station_install

	wpa_start
	
	station_connect
	ret=$?
	return $ret
}

check_wifi_config_update()
{
	while true
	do
        ### dana app update wifi config info,save info to /tmp/wifi_info
		### check /tmp/wifi_info then do wifi station connect
		if [ -e "/tmp/wifi_info" ];then
			station_connect
	        if [ $? -eq 0 ];then
				echo "wifi config updated successfully!!!"
				continue
			else
				station_connect
				ret=$?
				if [ $ret -eq 0 ];then
					echo "connect back to the original wifi!!!"
					continue
				fi
				echo "connect failed 3, ret: $ret, please check your ssid and password !!!"
				if [ $ret -eq 3 ];then
					play_password_err
				fi
				/usr/sbin/wifi_station.sh stop
				break
			fi
		fi
		sleep 1
		echo -n "" > /tmp/wpa_log
	done
	
	connect_failed_wait_reset
}

#main
#wifi test alone, no need to check wifi at factory test
#if test -e /etc/jffs2/danale.conf ;then
#	TEST_MODE=0
#else
#	TEST_MODE=1
#fi


ssid=`awk 'BEGIN {FS="="}/\[wireless\]/{a=1} a==1 && $1~/^ssid/{gsub(/\"/,"",$2);
	gsub(/\;.*/, "", $2);gsub(/^[[:blank:]]*/,"",$2);print $2}' $cfgfile`

if [ "$ssid" = "" ]
then
	###wifi station driver install, then wait danaairlink send config info
	station_install
	
	play_please_config_net

	while true
	do
		### when get config info, anyka_ipc will save ssid info to /tmp/wireless
		### check /tmp/wireless then do wifi station connect
		if [ -e "/tmp/wireless/gbk_ssid" ];then		
			play_get_config_info
			wpa_start
			station_connect
			ret=$?
			if [ $ret -eq 0 ];then
				check_wifi_config_update
			else
				echo "connect failed 1, ret: $ret, please check your ssid and password !!!"
				if [ $ret -eq 3 ];then
				    play_password_err
				fi
				play_afresh_net_config
				rm -rf /tmp/wireless/
				echo -n "" > /tmp/wpa_log
				/usr/sbin/wifi_station.sh stop
				#break
			fi
		fi

		sleep 1
	done
	connect_failed_wait_reset

fi

station_start
ret=$?
if [ $ret -eq 0 ];then
	check_wifi_config_update
else
	echo "connect failed 2, ret: $ret, please check your ssid and password !!!"
	if [ $ret -eq 3 ];then
        play_password_err
	fi
	#/usr/sbin/wifi_station.sh stop
	#connect_failed_wait_reset
fi

