define puppet_redbox::add_csv_uploader (
  $source                     = $title,
  $extract_path               = '/opt',
  $download_path              = undef,
  $can_download_and_overwrite = true,) {
#  require 'archive'

  if (!$download_path) {
    fail("Must define an absolute download path including filename.")
  }

  #  $creates = $can_download_and_overwrite ? {
  #    true    => undef,
  #    default => "${extract_path}/${expected_extracted_directory_name}",
  #  }


  validate_absolute_path($extract_path)
  validate_absolute_path($download_path)

  #  $archive_name = basename($source)
  #  $full_download_path = "${download_path}/${archive_name}"

  ensure_package { 'unzip': }
  exec { "wget ${source} -O ${download_path}": } ->
  exec { "unzip -u -d ${extract_path}/ ${download_path}": require => Package['unzip'], }

  #  archive { $full_download_path:
  #    extract_path => $extract_path,
  #    extract      => true,
  #    source       => $source,
  #    # # determines whether it will download (and subsequently overwrite if extract == 'true')
  #    creates      => $creates,
  #    cleanup      => true,
  #  } ->
  # # workaround, as cleanup doesn't seem to work
  #  exec { "/bin/rm -f ${full_download_path}": }
}