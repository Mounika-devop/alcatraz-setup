class karaf_nfs_birthing($karaf_nfs_user, $karaf_nfs_group, $karaf_nfs_apps_dir, $karaf_nfs_home, $karaf_nfs_data_dir, $karaf_nfs_log_dir, $temp_file_download_path, $build_number, $zeromq_zip, $zeromq_version, $jzmq_tar, $java_home, $java_home_jars, $setenv_java_max_perm_mem, $kafka_zkservers, $nfs_path, $nfs_failed_xml_path, $karaf_nfs_dumppath) {

	$karaf_nfs_package_id = "karaf_with_exporter_monitor_${build_number}.tar.gz"
	$ceph_package = "alceph_${build_number}_amd64.deb"

	package { 'nfs-kernel-server':
		ensure => installed,
	}

    service { 'nfs-service':
        ensure   => running,
        provider => "systemd",
        require  => Package["nfs-kernel-server"],
    }

	file {"$karaf_nfs_home":
		ensure => "directory",
		owner => "$karaf_nfs_user",
		group => "$karaf_nfs_group",
		require => Package["nfs-kernel-server"],
	}

	file { "$karaf_nfs_data_dir":
		ensure  => directory,
		recurse => true,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => File["$karaf_nfs_home"],
	}

	file { '/data1/exportoutput':
		ensure  => directory,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => File["$karaf_nfs_data_dir"],
	}

	file { '/data1/tmp':
		ensure  => directory,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => File["/data1/exportoutput"],
	}

	file { '/data1/failedxml':
		ensure  => directory,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => File["/data1/tmp"],

	}

	file { '/data1/stormexports':
		ensure  => directory,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => File["/data1/failedxml"],

	}

	file { "$karaf_nfs_log_dir":
		ensure  => directory,
		recurse => true,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => File["/data1/stormexports"],
	}

	file {"/etc/ceph":
		ensure => directory,
		recurse => true,
		source => "puppet:///modules/common_files/ceph_files",
		require => File["$karaf_nfs_log_dir"],
	}

	file {"$karaf_nfs_apps_dir/config":
		ensure => 'directory',
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => File["/etc/ceph"],
	}

	file {"$karaf_nfs_apps_dir/config/keystore/":
		ensure => directory,
		owner => "$karaf_nfs_user",
		group => "$karaf_nfs_group",
		recurse => true, 
		source => "puppet:///modules/common_files/townsend/keystore/",
		require => File["$karaf_nfs_apps_dir/config"],
	}


	file { "/etc/ssl/node-0-keystore.jks":
		ensure  => present,
		owner   => "$karaf_nfs_user",
		group   => "$karaf_nfs_group",
		source  => "puppet:///modules/common_files/es_certs/node-0-keystore.jks",
		require => File["$karaf_nfs_apps_dir/config/keystore/"],
	}

	file { "/etc/ssl/truststore.jks":
		ensure  => present,
		owner   => "$karaf_nfs_user",
		group   => "$karaf_nfs_group",
		source  => "puppet:///modules/common_files/es_certs/truststore.jks",
		require => File["/etc/ssl/node-0-keystore.jks"],
	}


	file { "$karaf_nfs_apps_dir/$zeromq_zip":
		ensure => present,     
		source => "puppet:///modules/common_files/package/$zeromq_zip",
		require => File["/etc/ssl/truststore.jks"],
	}

	exec { 'unzip_zeromq_zip':     
		command => "sudo unzip -o  $karaf_nfs_apps_dir/$zeromq_zip",
		cwd     => "$karaf_nfs_apps_dir",     
		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
		require => File["$karaf_nfs_apps_dir/$zeromq_zip"],
	}

	file {"$karaf_nfs_apps_dir/$jzmq_tar":
		ensure => present,     
		source => "puppet:///modules/common_files/package/$jzmq_tar",
		require => Exec["unzip_zeromq_zip"],
	}

	exec { 'untar_jzmq_tar':     
		command => "sudo tar -xvf $karaf_nfs_apps_dir/$jzmq_tar",
		cwd     => "$karaf_nfs_apps_dir",     
		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
		require => File["$karaf_nfs_apps_dir/$jzmq_tar"],
	}

	file { "$karaf_nfs_home_dir/$ceph_package":
		ensure => present,     
		source => "puppet:///modules/common_files/build/$build_number/$ceph_package",
		require => Exec['untar_jzmq_tar'],
	}

	package { "$ceph_package":
		provider => dpkg,
		ensure => installed,
		source => "$karaf_nfs_home_dir/$ceph_package",
		require => File["$karaf_nfs_home_dir/$ceph_package"],
	}

	file {"$karaf_nfs_home/$karaf_nfs_package_id":
		ensure => present,
		source => "puppet:///modules/common_files/build/$build_number/$karaf_nfs_package_id",
		require => Package["$ceph_package"],
	}

	exec {'karaf_nfs_install':
		command => "tar -xzf $karaf_nfs_home/$karaf_nfs_package_id",
		cwd     => "$karaf_nfs_home",
		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
		require => File["$karaf_nfs_home/$karaf_nfs_package_id"],
	}

	file {"$karaf_nfs_home/bin/setenv":
		ensure  => present,
		owner         => "$karaf_nfs_user",
		group         => "$karaf_nfs_group",
		content => template('karaf_nfs_birthing/setenv.erb'),
		require        => Exec["karaf_nfs_install"],
	}

	file {"$karaf_nfs_home/etc/org.ops4j.pax.logging.cfg":
		ensure => present,
		mode    => 0777,
		content => template('karaf_nfs_birthing/org.ops4j.pax.logging.cfg.erb'),
		require => File["${karaf_nfs_home}/bin/setenv"],
	}

	exec { "chown_${karaf_nfs_home}":
		command => "chown -R ${karaf_nfs_user}:${karaf_nfs_group} $karaf_nfs_home",
		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
		require => File["$karaf_nfs_home/etc/org.ops4j.pax.logging.cfg"],
	}

	file { "/lib/systemd/system/karaf.service":
		ensure => present,
		mode => "0755",
		content => template('karaf_nfs_birthing/karaf_service.erb'),
		require => Exec["chown_${karaf_nfs_home}"],
	}

	exec { "iptables_443_redirect":
		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
		command => "iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to 2443",
		require => File["/lib/systemd/system/karaf.service"],
	}

	exec { "changing_jetty_port":
		path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
		command => "sed -i -e 's/>443</>2443</g' ${karaf_nfs_home}/etc/jetty.xml",
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

	file { "$karaf_nfs_dumppath":
		ensure  => directory,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		require => Exec["iptables_save"],
	}


	file { "$karaf_nfs_home/bin/karaf":
		ensure      => present,
		mode        => 0755,
		owner       => $karaf_nfs_user,
		group       => $karaf_nfs_group,
		content     => template('karaf_birthing/karaf.erb'),
		require     => File["$karaf_nfs_dumppath"],
	}

	file { "$karaf_nfs_home/etc/actiance/apc-system/apc-config/zookeeper.cfg":
		ensure  => present,
		mode    => 0644,
		owner   => $karaf_nfs_user,
		group   => $karaf_nfs_group,
		content => template('karaf_birthing/zookeeper_cfg.erb'),
		require => File["$karaf_nfs_home/bin/karaf"],
	}

    file { "/etc/exports":
        ensure  => present,
        mode    => 0644,
        owner   => root,
        group   => root,
        source  => "puppet:///modules/karaf_nfs_birthing/exports",
        require => File["$karaf_nfs_home/etc/actiance/apc-system/apc-config/zookeeper.cfg"],
        notify  => Service["nfs-server"],
    }

}


