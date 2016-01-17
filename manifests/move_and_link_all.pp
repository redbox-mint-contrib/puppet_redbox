define puppet_redbox::move_and_link_all (
  $packages            = $title,
  $target_parent       = '/opt',
  $owner               = undef,
  $relocation_data_dir = '/mnt/data',
  $relocation_logs_dir = '/mnt/logs') {
  $system = $packages[system]
  $link_data_targets = prefix(['storage', 'solr', 'home/database', 'home/activemq-data'], "${system}/")

  exec { "stop ${system} before tidy/move/link": command => "service ${system} stop", }

  puppet_redbox::add_tidy { $system: require => Exec["stop ${system} before tidy/move/link"], }

  file { "${relocation_data_dir}/${system}":
    owner   => $owner,
    recurse => true,
  }

  file { "${relocation_logs_dir}/${system}":
    owner   => $owner,
    recurse => true,
  }

  file { "${relocation_data_dir}/${system}/home":
    owner   => $owner,
    recurse => true,
    require => File["${relocation_data_dir}/${system}"],
    notify  => [
      Puppet_redbox::Move_and_link_directory[$link_data_targets],
      Puppet_redbox::Move_and_link_directory["${target_parent}/${system}/home/logs"]],
  }

  puppet_redbox::move_and_link_directory { $link_data_targets:
    target_parent => $target_parent,
    relocation    => $relocation_data_dir,
    owner         => $owner,
    require       => [Exec["stop ${system} before tidy/move/link"], File["${relocation_data_dir}/${system}"]]
  }

  puppet_redbox::move_and_link_directory { "${target_parent}/${system}/home/logs":
    relocation => "${relocation_logs_dir}/${system}",
    owner      => $owner,
    require    => [
      Puppet_redbox::Add_tidy[$system],
      Exec["stop ${system} before tidy/move/link"],
      File["${relocation_logs_dir}/${system}"]],
  }

  file { "/var/log/${system}":
    ensure  => link,
    target  => "${relocation_logs_dir}/${system}",
    owner   => $owner,
    require => Puppet_redbox::Move_and_link_directory["${target_parent}/${system}/home/logs"],
  }

  exec { "restart ${system} after tidy/move/link":
    command => "service ${system} restart",
    require => [
      Puppet_redbox::Move_and_link_directory[$link_data_targets],
      Puppet_redbox::Move_and_link_directory["${target_parent}/${system}/home/logs"]]
  }

}