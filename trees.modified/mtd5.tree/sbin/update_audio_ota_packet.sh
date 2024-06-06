#!/bin/sh

AUDIO_FILE_PATH="/data/audio_file"


#判断是否已经升级过语音包
if [ -f /etc/jffs2/already_update_audio_flag ];then
    echo "already update audio"
    exit 0
fi

#下载升级包
mkdir -p /tmp/audio_down
echo "download audio_update.tar"
result=`/usr/bin/cloudAPI -c 300 -url http://yihome-publicfiles-us.oss-us-west-1.aliyuncs.com/fw615/audio_update.tar  -filename /tmp/audio_down/audio_update.tar | grep success`
if [ -z "$result" ];then
    echo "download audio_update.tar failed"
    exit 1
fi

echo "download audio_update.tar successfully"

#解压升级包
cd /tmp/audio_down
tar xvf audio_update.tar && rm -f audio_update.tar

#校验升级包
result=`md5sum -c /tmp/audio_down/audio_update.tgz.md5 | grep OK`
if [ -z "$result" ];then
    echo "MD5 check audio_update.tgz failed, can't updata"
    exit 1
fi

#校验通过升级语音包
/usr/sbin/update_factory_data.sh  audio

device_language=`cut -c 10-12 ${AUDIO_FILE_PATH}/language.conf`

if [ "$device_language" != "enu" ];then
    echo  "update language failed ,language is $device_language"
    exit 1
fi

#创建标记文件，表示已经升级过语音包
touch /etc/jffs2/already_update_audio_flag 

echo "update language successfully"
