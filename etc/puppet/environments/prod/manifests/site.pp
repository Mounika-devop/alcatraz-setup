node 'fab-dr01-kaf-h2','fab-dr01-kaf-h3','fab-dr01-kaf-h4'  {
    class { 'kafka':
        kafka_user_home                 => "/apps",
        kafka_dir                       => "/apps/kafka_2.11-0.11.0.0",
        kafka_link                      => "/apps/kafka",
        kafka_port                      => "9552",
        kafka_user                      => "appsuser",
        kafka_group                     => "appsuser",
        kafka_heap_xmx                  => "4096M",
        kafka_heap_xms                  => "512M",
        kafka_sys_logs_dir              => "/logs/kafka",
        kafka_metrics_dir               => "/data1/kafka_metrics",
        kafka_logs_dir                  => "/data1/kafka-logs",
        java_home                       => "/usr/lib/jvm/java-8-oracle",
        zookeeper_connects              => "fab-dr01-zoo-h1:2471,fab-dr01-zoo-h2:2471,fab-dr01-zoo-h3:2471",
        zookeeper_connection_timeout_ms => "1000000",
        zookeeper_data_dir              => "/data1/zookeeper",
        zookeeper_port                  => "2471",
        broker_list                     => "fab-dr01-kaf-h2:9552,fab-dr01-kaf-h3:9552,fab-dr01-kaf-h4:9552",
    }
}


############################### Zookeeper Hosts ########################################

node 'fab-dr01-zoo-h1' {
    class { 'zookeeper':
        zookeepr_dir    => "/apps/zookeeper-3.4.6",
        zoo_port        => "2471",
        tick_time       => "2000",
        init_limit      => "10",
        sync_limit      => "5",
        zoo_data_dir    => "/data1/zookeeper",
        servers         => ['fab-dr01-zoo-h1','fab-dr01-zoo-h2','fab-dr01-zoo-h3'],
        zoo_minmem      => "1g",
        zoo_maxmem      => "4g",
        zoo_myid_nodeno => "1",
        zoo_log_dir     => "/logs/zookeeper",
        zookeeper_user  => "appsuser",
        zookeeper_group => "appsuser",
    }
}



node 'fab-dr01-kafzoo-h1' {
    class { 'kafka_zoo':
        apps_dir                          => "/apps",
        zookeepr_dir                      => "/apps/zookeeper-3.4.6",
        tick_time                         => "2000",
        init_limit                        => "10",
        sync_limit                        => "5",
        zoo_data_dir                      => "/data1/zookeeper",
        servers                           => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        zoo_port                          => "2471",
        kafka_ver                         => "2.11-0.11.0.0",
        kafka_port                        => "9552",
        zoo_minmem                        => "1g",
        zoo_maxmem                        => "4g",
        zoo_myid_nodeno                   => "1",
        kafka_dir                         => "/apps/kafka_2.9.1-0.8.1.1_actiance",
        zoo_log_dir                       => "/logs/zookeeper",
        zookeeper_user                    => "appsuser",
        zookeeper_group                   => "appsuser",
        broker_id                         => "1",
        kafka_user                        => "appsuser",
        kafka_group                       => "appsuser",
        kafka_logs_dir                    => "/data1/kafka-logs",
        kafka_partitions                  => "16",
        kafka_metric_dir                  => "/data1/kafka_metrics",
        consumer_servers                  => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'], 
        kafka_syslog_dir                  => "/logs/kafka",
        kafka_syslog_file                 => "/logs/kafka/system.log",
        kafka_num_network_threads         => "2",
        kafka_num_io_threads              => "2",
        kafka_socket_send_buffer_bytes    => "1048576",
        kafka_socket_receive_buffer_bytes => "1048576",
        kafka_socket_request_max_bytes    => "20971520",
        kafka_log_flush_interval_message  => "10000",
        kafka_log_flush_interval_ms       => "1000",
        kafka_log_segment_bytes           => "536870912",
        kafka_log_cleanup_interval_mins   => "1",
        kafka_zookeeper_conn_timeout_ms   => "1000000",
        kafka_producer_type               => "sync",
        kafka_compression_codec           => "none",
        kafka_serializer_class            => "kafka.serializer.DefaultEncoder"

    }

}



