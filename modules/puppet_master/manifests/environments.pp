# puppet_master/manifests/environments.pp
#
# Let Vagrant+puppet build the puppet master
#
class puppet_master::environments {

require puppet_master

$packages = [ "hiera",
            ]
package { $packages: ensure => installed, }

file { "/etc/puppet/environments":
  ensure => "link",
  force  => true,
  target => "/vagrant/files/puppet/environments",
  require => Package['puppet-server'],
}
# Tell puppet to use directory environments
augeas { "configure directory environments":
  require => Package['puppet-server'],
  context => "/files/etc/puppet/puppet.conf/main",
  changes => [
    'set environmentpath $confdir/environments',
  ],
  #onlyif => '/bin/grep environmentpath /etc/puppet/puppet.conf | /bin/grep -v "^\\s*environmentpath=\\$confdir/environments"',
}
file { "/etc/puppet/hiera.yaml":
  ensure => "link",
  force  => true,
  target => "/vagrant/files/puppet/hiera.yaml",
  require => Package['puppet-server', 'hiera'],
} ->
file { "/etc/hiera.yaml":
  ensure => "link",
  force  => true,
  target => "/etc/puppet/hiera.yaml",
  require => Package['puppet-server', 'hiera'],
}

}
