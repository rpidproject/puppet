# Config files for Icinga
class icinga::config {
  notice("Icinga test mode: ${icinga_test_mode}")

  file { '/usr/local/icinga/etc':
    ensure  => directory,
    require => Exec['build-icinga-core'],
  }

  $icinga_config_files = ['icinga.cfg',
                          'contacts.cfg',
                          'cgi.cfg',
                          'hostgroups.cfg',
                          'hosts.cfg',
                          'resource.cfg',
                          'servicegroups.cfg',
                          'timeperiods.cfg',
                          'dependencies.cfg',
                          'webchecks.cfg' ]

  exec { 'icinga-config-check':
    command     => '/usr/local/icinga/bin/icinga -v /usr/local/icinga/etc/icinga.cfg && /sbin/service icinga restart',
    refreshonly => true,
  }

  $icinga_config_files.each | String $config_file | {
    file { "/usr/local/icinga/etc/${config_file}":
      source  => "puppet:///modules/icinga/${config_file}",
      require => File['/usr/local/icinga/etc'],
      notify  => Exec['icinga-config-check'],
    }
  }

  file { '/usr/local/icinga/etc/commands.cfg':
    content => epp('icinga/commands.cfg.epp',
      {
        icinga_test_mode => lookup('icinga::test_mode', Boolean),
      }),
    require => File['/usr/local/icinga/etc'],
    notify  => Exec['icinga-config-check'],
  }

  file { '/usr/local/icinga/etc/host_templates.cfg':
    content => epp('icinga/host_templates.cfg.epp',
      {
        icinga_contact => lookup('icinga::contact', String),
      }),
    require => File['/usr/local/icinga/etc'],
    notify  => Exec['icinga-config-check'],
  }

  file { '/usr/local/icinga/etc/service_templates.cfg':
    content => epp('icinga/service_templates.cfg.epp',
      {
        icinga_contact     => lookup('icinga::contact', String),
        icinga_key_contact => lookup('icinga::key_contact', String),
      }),
    require => File['/usr/local/icinga/etc'],
    notify  => Exec['icinga-config-check'],
  }

  file { '/usr/local/icinga/etc/services.cfg':
    content => epp('icinga/services.cfg.epp'),
    require => File['/usr/local/icinga/etc'],
    notify  => Exec['icinga-config-check'],
  }

  file { '/etc/ssl/certs/wildcard.thirtythreebuild.co.uk.crt':
    source => 'puppet:///modules/icinga/wildcard.thirtythreebuild.co.uk.crt',
    mode   => '0777',
  }

  file { '/etc/ssl/certs/wildcard.thirtythreebuild.co.uk.key':
    source => 'puppet:///modules/icinga/wildcard.thirtythreebuild.co.uk.key',
    mode   => '0777',
  }

}
