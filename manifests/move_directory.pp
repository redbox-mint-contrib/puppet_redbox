define puppet_redbox::move_directory (
  $relocation_target = $title,
  $source_target     = undef,
  $owner             = undef,
  $move_options      = '-fn',
  $exec_path         = ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],) {
  Exec {
    path      => $exec_path,
    logoutput => true,
  }
  include 'puppet_common'

  create_parent_directories($relocation_target)
}