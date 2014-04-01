define puppet-redbox::add_ssl_cert (
  $ssl_config = $title) {
  file { $ssl_config[file]: content => $ssl_config[content], }

}
