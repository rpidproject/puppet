# Deploy the AWS SDK credentials
class profile::aws_credentials {
  if lookup('aws::test_mode') {
    notice('AWS orchestration is using the TEST credentials')
    $aws_access_key = hiera('aws_test_access_key')
    $aws_secret_key = hiera('aws_test_secret_key')
  } else {
    notice('AWS orchestration is using the LIVE credentials')
    $aws_access_key = hiera('aws_access_key')
    $aws_secret_key = hiera('aws_secret_key')
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
