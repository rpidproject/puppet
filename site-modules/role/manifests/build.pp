# Be the build node
class role::build {
  include profile::handle::build
  include profile::cordra::build
  include profile::collections::build
}
