#!/bin/bash
# /usr/local/bin/scron.sh

if [[ -e /root/lockfile ]]; then
exit 1
else
touch /root/lockfile
/usr/local/bin/script.sh
echo "Message log file" | /sbin/ssmtp -v -s trashscum@list.ru -a < /root/message.log
rm /root/lockfile -f
fi
