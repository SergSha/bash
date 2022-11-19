<h3>### BASH ###</h3>

<p>Пишем скрипт</p>

<h4>Описание домашнего задания</h4>

<p>Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.<br />
Необходимая информация в письме:</p>
<ul>
<li>Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;</li>
<li>Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;</li>
<li>Ошибки веб-сервера/приложения c момента последнего запуска;</li>
<li>Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.</li>
<li>Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.</li>
В письме должен быть прописан обрабатываемый временной диапазон.</ul>



<h4>Создание стенда "Bash"</h4>

<p>Содержимое Vagrantfile:</p>

<pre>[user@localhost bash]$ <b>vi ./Vagrantfile</b></pre>

<pre># -*- mode: ruby -*-
# vi: set ft=ruby :

MACHINES = {
  :bash => {
    :box_name => "centos/7",
    :vm_name => "bash",
    :ip => '192.168.50.10',
    :mem => '512',
    :cpus => '1'
  }
}
Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      box.vm.network "private_network", ip: boxconfig[:ip]
      box.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", boxconfig[:mem]]
        vb.customize ["modifyvm", :id, "--cpus", boxconfig[:cpus]]
      end
      box.vm.provision "shell", inline: <<-SHELL
        mkdir -p ~root/.ssh
        cp ~vagrant/.ssh/auth* ~root/.ssh
      SHELL
    end
  end
end</pre>

<p>Запустим виртуальную машину:</p>

<pre>[user@localhost bash]$ <b>vagrant up</b></pre>

<pre>[user@localhost bash]$ <b>vagrant status</b>
Current machine states:

bash                      running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
[user@localhost bash]$</pre>

<pre>[user@localhost bash]$ <b>vagrant ssh bash</b>
[vagrant@bash ~]$ <b>sudo -i</b>
[root@bash ~]#</pre>

<p>Создадим директорий sendmaillog, где будем создавать скрипты по формированию и отправке почтовых сообщений логов:</p>

<pre>[root@bash ~]# <b>mkdir ./sendmaillog</b>
[root@bash ~]#</pre>

<p>Переходим в этот директорий:</p>

<pre>[root@bash ~]# <b>cd ./sendmaillog</b>
[root@bash sendmaillog]#</pre>

<p>Создадим скрипт создания почтового сообщения script.sh:</p>

<pre>[root@bash sendmaillog]# <b>vi ./script.sh</b>
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
rm -f /tmp/last.log</pre>

<p>Файл /root/sendmaillog/lastline хранит последнюю строку, чтобы при следующем запуске скрипт использовал эту строку для дальнейшего чтения лог файла access.log.<br />
Временный файл /tmp/last.log содержит те строки, которые появляются в лог файле access.log с момента последнего запуска скрипта.</p>

<p>Создадим скрипт запуска скрипта формирования сообщения и блокировки повторного запуска scron.sh:</p>

<pre>[root@bash sendmaillog]# <b>vi ./scron.sh</b>
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
fi</pre>

<p>Добавим права на исполнение скриптам:</p>

<pre>[root@bash sendmaillog]# <b>chmod +x ./script.sh</b></pre>

<pre>[root@bash sendmaillog]# <b>chmod +x ./scron.sh</b></pre>

<p>Установим репозиторий EPEL:</p>

<pre>[root@bash sendmaillog]# <b>yum install epel-release -y<b></pre>

<p>Установим почтовый сервис ssmtp:</p>

<pre>[root@bash sendmaillog]# <b>yum install ssmtp -y<b></pre>

<p>Добавим конфиг файл ssmtp-ya.conf (файл ssmtp.conf оставляем как есть):</p>

<pre>[root@bash sendmaillog]# <b>vi /etc/ssmtp/ssmtp-ya.conf<b></pre>

