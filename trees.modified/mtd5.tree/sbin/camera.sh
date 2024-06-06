#! /bin/sh
### BEGIN INIT INFO
# File:				camera.sh	
# Provides:         
# Required-Start:   $
# Required-Stop:
# Default-Start:     
# Default-Stop:
# Short-Description: install or remove camera drivers
# Author:			
# Email: 			
# Date:				2015-9-28
### END INIT INFO

MODE=$1

usage()
{
	echo "Usage: $0 setup | remove"
}


camera_remove()
{
	rmmod /usr/modules/ak_info_dump.ko
	rmmod /usr/modules/akcamera.ko
	find /usr/modules -maxdepth 1 -type f -name "sensor_*.ko" -exec rmmod {} \;
	find /etc/jffs2 -maxdepth 1 -type f -name "sensor_*.ko" -exec rmmod {} \;
    if [ -d /data/ ];then
        find /data/sensor_ko_and_isp_conf -maxdepth 1 -type f -name "sensor_*.ko" -exec rmmod {} \;
        find /mnt/Factory/data/sensor -maxdepth 1 -type f -name "sensor_*.ko" -exec rmmod {} \;
    fi
}

camera_setup()
{
	find /etc/jffs2 -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;
	find /usr/modules -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;

    if [ -d /data/ ];then

        #挂载SD卡
        if test -e /dev/mmcblk0p1 ;then
            mount -rw /dev/mmcblk0p1 /mnt
        elif test -e /dev/mmcblk0 ;then
            mount -rw /dev/mmcblk0 /mnt
        fi

        #产测下拷贝sensor驱动和IQ文件
        if [ -d /mnt/Factory/data ];then
            /mnt/Factory/data/data_copy.sh cp_sensor
        else
            echo "camera_setup:not factory mode"
        fi


        #解压sensor驱动并加载
        if [ -f /etc/jffs2/sensor.tgz ];then #说明是产测拷贝第二阶段的方式
            mkdir -p /tmp/sensor_ko_and_isp_conf/ && tar zxvf /etc/jffs2/sensor.tgz -C /tmp/sensor_ko_and_isp_conf/
            find /tmp/sensor_ko_and_isp_conf -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;
        else
            find /data/sensor_ko_and_isp_conf -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;
        fi

        #产测模式下，加载所有sensor驱动,用于产测的HW值指定的sensor类型不对时进行自动识别
        if [ -d /mnt/Factory/data ];then
            find /mnt/Factory/data/sensor -maxdepth 1 -type f -name "sensor_*.ko" -exec insmod {} \;
        fi

        #卸载SD卡
        if test -e /dev/mmcblk0p1 ;then
            umount  /mnt
        elif test -e /dev/mmcblk0 ;then
            umount  /mnt
        fi
    fi 
    
	insmod /usr/modules/akcamera.ko
	insmod /usr/modules/ak_info_dump.ko
}

case "$MODE" in
	setup)
		camera_setup
		;;
	remove)
		camera_remove
		;;
	*)
		usage
		;;
esac
exit 0

