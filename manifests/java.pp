class puppet-redbox::java (
  $version = 'present',) {
  class { 'puppet-redbox::variables::java': } ->
  package { 'java':
    ensure => $version,
    name   => $variables::java::use_java_package_name,
  } ->
  class { 'puppet-redbox::post_config::java': }

}
