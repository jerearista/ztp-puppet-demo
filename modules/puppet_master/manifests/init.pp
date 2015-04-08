# puppet_master/manifests/init.pp
#
# Let Vagrant+puppet build the puppet master
#
class puppet_master {

#exec { "disable_selinux":
#  command => 'setenforce permissive',
#} ->
#augeas { "set selinux permissive":
#  context => "/files/etc/sysconfig/selinux",
#  changes => [
#    "set SELINUX permissive",
#  ],
#}

$packages = [ "puppet-server",
              "puppet",
              "augeas",
              "expect",
            ]
package { $packages: ensure => installed, }

file { '/etc/puppet/puppet.conf':
    ensure => file,
    require => Package['puppet-server'],
}

# Configure the puppet master's certificate
augeas { "configure master cert":
  require => File['/etc/puppet/puppet.conf'],
  context => "/files/etc/puppet/puppet.conf/main",
  changes => [
    #"set certname puppetmaster",
    "set dns_alt_names puppet,puppetmaster,puppet.example.com,ztps,ztps.example.com,ztps.ztp-test.com"
  ],
}

#service { "puppet":
#  require => Package['puppet-server'],
#  enable => false,
#}

#file { "/etc/httpd/conf.d/puppetmaster.conf":
#  ensure => "file",
#  #source => "puppet:///modules/puppet_master/puppetmaster.conf",
#  #source => "/home/vagrant/modules/puppet_master/files/puppetmaster.conf",
#  source => "/vagrant/modules/puppet_master/files/puppetmaster.conf",
#  require => Package["httpd", "puppet-server"],
#  #notify => Service["httpd"],
#}
#augeas { "configure puppetmaster.conf":
#  require => File['/etc/httpd/conf.d/puppetmaster.conf'],
#  context => "/files/etc/puppet/puppet.conf/main",
#  changes => [
#    "set SSLCertificateFile /var/lib/puppet/ssl/certs/$::hostname.pem",
#    "set SSLCertificateKeyFile/var/lib/puppet/ssl/private_keys/$::hostname.pem",
#  ],
#}

# Configure autosign
file { "/etc/puppet/autosign.conf":
  ensure => "link",
  #source => "puppet:///modules/puppet_master/autosign.conf",
  #source => "/home/vagrant/modules/puppet_master/files/autosign.conf",
  force  => true,
  target => "/vagrant/modules/puppet_master/files/autosign.conf",
  require => Package['puppet-server'],
}

file { "/etc/puppet/manifests/site.pp":
  ensure => "link",
  force  => true,
  #source => "puppet:///modules/puppet_master/site.pp",
  #source => "/home/vagrant/modules/puppet_master/files/site.pp",
  target => "/vagrant/modules/puppet_master/files/site.pp",
  require => Package['puppet-server'],
}

file { "/etc/puppet/manifests/nodes.pp":
  ensure => "link",
  force  => true,
  #source => "puppet:///modules/puppet_master/manifests/nodes.pp",
  #source => "/home/vagrant/modules/puppet_master/files/nodes.pp",
  target => "/vagrant/modules/puppet_master/files/nodes.pp",
  require => Package['puppet-server'],
}
exec { "chcon_puppet_dir2":
  command => 'restorecon -Rv /etc/puppet',
  require => File[ '/etc/puppet/manifests/nodes.pp' ],
  #require => File[
  #             '/etc/puppet/autosign.conf',
  #             '/etc/puppet/manifests/site.pp',
  #             '/etc/puppet/manifests/nodes.pp',
  #           ],
}


exec { "gen_puppet_ca_certs":
  #command => 'puppet master --verbose --no-daemonize',
  command => '/vagrant/modules/puppet_master/files/gen_puppet_master_certs.sh',
  require => [ Package['puppet-server'],
               Package['expect'],
             ],
  #unless  => "ls /var/lib/puppet/ssl/*/puppetmaster.pem",
  unless  => "ls /var/lib/puppet/ssl/*/$::hostname.pem",
} ->
service { "puppetmaster":
  ensure => running,
  enable => true,
  require => Package['puppet-server'],
  subscribe => File['/etc/puppet/puppet.conf'],
}
}
