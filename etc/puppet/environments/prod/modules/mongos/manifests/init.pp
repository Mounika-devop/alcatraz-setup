class mongos( $apps_dir, $mongo_user, $mongo_port, $mongod_port, $configdbs_and_port,$configdbs_and_port1 ) {
	include mongos::common

	user { $mongo_user:
		ensure     => present,
		managehome => true,
		home       => "${apps_dir}",
		shell      => "/bin/false",
		gid        => $mongo_user,
		require    => Group[$mongo_user],
	}
	group { $mongo_user:
		ensure  => present,
		require => Class["$::common"],
	}

    exec { 'add-webupd8-repo':
        command => "echo -ne \"\r\" | sudo add-apt-repository ppa:webupd8team/java",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => User["$mongo_user"],
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

    #    file { "/usr/lib/jvm/java-8-oracle/jre/lib":
    #    ensure  => directory,
    
    #require => Package["oracle-java8-set-default"],
    #}

	################# Import the public key
	exec { "import-apt-key":
		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
		command => "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927",
		unless  => "apt-key list | grep EA312927",
    require => Package["oracle-java8-set-default"],
		#		require => File["/usr/lib/jvm/java-8-oracle/jre/lib"]
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


	#  exec { "kill_mongoservice":
	#    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
	#    command => "pkill mongodb",
	#    unless => "ps -ef | grep mongo",
	#   require => Package["mongodb-org-tools"],
	#  }
	#  service { "mongodb":
	#	ensure => "stopped",
	#        require => Package["mongodb-org-tools"],
	# }
    #exec { "create_logdir":
    #	command => "/bin/mkdir -p /logs/mongodb && chown -R appsuser:appsuser /logs/mongodb",
    #	require => Package["mongodb-org-tools"],
    #}
    file { "/logs/mongodb":
        ensure  => directory,
        owner   => "$mongo_user",
        group   => "$mongo_user",
        require => Package["mongodb-org-tools"],
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

    file { "/etc/ssl/mongokeyfile":
        mode => 0400,
        owner   => "appsuser",
        group   => "appsuser",
        source  => "puppet:///modules/mongos/mongokeyfile",
        require => File["/etc/ssl/mongodb.pem"],
    }

        


    #   exec { "create_cert":
    #		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    #    cwd     => "/etc/ssl",
    #    command => 'openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-cert.crt -keyout mongodb-cert.key -subj "/C=IN/ST=KAR/L=BLR/O=Actiance/OU=DevOps"',
    #    require => File["/logs/mongodb"],

    #}

    #exec { "create_pem":
    #		path  => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    #    cwd     => "/etc/ssl",
    #    command => 'cat mongodb-cert.key mongodb-cert.crt > mongodb.pem',
    #    require => Exec["create_cert"],
    #}

    #    exec { "import_cert":
    #		path          => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    #    cwd     => "/etc/ssl",
    #    command => "keytool -noprompt -importcert -trustcacerts -file /etc/ssl/mongodb-cert.crt -alias mongodb -keystore /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts -storepass changeit",
    #	unless         => "keytool -list -v -keystore /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts -storepass changeit | grep mongodb",
    ##    require => Exec["create_pem"],
    #   require => File["/etc/ssl/mongokeyfile"],

    #}


	file { "/lib/systemd/system/mongodb.service":
		ensure  => present,
		mode    => '0755',
		content => template('mongos/mongodb_service.erb'),
		require => File["/etc/ssl/mongokeyfile"],
	}
	file { "/lib/systemd/system/mongod.service":
		ensure  => present,
		mode    => '0755',
		content => template('mongos/mongod_service.erb'),
		require => File["/etc/ssl/mongokeyfile"],
	}

    file {"/usr/lib/jvm/java-8-oracle/jre/lib/security":
        ensure => directory,
        recurse => true,
        source  => "puppet:///modules/common_files/security_jar",
        require => File["/lib/systemd/system/mongodb.service"],
    }
    

    file { "/usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts":
        mode    => 0644,
    	owner   => "root",
        group   => "root",
        source  => "puppet:///modules/mongos/cacerts",
        require => File["/usr/lib/jvm/java-8-oracle/jre/lib/security"],
    }


	  file { "/etc/mongod.conf":
	    ensure => present,
	    mode => '0644',
	    content => template('mongos/etc_mongod.conf.erb'),
	    #require => Package["mongodb-org-tools"],
	    require => File["/usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts"],
	    #	    notify  => Service['mongodb'],
	  }



	service { 'mongodb':
		ensure     => 'running',
		require    => File["/etc/mongod.conf"],
		enable     => 'true',
		#hasstatus  => 'true',
		provider   => 'systemd',
		#subscribe => File["/etc/mongod.conf"],
	} 
	service { 'mongod':
		ensure     => 'running',
		require    => File["/etc/mongod.conf"],
		enable     => 'true',
		#hasstatus  => 'true',
		provider   => 'systemd',
		#subscribe => File["/etc/mongod.conf"],
	}

}
