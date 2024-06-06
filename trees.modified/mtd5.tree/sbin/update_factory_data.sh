#!/bin/sh

AUDIO_FILE_PATH="/data/audio_file"
AUDIO_UPDATE_PACKET_ON_MEMORY="/tmp/audio_down/audio_update.tgz"
AUDIO_UPDATE_PACKET_ON_SD="/mnt/v200_update/audio_update.tgz"
AUDIO_UPDATE_TMP_PATH="/tmp/audio_update"

#固件存储sensor文件的位置
SENSOR_FILE_PATH="/etc/jffs2/"
#SD卡存放sensor文件的路径
NEW_SENSOR_FILE_PATH="/mnt/v200_update"

#固件存储wifi驱动的位置
WIFI_FILE_PATH="/data"
#SD卡存放wifi升级包的路径
NEW_WIFI_FILE_PATH="/mnt/v200_update"

FILE_NAME=""
NEW_FILE_PATH=""
FILE_PATH=""


MODE=$1

usage()
{
	echo "Usage: $0 audio|all)"
	exit 3
}


copy_file()
{
    NEW_FILE_PATH=$1
    FILE_PATH=$2
    FILE_NAME=$3

    if [ -f $NEW_FILE_PATH/$FILE_NAME ];then
        echo "found $NEW_FILE_PATH/$FILE_NAME, update it"
        MD5UM=`md5sum ${FILE_PATH}/${FILE_NAME} | awk '{print $1}'`
        NEW_MD5UM=`md5sum ${NEW_FILE_PATH}/${FILE_NAME} | awk '{print $1}' `
        echo "copy_file md5dum ${MD5UM} ${NEW_MD5UM}"
        if [ "${MD5UM}" != "${NEW_MD5UM}" ];then
            echo "check md5sum diff,copy ${FILE_NAME}"
            rm -f ${FILE_PATH}/${FILE_NAME}
            cp ${NEW_FILE_PATH}/${FILE_NAME} ${FILE_PATH}/${FILE_NAME}
            MD5UM=`md5sum ${FILE_PATH}/${FILE_NAME} | awk '{print $1}'`
            if [ "${MD5UM}" = "${NEW_MD5UM}" ];then
                echo "copy ${NEW_FILE_PATH}/${FILE_NAME} to ${FILE_PATH}/${FILE_NAME}successfully"
                mv ${NEW_FILE_PATH}/${FILE_NAME} ${NEW_FILE_PATH}/${FILE_NAME}.done
                return 1
            else
                echo "copy ${NEW_FILE_PATH}/${FILE_NAME} to ${FILE_PATH}/${FILE_NAME} failed"
            fi
        fi 
    fi
    return 0
}


update_audio_file()
{
    if [ -f $AUDIO_UPDATE_PACKET_ON_SD ];then
        echo "found audio update packet on SD, update it"
        # cp -f $AUDIO_UPDATE_PACKET_ON_SD $AUDIO_UPDATE_PACKET
        rm -rf $AUDIO_FILE_PATH/*
        tar zxvf $AUDIO_UPDATE_PACKET_ON_SD -C $AUDIO_FILE_PATH
        mv $AUDIO_UPDATE_PACKET_ON_SD  $AUDIO_UPDATE_PACKET_ON_SD.done

    elif [ -f ${AUDIO_UPDATE_PACKET_ON_MEMORY} ];then
        echo "found audio update packet on memory, update it"
        rm -rf $AUDIO_FILE_PATH/*
        tar zxvf $AUDIO_UPDATE_PACKET_ON_MEMORY -C $AUDIO_FILE_PATH
        rm $AUDIO_UPDATE_PACKET_ON_MEMORY
    fi

    # if [ -f ${AUDIO_UPDATE_PACKET} ];then
    #     mkdir -p $AUDIO_UPDATE_TMP_PATH
    #     tar zxvf $AUDIO_UPDATE_PACKET -C /tmp/audio_update
    #     device_language=`cut -c 10-12 ${AUDIO_FILE_PATH}/language.conf`
    #     update_language=`cut -c 10-12 ${AUDIO_UPDATE_TMP_PATH}/language.conf`

    #     if [ "$device_language" != "$update_language"];then
    #         echo "different language, start to update"
    #         rm -rf $AUDIO_FILE_PATH/*
    #         cp -a $AUDIO_UPDATE_TMP_PATH/*  $AUDIO_FILE_PATH/
    #         chmod -R 777 $AUDIO_FILE_PATH/*
    #         ccli -t --f "/data/audio_file/language/1.aac"
    #     else
    #         echo "same language, don't need to update"
    #         ccli -t --f "/data/audio_file/language/1.aac"
    #     fi
    # fi
}

update_sensor_file()
{
    copy_file $NEW_SENSOR_FILE_PATH $SENSOR_FILE_PATH "sensor.tgz"
    ret=$?

    if [ $ret = 1 ];then
        echo "sensor file changed, reboot"
        reboot
        #rm -f /tmp/sensor_ko_and_isp_conf/*
        #tar zxvf $SENSOR_FILE_PATH/sensor.tgz -C  /tmp/sensor_ko_and_isp_conf/
        #find /tmp/sensor_ko_and_isp_conf -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;

    fi
}

update_wifi_file()
{
    copy_file $NEW_WIFI_FILE_PATH $WIFI_FILE_PATH "wifi_driver.sh"
    copy_file $NEW_WIFI_FILE_PATH $WIFI_FILE_PATH "wifi_station.sh"
    copy_file $NEW_WIFI_FILE_PATH $WIFI_FILE_PATH "wifi_driver.tgz"
    copy_file $NEW_WIFI_FILE_PATH $WIFI_FILE_PATH "wifi_tool.tgz"
}




case "$MODE" in
	audio)
		update_audio_file
		;;
	all)
		update_audio_file
        update_wifi_file
        update_sensor_file
		;;
	*)
		usage
		;;
esac
exit 0