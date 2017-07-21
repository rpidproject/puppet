# Default firewall rules which come after all others
class profile::firewall_post {
  firewall { '998 log all unmatched inputs':
    chain      => 'INPUT',
    jump       => 'LOG',
    log_level  => '6',
    log_prefix => '[FIREWALL] DROP INPUT: ',
    before     => undef,
  }

  firewall { '998 log all unmatched outputs':
    chain      => 'OUTPUT',
    jump       => 'LOG',
    log_level  => '6',
    log_prefix => '[FIREWALL] DROP OUTPUT: ',
    before     => undef,
  }

  if lookup('firewall_drop', Boolean) {
    firewall { '999 drop all input':
      chain  => 'INPUT',
      proto  => 'all',
      action => 'drop',
      before => undef,
    }

    firewall { '999 drop all output':
      chain  => 'OUTPUT',
      proto  => 'all',
      action => 'drop',
      before => undef,
    }
  }
}
