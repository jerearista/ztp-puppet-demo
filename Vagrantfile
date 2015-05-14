# -*- mode: ruby -*-
# vi: set ft=ruby :

# The method of using a YAML config file for the actual VMs is heavily
# based on:
# https://github.com/miguno/wirbelsturm
# http://www.michael-noll.com/blog/2014/03/17/wirbelsturm-one-click-deploy-storm-kafka-clusters-with-vagrant-puppet/
#

Vagrant.require_version ">= 1.7.2"

require 'yaml'
require_relative 'lib/vagrant_config'
include Vagrant_config

vagrantfile_dir = File.expand_path(File.dirname(__FILE__))
config_file = ENV['VAGRANT_CONFIG_FILE'] || File.join(vagrantfile_dir, 'vagrant.yaml')
vagrant_config = YAML.load_file(config_file)
nodes = JSON.parse(compile_node_catalog(config_file), :symbolize_names => true)
config_version = IO.read(File.join(vagrantfile_dir, 'VERSION')).strip!

MANAGEMENT = "demo-mgmt"
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  #
  nodes.each_pair do |node_name,node_opts|
    config.vm.define node_name do |c|
      # Every Vagrant development environment requires a box. You can search for
      # boxes at https://atlas.hashicorp.com/search.
      c.vm.box = node_opts[:box]
      if node_opts[:box_url]
        c.vm.box_url = node_opts[:box_url]
      end
      #c.vm.network :private_network, ip: node_opts[:ip]
      #c.vm.network :private_network, type: "dhcp"
      if node_opts[:virtualbox][:shared_folders]
        #c.vm.synced_folder "./", "/vagrant", disabled: true
        c.vm.synced_folder "./", "/vagrant"
        #c.vm.synced_folder "./", "/vagrant", type: "nfs"
      else
        c.vm.synced_folder "./", "/vagrant", disabled: true
      end

      c.vm.provider "virtualbox" do |v|

        # set auto_update to false, if do NOT want to check the correct additions
        # version when booting this machine
        #v.vbguest.auto_update = false

        # Debugging
        if node_opts[:virtualbox][:gui]
          v.gui = true
        end

        # Set the visual name in VirtualBox
        #v.name = node_name

        if node_opts[:virtualbox][:username]
          memory = node_opts[:virtualbox][:memory]
          v.customize [
               "modifyvm", :id,
               "--memory", "#{memory}",
            ]
        end

        if node_opts[:virtualbox][:username]
          c.ssh.username = node_opts[:virtualbox][:username]
        end

        if node_opts[:virtualbox][:provision]
          #config.vm.provision "file", source: "", destination: ""
          #c.vm.provision "file", source: "manifests", destination: "/home/vagrant/manifests"
          #c.vm.provision "file", source: "manifests/default.pp", destination: "/home/vagrant/manifests/default.pp"
          c.vm.provision "puppet" do |puppet|
            #puppet.manifests_path = ["vm", "/home/vagrant/manifests"]
            #puppet.manifests_path = ["vm", "/home/vagrant/manifests"]
            ##puppet.manifests_path = "manifests"
            ##puppet.manifest_file = "default.pp"
            puppet.module_path = "modules"
            puppet.options = "--verbose"
            #puppet.options = "--verbose --debug"
          end
        end
        #c.provision "shell", inline: <<-SHELL
        #SHELL
        if node_name.to_s.include? "veos"
          # Only do these parts for veos nodes
          if node_opts[:virtualbox][:ztp]
            c.vm.provision "shell", inline: <<-SHELL
              FastCli -p 15 -c "write erase
             reload
              no
              "
            SHELL
          else
            c.vm.provision "file", source: "files/eapi.conf", destination: "/mnt/flash/eapi.conf"
            c.vm.provision "file", source: "files/dhclient.conf", destination: "/mnt/flash/dhclient.conf"
            c.vm.provision "file", source: "files/extensions/rbeapi-0.1.0.swix", destination: "/mnt/flash/rbeapi-0.1.0.swix"
            c.vm.provision "file", source: "files/extensions/puppet-enterprise-3.7.2-eos-4-i386.swix", destination: "/mnt/flash/puppet-enterprise-3.7.2-eos-4-i386.swix"
            c.vm.provision "shell", inline: <<-SHELL
              FastCli -p 15 -c "configure
              hostname #{node_name.to_s}
              ip domain-name example.com
              ip host ztps.example.com 172.16.130.11
              ip host puppet 172.16.130.11
              interface Ethernet1
                 no switchport
                 ip address #{node_opts[:ip]}/24
                 no shutdown
              alias pa bash sudo puppet agent
              alias puppet bash sudo puppet
              username admin privilege 15 role network-admin secret admin
              interface Management1
                 description Provisioned by Vagrant
              management api http-commands
              protocol unix-socket
              end
              copy running-config startup-config
              copy flash:puppet-enterprise-3.7.2-eos-4-i386.swix extension:
              copy flash:rbeapi-0.1.0.swix extension:
              delete flash:puppet-enterprise-3.7.2-eos-4-i386.swix
              delete flash:rbeapi-0.1.0.swix
              extension puppet-enterprise-3.7.2-eos-4-i386.swix
              extension rbeapi-0.1.0.swix
              copy installed-extensions boot-extensions"
            SHELL
            #c.vm.provision "shell", inline: <<-SHELL
            #  FastCli -p 15 -c "configure
            #  management api http-commands
            #     no protocol https
            #     protocol http
            #     no shutdown
            #  end
            #  copy running-config startup-config"
            #SHELL
          end
        else
          c.vm.hostname = node_name.to_s
          c.vm.network :private_network, ip: node_opts[:ip]
        end

        if node_opts[:virtualbox][:forwarded_ports]
          forward_ports = node_opts[:virtualbox][:forwarded_ports]
          forward_ports.each { |ports|
            guest_port = ports[:guest]
            host_port = ports[:host]
            c.vm.network :forwarded_port, guest: guest_port, host: host_port
          }
        end

        if node_opts[:virtualbox][:patches]
          patches = node_opts[:virtualbox][:patches]
          patches.each { |patch|
            nic = patch[:nic]
            network = patch[:network]
            v.customize [
               "modifyvm", :id,
               "--nic#{nic}", "intnet", "--intnet#{nic}", "#{network}",
            ]
          }
        end
      end

      # Disable automatic box update checking. If you disable this, then
      # boxes will only be checked for updates when the user runs
      # `vagrant box outdated`. This is not recommended.
      # c.vm.box_check_update = false

      # Enable provisioning with a shell script. Additional provisioners such as
      # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
      # documentation for more information about their specific syntax and use.
      # config.vm.provision "shell", inline: <<-SHELL
      #   sudo apt-get update
      #   sudo apt-get install -y apache2
      # SHELL
    end
  end
end
