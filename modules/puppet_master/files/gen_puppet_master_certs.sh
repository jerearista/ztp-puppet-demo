#!/usr/bin/env bash

#
# Generate puppet master server certificates
#
# Using expect is ugly but the mostreliable way to generate the certs/keys
# properly is to let the puppet tools do it.  On startup, if the 
# server cert/key does not exist, puppet will generate and sign them
# including the CA cert.   So, we fire off the puppet master and wait for 
# confirmation that everything is up & running, then kill it with CTRL+C.
#

# ls /var/lib/puppet/ssl/*/puppetmaster.pem
#/var/lib/puppet/ssl/certs/puppetmaster.pem
#/var/lib/puppet/ssl/private_keys/puppetmaster.pem
#/var/lib/puppet/ssl/public_keys/puppetmaster.pem

# sudo find /var/lib/puppet/ssl/ -name puppetmaster.pem 
#/var/lib/puppet/ssl/certs/puppetmaster.pem
#/var/lib/puppet/ssl/public_keys/puppetmaster.pem
#/var/lib/puppet/ssl/private_keys/puppetmaster.pem
#/var/lib/puppet/ssl/ca/signed/puppetmaster.pem

# Example:
# $ sudo puppet master --verbose --no-daemonize &
# Info: Creating a new SSL key for ca
# Info: Creating a new SSL certificate request for ca
# Info: Certificate Request fingerprint (SHA256): E5:28:34:D3:CD:55:93:8F:15:11:CB:6C:35:DB:F1:47:1E:DF:B4:F9:11:AD:DD:24:D0:B5:AF:EF:D2:0B:D4:B3
# Notice: Signed certificate request for ca
# Info: Creating a new certificate revocation list
# Info: Creating a new SSL key for puppetmaster
# Info: csr_attributes file loading from /etc/puppet/csr_attributes.yaml
# Info: Creating a new SSL certificate request for puppetmaster
# Info: Certificate Request fingerprint (SHA256): CD:97:5D:72:5B:9B:F5:CC:F8:46:F1:71:E3:03:BF:67:57:0D:81:10:DA:79:4C:F2:C0:EB:DA:1F:B8:39:D9:A9
# Notice: puppetmaster has a waiting certificate request
# Info: authstore: defaulting to no access for puppetmaster
# Notice: Signed certificate request for puppetmaster
# Notice: Removing file Puppet::SSL::CertificateRequest puppetmaster at '/var/lib/puppet/ssl/ca/requests/puppetmaster.pem'
# Notice: Removing file Puppet::SSL::CertificateRequest puppetmaster at '/var/lib/puppet/ssl/certificate_requests/puppetmaster.pem'
# Notice: Starting Puppet master version 3.4.3

expect <<- DONE
  set timeout 60

  spawn puppet master --verbose --no-daemonize
  match_max 100000

  # Look for passwod prompt
  expect "Notice: Starting Puppet master version*"
  sleep 2
  # Send CTRL+C to exit
  send -- \003
  expect eof
DONE
