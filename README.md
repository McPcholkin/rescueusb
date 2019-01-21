# WORK IN PROGRESSSSSS

# Universal Rescue USB drive

I searching for recovery USB drive for long time, but all find solutions not fully cover my needs, so i decide make my ideal universal USB drive by myself.

In this repo i share my configs for GRUB2 and GRUB4DOS + instructions how format and test USB drive.

## This USB drive can:
* Boot on BIOS and UEFI
* Diagnose HW problems
* Install Linux (debian, mint)
* Install Windows (XP, 7, 8.1, 10)
* Backup / Restore
* Pen-testing (Kali linux)
* Repair bootloader 
* Repair partition table
* Flash BIOS
* And more

------------------------------------------------------------------------------------------

## Items:
1. [Prepare](#prepare-)
  1. [Get closest debian mirror](#get-closest-debian-mirror)
  1. [Create chroot](#create-chroot-)
    1. [Prepare chroot](#prepare-chroot-)
  1. [Prepare USB drive](prepare-usb-drive-)
    1. [Clear partition table](#clear-partition-table-)
    1. [Create MBR partition table](#create-mbr-partition-table-)
    1. [Get USB drive size](#get-usb-drive-size-)
    1. [Create main partition](#create-main-partition-)
    1. [Create small partition for UEFI boot](#create-small-partition-for-uefi-boot-)
    1. [Make main partition bootable](#make-main-partition-bootable-)
    1. [Final result](#final-result-)
    1. [Format partitions](#format-partitions-)
    1. [Mount partitions](#mount-partitions-)
  1. [Install GRUB](#install-grub-)
    1. [Install GRUB2 fot BIOS boot](#install-grub2-fot-bios-boot-)
    1. [Add file from Ubuntu CD UEFI boot](#add-file-from-ubuntu-cd-uefi-boot-)
    1. [Download GRUB4DOS](#download-grub4dos)
    1. [Copy memdisk](#copy-memdisk-)
    1. [Download GRUB configs](#download-grub-configs-)
1. [Download tools and distros](#download-tools-and-distros-)
  1. [Make dirs for tools](#make-dirs-for-tools-)
  1. [Get defragfs tool to defrag ISO images for use in grub4dos](#get-defragfs-tool-to-defrag-iso-images-for-use-in-grub4dos-)
  1. [Download Debian installers and Live images](#download-debian-installers-and-live-images-)
  1. [Download Linux Mint](#download-linux-mint-)
  1. [Download Kali Linux](#download-kali-linux-)

----------------------------------------------------------------------------------------

## Prepare:
Installation be inside chroot, it safe and easy to clean after install.

### [*Get closest debian mirror*](https://www.debian.org/mirror/list)

### Create chroot:
```
sudo apt-get update
sudo apt-get install debootstrap
mkdir usb_install
sudo debootstrap stable usb_install http://debian.volia.net/debian/
sudo mount --bind /dev usb_install/dev
sudo mount --bind /proc usb_install/proc
sudo chroot usb_install
```

#### Prepare chroot:
```
apt-get update
apt-get install parted wget p7zip-full unzip ntfs-3g dosfstools grub-pc grub-efi-amd64-bin grub-efi-ia32-bin grub-imageboot grep aria2 ca-certificates gzip
```

#### Prepare USB drive:
*Insert USB drive, and check what name it take*
```
dmesg
```
```
[2949128.264602] usb-storage 3-4:1.0: USB Mass Storage device detected
[2949129.487527] sd 6:0:0:0: [sdb] 7909376 512-byte logical blocks: (4.05 GB/3.77 GiB)
[2949129.499389] sd 6:0:0:0: [sdb] Attached SCSI removable disk
```

Next steps be use **/dev/sdb** as USB drive

#### Clear partition table:
```
dd if=/dev/zero of=/dev/sdb bs=1M count=10
```

#### Create MBR partition table:
*Not all PC work with GPT*
```
parted /dev/sdb mktable msdos
```

Main problem in UEFI it can use only fat32 (some rare PC can see NTFS) so need 2 partitions, main and UEFI (3-5 MB) to boot GRUB on EFI mode.

#### Get USB drive size:
```
parted /dev/sdb unit MB p
```
```
Model: JetFlash Transcend 4GB (scsi)
Disk /dev/sdb: 4050MB
```

In my case start of second partition be **4045MB** *(4050 - 5 = 4045 MB)*

#### Create main partition:
```
parted /dev/sdb mkpart primary ntfs 0% 4045MB
```

#### Create small partition for UEFI boot:
```
parted /dev/sdb mkpart primary fat32 4045MB 100%
```

#### Make main partition bootable:
```
parted /dev/sdb set 1 boot on
```

#### Final result:
```
Model: JetFlash Transcend 4GB (scsi)
Disk /dev/sdb: 4050MB
Partition Table: msdos

Number  Start   End     Size    Type     File system  Flags
 1      1049kB  4045MB  4044MB  primary               boot
 2      4045MB  4050MB  4194kB  primary               lba

```

#### Format partitions:
```
mkfs.ntfs -L RESCUEUSB  /dev/sdb1
mkfs.msdos -n UEFI /dev/sdb2
```

#### Mount partitions:
```
mkdir /mnt/rescueusb
mount /dev/sdb1 /mnt/rescueusb
mkdir /mnt/uefi
mount /dev/sdb2 /mnt/uefi
```

------------------------------------------------------------------------------------

### Install GRUB:

#### Install GRUB2 fot BIOS boot:
```
grub-install --target=i386-pc --boot-directory="/mnt/rescueusb/boot" /dev/sdb
cp -r /usr/lib/grub/x86_64-efi /mnt/rescueusb/boot/grub
```

#### Add file from Ubuntu CD UEFI boot:
```
nano /mnt/rescueusb/boot/grub/x86_64-efi/grub.cfg
```
```
insmod part_acorn
insmod part_amiga
insmod part_apple
insmod part_bsd
insmod part_dfly
insmod part_dvh
insmod part_gpt
insmod part_msdos
insmod part_plan
insmod part_sun
insmod part_sunpc
source /boot/grub/grub.cfg
```

#### [Download GRUB4DOS](https://sourceforge.net/projects/grub4dos/) 
And copy it to chroot
```
unzip grub4dos-0.4.4.zip
cp grub4dos-0.4.4/grub.exe /mnt/rescueusb/boot/
```

#### Copy memdisk:
*Memdisk needed to boot floppy images*
```
cp /boot/memdisk /mnt/rescueusb/boot/
```

#### Download GRUB configs:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/chntpw.lst -O /mnt/rescueusb/boot/chntpw.lst
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/winpe.lst -O /mnt/rescueusb/boot/winpe.lst
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/grub/grub.cfg -O /mnt/rescueusb/boot/grub/grub.cfg
```

-----------------------------------------------------------------------------------------

## Download tools and distros:

### Make dirs for tools:
```
mkdir /mnt/rescueusb/boot/{acronis,debian,mint,winpe,rescuecd,kali}
```

### Get defragfs tool to defrag ISO images for use in grub4dos:
```
wget https://raw.githubusercontent.com/ThomasCX/defragfs/master/defragfs -O /mnt/rescueusb/boot/defragfs
```

### Download Debian installers and Live images:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/debian/update_debian.sh -O /mnt/rescueusb/boot/debian/update_debian.sh
bash /mnt/rescueusb/boot/debian/update_debian.sh
```

### Download Linux Mint:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/mint/update_mint.sh -O /mnt/rescueusb/boot/mint/update_mint.sh
bash /mnt/rescueusb/boot/mint/update_mint.sh
```

### Download Kali Linux:
```
wget https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part1_MAIN/boot/kali/update_kali.sh -O /mnt/rescueusb/boot/kali/update_kali.sh
bash /mnt/rescueusb/boot/kali/update_kali.sh
```

-------------------------------------------------------------------------------------------


Download usefull tools to put in `/mnt/rescueusb/boot/rescuecd/`

[Dos image to upgrade BIOS](https://www.allbootdisks.com/download/dos.html)   
[Chntpw also known as Offline NT Password & Registry Editor](https://www.techspot.com/downloads/6967-chntpw.html)   
[Clonezilla to backup linux PC](https://clonezilla.org/downloads/download.php?branch=stable)   
[HDD Regenerator](https://duckduckgo.com/?q=HDD+regenerator+img&t=h_&ia=web)   
[Hiren's BootCD 15.2 DOS](https://duckduckgo.com/)   
[Memtest 5.01](https://mirrors.slackware.com/slackware/slackware-14.2/kernels/memtest/memtest.mirrorlist)   
[MHDD DOS](http://www.mhdd.ru/files/mhdd32ver4.6floppy.exe)   
```
wget --no-check-certificate  http://www.mhdd.ru/files/mhdd32ver4.6floppy.exe
7z e mhdd32ver4.6floppy.exe
cp mhdd32ver4.6floppy /mnt/rescueusb/boot/rescuecd/mhdd32ver4.6_Boot-1.44M.img
```
[Norton Ghost 11 ima](https://duckduckgo.com/?q=nortonghost11.ima&t=h_&ia=web)   
[Rescatux](https://www.supergrubdisk.org/category/download/rescatuxdownloads/rescatux-beta/)   
[WHDD](https://www.richud.com/wiki/WHDD_Live_ISO_Boot_CD)   


--------------------------------------------------------------------------------------------

## UEFI Part

Copy grub2 config
```
mkdir -p /mnt/uefi/boot/grub/
wget --no-check-certificate https://raw.githubusercontent.com/McPcholkin/rescueusb/master/part2_UEFI/boot/grub/grub.cfg -O /mnt/uefi/boot/grub/grub.cfg
```

Create UEFI loader 
```
mkdir -p /mnt/uefi/EFI/BOOT/
GRUB_MODULES="fat iso9660 part_gpt part_msdos ntfs ext2 exfat btrfs hfsplus udf font gettext gzio normal boot linux linux16 configfile loopback chain efifwsetup efi_gop efi_uga ls help echo elf search search_label search_fs_uuid search_fs_file test all_video loadenv gfxterm gfxterm_background gfxterm_menu"
grub-mkimage -o /mnt/uefi/EFI/BOOT/bootx64.efi -p /boot/grub -O x86_64-efi $GRUB_MODULES
grub-mkimage -o /mnt/uefi/EFI/BOOT/bootia32.efi -p /boot/grub -O i386-efi $GRUB_MODULES 
```


NOT USED...
Some UEFI only systems (UEFI Bay Trail) locked to 32-bit efi loaders, to boot on this systems need patched bootia32.efi
```
cp /mnt/uefi/EFI/BOOT/BOOTIA32.EFI /mnt/uefi/EFI/BOOT/64_bit_only_____BOOTIA32.EFI
wget --no-check-certificate https://github.com/hirotakaster/baytail-bootia32.efi/blob/master/bootia32.efi?raw=true -O /mnt/uefi/EFI/BOOT/32_bit_only_____BOOTIA32.EFI 
cp /mnt/uefi/EFI/BOOT/32_bit_only_____BOOTIA32.EFI cp /mnt/uefi/EFI/BOOT/BOOTIA32.EFI
```


Umount done USB drive
```
umount /mnt/rescueusb/
umount /mnt/uefi/
```

Exit chroot
```
exit
sudo umount usb_install/dev
sudo umount usb_install/proc
```

-------------------------------------------------------------------------------------




## Testing:
To test USB drive easy i use QEMU

```
sudo apt-get install qemu-system-x86
mkdir testing_boot_usb
cd testing_boot_usb
```

Create dummy drive image:
```
qemu-img create -f qcow test1.qcow 1G
```

Options (more RAM and cores = faster boot):
* `-m 2048` - give 2GB RAM
* `-usb /dev/sdb` - attach usb drive
* `-hda test1.qcow` - attach dummy drive
* `-cpu kvm64` - emulated CPU
* `-smp cores=4` - set 4 cores to emulated CPU
* `-cdrom /some_iso.iso` - optional ISO images testing
* `-enable-kvm` - enable KVM full virtualization support (if host support virtualization it make boot way more faster)
* `-bios bios.bin` - use specific bios image

For UEFI testing need UEFI images:
Download (fresh build from EDK II Project)[https://www.kraxel.org/repos/jenkins/edk2/]
```
wget https://www.kraxel.org/repos/jenkins/edk2/edk2.git-ovmf-ia32-0-20190108.873.g1f7b748315.noarch.rpm
wget https://www.kraxel.org/repos/jenkins/edk2/edk2.git-ovmf-x64-0-20190108.873.g1f7b748315.noarch.rpm
sudo apt-get install cpio rpm2cpio
rpm2cpio edk2.git-ovmf-ia32-0-20190108.873.g1f7b748315.noarch.rpm | cpio -idmv
rpm2cpio edk2.git-ovmf-x64-0-20190108.873.g1f7b748315.noarch.rpm | cpio -idmv
cp ./usr/share/edk2.git/ovmf-ia32/OVMF-pure-efi.fd UEFI_32.fd
cp ./usr/share/edk2.git/ovmf-x64/OVMF-pure-efi.fd UEFI_64.fd
```

To test in BIOS mode:
X32
```
sudo qemu-system-i386 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm
```

X64
```
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm
```

To test in UEFI mode:
X32
```
sudo qemu-system-i386 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm -bios UEFI_32.fd
```

X64
```
sudo qemu-system-x86_64 -m 2048 -usb /dev/sdb -hdb test1.qcow -cpu kvm64 -smp cores=4 -enable-kvm -bios UEFI_64.fd
```

Also you can test any other CPU, to show available CPU list:
```
qemu-system-x86_64 -cpu help
```

