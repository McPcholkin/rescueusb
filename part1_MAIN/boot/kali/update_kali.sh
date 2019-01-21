#!/bin/bash

SCRIPT_PATH=$(dirname "$0")
CURRENT_KALI=$(ls $SCRIPT_PATH/ | grep "kali-linux")

NEW_KALI=$(wget -nv -q -O - http://www.kali.org/downloads | gunzip -c | grep "xfce" | sed 's/^.*\(kali-linux-xfce.*iso\).*$/\1/')

NEW_KALI_LINK=$(wget -nv -q -O - http://www.kali.org/downloads | gunzip -c | grep "xfce" | sed 's/^.*\(https.*iso.torrent\).*$/\1/')

NEW_KALI_VER=$(wget -nv -q -O - http://www.kali.org/downloads | gunzip -c | grep "xfce" | sed 's/^.*\(kali-linux-xfce.*iso\).*$/\1/' | cut -f4 -d-)

CUR_KALI_VER=$(ls $SCRIPT_PATH/ | grep "kali-linux" | cut -f4 -d-)

ARIA_VER=$(aria2c --version | head -n 1)
ARIA_PATH=$(whereis -b -f aria2c | cut -d ' ' -f 2)

# -------------------------------------------

echo ""
echo "Update Kali image"
echo ""
echo "Dist path - $SCRIPT_PATH"
echo "$ARIA_VER"
echo "Current Kali X32 - $CURRENT_KALI"
echo "New Kali X32     - $NEW_KALI"
echo ""


if [ "$CURRENT_KALI_32" == "$NEW_KALI" ] 
  then
    echo "You have latest Kali release"
    echo "Update not needed"
    exit 0
  else 
    echo "New Kali version available"
    echo "Current - $CUR_KALI_VER"
    echo "New     - $NEW_KALI_VER"
    echo ""
fi

read -n1 -r -p "Press Y to continue update or press any key to abort" key
echo ""

if [ "$key" = 'y' ] || [ "$key" = 'Y' ]
  then
    # Space pressed, do something
    # echo [$key] is empty when SPACE is pressed # uncomment to trace
    echo ""
    echo "Start update"
    echo ""
else
    # Anything else pressed, do whatever else.
    # echo [$key] not empty
    echo "Update aborted"
    exit 1
fi

#---------------------------------------------------

if [ ! -e $ARIA_PATH ]
  then 
    echo "Aria2 Not installed, install it?"
    read -n1 -r -p "Press Y to install Aria2  or press any key to abort" key

    if [ "$key" = 'y' ] || [ "$key" = 'Y' ]
      then
        sudo apt-get update
        sudo apt-get install aria2
      else
        echo "Aria2 not installed, abort Debian live update"
        exit 1
    fi
fi

#--------------------------------------------------------------

echo "Remove old images"
rm $SCRIPT_PATH/$CURRENT_KALI
echo "Done remove old images"
echo ""

echo "Download new images"
echo ""
wget $NEW_KALI_LINK -O $SCRIPT_PATH/$NEW_KALI".torrent"
echo ""

aria2c --seed-time=0 $SCRIPT_PATH/$NEW_KALI".torrent" -d $SCRIPT_PATH

KALI_ISO_PATH=$(aria2c --show-files $SCRIPT_PATH/$NEW_KALI".torrent" | grep -v "sha256sum" | grep "amd64.iso" | tail -n 1 | cut -f2-10 -d.)

KALI_DOWNLOAD_DIR=$(aria2c --show-files $SCRIPT_PATH/$NEW_KALI".torrent" | grep -v "sha256sum" | grep "amd64.iso" | tail -n 1 | cut -f2-10 -d. | cut -f2 -d\/)

rm $SCRIPT_PATH/$NEW_KALI".torrent"
mv $SCRIPT_PATH$KALI_ISO_PATH $SCRIPT_PATH/
rm -r $SCRIPT_PATH/$KALI_DOWNLOAD_DIR

echo ""

echo "Done download new images"
echo ""

echo "New images downloaded, update GRUB config!"

exit 0
