# -*- mode: ruby -*-
# vi: set ft=ruby :

# VM
var_box            = "bento/almalinux-9.5"
var_box_version    = "202502.21.0"

# Credentials
file_token = "#{ENV['HOME']}/tokens/.edb_subscription_token"

if File.exist?(file_token)
  credentials = File.read(file_token)
  puts
  puts "Credential file exists"
else
  puts ""
  puts "***********************************************"
  puts "Error:"
  puts "~/.edb_subscription_token file doesn't exists."
  puts "Please, create file :"
  puts "echo '<your_token>' > ~/.edb_subscription_token"
  puts "***********************************************"
  puts ""
  exit(1) # Stop the program with an error code
end

if ENV['VM1_NAME'].nil? || ENV['VM1_NAME'].empty?
  puts ""
  puts "**************************************************"
  puts "Please, run this script from 00-provision.sh"
  puts "**************************************************"
  puts ""
  exit(1)
end

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
  config.vm.synced_folder "~/tokens", "/tokens", type: "rsync"

  config.vm.define ENV['VM1_NAME'] do |vm1|
    vm1.vm.box = var_box
    vm1.vm.hostname=ENV['VM1_NAME']
    vm1.vm.network "private_network", ip: ENV['VM1_PUBLIC_IP']
    vm1.vm.network "forwarded_port", guest: 22, host: ENV['VM1_SSH_PORT']
    vm1.vm.provider "virtualbox" do |vmp|
      vmp.memory = ENV['VM1_MEMORY']
      vmp.cpus = ENV['VM1_CPU']
      vmp.name = ENV['VM1_NAME']
    end
    vm1.vm.provision :hosts, :sync_hosts => true
    vm1.vm.provision "shell", path: "scripts/install_vm1.sh"
  end

  config.vm.define ENV['VM2_NAME'] do |vm2|
    vm2.vm.box = var_box
    vm2.vm.hostname=ENV['VM2_NAME']
    vm2.vm.network "private_network", ip: ENV['VM2_PUBLIC_IP']
    vm2.vm.network "forwarded_port", guest: 22, host: ENV['VM2_SSH_PORT']
    vm2.vm.provider "virtualbox" do |vmp|
      vmp.memory = ENV['VM2_MEMORY']
      vmp.cpus = ENV['VM2_CPU']
      vmp.name = ENV['VM2_NAME']
    end
    vm2.vm.provision :hosts, :sync_hosts => true
    vm2.vm.provision "shell", path: "scripts/install_vm2.sh"
  end

  config.vm.define ENV['VM3_NAME'] do |vm3|
    vm3.vm.box = var_box
    vm3.vm.hostname=ENV['VM3_NAME']
    vm3.vm.network "private_network", ip: ENV['VM3_PUBLIC_IP']
    vm3.vm.network "forwarded_port", guest: 22, host: ENV['VM3_SSH_PORT']
    vm3.vm.provider "virtualbox" do |vmp|
      vmp.memory = ENV['VM3_MEMORY']
      vmp.cpus = ENV['VM3_CPU']
      vmp.name = ENV['VM3_NAME']
    end
    vm3.vm.provision :hosts, :sync_hosts => true
    vm3.vm.provision "shell", path: "scripts/install_vm3.sh"
  end

end
