define puppet-redbox::add_ssl_cert (
  $ssl_config = $title) {
  create_parent_directories($ssl_config[file])
  file { $ssl_config[file]: content => $ssl_config[content], }

}