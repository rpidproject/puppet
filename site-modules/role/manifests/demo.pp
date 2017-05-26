# Be the demo node
class role::demo {
  include profile::common

  notice(lookup('test_secret'))
}
