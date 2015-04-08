# puppet_master/manifests/passenger.pp
#
# Let Vagrant+puppet build the puppet master
#
class puppet_master::passenger {

# Do initial Puppet master setup first
require puppet_master

# Install the necessary packages
$packages = [ "httpd",
              "mod_ssl",
              "rubygem-rack",
              "mod_passenger",
            ]
package { $packages: ensure => installed, }

# Ensure SELinux is not in enforcing mode
exec { "disable_selinux":
  command => 'setenforce permissive',
  onlyif  => "[ `/sbin/getenforce` == 'Enforcing' ]",
}->
augeas { "set selinux permissive":
  context => "/files/etc/sysconfig/selinux",
  changes => [
    "set SELINUX permissive",
  ],
}


# Setup passenger dirs
$passenger_dirs = [ "/usr/share/puppet",
                    "/usr/share/puppet/rack",
                    "/usr/share/puppet/rack/puppetmasterd",
                    "/usr/share/puppet/rack/puppetmasterd/public",
                    "/usr/share/puppet/rack/puppetmasterd/tmp",
                  ]
file { $passenger_dirs:
  ensure => "directory",
  owner  => "puppet",
  group  => "puppet",
  require => Package['mod_passenger'],
}

# Copy passenger config
file { "/usr/share/puppet/rack/puppetmasterd/config.ru":
  #ensure => "link",
  #target => "/usr/share/puppet/ext/rack/config.ru",
  ensure => "file",
  source => "/usr/share/puppet/ext/rack/config.ru",
  owner  => "puppet",
  group  => "puppet",
  #source => "/vagrant/modules/puppet_master/files/",
  #force  => true,
  require => File['/usr/share/puppet/rack/puppetmasterd'],
}
exec { "chcon_puppet_dir":
  command => 'restorecon -Rv /usr/share/puppet',
  require => File['/usr/share/puppet/rack/puppetmasterd/config.ru'],
}
file { "/var/run/passenger":
  ensure => "directory",
  #owner  => "puppet",
  #group  => "puppet",
} ->
exec { "chcon_passenger_dir":
  command => 'restorecon -Rv /var/run/passenger',
}

service { "puppet":
  require => Package['puppet-server'],
  enable => false,
  ensure => stopped,
}

file { "/etc/httpd/conf.d/puppetmaster.conf":
  ensure => "file",
  #source => "puppet:///modules/puppet_master/puppetmaster.conf",
  #source => "/home/vagrant/modules/puppet_master/files/puppetmaster.conf",
  source => "/vagrant/modules/puppet_master/files/puppetmaster.conf",
  require => Package["httpd", "puppet-server"],
  #notify => Service["httpd"],
}
#augeas { "configure puppetmaster.conf":
#  require => File['/etc/httpd/conf.d/puppetmaster.conf'],
#  context => "/files/etc/puppet/puppet.conf/main",
#  changes => [
#    "set SSLCertificateFile /var/lib/puppet/ssl/certs/$::hostname.pem",
#    "set SSLCertificateKeyFile/var/lib/puppet/ssl/private_keys/$::hostname.pem",
#  ],
#}

service { "puppetmaster":
  enable => false,
  ensure => stopped,
  require => [ Package['puppet-server'],
               File['/etc/httpd/conf.d/puppetmaster.conf'],
             ],
} ->
service { "httpd":
  enable => true,
  ensure => running,
  subscribe => File['/etc/httpd/conf.d/puppetmaster.conf',
                    '/etc/puppet/puppet.conf'
                   ],
}
}
