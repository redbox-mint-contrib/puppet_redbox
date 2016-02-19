# This manifest is intended only to copy existing system config files before an upgrade.
# In the event of upgrade errors, relevant config files can be diffed against the upgraded files or
# manually replaced. While overwriting occurs, be aware that no purging or pre-deletion occurs in
# the backup directory (as this is only a simple backup process, guards against e.g., incorrect
# backup folder selection).
# This manifest is NOT intended to be used as a whole system backup/restore function - this is
# handled by a different module.
define puppet_redbox::pre_upgrade_backup (
  $backup_source       = $title,
  $backup_destination_parent_path = '/tmp',
  $system_name         = undef,
  $exclude_directories = ['storage', 'solr', 'logs'],
  $exec_path           = [
    '/usr/local/bin',
    '/opt/local/bin',
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin'],) {
  Exec {
    path      => $exec_path,
    logoutput => true,
  }

  if ($::environment == 'production') {
    if ($system_name == undef) {
      fail("Must define a system name before backup for ${backup_source}.")
    }
    validate_absolute_path($backup_source)

    $backup_destination = "${backup_destination_parent_path}/backup_${system_name}"
    validate_absolute_path($backup_destination)

    case $::operatingsystem {
      'CentOS', 'RedHat', 'Fedora' : {
        case $::operatingsystemmajrelease {
          '7'     : {
            $service_stop_command = "systemctl stop ${system_name}"
            $service_restart_command = "systemctl restart ${system_name}"
          }
          default : {
            $service_stop_command = "service ${system_name} stop"
            $service_restart_command = "service ${system_name} restart"
          }

        }
      }
    }

    exec { "turn on ${system_name}": command => "chkconfig ${system_name} on" } ->
    exec { "stop ${system_name} before backup": command => "${service_stop_command} || echo 'service not running'", }

    file { $backup_destination: ensure => directory, }

    $exclusions = join(suffix(prefix($exclude_directories, "--filter='- "), "'"), ' ')

    exec { "backup sources: ${$backup_source} to: ${backup_destination}":
      command => "/usr/bin/rsync -rcvzh ${exclusions} ${backup_source} ${backup_destination}/",
      require => [File[$backup_destination], Exec["stop ${system_name} before backup"]],
      before  => Exec["restart ${system_name} after backup"],
    }

    exec { "restart ${system_name} after backup":
      command => "${service_restart_command} || echo 'service not running'",
      require => [Exec["backup sources: ${$backup_source} to: ${backup_destination}"]]
    }
  } else {
    notify { "Skipping backup for ${backup_source} as NOT required in environment: ${::environment}": }
  }
}