<pre># /etc/ssmtp/ssmtp-ya.conf
# /etc/ssmtp/ssmtp.conf
# От имени кого будут отправляться письма
root=kibmoney@yandex.ru
# Имя нашего сервера
hostname=bash
# Разрешаем пользователям менять поле From
FromLineOverride=YES
# Авторизация на Яндексе
AuthUser=kibmoney@yandex.ru
AuthPass=voqxuhespvsrkfyo
# Сервер яндекса
mailhub=stmp.yandex.ru:465
# С какого домена будут приходить письма
rewriteDomain=yandex.ru
# Разрешаем шифрование
UseTLS=YES
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt</pre>

<p>Вносим изменение в файл revaliases:</p>

<pre>[root@bash sendmaillog]# <b>vi /etc/ssmtp/revaliases<b></pre>

<p>В конец файла добавим строку:</p>

<pre>root:kibmoney@yandex.ru:smtp.yandex.ru:465</pre>

<p>Проверим отправку электронной почты:</p>

<pre>[root@bash sendmaillog]# <b>echo test | /usr/sbin/ssmtp -C /etc/ssmtp/ssmtp-yandex.conf -v -s kibmoney@yandex.ru</b>
[<-] 220 myt5-aad1beefab42.qloud-c.yandex.net (Want to use Yandex.Mail for your domain? Visit http://pdd.yandex.ru) 1668886366-CLnSSrAxmO-WkVSFUhc
[->] EHLO bash
[<-] 250 ENHANCEDSTATUSCODES
[->] AUTH LOGIN
[<-] 334 VXNlcm5hbWU6
[->] a2libW9uZXlAeWFuZGV4LnJ1
[<-] 334 UGFzc3dvcmQ6
[<-] 235 2.7.0 Authentication successful. 1668886366-CLnSSrAxmO-WkVSFUhc
[->] MAIL FROM:<kibmoney@yandex.ru>
[<-] 250 2.1.0 <kibmoney@yandex.ru> ok 1668886366-CLnSSrAxmO-WkVSJMK6
[->] RCPT TO:<kibmoney@yandex.ru>
[<-] 250 2.1.5 <kibmoney@yandex.ru> recipient ok 1668886366-CLnSSrAxmO-WkVSJMK6
[->] DATA
[<-] 354 Start mail input, end with <CRLF>.<CRLF>
[->] Received: by bash (sSMTP sendmail emulation); Sat, 19 Nov 2022 19:32:46 +0000
[->] From: "root" <kibmoney@yandex.ru>
[->] Date: Sat, 19 Nov 2022 19:32:46 +0000
[->] test
[->] 
[->] .
[<-] 250 2.0.0 Ok: queued on myt5-aad1beefab42.qloud-c.yandex.net 1668886366-CLnSSrAxmO-WkVSJMK6
[->] QUIT
[<-] 221 2.0.0 Closing connecton
[root@bash sendmaillog]#</pre>

<p>Как видим, отправка сообщение прошла успешно.</p>

<p>Теперь попробуем запустить сам скрипт отправки почтового сообщения:</p>

<pre>[root@bash sendmaillog]# <b>./scron.sh</b>
[<-] 220 sas1-78334f65778a.qloud-c.yandex.net (Want to use Yandex.Mail for your domain? Visit http://pdd.yandex.ru) 1668889033-rHPs3aHHs0-HDVeq5MW
[->] EHLO bash
[<-] 250 ENHANCEDSTATUSCODES
[->] AUTH LOGIN
[<-] 334 VXNlcm5hbWU6
[->] a2libW9uZXlAeWFuZGV4LnJ1
[<-] 334 UGFzc3dvcmQ6
[<-] 235 2.7.0 Authentication successful. 1668889034-rHPs3aHHs0-HDVeq5MW
[->] MAIL FROM:<kibmoney@yandex.ru>
[<-] 250 2.1.0 <kibmoney@yandex.ru> ok 1668889034-rHPs3aHHs0-HEVeViJt
[->] RCPT TO:<kibmoney@yandex.ru>
[<-] 250 2.1.5 <kibmoney@yandex.ru> recipient ok 1668889034-rHPs3aHHs0-HEVeViJt
[->] DATA
[<-] 354 Start mail input, end with <CRLF>.<CRLF>
[->] Received: by bash (sSMTP sendmail emulation); Sat, 19 Nov 2022 20:17:13 +0000
[->] From: "root" <kibmoney@yandex.ru>
[->] Date: Sat, 19 Nov 2022 20:17:13 +0000
[->] 
[->] 
[->] Processed time period:
[->] Start:	14/Aug/2019:04:12:10
[->] End:	15/Aug/2019:00:25:46
[->] 
[->] 
[->] List of IP addresses with the most requests:
[->] Count	| IP address
[->] ------	+ ------
[->] 45	| 93.158.167.130
[->] 39	| 109.236.252.130
[->] 37	| 212.57.117.19
[->] 33	| 188.43.241.106
[->] 31	| 87.250.233.68
[->] 24	| 62.75.198.172
[->] 22	| 148.251.223.21
[->] 20	| 185.6.8.9
[->] 17	| 217.118.66.161
[->] 16	| 95.165.18.146
[->] ------	+ ------
[->] 
[->] 
[->] TList of the most requested URLs:
[->] Count	| URL
[->] ------	+ ------
[->] 124	| http://yandex.com/bots
[->] 73	| https://dbadmins.ru/
[->] 24	| https://dbadmins.ru
[->] 21	| http://www.semrush.com/bot.html
[->] 20	| http://www.domaincrawler.com/dbadmins.ru
[->] 15	| https://dbadmins.ru/2016/10/26/%D0%B8%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5-%D1%81%D0%B5%D1%82%D0%B5%D0%B2%D1%8B%D1%85-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B5%D0%BA-%D0%B4%D0%BB%D1%8F-oracle-rac/
[->] 14	| https://dbadmins.ru/2016/10/17/%D0%9F%D1%80%D0%BE%D0%B4%D0%BE%D0%BB%D0%B6%D0%B0%D0%B5%D0%BC-%D1%8D%D0%BA%D1%81%D0%BF%D0%B5%D1%80%D0%B8%D0%BC%D0%B5%D0%BD%D1%82%D1%8B-%D1%81-lacp/
[->] 11	| http://www.bing.com/bingbot.htm
[->] 9	| http://www.google.com/bot.html
[->] 4	| https://dbadmins.ru/wp-content/themes/llorix-one-lite/css/font-awesome.min.css?ver=4.4.0
[->] ------	+ ------
[->] 
[->] 
[->] List of all HTTP response codes:
[->] Count	| Code
[->] ------	+ ------
[->] 497	| 200
[->] 95	| 301
[->] 48	| 404
[->] 7	| 400
[->] 3	| 500
[->] 2	| 499
[->] 1	| 405
[->] 1	| 403
[->] 1	| 304
[->] ------	+ ------
[->] 
[->] 
[->] All error codes of the web server/application:
[->] Count	| Code
[->] ------	+ ------
[->] 48	| 404
[->] 7	| 400
[->] 3	| 500
[->] 2	| 499
[->] 1	| 405
[->] 1	| 403
[->] ------	+ ------
[->] 
[->] 
[->] .
[<-] 250 2.0.0 Ok: queued on sas1-78334f65778a.qloud-c.yandex.net 1668889035-rHPs3aHHs0-HEVeViJt
[->] QUIT
[<-] 221 2.0.0 Closing connecton
[root@bash sendmaillog]#</pre>

<img src="./screens/Screenshot from 2022-11-19 23-18-10.png" alt="Log message" />

<p>Добавил запись в cron, запускающий скрипт отправки почтового сообщения каждый час:</p>

<pre>[root@bash sendmaillog]# echo '0 * * * * /root/sendmaillog/scron.sh' >> /var/spool/cron/root</pre>

<p>Дождавшись очередного часа (в данном случае в 0 часов 00 минут) на электронную почту мы получили следующее сообщение, которое сформировалось с помощью cron:</p>

<img src="./screens/Screenshot from 2022-11-20 00-00-49.png" alt="Log message" />

