define puppet_redbox::restart_system ($packages = $title,) {
  $redbox_system = $packages[system]
  $redbox_package = $packages[package]

  exec { "restart after overlay for ${redbox_system}":
    command => "service ${redbox_system} restart",
    require => Package[$redbox_package],
  }
}