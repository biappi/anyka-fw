#!/bin/sh
# File:				update.sh	
# Provides:         
# Description:      update zImage&rootfs under dir1/dir2/...
# Author:			xc

VAR1="uImage"
VAR2="root.sqsh4"
VAR3="usr.sqsh4"
VAR4="usr.jffs2"
VAR5="audio_update.tgz"

ZMD5="uImage.md5"
SMD5="usr.sqsh4.md5"
JMD5="usr.jffs2.md5"
RMD5="root.sqsh4.md5"
AMD5="audio_update.tgz.md5"

DIR1="/tmp"
DIR2="/mnt"
UPDATE_DIR_TMP=0
UPDATE_WAY=0 #0:表示TF升级; 1:表示OTA升级

cfgfile="/etc/jffs2/anyka_cfg.ini"
ssid=`cat $cfgfile | grep -w 'ssid' | awk '{print $3}'`

update_voice_tip()
{
	echo "play update voice tips"

	REGION=`sed -n '4p' /etc/jffs2/yi.conf | cut -c 9-10`
	echo $REGION
	#if [ "$REGION" == "CN" ];then

    if [  -d /data ];then
        chmod 777 /tmp/ramdisk/ -R
        cp /data/audio_file/language/1.aac /tmp/ramdisk/update_success.aac
        if [ -f $DIR1/9.aac ];then
            #如果升级包存在语音，改为播放升级包里的“开始升级语音”
            ccli -t --f "$DIR1/9.aac"   
        else
            ccli -t --f "/data/audio_file/language/9.aac"   
        fi
    else
        if [ -z "$ssid" ];then
            echo "no bind,!choose us!"
            ln -s /usr/share/audio_file/us/ /tmp/audio
            chmod 777 /tmp/ramdisk/ -R
            cp -f /usr/share/audio_file/us/update_success.aac /tmp/ramdisk/update_success.aac
            chmod 777 /tmp/ramdisk/update_success.aac
        else
            if [ "$REGION" == "CN" ];then
                echo "bindkey CN!"
                ln -s /usr/share/audio_file/simplecn/ /tmp/audio
                chmod 777 /tmp/ramdisk/ -R
                cp -f /usr/share/audio_file/simplecn/update_success.aac /tmp/ramdisk/update_success.aac
                chmod 777 /tmp/ramdisk/update_success.aac
            else
                echo "bindkey not cn!choose us!"
                ln -s /usr/share/audio_file/us/ /tmp/audio
                chmod 777 /tmp/ramdisk/ -R
                cp -f /usr/share/audio_file/us/update_success.aac /tmp/ramdisk/update_success.aac
                chmod 777 /tmp/ramdisk/update_success.aac
            fi
        fi
        ccli -t --f "/tmp/audio/updating.aac"
    fi

	
	sleep 5
}

play_sd_update_voice()
{
	REGION=`sed -n '4p' /etc/jffs2/yi.conf | cut -c 9-10`
	echo $REGION
	#if [ "$REGION" == "CN" ];then
    if [  -d /data ];then
        chmod 777 /tmp/ramdisk/ -R
        cp /data/audio_file/language/1.aac /tmp/ramdisk/update_success.aac
        ak_adec_demo 16000 1 aac /data/audio_file/language/9.aac
    else
        if [ -z "$ssid" ];then
            echo "no bind!choose us!"
            ln -s /usr/share/audio_file/us/ /tmp/audio
            chmod 777 /tmp/ramdisk/ -R
            cp -f /usr/share/audio_file/us/update_success.aac /tmp/ramdisk/update_success.aac
            chmod 777 /tmp/ramdisk/update_success.aac
        else
            if [ "$REGION" == "CN" ];then
                echo "bindkey CN!"
                ln -s /usr/share/audio_file/simplecn/ /tmp/audio
                chmod 777 /tmp/ramdisk/ -R
                cp -f /usr/share/audio_file/simplecn/update_success.aac /tmp/ramdisk/update_success.aac
                chmod 777 /tmp/ramdisk/update_success.aac
            else
                echo "bindkey not cn!choose us!"
                ln -s /usr/share/audio_file/us/ /tmp/audio
                chmod 777 /tmp/ramdisk/ -R
                cp -f /usr/share/audio_file/us/update_success.aac /tmp/ramdisk/update_success.aac
                chmod 777 /tmp/ramdisk/update_success.aac
            fi
        fi
        ak_adec_demo 16000 1 aac /tmp/audio/updating.aac
    fi
	
}

