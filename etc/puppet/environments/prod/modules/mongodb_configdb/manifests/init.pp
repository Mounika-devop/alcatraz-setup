class mongodb_configdb($mongo_user, $data_drive, $data_dir, $log_dir, $dbpath,$logpath,$logpath_file,$logappend, $port) {

#data_drive => '/data1',
#data_dir => "$data_drive", 
#log_dir => "/logs",
#dbpath => "$data_dir/mongodb",
#logpath => "$log_dir/mongodb",
#logpath_file => "$logpath/mongodb.log",
#port => '27018',
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

  exec { "kill_mongoservice":
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    command => "sudo service mongod stop",
    unless => "ps -ef | grep mongo",
    require => Package["mongodb-org-tools"],
  }

  #file { "$data_drive":
  #  ensure => directory,
  #  require => Exec["kill_mongoservice"],
  #}
  user { $mongo_user:
      ensure     => present,
      shell      => "/bin/false",
      managehome => true,
      home       => "/apps",
      gid        => $mongo_user,
      require    => Group[$mongo_user],
  }

  group { $mongo_user:
      ensure  => present,
      require => Exec["kill_mongoservice"],
  }


  file { "$data_dir":
    ensure => directory,
    owner => "$mongo_user",
    group => "$mongo_user",
    require => User[$mongo_user],
  }
  
  file { "$dbpath":
    ensure => directory,
    owner => "$mongo_user",
    group => "$mongo_user",
    require => File["$data_dir"],
  }

  file { "$log_dir":
    ensure => directory,
    owner => "$mongo_user",
    group => "$mongo_user",
    require => File["$dbpath"],
  }


  file { "$logpath":
    ensure => directory,
    owner => "$mongo_user",
    group => "$mongo_user",
    require => File["$log_dir"],
  }

  file { "/etc/mongod.conf":
    ensure => present,
    content => template('mongodb_configdb/etc_mongod.conf.erb'),
    require => File["$logpath"],
  }

#    exec { "create_cert":
#        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
#        cwd     => "/etc/ssl",
#        command => 'openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-cert.crt -keyout mongodb-cert.key -subj "/C=IN/ST=KAR/L=BLR/O=Actiance/OU=DevOps"',
#        require => File["/etc/mongod.conf"],

#    }

#    exec { "create_pem":
#        path  => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
#        cwd     => "/etc/ssl",
#        command => 'cat mongodb-cert.key mongodb-cert.crt > mongodb.pem',
#        require => Exec["create_cert"],
#    }
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


    #exec { "import_cert":
    #    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    #    cwd     => "/etc/ssl",
    #    command => "keytool -noprompt -importcert -trustcacerts -file /etc/ssl/mongodb-cert.crt -alias mongodb -keystore /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts -storepass changeit",
    #    require => Exec["create_pem"],

    #}


  file { "/lib/systemd/system/mongod.service":
    ensure => present,
    content => template('mongodb_configdb/mdbconf.service.erb'),
    require => File["/etc/ssl/mongodb.pem"],
  }
  
  service { 'mongod':
    ensure     => 'running',
    require    => File['/lib/systemd/system/mongod.service'],
    provider   => 'systemd',
    enable     => 'true',
    hasstatus  => 'true',
    #subscribe => [File["/etc/init/mongod.conf"], File["/etc/mongod.conf"]],
  }

}

