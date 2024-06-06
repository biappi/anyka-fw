#! /bin/sh
### BEGIN INIT INFO
# File:				service.sh
# Provides:         init service
# Required-Start:   $
# Required-Stop:
# Default-Start:
# Default-Stop:
# Short-Description:web service
# Author:			gao_wangsheng
# Email: 			gao_wangsheng@anyka.oa
# Date:				2012-12-27
### END INIT INFO

MODE=$1
PUSHID_MODE=0
TEST_MODE=0
FACTORY_TEST=0
DEBUG_MODE=0
UPDATE_MODE=0
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

hwConfigFile="/etc/jffs2/hw.conf"

usage()
{
	echo "Usage: $0 start|stop)"
	exit 3
}

## 检查日志开关, 默认关。
isLogOn=false
if [[ -f "/backup/logon" ]]; then
        isLogOn=true
else
		echo 3 > /proc/sys/kernel/printk
fi

checkLogSwitchRun()
{
	# echo "$1"
	if [[ "$isLogOn"x == "true"x ]]; then
		echo "isLogon=$isLogOn"
		$1
	else
		$1 > /dev/null 2>&1
	fi
}

stop_service()
{
	killall -12 daemon
	echo "watch dog closed"
	#sleep 5
	killall daemon
	killall cmd_serverd

	/usr/sbin/anyka_ipc.sh stop

	echo "stop network service......"
	killall net_manage.sh

    /usr/sbin/eth_manage.sh stop
    /usr/sbin/wifi_manage.sh stop
}

close_white_led()
{
    whiteLightNegativeFlag=`cut -b 24 ${hwConfigFile}`
    echo "close white led, whiteLightNegativeFlag = ${whiteLightNegativeFlag}"
    if [ $whiteLightNegativeFlag = 1 ]; then
        echo 1 > /sys/user-gpio/WHITE_LED
    else
        echo 0 > /sys/user-gpio/WHITE_LED
    fi
}

start_service ()
{
	checkLogSwitchRun cmd_serverd

    close_white_led

    #ulimit -c unlimited
	killall telnetd

    echo "1" > /proc/sys/kernel/core_uses_pid
    echo "/mnt/core_%e_%p_%t" > /proc/sys/kernel/core_pattern

	if [ $FACTORY_TEST = 1 ]; then
		/mnt/Factory/config.sh
		#insmod /mnt/usbnet/udc.ko
	    #insmod /mnt/usbnet/g_ether.ko
	    #sleep 1
	    #ifconfig eth0 up
	    #sleep 1
	    #/usr/sbin/eth_manage.sh start
		 echo "######start yunyi product test."
	#	 /mnt/usbnet/product_test & 
	elif [ $PUSHID_MODE = 1 ]; then
		while [ ! -e /etc/jffs2/yi.conf ]
		do
			echo "pls push sn."
			/mnt/yiSn/tf_burn_id.sh
			sleep 5
		done
	else
		if [ $UPDATE_MODE = 1 ]; then
	        echo "to do software update check."
		#ak_adec_demo 16000 1 aac /usr/share/updating.aac
	        /usr/sbin/update.sh
	    	fi
		if [ $DEBUG_MODE = 1 ]; then
	        echo "#################debug mode##############"
		/mnt/debug/config.sh
		fi

        ifconfig eth0 up
        sleep 1

		checkLogSwitchRun daemon

		if [ ! -e "/etc/jffs2/hw.conf" ];then
			echo "HW=12151005501110018000000000000000" > /etc/jffs2/hw.conf
			chmod 777 /etc/jffs2/hw.conf
		fi

        if [ ! -e "/etc/jffs2/hostapd_atmb.conf" ];then
			cp /usr/sbin/hostapd_atmb.conf /etc/jffs2/hostapd_atmb.conf -f
		fi

        if [ -f "/usr/sbin/update_factory_data.sh" ];then
            /usr/sbin/update_factory_data.sh all
        fi

		/usr/sbin/anyka_ipc.sh start 
		
		echo "start ipc service......"
	fi

	boot_from=`cat /proc/cmdline | grep nfsroot`
	if [ -z "$boot_from" ];then
		echo "start net service......"
		#/usr/sbin/net_manage.sh &
	else
		echo "## start from nfsroot, do not change ipaddress!"
	fi
	unset boot_from
}

restart_service ()
{
	echo "restart service......"
	stop_service
	start_service
}

#
# main:
#
if test -f /etc/jffs2/yi.conf ;then
	PUSHID_MODE=0
else
#	PUSHID_MODE=1
	TEST_MODE=1
fi

if [ ! -e "/etc/jffs2/time_zone.sh" ];then
	echo "export TZ=GMT-08:00" > /etc/jffs2/time_zone.sh
	chmod 777 /etc/jffs2/time_zone.sh
fi

if test -e /dev/mmcblk0p1 ;then
    mount -rw /dev/mmcblk0p1 /mnt
elif test -e /dev/mmcblk0 ;then
    mount -rw /dev/mmcblk0 /mnt
fi

if test -d /mnt/Factory ;then
	FACTORY_TEST=1
else
	FACTORY_TEST=0
fi

if test -d /mnt/debug ;then
	DEBUG_MODE=1
else
	DEBUG_MODE=0
fi
if test -d /mnt/update ;then
    UPDATE_MODE=1
else
    UPDATE_MODE=0
fi

case "$MODE" in
	start)
		start_service
		;;
	stop)
		stop_service
		;;
	restart)
		restart_service
		;;
	*)
		usage
		;;
esac
exit 0

