class zookeeper($zookeepr_dir, $zoo_port, $tick_time, $init_limit, $sync_limit, $zoo_data_dir, $servers, $zoo_minmem, $zoo_maxmem, $zoo_myid_nodeno, $zoo_log_dir, $zookeeper_user, $zookeeper_group){

#### Ensure python is installed
    package {
        'software-properties-common':
            ensure => installed;
        'python-software-properties':
            ensure => installed;
    }

#### Ensure JAva package is installed
    exec { 'add-webupd8-repo':
        command => 'sudo add-apt-repository ppa:webupd8team/java',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        notify => Exec["apt-update"],
    }

    exec { 'apt-update':
        command => 'sudo apt-get update',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
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
        ensure => present,
        require => [Exec["apt-update"], Exec['add-webupd8-repo'], Exec['set-licence-selected'], Exec['set-licence-seen']],
    }

    package { 'oracle-java8-set-default':
        ensure => installed,
            require => Package['oracle-java8-installer'],
    }

################# Ensure user and group are present
    user { $zookeeper_user:
         ensure     => present,
         managehome => true,
         home       => "/apps",
         shell      => "/bin/false",
         gid        => $zookeeper_group,
         require    => Group[$zookeeper_group],
       }
       
    group { $zookeeper_group:
         ensure => present,
    }


####Create Zookeeper directory
    exec { "mkdir_p_${zookeepr_dir}":
         path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "mkdir -p ${zookeepr_dir} ${kafka_syslog_dir} ${zoo_log_dir}",
    }

####Copy zookeeper package from source
    file {"$zookeepr_dir":
       ensure => directory,
       recurse => true,
       source => "puppet:///modules/common_files/package/zookeeper-3.4.6",
       require => [Package['oracle-java8-set-default'], Exec["mkdir_p_${zookeepr_dir}"]]
    }

###Create Zookeeper conf file 
    file { "$zookeepr_dir/conf/zoo.cfg":
            ensure => present,
            content => template('zookeeper/zoo.cfg.erb'),
            require => File[$zookeepr_dir],
    }

###Create Zookeeper file to setup an environment
    file {"$zookeepr_dir/conf/java.env":
        ensure => present,
            content => template('zookeeper/java.env.erb'),
            require => File[$zookeepr_dir],
    }

    exec { "exec_perm_zoo_bin":
        command => "chmod a+x $zookeepr_dir/bin/*.sh",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$zookeepr_dir/conf/java.env"],
    }


###Create Zookeeper log file 
    file {"$zoo_log_dir":
            ensure => directory,
            owner => "$zookeeper_user",
            group => "$zookeeper_group",
             mode => 755,
            require => File[$zookeepr_dir],
    }


    ####Create Zookeeper Service
    file { "/lib/systemd/system/zookeeper.service":
         ensure => present,
         mode => "0755",
         content => template('zookeeper/zookeeper_service.erb'),
         require => [File["${zookeepr_dir}/conf/zoo.cfg"], Exec["exec_perm_zoo_bin"]],
    }

    ### Create dir for myid
    file { "$zoo_data_dir":
         ensure => directory,
         recurse => true,
         owner => "$zookeeper_user",
         group => "$zookeeper_group",
         mode   => "0777",
         require => File["${zookeepr_dir}/conf/zoo.cfg"],
    }

    ### Create Mypid file
    file {"$zoo_data_dir/myid":
         ensure => present,
       #  owner => "$zookeeper_user",
       # group => "$zookeeper_group",
         mode   => "0777",
         content => "$zoo_myid_nodeno",
         require => File["$zoo_data_dir"],
    }

    file { "/apps/zookeeper":
        ensure  => link,
        target  => "/apps/zookeeper-3.4.6",
        require => File["$zoo_data_dir/myid"],
    }

    ################ Start Zookeeper
    service { 'zookeeper':
            ensure      => running,
            provider    => 'systemd',
            enable      => true,
            require     => [File['/lib/systemd/system/zookeeper.service'], File["/apps/zookeeper"]],
    }
}
