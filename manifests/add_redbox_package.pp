
define puppet_redbox::add_redbox_package (
  $packages        = $title,
  $owner           = undef,
  $has_ssl         = undef,
  $tf_env          = undef,
  $system_config   = undef,
  $base_server_url = undef,
  $proxy           = undef,
    $relocation_data_dir = '/mnt/data',
  $relocation_logs_dir = '/mnt/logs') {
  if ($packages[server_url_context]) {
    $server_url = "${base_server_url}/${packages[server_url_context]}"
  } else {
    $server_url = $base_server_url
  }
  $redbox_package = $packages[package]
  $redbox_system = $packages[system]

  puppet_common::add_directory { $packages[install_directory]:
    owner  => $owner,
    before => Package[$redbox_package]
  }

  puppet_redbox::pre_upgrade_backup { $packages[install_directory]:
    system_name => $redbox_system,
    require     => Puppet_common::Add_directory[$packages[install_directory]],
    before      => Package[$redbox_package]
  }

#  TODO : add test to ensure can install a version on fresh vm (no matter what latest in yum is),
  # or show logged error if already running a redbox instance
  if ($packages[pre_install]) {
    package { $packages[pre_install]:
      require => [
        Puppet_common::Add_directory[$packages[install_directory]],
        Puppet_redbox::Pre_upgrade_backup[$packages[install_directory]]],
      before  => [Package[$redbox_package]],
    }
  }

  if ($packages[post_install]) {
    if ($packages[institutional_build]) {
      $before_post_install_list = [
        Puppet_redbox::Institutional_build::Overlay[$packages[institutional_build]]
        ]
    }

    package { $packages[post_install]:
      require => Package[$redbox_package],
      before  => $before_post_install_list,
    }
  }

  $package_version = $packages[version] ? {
    undef   => installed,
    default => $packages[version],
  }

  package { $redbox_package: ensure => $package_version, }

  if ($redbox_system == 'redbox') {
    if ($packages[institutional_build]) {
      $before_list = [Puppet_redbox::Institutional_build::Overlay[$packages[institutional_build]]]
    }

    puppet_redbox::update_system_config { [
      "${packages[install_directory]}/home/config-include/2-misc-modules/rapidaaf.json",
      "${packages[install_directory]}/home/config-include/plugins/rapidaaf.json"]:
      system_config => $system_config,
      notify        => Exec["${redbox_system}-restart_on_refresh"],
      subscribe     => Package[$redbox_package],
      before        => $before_list,
    }

    if ($system_config and $system_config[api]) {
      file_line { 'update system-config.json api key':
        path      => "${packages[install_directory]}/home/config-include/2-misc-modules/apiSecurity.json",
        line      => "\"apiKey\": \"${system_config[api][clients][apiKey]}\",",
        match     => "\"apiKey\":.*$",
        subscribe => Package[$redbox_package],
        before    => $before_list,
      } ->
      file_line { 'update system-config.json api user':
        path      => "${packages[install_directory]}/home/config-include/2-misc-modules/apiSecurity.json",
        line      => "\"username\": \"${system_config[api][clients][username]}\"",
        match     => '\"username\":.*$',
        subscribe => Package[$redbox_package],
        before    => $before_list,
      }
    }
  }

  puppet_redbox::update_server_env { "${packages[install_directory]}/server/tf_env.sh":
    tf_env     => $tf_env,
    has_ssl    => $has_ssl,
    server_url => $server_url,
    notify     => Exec["${redbox_system}-restart_on_refresh"],
    subscribe  => Package[$redbox_package],
  }

  if ($packages[institutional_build]) {
    $require_list = [Package[$redbox_package], Puppet_redbox::Update_server_env["${packages[install_directory]}/server/tf_env.sh"]]

    # # institutional overlay should be last of package/config installs
    puppet_redbox::institutional_build::overlay { $packages[institutional_build]:
      system_install_directory => $packages[install_directory],
      notify                   => [Service[$redbox_system]],
      require                  => $require_list,
    }
  }

  service { $redbox_system:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    status     => "service ${redbox_system} status | grep 'is running'",
    subscribe  => Package[$redbox_package],
  }

  exec { "${redbox_system}-restart_on_refresh":
    command     => "service ${redbox_system} restart",
    tries       => 2,
    try_sleep   => 3,
    refreshonly => true,
    user        => 'root',
    logoutput   => true,
  }

  #  mint is not always proxied
  if ($redbox_system == 'mint' and $proxy and !empty(grep([join($proxy, ',')], 'http://localhost:9001/mint'))) {
    puppet_redbox::prime_system { 'localhost:9001/mint':
      subscribe => [Exec["${redbox_system}-restart_on_refresh"], Service[$redbox_system]],
    }
  } else {
    puppet_redbox::prime_system { $server_url:
      subscribe => [Exec["${redbox_system}-restart_on_refresh"], Service[$redbox_system]],
    }
  }

}
