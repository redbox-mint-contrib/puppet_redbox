define puppet_redbox::institutional_build::overlay (
  $git_clone_url            = $title,
  $institution_ssh_user     = 'root',
  $revision                 = 'master',
  $system_install_directory = undef,
  $local_repo_parent        = '/tmp',) {
  validate_absolute_path($local_repo_parent)

  if ($system_install_directory == undef) {
    fail('You must specify a system install directory to where the institutional build is to be copied.'
    )
  }
  $git_base_name = basename($git_clone_url)

  $local_repo = "${local_repo_parent}/${git_base_name}"
  $latest_or_present = $revision ? {
    'master' => latest,
    default  => present
  }

  vcsrepo { "clone ${git_clone_url} to ${local_repo}":
    ensure   => $latest_or_present,
    provider => git,
    source   => $git_clone_url,
    path     => $local_repo,
    revision => $revision,
    user     => $institution_ssh_user,
  }

  exec { "copy files from ${local_repo} to ${system_install_directory}":
    command => "/usr/bin/rsync -rcvzh --filter='- .git*' --filter='- README*' ${local_repo}/* ${system_install_directory}/",
    require => Vcsrepo["clone ${git_clone_url} to ${local_repo}"],
  }

}
