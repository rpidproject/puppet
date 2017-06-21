# Run the Handle Server container
class handle::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $handle_run_dir = "${docker_run_dir}/handle"

  file { $handle_run_dir:
    ensure => directory,
  }

  file { "${handle_run_dir}/config.dct":
    content => epp('handle/config.dct.epp', lookup('handle::config', Hash, 'hash')),
  }

  file { "${handle_run_dir}/contactdata.dct":
    content => epp('handle/contactdata.dct.epp',
      {
        'admin_email'    => lookup('handle::admin_email'),
        'admin_org_name' => lookup('handle::admin_org_name'),
      },
    ),
  }

  $handle_tag = lookup('handle::handle_tag')
  docker::run { 'rpid-handle':
    image   => "rpid-handle:${handle_tag}",
    volumes => ["${handle_run_dir}:/handle"],
  }
}
