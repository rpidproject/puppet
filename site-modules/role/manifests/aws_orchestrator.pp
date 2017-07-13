# Manage AWS resources
class role::aws_orchestrator {
  include profile::aws_sdk
  include profile::aws_credentials
  include profile::aws_resources
}
