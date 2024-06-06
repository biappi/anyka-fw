#! /bin/sh
### BEGIN INIT INFO
# File:				camera.sh	
# Provides:         camera service 
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description:web service
# Author:			gao_wangsheng
# Email: 			gao_wangsheng@anyka.oa
# Date:				2012-8-8
### END INIT INFO

MODE=$1
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/data
mode=hostapd
network=
usage()
{
	echo "Usage: $0 start|stop)"
	exit 3
}

## 检查日志开关, 默认关。
isLogOn=false
if [[ -f "/backup/logon" ]]; then
        isLogOn=true
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

stop()
{
	killall -15 anyka_ipc
	echo "stopping ipc service......"
}

start ()
{
	echo "start ipc service......"
	pid=`pgrep anyka_ipc`
    if [ "$pid" = "" ]
    then
	    source /etc/jffs2/time_zone.sh
	    checkLogSwitchRun anyka_ipc &
	fi
}

restart ()
{
	echo "restart ipc service......"
	stop
	start
}

#
# main:
#

case "$MODE" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	*)
		usage
		;;
esac
exit 0

