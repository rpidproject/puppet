# Build the PIT API Docker image
class profile::pit::build {
  include profile::docker::builder
  include pit::build
}
