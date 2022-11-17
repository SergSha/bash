#!/bin/bash
# /media/script.sh
echo "#Обрабатываемый временной промежуток" > /media/log.log
cat /media/access.log | cut -d " " -f 4 | sort | sed -n '1 p; $ p;' | sed -e 's/^.//' >> /media/log.log
echo " " >> /media/log.log
echo "#Самое запрашиваемое доменное имя" >> /media/log.log
cat /media/access.log | grep GET | grep -oE https?://[a-z][.][a-z] | sort -rn |uniq -c |sort -rn | sed 's/^ *//' | sed -e '1! d' >> /media/log.log
echo " " >> /media/log.log
echo "#Самый запрашиваемый IP" >> /media/log.log
cat /media/access.log | grep GET | sort | cut -d " " -f 1 | uniq -c | sort -rn | sed 's/^ *//' | sed -e '1! d' >> /media/log.log
echo " " >> /media/log.log
echo "#Все коды возврата" >> /media/log.log >> /media/log.log
cat /media/access.log | grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' | cut -d " " -f 2 | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >> /media/log.log
echo " " >> /media/log.log
echo "#Коды возврата ошибок" >> /media/log.log
cat /media/access.log | grep -oE 'HTTP/1.1" [0-9][0-9][0-9]' | cut -d " " -f 2 | grep -E "(4[0-9][0-9]|5[0-9][0-9])" | sort -rn | uniq -c | sort -rn | sed 's/^ *//' >> /media/log.log

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