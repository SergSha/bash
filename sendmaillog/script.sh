#!/bin/bash
# /root/sendmaillog/script.sh

logdir=$HOME/sendmaillog
meslog=$logdir/message.log

# Create temp file last.log
if [ ! -e $logdir/lastline ]
then
cat $HOME/access.log > /tmp/last.log
else
lastnum=$(grep -nxF -f $logdir/lastline $logdir/access.log | awk -F":" '{print $1}')
sed "1, $lastnum d" $logdir/access.log > /tmp/last.log
fi

# Обрабатываемый временной период
echo -e "\n" > $meslog
echo "Processed time period:" >>  $meslog
awk '{print $4}' /tmp/last.log | sort | sed -n '1p' | cut -c 2- | awk '{print "Start:\t" $1}' >> $meslog
awk '{print $4}' /tmp/last.log | sort | sed -n '$p' | cut -c 2- | awk '{print "End:\t" $1}' >> $meslog
echo -e "\n" >> $meslog

# Список IP адресов с наибольшим количеством запросов
echo "List of IP addresses with the most requests:" >> $meslog
grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" /tmp/last.log | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| IP address\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> $meslog
echo -e "\n" >> $meslog

# Список самых запрашиваемых URL
echo "TList of the most requested URLs:" >> $meslog
grep -o "http[^ ]*" /tmp/last.log | sed 's/\"/ /' | sed 's/)/ /' | awk '{print $1}' | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| URL\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> $meslog
echo -e "\n" >> $meslog

# Список всех кодов HTTP ответа
echo "List of all HTTP response codes:" >> $meslog
grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' /tmp/last.log | cut -d " " -f 2 | sort | uniq -c | sort -rn | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> $meslog
echo -e "\n" >> $meslog

# Все коды ошибок веб-сервера/приложения
echo "All error codes of the web server/application:" >> $meslog
grep -oE 'HTTP/1.1" [4|5][0-9][0-9]' /tmp/last.log | cut -d " " -f 2 | sort | uniq -c | sort -nr | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> $meslog
echo -e "\n" >> $meslog

# Update last log line in lastline
tail -n 1 /tmp/last.log > $logdir/lastline

# Delete temp file
rm -f /tmp/last.log