node 'fab-dr01-kafzoo-h2' {
    class { 'kafka_zoo':
        apps_dir                          => "/apps",
        zookeepr_dir                      => "/apps/zookeeper-3.4.6",
        tick_time                         => "2000",
        init_limit                        => "10",
        sync_limit                        => "5",
        zoo_data_dir                      => "/data1/zookeeper",
        servers                           => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        zoo_port                          => "2471",
        kafka_port                        => "9552",
        zoo_minmem                        => "1g",
        zoo_maxmem                        => "4g",
        zoo_myid_nodeno                   => "2",
        kafka_dir                         => "/apps/kafka_2.9.1-0.8.1.1_actiance",
        zoo_log_dir                       => "/logs/zookeeper",
        zookeeper_user                    => "appsuser",
        zookeeper_group                   => "appsuser",
        broker_id                         => "2",
        kafka_user                        => "appsuser",
        kafka_group                       => "appsuser",
        kafka_logs_dir                    => "/data1/kafka-logs",
        kafka_partitions                  => "16",
        kafka_metric_dir                  => "/data1/kafka_metrics",
        consumer_servers                  => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'], 
        kafka_syslog_dir                  => "/logs/kafka",
        kafka_syslog_file                 => "/logs/kafka/system.log",
        kafka_num_network_threads         => "2",
        kafka_num_io_threads              => "2",
        kafka_socket_send_buffer_bytes    => "1048576",
        kafka_socket_receive_buffer_bytes => "1048576",
        kafka_socket_request_max_bytes    => "20971520",
        kafka_log_flush_interval_message  => "10000",
        kafka_log_flush_interval_ms       => "1000",
        kafka_log_segment_bytes           => "536870912",
        kafka_log_cleanup_interval_mins   => "1",
        kafka_zookeeper_conn_timeout_ms   => "1000000",
        kafka_producer_type               => "sync",
        kafka_compression_codec           => "none",
        kafka_serializer_class            => "kafka.serializer.DefaultEncoder"

    }

}

node 'fab-dr01-kafzoo-h3' {
    class { 'kafka_zoo':
        apps_dir                          => "/apps",
        zookeepr_dir                      => "/apps/zookeeper-3.4.6",
        tick_time                         => "2000",
        init_limit                        => "10",
        sync_limit                        => "5",
        zoo_data_dir                      => "/data1/zookeeper",
        servers                           => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        zoo_port                          => "2471",
        kafka_port                        => "9552",
        zoo_minmem                        => "1g",
        zoo_maxmem                        => "4g",
        zoo_myid_nodeno                   => "3",
        kafka_dir                         => "/apps/kafka_2.9.1-0.8.1.1_actiance",
        zoo_log_dir                       => "/logs/zookeeper",
        zookeeper_user                    => "appsuser",
        zookeeper_group                   => "appsuser",
        broker_id                         => "3",
        kafka_user                        => "appsuser",
        kafka_group                       => "appsuser",
        kafka_logs_dir                    => "/data1/kafka-logs",
        kafka_partitions                  => "16",
        kafka_metric_dir                  => "/data1/kafka_metrics",
        consumer_servers                  => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'], 
        kafka_syslog_dir                  => "/logs/kafka",
        kafka_syslog_file                 => "/logs/kafka/system.log",
        kafka_num_network_threads         => "2",
        kafka_num_io_threads              => "2",
        kafka_socket_send_buffer_bytes    => "1048576",
        kafka_socket_receive_buffer_bytes => "1048576",
        kafka_socket_request_max_bytes    => "20971520",
        kafka_log_flush_interval_message  => "10000",
        kafka_log_flush_interval_ms       => "1000",
        kafka_log_segment_bytes           => "536870912",
        kafka_log_cleanup_interval_mins   => "1",
        kafka_zookeeper_conn_timeout_ms   => "1000000",
        kafka_producer_type               => "sync",
        kafka_compression_codec           => "none",
        kafka_serializer_class            => "kafka.serializer.DefaultEncoder"

    }
}

