# Common firewall rules
class profile::firewall {
  firewall { '100 Allow ICMP in':
    chain  => 'INPUT',
    proto  => 'icmp',
    action => 'accept',
  }

  firewall { '100 Allow ICMP out':
    chain  => 'OUTPUT',
    proto  => 'icmp',
    action => 'accept',
  }

  firewall { '100 Allow TCP/UDP traffic out':
    chain  => 'OUTPUT',
    proto  => 'all',
    action => 'accept',
  }
}
