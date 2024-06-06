#!/bin/sh
# File:				update.sh	
# Provides:         
# Description:      recover system configuration
# Author:			aj

cfgfile="/etc/jffs2/anyka_cfg.ini"

play_recover_tip()
{
	ssid=`cat $cfgfile | grep -w 'ssid' | awk '{print $3}'`

    if [ ! -d /data ];then
        if [ -z "$ssid" ];then
            ccli -t --f "/usr/share/audio_file/common/poweroff.aac"
        else
            ccli -t --f "/tmp/audio/reset.aac"
        fi
    else
        if [ -z "$ssid" ] && [ ! -d /mnt/Factory/data ];then
            ccli -t --f "/data/audio_file/language/1001.aac"
        else
            ccli -t --f "/data/audio_file/language/11.aac"
        fi
    fi
	
	sleep 3
}

play_recover_tip

#recover factory config ini
cp /usr/local/factory_cfg.ini /etc/jffs2/anyka_cfg.ini
cp /usr/local/yi_cfg.ini /etc/jffs2/yi_cfg.ini
rm /etc/jffs2/logStatus.conf -rf
rm /etc/jffs2/wifi_mac.ini -f
sync

#recover isp config ini
rm -rf /etc/jffs2/isp*.conf

