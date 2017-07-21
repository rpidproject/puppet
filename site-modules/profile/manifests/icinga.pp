# Be the Icinga server
class profile::icinga {
  include icinga::server

  # For AWS monitoring
  include profile::aws_sdk
  include profile::icinga_aws_creds
}
