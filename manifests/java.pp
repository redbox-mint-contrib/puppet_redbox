class puppet_redbox::java (
  $version = 'present',) {
  class { 'puppet_redbox::variables::java': } ->
  package { 'java':
    ensure => $version,
    name   => $variables::java::use_java_package_name,
  } ->
  class { 'puppet_redbox::post_config::java': }

}
