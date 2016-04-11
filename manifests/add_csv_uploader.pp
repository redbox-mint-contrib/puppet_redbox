define puppet_redbox::add_csv_uploader (
  $source        = $title,
  $extract_path  = '/opt',
  $download_path = '/tmp',
  $can_download_and_overwrite        = true,
  $expected_extracted_directory_name = undef,) {
  require 'archive'
  $creates = $can_download_and_overwrite ? {
    true    => undef,
    default => "${extract_path}/${expected_extracted_directory_name}",
  }

  validate_absolute_path($extract_path)
  validate_absolute_path($download_path)

  $archive_name = basename($source)
  $full_download_path = "${download_path}/${archive_name}"

  archive { $full_download_path:
    extract_path => $extract_path,
    extract      => true,
    source       => $source,
    # # determines whether it will download (and subsequently overwrite if extract == 'true')
    creates      => $creates,
    cleanup      => true,
  } ->
  # # workaround, as cleanup doesn't seem to work
  exec { "/bin/rm -f ${full_download_path}": }

}