define puppet-redbox::add_redbox_package (
  $packages         = $title,
  $owner            = undef,
  $install_parent_directory,
  $server_directory = 'server',
  $has_ssl          = undef,
  $server_url       = undef,) {
  $redbox_package = $packages[package]
  $redbox_system  = $packages[system]
  $target_path    = "${install_parent_directory}/${redbox_system}/${server_directory}"

  package { $redbox_package: } ->
  puppet-redbox::update_server_url { $redbox_system:
    has_ssl                  => $has_ssl,
    server_url               => $server_url,
    install_parent_directory => $install_parent_directory,
  } ->
  service { 'redbox':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    status     => 'service redbox status | grep "is running"',
    subscribe  => Package[$redbox_package],
  }

  exec { "restart_on_refresh":
    command     => "service ${redbox_system} restart",
    tries       => 2,
    try_sleep   => 3,
    refreshonly => true,
    subscribe   => Puppet-redbox::Update_server_url[$redbox_system],
    user        => 'root',
    cwd         => $target_path,
    logoutput   => true,
  }

}