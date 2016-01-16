define puppet_redbox::move_and_link_directory (
  $target        = $title,
  $target_parent = undef,
  $relocation    = undef,
  $owner         = undef,
  $exec_path     = hiera_array(exec_path, ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'])) {
  Exec {
    path      => $exec_path,
    logoutput => true,
  }

  if ($target_parent) {
    $relocation_target = "${relocation}/${target}"
    $source_target = "${target_parent}/${target}"
  } else {
    $relocation_target = $relocation
    $source_target = $target
  }
  include 'puppet_common'
  create_parent_directories($relocation_target)

  #  copy recursively
  exec { "cp -pRf ${source_target}/* ${relocation_target}/ && rm -Rf ${source_target} && ln -s ${relocation_target} ${source_target}"
  :
    unless => "test -h ${source_target}",
    onlyif => "test -d ${source_target} && test -d ${relocation_target}",
  }

  #  file { $relocation_target:
  #    ensure             => present,
  #    recurse            => true,
  #    source             => $source_target,
  #    validate_cmd       => "test -d ${source_target}",
  #    source_permissions => use_when_creating,
  #  }

  # link back in original
  #  file { $source_target:
  #    ensure       => link,
  #    force        => true,
  #    validate_cmd => "test -d ${source_target}",
  #    target       => $relocation_target,
  #    require      => File[$relocation_target],
  #  }
}