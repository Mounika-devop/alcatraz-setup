class mongodb($mongo_user,$apps_dir,$data_drive, $dbpath, $logpath,$logpath_file,$shardsvr,$logappend,$port,$replSet) {
#$user = 'sysops',
#$data_drive = '/data1',
#$dbpath = '/data1/mongodb/data',
#$logpath = '/data1/mongodb/log',
#$logpath_file = '/data1/mongodb/log/mongodb.log',
#$shardsvr = 'true',
#$logappend = 'true',
#$port = '27017',
#$replSet = 'cs_poc') {

exec { 'add-webupd8-repo':
    command => 'sudo add-apt-repository ppa:webupd8team/java',
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
}

exec { 'apt-update':
    command => 'sudo apt-get update',
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    require => Exec["add-webupd8-repo"],
#    notify => Exec["apt-update"]
}

exec {
    'set-licence-selected':
        command => 'echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
    'set-licence-seen':
        command => 'echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
}

package { 'oracle-java7-installer':
    ensure  => present,
    require => [Exec['apt-update'],Exec['add-webupd8-repo'], Exec['set-licence-selected'], Exec['set-licence-seen']],
}

package {
  'oracle-java7-set-default':
    ensure  => installed,
    require => Package['oracle-java7-installer'],
}

  ################# Import the public key
  exec { "import-apt-key":
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    command => "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927",
    unless  => "apt-key list | grep EA312927",
	require    => Package["oracle-java7-set-default"],
  }
  
  ################ Create a list file for MongoDB
  exec { "create_mongo_list":
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    command => "echo 'deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list",
	unless => "cat /etc/apt/sources.list.d/mongodb-org-3.2.list | grep /etc/apt/sources.list.d/mongodb-org-3.2.list",
    require => Exec["import-apt-key"],
  }
  
  ################ Reload local package database
  exec { "mongo-apt-update":
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    command => "sudo apt-get update",
    unless => "ls /usr/bin | grep mongo",
    require => Exec["create_mongo_list"],
  }

  ############### Install MongoDB
  #$mongo_components = [ "mongodb-org", "mongodb-org-server", "mongodb-org-shell", "mongodb-org-mongos", "mongodb-org-tools" ]
  package { "mongodb-org": 
    ensure => '3.2.11',
    require => Exec["mongo-apt-update"],
  }

  package { "mongodb-org-server":
    ensure => '3.2.11',
    require => Package["mongodb-org"],
  }

  package { "mongodb-org-shell":
    ensure => '3.2.11',
    require => Package["mongodb-org-server"],
  }

  package { "mongodb-org-mongos":
    ensure => '3.2.11',
    require => Package["mongodb-org-shell"],
  }

  package { "mongodb-org-tools":
    ensure => '3.2.11',
    require => Package["mongodb-org-mongos"],
  }
/*
  file { "$data_drive/mongodb":
    ensure => directory,
    owner => mongodb,
    group => mongodb,
    require => Package["mongodb-org-tools"],
  }
*/
  user { $mongo_user:
	  ensure     => present,
	  shell      => "/bin/false",
	  managehome => true,
	  home       => "${apps_dir}",
	  gid     => $mongo_user,
	  require => Group[$mongo_user],

#      password => pw_hash('alcatraz1400','SHA-512','mysalt'),
#      groups   => "sudo",
  }

   group { $mongo_user:
  	  ensure  => present,
  	  require => Package["mongodb-org-tools"],
  }

  file { "$dbpath":
    ensure => directory,
    owner => "$mongo_user",
    group => "$mongo_user",
    require => [Package["mongodb-org-tools"],User[$mongo_user]],
  }

  file { "$logpath":
    ensure => directory,
    owner => $mongo_user,
    group => $mongo_user,
    require => File["$dbpath"],
  }

  file { "$logpath_file":
	  ensure  => present,
	  owner   => $mongo_user,
	  group   => $mongo_user,
	  require => File["$logpath"],
  }

  file { "${apps_dir}/.mongorc.js":
     ensure => present,
     mode => '0777',
     require => File["$logpath_file"],
  }

  file { "/etc/mongod.conf":
    ensure => present,
    content => template('mongodb/etc_mongod.conf.erb'),
    require => File["${apps_dir}/.mongorc.js"],
  }

    exec { "create_cert":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/etc/ssl",
        command => 'openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-cert.crt -keyout mongodb-cert.key -subj "/C=IN/ST=KAR/L=BLR/O=Actiance/OU=DevOps"',
        require => File["/etc/mongod.conf"],

    }

    exec { "create_pem":
        path  => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/etc/ssl",
        command => 'cat mongodb-cert.key mongodb-cert.crt > mongodb.pem',
        require => Exec["create_cert"],
    }

    exec { "import_cert":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/etc/ssl",
        command => "keytool -noprompt -importcert -trustcacerts -file /etc/ssl/mongodb-cert.crt -alias mongodb -keystore /usr/lib/jvm/java-7-oracle/jre/lib/security/cacerts -storepass changeit",
	unless  => "keytool -list -v -keystore /usr/lib/jvm/java-7-oracle/jre/lib/security/cacerts -storepass changeit | grep mongodb",
        require => Exec["create_pem"],

    }


  
   file { "/lib/systemd/system/mongodb.service":
    ensure  => present,
    content => template('mongodb/mongodb_service.erb'),
    require => Exec["import_cert"],
    notify  => Service["mongodb"],
  } 
  
  service { 'mongodb':
    ensure    => 'running',
    require   => File['/lib/systemd/system/mongodb.service'],
    enable    => 'true',
    hasstatus => 'true',
    provider  => 'systemd',
    subscribe => File["/lib/systemd/system/mongodb.service"],
  }
  exec { 'mongo_restart1':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "systemctl restart mongodb && sleep 5",
      require => Service["mongodb"],
  }


  file { "/tmp/initiate.js":
      ensure  => present,
      source  => "puppet:///modules/mongodb/initiate.js",
      require => Exec["mongo_restart1"],
  }

  exec { 'mongo_initiate':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "/bin/cat /tmp/initiate.js | /usr/bin/mongo --port 23757 --ssl --sslAllowInvalidCertificates",
        require => File['/tmp/initiate.js'],
  }

  file { "/tmp/create_admin_user.js":
      ensure  => present,
      source  => "puppet:///modules/mongodb/create_admin_user.js",
      require => Exec["mongo_initiate"],
  }

  exec { 'mongo_restart':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "systemctl restart mongodb && sleep 5",
        require => File["/tmp/create_admin_user.js"],
  }

  exec { 'create_admin_user':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "/bin/cat /tmp/create_admin_user.js | /usr/bin/mongo --port 23757 --ssl --sslAllowInvalidCertificates",
        require => Exec["mongo_restart"],
 }

 file { '/etc/ssl/mongokeyfile':
     ensure  => present,
     mode    => 0400,
     owner   => $mongo_user,
     group   => $mongo_user,
     source  => "puppet:///modules/mongodb/mongokeyfile",
     require => Exec["create_admin_user"],
 }

 exec { 'auth_true':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "echo 'auth = true' | sudo tee -a /etc/mongod.conf",
        require => File["/etc/ssl/mongokeyfile"],
 }


 exec { 'mongo_key_file':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "echo 'keyFile =  /etc/ssl/mongokeyfile' | sudo tee -a /etc/mongod.conf",
        require => Exec["auth_true"],
 }

 exec { 'mongo_restart3':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "systemctl restart mongodb && sleep 5",
        require => Exec["mongo_key_file"], 
 }

}

