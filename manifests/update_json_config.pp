define puppet_redbox::update_json_config (
  $jsons_config_path = $title,
  $json_config_keys  = undef,
  $root_path         = get_module_path('puppet_redbox')) {
  if ($json_config == undef) {
    fail("json config keys are required.")
  }
  ## refactor and resuse with new manifests/functions in puppet_common
  if ($system_config) {
    $load_path = "${root_path}/lib/augeas/lenses"

    ensure_packages('augeas')

    augeas { "${system_config_path}_rapid":
      load_path => $load_path,
      incl      => $system_config_path,
      lens      => 'Custom_json.lns',
      changes   => ["set dict/entry[. = 'rapidAafSso']/dict/entry[. = 'iss']/string \"${system_config[rapidAafSso][iss]}\""],
      require   => Package['augeas'],
    }
  }
}
