# puppet_master/manifests/environments.pp
#
# Ensure Puppet is configured for directory-environments
#
class puppet_master::environments {

  #require puppet_master

  File {
    require => Package['puppet-server', 'hiera'],
  }

  $packages = [ "hiera",
              ]
  package { $packages: ensure => installed, }

  file { "/etc/puppet/environments":
    ensure => directory,
  }

  # Tell puppet to use directory environments
  augeas { "configure directory environments":
    context => "/files/etc/puppet/puppet.conf/main",
    changes => [
      'set environmentpath $confdir/environments',
    ],
    #onlyif => '/bin/grep environmentpath /etc/puppet/puppet.conf | /bin/grep -v "^\\s*environmentpath=\\$confdir/environments"',
    notify => Service['puppetmaster'],
  }

  file { "/etc/hiera.yaml":
    ensure => "link",
    force  => true,
    target => "/etc/puppet/hiera.yaml",
    require => Package['puppet-server', 'hiera'],
  }

}
