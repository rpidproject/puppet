# Be the build node
class role::build {
  include profile::common

  notice(lookup('test_secret'))
}
