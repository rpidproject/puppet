# Build the Cordra Docker image
class profile::cordra::build {
  include profile::docker::builder
  include cordra::build
}
