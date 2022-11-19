#!/bin/bash
# /usr/local/bin/script.sh

if [ ! -e /root/lastline ]
then
cat /root/access.log > /root/last.log
else
lastnum=$(grep -nxF -f /root/lastline /root/access.log | awk -F":" '{print $1}')
sed "1, $lastnum d" /root/access.log > /root/last.log
fi

echo "Обрабатываемый временной промежуток:" >  /root/message.log
awk '{print $4}' /root/last.log | sort | sed -n '1p' | cut -c 2- | awk '{print "Start:\t" $1}' >> /root/message.log
awk '{print $4}' /root/last.log | sort | sed -n '$p' | cut -c 2- | awk '{print "End:\t" $1}' >> /root/message.log
echo -e "\n" >> /root/message.log

echo "10 IP адресов с наибольшим количеством запросов:" >> /root/message.log
grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" /root/last.log | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| IP address\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> /root/message.log
echo -e "\n" >> /root/message.log

echo "10 самых запрашиваемых URL:" >> /root/message.log
grep -o "http[^ ]*" /root/last.log | sed 's/\"/ /' | sed 's/)/ /' | awk '{print $1}' | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| URL\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> /root/message.log
echo -e "\n" >> /root/message.log

echo "Все коды возврата:" >> /root/message.log
grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' /root/last.log | cut -d " " -f 2 | sort | uniq -c | sort -rn | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> /root/message.log
echo -e "\n" >> /root/message.log

echo "Коды возврата ошибок:" >> /root/message.log
grep -oE 'HTTP/1.1" [4|5][0-9][0-9]' /root/last.log | cut -d " " -f 2 | sort | uniq -c | sort -nr | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> /root/message.log
echo -e "\n" >> /root/message.log

tail -n 1 /root/last.log > /root/lastline

rm -f /root/last.log

