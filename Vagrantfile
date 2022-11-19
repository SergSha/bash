# -*- mode: ruby -*-
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
#      box.vm.network "forwarded_port", guest: 8888, host: 80
      box.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", boxconfig[:mem]]
        vb.customize ["modifyvm", :id, "--cpus", boxconfig[:cpus]]
      end
      box.vm.provision "shell", inline: <<-SHELL
        mkdir -p ~root/.ssh
        cp ~vagrant/.ssh/auth* ~root/.ssh
        yum install epel-release -y && yum install ssmtp -y
        mv /vagrant/sendmaillog/ssmtp-ya.conf /etc/ssmtp/
        echo "root:kibmoney@yandex.ru:smtp.yandex.ru:465" >> /etc/ssmtp/revaliases
        mv /vagrant/{sendmaillog,access.log} $HOME/
        chmod +x $HOME/sendmaillog/{script,scron}.sh
        echo "0 * * * * $HOME/sendmaillog/scron.sh" >> /var/spool/cron/root
      SHELL
#      if boxconfig[:vm_name] == "bash"
#        box.vm.provision "ansible" do |ansible|
#          ansible.playbook = "ansible/playbook.yml"
#          ansible.inventory_path = "ansible/hosts"
#          ansible.become = true
#          ansible.host_key_checking = "false"
#          ansible.limit = "all"
##          ansible.verbose = "vvv"
#        end
#      end
    end
  end
end
