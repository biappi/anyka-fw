#! /bin/sh
### BEGIN INIT INFO
# File:				station_connect.sh	
# Description:      wifi station connect to AP 
# Author:			gao_wangsheng
# Email: 			gao_wangsheng@anyka.oa
# Date:				2012-8-2
### END INIT INFO

MODE=$1
GSSID="$2"
sleep 1
T_GSSID1=${GSSID//\'/\\\'}
T_GSSID2=${T_GSSID1//\"/\\\"}
SSID=\\\"$T_GSSID2\\\"
echo "T_GSSID1=($T_GSSID1),T_GSSID2=($T_GSSID2),SSID=($SSID)"
GPSK="$3"
T_GPSK1=${GPSK//\'/\\\'}
T_GPSK2=${T_GPSK1//\"/\\\"}
PSK=\\\"$T_GPSK2\\\"
echo "T_GPSK1=($T_GPSK1),T_GPSK2=($T_GPSK2),PSK=($PSK)"
KEY=$PSK
KEY_INDEX=$4
KEY_INDEX=${KEY_INDEX:-0}
NET_ID=
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

usage()
{
	echo "Usage: $0 mode(wpa|wep|open) ssid password"
	exit 1
}

refresh_net()
{
	#### remove all connected netword
	while true
	do
		NET_ID=`wpa_cli -iwlan0 list_network\
			| awk 'NR>=2{print $1}'`

		if [ -n "$NET_ID" ];then
			wpa_cli -p/var/run/wpa_supplicant remove_network $NET_ID
		else
			break
		fi
	done
	wpa_cli -p/var/run/wpa_supplicant ap_scan 1
}

station_connect()
{	
	WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	echo "P_WPA_SPC $WPA_SPC_UP"
	while [ ! -n "$WPA_SPC_UP" ]
	do
			echo "wait wpa_supplicant up"
			sleep 1
			WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	done

	sh -c "wpa_cli -iwlan0 set_network $1 scan_ssid 1"
	wpa_cli -iwlan0 enable_network $1
	wpa_cli -iwlan0 select_network $1
#	wpa_cli -iwlan0 save_config
	
}

connect_wpa()
{
	WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	echo "P_WPA_SPC $WPA_SPC_UP"
	while [ ! -n "$WPA_SPC_UP" ]
	do
			echo "wait wpa_supplicant up"
			sleep 1
			WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	done
	
	
	NET_ID=""
	refresh_net

	NET_ID=`wpa_cli -iwlan0 add_network`
	sh -c "wpa_cli -iwlan0 set_network $NET_ID ssid $SSID"
	wpa_cli -iwlan0 set_network $NET_ID key_mgmt WPA-PSK
	sh -c "wpa_cli -iwlan0 set_network $NET_ID psk $PSK"

	station_connect $NET_ID
}

connect_wep()
{
	WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	echo "P_WPA_SPC $WPA_SPC_UP"
	while [ ! -n "$WPA_SPC_UP" ]
	do
			echo "wait wpa_supplicant up"
			sleep 1
			WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	done
	
	NET_ID=""
	refresh_net

	NET_ID=`wpa_cli -iwlan0 add_network`
	sh -c "wpa_cli -iwlan0 set_network $NET_ID ssid $SSID"
	wpa_cli -iwlan0 set_network $NET_ID key_mgmt NONE
	
	wpa_cli -iwlan0 set_network $NET_ID wep_key0 $GPSK
	wpa_cli -iwlan0 set_network $NET_ID wep_tx_keyidx 0
	#wpa_cli -iwlan0 set_network $NET_ID auth_alg SHARED
	
	station_connect $NET_ID
}

connect_open()
{
	WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	echo "P_WPA_SPC $WPA_SPC_UP"
	while [ ! -n "$WPA_SPC_UP" ]
	do
			echo "wait wpa_supplicant up"
			sleep 1
			WPA_SPC_UP=`ps | grep -v grep | grep wpa_supplicant`
	done
	
	NET_ID=""
	refresh_net
	
	NET_ID=`wpa_cli -iwlan0 add_network`
	sh -c "wpa_cli -iwlan0 set_network $NET_ID ssid $SSID"
	wpa_cli -iwlan0 set_network $NET_ID key_mgmt NONE

	station_connect $NET_ID
}

check_ssid_ok()
{
	if [ "$GSSID" = "" ]
	then
		echo "Incorrect ssid!"
		usage
	fi
}

check_password_ok()
{
	if [ "$GPSK" = "" ]
	then
		echo "Incorrect password!"
		usage
	fi
}


#
# main:
#
##  wifi_enc_type 
#	WIFI_ENCTYPE_NONE,
#	WIFI_ENCTYPE_WEP,
#	WIFI_ENCTYPE_WPA_TKIP,
#	WIFI_ENCTYPE_WPA_AES,
#	WIFI_ENCTYPE_WPA2_TKIP,
#	WIFI_ENCTYPE_WPA2_AES

echo $0 $*
case "$MODE" in
	1)
		check_ssid_ok
		connect_open
		;;
	2)
		check_ssid_ok
		check_password_ok
		connect_wep
		;;
	3 | 4 | 5 | 6)
		check_ssid_ok
		check_password_ok
		connect_wpa
		;;
	*)
		usage
		;;
esac
exit 0

