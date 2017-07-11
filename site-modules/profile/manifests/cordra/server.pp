# Run the Cordra container
class profile::cordra::server {
  include profile::docker::runner
  include cordra::server
}
