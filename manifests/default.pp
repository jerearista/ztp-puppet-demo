#
# Default.pp: Manifest used by Vagrant provision
#
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

include puppet_master
#include puppet_master::passenger
include puppet_master::environments

# Setup ztpserver dirs
file { '/usr/share/ztpserver':
  ensure => "link",
  target => "/vagrant/files/ztpserver",
  force  => true,
  backup => true,
}

