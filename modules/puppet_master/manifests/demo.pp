class puppet_master::demo (
  $environment = "production",
  $revision    = "develop",
){
  $environments = "/etc/puppet/environments"
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
    require => File["${environments}"],
    owner   => vagrant,
    group   => vagrant,
  }

  vcsrepo { "${my_env}":
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    ensure   => present,
    source   => 'https://github.com/jerearista/puppet-demo-environment.git',
    revision => master,
  } ->
  file { '/etc/puppet/hiera.yaml':
    # Puppet 2 does not have a global hiera_config setting like puppet 3...
    ensure => link,
    target => "${my_env}/hiera.yaml",
    force  => true,
  }

  vcsrepo { "${modules}/eos":
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    ensure   => present,
    source   => 'https://github.com/arista-eosplus/puppet-eos.git',
    revision => $revision,
  }

  vcsrepo { "${modules}/eos_config":
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    ensure   => present,
    source   => 'https://github.com/jerearista/puppet-eos_config-demo.git',
    revision => master,
    #revision => $revision,
  }

  vcsrepo { "${modules}/netdev_stdlib":
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    ensure   => present,
    source   => 'https://github.com/puppetlabs/netdev_stdlib.git',
    revision => master,
  }

  vcsrepo { "${modules}/netdev_stdlib_eos":
    provider => git,
    force    => true,  # clobber dest path if it previously existed
    ensure   => present,
    source   => 'https://github.com/arista-eosplus/puppet-netdev.git',
    revision => master,
  }
}
