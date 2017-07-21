# Deploy the AWS SDK credentials
class profile::aws_credentials {
  if lookup('aws::test_mode') {
    notice('AWS orchestration is using the TEST credentials')
    $aws_access_key = lookup('aws::test_access_key', String)
    $aws_secret_key = lookup('aws::test_secret_key', String)
  } else {
    notice('AWS orchestration is using the LIVE credentials')
    $aws_access_key = lookup('aws::access_key', String)
    $aws_secret_key = lookup('aws::secret_key', String)
  }

  file { '/root/.aws':
    ensure => directory,
  }

  file { '/root/.aws/credentials':
    content => epp('site/aws_credentials.epp',
      { 'aws_access_key' => $aws_access_key,
        'aws_secret_key' => $aws_secret_key }),
    require => File['/root/.aws'],
  }
}
