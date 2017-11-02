class ganglia_agent {
    package { 'ganglia-monitor':
        ensure => installed,
    }

    file { '/usr/lib/ganglia/python_modules':
        ensure => directory,
        require => Package['ganglia-monitor'],
    }

    file { '/usr/lib/ganglia/python_modules/diskstat.py':
        ensure => present,
        source => 'puppet:///modules/ganglia_agent/diskstat.py',
        require => File['/usr/lib/ganglia/python_modules'],
    }

    file { '/etc/ganglia/conf.d':
        ensure => directory,
        require => File['/usr/lib/ganglia/python_modules/diskstat.py'],
    }

    file { '/etc/ganglia/conf.d/modpython.conf':
        ensure => present,
        source => 'puppet:///modules/ganglia_agent/modpython.conf',
        require => File['/etc/ganglia/conf.d'],
    }

    file { '/etc/ganglia/conf.d/diskstat.pyconf':
        ensure => present,
        source => 'puppet:///modules/ganglia_agent/diskstat.pyconf',
        require => File['/etc/ganglia/conf.d/modpython.conf'],
		notify => Service['ganglia-monitor'],
    }
   
    service { 'ganglia-monitor':
		ensure => running,
		enable => true,
		provider => "systemd",
		require => File['/etc/ganglia/conf.d/diskstat.pyconf'],
    }

	file { '/etc/ganglia/gmond.conf':
		ensure  => present,
		content => template('ganglia_agent/gmond.conf.erb'),
		notify  => Service["ganglia-monitor"],
	}
}
