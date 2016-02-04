define puppet_redbox::institutional_build::git_overlay (
  $git_clone_url        = $title,
  $local_staging        = undef,
  $institution_ssh_user = 'root',
  $revision             = 'master',) {
  $latest_or_present = $revision ? {
    'master' => latest,
    default  => present
  }

  vcsrepo { "clone ${git_clone_url} to ${local_staging}":
    ensure   => $latest_or_present,
    provider => git,
    source   => $git_clone_url,
    path     => $local_staging,
    revision => $revision,
    user     => $institution_ssh_user,
  }

}
