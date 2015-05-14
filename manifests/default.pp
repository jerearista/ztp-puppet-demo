#
# Default.pp: Manifest used by Vagrant provision
#
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

node /^puppet\d+$/ {
  include puppet_master::server_base
  include puppet_master
  #include puppet_master::passenger
  include puppet_master::environments
  include puppet_master::demo

  # Setup ztpserver dirs
  file { '/usr/share/ztpserver':
    ensure => "link",
    target => "/vagrant/files/ztpserver",
    force  => true,
    backup => true,
  }
}

node default {
  notify { 'Hit default node classification.   Nothing to apply': }
}

