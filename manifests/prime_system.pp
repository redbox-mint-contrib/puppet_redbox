define puppet-redbox::prime_system ($system = $title,) {
  exec { "$system-primer":
    command     => "wget --spider ${system}",
    tries       => 2,
    try_sleep   => 20,
    refreshonly => true,
    user        => 'root',
    logoutput   => true,
  }

}