#!/sbin/busybox sh

# Ketut P. Kumajaya, Sept 2014
# Do not remove above credits header!

# Usage: fstab.sh [0|1] [sammy42|sammy44|cm110]

EXT4OPT="noatime,nosuid,nodev,discard,noauto_da_alloc,journal_async_commit,errors=panic    wait,check"
F2FSOPB="background_gc=off,inline_xattr,active_logs=2    wait"
F2FSOPT="noatime,nosuid,nodev,discard,$F2FSOPB"

# Galaxy Tab 3 T31x spesific config
FSTAB=/fstab.smdk4x12

SYSTEMDEV="\
/dev/block/platform/dw_mmc/by-name/SYSTEM    "
DATADEV="\
/dev/block/platform/dw_mmc/by-name/USERDATA  "
CACHEDEV="\
/dev/block/platform/dw_mmc/by-name/CACHE     "
HIDDENDEV="\
/dev/block/platform/dw_mmc/by-name/HIDDEN    "; # Same as CACHEDEV for a common /cache

EFS="\
/dev/block/platform/dw_mmc/by-name/EFS           /efs           ext4    nodiratime,$EXT4OPT"

# Galaxy Tab 3 T315 LTE
# TOMBSTONES="\
# /dev/block/platform/dw_mmc/by-name/TOMBSTONES    /tombstones    ext4    nodiratime,$EXT4OPT"
# RADIO="\
# /dev/block/platform/dw_mmc/by-name/RADIO         /firmware      vfat    ro,shortname=lower,fmask=0133,dmask=0022,context=u:object_r:radio_efs_file:s0    wait"

SAMMY44="
/devices/platform/s3c-sdhci.2/mmc_host/mmc1      auto           vfat    default    voldmanaged=extSdCard:auto,noemulatedsd
/devices/platform/s5p-ehci/usb1*sda              auto           vfat    default    voldmanaged=UsbDriveA:auto
/devices/platform/s5p-ehci/usb1*sdb              auto           vfat    default    voldmanaged=UsbDriveB:auto
/devices/platform/s5p-ehci/usb1*sdc              auto           vfat    default    voldmanaged=UsbDriveC:auto
/devices/platform/s5p-ehci/usb1*sdd              auto           vfat    default    voldmanaged=UsbDriveD:auto
/devices/platform/s5p-ehci/usb1*sde              auto           vfat    default    voldmanaged=UsbDriveE:auto
/devices/platform/s5p-ehci/usb1*sdf              auto           vfat    default    voldmanaged=UsbDriveF:auto"

CM110="
/devices/platform/s3c-sdhci.2/mmc_host/mmc1      auto           auto    defaults    voldmanaged=sdcard1:auto
/devices/platform/s5p-ehci                       auto           auto    defaults    voldmanaged=usbdisk0:auto"

DATAPOINT="/data      "

/sbin/busybox echo -e "# Generated on $(/sbin/busybox date) by /sbin/fstab.sh script\n" > $FSTAB

if /sbin/busybox echo "$1" | /sbin/busybox grep -q "1"; then
  CACHEDEV=$HIDDENDEV
  DATAPOINT="/.secondrom"
else
  if /sbin/busybox blkid $SYSTEMDEV | /sbin/busybox grep -q "ext4"; then
    /sbin/busybox echo "$SYSTEMDEV    /system        ext4    ro,noatime,nodiratime    wait" >> $FSTAB
  else
    /sbin/busybox echo "$SYSTEMDEV    /system        f2fs    ro,noatime,nodiratime,$F2FSOPB" >> $FSTAB
  fi
fi

/sbin/busybox echo "$EFS" >> $FSTAB

if /sbin/busybox blkid $CACHEDEV | /sbin/busybox grep -q "ext4"; then
  /sbin/busybox echo "$CACHEDEV    /cache         ext4    nodiratime,$EXT4OPT" >> $FSTAB
else
  /sbin/busybox echo "$CACHEDEV    /cache         f2fs    nodiratime,$F2FSOPT" >> $FSTAB
fi

if /sbin/busybox blkid $DATADEV | /sbin/busybox grep -q "ext4"; then
  /sbin/busybox echo "$DATADEV    $DATAPOINT    ext4    $EXT4OPT,encryptable=footer" >> $FSTAB
else
  /sbin/busybox echo "$DATADEV    $DATAPOINT    f2fs    $F2FSOPT,encryptable=footer" >> $FSTAB
fi

# /sbin/busybox echo "$TOMBSTONES" >> $FSTAB; # Galaxy Tab 3 T315 LTE

if /sbin/busybox echo "$2" | /sbin/busybox grep -q -i "SAMMY44"; then
  /sbin/busybox echo -e "$SAMMY44" >> $FSTAB
fi

if /sbin/busybox echo "$2" | /sbin/busybox grep -q -i "CM110"; then
  # /sbin/busybox echo "$RADIO" >> $FSTAB; # Galaxy Tab 3 T315 LTE
  /sbin/busybox echo -e "$CM110" >> $FSTAB
fi

/sbin/busybox echo "" >> $FSTAB
