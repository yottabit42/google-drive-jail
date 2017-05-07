#!/bin/sh
#
# This script installs golang, adds golang to the profile path, and then uses
# golang to download and install odeke-em/drive client for interacting with
# Google Drive. Assumption is made that the user has enabled the display of
# Google Photos in Google Drive. A subdirectory is created in the $configDir
# root, a subordinate script is added to cron, and the subordinate script is
# run once so we don't have to wait on cron.
#
# Also available in a convenient Google Doc:
# https://docs.google.com/document/d/1LSr3J6hdnCDQHfiH45K3HMvEqzbug7GeUeDa_6b_Hhc
#
# Jacob McDonald
# Revision 170506a-yottabit
#
# Licensed under BSD-3-Clause, the Modified BSD License

configDir=$(dialog --no-lines --stdout --inputbox "Persistent storage is:" \
0 0 "/config") || exit
gdriveDir=$(dialog --no-lines --stdout --inputbox "Google Drive storage is:" \
0 0 "$configDir/gdrive") || exit

if [ -d "$configDir" ] ; then
  echo "$configDir exists, like a boss!"
else
  echo "$configDir does not exist, so exiting (you might want to link a dataset)."
  exit
fi

if [ -d "$gdriveDir" ] ; then
  echo "$gdriveDir exists, like a boss!"
else
  echo "$gdriveDir does not exist, so exiting (you might want to link a dataset)."
  exit
fi

/usr/sbin/pkg update || exit
/usr/sbin/pkg upgrade --yes || exit
/usr/sbin/pkg install --yes go || exit
/usr/sbin/pkg clean --yes || exit

# Add golang to the user profile path
echo "GOPATH=\$HOME/gopath" >> ~/.profile
echo "export GOPATH" >> ~/.profile
echo "PATH=\$GOPATH:\$GOPATH/bin:\$PATH" >> ~/.profile
echo "export PATH" >> ~/.profile
. ~/.profile

# Install the odeke-em/drive client
/usr/local/bin/go get -u "github.com/odeke-em/drive/cmd/drive" || exit

# Initialize Google Drive
drive init "$gdriveDir" || exit

echo "42 11,23 * * * root \"$configDir/getPhotos.sh\" \
>> \"$configDir/getPhotos.log\" 2>&1" >> /etc/crontab

"$configDir/getPhotos.sh"
