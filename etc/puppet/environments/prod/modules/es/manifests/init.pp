class es ($es_user, $es_version, $data_dir, $log_dir, $ess_hosts, $build_number, $cluster_name) {

    user { $es_user:
		ensure     => present,
		managehome => true,
		home       => "/apps",
		shell      => "/bin/false",
		gid        => $es_user,
		require    => Group[$es_user],
	}

    group { $es_user:
        ensure  => present,
    }

    package { 'unzip':
        ensure  => present,
        require => User["$es_user"],
    }
   
    package { 'software-properties-common':
	ensure => present,
        require => Package["unzip"],
    }

    exec { 'add-webupd8-repo':
        command => 'sudo add-apt-repository ppa:webupd8team/java',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => Package["software-properties-common"],
    }

    exec { 'apt-update':
        command => 'sudo apt-get update',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => Exec["add-webupd8-repo"],
        #notify => Exec["apt-update"]
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

    file { "/tmp/elasticsearch-${es_version}.deb":
        ensure  => present,
        source  => "puppet:///modules/es/elasticsearch-${es_version}.deb",
        require => Package['oracle-java8-set-default'],
    }

    package { "elasticsearch":
        provider => dpkg,
        ensure   => installed,
        source   => "/tmp/elasticsearch-${es_version}.deb",
        require  => File["/tmp/elasticsearch-${es_version}.deb"],
    }

    file { "/tmp/scripts_${build_number}.zip":
        ensure  => present,
        source  => "puppet:///modules/common_files/build/${build_number}/scripts_${build_number}.zip",
        require => Package["elasticsearch"],
    }

    exec { "extract_tokenizer":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/tmp",
        command => "unzip -o /tmp/scripts_${build_number}.zip -d /tmp",
        require => File["/tmp/scripts_${build_number}.zip"],
    }

    exec { "install_tokenizer":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/usr/share/elasticsearch/bin",
        command => "/usr/share/elasticsearch/bin/plugin install file:/tmp/scripts-distro/elasticsearch/actiance-standard-tokenizer-1.0.zip -verbose",
	unless  => "/usr/share/elasticsearch/bin/plugin list | grep actiance-standard-tokenizer",
        require => Exec["extract_tokenizer"],
    }

    exec { "install_search_guard_ssl_plugin":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/usr/share/elasticsearch/bin",
        command => "/usr/share/elasticsearch/bin/plugin install -b com.floragunn/search-guard-ssl/2.4.2.19 -verbose",
	unless  => "/usr/share/elasticsearch/bin/plugin list | grep search-guard-ssl",
        require => Exec["install_tokenizer"],
        #require => Package["elasticsearch"],
    }

    exec { "install_search_guard_2_plugin":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/usr/share/elasticsearch/bin",
        command => "/usr/share/elasticsearch/bin/plugin install -b com.floragunn/search-guard-2/2.4.2.9",
	unless  => "/usr/share/elasticsearch/bin/plugin list | grep search-guard-2",
        require => Exec["install_search_guard_ssl_plugin"],
    }

    exec { "install_head_plugin":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/usr/share/elasticsearch/bin",
        command => "/usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head -verbose",
	unless  => "/usr/share/elasticsearch/bin/plugin list | grep head",
        require => Exec["install_search_guard_2_plugin"],
    }

    file { "${data_dir}":
        ensure => directory,
        owner  => $es_user,
        group  => $es_user,
        require => Exec["install_head_plugin"],
    }

    file { "${log_dir}":
        ensure  => directory,
        owner   => $es_user,
        group   => $es_user,
        require => File["${data_dir}"],
    }

    file { "/etc/elasticsearch":
        ensure  => directory,
        owner   => $es_user,
        group   => $es_user,
        require => File["${log_dir}"],
    }

    file { "/etc/elasticsearch/node-0-keystore.jks":
        ensure  => present,
        owner   => $es_user,
        group   => $es_user,
        source  => "puppet:///modules/es/node-0-keystore.jks",
        require => File["/etc/elasticsearch"],
    }

    file { "/etc/elasticsearch/truststore.jks":
        ensure  => present,
        owner   => $es_user,
        group   => $es_user,
        source  => "puppet:///modules/es/truststore.jks",
        require => File["/etc/elasticsearch/node-0-keystore.jks"],
    }

    file { "/usr/share/elasticsearch/plugins/search-guard-2/sgconfig/sg_config.yml":
        ensure  => present,
        owner   => $es_user,
        group   => $es_user,
        source  => "puppet:///modules/es/sg_config.yml",
        require => File["/etc/elasticsearch/truststore.jks"],
    }

    file { "/usr/share/elasticsearch/plugins/search-guard-2/sgconfig/sg_internal_users.yml":
        ensure  => present,
        owner   => $es_user,
        group   => $es_user,
        source  => "puppet:///modules/es/sg_internal_users.yml",
        require => File["/etc/elasticsearch/node-0-keystore.jks"],
    }

    file { "/etc/elasticsearch/elasticsearch.yml":
        mode    => 0600,
        ensure  => present,
        owner   => $es_user,
        group   => $es_user,
        content => template('es/elasticsearch.yml.erb'),
        require => File["/usr/share/elasticsearch/plugins/search-guard-2/sgconfig/sg_internal_users.yml"],
    }

    file { "/data1/heapdump":
        ensure  => directory,
        owner   => $es_user,
        group   => $es_user,
        require => File["/etc/elasticsearch/elasticsearch.yml"],
    }

    file { "/lib/systemd/system/elasticsearch.service":
        mode   	 => 0644,
        ensure   => present,
	source   => "puppet:///modules/es/elasticsearch.service",
	require  => File["/data1/heapdump"],
    }

    file { "/etc/init.d/elasticsearch":
        mode	=> 0755,
        ensure	=> present,
        source  => "puppet:///modules/es/elasticsearch",
        require => File["/lib/systemd/system/elasticsearch.service"],
    }

    file { "/usr/share/elasticsearch/bin/elasticsearch.in.sh":
        mode    => 0755,
        ensure  => present,
        content => template('es/elasticsearch.in.sh.erb'),
        require => File["/etc/init.d/elasticsearch"],
    }

    exec { 'es_perm':
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        command => "/bin/chown -v -R appsuser:appsuser /etc/elasticsearch",
        require => File["/usr/share/elasticsearch/bin/elasticsearch.in.sh"],
    }

    service { "elasticsearch":
        ensure   => running,
        provider => "upstart",
        enable   => true,
        require  => Exec["es_perm"],
    }

}
