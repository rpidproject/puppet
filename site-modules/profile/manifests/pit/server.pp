# Run the PIT API container
class profile::pit::server {
  include profile::docker::runner
  include pit::server
}
