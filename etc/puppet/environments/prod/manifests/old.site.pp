node 'fab-prod02-kaf-h2' {
    class { 'kafka':
        kafka_dir                         => "/apps/kafka_2.9.1-0.8.1.1_actiance",
        kafka_port                        => "9552",
        zoo_port                          => "2471",
        zoo_data_dir                      => "/data1/zookeeper",
        autopurge_snapRetainCount         => "4",
        autopurge_purgeInterval           => "5",
        broker_id                         => "1",
        kafka_user                        => "appsuser",
        kafka_group                       => "appsuser",
        kafka_logs_dir                    => "/data1/kafka-logs",
        kafka_partitions                  => "16",
        kafka_metric_dir                  => "/data1/kafka_metrics",
        consumer_servers                  => ['fab-jpus01-kaf-h2'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-jpus01-kaf-h2'],
        kafka_syslog_dir                  => "/logs/kafka",
        kafka_syslog_file                 => "/logs/kafka/system.log",
        kafka_num_network_threads         => "2",
        kafka_num_io_threads              => "2",
        kafka_socket_send_buffer_bytes    => "1048576",
        kafka_socket_receive_buffer_bytes => "1048576",
        kafka_socket_request_max_bytes    => "104857600",
        kafka_log_flush_interval_message  => "10000",
        kafka_log_flush_interval_ms       => "1000",
        kafka_log_segment_bytes           => "536870912",
        kafka_log_cleanup_interval_mins   => "1",
        servers                           => ['fab-jpus01-kaf-h2'],
        kafka_zookeeper_conn_timeout_ms   => "1000000",
        kafka_producer_type               => "sync",
        kafka_compression_codec           => "none",
        kafka_serializer_class            => "kafka.serializer.DefaultEncoder",
    }
}


############################### Zookeeper Hosts ########################################

node 'fab-prod02-zoo-h1' {
    class { 'zookeeper':
        zookeepr_dir    => "/apps/zookeeper-3.4.6",
        zoo_port        => "2471",
        tick_time       => "2000",
        init_limit      => "10",
        sync_limit      => "5",
        zoo_data_dir    => "/data1/zookeeper",
        servers         => ['fab-prod02-zoo-h1'],
        zoo_minmem      => "1g",
        zoo_maxmem      => "4g",
        zoo_myid_nodeno => "1",
        zoo_log_dir     => "/logs/zookeeper",
        zookeeper_user  => "appsuser",
        zookeeper_group => "appsuser",
    }
}



node 'fab-prod02-kafzoo-h1' {
    class { 'kafka_zoo':
        apps_dir                          => "/apps",
        zookeepr_dir                      => "/apps/zookeeper-3.4.6",
        tick_time                         => "2000",
        init_limit                        => "10",
        sync_limit                        => "5",
        zoo_data_dir                      => "/data1/zookeeper",
        servers                           => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'],
        zoo_port                          => "2471",
        kafka_port                        => "9552",
        zoo_minmem                        => "1g",
        zoo_maxmem                        => "4g",
        zoo_myid_nodeno                   => "1",
        kafka_dir                         => "/apps/kafka_2.9.1-0.8.1.1_actiance",
        zoo_log_dir                       => "/logs/zookeeper",
        zookeeper_user                    => "appsuser",
        zookeeper_group                   => "appsuser",
        autopurge_snapRetainCount         => "4",
        autopurge_purgeInterval           => "5",
        broker_id                         => "1",
        kafka_user                        => "appsuser",
        kafka_group                       => "appsuser",
        kafka_logs_dir                    => "/data1/kafka-logs",
        kafka_partitions                  => "16",
        kafka_metric_dir                  => "/data1/kafka_metrics",
        consumer_servers                  => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'], 
        kafka_syslog_dir                  => "/logs/kafka",
        kafka_syslog_file                 => "/logs/kafka/system.log",
        kafka_num_network_threads         => "2",
        kafka_num_io_threads              => "2",
        kafka_socket_send_buffer_bytes    => "1048576",
        kafka_socket_receive_buffer_bytes => "1048576",
        kafka_socket_request_max_bytes    => "104857600",
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



node 'fab-prod02-kafzoo-h2' {
    class { 'kafka_zoo':
        apps_dir                          => "/apps",
        zookeepr_dir                      => "/apps/zookeeper-3.4.6",
        tick_time                         => "2000",
        init_limit                        => "10",
        sync_limit                        => "5",
        zoo_data_dir                      => "/data1/zookeeper",
        servers                           => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'],
        zoo_port                          => "2471",
        kafka_port                        => "9552",
        zoo_minmem                        => "1g",
        zoo_maxmem                        => "4g",
        zoo_myid_nodeno                   => "2",
        kafka_dir                         => "/apps/kafka_2.9.1-0.8.1.1_actiance",
        zoo_log_dir                       => "/logs/zookeeper",
        zookeeper_user                    => "appsuser",
        zookeeper_group                   => "appsuser",
        autopurge_snapRetainCount         => "4",
        autopurge_purgeInterval           => "5",
        broker_id                         => "2",
        kafka_user                        => "appsuser",
        kafka_group                       => "appsuser",
        kafka_logs_dir                    => "/data1/kafka-logs",
        kafka_partitions                  => "16",
        kafka_metric_dir                  => "/data1/kafka_metrics",
        consumer_servers                  => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'], 
        kafka_syslog_dir                  => "/logs/kafka",
        kafka_syslog_file                 => "/logs/kafka/system.log",
        kafka_num_network_threads         => "2",
        kafka_num_io_threads              => "2",
        kafka_socket_send_buffer_bytes    => "1048576",
        kafka_socket_receive_buffer_bytes => "1048576",
        kafka_socket_request_max_bytes    => "104857600",
        kafka_log_flush_interval_message  => "10000",
        kafka_log_flush_interval_ms       => "1000",
        kafka_log_segment_bytes           => "536870912",
        kafka_log_cleanup_interval_mins   => "1",
        kafka_zookeeper_conn_timeout_ms   => "1000000",
        kafka_producer_type               => "sync",
        kafka_compression_codec           => "none",
        kafka_serializer_class            => "kafka.serializer.DefaultEncoder"

    }

    #    class { '::mcollective':
    #    middleware_hosts => ['puppet.actiance.local'],
    #}
    #include mcollective-puppet
}

node 'fab-prod02-kafzoo-h3' {
    class { 'kafka_zoo':
        apps_dir                          => "/apps",
        zookeepr_dir                      => "/apps/zookeeper-3.4.6",
        tick_time                         => "2000",
        init_limit                        => "10",
        sync_limit                        => "5",
        zoo_data_dir                      => "/data1/zookeeper",
        servers                           => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'],
        zoo_port                          => "2471",
        kafka_port                        => "9552",
        zoo_minmem                        => "1g",
        zoo_maxmem                        => "4g",
        zoo_myid_nodeno                   => "3",
        kafka_dir                         => "/apps/kafka_2.9.1-0.8.1.1_actiance",
        zoo_log_dir                       => "/logs/zookeeper",
        zookeeper_user                    => "appsuser",
        zookeeper_group                   => "appsuser",
        autopurge_snapRetainCount         => "4",
        autopurge_purgeInterval           => "5",
        broker_id                         => "3",
        kafka_user                        => "appsuser",
        kafka_group                       => "appsuser",
        kafka_logs_dir                    => "/data1/kafka-logs",
        kafka_partitions                  => "16",
        kafka_metric_dir                  => "/data1/kafka_metrics",
        consumer_servers                  => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'], 
        kafka_syslog_dir                  => "/logs/kafka",
        kafka_syslog_file                 => "/logs/kafka/system.log",
        kafka_num_network_threads         => "2",
        kafka_num_io_threads              => "2",
        kafka_socket_send_buffer_bytes    => "1048576",
        kafka_socket_receive_buffer_bytes => "1048576",
        kafka_socket_request_max_bytes    => "104857600",
        kafka_log_flush_interval_message  => "10000",
        kafka_log_flush_interval_ms       => "1000",
        kafka_log_segment_bytes           => "536870912",
        kafka_log_cleanup_interval_mins   => "1",
        kafka_zookeeper_conn_timeout_ms   => "1000000",
        kafka_producer_type               => "sync",
        kafka_compression_codec           => "none",
        kafka_serializer_class            => "kafka.serializer.DefaultEncoder"

    }
    #
    #class { '::mcollective':
    #    middleware_hosts => ['puppet.actiance.local'],
    #}
    #include mcollective-puppet
}

node 'fab-prod02-ess-h4', 'fab-prod02-ess-h5', 'fab-prod02-ess-h6' {
   class { 'es':
         es_user                           => "appsuser",
         es_group                          => "appsuser",
         es_dir                            => "/apps",
         es_version                        => "2.3.2",
         cluster_name                      => "jpuat01essdata",
         path_data                         => "/data1/elasticsearch",
         path_logs                         => "/logs/elasticsearch",
         index_mapper_dynamic              => "false",
         index_refresh_interval            => "180s",
         transport_netty_worker_count      => "4",
         action_destructive_requires_name  => "true",
         es_heap_size                      => "1g",
         es_tcp_port                       => "9740",
         es_http_port                      => "9640",
         ess_hosts                         => '["fab-prod02-ess-h4","fab-prod02-ess-h5","fab-prod02-ess-h5-2"]',
         index_query_bool_max_clause_count => "8192",
       }

}

node 'fab-prod02-essr-h4-1', 'fab-prod02-essr-h4-2', 'fab-prod02-essr-h5-1' {
   class { 'es':
         es_user                           => "appsuser",
         es_group                          => "appsuser",
         es_dir                            => "/apps",
         es_version                        => "2.3.2",
         cluster_name                      => "jpuat01essreports",
         path_data                         => "/data1/elasticsearch",
         path_logs                         => "/logs/elasticsearch",
         index_mapper_dynamic              => "false",
         index_refresh_interval            => "180s",
         transport_netty_worker_count      => "4",
         action_destructive_requires_name  => "true",
         es_heap_size                      => "1g",
         es_tcp_port                       => "9740",
         es_http_port                      => "9640",
         ess_hosts                         => '["fab-prod02-essr-h4-1","fab-prod02-essr-h4-2","fab-prod02-essr-h5-1"]',
         index_query_bool_max_clause_count => "8192",
       }

       #  class { '::mcollective':
       # middleware_hosts => [ 'puppet.actiance.local' ],
       #}
       #include mcollective-puppet
}

node 'fab-prod02-mdb-h4','fab-prod02-mdb-h4-2','fab-prod02-mdb-h5-1','fab-prod02-mdb-h5-2' {

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
                        replSet      => 'jpuat01mongo',
                  }

        #class { '::mcollective':
        #        middleware_hosts => [ 'puppet.actiance.local' ],
        #}
        #include mcollective-puppet

}
node 'fab-prod02-mdbconf-h1', 'fab-prod02-mdbconf-h2', 'fab-prod02-mdbconf-h3' {
        class { 'mongodb_configdb':
                mongo_user   => 'appsuser',
                data_drive   => '/data1',
                data_dir     => '/data1',
                log_dir      => '/logs',
                dbpath       => '/data1/mongodb',
		logappend                  => 'true',
                logpath      => '/logs/mongodb',
                logpath_file => '/logs/mongodb/mongod.log',
                port         => '23758',
        }
        #class { '::mcollective':
        #        middleware_hosts => [ 'puppet.actiance.local' ],
        #}
        #include mcollective-puppet

}
node 'fab-prod02-haz-h1','fab-prod02-haz-h2','fab-prod02-haz-h3' {
    class { 'hazelcast_birthing':
            require                                             => Class['mongos'],
            build_number                                        => "1.0.0-15253-ga0effe5",
            apps_dir                                            => "/apps",
            scribe_port                                         => "1853",
            haz_port                                            => "5281",
            haz_log_dir                                         => "/logs/hazelcast",
            hazelcast_home                                      => "/apps/alcatraz_cache-1.0",
            hazelcast_user                                      => "appsuser",
            hazelcast_group                                     => "appsuser",
            java_home_jars                                      => "/usr/lib/jvm/java-8-oracle/jre/lib/security" ,
            server_primary_mongo_host_port                      => "23757",
            server_primary_mongo_write_concern                  => "3",
            alcatraz_hazelcast_hosts                            => "fab-prod02-haz-h1:5281,fab-prod02-haz-h2:5281,fab-prod02-haz-h3:5281",
            server_primary_es_host_ip                           => "fab-prod02-ess-h4,fab-prod02-ess-h5,fab-prod02-ess-h5-2",
            server_primary_essr_host_ip                         => "fab-prod02-essr-h4-1,fab-prod02-essr-h4-2,fab-prod02-essr-h5-1",
            server_primary_es_host_tcp_port                     => "9740",
            server_primary_es_host_cluster_name                 => "prod02essdata",
            essr_cluster_name                                   => "prod02essreport",
            server_primary_es_host_port                         => "9640",
            alcatraz_hazelcast_store_enabled                    => "false",
            alcatraz_hazelcast_enrich_pool_size                 => "10",
            alcatraz_hazelcast_filterresults_thread_count       => "100",
            prop_temp_file_path                                 => "/data1/tmp",
	    heapdump_file_path                                  => "/data1/heapdumps",
            alcatraz_hazelcast_transform_threadpool_threadcount => "100",
            alcatraz_enrich_results_batch_mode                  => "false",
            server_keystore_filepath                            => "/apps/config/keystore/admin_one_keystore.jks",
            server_truststore_filepath                          => "/apps/config/keystore/CATrustStore.jks",
            server_clientkeystore_filepath                      => "/apps/config/keystore/client_actiance_cert_keystore.jks",
            server_keystore_password                            => "actiance",
            server_truststore_password                          => "actiance",
            server_ip                                           => "fab-prod02-nfs-h1",
            server_clientport                                   => "6000",
            server_port                                         => "6001",
            server_username                                     => "alcatraz",
            server_groupname                                    => "alcatrazgroup",
            hazelcast_jvm_min_mem                               => "256m",
            kafka_brokers_with_ports                            => "fab-prod02-kafzoo-h1:9552,fab-prod02-kafzoo-h2:9552,fab-prod02-kafzoo-h3:9552",
            kafka_zkservers                                     => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
            kafka_numpartitions                                 => "16",

    }
class { 'mongos':
        apps_dir           => "/apps",
        mongo_user         => "appsuser",
        mongo_port         => "23757",
        configdbs_and_port => "fab-prod02-mdbconf-h1:23758,fab-prod02-mdbconf-h2:23758,fab-prod02-mdbconf-h3:23758",
    }

}
node 'fab-prod02-karafui-h1-1','fab-prod02-karafui-h1-2','fab-prod02-karafui-h2-1','fab-prod02-karafui-h2-2','fab-prod02-karafdig-h1-1','fab-prod02-karafdig-h1-2','fab-prod02-karafdig-h2-1','fab-prod02-karafdig-h2-2' {
   class { 'karaf_birthing':
                require                                 => Class['mongos'],
                karaf_user                              => "appsuser",
                karaf_group                             => "appsuser",
                karaf_apps_dir                          => "/apps",
                karaf_home                              => "/apps/karaf",
                karaf_data_dir                          => "/data1/karaf",
                karaf_log_dir                           => "/logs/karaf",
                build_number                            => "1.0.0-15253-ga0effe5",
                zeromq_zip                              => "zeromq-3.2.4.zip",
                zeromq_version                          => "zeromq-3.2.4",
                jzmq_tar                                => "jzmq.tar",
                java_home                               => "/usr/lib/jvm/java-8-oracle",
                setenv_java_max_mem                     => "4096M",
                setenv_java_max_perm_mem                => "2048M",
                kafka_brokers_with_ports                => "fab-prod02-kafzoo-h1:9552,fab-prod02-kafzoo-h2:9552,fab-prod02-kafzoo-h3:9552",
                kafka_numpartitions                     => "16",
                kafka_topic                             => "rs1,export,largemsg",
                kafka_zkservers                         => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
                server_primary_es_host_ip               => "fab-prod02-ess-h1,fab-prod02-ess-h2,fab-prod02-ess-h3,fab-prod02-essmas-h1,fab-prod02-essmas-h2,fab-prod02-essmas-h3",
                server_primary_essr_host_ip             => "fab-prod02-essr-h2,fab-prod02-essr-h3,fab-prod02-essr-h4,fab-prod02-essr-h5-1,fab-prod02-essrmas-h1,fab-prod02-essrmas-h2,fab-prod02-essrmas-h3",
                server_primary_es_host_port             => "9640",
                server_primary_es_host_tcp_port         => "9740",
                server_primary_es_host_cluster_name     => "prod02essdata",
                essr_cluster_name                       => "prod02essreport",
                server_primary_storm_host_ip            => "fab-prod02-stm-h1",
                server_primary_storm_host_port          => "3050",
                server_primary_zmq_host_ip              => "127.0.0.1",
                server_primary_zmq_host_port            => "?",
                server_primary_zk_host_ip               => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
                server_primary_zk_host_port             => "2471",
                server_primary_memcache_host_ip         => "127.0.0.1",
                server_primary_memcache_host_port       => "11211",
                server_primary_object_store_provider    => "swift",
                server_primary_object_store_identity    => "sysops:swift",
                server_primary_object_store_credential  => "N9gIoMw1G8A2ftpmhmwhaRC9t4lr7fkLpyi8et7e",
                server_primary_object_store_host_url    => "http://fab-prod02-cephrad-h1:7480/auth/",
                server_primary_mongo_host_ip            => "127.0.0.1",
                server_primary_mongo_host_port          => "23757",
                server_primary_mongo_host_maxconnection => "100",
                temp_file_download_path                 => "/data1/tmp",
                mail_smtp_host                          => "fab-prod02-karafui-h1-1",
                mail_smtp_port                          => "2500",
                alcatraz_hazelcast_hosts                => "fab-prod02-haz-h1:5281,fab-prod02-haz-h2:5281,fab-prod02-haz-h3:5281",
		server_keystore_filepath                => "/apps/config/keystore/admin_one_keystore.jks" ,
		server_truststore_filepath              => "/apps/config/keystore/CATrustStore.jks" ,
		server_clientkeystore_filepath          => "/apps/config/keystore/client_alcatraz_cert_keystore.jks" ,
		server_keystore_password                => "actiance" ,
		server_truststore_password              => "actiance" ,
		keystore_server_ip                      => "fab-prod-twn-lb.sfo.actiance.local" ,
		keystore_server_clientport              => "6000" ,
		keystore_server_port                    => "6001" ,
		keystore_server_username                => "alcatrazclient",
		keystore_server_groupname               => "alcatrazgrp" ,
                exporter_worker_count                   => "1",
                nfs_path                                => "/nfs-path/stormexports",
                nfs_failed_xml_path                     => "/nfs-path/failedxml",
                export_package_location                 => "",
                export_monitor_zkservers                => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
                server_journaling_url                   => "",
                server_journaling_userName              => "",
                server_journaling_password              => "",
                server_journaling_authScheme            => "",
       }

    class { 'mongos':
        apps_dir           => "/apps",
        mongo_user         => "appsuser",
        mongo_port         => "23757",
        configdbs_and_port => "fab-prod02-mdbconf-h1:23758,fab-prod02-mdbconf-h2:23758,fab-prod02-mdbconf-h3:23758",
    }




}


node 'fab-prod02-nfs-h5' {
   class { 'karaf_nfs_birthing':
                require                                 => Class['mongos'],
                karaf_nfs_user                          => "appsuser",
                karaf_nfs_group                         => "appsuser",
                karaf_nfs_apps_dir                      => "/apps",
                karaf_nfs_home                          => "/apps/karaf_nfs",
                karaf_nfs_data_dir                      => "/data1/karaf",
                karaf_nfs_log_dir                       => "/logs/karaf_nfs",
                temp_file_download_path                 => "/data1/tmp",
                build_number                            => "1.0.0-15253-ga0effe5",
                zeromq_zip                              => "zeromq-3.2.4.zip",
                zeromq_version                          => "zeromq-3.2.4",
                jzmq_tar                                => "jzmq.tar",
                java_home                               => "/usr/lib/jvm/java-8-oracle",
                java_home_jars                          => "/usr/lib/jvm/java-8-oracle/jre/lib/security",
                setenv_java_max_mem                     => "4096M",
                setenv_java_max_perm_mem                => "1024M",
                kafka_brokers_with_ports                => "fab-prod02-kafzoo-h1:9552,fab-prod02-kafzoo-h2:9552,fab-prod02-kafzoo-h3:9552",
                kafka_numpartitions                     => "16",
                kafka_topic                             => "rs1,export,largemsg",
                kafka_zkservers                         => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
                server_primary_es_host_ip               => "fab-prod02-ess-h1,fab-prod02-ess-h1,fab-prod02-ess-h3,fab-prod02-essmas-h1,fab-prod02-essmas-h2,fab-prod02-essmas-h3",
                server_primary_es_host_port             => "9640",
                server_primary_es_host_tcp_port         => "9740",
                server_primary_es_host_cluster_name     => "prod02essdata",
                server_primary_storm_host_ip            => "fab-prod02-stm-h1",
                server_primary_storm_host_port          => "3050",
                server_primary_zmq_host_ip              => "127.0.0.1",
                server_primary_zmq_host_port            => "?",
                server_primary_zk_host_ip               => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
                server_primary_zk_host_port             => "2471",
                server_primary_memcache_host_ip         => "127.0.0.1",
                server_primary_memcache_host_port       => "11211",
                server_primary_object_store_provider    => "swift",
                server_primary_object_store_identity    => "sysops:swift",
                server_primary_object_store_credential  => "N9gIoMw1G8A2ftpmhmwhaRC9t4lr7fkLpyi8et7e",
                server_primary_object_store_host_url    => "http://fab-prod02-cephrad-h1:7480/auth/",
                server_primary_mongo_host_ip            => "127.0.0.1",
                server_primary_mongo_host_port          => "23757",
                server_primary_mongo_host_maxconnection => "10",
                mail_smtp_host                          => "10.100.210.26",
                mail_smtp_port                          => "25",
                alcatraz_hazelcast_hosts                => "fab-prod02-haz-h1:5281,fab-prod02-haz-h2:5281,fab-prod02-haz-h3:5281",
                server_keystore_filepath                => "/apps/config/keystore/admin_one_keystore.jks" ,
                server_truststore_filepath              => "/apps/config/keystore/CATrustStore.jks" ,
                server_clientkeystore_filepath          => "/apps/config/keystore/client_alcatraz_cert_keystore.jks" ,
                server_keystore_password                => "alcatraz" ,
                server_truststore_password              => "alcatraz" ,
                keystore_server_ip                      => "10.100.1.51" ,
                keystore_server_clientport              => "6000" ,
                keystore_server_port                    => "6001" ,
                keystore_server_username                => "alcatrazclient" ,
                keystore_server_groupname               => "alcatrazgrp" ,
                exporter_worker_count                   => "1",
                nfs_path                                => "/data1/stormexports",
                nfs_failed_xml_path                     => "/data1/failedxml",
                export_package_location                 => "/data1/exportoutput",
                export_monitor_zkservers                => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
                server_journaling_url                   => "",
                server_journaling_userName              => "",
                server_journaling_password              => "",
                server_journaling_authScheme            => "",
       }

    class { 'mongos':
        apps_dir           => "/apps",
        mongo_user         => "appsuser",
        mongo_port         => "23757",
        configdbs_and_port => "fab-prod02-mdbconf-h1:23758,fab-prod02-mdbconf-h2:23758,fab-prod02-mdbconf-h3:23758",
    }

    #    class { '::mcollective':
    #    middleware_hosts => [ 'puppet.actiance.local' ],
    #}

    #include mcollective-puppet

}

node 'fab-prod02-stm-h1', 'fab-prod02-stm-h2', 'fab-prod02-stm-h3', 'fab-prod02-stm-h4', 'fab-prod02-stm-h5' {

     class { 'storm_birthing':
	       require                                 => Class['mongos'],
           build_number                            => "1.0.0-15253-ga0effe5",
           storm_user                              => "appsuser",
           storm_group                             => "appsuser",
           data_dir                                => "/data1",
           storm_data_dir                          => "/data1/storm",
           log_dir                                 => "/logs",
           storm_log_dir                           => "/logs/storm",
           apps_dir                                => "/apps" ,
           storm_version                           => "storm-1.0.2" ,
           zeromq_zip                              => "zeromq-3.2.4.zip" ,
           zeromq_version                          => "zeromq-3.2.4" ,
           jzmq_tar                                => "jzmq.tar" ,
           java_home_jars                          => "/usr/lib/jvm/java-8-oracle/jre/lib/security",
           storm_zookeper_servers                  => ['fab-prod02-kafzoo-h1','fab-prod02-kafzoo-h2','fab-prod02-kafzoo-h3'],
           storm_zookeeper_port                    => "2471",
           nimbus_host                             => "fab-prod02-stm-h1" ,
           nimbus_thrift_port                      => "3457",
           supervisor_slots_ports                  => [3700, 3701],
           storm_worker_childopts_xms              => "256m",
           storm_worker_childopts_xmx              => "16384m",
           storm_ui_childopts_xms                  => "256m",
           storm_ui_childopts_xmx                  => "768m",
           storm_ui_port                           => "3050",
           server_primary_es_host_ip               => "fab-prod02-ess-h1,fab-prod02-ess-h2,fab-prod02-ess-h3,fab-prod02-essmas-h1,fab-prod02-essmas-h2,fab-prod02-essmas-h3",
           server_primary_essr_host_ip             => "fab-prod02-essr-h2,fab-prod02-essr-h3,fab-prod02-essr-h4,fab-prod02-essr-h5-1,fab-prod02-essrmas-h1,fab-prod02-essrmas-h2,fab-prod02-essrmas-h3",
           server_primary_es_host_port             => "9640",
           server_primary_es_host_tcp_port         => "9740",
           server_primary_es_host_cluster_name     => "prod02essdata",
           essr_cluster_name                       => "prod02essreport",
           alcatraz_es_number_of_shards            => "6",
           alcatraz_es_number_of_replicas          => "1",
           server_primary_storm_host_ip            => "127.0.0.1" ,
           server_primary_storm_host_port          => "?" ,
           server_primary_zmq_host_ip              => "127.0.0.1" ,
           server_primary_zmq_host_port            => "?" ,
           server_primary_zk_host_ip               => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471" ,
           server_primary_zk_host_port             => "2471" ,
           server_primary_zk_host_url              => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471",
           server_primary_object_store_provider    => "swift",
           server_primary_object_store_identity    => "sysops:swift",
           server_primary_object_store_credential  => "N9gIoMw1G8A2ftpmhmwhaRC9t4lr7fkLpyi8et7e",
           server_primary_object_store_host_url    => "http://fab-prod02-cephrad-h1:7480/auth/",
           server_primary_mongo_host_ip            => "127.0.0.1" ,
           server_primary_mongo_host_port          => "23757" ,
           server_primary_mongo_host_maxconnection => "100" ,
           mail_smtp_host                          => "fab-prod02-warden-h1" ,
           mail_smtp_port                          => "25" ,
           kafzoo_brokers                          => "fab-prod02-kafzoo-h1:9552,fab-prod02-kafzoo-h2:9552,fab-prod02-kafzoo-h3:9552",
           kafzoo_numpartitions                    => "16" ,
           kafzoo_topic                            => "rs1" ,
           kafzoo_zkservers                        => "fab-prod02-kafzoo-h1:2471,fab-prod02-kafzoo-h2:2471,fab-prod02-kafzoo-h3:2471" ,
           ingestion_worker_count                  => "2" ,
           exporter_worker_count                   => "1" ,
           alcatraz_hazelcast_hosts                => "fab-prod02-haz-h1:5281,fab-prod02-haz-h2:5281,fab-prod02-haz-h3:5281",
           server_keystore_filepath                => "/apps/config/keystore/admin_one_keystore.jks" ,
           server_truststore_filepath              => "/apps/config/keystore/CATrustStore.jks" ,
           server_clientkeystore_filepath          => "/apps/config/keystore/client_alcatraz_cert_keystore.jks" ,
           server_keystore_password                => "actiance" ,
           server_truststore_password              => "actiance" ,
           keystore_server_ip                      => "fab-prod-twn-lb.sfo.actiance.local ",
           keystore_server_clientport              => "6000" ,
           keystore_server_port                    => "6001" ,
           keystore_server_username                => "alcatrazclient" ,
           keystore_server_groupname               => "alcatrazgrp" ,
           nfs_path                                => "/nfs-path/stormexports" ,
           nfs_failed_xml_path                     => "/nfs-path/failedxml",
           ingestion_consumer_group                => "ingestionconsumers" ,
           ingestion_topics                        => "rs1" ,
           export_topic                            => "export" ,
           export_consumer_group                   => "exportconsumers" ,
           ingestion_largemsg_topic                => "largemsg",
    }
	class { 'mongos':
        	apps_dir           => "/apps",
        	mongo_user         => "appsuser",
        	mongo_port         => "23757",
        	configdbs_and_port => "fab-prod02-mdbconf-h1:23758,fab-prod02-mdbconf-h2:23758,fab-prod02-mdbconf-h3:23758",
    	}

}

node /fab-prod02-dns-h1/ {
    include sendmail
}


node 'fab-prod02-egw-h1-1','fab-prod02-egw-h1-2','fab-prod02-egw-h2-1','fab-prod02-egw-h2-2' {
    class { 'egw':
	require     => Class['mongos'],
        apps_dir => "/apps",
        data_dir => "/data1/egw",
        logs_dir => "/logs/egw",
    }
    class { 'mongos':
        	apps_dir           => "/apps",
        	mongo_user         => "appsuser",
        	mongo_port         => "23757",
        	configdbs_and_port => "fab-prod02-mdbconf-h1:23758,fab-prod02-mdbconf-h2:23758,fab-prod02-mdbconf-h3:23758",
    }
}

node 'fab-prod02-warden-h1','fab-prod02-puppet-h3' {
    include sendmail
}
