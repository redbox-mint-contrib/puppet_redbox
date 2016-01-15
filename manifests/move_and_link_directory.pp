define puppet_redbox::move_and_link_directory ($target = $title, $target_parent = undef, $relocation = undef, $owner = undef,) {
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
  file { $relocation_target:
    ensure             => present,
    recurse            => true,
    source             => $source_target,
    validate_cmd       => "test -d ${source_target}",
    source_permissions => use_when_creating,
  }

  # link back in original
  file { $source_target:
    ensure       => link,
    force        => true,
    validate_cmd => "test -d ${source_target}",
    target       => $relocation_target,
    require      => File[$relocation_target],
  }

}