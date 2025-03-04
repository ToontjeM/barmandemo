# -*- mode: ruby -*-
# vi: set ft=ruby :

# VM
var_box            = "bento/almalinux-9.5"
var_box_version    = "202502.21.0"

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  # Box
  config.vm.box = var_box
  config.vm.box_version = var_box_version

  # Share files
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.synced_folder "./scripts", "/vagrant_scripts", type: "rsync"
  config.vm.synced_folder "./config", "/vagrant_config", type: "rsync"
  config.vm.synced_folder "#{ENV['HOME']}/tokens", "/tokens", type: "rsync"

  config.vm.define "pg1" do |pg1|
    pg1.vm.box = var_box
    pg1.vm.hostname = "pg1"
    pg1.vm.network "private_network", ip: "192.168.56.11"
    pg1.vm.provider "virtualbox" do |vmp|
      vmp.memory = 1024
      vmp.cpus = 1
      vmp.name = "pg1"
    end
    pg1.vm.provision "shell", path: "scripts/install_pg1.sh"
  end

  config.vm.define "pg2" do |pg2|
    pg2.vm.box = var_box
    pg2.vm.hostname = "pg2"
    pg2.vm.network "private_network", ip: "192.168.56.12"
    pg2.vm.provider "virtualbox" do |vmp|
      vmp.memory = 1024
      vmp.cpus = 1
      vmp.name = "pg2"
    end
    pg2.vm.provision "shell", path: "scripts/install_pg2.sh"
  end

  config.vm.define "backup" do |backup|
    backup.vm.box = var_box
    backup.vm.hostname = "backup"
    backup.vm.network "private_network", ip: "192.168.56.13"
    backup.vm.provider "virtualbox" do |vmp|
      vmp.memory = 1024
      vmp.cpus = 1
      vmp.name = "backup"
    end
    backup.vm.provision "shell", path: "scripts/install_backup.sh"
  end

  config.vm.provision :hosts, :sync_hosts => true
end
