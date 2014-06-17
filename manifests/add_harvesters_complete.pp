define puppet-redbox::add_harvesters_complete (
  $harvester_install_dir = hiera(h_install_dir, $title),
  $pgsql_version = hiera(h_postgres_version, "9.2"),
  $tomcat_install = hiera(h_tomcat_install, "/opt/tomcat7"),
  $tomcat_package_url = hiera(h_tomcat_package_url, "http://dev.redboxresearchdata.com.au/jdk/"),
  $tomcat_package = hiera(h_tomcat_package, "apache-tomcat-7.0.22.tar.gz"),
  $tomcat_package_dir = hiera(h_tomcat_package_dir, "apache-tomcat-7.0.22"),
  $oaiserver_config_src = hiera(h_oaiserver_config_src, "https://raw.githubusercontent.com/redbox-mint/oai-server/master/support/install/"),
  $oaiserver_init_sql = hiera(h_oaiserver_init_sql, "init.sql"),
  $cm_spring_idp_config_src = hiera(h_cm_spring_idp_config_src, "https://raw.githubusercontent.com/redbox-mint/curation-manager/master/web-app/WEB-INF/conf/spring/identityProdiverServiceProperties/"),
  $cm_spring_config_src = hiera(h_cm_spring_config_src , "https://raw.githubusercontent.com/redbox-mint/curation-manager/master/grails-app/conf/spring/"),
  $cm_spring_config_resource = hiera(h_cm_spring_config_resource, "resource.xml"),
  $cm_workdir = hiera(h_cm_workdir, "/var/local/curationmanager/"),
  $cm_idp_1 = hiera(h_cm_idp_1, "asynchronousSchedule.properties"),
  $cm_idp_2 = hiera(h_cm_idp_2, "handleIdentityProviderConf.properties"),
  $cm_idp_3= hiera(h_cm_idp_3, "localIdentityProviderConf.properties"),
  $cm_idp_4 = hiera(h_cm_idp_4, "nlaIdentityProviderConf.properties"),
  $cm_idp_5 = hiera(h_cm_idp_5, "orcIdentityProviderConf.properties"),
  $hm_war_url = hiera(h_hm_war_url, "http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata&a=json-harvester-manager&v=LATEST&e=war"),
  $cm_war_url = hiera(h_cm_war_url, "http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata&a=CurationManager&v=LATEST&e=war"),
  $oaiserver_war_url = hiera(h_oaiserver_war_url, "http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata.oai&a=oai-server&v=LATEST&e=war"),
  $hm_workdir=hiera(h_hm_workdir, ".json-harvester-manager-production"),
  $oaiserver_workdir=hiera(h_oaiserver_workdir, ".oai-server"),
  $wget_cmd = hiera(h_wget_cmd, "wget -N"),
  $wget_download_cmd = hiera(h_wget_download_cmd, "wget -N -O "),
  $cm_handler_key_url=hiera(h_cm_handler_key_url, "https://github.com/redbox-mint/curation-manager/raw/master/web-app/WEB-INF/conf/spring/handle/admpriv.bin"),
  $oaiharvester_package=hiera(h_oaiharvester_package, "redbox-oaipmh-feed.zip"),
  $oaiharvester_package_url=hiera(h_oaiharvester_package_url, "http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata.oai&a=redbox-oai-feed&v=LATEST&e=zip&c=bin"),
  $oaiharvester_id=hiera(h_oaiharvester_id, "redbox-oai-pmh-feed"),
  $mintcsvharvester_package=hiera(h_mintcsvharvester_package, "mint-csvjdbc-harvester.zip"),
  $mintcsvharvester_package_url=hiera(h_mintcsvharvester_package_url, "http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata&a=mint-csvjdbc-harvester&v=LATEST&e=zip&c=bin"),
  $mintcsvharvester_id=hiera(h_mintcsvharvester_id, "mint-csvjdbc"),
  $hm_url=hiera(h_hm_url, "http://localhost:8080/json-harvester-manager/harvester/"),
  $oaiharvester_samplehelper = hiera(h_oaiharvester_samplehelper, "https://raw.githubusercontent.com/redbox-harvester/redbox-oai-feed/master/support/install/addSampleRecord.groovy"),
  $oaiserver_formats_url = hiera(h_oaiserver_formats_url, "http://localhost/oai-server/?verb=ListMetadataFormats"),
  $groovy_version=hiera(h_groovy_version, "2.2.2"),
  $groovy_install_url=hiera(h_groovy_install_url, "http://dl.bintray.com/groovy/maven/groovy-binary-"),
  $groovy_install_dir=hiera(h_groovy_install_dir, "/opt/groovy"),
  $logRotateConf = hiera(h_logRotateConf, "tomcatLogRotate"),
  $isReadyScript = hiera(h_isReadyScript, "isready.sh"),
  $timestamp = generate('/bin/date', '+%Y-%m-%d_%H-%M-%S'),
  $mintHarvesterUser = hiera(h_mintHarvesterUser, "mintHarvest"),
  $mintHarvesterSshKey = hiera(h_mintHarvesterSshKey, undef),
  ) {
  ## Install Postgres
  class { 'postgresql::globals':
	  manage_package_repo => true,
	  version             => $pgsql_version,
	  pg_hba_conf_defaults=>false,
	}
	
	postgresql::server::db { 'oaiserver':
	  user     => 'oaiserver',
	  password => postgresql_password('oaiserver', 'oaiserver'),
	} 
	postgresql::server::db { 'curationmanager':
    user     => 'curationmanager',
    password => postgresql_password('curationmanager', 'curationmanager'),
  } 
	postgresql::server::pg_hba_rule { 'Local access as postgres user':
    type => 'local',
    database => 'all',
    user => 'postgres',
    auth_method => 'ident',
  } 
  postgresql::server::pg_hba_rule { 'allow localhost TCP access to postgresql user':
    type => 'host',
    database => 'all',
    user => 'postgres',
    address => '127.0.0.1/32',
    auth_method => 'md5',
  } 
	postgresql::server::pg_hba_rule { 'allow trust access from localhost':
	  description => "allow trust access from localhost",
	  type => 'host',
	  database => 'all',
	  user => 'all',
	  address => '127.0.0.1/32',
	  auth_method => 'trust',
	} 
	postgresql::server::pg_hba_rule { 'allow trust access from local':
    description => "allow trust access from localhost",
    type => 'local',
    database => 'all',
    user => 'all',
    auth_method => 'trust',
  }
   
  file { '/opt/postgresql':
    ensure => directory,
	} ->
	file { '/var/lib/postgresql':
	  ensure  => link,
	  target  => '/opt/postgresql',
	  before  => Class['::postgresql::server::install'],
	}
  
  # Install Tomcat and install app WARs and their configuration
  service {"Stop any existing Tomcat":
    ensure    => stopped,
    hasstatus => false,
    status    => "cat /var/run/tomcat/tomcat7.pid",
    stop      => "kill `cat /var/run/tomcat/tomcat7.pid` && rm -rf /var/run/tomcat/tomcat7.pid",
    require  => Class['postgresql::server'],
  } -> exec { "Download Tomcat Bundle":
    cwd     => '/tmp/',
    creates => "/tmp/${tomcat_package}",
    command => "${wget_cmd} ${tomcat_package_url}${tomcat_package}",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
    unless    => "ls -l ${tomcat_install}",
  } -> exec {"Extract Tomcat Bundle to Tomcat install directory":
    cwd       => '/tmp/', 
    creates   => '/tmp/${tomcat_package_dir}',
    command   => "tar xzf ${tomcat_package} && mv -f ${tomcat_package_dir} ${tomcat_install} && rm -rf ${tomcat_package} && curl -o ${tomcat_install}/bin/setenv.sh ${oaiserver_config_src}setenv.sh && chmod +x ${tomcat_install}/bin/setenv.sh && chown -R tomcat:tomcat ${tomcat_install} && curl -o /etc/init.d/tomcat7 ${oaiserver_config_src}tomcat7 && chmod +x /etc/init.d/tomcat7",
    path      => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
    unless    => "ls -l ${tomcat_install}",
  } -> file {"${harvester_install_dir}":
      ensure => directory,
      owner => "tomcat",
  } -> file {"${harvester_install_dir}${hm_workdir}":
    ensure  => directory,
    owner   => "tomcat",
  } -> file {"${harvester_install_dir}${oaiserver_workdir}":
    ensure  => directory,
    owner   => "tomcat"
  } -> file {"${cm_workdir}":
    ensure  => directory,
    owner   => "tomcat"
  } -> file {"/home/tomcat/${hm_workdir}":
    ensure  => link,
    target  => "${harvester_install_dir}${hm_workdir}"
  }  -> file {"/home/tomcat/${oaiserver_workdir}":
    ensure  => link,
    target  => "${harvester_install_dir}${oaiserver_workdir}"
  } -> exec {"Download oai-server, json-harvester-manager and curation manager WAR files and other config files": 
    cwd     => "${tomcat_install}/webapps/",
    command => "${wget_download_cmd} json-harvester-manager.war '${hm_war_url}' && ${wget_download_cmd} CurationManager.war '${cm_war_url}' && ${wget_download_cmd} oai-server.war '${oaiserver_war_url}'",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
    unless  => "ls -l ${tomcat_install}/webapps/json-harvester-manager",
  } -> exec {"Download the config files":
    cwd     => "${cm_workdir}",
    command => "${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_1}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_2}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_3}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_4}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_5}' && ${wget_cmd} '${$cm_spring_config_src}${cm_spring_config_resource}' && ${wget_cmd} '${cm_handler_key_url}'",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
    unless  => "ls -l ${tomcat_install}/webapps/json-harvester-manager",
  } -> exec {"Download and apply SQL init file":
    cwd     => '/tmp',
    command => "${wget_cmd} ${oaiserver_config_src}${oaiserver_init_sql} && psql -U oaiserver < ${oaiserver_init_sql}",
    path    => ['/usr/bin','/usr/sbin', '/bin'],
    unless  => "ls -l ${tomcat_install}/webapps/oai-server",
  } -> exec { "Wait for Tomcat to die.":
    cwd   => "${harvester_install_dir}",
    command => "./${isReadyScript} '${tomcat_install}/logs/catalina.out' 'Tomcat' 'Destroying ProtocolHandler'",
    path    => ['/usr/bin','/usr/sbin', '/bin', "${harvester_install_dir}"],
    onlyif  => "ls -l ${tomcat_install}/logs/catalina.out",
  } -> exec { "Move out current Tomcat catalina.out":
    cwd   => "${tomcat_install}/logs",
    command => "mv catalina.out catalina_${timestamp}",
    path    => ['/usr/bin','/usr/sbin', '/bin'],
    onlyif  => "ls -l catalina.out",
  } -> exec { "Download helper script and logrotateConf":
    cwd   => "${harvester_install_dir}",
    command => "${wget_cmd} ${oaiserver_config_src}${isReadyScript} && chmod +x ${isReadyScript} && ${wget_download_cmd} /etc/logrotate.d/${logRotateConf} ${oaiserver_config_src}${logRotateConf}",
    path    => ['/usr/bin','/usr/sbin', '/bin'],
    unless  => "ls -l ${isReadyScript}",
  } -> service {"Configure Tomcat service":
    name => "tomcat7",
    ensure => running,
    hasrestart => true,
    enable => true
  } -> exec { "Wait for Tomcat to be ready.":
    cwd   => "${harvester_install_dir}",
    command => "./${isReadyScript} '${tomcat_install}/logs/catalina.out' 'Tomcat' 'Server startup'",
    path    => ['/usr/bin','/usr/sbin', '/bin', "${harvester_install_dir}"],
    onlyif  => "ls -l ${tomcat_install}/logs/catalina.out",
  }-> exec {"Install OAI-PMH FEED harvester":
    cwd     => "/tmp",
    command => "curl -L -o ${oaiharvester_package} '${oaiharvester_package_url}' && curl -i -F 'harvesterPackage=@${oaiharvester_package}' -H 'Accept: application/json' '${hm_url}upload/${oaiharvester_id}' && curl -o harvester.check -i -H 'Accept: application/json' '${hm_url}' &&  grep '${oaiharvester_id}' harvester.check >/dev/null",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
    unless  => "ls /opt/harvester/${hm_workdir}/harvest/${oaiharvester_id}"
  } -> exec {"Starting OAI-PMH FEED harvester":
    cwd     => "/tmp",
    command => "curl -o ${oaiharvester_id}_harvester.check -i -H 'Accept: application/json' '${hm_url}start/${oaiharvester_id}'",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin']
  } -> exec {"Install Mint CSVJDBC harvester":
    cwd     => "/tmp",
    command => "curl -L -o ${mintcsvharvester_package} '${mintcsvharvester_package_url}' && curl -i -F 'harvesterPackage=@${mintcsvharvester_package}' -H 'Accept: application/json' '${hm_url}upload/${mintcsvharvester_id}' && curl -o harvester.check -i -H 'Accept: application/json' '${hm_url}' &&  grep '${mintcsvharvester_id}' harvester.check >/dev/null",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
    unless  => "ls /opt/harvester/${hm_workdir}/harvest/${mintcsvharvester_id}"
  } -> exec {"Starting Mint CSVJDBC harvester":
    cwd     => "/tmp",
    command => "curl -o ${mintcsvharvester_id}_harvester.check -i -H 'Accept: application/json' '${hm_url}start/${mintcsvharvester_id}'",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin']
  } -> package {"Install unzip":
      name  => "unzip",
  } -> exec {"Downloading groovy...":
    cwd     => "/tmp",
    command => "${wget_download_cmd} groovy-binary-${groovy_version}.zip ${groovy_install_url}${groovy_version}.zip && unzip groovy-binary-${groovy_version}.zip && mv /tmp/groovy-${groovy_version} ${groovy_install_dir} && ln -s ${groovy_install_dir}/bin/groovy /usr/bin/groovy",
    unless  => "ls -l ${groovy_install_dir}",
    path    => ['/usr/bin','/usr/sbin', '/bin'],
  } -> exec {"Downloading helper script for adding sample data.":
    cwd     => "/opt/harvester",
    command => "${wget_download_cmd} addSampleRecord.groovy ${oaiharvester_samplehelper} && chmod +x addSampleRecord.groovy",
    path    => ['/usr/bin','/usr/sbin', '/bin'],
  } -> exec {"Priming OAI-Server": 
    cwd     => "/opt/harvester",
    command => "curl --retry 2 --retry-delay 60 ${$oaiserver_formats_url}",
    path    => ['/usr/bin','/usr/sbin', '/bin'],
  } -> file {"${harvester_install_dir}${hm_workdir}/harvest/${mintcsvharvester_id}/input":
    ensure  => directory,
    owner   => "tomcat",
    mode    => 0775,
    recurse => true,
  } -> file {"${harvester_install_dir}${hm_workdir}/harvest/${mintcsvharvester_id}/output":
    ensure  => directory,
    owner   => "tomcat",
    mode    => 0775,
    recurse => true,
  } -> file {"/home/${mintHarvesterUser}/input":
    ensure  => link,
    target  => "${harvester_install_dir}${hm_workdir}/harvest/${mintcsvharvester_id}/input",  
    require => User["${mintHarvesterUser}"]
  }
  
  
  if ($mintHarvesterSshKey == undef) {
		  user {"Add tomcat user":
		    name    => "tomcat",
		    ensure  => present,
		  } -> file {"/home/tomcat":
		      ensure => directory,
		      owner => "tomcat",
		  } -> user {"Creating user '${mintHarvesterUser}'":
		      name    => "${mintHarvesterUser}",
		      ensure  => present,
		      groups  => ["${mintHarvesterUser}"],
		      gid     => "tomcat",
		  } -> file {"/home/${mintHarvesterUser}/":
		       ensure  => directory,
		       owner => "${mintHarvesterUser}",
		       group => "${mintHarvesterUser}",
		       mode  => 0700
		  } -> file {"/home/${mintHarvesterUser}/.profile":
           ensure  => file,
           owner   => "${mintHarvesterUser}",
           content => "umask 002",
      } -> file {"/home/${mintHarvesterUser}/.ssh":
		       ensure  => directory,
		       owner => "${mintHarvesterUser}",
		       group => "${mintHarvesterUser}",
		       mode  => 0700
		  } -> exec {"Use public SSH key used in instance creation for user '${mintHarvesterUser}'":
		      command => "cp -R /home/ec2-user/.ssh/authorized_keys /home/${mintHarvesterUser}/.ssh/authorized_keys && chown -R ${mintHarvesterUser}:${mintHarvesterUser} /home/${mintHarvesterUser}/.ssh && chmod -R go-rwx /home/${mintHarvesterUser}/.ssh",
		      path    => ['/usr/bin','/usr/sbin', '/bin'],
		      unless  => "ls /home/${mintHarvesterUser}/.ssh",
	    }
  } else {
      user {"Add tomcat user":
        name    => "tomcat",
        ensure  => present,
      } -> file {"/home/tomcat":
          ensure => directory,
          owner => "tomcat",
      } -> user {"Creating user '${mintHarvesterUser}'":
		      name    => "${mintHarvesterUser}",
		      ensure  => present,
		      groups  => ["${mintHarvesterUser}"],
		      gid     => "tomcat",
		  } -> file {"/home/${mintHarvesterUser}/":
		       ensure  => directory,
		       owner => "${mintHarvesterUser}",
		       group => "${mintHarvesterUser}",
		       mode  => 0700
		  } -> file {"/home/${mintHarvesterUser}/.profile":
           ensure  => file,
           owner   => "${mintHarvesterUser}",
           content => "umask 002",
      } -> file {"/home/${mintHarvesterUser}/.ssh":
		       ensure  => directory,
		       owner => "${mintHarvesterUser}",
		       group => "${mintHarvesterUser}",
		       mode  => 0700
		  } -> ssh_authorized_key {"Injecting Public SSH Key for user '${mintHarvesterUser}'":
	         name   => "${mintHarvesterUser}",
	         ensure => present,
	         key    => "${mintHarvesterSshKey}",
	         user   => "${$mintHarvesterUser}",
	         type => ssh-rsa
      }  
  }
  include postgresql::server
}