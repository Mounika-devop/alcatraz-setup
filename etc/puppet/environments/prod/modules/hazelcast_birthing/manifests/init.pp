class hazelcast_birthing($build_number, $apps_dir, $heapdump_file_path, $scribe_port, $haz_port, $haz_log_dir, $hazelcast_home, $hazelcast_user, $hazelcast_group, $java_home_jars, $prop_temp_file_path, $hazelcast_jvm_min_mem, $kafka_brokers_with_ports, $kafka_zkservers) {

    $alcatraz_cache_package = "alcatraz_cache_${build_number}.zip"
    $ceph_package = "alceph_${build_number}_amd64.deb"

    file { "${hazelcast_home}":
        ensure => directory,
        owner  => $hazelcast_user,
        group  => $hazelcast_group,
    }

    file {"hazelcat_tar":
        ensure => present,
        path   => "${hazelcast_home}/$alcatraz_cache_package",
        source => "puppet:///modules/common_files/build/$build_number/$alcatraz_cache_package",
        require => File["${hazelcast_home}"],
    }

    exec {'alcatraz_cache_install':
         command => "unzip -o $hazelcast_home/$alcatraz_cache_package",
         cwd     => "$hazelcast_home",
         path    => ["/usr/bin", "/bin"],
         require => File['hazelcat_tar'],
    }

    exec { 'remove_deb_pack':
        command => "dpkg -r alceph",
        cwd     => "$hazelcast_home",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => Exec ['alcatraz_cache_install'],
    }

    file { "$hazelcast_home/$ceph_package":
        ensure => present,
        source => "puppet:///modules/common_files/build/$build_number/$ceph_package",
        require => Exec['remove_deb_pack'],
    }

    exec {'alcatraz_ceph_install':
        command => "dpkg -i $hazelcast_home/$ceph_package",
        cwd     => "$hazelcast_home",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$hazelcast_home/$ceph_package"],
    }

    file {"/etc/ceph":
        ensure => present,
        recurse => true,
        source => "puppet:///modules/common_files/ceph_files",
        require => Exec['alcatraz_ceph_install'],
        owner  => $hazelcast_user,
        group  => $hazelcast_group,
    }

    file { "$apps_dir/config":
        ensure => 'directory',
        require => File["/etc/ceph"],
        owner  => $hazelcast_user,
        group  => $hazelcast_group,
    }

    file { "$apps_dir/config/keystore/":
        ensure => directory,
        owner => "$hazelcast_user",
        group => "$hazelcast_group",
        recurse => true,
        source => "puppet:///modules/common_files/townsend/keystore/",
        require => File["$apps_dir/config"],
    }   

    file { "/etc/ssl/node-0-keystore.jks":
        ensure => present,
        owner => "$hazelcast_user",
        group => "$hazelcast_group",
        source => "puppet:///modules/common_files/es_certs/node-0-keystore.jks",
        require => File["$apps_dir/config/keystore/"],
    }

    file { "/etc/ssl/truststore.jks":
        ensure  => present,
        owner   => "$hazelcast_user",
        group   => "$hazelcast_group",
        source  => "puppet:///modules/common_files/es_certs/truststore.jks",
        require => File["/etc/ssl/node-0-keystore.jks"],
    }

    file { "/data1/notification":
        ensure  => directory,
        owner   => $hazelcast_user,
        group   => $hazelcast_group,
        require => File["/etc/ssl/truststore.jks"],
    }

    file { "/data1/notification/100_Puffery_Email_Violation.txt":
        ensure  => present,
        mode    => 0700,
        source  => "puppet:///modules/hazelcast_birthing/100_Puffery_Email_Violation.txt",
        owner   => "$hazelcast_user",
        group   => "$hazelcast_group",
        require => File["/data1/notification"],
    }

    file { "$hazelcast_home/conf/cluster.xml":
        content => template('hazelcast_birthing/cluster.xml.erb'),
        require => File["/data1/notification/100_Puffery_Email_Violation.txt"],
        owner  => $hazelcast_user,
        group  => $hazelcast_group,
    }

    file { "$haz_log_dir":
        ensure  => directory,
        recurse => true,
        owner   => "$hazelcast_user",
        group   => "$hazelcast_group",
        require => File["${hazelcast_home}/conf/cluster.xml"],
    }

    file { "/data1/tmp":
        ensure  => directory,
        owner 	=> "$hazelcast_user",
        group 	=> "$hazelcast_group",
        require => File["$haz_log_dir"],
    }

    file { "$heapdump_file_path":
        ensure  => directory,
        recurse => true,
        owner   => "$hazelcast_user",
        group   => "$hazelcast_group",
        require => File["/data1/tmp"],
    }

    file { "$hazelcast_home/bin/start.sh":
        ensure => present,
        mode    => 0777,
        content => template('hazelcast_birthing/start.sh.erb'),
        require => File["$heapdump_file_path"],
        owner  => $hazelcast_user,
        group  => $hazelcast_group,
    }

    file { "/lib/systemd/system/hazelcast.service":
        ensure => present,
        mode => "0755",
        content => template('hazelcast_birthing/hazelcast_service.erb'),
        require => File["${hazelcast_home}/bin/start.sh"],
    }

    exec { "chown_${hazelcast_user}":
        command => "ls -l /usr/lib | egrep \"sysops\" | awk '{print \$NF}' | xargs -I{} chown -R ${hazelcast_user}:${hazelcast_group} {} /usr/lib/librados*",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/usr/lib",
        require => File["/lib/systemd/system/hazelcast.service"],
    }

    file { "$hazelcast_home/conf/zookeeper.cfg":
        ensure   => present,
        mode     => "0644",
        content => template('hazelcast_birthing/zookeeper_cfg.erb'),
        require  => Exec["chown_${hazelcast_user}"],
    }

    file { "${apps_dir}/hazelcast":
        ensure  => 'link',
        owner   => "${hazelcast_user}",
        target  => "${hazelcast_home}",
        require => File["${hazelcast_home}"],
    }

}

