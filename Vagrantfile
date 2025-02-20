# -*- mode: ruby -*-
# vi: set ft=ruby :

var_box = "generic/ubuntu2204"

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end
  
  config.vm.provision :hosts, :sync_hosts => true
  config.vm.provision "shell", path: "bootstrap.sh"

  config.vm.define "pg" do |pg|
    pg.vm.box = var_box
    pg.vm.hostname= "pg"
    pg.vm.network "private_network", ip: "192.168.56.11"
    pg.vm.provider "virtualbox" do |vmp|
      vmp.memory = "1024"
      vmp.cpus = "1"
      vmp.name = "pg"
    end
    pg.vm.provision "shell", path: "bootstrap_pg.sh"
  end

  config.vm.define "backup" do |backup|
    backup.vm.box = var_box
    backup.vm.hostname = "backup"
    backup.vm.network "private_network", ip: "192.168.56.12"
    backup.vm.provider "virtualbox" do |vms2|
      vms2.memory = "1024"
      vms2.cpus = "1"
      vms2.name = "backup"
    end
    backup.vm.provision "shell", path: "bootstrap_backup.sh"
  end
end