node 'fab-dr01-ess-h1', 'fab-dr01-ess-h2', 'fab-dr01-ess-h3' {
    class { 'es':
        es_user      => "appsuser",
        es_version   => "2.4.2",
        cluster_name => "dr01essdata",
        ess_hosts    => '["fab-dr01-ess-h1","fab-dr01-ess-h2","fab-dr01-ess-h3"]',
        data_dir     => "/data1/elasticsearch",
        log_dir      => "/logs/elasticsearch",
        build_number => "1.0.0-15253-ga0effe5",
    }

}

node 'fab-dr01-essr-h1', 'fab-dr01-essr-h2', 'fab-dr01-essr-h3' {
    class { 'es':
        es_user      => "appsuser",
        es_version   => "2.4.2",
        cluster_name => "dr01essreport",
        ess_hosts    => '["fab-dr01-essr-h1","fab-dr01-essr-h2","fab-dr01-essr-h3"]',
        data_dir     => "/data1/elasticsearch",
        log_dir      => "/logs/elasticsearch",
        build_number => "1.0.0-15253-ga0effe5",
    }

}



node 'fab-dr01-mdb-h4-1','fab-dr01-mdb-h4-2' {

    class { 'mongodb':
        mongo_user   => 'appsuser',
        apps_dir     => "/apps",
        data_drive   => '/data1',
        dbpath       => '/data1/mongodb',
        logpath      => '/logs/mongodb',
        logpath_file => '/logs/mongodb/mongod.log',
        port         => '23757',
        shardsvr     => 'true',
        logappend    => 'true',
        replSet      => 'dr01mongo',
    }
}
node 'fab-dr01-mdbconf-h1', 'fab-dr01-mdbconf-h2', 'fab-dr01-mdbconf-h3' {
    class { 'mongodb_configdb':
        mongo_user   => 'appsuser',
        data_drive   => '/data1',
        data_dir     => '/data1',
        log_dir      => '/logs',
        dbpath       => '/data1/mongodb',
        logappend    => 'true',
        logpath      => '/logs/mongodb',
        logpath_file => '/logs/mongodb/mongod.log',
        port         => '23758',
    }
}

node 'fab-dr01-haz-h1','fab-dr01-haz-h2','fab-dr01-haz-h3' {
    class { 'hazelcast_birthing':
        require                                             => Class['mongos'],
        build_number                                        => "1.0.0-13817-g7d0f028",
        apps_dir                                            => "/apps",
        heapdump_file_path                                  => "/data1/heapdumps",
        scribe_port                                         => "1853",
        haz_port                                            => "5281",
        haz_log_dir                                         => "/logs/hazelcast",
        hazelcast_home                                      => "/apps/alcatraz_cache-1.0",
        hazelcast_user                                      => "appsuser",
        hazelcast_group                                     => "appsuser",
        java_home_jars                                      => "/usr/lib/jvm/java-8-oracle/jre/lib/security" ,
        prop_temp_file_path                                 => "/data1/tmp",
        hazelcast_jvm_min_mem                               => "256m",
        kafka_brokers_with_ports                            => "fab-dr01-kafzoo-h1:9552,fab-dr01-kafzoo-h2:9552,fab-dr01-kafzoo-h3:9552",
        kafka_zkservers                                     => "fab-dr01-kafzoo-h1:2471,fab-dr01-kafzoo-h2:2471,fab-dr01-kafzoo-h3:2471",
    }
    class { 'mongos':
        apps_dir            => "/apps",
        mongo_user          => "appsuser",
        mongo_port          => "23757",
        mongod_port         => "23758",
        configdbs_and_port  => "fab-dr01-mdbconf-h1:23758,fab-dr01-mdbconf-h2:23758,fab-dr02-mdbconf-h3:23758",
        configdbs_and_port1 => "fab-dr01-mdbconf-site-h1:23758,fab-dr01-mdbconf-site-h2:23758,fab-dr02-mdbconf-site-h3:23758",
    }

}
node 'fab-dr01-karaf-h1','fab-dr01-karaf-h2','fab-dr01-karaf-h3' {
    class { 'karaf_birthing':
        require                                 => Class['mongos'],
        karaf_user                              => "appsuser",
        karaf_group                             => "appsuser",
        karaf_apps_dir                          => "/apps",
        karaf_home                              => "/apps/karaf",
        karaf_data_dir                          => "/data1/karaf",
        karaf_log_dir                           => "/logs/karaf",
        build_number                            => "1.0.0-13817-g7d0f028",
        zeromq_zip                              => "zeromq-3.2.4.zip",
        zeromq_version                          => "zeromq-3.2.4",
        jzmq_tar                                => "jzmq.tar",
        java_home                               => "/usr/lib/jvm/java-8-oracle",
        setenv_java_max_perm_mem                => "2048M",
        kafka_zkservers                         => "fab-dr01-kafzoo-h1:2471,fab-dr01-kafzoo-h2:2471,fab-dr01-kafzoo-h3:2471",
        temp_file_download_path                 => "/data1/tmp",
        nfs_path                                => "/nfs-path/stormexports",
        nfs_failed_xml_path                     => "/nfs-path/failedxml",
        karaf_dumppath                          =>  "/data1/heapdump",
    }

    class { 'mongos':
        apps_dir           => "/apps",
        mongo_user         => "appsuser",
        mongo_port         => "23757",
        mongod_port         => "23758",
        configdbs_and_port => "fab-dr01-mdbconf-h1:23758,fab-dr01-mdbconf-h2:23758,fab-dr02-mdbconf-h3:23758",
        configdbs_and_port1 => "fab-dr01-mdbconf-site-h1:23758,fab-dr01-mdbconf-site-h2:23758,fab-dr02-mdbconf-site-h3:23758",
    }
}


