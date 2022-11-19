#!/bin/bash
# /root/sendmaillog/scron.sh

lockfile=$HOME/sendmaillog/lockfile

if [[ -e $lockfile ]]; then
exit 1
else
touch $lockfile
$HOME/sendmaillog/script.sh
echo "Message log file" | /usr/sbin/ssmtp -C /etc/ssmtp/ssmtp-ya.conf -v -s kibmoney@yandex.ru -a < $HOME/sendmaillog/message.log
rm $lockfile -f
fi
