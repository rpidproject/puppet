# Install icinga-web
class icinga::web_install {
  $icinga_version = lookup('icinga::version', String)

  utils::remote_file { "/root/icinga-web-${icinga_version}.tar.gz":
    source  => "http://sourceforge.net/projects/icinga/files/icinga-web/${icinga_version}/icinga-web-${icinga_version}.tar.gz/download",
    require => Class['icinga::dependencies'],
  }

  exec { 'unpack-icinga-web':
    cwd       => '/root',
    command   => "/bin/tar xvf icinga-web-${icinga_version}.tar.gz",
    creates   => "/root/icinga-web-${icinga_version}",
    require   => Utils::Remote_file["/root/icinga-web-${icinga_version}.tar.gz"],
    logoutput => false,
  }

  exec { 'build-icinga-web':
    cwd     => "/root/icinga-web-${icinga_version}",
    command => "/root/icinga-web-${icinga_version}/configure && /usr/bin/make install",
    creates => '/usr/local/icinga-web',
    require => [Exec['unpack-icinga-web'], Package['php5-cli']],
  }
}
