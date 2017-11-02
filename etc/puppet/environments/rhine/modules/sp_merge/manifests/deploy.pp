class sp_merge::deploy {

    include sp_merge

    package { 'python-pip':
        ensure => installed,
    }


    exec { 'kazoo_install':
        command => "/usr/bin/pip install kazoo" ,
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => Package['python-pip'],
    }


    Class['sp_merge'] -> Class['sp_merge::deploy']
    exec { "test_sp":
        cwd     => "/tmp/alcatraz_config",
        command => "/bin/bash /tmp/alcatraz_config/test_new_properties.sh ${sp_merge::zoo_host}:${sp_merge::zoo_port} $sp_merge::alcatraz_version | /usr/bin/tee test_property.log",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => [Class["sp_merge"],Exec['kazoo_install']],
    }

    exec { "deploy_sp":
        #command => "echo success ",
        command => "/bin/bash /tmp/alcatraz_config/deploy_new_properties.sh ${sp_merge::zoo_host}:${sp_merge::zoo_port} $sp_merge::alcatraz_version | /usr/bin/tee deploy_properties.log",
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        require => Exec["test_sp"],
        unless  => "grep -E -i 'Error uploading properties|server property missing' /tmp/alcatraz_config/test_property.log",
    }

}

