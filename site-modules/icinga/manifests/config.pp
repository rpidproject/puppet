# Config files for Icinga
class icinga::config {

  $cordra_password = lookup('cordra::admin_password')

  file { '/usr/local/icinga/etc':
    ensure  => directory,
    require => Exec['build-icinga-core'],
  }

  $icinga_config_files = ['icinga.cfg',
                          'cgi.cfg',
                          'hostgroups.cfg',
                          'hosts.cfg',
                          'resource.cfg',
                          'servicegroups.cfg',
                          'timeperiods.cfg',
                          'dependencies.cfg']

  exec { 'icinga-config-check':
    command     => '/usr/local/icinga/bin/icinga -v /usr/local/icinga/etc/icinga.cfg && /usr/sbin/service icinga restart',
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
    content => epp('icinga/commands.cfg.epp'),
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

  file { '/usr/local/icinga/etc/contacts.cfg':
    content => epp('icinga/contacts.cfg.epp',
      {
        admin_email => lookup('site::admin_email')
      }
    ),
    require => File['/usr/local/icinga/etc'],
    notify  => Exec['icinga-config-check'],
  }


  file { '/usr/local/icinga/etc/webchecks.cfg':
    content => epp('icinga/webchecks.cfg.epp',
      { 
        rpid_host        => lookup('site::ip_address'),
        collections_port => lookup('collections::manifold::host_port'),
        handle_port      => lookup('handle::config.host_ports.http'),
        handle_auth      => 'dummy:dummy',
        cordra_port      => lookup('cordra::config.host_ports.http'),
        cordra_auth      => "admin:${cordra_password}",
        pit_port         => lookup('pit::host_port'),
        pit_application  => lookup('pit::application_name'),
      }
    ),
    require => File['/usr/local/icinga/etc'],
    notify  => Exec['icinga-config-check'],
  }
}
