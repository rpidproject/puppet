# Default firewall rules which come before all others
class profile::firewall_pre {
  Firewall {
    require => undef,
  }

  firewall { '000 Allow all local in':
    chain   => 'INPUT',
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }

  firewall { '000 Allow all local out':
    chain    => 'OUTPUT',
    proto    => 'all',
    outiface => 'lo',
    action   => 'accept',
  }

  firewall { '000 Allow RELATED,ESTABLISHED in':
    chain  => 'INPUT',
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }

  firewall { '000 Allow RELATED,ESTABLISHED out':
    chain  => 'OUTPUT',
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }

  firewall { '100 allow DNS out (UDP)':
    chain  => 'OUTPUT',
    state  => ['NEW'],
    dport  => '53',
    proto  => 'udp',
    action => 'accept',
  }

  firewall { '100 allow DNS out (TCP)':
    chain  => 'OUTPUT',
    state  => ['NEW'],
    dport  => '53',
    proto  => 'tcp',
    action => 'accept',
  }
}
