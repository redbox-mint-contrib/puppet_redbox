define puppet_redbox::prime_system ($system = $title,) {
  exec { "${system}-primer":
    command     => "wget --no-check-certificate --tries=2 --wait=5 --spider -O /dev/null ${system}",
    tries       => 2,
    try_sleep   => 3,
    refreshonly => true,
    user        => 'root',
    logoutput   => true,
  }

}
