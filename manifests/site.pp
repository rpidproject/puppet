# Manage puppetlabs-firewall global setup
resources { 'firewall':
    purge => false,
}

Firewall {
  before  => Class['profile::firewall_post'],
  require => Class['profile::firewall_pre'],
}

class { ['profile::firewall_pre', 'profile::firewall_post']: }
class { 'firewall': }

include(lookup('classes', { 'merge' =>  'unique' }))
