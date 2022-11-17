#!/bin/bash
# /media/cs.sh
if [[ -e /media/lockfile ]]; then
exit 1
else
touch /media/lockfile
/media/s.sh
echo "Log file" | /sbin/ssmtp -v -s trashscum@list.ru -a < /media/log.log
rm /media/lockfile -f
fi