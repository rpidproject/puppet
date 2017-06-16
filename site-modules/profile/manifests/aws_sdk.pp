# Install the AWS Ruby SDK
class profile::aws_sdk {
  # We need aws-sdk-core in the Puppet context,
  # for AWS orchestration to work
  ensure_packages(['aws-sdk-core', 'retries'],
  {
    provider => puppet_gem,
  })

  # We also need aws-sdk-core in the system context,
  # for the AWS resources check to work
  exec { 'install-aws-sdk-core':
    command => '/usr/bin/gem install aws-sdk-core',
    unless  => '/usr/bin/gem spec aws-sdk-core',
  }
}
