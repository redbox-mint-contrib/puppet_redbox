define puppet_redbox::institutional_build::overlay (
  $source                   = $title,
  $system_install_directory = undef,
  $local_staging_parent     = '/tmp',
  $overlay_type             = 'puppet') {
  # # required for basename function - as not yet at latest stdlib library.
  include 'puppet_common'
  validate_absolute_path($local_staging_parent)

  if ($system_install_directory == undef) {
    fail('You must specify a system install directory to where the institutional build is to be copied.')
  }

  $source_base_name = basename($source)
  $local_staging = "${local_staging_parent}/${source_base_name}"

  case $overlay_type {
    'git'   : {
      puppet_redbox::institutional_build::git_overlay { $source:
        local_staging => $local_staging,
        before        => Exec["copy files from ${local_staging} to ${system_install_directory}"]
      }
    }

    default : {
      puppet_redbox::institutional_build::puppet_overlay { $source:
        local_staging => $local_staging,
        before        => Exec["copy files from ${local_staging} to ${system_install_directory}"]
      }
    }
  }

  exec { "copy files from ${local_staging} to ${system_install_directory}": command => "/usr/bin/rsync -rcvzh --filter='- .git*' --filter='- README*' ${local_staging}/* ${system_install_directory}/"
  }
}