node 'fab-dr01-mdb-h1' {
    class { 'mongodb':
        mongo_user   => 'appsuser',
        apps_dir     => "/apps",
        data_drive   => '/data1',
        dbpath       => '/data1/mongodb',
        logpath      => '/logs/mongodb',
        logpath_file => '/logs/mongodb/mongodb.log',
        port         => '23757',
        shardsvr     => 'true',
        logappend    => 'true',
        replSet      => 'dr01mongo',
    }
}
