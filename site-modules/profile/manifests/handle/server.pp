# Run the Handle Server container
class profile::handle::server {
  include profile::docker::runner
  include handle::server
}
