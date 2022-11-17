#!/bin/bash
# /media/script.sh

echo "Обрабатываемый временной промежуток:" >  ./message.log
#cat ./access.log | cut -d " " -f 4 | sort | sed -n '1 p; $ p;' | sed -e 's/^.//' >>  ./message.log
awk '{print $4}' ./access.log | sort | sed -n '1p;$p;' | cut -c 2- >> ./message.log
echo -e "\n" >> ./message.log

echo "10 с наибольшим количеством запросов IP адресов:" >> ./message.log
#cat ./access.log | grep GET | sort | cut -d " " -f 1 | uniq -c | sort -rn | sed 's/^ *//' | sed -e '1! d' >>  ./message.log
grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" ./access.log | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| IP address\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
echo -e "\n" >> ./message.log

echo "10 самых запрашиваемых URL:" >> ./message.log
#cat ./access.log | grep GET | grep -oE https?://[a-z][.][a-z] | sort -rn |uniq -c |sort -rn | sed 's/^ *//' | sed -e '1! d' >>  ./message.log
grep -o "http[^ ]*" ./access.log | sed 's/\"/ /' | sed 's/)/ /' | awk '{print $1}' | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| URL\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
echo -e "\n" >> ./message.log

echo "Коды возврата ошибок:" >> ./message.log
#cat ./access.log | grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' | cut -d " " -f 2 | grep -E "(4[0-9][0-9]|5[0-9][0-9])" | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >> ./message.log
cat ./access.log | grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' | cut -d " " -f 2 | grep -E "(4[0-9][0-9]|5[0-9][0-9])" | sort | uniq -c | sort -nr | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
echo -e "\n" >> ./message.log

echo "Все коды возврата:" >> ./message.log
#cat ./access.log | grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' | cut -d " " -f 2 | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >>  ./message.log
cat ./access.log | grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' | cut -d " " -f 2 | sort | uniq -c | sort -rn | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
echo -e "\n" >> ./message.log

# user@WN:~/otus_bash$ cat ./sort.txt
# winter
# spring
# summer
# spring
# autemn
# user@WN:~/otus_bash$ cat ./sort.txt | sort -rn | uniq -c | sort -rn | sed -e '1,3!d'
      # 2 spring
      # 1 winter
      # 1 summer
# user@WN:~/otus_bash$

# потом использовать grep по выбранному времени (часу) по всему log

#grep -o "http[^ ]*" ./access.log | sed 's/\"/ /' | awk '{print $1}' | sort | uniq -c | sort -nr | head



