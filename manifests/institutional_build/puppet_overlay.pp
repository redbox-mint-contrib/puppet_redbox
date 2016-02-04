define puppet_redbox::institutional_build::puppet_overlay ($source_url = $title, $local_staging = undef) {
  file { $local_staging:
    source  => $source_url,
    recurse => true,
  }

}
