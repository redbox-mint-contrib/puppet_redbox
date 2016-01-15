define puppet_redbox::move_and_link_directory (
  $target        = $title,
  $target_parent = undef,
  $relocation    = undef,
  $owner         = undef,
  $system        = undef,) {
  $relocation_target = "${relocation}/${target}"
  $source_target = "${target_parent}/${target}"

  exec { "stop ${system} before $source_target to $relocation_target":
    command => "service ${system} stop",
    before  => Puppet_redbox::Move_directory[$relocation_target],
    require => Service[$system],
  }
  ensure_resource('file', $relocation, {
    'owner'   => $owner,
    'recurse' => true,
  }
  )
  puppet_redbox::move_directory { $relocation_target:
    source_target => $source_target,
    owner         => $owner,
    require       => [File[$relocation], Service[$system]],
  } ->
  file { $relocation_target:
    ensure             => present,
    recurse            => true,
    source             => $source_target,
    source_permissions => use_when_creating,
    require            => [Service[$system], Puppet_redbox::Move_directory[$relocation_target]],
  }

  file { $source_target:
    ensure  => link,
    force   => true,
    target  => $relocation_target,
    require => [Service[$system], Puppet_redbox::Move_directory[$relocation_target], File[$relocation_target]],
  }

  exec { "restart ${system} after $source_target to $relocation_target":
    command => "service ${system} restart",
    require => [
      Exec["stop ${system} before $source_target to $relocation_target"],
      Puppet_redbox::Move_directory[$relocation_target],
      File[$relocation_target],
      File[$source_target]],
  }

}