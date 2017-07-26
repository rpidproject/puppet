# Run the Collections Server containers
class profile::collections::server {
  include profile::docker::runner
  include collections::server
}
