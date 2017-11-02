class mongodb($mongo_user,$apps_dir,$data_drive, $dbpath, $logpath,$logpath_file,$shardsvr,$logappend,$port,$replSet) {

exec { 'add-webupd8-repo':
    command => 'sudo add-apt-repository ppa:webupd8team/java',
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
}

exec { 'apt-update':
    command => 'sudo apt-get update',
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    require => Exec["add-webupd8-repo"],
}

exec {
    'set-licence-selected':
        command => 'echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
    'set-licence-seen':
        command => 'echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
}

package { 'oracle-java8-installer':
    ensure  => present,
    require => [Exec['apt-update'],Exec['add-webupd8-repo'], Exec['set-licence-selected'], Exec['set-licence-seen']],
}

package {
  'oracle-java8-set-default':
    ensure  => installed,
    require => Package['oracle-java8-installer'],
}

  ################# Import the public key
  exec { "import-apt-key":
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    command => "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927",
    unless  => "apt-key list | grep EA312927",
	require    => Package["oracle-java8-set-default"],
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

    file { "/etc/ssl/mongodb-cert.crt":
        mode    => 0644,
        source  => "puppet:///modules/mongos/mongodb-cert.crt",
        require => File["/logs/mongodb"],
    }

    file { "/etc/ssl/mongodb-cert.key":
        mode    => 0644,
        source  => "puppet:///modules/mongos/mongodb-cert.key",
        require => File["/etc/ssl/mongodb-cert.crt"],
    }

    file { "/etc/ssl/mongodb.pem":
        mode    => 0644,
        source  => "puppet:///modules/mongos/mongodb.pem",
        require => File["/etc/ssl/mongodb-cert.key"],
    }

    exec { "remove_cacerts":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/usr/lib/jvm/java-8-oracle/jre/lib/security",
        command => "rm -rfv /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts",
        require => File["/etc/ssl/mongodb.pem"],
    }

    file { "/usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/cacerts",
        owner   => "root",
        group   => "root",
        require => Exec["remove_cacerts"],
    }
    
    file { "/lib/systemd/system/mongodb.service":
        ensure  => present,
        mode    => 0644,
        content => template('mongodb/mongodb_service.erb'),
        require => File["/usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts"],
    }

    service { 'mongodb':
        ensure    => 'running',
        require   => File['/lib/systemd/system/mongodb.service'],
        enable    => 'true',
        hasstatus => 'true',
        provider  => 'systemd',
        subscribe => File["/lib/systemd/system/mongodb.service"],
    }

}

