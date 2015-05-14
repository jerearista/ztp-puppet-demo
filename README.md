# ztp-puppet-demo
Demo vagrant testbed with a Linux server running dhcp, ejabberd, ZTP Server, and Puppet master plus 1 or more vEOS nodes.

This environment requires a linux basebox (gently modified from https://github.com/arista-eosplus/packer-ztpserver/) and a vEOS basebox (https://github.com/jerearista/vagrant-veos).
Optionally, the Puppet Enterprise agent may be downloaded from http://PuppetLabs.com/ and placed in modules/puppet_master/files/ztpserver/files/puppet/puppet-enterprise-3.7.2-eos-4-i386.swix if you desire for ZTP Server to install the pe agent on vEOS.   NOTE:  The Puppet Enterprise agent may be used with either Puppet Enterprise or OSS Puppet masters.
Puppet agent will, also, require modules/puppet_master/files/ztpserver/files/puppet/rbeapi-0.1.0.swix to use netdev-stdlib or puppet-eos Puppet modules.

Configure your desired environment in `vagrant.yaml`.  Then fire it up with ‘vagrant up’.

Each VM will be named based on the hostname_prefix and the node-number.  e.g. the first veos node (prefic: veos0) will be “veos01” and the puppet/ZTP Server will be “puppet1”.
You can connect to the VMs with ‘vagrant ssh <name>’.

For the vEOS node(s), setting “ztp: true” will cause the config to be erased and the node booted in to ZTP mode.   With the included configurations, that node should be configured by ZTP with a base config and puppet-enterprise agent installed (if the RPM is in the proper location... distributed separately by http://puppetlabs.com/).

Network connectivity and port forwarding (for test or development work with eAPI) may also be configured in the vagrant.yaml file.

## Vagrant

For Vagrant use, this requires a properly built basebox (virtualbox) and has been tested with Fedora 20, initially.

Simplified installation of VirtualBox Guest Additions: https://ask.fedoraproject.org/en/question/44503/fedora-20-virtualbox-guest-additions-install/
http://rpmfusion.org/Configuration/

    # For fedora 14 and higher:
    sudo su -c ‘yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm’
    sudo yum install VirtualBox-guest kmod-VirtualBox

### Deploying an environment

    vagrant box add Fedora-20-base
    git clone https://github.com/jerearista/ztp-puppet-demo.git
    cd ztp-puppet-demo
    # edit vagrant.yaml
        - nodes --> puppet_master --> box: & box_url:
    vagrant up puppet1

At this point, the base VM will be booted, then provisioned, via puppet, to create an Open Source Puppet master.

    mkdir -p files/puppet/environments
    git clone https://github.com/jerearista/puppet-demo-environment.git files/puppet/environments/demo
    git clone https://github.com/jerearista/puppet-eos_config-demo.git files/puppet/environments/demo/modules/eos_config/



