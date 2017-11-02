class mongos::common {

    $common_packages = [ 'python', 'openssl', 'libboost-regex1.58.0', 'libgoogle-glog0v5', 'libtbb2', 'librados2', 'librados-dev', 'software-properties-common', 'libboost-thread1.58', 'unzip' ]

    package { $common_packages:
        ensure   => 'installed',
    }

    file { "/usr/lib/librados.so":
        ensure  => 'link',
        target  => '/usr/lib/x86_64-linux-gnu/librados.so.2.0.0',
        require => Package[$common_packages],
    }


#    exec { 'add-webupd8-repo':
#        command => "echo -ne \"\r\" | sudo add-apt-repository ppa:webupd8team/java",
#        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
#        require => File["/usr/lib/librados.so"],
#    }
#
#    exec { 'apt-update':
#        command => 'sudo apt-get update',
#        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
#        require => Exec["add-webupd8-repo"],
#    }
#
#    exec {
#        'set-licence-selected':
#            command => 'echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections',
#            path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
#        'set-licence-seen':
#            command => 'echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections',
#            path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
#    }
#
#    package { 'oracle-java8-installer':
#        ensure  => present,
#        require => [Exec['apt-update'],Exec['add-webupd8-repo'], Exec['set-licence-selected'], Exec['set-licence-seen']],
#    }
#
#    package {
#        'oracle-java8-set-default':
#            ensure  => installed,
#            require => Package['oracle-java8-installer'],
#    }
#
#    file { "/usr/lib/jvm/java-8-oracle/jre/lib":
#        ensure  => directory,
#        require => Package["oracle-java8-set-default"],
#    }
}

