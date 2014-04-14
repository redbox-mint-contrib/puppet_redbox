define puppet-redbox::add_redbox_package (
  $packages                 = $title,
  $owner                    = undef,
  $install_parent_directory = undef,
  $has_ssl                  = undef,  
  $tf_env                   = undef,
  $system_config            = undef,) {
  $redbox_package = $packages[package]
  $redbox_system = $packages[system]
  $server_url = $packages[server_url]

  package { $redbox_package: }

  puppet-redbox::update_system_config { "${install_parent_directory}/${redbox_system}/home/system-config.json":
    system_config => $system_config,
    notify        => Exec['restart_on_refresh'],
    require       => Package[$redbox_package],
  }

  puppet-redbox::update_server_env { "${install_parent_directory}/${redbox_system}/server/tf_env.sh":
    tf_env     => $tf_env,
    has_ssl    => $has_ssl,
    server_url => $server_url,
    notify     => Exec['restart_on_refresh'],
    require    => Package[$redbox_package],
  }

  service { $redbox_system:
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    status     => "service ${redbox_system} status | grep 'is running'",
    subscribe  => Package[$redbox_package],
  }

  exec { 'restart_on_refresh':
    command     => "service ${redbox_system} restart",
    tries       => 2,
    try_sleep   => 3,
    refreshonly => true,
    user        => 'root',
    cwd         => $target_path,
    logoutput   => true,
  }

}