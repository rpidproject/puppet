# Build the Handle Server Docker image
class profile::handle::build {
  include profile::docker::builder
  include handle::build
}
