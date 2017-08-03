# Be the RPID node
class role::rpid {
  include profile::handle::build
  include profile::handle::server
  include profile::cordra::build
  include profile::cordra::server
  include profile::collections::build
  include profile::collections::server
}
