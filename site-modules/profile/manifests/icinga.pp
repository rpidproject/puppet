# Be the Icinga server
class profile::icinga {
  include icinga::server

  # For AWS monitoring
  include profile::aws_sdk
  include profile::icinga_aws_creds

  class { '::mysql::server':
    root_password           => lookup('mysql_password', String),
    remove_default_accounts => true,
  }

  file { '/usr/local/icinga/etc/htpasswd.users':
    source  => 'puppet:///modules/profile/icinga/htpasswd.icinga',
    require => Exec['build-icinga-core'],
  }

  file { '/etc/apache2/sites-enabled/icinga.conf':
    source  => 'puppet:///modules/profile/icinga/icinga.conf.apache',
    notify  => Service['apache2'],
    require => Package['apache2'],
  }

  $icinga_config_files = ['icinga.cfg',
                          'cgi.cfg',
                          'hostgroups.cfg',
                          'hosts.cfg',
                          'host_templates.cfg',
                          'resource.cfg',
                          'servicegroups.cfg',
                          'service_templates.cfg',
                          'timeperiods.cfg',
                          'contacts.cfg',
                          'dependencies.cfg',
                          'webchecks.cfg' ]

  $icinga_config_files.each | $config_file | {
    file { "/usr/local/icinga/etc/${config_file}":
      source  => "puppet:///modules/profile/icinga/${config_file}",
      require => Exec['build-icinga-core'],
      notify  => Exec['icinga-config-check'],
    }
  }

  file { '/usr/local/icinga/etc/commands.cfg':
    content => epp('site/icinga/commands.cfg.epp'),
    require => Exec['build-icinga-core'],
    notify  => Exec['icinga-config-check'],
  }

  file { '/usr/local/icinga/etc/services.cfg':
    content => epp('site/icinga/services.cfg.epp'),
    require => Exec['build-icinga-core'],
    notify  => Exec['icinga-config-check'],
  }
}
