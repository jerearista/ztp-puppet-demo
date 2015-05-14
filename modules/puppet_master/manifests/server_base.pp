class puppet_master::server_base {

  package { ['ntp']:
    ensure => present,
  }
  service { ['ntpd']:
    enable => true,
    ensure => running,
    require => Package['ntp'],
  }

  package { ['rbeapi']:
    ensure => latest,
    provider => gem,
  }

  # TODO: add user/group/sudoers for a generic admin

  host { 'localhost':
    ip           => '127.0.0.1',
    host_aliases => ["${::hostname}", "${::fqdn}",
                     'localhost.localdomain', 'localhost4', 'localhost4.localdomain4',
                     'puppet', 'ztps',
                     'ztps.example.com', 'puppet.example.com',
                     'ztps', 'ztps.ztps-test.com', 'puppet.ztps-test.com'],
  }

}
