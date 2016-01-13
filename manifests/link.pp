define puppet_redbox::link (
  $target        = $title,
  $target_parent = undef,
  $relocation    = undef,
  $owner         = undef,
  $exec_path     = ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],)
{
  Exec {
    path      => $exec_path,
    logoutput => true,
  }
  ensure_resource('file', $relocation, {
    'ensure' => 'directory'
  }
  )

  exec { "mv ${target}":
    command => "mv ${target_parent}/${target} ${relocation}/${target}",
    require => File[$relocation],
  }

  file { "${relocation}/${target}":
    owner   => $owner,
    ensure  => directory,
    recurse => true,
    require => Exec["mv ${target}"],
  }

  file { "${target_parent}/${target}":
    ensure  => link,
    target  => "${relocation}/${target}",
    require => Exec["mv ${target}"],
  }

}
