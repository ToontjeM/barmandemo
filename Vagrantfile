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
#  config.vm.synced_folder ".", "/vagrant", type: "rsync"
#  config.vm.synced_folder "./scripts", "/vagrant_scripts", type: "rsync"
#  config.vm.synced_folder "./config", "/vagrant_config", type: "rsync"
#  config.vm.synced_folder "#{ENV['HOME']}/tokens", "/tokens", type: "rsync"
  config.vm.synced_folder ".", "/vagrant"
  config.vm.synced_folder "./scripts", "/vagrant_scripts"
  config.vm.synced_folder "./config", "/vagrant_config"
  config.vm.synced_folder "#{ENV['HOME']}/tokens", "/tokens"

  config.vm.define "pghost" do |pghost|
    pghost.vm.box = var_box
    pghost.vm.hostname = "pghost"
    pghost.vm.network "private_network", ip: "192.168.56.11"
    pghost.vm.provider "virtualbox" do |vmp|
      vmp.memory = 1024
      vmp.cpus = 1
      vmp.name = "pghost"
    end
    pghost.vm.provision "shell", path: "scripts/install_pghost.sh"
  end

  config.vm.define "barmanhost" do |barmanhost|
    barmanhost.vm.box = var_box
    barmanhost.vm.hostname = "barmanhost"
    barmanhost.vm.network "private_network", ip: "192.168.56.13"
    barmanhost.vm.provider "virtualbox" do |vmp|
      vmp.memory = 1024
      vmp.cpus = 1
      vmp.name = "barmanhost"
    end
    barmanhost.vm.provision "shell", path: "scripts/install_barmanhost.sh"
  end

  config.vm.provision :hosts, :sync_hosts => true
end
