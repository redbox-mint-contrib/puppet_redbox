# == Class: puppet_redbox
#
# Puppet Centos installation of redbox and mint, including harvester,apache proxy and system_config
# population.
# === Authors
#
# Matt Mulholland <matt@redboxresearchdata.com.au>
# <a href="https://github.com/shilob">Shilo Banihit</a>
# === Copyright
#
# Copyright (C) 2013 Queensland Cyber Infrastructure Foundation (http://www.qcif.edu.au/)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, write to the Free Software Foundation, Inc.,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
class puppet_redbox (
  $install_type             = 'basic',
  $redbox_user              = hiera(redbox_user, 'redbox'),
  $install_parent_directory = hiera(install_parent_directory, '/opt'),
  $is_fresh_install         = false,
  $packages                 = hiera_hash(packages, {
    redbox              => {
      system              => 'redbox',
      package             => 'redbox-distro',
      server_url_context  => 'redbox',
      install_directory   => '/opt/redbox',
      institutional_build => '',
    }
    ,
    mint                => {
      system              => 'mint',
      package             => 'mint-distro',
      server_url_context  => 'mint',
      install_directory   => '/opt/mint',
      post_install        => [
        'mint-solr-geonames',
        'mint-build-distro-initial-data'],
      institutional_build => '',
    }
  }
  ),
  $proxy                    = hiera(proxy, [
    {
      path => '/mint',
      url  => 'http://localhost:9001/mint'
    }
    ,
    {
      path => '/redbox',
      url  => 'http://localhost:9000/redbox'
    }
    ,
    {
      path => '/oai-server',
      url  => 'http://localhost:8080/oai-server'
    }
    ]),
  $has_dns                  = hiera(has_dns, false),
  $has_ssl                  = hiera(has_ssl, false),
  $exec_path                = hiera_array(exec_path, [
    '/usr/local/bin',
    '/opt/local/bin',
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin']),
  $ssl_config               = hiera_hash(ssl_config, {
    cert  => {
      file  => "/etc/ssl/local_certs/${::fqdn}.crt"
    }
    ,
    key   => {
      file => "/etc/ssl/local_certs/${::fqdn}.key",
      mode => '0444'
    }
    ,
    chain => {
      file  => "/etc/ssl/local_certs/${::fqdn}.chain"
    }
  }
  ),
  $yum_repos                = hiera(yum_repos, [
    {
      name     => 'redbox_releases',
      descr    => 'Redbox_release_repo',
      baseurl  => 'http://dev.redboxresearchdata.com.au/yum/releases',
      gpgcheck => 0,
      priority => 15,
      enabled  => 1
    }
    ,
    {
      name     => 'redbox_snapshots',
      descr    => 'Redbox_snapshot_repo',
      baseurl  => 'http://dev.redboxresearchdata.com.au/yum/snapshots',
      gpgcheck => 0,
      priority => 20,
      enabled  => 1
    }

    ]),
  $crontab                  = hiera_hash(crontab, undef),
  $tf_env                   = hiera_hash(tf_env, undef),
  $system_config            = hiera_hash(system_config, undef),
  $relocation_data_dir      = hiera_hash(relocation_data_dir, '/mnt/data'),
  $relocation_logs_dir      = hiera_hash(relocation_logs_dir, '/mnt/logs')) {
  if ($has_dns and $::fqdn) {
    $server_url = $::fqdn
  } elsif ($::ipaddress) {
    $server_url = $::ipaddress
  } else {
    $server_url = $::ipaddress_lo
  }

  host { [$::fqdn, $::hostname]: ip => $::ipaddress, }

  Exec {
    path      => $exec_path,
    logoutput => false,
  }

  Package {
    allow_virtual => false, }

  puppet_common::add_systemuser { $redbox_user: }

  ensure_resource(file, $install_parent_directory, {
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  )

  contain 'puppet_common::java'

  if ($proxy) {
    class { 'puppet_redbox::add_proxy_server':
      require    => Class['Puppet_common::Java'],
      before     => Puppet_redbox::Add_redbox_package[values($packages)],
      notify     => Service['httpd'],
      server_url => $server_url,
      has_ssl    => $has_ssl,
      ssl_config => $ssl_config,
      proxy      => $proxy,
    }

    #  Force apache restart after puppet module as guarantee that latest redbox refreshed -
    #  problem occurs when duplicating httpd 'service' call already made by apache module (hence use
    #  of 'exec') or when change made to redbox which doesn't trigger httpd service (as it is
    #  already running).
    exec { 'service httpd restart': require => Puppet_redbox::Add_redbox_package[values($packages)], }

  }

  ensure_packages('unzip')
  ensure_resource('puppet_common::add_yum_repo', $yum_repos, {
    'exec_path' => $exec_path
  }
  )
  puppet_redbox::add_redbox_package { [values($packages)]:
    owner           => $redbox_user,
    has_ssl         => $has_ssl,
    tf_env          => $tf_env,
    system_config   => $system_config,
    base_server_url => $server_url,
    proxy           => $proxy,
    require         => [
      Puppet_common::Add_systemuser[$redbox_user],
      Class['Puppet_common::Java'],
      Puppet_common::Add_yum_repo[$yum_repos],
      Package['unzip']],
  } ->
  file { [$relocation_data_dir, $relocation_logs_dir]:
    ensure => directory,
    owner  => 'root',
  } -> puppet_redbox::restart_system { [values($packages)]: }

  # #hack for now until resolve issue of too much file recursion (or rip out altogether)
  if ($is_fresh_install) {
    puppet_redbox::move_and_link_all { [values($packages)]:
      owner     => $redbox_user,
      exec_path => $exec_path,
      require   => [File[$relocation_data_dir], File[$relocation_logs_dir], Puppet_redbox::Restart_system[values($packages)]],
    }
  } else {
    notify { 'WARNING: No links will be created or checked, so ensure this is NOT a fresh install.': }
  }

  if ($crontab) {
    puppet_common::add_cron { $crontab: cron_path => join($exec_path, ':'), }
  }

  # Check flag whether to install Harvester stack
  if $install_type == 'harvester-complete' {
    puppet_redbox::add_harvesters_complete { '/opt/harvester/': require => Package['unzip'] }
  }

  tidy { '/var/lib/puppet/reports':
    age     => '1w',
    recurse => true,
    matches => ['*.yaml'],
  }

}
