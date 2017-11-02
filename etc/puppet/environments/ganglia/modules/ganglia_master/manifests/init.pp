class ganglia_master($haz_hosts,$stm_hosts,$karaf_hosts,$nfs_hosts,$mdb_hosts,$ess_hosts,$essr_hosts,$kaf_hosts,$egw_hosts,$kdig_hosts,$cmon_hosts,$cdep_hosts,$crad_hosts,$cosd_hosts,$kib_hosts) {

    $ganglia_packages = ['ganglia-monitor','rrdtool','gmetad','ganglia-webfrontend']
    package { $ganglia_packages:
        ensure => installed,
    }

    exec { 'ganglia_default_conf':
        command => "cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => Package[$ganglia_packages],
    }

    file { '/etc/ganglia/gmetad.conf':
        content => template('ganglia_master/gmetad.conf.erb'),
        mode    => 0644,
        require => Exec['ganglia_default_conf'],
    }

    file { '/etc/ganglia/gmond.conf':
        content => template('ganglia_master/gmond.conf.erb'),
        mode    => 0644,
        require => File['/etc/ganglia/gmetad.conf'],

    }
    
    service { 'ganglia-monitor':
       ensure       => running,
       enable       => true,
       provider     => systemd,
       require      => File['/etc/ganglia/gmond.conf'],
    }

    service { 'gmetad':
        ensure   => running,
        enable   => true,
        provider => systemd,
        require  => Service['ganglia-monitor'],
    }

    service { 'apache2':
        ensure   => running,
        provider => upstart,
        require  => Service['gmetad'],
    }

}
