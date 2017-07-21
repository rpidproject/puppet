# Manage AWS credentials for Icinga monitoring
class profile::icinga_aws_creds {
  file { '/home/icinga/.aws':
    ensure  => directory,
    owner   => 'icinga',
    group   => 'icinga',
    require => User['icinga'],
  }

  file { '/home/icinga/.aws/credentials':
    content => epp('profile/aws_credentials.epp',
      { 'aws_access_key' => lookup('aws::access_key', String),
        'aws_secret_key' => lookup('aws::secret_key', String) }),
    owner   => 'icinga',
    group   => 'icinga',
    require => File['/home/icinga/.aws'],
  }
}
