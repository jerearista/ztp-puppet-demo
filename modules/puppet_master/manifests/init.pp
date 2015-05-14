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

  $packages = [ 'puppet-server',
                'puppet',
                'augeas',
                'expect',
              ]
  package { $packages: ensure => installed, }

  file { '/etc/puppet/puppet.conf':
    ensure  => file,
    require => Package['puppet-server'],
  }

  # Configure the puppet master's certificate
  $context = '/files/etc/puppet/puppet.conf/main'
  $hostaliases = "puppet,${::fqdn},${::hostname},puppet.example.com,ztps,ztps.example.com,ztps.ztp-test.com"
  augeas { "${context}/dns_alt_names":
    require => File['/etc/puppet/puppet.conf'],
    context => $context,
    changes => [
      #"set certname puppetmaster",
      "set dns_alt_names ${::hostaliases}",
    ],
    onlyif  => "get dns_alt_names != ${::hostaliases}",
    #onlyif  => "/var/lib/puppet/ssl/certs/${::fqdn}.pem",
  }

  # Configure autosign
  file { '/etc/puppet/autosign.conf':
    ensure  => file,
    source  => 'puppet:///modules/puppet_master/autosign.conf',
    #source => "/home/vagrant/modules/puppet_master/files/autosign.conf",
    #force  => true,
    #target => "/vagrant/modules/puppet_master/files/autosign.conf",
    require => Package['puppet-server'],
  }

  file { '/etc/puppet/manifests/site.pp':
    ensure  => file,
    source  => 'puppet:///modules/puppet_master/site.pp',
    require => Package['puppet-server'],
  }

  file { '/etc/puppet/manifests/nodes.pp':
    ensure  => file,
    source  => 'puppet:///modules/puppet_master/nodes.pp',
    require => Package['puppet-server'],
  }
  #exec { "chcon_puppet_dir2":
  #  command => 'restorecon -Rv /etc/puppet',
  #  require => File[ '/etc/puppet/manifests/nodes.pp' ],
  #  #require => File[
  #  #             '/etc/puppet/autosign.conf',
  #  #             '/etc/puppet/manifests/site.pp',
  #  #             '/etc/puppet/manifests/nodes.pp',
  #  #           ],
  #}

  exec { 'gen_puppet_ca_certs':
    #command => 'puppet master --verbose --no-daemonize',
    command => '/vagrant/modules/puppet_master/files/gen_puppet_master_certs.sh',
    require => [
      Package['puppet-server'],
      Package['expect'],
    ],
    #unless  => "ls /var/lib/puppet/ssl/*/puppetmaster.pem",
    #unless  => "ls /var/lib/puppet/ssl/*/${::fqdn}.pem",
    # Doing this because in some cases FQDN may be a differenc case from the filenames.
    # ...alt: get puppetlabs-stdlib and use downcase(${::fqdn})
    unless  => 'ls /var/lib/puppet/ssl/private_keys/*.pem',
  } ->
  service { 'puppetmaster':
    ensure    => running,
    enable    => true,
    require   => Package['puppet-server'],
    subscribe => File['/etc/puppet/puppet.conf'],
  }

}
