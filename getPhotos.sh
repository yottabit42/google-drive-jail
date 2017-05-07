#!/bin/sh
#
# This script is intended to pull Google Photos via cron with odeke-em/drive
# client. The user should already have Google Photos enabled in Google Drive,
# and adjust the paths as needed.
#
# Jacob McDonald
# Revision 170506a-yottabit

# Adjust your Google Drive location here
gdriveDir="/config/gdrive"

# Init the errorlevel variable
E=1

# Init the loop counter
L=0

echo
echo Started `date`

# Run drive pull operation in a loop
# -no-prompt will accept -fix-clashes operation non-interactively
# -fix-clashes will fix clashes and then exit, so loop until pull operation
#   finishes successfully
# -ignore-conflict allows override of destination files that are mismatched;
#   this shouldn't happen, but it has for some reason... incomplete pull op
#   or some such. Best to use filesystem snapshots to roll back, just in case

cd "$gdriveDir" || exit

while [ $E -ne 0 ]; do
  time /root/gopath/bin/drive pull -fix-clashes -no-prompt -ignore-conflict \
-verbose "Google Photos"
  E=$?
  L=$((L+1))
  echo Errorlevel: $E
  echo Passes complete: $L
done

echo Finished `date`