# Run the Cordra container
class cordra::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $cordra_run_dir = "${docker_run_dir}/cordra"
  $cordra_tag = lookup('cordra::cordra_tag', String)

  file { [
    $cordra_run_dir,
    "${cordra_run_dir}/data"
  ]:
    ensure => directory,
  }

  docker::run { 'rpid-cordra':
    ensure => present,
    image   => "rpid-cordra:${cordra_tag}",
    volumes => ["${cordra_run_dir}:/data"],
  }
}
