# Be the build node
class role::build {
  include profile::common
  include profile::handle::build
  include profile::cordra::build
}
