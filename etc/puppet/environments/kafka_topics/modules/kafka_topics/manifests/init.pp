class kafka_topics($zoo_hosts,$zoo_port) {
    package { 'unzip':
        ensure => present,
    }

    file { '/tmp/create_topics.sh':
        ensure  => present,
        mode    => 0755,
        content => template('kafka_topics/sample.sh.erb'),
        require => Package["unzip"],
    }

    exec { "create_topics":
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        cwd     => "/tmp",
        command => "/bin/bash /tmp/create_topics.sh",
        require => File['/tmp/create_topics.sh'],
    }
}
