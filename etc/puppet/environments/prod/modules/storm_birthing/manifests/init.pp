class storm_birthing($build_number, $storm_user, $storm_group, $data_dir, $storm_data_dir, $log_dir ,$storm_log_dir, $apps_dir ,$storm_version ,$zeromq_zip ,$zeromq_version ,$jzmq_tar , $java_home_jars, $storm_zookeper_servers , $storm_zookeeper_port, $nimbus_host, $nimbus_thrift_port, $supervisor_slots_ports ,$storm_worker_childopts_xms,$storm_worker_childopts_xmx, $storm_ui_childopts_xms, $storm_ui_childopts_xmx, $storm_ui_port, $kafzoo_brokers, $kafzoo_zkservers, $nfs_path, $nfs_failed_xml_path)
{
    $ceph_package = "alceph_${build_number}_amd64.deb"
    $storm_build_zip = "storm_${build_number}.zip"
    $storm_home_dir = "/apps/${storm_version}"

    #create directories
    #$directory_list1 = ["$data_dir","$storm_data_dir",]
    file {"$data_dir":
       ensure  => "directory",
       owner   => "$storm_user",
       group   => "$storm_group",   
    }

    #$directory_list2 = ["$log_dir","$storm_log_dir",]
    file {"$storm_data_dir":
       ensure  => "directory",
       owner   => "$storm_user",
       group   => "$storm_group",
       require => File["$data_dir"],
    }

    file { "$storm_log_dir":
       ensure => "directory",
       owner => "$storm_user",
       group => "$storm_group",
       require => File["$storm_data_dir"],
    }

    file { "$storm_home_dir":
             ensure  => "directory",
             owner   => "$storm_user",
             group   => "$storm_group",
             require => File["$storm_log_dir"],
    }

    ###### Copy ceph files to /etc/ceph
    ####ceph.client.admin.keyring ceph.conf keyring.radosgw.gateway rbdmap
    file { "/etc/ceph":
          ensure  => directory,
          recurse => true,
          source  => "puppet:///modules/common_files/ceph_files",
          require =>  File["$storm_home_dir"],
    }

    ##### Copy Townsend Keys
    file { "$apps_dir/config":
        ensure  => 'directory',
        recurse => true,
        #require => File["/usr/lib"],
        require => File["/etc/ceph"],
    }

    ####  Ensure townsend keystore owner is sysops/apcuser
    file {"$apps_dir/config/keystore/":
       ensure  => directory,
       owner   => "$storm_user",
       group   => "$storm_group",
       recurse => true, 
       source  => "puppet:///modules/common_files/townsend/keystore",
       require => File["$apps_dir/config"],
    }

    file { "/etc/ssl/node-0-keystore.jks":
       ensure => present,
       owner => "$storm_user",
       group => "$storm_group",
       #recurse => true,
       source => "puppet:///modules/common_files/es_certs/node-0-keystore.jks",
       require => File["$apps_dir/config/keystore/"],
    }

    file { "/etc/ssl/truststore.jks":
        ensure  => present,
        owner   => "$storm_user",
        group   => "$storm_group",
        source  => "puppet:///modules/common_files/es_certs/truststore.jks",
        require => File["/etc/ssl/node-0-keystore.jks"],
    }

    ##### Copy storm build zip to /home/sysops/apps/storm-0.9.0.1
    file { "$storm_home_dir/$storm_build_zip":
       ensure  => present,     
       source  => "puppet:///modules/common_files/build/$build_number/$storm_build_zip",
       require => File ["/etc/ssl/truststore.jks"],
    }

    ##### Unzip storm build zip in /home/sysops/apps/storm-0.9.0.1
    exec { 'unzip_storm_build_zip':     
        command => "sudo unzip -o  $storm_home_dir/$storm_build_zip",
        cwd     => "$storm_home_dir",     
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$storm_home_dir/$storm_build_zip"],
    }

    ##### Copy zermoq to /home/sysops/apps
    file { "$apps_dir/$zeromq_zip":
        ensure => present,     
        source => "puppet:///modules/common_files/package/$zeromq_zip",
        require => Exec["unzip_storm_build_zip"],
    }

    ##### Unzip zeromq zip in /home/sysops/apps
    exec { 'unzip_zeromq_zip':     
        command => "sudo unzip -o $apps_dir/$zeromq_zip",
        cwd     => "$apps_dir",     
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$apps_dir/$zeromq_zip"],
    }

    ##### Copy jzmq.tar apps dir 
    file { "$apps_dir/$jzmq_tar":
       ensure => present,     
       source => "puppet:///modules/common_files/package/$jzmq_tar",
       #source => "${file_path_to_jzmq_tar}",
       require => Exec["unzip_zeromq_zip"],
    }

	##### Untar jzmq tar in /home/sysops/apps
    exec { 'untar_jzmq_tar':     
        command => "sudo tar -xvf $apps_dir/$jzmq_tar",
        cwd     => "$apps_dir",     
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$apps_dir/$jzmq_tar"],
    }

	##### Make bash aliases changes
    file { "$apps_dir/.bash_aliases":
         ensure => present,
         mode => "0755",
         content => template('storm_birthing/bash_aliases.erb'),
         require =>  Exec["untar_jzmq_tar"],
    }

    file { '/etc/environment':
        ensure  => present,
        mode    => "0644",
        content => template('storm_birting/environment.erb'),
        require => File["$apps_dir/.bash_aliases"],
    }

	##### Update storm_home/conf/storm.yaml 
    file { "$storm_home_dir/conf/storm.yaml":
        ensure => present,
        content => template('storm_birthing/storm.yaml.erb'),
        require => File["$apps_dir/.bash_aliases"],
    }

	##### Update storm_home/logback/cluster.xml
    file { "$storm_home_dir/log4j2/cluster.xml":
        ensure => present,
        content => template('storm_birthing/cluster.xml.erb'),
        require => File["${storm_home_dir}/conf/storm.yaml"],
    }

    file { "$storm_home_dir/log4j2/worker.xml":
        ensure  => present,
        content => template('storm_birthing/worker.xml.erb'),
        require => File["$storm_home_dir/log4j2/cluster.xml"],
    }

	##### Update Storm server.properties file
    file {"$storm_home_dir/conf/server.properties":
          ensure => present,
          content => template('storm_birthing/server.properties.erb'),
          require => File["$storm_home_dir/log4j2/worker.xml"],
    }

    file { "/data1/tmp":
        ensure  => directory,
        owner   => "$storm_user",
        group   => "$storm_group",
        require => File["$storm_home_dir/conf/server.properties"],
    }

    file { "/data1/tmp/tika":
        ensure  => directory,
        owner   => "$storm_user",
        group   => "$storm_group",
        require => File["/data1/tmp"],
    }

    file { "/data1/notification":
        ensure => directory,
        owner   => "$storm_user",
        group   => "$storm_group",
        require => File["/data1/tmp/tika"],
    }

    file { "/data1/notification/100_Puffery_Email_Violation.txt":
        ensure  => present,
        mode    => 0700,
        source  => "puppet:///modules/storm_birthing/100_Puffery_Email_Violation.txt",
        owner   => "$storm_user",
        group   => "$storm_group",
        require => File["/data1/notification"],
    }

    file { "$storm_home_dir/$ceph_package":
       ensure  => present,     
       source  => "puppet:///modules/common_files/build/$build_number/$ceph_package",
       require => File["/data1/notification/100_Puffery_Email_Violation.txt"],
    }

    package { "$ceph_package":
        provider => dpkg,
        ensure => installed,
        source => "$storm_home_dir/$ceph_package",
        require => File["$storm_home_dir/$ceph_package"],
    }

    file { "/lib/systemd/system/stormnimbus.service":
         ensure  => present,
         mode    => "0755",
         content => template('storm_birthing/stormnimbus_service.erb'),
         require => Exec['ceph_install'],
    }

    file { "${storm_data_dir}/heapdump":
        ensure  => directory,
        owner   => "${storm_user}",
        group   => "${storm_user}",
        require => File["/lib/systemd/system/stormnimbus.service"],
    }

    file { "${storm_data_dir}/heapdump/nimbus":
        ensure  => directory,
        owner   => "${storm_user}",
        group   => "${storm_user}",
        require => File["${storm_data_dir}/heapdump"],
    }

    file { "${storm_data_dir}/heapdump/supervisor":
        ensure  => directory,
        owner   => "${storm_user}",
        group   => "${storm_user}",
        require => File["${storm_data_dir}/heapdump/nimbus"],
    }

    file { "${storm_data_dir}/heapdump/worker":
        ensure  => directory,
        owner   => "${storm_user}",
        group   => "${storm_user}",
        require => File["${storm_data_dir}/heapdump/supervisor"],
    }


    file { "/lib/systemd/system/stormsupervisor.service":
         ensure  => present,
         mode    => "0755",
         content => template('storm_birthing/stormsupervisor_service.erb'),
         require => File["${storm_data_dir}/heapdump/worker"],
    }

    file { "/lib/systemd/system/stormui.service":
        ensure  => present,
        mode    => "0755",
        content => template('storm_birthing/stormui_service.erb'),
        require => File["/etc/systemd/system/stormsupervisor.service"],

    }

    file { "${apps_dir}/storm":
        ensure  => 'link',
        owner   => "${storm_user}",
        target  => "${storm_home_dir}", 
        require => File['/etc/systemd/system/stormui.service'],
    }

    file { "${storm_home_dir}/security":
        ensure  => directory,
        owner   => "${storm_user}",
        group   => "${storm_user}",
        require => File["${apps_dir}/storm"],
    }

    file { "${storm_home_dir}/conf/zookeeper.cfg":
        ensure  => present,
        owner   => "${storm_user}",
        group   => "${storm_user}",
        content => template('storm_birthing/zookeeper_cfg.erb'),
        require => File["${apps_dir}/storm"],
    }

    file { "${storm_home_dir}/security/.keystore":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/.keystore",
        owner   => "root",
        group   => "root",
        require => File["${storm_home_dir}/conf/zookeeper.cfg"],
    }

    file { "${storm_home_dir}/security/.ssokeystore":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/.ssokeystore",
        owner   => "root",
        group   => "root",
        require => File["${storm_home_dir}/security/.keystore"],
    }

    file { "${storm_home_dir}/security/DRClientCert":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/DRClientCert",
        owner   => "root",
        group   => "root",
        require => File["${storm_home_dir}/security/.ssokeystore"],
    }

    file { "${storm_home_dir}/security/DRServerTruststore":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/DRServerTruststore",
        owner   => "root",
        group   => "root",
        require => File["${storm_home_dir}/security/DRClientCert"],
    }

    file { "${storm_home_dir}/security/ssosign-public.cer":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/ssosign-public.cer",
        owner   => "root",
        group   => "root",
        require => File["${storm_home_dir}/security/DRServerTruststore"],
    }

}
