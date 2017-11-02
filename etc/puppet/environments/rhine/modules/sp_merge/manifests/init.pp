class sp_merge($build_number,$alcatraz_version,$fabrics,$zoo_host,$zoo_port) {
    
    ###  defining variable which is build specific alctrazconfig deb ###
    $alcatrazconfig_deb = "alcatrazconfig_${build_number}_amd64.deb"
    #$fabrics = ['hazelcast','karaf']
    $fabdir = "/tmp/$alcatraz_version"
    ### Downloading alctrazconfig debian package which has alcatraz version details ###
    file { "/tmp/$alcatrazconfig_deb":
        ensure => present,
        source => "puppet:///modules/common_files/builds/$build_number/alcatrazconfig_${build_number}_amd64.deb",
    }

    package { "alcatrazconfig":
        ensure   => installed,
        provider => dpkg,
        source   => "/tmp/$alcatrazconfig_deb",
        require  => File["/tmp/$alcatrazconfig_deb"],
    }

    file { "/tmp/product-build.info":
        ensure  => present,
        source  => "puppet:///modules/common_files/builds/$build_number/product-build.info",
        require => Package["alcatrazconfig"],
    }

    define fabric {
        file { "$title":
            name => $operatingsystem ? {
                default => "/tmp/$alcatraz_version/$title.server.properties",
            },
           require => File["/tmp/product-build.info"],
        }
    }

    fabric { $fabrics: }

    #    exec { "deploy_sp":
    #   cwd     => "/tmp/alcatraz_config",
        #command => "/bin/bash /tmp/alcatraz_config/deploy_new_properties.sh $zoo_host $alcatraz_version",
        #    command => "ls -ltrh /home/sysops",
        #path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
        #unless  => "/bin/bash /tmp/alcatraz_config/test_new_properties.sh $zoo_host $alcatraz_version",
        #require => Augeas["karaf"],
        #}


}
