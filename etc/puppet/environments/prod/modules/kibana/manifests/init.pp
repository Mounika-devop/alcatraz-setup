class kibana($kibana_version, $nginx_version, $nginx_log_dir, $essr_host, $certs_dir, $nginx_port, $kibana_port, $base64_credentials, $dns_ip, $es_user, $es_paswd, $ssl_verify, $kibana_home, $kibana_log_dir, $report_domain) {
   package { 'libpcre3':
      ensure => installed,
      #    require => Package['oracle-java8-set-default'],
   }
   package { 'Lua5.1':
      ensure => installed,
      require => Package['libpcre3'],
   }
   file { "/tmp/nginx-${nginx_version}.deb":
        ensure  => present,
        source  => "puppet:///modules/kibana/nginx-${nginx_version}-amd64.deb",
        require => Package['Lua5.1']
    }

    package { "nginx":
        provider => dpkg,
        ensure   => installed,
        source   => "/tmp/nginx-${nginx_version}.deb",
        require  => File["/tmp/nginx-${nginx_version}.deb"],
    }

    file { "$certs_dir":
        ensure  => directory,
        recurse => true,
        source  => "puppet:///modules/kibana/certs",
    }

    file { "$nginx_log_dir":
        ensure => directory,
		require => File["$certs_dir"],
    }

    file { "$kibana_log_dir":
        ensure => directory,
        owner   => "kibana",
        group   => "kibana",
        mode    => 755,
		require => File["$nginx_log_dir"],
    }

	file { "/usr/local/nginx/nginx.conf":
        mode    => 0644,
        ensure  => present,
        content => template('kibana/nginx.conf.erb'),
		require => Package["nginx"],
    }

	file { "/lib/systemd/system/nginx.service":
        mode     => 0644,
        ensure   => present,
        source   => "puppet:///modules/kibana/nginx.service",
        require  => File["/usr/local/nginx/nginx.conf"],
    }

  exec { "touch_nginx_access_log":
	   command => "/usr/bin/touch /logs/nginx/kibana.access.log",
	   cwd => "/logs/nginx",
	   require => File["/lib/systemd/system/nginx.service"],
	}

	service { "nginx":
        ensure   => running,
        provider => "systemd",
        require  => Exec["touch_nginx_access_log"],
  }

	file { "/tmp/kibana-${kibana_version}.deb":
        ensure  => present,
        source  => "puppet:///modules/kibana/kibana-${kibana_version}-amd64.deb",
    }

	package { "kibana":
        provider => dpkg,
        ensure   => installed,
        source   => "/tmp/kibana-${kibana_version}.deb",
        require  => File["/tmp/kibana-${kibana_version}.deb"],
    }

	file { "$kibana_home/config/kibana.yml":
        mode    => 0644,
        ensure  => present,
        content => template('kibana/kibana.yml.erb'),
        require => Package["kibana"],
  }

  file { "$kibana_home/optimize/bundles/commons.bundle.js":
        mode  => 0644,
        ensure => present,
        source => "puppet:///modules/kibana/bundlejs/commons.bundle.js",
        require => File["$kibana_home/config/kibana.yml"]
  }

  file { "$kibana_home/optimize/bundles/kibana.bundle.js":
        mode  => 0644,
        ensure => present,
        source => "puppet:///modules/kibana/bundlejs/kibana.bundle.js",
        require => File["$kibana_home/optimize/bundles/commons.bundle.js"]
  }

  file { "$kibana_home/src/ui/views/ui_app.jade":
        mode  => 0644,
        ensure => present,
        source => "puppet:///modules/kibana/ui_app.jade",
        require => File["$kibana_home/optimize/bundles/kibana.bundle.js"]
  }

  file { "$kibana_home/NOTICE.txt":
        mode  => 0644,
        ensure => present,
        source => "puppet:///modules/kibana/NOTICE.txt",
        require => File["$kibana_home/src/ui/views/ui_app.jade"]
  }

  file { "$kibana_log_dir/kibana.log":
       ensure  => present,
       owner   => "kibana",
       group   => "kibana",
       mode    => 644,
       require => File["$kibana_home/NOTICE.txt"],
    }

	service { "kibana":
        ensure   => running,
        provider => "systemd",
        require  => Package["kibana"],
    }

}
