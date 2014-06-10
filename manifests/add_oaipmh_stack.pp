define puppet-redbox::add_oaipmh_stack (
  $harvester_install_dir = $title,
  $pgsql_version = "9.3",
  $tomcat_install = "/opt/tomcat7",
  $tomcat_package_url = "http://dev.redboxresearchdata.com.au/jdk/",
  $tomcat_package = "apache-tomcat-7.0.22.tar.gz",
  $tomcat_package_dir ="apache-tomcat-7.0.22",
  $oaiserver_config_src = "https://raw.githubusercontent.com/redbox-mint/oai-server/master/support/install/",
  $oaiserver_init_sql = "init.sql",
  $cm_spring_idp_config_src = "https://raw.githubusercontent.com/redbox-mint/curation-manager/master/web-app/WEB-INF/conf/spring/identityProdiverServiceProperties/",
  $cm_spring_config_src = "https://raw.githubusercontent.com/redbox-mint/curation-manager/master/grails-app/conf/spring/",
  $cm_spring_config_resource = "resource.xml",
  $cm_workdir = "/var/local/curationmanager/",
  $cm_idp_1 = "asynchronousSchedule.properties",
  $cm_idp_2 = "handleIdentityProviderConf.properties",
  $cm_idp_3= "localIdentityProviderConf.properties",
  $cm_idp_4 = "nlaIdentityProviderConf.properties",
  $cm_idp_5 = "orcIdentityProviderConf.properties",
  $hm_war_url="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata&a=json-harvester-manager&v=LATEST&e=war",
  $cm_war_url="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata&a=CurationManager&v=LATEST&e=war",
  $oaiserver_war_url="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata.oai&a=oai-server&v=LATEST&e=war",
  $hm_workdir=".json-harvester-manager-production",
  $oaiserver_workdir=".oai-server",
  $wget_cmd = "wget -N",
  $wget_download_cmd = "wget -N -O ",
  $cm_handler_key_url="https://github.com/redbox-mint/curation-manager/raw/master/web-app/WEB-INF/conf/spring/handle/admpriv.bin",
  $oaiharvester_package="redbox-oaipmh-feed.zip",
  $oaiharvester_package_url="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata.oai&a=redbox-oai-feed&v=LATEST&e=zip&c=bin",
  $oaiharvester_id="redbox-oai-pmh-feed",
  $mintcsvharvester_package="mint-csvjdbc-harvester.zip",
  $mintcsvharvester_package_url="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.com.redboxresearchdata&a=mint-csvjdbc-harvester&v=LATEST&e=zip&c=bin",
  $mintcsvharvester_id="mint-csvjdbc",
  $hm_url="http://localhost:8080/json-harvester-manager/harvester/",
  $oaiharvester_samplehelper = "https://raw.githubusercontent.com/redbox-harvester/redbox-oai-feed/master/support/install/addSampleRecord.groovy",
  $oaiserver_formats_url = "http://localhost/oai-server/?verb=ListMetadataFormats",
  $groovy_version="2.2.2",
  $groovy_install_url="http://dl.bintray.com/groovy/maven/groovy-binary-",
  $groovy_install_dir="/opt/groovy",
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
  
  # Install Tomcat and install app WARs and their configuration
  service {"Stop any existing Tomcat":
    ensure    => stopped,
    hasstatus => false,
    status    => "cat /var/run/tomcat/tomcat7.pid",
    stop      => "kill `cat /var/run/tomcat/tomcat7.pid` && rm -rf /var/run/tomcat/tomcat7.pid",
    require  => Class['postgresql::server'],
  } -> user {"Add tomcat user":
    name    => "tomcat",
    ensure  => present,
  } -> file {"/home/tomcat":
      ensure => directory,
      owner => "tomcat",
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
    owner   => "tomcat"
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
  } -> exec {"Download the config files":
    cwd     => "${cm_workdir}",
    command => "${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_1}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_2}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_3}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_4}' && ${wget_cmd} '${cm_spring_idp_config_src}${cm_idp_5}' && ${wget_cmd} '${$cm_spring_config_src}${cm_spring_config_resource}' && ${wget_cmd} '${cm_handler_key_url}'",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin'],
  } -> exec {"Download and apply SQL init file":
    cwd     => '/tmp',
    command => "${wget_cmd} ${oaiserver_config_src}${oaiserver_init_sql} && psql -U oaiserver < ${oaiserver_init_sql}",
    path    => ['/usr/bin','/usr/sbin', '/bin'],
  } -> service {"Configure Tomcat service":
    name => "tomcat7",
    ensure => running,
    hasrestart => true,
    enable => true
  } -> exec {"Install OAI-PMH FEED harvester":
    cwd     => "/tmp",
    command => "curl -L -o ${oaiharvester_package} '${oaiharvester_package_url}' && curl -i -F 'harvesterPackage=@${oaiharvester_package}' -H 'Accept: application/json' '${hm_url}upload/${oaiharvester_id}' && curl -o harvester.check -i -H 'Accept: application/json' '${hm_url}' &&  grep '${oaiharvester_id}' harvester.check >/dev/null",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin']
  } -> exec {"Starting OAI-PMH FEED harvester":
    cwd     => "/tmp",
    command => "curl -o ${oaiharvester_id}_harvester.check -i -H 'Accept: application/json' '${hm_url}start/${oaiharvester_id}'",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin']
  } -> exec {"Install Mint CSVJDBC harvester":
    cwd     => "/tmp",
    command => "curl -L -o ${mintcsvharvester_package} '${mintcsvharvester_package_url}' && curl -i -F 'harvesterPackage=@${mintcsvharvester_package}' -H 'Accept: application/json' '${hm_url}upload/${mintcsvharvester_id}' && curl -o harvester.check -i -H 'Accept: application/json' '${hm_url}' &&  grep '${mintcsvharvester_id}' harvester.check >/dev/null",
    path    => ['/usr/bin','/usr/sbin', '/bin', '/sbin']
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
  }
  
  include postgresql::server
}