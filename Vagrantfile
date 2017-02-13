# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

# Loads properties files and functions
require_relative 'rb/common_properties.rb'

# Setup VMs Network Adapters and IPs
@network_adapter_name = get_common_property("network_adapter_name")
@file_server_ip = get_common_property("file_server_ip")

Vagrant.configure("2") do |config|

	####################################################################################################
	# VM CPU and Memory settings (override)
	####################################################################################################
	config.vm.provider :virtualbox do |v, override|
		v.gui = false
		v.customize ["modifyvm", :id, "--memory", 1024]
		v.customize ["modifyvm", :id, "--cpus", 2]
		v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
	end
	
	
	####################################################################################################
	# FILE SERVER SETUP
	####################################################################################################
	config.vm.define "jenkins-server" do |centos7|
		centos7.vm.box = "inspired/centos7"
		centos7.vm.box_url = "http://172.28.23.224/binaries/vagrant/boxes/centos-7-x64-virtualbox-v2.box"
		
		centos7.vm.synced_folder ".", "/vagrant", disabled: false
		
		centos7.vm.network "private_network", ip: @file_server_ip, name: @network_adapter_name, netmask: "255.255.255.0"
		
		centos7.vm.provision "shell", path: "scripts/config-jenkins-server.sh"
	end

end

