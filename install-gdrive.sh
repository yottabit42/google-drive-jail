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
# Revision 171102a-yottabit
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

/usr/sbin/pkg update
/usr/sbin/pkg upgrade --yes || exit
/usr/sbin/pkg install --yes go || exit
/usr/sbin/pkg clean --yes || exit

# Add golang to the user profile path
if grep 'GOPATH=\$HOME/gopath' ~/.profile; then
  true
else
  echo "GOPATH=\$HOME/gopath" >> ~/.profile
fi
if grep 'export GOPATH' ~/.profile; then
  true
else
  echo "export GOPATH" >> ~/.profile
fi
if grep 'PATH=\$GOPATH:\$GOPATH/bin:\$PATH' ~/.profile; then
  true
else
  echo "PATH=\$GOPATH:\$GOPATH/bin:\$PATH" >> ~/.profile
fi
if grep 'export PATH' ~/.profile; then
  true
else
  echo "export PATH" >> ~/.profile
fi

# Source the update env vars
. ~/.profile

# Install the odeke-em/drive client
/usr/local/bin/go get -u "github.com/odeke-em/drive/cmd/drive" || exit

# Initialize Google Drive
drive init "$gdriveDir" || exit

# Add trigger to crontab
# Default run interval is daily at 1142 and 2342, localtime
if grep 'getPhotos.sh' /etc/crontab; then
  echo 'getPhotos.sh already in crontab'
else
  echo "42 11,23 * * * root \"$configDir/getPhotos.sh\" \
  >> \"$configDir/getPhotos.log\" 2>&1" >> /etc/crontab
fi

# Kickoff initial pull
"$configDir/getPhotos.sh"
