define puppet_redbox::update_server_env (
  $server_path               = $title,
  $tf_env                    = undef,
  $has_ssl                   = false,
  $server_url                = undef,
  $has_institutional_overlay = true) {
  if ($has_ssl) {
    $protocol = https
  } else {
    $protocol = http
  }

  if ($has_institutional_overlay) {
    #notify { "There is an institutional overlay present, so server url should only be updated there.": }
  } else {
    file_line { "update_server_url_${server_path}":
      path  => $server_path,
      line  => "export SERVER_URL=\"${protocol}://${server_url}/\"",
      match => "^export SERVER_URL=\".*\"$",
    }
  }

  if ($tf_env and $tf_env[server_environment]) {
    file_line { "update_server_env_${server_path}":
      path  => $server_path,
      line  => "export SERVER_ENVIRONMENT=\"${tf_env[server_environment]}\"",
      match => '^export SERVER_ENVIRONMENT=.*$',
    }
  }
}
