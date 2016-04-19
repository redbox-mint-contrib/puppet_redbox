define puppet_redbox::restart_system ($packages = $title,) {
  $redbox_system = $packages[system]

  exec { "restart after overlay for ${redbox_system}": command => "service ${redbox_system} restart" }
}