# /etc/puppet/manifests/nodes.pp

node 'common' {
        #include dns-client
        #include ntp-client
}

node default inherits common {
}

node 'ztps.ztps-test.com' inherits common {
}

node /^veos\d+/ inherits common {
  notify { 'Made it to /etc/puppet/manifests/nodes.pp - veos!': }
}

node /^ztps/ inherits common {
  notify { 'Made it to /etc/puppet/manifests/nodes.pp - ZTPServer!': }
}
