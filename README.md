Personal firmware for Anyka cameras
-----------------------------------

This repo contains scripts, notes and personal firmware for using a cheap
Anyka wifi camera without using any account at all.


## CPU Info

The chipset is: **AK3918EN080**

```
[root@anyka ~]$ cat /proc/cpuinfo 
Processor       : ARM926EJ-S rev 5 (v5l)
BogoMIPS        : 199.06
Features        : swp half fastmult edsp java 
CPU implementer : 0x41
CPU architecture: 5TEJ
CPU variant     : 0x0
CPU part        : 0x926
CPU revision    : 5

Hardware        : Cloud39EV2_AK3918E80PIN_MNBD
Revision        : 0000
Serial          : 0000000000000000
```

```
[root@anyka ~]$ uname -a
Linux anyka 3.4.35 #2 Mon Sep 25 14:25:49 CST 2023 armv5tejl GNU/Linux
```


## U-Boot

Out of the box U-Boot environment

```
anyka$ env print
backuppage=ffffffff
baudrate=115200
boot_normal=readcfg; run read_kernel; bootm ${loadaddr}
bootargs=console=ttySAK0,115200n8 root=/dev/mtdblock4 rootfstype=squashfs init=/sbin/init mem=64M memsize=64M
bootcmd=run boot_normal
bootdelay=0
console=ttySAK0,115200n8
erase_env=sf probe 0:0 ${sf_hz} 0; sf erase 0x20000 0x2000
ethaddr=00:55:7b:b5:7d:f7
fs_addr=0x230000
init=/sbin/init
ipaddr=192.168.1.99
kernel_addr=31000
kernel_size=159f88
loadaddr=81808000
memsize=64M
mtd_root=/dev/mtdblock4 
netmask=255.255.255.0
read_kernel=sf probe 0:0 ${sf_hz} 0; sf read ${loadaddr} ${kernel_addr} ${kernel_size}
rootfstype=squashfs
serverip=192.168.1.1
setcmd=setenv bootargs console=${console} root=${mtd_root} rootfstype=${rootfstype} init=${init} mem=${memsize}
sf_hz=20000000
stderr=serial
stdin=serial
stdout=serial
update_flag=0
ver=U-Boot 2013.10.0-AK_V2.0.04 (Jun 05 2023 - 14:05:38)
vram=12M

Environment size: 950/4088 bytes

anyka$
```


## Firmware dump

The layout of the MTD device

```
/data # cat /proc/mtd
dev:    size   erasesize  name
mtd0: 00800000 00001000 "spi0.0"
mtd1: 00180000 00001000 "KERNEL"
mtd2: 00001000 00001000 "MAC"
mtd3: 00001000 00001000 "ENV"
mtd4: 00100000 00001000 "A"
mtd5: 002f5000 00001000 "B"
mtd6: 00010000 00001000 "C"
mtd7: 0022a000 00001000 "D"
```

How i got the dump

```
/data # nanddump /dev/mtd0 | nc 192.168.1.128 31337
/data # nanddump /dev/mtd1 | nc 192.168.1.128 31337
/data # nanddump /dev/mtd2 | nc 192.168.1.128 31337
/data # nanddump /dev/mtd3 | nc 192.168.1.128 31337
/data # nanddump /dev/mtd4 | nc 192.168.1.128 31337
/data # nanddump /dev/mtd5 | nc 192.168.1.128 31337
/data # nanddump /dev/mtd6 | nc 192.168.1.128 31337
/data # nanddump /dev/mtd7 | nc 192.168.1.128 31337
/data # 
```

```
willy@Hitagi ankya$ nc -l 31337 > mtd0
willy@Hitagi ankya$ nc -l 31337 > mtd1
willy@Hitagi ankya$ nc -l 31337 > mtd2
willy@Hitagi ankya$ nc -l 31337 > mtd3
willy@Hitagi ankya$ nc -l 31337 > mtd4
willy@Hitagi ankya$ nc -l 31337 > mtd5
willy@Hitagi ankya$ nc -l 31337 > mtd6
willy@Hitagi ankya$ nc -l 31337 > mtd7
```

Filesystem layout

```
[root@anyka ~]$ mount
rootfs on / type rootfs (rw)
/dev/root on / type squashfs (ro,relatime)
devtmpfs on /dev type devtmpfs (rw,relatime,mode=0755)
proc on /proc type proc (rw,relatime)
tmpfs on /tmp type tmpfs (rw,relatime)
tmpfs on /var type tmpfs (rw,relatime)
devpts on /dev/pts type devpts (rw,relatime,mode=600,ptmxmode=000)
tmpfs on /mnt type tmpfs (rw,relatime)
sysfs on /sys type sysfs (rw,relatime)
/dev/mtdblock5 on /usr type squashfs (ro,relatime)
/dev/mtdblock6 on /etc/jffs2 type jffs2 (rw,relatime)
/dev/mtdblock7 on /data type jffs2 (rw,relatime)
/dev/loop0 on /tmp/ramdisk type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=cp437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
```
