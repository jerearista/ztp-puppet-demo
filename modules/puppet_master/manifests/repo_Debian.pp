class puppet_master::repo_Debian {
  exec { 'download PuppetLabs package':
    command => 'wget https://apt.puppetlabs.com/puppetlabs-release-precise.deb',
    unless  => 'grep puppetlabs /etc/apt/sources.list',
  } ->
  exec { 'Install PuppetLabs package':
    command => 'dpkg -i puppetlabs-release-trusty.deb',
  } ->
  exec { 'update packages':
    command => 'dpkg -i puppetlabs-release-trusty.deb',
  }

}
