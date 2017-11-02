class egw($apps_dir,$data_dir,$logs_dir,$log_postfix_dir) {
    package { 'python-software-properties':
        ensure => installed,
    }

    file { '/opt/ssl-cert_1.0.35_all.deb':
        owner   => root,
        group   => root,
        mode    => 644,
        ensure  => present,
        source  => "puppet:///modules/egw/ssl-cert_1.0.35_all.deb",
        require => Package["oracle-java8-set-default"],
    }

    package { 'ssl-cert':
        ensure   => installed,
        provider => dpkg,
        source   => '/opt/ssl-cert_1.0.35_all.deb',
        require  => File['/opt/ssl-cert_1.0.35_all.deb'],
    }

    package { 'postfix':
        ensure   => installed,
        require  => Package['ssl-cert'],
    }

    file { '/etc/postfix/main.cf':
        ensure  => present,
        mode    => 0644,
        content => template('egw/main.cf.erb'),
        require => Package["postfix"],
    }

    #file { "$apps_dir":
    #    ensure  => directory,
    #    owner   => appsuser,
    #    group   => appsuser,
    #    require => File["/etc/postfix/main.cf"],
    #}

    file { "$apps_dir/EmailJournal":
        ensure  => directory,
        recurse => true,
        source  => "puppet:///modules/egw/EmailJournal",
        owner   => appsuser,
        group   => appsuser,
        #    require => File["$apps_dir"],
        require => File["/etc/postfix/main.cf"],
    }

    file { "$apps_dir/EmailJournal/configs/config.properties":
        mode    => 0644,
        content => template('egw/config.properties.erb'),
        require => File["$apps_dir/EmailJournal"],
        owner   => appsuser,
        group   => appsuser,
    }

    file { "$apps_dir/EmailJournal/configs/log4j.properties":
        mode    => 0644,
        content => template('egw/log4j.properties.erb'),
        require => File["$apps_dir/EmailJournal/configs/config.properties"],
        owner   => appsuser,
        group   => appsuser,
    }

    file { "/etc/init.d/lweg-jilter":
        mode    => 0755,
        content => template('egw/lweg-jilter.erb'),
        require => File["$apps_dir/EmailJournal/configs/log4j.properties"],
        owner   => appsuser,
        group   => appsuser,
    }

    file { "${logs_dir}":
        ensure  => directory,
        owner   => appsuser,
        group   => appsuser,
        require => File["/etc/init.d/lweg-jilter"],
    }

    file { "${data_dir}":
        ensure  => directory,
        require => File["${logs_dir}"],
        owner   => appsuser,
        group   => appsuser,
    }

    file { "${data_dir}/data":
        ensure  => directory,
        require => File["${data_dir}"],
        owner   => appsuser,
        group   => appsuser,
    }

    file { "${data_dir}/data/egw.jks":
        ensure  => present,
        mode    => 0644,
        owner   => appsuser,
        group   => appsuser,
        source  => "puppet:///modules/egw/egw.jks",
        require => File["${data_dir}/data"],
    }

    file { "/data1/heapdump":
        ensure  => directory,
        owner   => appsuser,
        group   => appsuser,
        require => File["${data_dir}/data/egw.jks"],
    }


    exec { 'keytool-export':
        command => "keytool -noprompt -export -alias egw -keystore ${data_dir}/data/egw.jks -file egw.cer -storepass facetime",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "${data_dir}/data",
        require => File["/data1/heapdump"],
    }

    exec { 'keytool-import':
        command => "keytool -noprompt -import -v -trustcacerts  -alias egw -file egw.cer -keystore /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts -storepass changeit",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        unless  => "keytool -v -list -keystore /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts -storepass changeit | egrep egw",
        cwd     => "${data_dir}/data",
        require => Exec["keytool-export"],
    }

    file { '/lib/systemd/system/lweg-jilter.service':
        ensure  => present,
        source  => "puppet:///modules/egw/lweg-jilter.service",
        require => Exec["keytool-import"],
    }

    file { "$log_postfix_dir":
        ensure  => directory,
        owner   => "syslog",
        group   => "adm",
        mode    => 0755,
        require => File['/lib/systemd/system/lweg-jilter.service'],
        notify => Service["rsyslog"],
    }

    file { '/etc/rsyslog.d/50-default.conf':
        ensure  => present,
        content => template("egw/50-default.conf.erb"),
        require => File["$log_postfix_dir"],
        notify => Service["rsyslog"],
    }

    service { 'rsyslog':
        ensure   => running,
        provider => "systemd",
        require  => File['/etc/rsyslog.d/50-default.conf'],
        notify   => Service["postfix"],
    }

    service { 'postfix':
        ensure  => running,
        require => Service["rsyslog"],
    }


    service { 'lweg-jilter':
        ensure   => running,
        provider => "systemd",
        require  => File["/lib/systemd/system/lweg-jilter.service"],
    }
}
