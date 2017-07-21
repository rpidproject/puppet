# Manage AWS credentials for Icinga monitoring
class profile::icinga_aws_creds {
  file { '/home/icinga/.aws':
    ensure  => directory,
    owner   => 'icinga',
    group   => 'icinga',
    require => User['icinga'],
  }

  file { '/home/icinga/.aws/credentials':
    content => epp('site/aws_credentials.epp',
      { 'aws_access_key' => hiera('aws_access_key'),
        'aws_secret_key' => hiera('aws_secret_key') }),
    owner   => 'icinga',
    group   => 'icinga',
    require => File['/home/icinga/.aws'],
  }
}