update_ispconfig()
{
	rm -rf /etc/jffs2/isp*.conf
}

update_kernel()
{
	echo "check ${VAR1}............................."

	if [ -e ${DIR1}/${VAR1} ] 
	then
		if [ -e ${DIR1}/${ZMD5} ];then

			result=`md5sum -c ${DIR1}/${ZMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check zImage failed, can't updata"
				return
			else
				echo "MD5 check zImage success"
			fi
		fi

		echo "update ${VAR1} under ${DIR1}...."
		updater local KERNEL=${DIR1}/${VAR1}
	fi	
}

update_squash()
{		
	echo "check ${VAR3}.........................."

	if [ -e ${DIR1}/${VAR3} ]
	then
		if [ -e ${DIR1}/${SMD5} ];then

			result=`md5sum -c ${DIR1}/${SMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check usr.sqsh4 failed, can't updata"
				return
			else
				echo "MD5 check usr.sqsh4 success"
			fi
		fi

		echo "update ${VAR3} under ${DIR1}...."
		updater local B=${DIR1}/${VAR3}
	fi	
}

update_jffs2()
{
	echo "check ${VAR4}........................"

	if [ -e ${DIR1}/${VAR4} ]
	then
		if [ -e ${DIR1}/${JMD5} ];then

			result=`md5sum -c ${DIR1}/${JMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check usr.jffs2 failed, can't updata"
				return
			else
				echo "MD5 check usr.jffs2 success"
			fi
		fi

		echo "update ${VAR4} under ${DIR1}...."
		updater local C=${DIR1}/${VAR4}
	fi	
}

update_rootfs_squash()
{		
	echo "check ${VAR2}.........................."

	if [ -e ${DIR1}/${VAR2} ]
	then
		if [ -e ${DIR1}/${RMD5} ];then

			result=`md5sum -c ${DIR1}/${RMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check root.sqsh4 failed, can't updata"
				return
			else
				echo "MD5 check root.sqsh4 success"
			fi
		fi

		echo "update ${VAR2} under ${DIR1}...."
		updater local A=${DIR1}/${VAR2}
	fi	
}

#D030AP
update_audio()
{		
	echo "check ${VAR5}.........................."

	if [ -e ${DIR1}/${VAR5} ]
	then
		if [ -e ${DIR1}/${AMD5} ];then

			result=`md5sum -c ${DIR1}/${AMD5} | grep OK`
			if [ -z "$result" ];then
				echo "MD5 check audio_update.tgz failed, can't updata"
				return
			else
				echo "MD5 check audio_update.tgz success"
			fi
		fi

		echo "update ${VAR5} under ${DIR1}...."

        mkdir -p /tmp/audio_down
        cp ${DIR1}/${VAR5}  /tmp/audio_down/audio_update.tgz
		# updater local A=${DIR1}/${VAR5}
        cp /usr/sbin/update_factory_data.sh  /tmp/audio_down/
        /tmp/audio_down/update_factory_data.sh  audio
        cp /data/audio_file/language/1.aac /tmp/ramdisk/update_success.aac
	fi	
}

update_check_image()
{
	echo "check update image .........................."

	for target in ${VAR1} ${VAR2} ${VAR3} ${VAR4} ${VAR5}
	do
		if [ -f ${DIR1}/${target} ]; then
			echo "find a target ${target}, update in /tmp"
			UPDATE_DIR_TMP=1
			break
		fi	
	done
}

#
# main:
#
#echo ""
#echo "### enter update.sh ###"
#echo "stop system service before update....."
if [ -e /mnt/update/update.tar ];then
	echo "TF update"
	UPDATE_WAY=0
	cp /mnt/update/update.tar /tmp/
else
	if [ -e /tmp/update.tar ];then
		echo "OTA update"
		UPDATE_WAY=1
	else
		echo "No update file, exit update"
		exit 1
	fi
fi

tar -xvf /tmp/update.tar -C /tmp/
if [ $? -ne 0 ];then
	echo "extract update file error"
	exit 1
fi

tar_ver=`cat /tmp/fw_version`
dev_ver=`cat /usr/fw_version`
echo "UP  VER:$tar_ver"
echo "DEV VER:$dev_ver"
echo "UPDATE_WAY:($UPDATE_WAY)==>0:TF update ; 1:OTA update"
if [ $UPDATE_WAY -ne 0 ];then #不等于0表示OTA升级
	if [ "$tar_ver" \> "$dev_ver" ]
	then echo "TAR VER is newer than the DEV VER"
	else
		echo "DEV VER IS OLD"
		rm ${DIR1}/${VAR3} ${DIR1}/${VAR1} ${DIR1}/${VAR2} ${DIR1}/${VAR4} ${DIR1}/${VAR5}
		exit 1
	fi
else #走TF升级
	if [ "$tar_ver" != "$dev_ver" ];then 
		echo "TAR VER is not equal (!=)"
	else
		echo "DEV VER IS equal (==)"
		rm ${DIR1}/${VAR3} ${DIR1}/${VAR1} ${DIR1}/${VAR2} ${DIR1}/${VAR4} ${DIR1}/${VAR5}
		exit 1
	fi
fi

killall -15 syslogd
killall -15 klogd
killall -15 tcpsvd

# send signal to stop watchdog
killall -12 daemon
sleep 3 #waiting watchdog close
killall -9 daemon
killall -9 anyka_ipc
 
anyka_ipc adec_mode &
sleep 10

PIDS=`ps -ef | grep anyka_ipc | grep -v grep | awk '{print $1}'`
if [ "$PIDS" != "" ];then
	echo "anyka_ipc is running"
	# play update vioce tip
	update_voice_tip
else
	echo "anyka_ipc is stopped!sd_update!"
	play_sd_update_voice
fi

killall -9 net_manage.sh
/usr/sbin/wifi_manage.sh stop
killall -9 smartlink

echo "############ please wait a moment. And don't remove TFcard or power-off #############"

/usr/sbin/update_play_aac.sh &

#led blink
/usr/sbin/led.sh blink 50 50

# cp busybox to tmp, avoid the command become no use
cp /bin/busybox /tmp/
chmod 777 /tmp -R
chmod 777 /tmp/busybox
#rm -rf /mnt/update
#sync
update_check_image

if [ $UPDATE_DIR_TMP -ne 1 ];then
	## copy the image file to /tmp to avoid update fail on TF-card
	for dir in ${VAR1} ${VAR2} ${VAR3} ${VAR4} ${VAR5}
	do
		cp ${DIR2}/${dir} /tmp/ 2>/dev/null
		cp ${DIR2}/${dir}.md5 /tmp/ 2>/dev/null
	done
	umount /mnt/ -l
	echo "update use image from /mnt"
else
	echo "update use image from /tmp"
fi
cd ${DIR1}

update_ispconfig

if [ -d /data ];then
    update_audio
    if [ -f $DIR1/special.sh ];then
        $DIR1/special.sh
    fi
fi

update_kernel
update_jffs2
update_squash
update_rootfs_squash

/tmp/busybox echo "############ update finished, reboot now #############"
killall -9 update_play_aac.sh

/tmp/busybox sleep 3

ccli -t --f "/tmp/ramdisk/update_success.aac"
/tmp/busybox sleep 5
/tmp/busybox reboot -f
