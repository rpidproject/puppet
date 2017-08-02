# Be a Vagrant box
class role::vagrant {
  include profile::common
  include profile::handle::build
  include profile::handle::server
  include profile::cordra::build
  include profile::cordra::server
}
