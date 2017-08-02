# Build the Collections Server Docker images
class profile::collections::build {
  include profile::docker::builder
  include collections::build
}