node 'fab-dr01-nfs-h4','fab-dr01-nfs-h5' {
    class { 'karaf_nfs_birthing':
        require                                 => Class['mongos'],
        karaf_nfs_user                          => "appsuser",
        karaf_nfs_group                         => "appsuser",
        karaf_nfs_apps_dir                      => "/apps",
        karaf_nfs_home                          => "/apps/karaf_nfs",
        karaf_nfs_data_dir                      => "/data1/karaf",
        karaf_nfs_log_dir                       => "/logs/karaf_nfs",
        temp_file_download_path                 => "/data1/tmp",
        build_number                            => "1.0.0-13817-g7d0f028",
        zeromq_zip                              => "zeromq-3.2.4.zip",
        zeromq_version                          => "zeromq-3.2.4",
        jzmq_tar                                => "jzmq.tar",
        java_home                               => "/usr/lib/jvm/java-8-oracle",
        java_home_jars                          => "/usr/lib/jvm/java-8-oracle/jre/lib/security",
        setenv_java_max_perm_mem                => "1024M",
        kafka_zkservers                         => "fab-dr01-kafzoo-h1:2471,fab-dr01-kafzoo-h2:2471,fab-dr01-kafzoo-h3:2471",
        nfs_path                                => "/data1/stormexports",
        nfs_failed_xml_path                     => "/data1/failedxml",
        karaf_nfs_dumppath                      => "/data1/heapdump",
    }

    class { 'mongos':
        apps_dir            => "/apps",
        mongo_user          => "appsuser",
        mongo_port          => "23757",
        mongod_port         => "23758",
        configdbs_and_port  => "fab-dr01-mdbconf-h1:23758,fab-dr01-mdbconf-h2:23758,fab-dr02-mdbconf-h3:23758",
        configdbs_and_port1 => "fab-dr01-mdbconf-site-h1:23758,fab-dr01-mdbconf-site-h2:23758,fab-dr02-mdbconf-site-h3:23758",
    }
}

