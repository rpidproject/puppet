# Build the PIT API Components
class pit::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $pit_build_dir = "${docker_build_dir}/pit"
  $handle_host = lookup('pit::handle_host')
  $handle_port = lookup('pit::handle_port')
  $handle_prefix = lookup('pit::handle_prefix')
  $cordra_host = lookup('pit::cordra_host')
  $cordra_port = lookup('pit::cordra_port')
  $cordra_prefix = lookup('pit::cordra_prefix')
  $admin_idx = lookup('handle::config.server.admin_idx')
  $site_handle = lookup('site::handle_prefix')
  $handle_admin_id = "${admin_idx}/${site_handle}"

  file { $pit_build_dir:
    ensure => directory,
  }

  vcsrepo { $pit_build_dir:
    ensure   => latest,
    revision => lookup('pit::revision'),
    provider => git,
    source   => lookup('pit::repos'),
    notify  => Exec['remove-pit-image'],
  } 

  file { "${pit_build_dir}/Dockerfile":
    content => epp('pit/Dockerfile.pit.epp',
      {
        'docker_base' => lookup('pit::docker_base'),
        'src_dir'     => lookup('pit::src_dir'),
      }
    ),
    notify  => Exec['remove-pit-image'],
  }

  file { "${pit_build_dir}/pitapi.properties":
    content => epp('pit/pitapi.properties.epp', {
      'handleBaseURI'  => "http://${handle_host}:${handle_port}",
      'handleAdminId'  => $handle_admin_id,
      'handlePrefix'   => $handle_prefix,
      'cordraURL'      => "http://${cordra_host}:${cordra_port}",
      'cordraPrefix'   => "${handle_prefix}.${cordra_prefix}-",

    }),
    require => Vcsrepo[$pit_build_dir],
    notify  => Exec['remove-pit-image'],
  } 

  exec { 'remove-pit-image':
      command     => "docker rmi -f rpid-pit",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['rpid-pit'],
  }
  

  docker::image { 'rpid-pit':
    ensure     => present,
    docker_dir => $pit_build_dir,
    notify     => Docker::Run['rpid-pit'],
  }

}
