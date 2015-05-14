class puppet_master::repo_RedHat {

  yumrepo { 'puppetlabs-deps':
    ensure   => 'present',
    baseurl  => 'http://yum.puppetlabs.com/fedora/f20/dependencies/$basearch',
    descr    => 'Puppet Labs Dependencies Fedora 20 - $basearch',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  }
  yumrepo { 'puppetlabs-deps-source':
    ensure   => 'present',
    baseurl  => 'http://yum.puppetlabs.com/fedora/f20/dependencies/SRPMS',
    descr    => 'Puppet Labs Source Dependencies Fedora 20 - $basearch - Source',
    enabled  => '0',
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  }
  yumrepo { 'puppetlabs-devel':
    ensure   => 'present',
    baseurl  => 'http://yum.puppetlabs.com/fedora/f20/devel/$basearch',
    descr    => 'Puppet Labs Devel Fedora 20 - $basearch',
    enabled  => '0',
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  }
  yumrepo { 'puppetlabs-devel-source':
    ensure   => 'present',
    baseurl  => 'http://yum.puppetlabs.com/fedora/f20/devel/SRPMS',
    descr    => 'Puppet Labs Devel Fedora 20 - $basearch - Source',
    enabled  => '0',
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  }
  yumrepo { 'puppetlabs-products':
    ensure   => 'present',
    baseurl  => 'http://yum.puppetlabs.com/fedora/f20/products/$basearch',
    descr    => 'Puppet Labs Products Fedora 20 - $basearch',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  }
  yumrepo { 'puppetlabs-products-source':
    ensure         => 'present',
    baseurl        => 'http://yum.puppetlabs.com/fedora/f20/products/SRPMS',
    descr          => 'Puppet Labs Products Fedora 20 - $basearch - Source',
    enabled        => '0',
    failovermethod => 'priority',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
  }


}
