define puppet-redbox::add_ssl_cert ($ssl_config = $title) {
  create_parent_directories($ssl_config[file])

  if ($ssl_config[content]) {
    file { $ssl_config[file]:
      content => $ssl_config[content],
      ensure  => file,
    }
  } else {
    file { $ssl_config[file]: ensure => file, }
  }
}