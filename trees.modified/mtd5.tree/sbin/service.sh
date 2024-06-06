#! /bin/sh

MODE=$1

case "$MODE" in
	start)
		echo "start service.sh"
		/usr/sbin/wifi_driver.sh station
		ifconfig wlan0 up
		wpa_supplicant -c /etc/jffs2/wpa_supplicant.mine.conf -i wlan0 -B
        echo "sleeping 3"
        sleep 3
		ifconfig wlan0 up
		udhcpc -i wlan0 &
		echo "end-start service.sh"

		;;
	stop)
		echo "stop service.sh"
		;;
	restart)
		echo "restart service.sh"
		;;
	*)
		echo "usage service.sh"
		;;
esac
exit 0

