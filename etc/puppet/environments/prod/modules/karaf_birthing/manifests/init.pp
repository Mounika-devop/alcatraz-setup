class karaf_birthing($karaf_user, $karaf_group, $karaf_apps_dir, $karaf_home, $karaf_data_dir, $karaf_log_dir, $build_number, $zeromq_zip, $zeromq_version, $jzmq_tar, $java_home, $setenv_java_max_perm_mem, $kafka_zkservers, $temp_file_download_path, $nfs_path, $nfs_failed_xml_path, $karaf_dumppath) {

    $lib_files = ["libboost-regex1.58", "libboost-thread1.58" , "libcrypto++9v5"]
    $karaf_package_id = "karaf_${build_number}.tar.gz"
    $ceph_package = "alceph_${build_number}_amd64.deb"
    $java_home_jars = "${java_home}/jre/lib/security"


    file {"$karaf_home":
        ensure  => "directory",
        owner   => "$karaf_user",
        group   => "$karaf_group",
    }

    file { "$karaf_data_dir":
        ensure  => directory,
        recurse => true,
        owner   => $karaf_user,
        group   => $karaf_group,
        require => File["$karaf_home"],
    }

    file { "$temp_file_download_path":
        ensure  => directory,
        recurse => true,
        owner   => $karaf_user,
        group   => $karaf_group,
        require => File["$karaf_data_dir"],
    }

    file { "$temp_file_download_path/tika":
        ensure  => directory,
        recurse => true,
        owner   => $karaf_user,
        group   => $karaf_group,
        require => File["$temp_file_download_path"],
    }

    file { "$karaf_log_dir":
        ensure  => directory,
        recurse => true,
        owner   => $karaf_user,
        group   => $karaf_group,
        require => File["$temp_file_download_path/tika"],
    }

    file { "/data1/notification":
        ensure   => directory,
        owner => $karaf_user,
        group => $karaf_group,
        require  => File["$karaf_log_dir"],
    }

    file { "/data1/notification/100_Puffery_Email_Violation.txt":
        ensure  => present,
        mode    => 0700,
        source  => "puppet:///modules/karaf_birthing/100_Puffery_Email_Violation.txt",
        owner   => "$karaf_user",
        group   => "$karaf_group",
        require => File["/data1/notification"],
    }

    file {"/etc/ceph":
        ensure => directory,
        recurse => true,
        source => "puppet:///modules/common_files/ceph_files",
        require => File["/data1/notification/100_Puffery_Email_Violation.txt"],
    }

    file {"$karaf_apps_dir/config":
        ensure => 'directory',
        #	require => File["/usr/lib/"],
        require => File["/etc/ceph"],
    }

    file {"$karaf_apps_dir/config/keystore/":
        ensure => directory,
        owner => "$karaf_user",
        group => "$karaf_group",
        recurse => true, 
        source => "puppet:///modules/common_files/townsend/keystore/",
        #source => "${path_to_townsend_keystore}",
        require => File["$karaf_apps_dir/config"],
    }

    file { "/etc/ssl/node-0-keystore.jks":
        ensure  => present,
        owner   => "$karaf_user",
        group   => "$karaf_group",
        source  => "puppet:///modules/common_files/es_certs/node-0-keystore.jks",
        require => File["$karaf_apps_dir/config/keystore/"],
    }

    file { "/etc/ssl/truststore.jks":
        ensure  => present,
        owner   => "$karaf_user",
        group   => "$karaf_group",
        source  => "puppet:///modules/common_files/es_certs/truststore.jks",
        require => File["/etc/ssl/node-0-keystore.jks"],
    }


    file { "$karaf_apps_dir/$zeromq_zip":
        ensure => present,     
        source => "puppet:///modules/common_files/package/$zeromq_zip",
        require => File["/etc/ssl/truststore.jks"],
    }

    exec { 'unzip_zeromq_zip':     
        command => "sudo unzip -o $karaf_apps_dir/$zeromq_zip",
        cwd     => "$karaf_apps_dir",     
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$karaf_apps_dir/$zeromq_zip"],
    }

    file {"$karaf_apps_dir/$jzmq_tar":
        ensure => present,     
        source => "puppet:///modules/common_files/package/$jzmq_tar",
        require => Exec["unzip_zeromq_zip"],
    }

    exec { 'untar_jzmq_tar':     
        command => "sudo tar -xvf $karaf_apps_dir/$jzmq_tar",
        cwd     => "$karaf_apps_dir",     
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$karaf_apps_dir/$jzmq_tar"],
    }

    file { "$karaf_home_dir/$ceph_package":
        ensure => present,     
        source => "puppet:///modules/common_files/build/$build_number/$ceph_package",
        require => Exec['untar_jzmq_tar'],
    }

    package { "$ceph_package":
        provider => dpkg,
        ensure => installed,
        source => "$karaf_home_dir/$ceph_package",
        require => File["$karaf_home_dir/$ceph_package"],
    }

    file {"$karaf_home/$karaf_package_id":
        ensure => present,
        source => "puppet:///modules/common_files/build/$build_number/$karaf_package_id",
        require =>  Package["$ceph_package"],
    }

    exec {'karaf_install':
        command => "tar -xzf $karaf_home/$karaf_package_id",
        cwd     => "$karaf_home",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$karaf_home/$karaf_package_id"],
    }


    file {"$karaf_home/bin/setenv":
        ensure  => present,
        owner   => "$karaf_user",
        group   => "$karaf_group",
        content => template('karaf_birthing/setenv.erb'),
        require => Exec["karaf_install"],
    }

    file {"$karaf_home/etc/org.ops4j.pax.logging.cfg":
        ensure => present,
        mode    => 0777,
        content => template('karaf_birthing/org.ops4j.pax.logging.cfg.erb'),
        #source => "puppet:///modules/karaf_birthing/org.ops4j.pax.logging.cfg",
        require => File["${karaf_home}/bin/setenv"],
    }

    exec { "chown_${karaf_home}":
        command => "chown -R ${karaf_user}:${karaf_group} ${karaf_home}",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => File["$karaf_home/etc/org.ops4j.pax.logging.cfg"],
    }

    file { "/etc/systemd/system/karaf.service":
        ensure => present,
        mode => "0755",
        content => template('karaf_birthing/karaf_service.erb'),
        require => Exec["chown_${karaf_home}"],
    }

    exec { "iptables_443_redirect":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to 2443",
        require => File["/etc/systemd/system/karaf.service"],
    }

    exec { "changing_jetty_port":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "sed -i -e 's/>443</>2443</g' ${karaf_home}/etc/jetty.xml",
        require => Exec["iptables_443_redirect"],
    }

    package { "iptables-persistent":
        ensure => installed,
        require => Exec["changing_jetty_port"],
    }

    exec { "iptables_save":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "iptables-save > /etc/iptables/rules.v4",
        require => Package["iptables-persistent"],
    }

    file { '/tmp/help.zip':
        ensure  => present,
        source  => "puppet:///modules/common_files/build/$build_number/help.zip",
        require => Exec["iptables_save"],
    }

    exec { 'extract_help_dir':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "/usr/bin/unzip -o /tmp/help.zip -d ${karaf_home}/",
        cwd     => "$karaf_home",
        require => File['/tmp/help.zip'],
    }

    file { "$karaf_home/help":
        ensure => directory,
        owner   => $karaf_user, 
        group   => $karaf_group,
        require => Exec["extract_help_dir"],
    }

    file { "$karaf_dumppath":
        ensure  => directory,
        owner   => $karaf_user, 
        group   => $karaf_group,
        require => File["$karaf_home/help"],
    }

    file { "$karaf_home/bin/karaf":
        ensure  => present,
        mode    => 0755,
        owner   => $karaf_user,
        group   => $karaf_group,
        content => template('karaf_birthing/karaf.erb'),
        require => File["$karaf_dumppath"],
    }

    file { "$karaf_home/etc/actiance/apc-system/apc-config/zookeeper.cfg":
        ensure  => present,
        mode    => 0644,
        owner   => $karaf_user,
        group   => $karaf_group,
        content => template('karaf_birthing/zookeeper_cfg.erb'),
        require => File["$karaf_home/bin/karaf"],
    }

    #######  This is only for JPMC Environments #######

    file { "${karaf_home}/etc/security/.keystore":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/.keystore",
        owner   => "root",
        group   => "root",
        require => File["$karaf_home/etc/actiance/apc-system/apc-config/zookeeper.cfg"],
    }

    file { "${karaf_home}/etc/security/.ssokeystore":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/.ssokeystore",
        owner   => "root",
        group   => "root",
        require => File["${karaf_home}/etc/security/.keystore"],
    }

    file { "${karaf_home}/etc/security/DRClientCert":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/DRClientCert",
        owner   => "root",
        group   => "root",
        require => File["${karaf_home}/etc/security/.ssokeystore"],
    }

    file { "${karaf_home}/etc/security/DRServerTruststore":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/DRServerTruststore",
        owner   => "root",
        group   => "root",
        require => File["${karaf_home}/etc/security/DRClientCert"],
    }

    file { "${karaf_home}/etc/security/ssosign-public.cer":
        ensure  => present,
        mode    => 0644,
        source  => "puppet:///modules/common_files/security/ssosign-public.cer",
        owner   => "root",
        group   => "root",
        require => File["${karaf_home}/etc/security/DRServerTruststore"],
    }

}

