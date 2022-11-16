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
#      if boxconfig[:vm_name] == "bash"
#        box.vm.provision "ansible" do |ansible|
#          ansible.playbook = "ansible/playbook.yml"
#          ansible.inventory_path = "ansible/hosts"
#          ansible.become = true
#          ansible.host_key_checking = "false"
#          ansible.limit = "all"
#          ansible.verbose = "vvv"
#        end
#      end
    end
  end
end</pre>

<p>Запустим виртуальную машину:</p>

<pre>[user@localhost bash]$ <b>vagrant up</b></pre>

<pre>[user@localhost bash]$ vagrant status
Current machine states:

bash                running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
[user@localhost bash]$</pre>

<pre>[user@localhost bash]$ <b>vagrant ssh bash</b>
[vagrant@bash ~]$ <b>sudo -i</b>
[root@bash ~]#</pre>

<p>Отключим selinux:</p>