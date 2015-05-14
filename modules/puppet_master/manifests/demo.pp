class puppet_master::demo (
  $environment       = 'production',
  $environments_path = '/etc/puppet/environments',
  $puppet_demo_revision       = 'master',
  $eos_revision               = 'develop',
  $netdev_stdlib_revision     = 'master',
  $netdev_stdlib_eos_revision = 'develop',
  $eos_config_revision        = 'master',
){
  $environments = '/etc/puppet/environments'
  $my_env       = "${environments}/${environment}"
  $modules      = "${my_env}/modules"
  $manifests    = "${my_env}/manifests"
  $hieradata    = "${my_env}/hieradata"
  $hierayaml    = "${my_env}/hiera.yaml"

  # TODO: Set dir/file ownership

  File {
    require => Package['puppet-server'],
  }

  #file { "${environments}":
  #  ensure => directory,
  #}

  Vcsrepo {
    require => File[$environments],
    owner   => vagrant,
    group   => vagrant,
  }

  vcsrepo { $my_env:
    ensure   => present,
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    source   => 'https://github.com/jerearista/puppet-demo-environment.git',
    revision => $puppet_demo_revision,
  } ->
  file { '/etc/puppet/hiera.yaml':
    # Puppet 2 does not have a global hiera_config setting like puppet 3...
    ensure => link,
    target => "${my_env}/hiera.yaml",
    force  => true,
  }

  vcsrepo { "${modules}/eos":
    ensure   => present,
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    source   => 'https://github.com/arista-eosplus/puppet-eos.git',
    revision => $eos_revision,
  }

  vcsrepo { "${modules}/eos_config":
    ensure   => present,
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    source   => 'https://github.com/jerearista/puppet-eos_config-demo.git',
    revision => $eos_config_revision,
    #revision => $revision,
  }

  vcsrepo { "${modules}/netdev_stdlib":
    ensure   => present,
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    source   => 'https://github.com/puppetlabs/netdev_stdlib.git',
    revision => $netdev_stdlib_revision,
  }

  vcsrepo { "${modules}/netdev_stdlib_eos":
    ensure   => present,
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    source   => 'https://github.com/arista-eosplus/puppet-netdev.git',
    revision => $netdev_stdlib_eos_revision,
  }
}
