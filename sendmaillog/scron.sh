#!/bin/bash
# /root/sendmaillog/scron.sh

# Электронная почта для получения сообщений логов
postmaillog='kibmoney@yandex.ru'

# Файл блокировки повторного запуска
lockfile=$HOME/sendmaillog/lockfile

if [[ -e $lockfile ]]; then
exit 1
else
touch $lockfile
$HOME/sendmaillog/script.sh
echo "Message log file" | /usr/sbin/ssmtp -C /etc/ssmtp/ssmtp-ya.conf -v -s $postmaillog -a < $HOME/sendmaillog/message.log
rm $lockfile -f
fi
