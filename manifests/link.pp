define puppet_redbox::link ($target = $title, $destination = undef, $owner = undef,) {
  if ($target == undef) {
    fail('Must specify target for conversion to link.')
  }

  if ($destination == undef) {
    fail('Must specify destination for relocation and link.')
  }

  exec { "mv ${target} ${destination}": }

  file { $target:
    ensure  => link,
    target  => $destination,
    require => Exec["mv ${target} ${destination}"],
    owner   => $owner,
  }

}
