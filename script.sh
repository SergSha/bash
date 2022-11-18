#!/bin/bash
# /usr/local/bin/script.sh

num=1
cat ./access.log | while read line
do
  [[ ! $line = $(cat ./lasttime) ]]
  num=$(( $num + 1 ))
done

last=$(sed '1, $num d' ./access.log)

# cat ./lasttime
# 182.254.243.249 - - [15/Aug/2019:00:24:38 +0300] "PROPFIND / HTTP/1.1" 405 173 "-" "-"rt=0.214 uct="-" uht="-" urt="-"

# grep -xF -f ./lasttime ./access.log

last=sed -n '$(cat ./lasttime),$/p' ./message.log
#sed -n '$last,$/p' ./message.log


echo "Обрабатываемый временной промежуток:" >  ./message.log
#cat ./access.log | cut -d " " -f 4 | sort | sed -n '1 p; $ p;' | sed -e 's/^.//' >>  ./message.log
echo $last | awk '{print $4}' | sort | sed -n '1p' | cut -c 2- | awk '{print "Start:\t" $1}' >> ./message.log
echo $last | awk '{print $4}' | sort | sed -n '$p' | cut -c 2- | awk '{print "End:\t" $1}' >> ./message.log
echo -e "\n" >> ./message.log

echo "10 IP адресов с наибольшим количеством запросов:" >> ./message.log
grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" ./access.log | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| IP address\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
echo -e "\n" >> ./message.log

echo "10 самых запрашиваемых URL:" >> ./message.log
grep -o "http[^ ]*" ./access.log | sed 's/\"/ /' | sed 's/)/ /' | awk '{print $1}' | sort | uniq -c | sort -nr | head | awk 'BEGIN{print "Count\t| URL\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
echo -e "\n" >> ./message.log

echo "Все коды возврата:" >> ./message.log
grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' ./access.log | cut -d " " -f 2 | sort | uniq -c | sort -rn | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
echo -e "\n" >> ./message.log

echo "Коды возврата ошибок:" >> ./message.log
grep -oE 'HTTP/1.1" [4|5][0-9][0-9]' ./access.log | cut -d " " -f 2 | sort | uniq -c | sort -nr | awk 'BEGIN{print "Count\t| Code\n------\t+ ------"} {print $1"\t| "$2} END{print "------\t+ ------"}' >> ./message.log
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



