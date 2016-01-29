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
  file { $relocation_target:
    ensure => directory,
    owner  => $owner,
  } ->
  exec { "cp -pRf ${source_target}/* ${relocation_target}/": unless => "test -h ${source_target}", } ->
  exec { "rm -Rf ${source_target} && ln -sf ${relocation_target} ${source_target}": unless => "test -h ${source_target}", } -> file { $source_target:
    ensure => link,
    force  => true,
    target => $relocation_target,
    owner  => $owner,
  }

}