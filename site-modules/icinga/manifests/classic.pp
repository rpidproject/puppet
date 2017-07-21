# Configure Apache for Icinga server
class icinga::classic {
  class { 'apache':
    default_vhost   => false,
    service_restart => '/bin/systemctl reload httpd',
    mpm_module      => 'prefork',
  }
  include apache::mod::php # for PNP4Nagios

  apache::namevirtualhost { '80': }
  apache::namevirtualhost { '443': }

  apache::vhost { 'monitor':
    port            => 80,
    docroot         => '/usr/local/icinga/share',
    redirect_status => 'permanent',
    redirect_dest   => 'https://monitor.thirtythreebuild.co.uk/',
  }

  apache::vhost { 'monitor-ssl':
    serveraliases     =>
      [
        'monitor.thirtythreebuild.co.uk',
        'monitor-staging.thirtythreebuild.co.uk',
      ],
    port              => 443,
    docroot           => '/usr/local/icinga/share',
    error_log_file    => 'icinga-error_log',
    access_log_file   => 'icinga-access_log',
    access_log_format => 'combined',
    ssl               => true,
    ssl_cert          => '/etc/ssl/certs/wildcard.thirtythreebuild.co.uk.crt',
    ssl_key           => '/etc/ssl/certs/wildcard.thirtythreebuild.co.uk.key',
    ssl_certs_dir     => '/etc/ssl/certs',
    aliases           => [
      {
        scriptalias => '/icinga/cgi-bin',
        path        => '/usr/local/icinga/sbin',
      },
      {
        alias => '/icinga',
        path  => '/usr/local/icinga/share',
      },
      {
        alias => '/pnp4nagios',
        path  => '/usr/local/pnp4nagios/share',
      },
      {
        aliasmatch => '/icinga-web/modules/([A-Za-z0-9]*)/resources/styles/([A-Za-z0-9]*\.css)$',
        path       => '/usr/local/icinga-web/app/modules/$1/pub/styles/$2',
      },
      {
        aliasmatch => '/icinga-web/modules/([A-Za-z0-9]*)/resources/images/([A-Za-z_\-0-9]*\.(png|gif|jpg))$',
        path       => '/usr/local/icinga-web/app/modules/$1/pub/images/$2',
      },
      {
        alias => '/icinga-web/js/ext3',
        path  => '/usr/local/icinga-web/lib/ext3',
      },
      {
        alias => '/icinga-web',
        path  => '/usr/local/icinga-web/pub',
      },
    ],
    directories       => [
      {
        path                => '/usr/local/icinga/sbin',
        allow_override      => ['None'],
        options             => ['ExecCGI'],
        auth_type           => 'Basic',
        auth_name           => 'Icinga Access',
        auth_basic_provider => 'file',
        auth_user_file      => '/usr/local/icinga/etc/htpasswd.users',
        auth_require        => 'user icinga',
      },
      {
        path                => '/usr/local/icinga/share',
        auth_type           => 'Basic',
        auth_name           => 'Icinga Access',
        auth_basic_provider => 'file',
        auth_user_file      => '/usr/local/icinga/etc/htpasswd.users',
        auth_require        => 'user icinga',
      },
      {
        path                => '/usr/local/pnp4nagios/share',
        allow_override      => ['None'],
        options             => ['FollowSymLinks'],
        auth_type           => 'Basic',
        auth_name           => 'Icinga Access',
        auth_basic_provider => 'file',
        auth_user_file      => '/usr/local/icinga/etc/htpasswd.users',
        auth_require        => 'user icinga',
        rewrites            => [
          {
            comment      => 'Set rewrite base',
            rewrite_base => '/pnp4nagios/',
          },
          {
            comment      => 'Prevent application and system files from being viewed',
            rewrite_rule => '^(application|modules|system) - [F,L]',
          },
          {
            comment      => 'Rewrite all other URLs to index.php/URL',
            rewrite_cond => [
              '%{REQUEST_FILENAME} !-f',
              '%{REQUEST_FILENAME} !-d',
            ],
            rewrite_rule => '.* index.php/$0 [PT,L]',
          },
        ],
      },
      {
        path     => '/usr/local/icinga-web/app/modules/\w+/pub/styles/',
        provider => 'directorymatch',
        allow    => 'from all',
      },
      {
        path     => '/usr/local/icinga-web/app/modules/\w+/pub/images/',
        provider => 'directorymatch',
        allow    => 'from all',
      },
      {
        path  => '/usr/local/icinga-web/lib/ext3',
        allow => 'from all',
      },
      {
        path           => '/usr/local/icinga-web/pub',
        allow          => 'from all',
        options        => ['FollowSymLinks'],
        allow_override => ['All'],
      },
    ],
  }
}
