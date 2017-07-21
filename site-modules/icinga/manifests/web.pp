# Manage icinga-web
class icinga::web {
  $icinga_version = lookup('icinga::version', String[1])
  $php = lookup('php::version', String[1])

  archive { 'icinga-web':
    path         => "/root/icinga-web-${icinga_version}.tar.gz",
    source       => "https://codeload.github.com/Icinga/icinga-web/tar.gz/v${icinga_version}",
    extract      => true,
    extract_path => '/root',
    cleanup      => true,
  }

  exec { 'build-icinga-web':
    cwd     => "/root/icinga-web-${icinga_version}",
    command => "/root/icinga-web-${icinga_version}/configure && /usr/bin/make install",
    creates => '/usr/local/icinga-web',
    require => [Archive['icinga-web'], Package["${php}-cli"]],
  }

  file { '/usr/local/icinga/etc/idomod.cfg':
    source  => 'puppet:///modules/icinga/idomod.cfg',
  }
}
