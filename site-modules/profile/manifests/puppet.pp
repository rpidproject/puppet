# Set up Puppet config and cron run
class profile::puppet {
  service { ['puppet', 'mcollective', 'pxp-agent']:
    ensure => stopped, # Puppet runs from cron
    enable => false,
  }

  cron { 'run-puppet':
    ensure  => present,
    command => '/usr/local/bin/run-puppet',
    minute  => '*/10',
    hour    => '*',
  }

  $scripts = [
    'papply',
    'plock',
    'punlock',
    'run-puppet',
  ]

  $scripts.each | $script | {
    file { "/usr/local/bin/${script}":
      source => "puppet:///modules/profile/puppet/${script}.sh",
      mode   => '0755',
    }
  }

  file { '/tmp/puppet.lastrun':
    content => strftime('%F %T'),
    backup  => false,
  }
}
