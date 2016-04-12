define puppet_redbox::institutional_build::copy ($common_path = $title, $target_parent = '/opt', $source_parent = undef,) {
  if empty($source_parent) {
    fail('source parent required.')
  }

  exec { "/bin/cp -f ${source_parent}/${common_path} ${target_parent}/${common_path}": }

}
