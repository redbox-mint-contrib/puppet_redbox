class puppet_redbox::archive::deploy_script (
  $script_name              = 'deploy.sh',
  $new_extension            = 'timestamp.new',
  $old_extension            = 'timestamp.old',
  $deploy_parent_directory  = undef,
  $install_parent_directory = undef,
  $owner                    = undef,
  $archives                 = undef,
  $server_url               = undef,
  $has_ssl                  = false,) {
  $working_directory = "/home/${owner}"
  $deploy_script_path = "${working_directory}/${script_name}"

  concat { $deploy_script_path:
    mode  => '0755',
    owner => $owner,
    group => $owner,
  }

  concat::fragment { 'deploy_main':
    target  => $deploy_script_path,
    content => template('puppet_redbox/deploy_main.sh.erb'),
    order   => '01',
  }

  $archive_values = values($archives)
  puppet_redbox::archive::deploy_archive { $archive_values: deploy_script_path => $deploy_script_path, } ->
  exec { $deploy_script_path:
    cwd       => $working_directory,
    user      => $owner,
    tries     => 3,
    try_sleep => 2,
    logoutput => true,
  }
}
