# Be the build node
class role::build {
  include profile::common
  include profile::docker
  include profile::build
}
