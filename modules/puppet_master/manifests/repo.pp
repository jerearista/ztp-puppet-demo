class puppet_master::repo {

  case $::osfamily {
    'RedHat': { include puppet_master::repo_RedHat }
    'Debian': { include puppet_master::repo_RedHat }
    default:  { fail("Don't know how to install the PuppetLabs packages on ${::operatingsystem}") }
  }

}