node 'fab-dr01-stm-h1', 'fab-dr01-stm-h2', 'fab-dr01-stm-h3' {

    class { 'storm_birthing':
        require                                 => Class['mongos'],
        build_number                            => "1.0.0-13817-g7d0f028",
        storm_user                              => "appsuser",
        storm_group                             => "appsuser",
        data_dir                                => "/data1",
        storm_data_dir                          => "/data1/storm",
        log_dir                                 => "/logs",
        storm_log_dir                           => "/logs/storm",
        apps_dir                                => "/apps" ,
        storm_version                           => "storm-1.1.1" ,
        zeromq_zip                              => "zeromq-3.2.4.zip" ,
        zeromq_version                          => "zeromq-3.2.4" ,
        jzmq_tar                                => "jzmq.tar" ,
        java_home_jars                          => "/usr/lib/jvm/java-8-oracle/jre/lib/security",
        storm_zookeper_servers                  => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        storm_zookeeper_port                    => "2471",
        nimbus_host                             => "fab-dr01-stm-h1" ,
        nimbus_thrift_port                      => "3457",
        supervisor_slots_ports                  => [3700, 3701],
        storm_worker_childopts_xms              => "256m",
        storm_worker_childopts_xmx              => "8192m",
        storm_ui_childopts_xms                  => "256m",
        storm_ui_childopts_xmx                  => "768m",
        storm_ui_port                           => "3050",
        kafzoo_brokers                          => "fab-dr01-kafzoo-h1:9552,fab-dr01-kafzoo-h2:9552,fab-dr01-kafzoo-h3:9552",
        kafzoo_zkservers                        => "fab-dr01-kafzoo-h1:2471,fab-dr01-kafzoo-h2:2471,fab-dr01-kafzoo-h3:2471" ,
        nfs_path                                => "/nfs-path/stormexports" ,
        nfs_failed_xml_path                     => "/nfs-path/failedxml",
    }
    class { 'mongos':
        apps_dir            => "/apps",
        mongo_user          => "appsuser",
        mongo_port          => "23757",
        mongod_port         => "23758",
        configdbs_and_port  => "fab-dr01-mdbconf-h1:23758,fab-dr01-mdbconf-h2:23758,fab-dr02-mdbconf-h3:23758",
        configdbs_and_port1 => "fab-dr01-mdbconf-site-h1:23758,fab-dr01-mdbconf-site-h2:23758,fab-dr02-mdbconf-site-h3:23758",
    }

}

node 'fab-dr01-egw-h1','fab-dr01-egw-h3','fab-dr01-egw-h2' {
    class { 'egw':
        apps_dir        => "/apps",
        require         => Class['mongos'],
        data_dir        => "/data1/egw",
        logs_dir        => "/logs/egw",
        log_postfix_dir => "/logs/postfix",
    }
    class { 'mongos':
        apps_dir            => "/apps",
        mongo_user          => "appsuser",
        mongo_port          => "23757",
        mongod_port         => "23758",
        configdbs_and_port  => "fab-dr01-mdbconf-h1:23758,fab-dr01-mdbconf-h2:23758,fab-dr02-mdbconf-h3:23758",
        configdbs_and_port1 => "fab-dr01-mdbconf-site-h1:23758,fab-dr01-mdbconf-site-h2:23758,fab-dr02-mdbconf-site-h3:23758",
    }
}

node 'fab-dr01-warden-h1','fab-dr01-puppet-h3' {
    include sendmail
}

node 'fab-dr01-kibana-h1'{
    class { 'kibana':
        kibana_version        => "4.6.2",
        nginx_version         => "1.10.1",
        nginx_log_dir         => "/logs/nginx",
        essr_host             => "fab-dr01-essr-h1",
        certs_dir             => "/home/sysops/certs",
        nginx_port            => "443",
        kibana_port           => "5602",
        base64_credentials    => "YWRtaW46YWxjYXRyYXoxNDAw",
        dns_ip                => "10.171.211.213",
        es_user               => "admin",
        es_paswd              =>"alcatraz1400",
        ssl_verify            => "false",
        kibana_home           => "/opt/kibana",
        kibana_log_dir        => "/logs/kibana",
        report_domain         => "report",
    }
}

node 'fab-dr01-warden-h2' {
    class { 'kafka_topics':
        zoo_hosts => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
        zoo_port  => "2471",
    }

}
