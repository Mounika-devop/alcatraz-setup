node default {
    include sysctl

    sysctl::conf {

      # prevent java heap swap
      "vm.swappiness": value =>  0;

      # increase max read/write buffer size that can be applied via setsockopt()
      "net.core.rmem_max": value =>  16777216;
      "net.core.wmem_max": value =>  16777216;

    }

}

node /fab-apac01-ganglia-h2/ {
    class { 'sp_merge':
        build_number     => "1.0.0-19961-g00110eb",
        alcatraz_version => "2.5.1.1",
        fabrics          => ['archive-export.storm','ediscovery-export.storm','ediscovery-metadata.storm','hazelcast','karaf','lfs.storm','nfs-karaf.karaf','storm'],
        zoo_host         => "fab-apac01-warden-h1",
        zoo_port         => "2471",
    }
    sp_merge::conf {

        #####   Common ElasticSearch across all fabrics #######
        "server.archive.es.host.ip": value                                         => "fab-apac01-ess-h5-1,fab-apac01-ess-h6-1,fab-apac01-ess-h7-1,fab-apac01-ess-h8-1";
        "server.metrics.es.host.ip": value                                         => "fab-apac01-essr-h5,fab-apac01-essr-h6,fab-apac01-essr-h7,fab-apac01-essr-h8";
        "server.archive.es.host.port": value                                       => "9640";
        "server.archive.es.host.tcp.port": value                                   => "9740";
        "es.settings.archive.number_of_replicas": value                            => "1";
        "server.metrics.es.host.port": value                                       => "9640";
        "server.metrics.es.host.tcp.port": value                                   => "9740";
        "es.settings.metrics.number_of_replicas": value                            => "1";
        "es.settings.archive.cluster.name": value                                  => "apac01essdata";
        "es.settings.metrics.cluster.name": value                                  => "apac01essreport";
        "es.settings.archive.searchguard.ssl.transport.keystore_filepath": value   => "/etc/ssl/node-0-keystore.jks";
        "es.settings.metrics.searchguard.ssl.transport.keystore_filepath": value   => "/etc/ssl/node-0-keystore.jks";
        "es.settings.archive.searchguard.ssl.transport.truststore_filepath": value => "/etc/ssl/truststore.jks";
        "es.settings.metrics.searchguard.ssl.transport.truststore_filepath": value => "/etc/ssl/truststore.jks";
        "es.settings.ssl.enabled": value                                           => "true";

        #### Common Hazelcast properties across all fabrics #####
        "alcatraz.hazelcast.hosts": value                       => "fab-apac01-haz-h1:5281,fab-apac01-haz-h2:5281,fab-apac01-haz-h3:5281";
        "alcatraz.hazelcast.port": value                        => "5281";

        #### Common Mongo Properties across all fabrics #####
        ###  Mongo Auth ####
        "server.mongo.auth.enabled": value               => "true";
        "server.primary.mongo.auth.password": value      => "pr8d8CSVJI1yRPlSk1GHxA==";
        "server.dr.mongo.auth.password": value           => "pr8d8CSVJI1yRPlSk1GHxA==";
        "server.local.mongo.auth.password": value        => "pr8d8CSVJI1yRPlSk1GHxA==";
        "server.sitespecific.mongo.auth.password": value => "pr8d8CSVJI1yRPlSk1GHxA==";

        #### Mongo Primary Details ###:
        "mongo.in.cluster.mode": value                          => "true";
        "server.primary.mongo.host.port": value                 => "23757";
        "server.primary.mongo.host.maxconnection": value        => "100";
        "server.primary.mongo.ssl.enabled": value               => "true";
        "server.primary.mongo.ssl.allowinvalidhostnames": value => "true";

        ##### Mongo Site Specific mongo details ###
        "server.sitespecific.mongo.host.port": value                 => "23758";
        "server.sitespecific.mongo.host.maxconnection": value        => "100";
        "server.sitespecific.mongo.ssl.enabled": value               => "true";
        "server.sitespecific.mongo.ssl.allowinvalidhostnames": value => "true";

        #### Alcatraz DR Details ####
        "dr.site.enabled": value  => "true";
        "site.type.dr": value     => "false";
        "alcatraz.site.id": value => "1";

        ####  NFS and Download File Path Location ###
        "nfs.path.location": value                 => "/nfs-path/stormexports";
        "prop.temp.file.path.files": value         => "/data1/tmp";
        "prop.temp.file.path.tika": value          => "/data1/tmp/tika";
        "supervision.notification.location": value => "";

        #### Kafka Zookeeper Settings ####
        "kafkaproducer.bootstrap.servers": value => "fab-apac01-kafzoo-h1:9552,fab-apac01-kafzoo-h2:9552,fab-apac01-kafzoo-h3:9552"; 
        "kafkaconsumer.bootstrap.servers": value => "fab-apac01-kafzoo-h1:9552,fab-apac01-kafzoo-h2:9552,fab-apac01-kafzoo-h3:9552";
        "zkservers": value                       => "fab-apac01-kafzoo-h1:2471,fab-apac01-kafzoo-h2:2471,fab-apac01-kafzoo-h3:2471";

        #### Storm settings ####
        ### Topic  rs1 ###
        "ingestion.topics": value          => "rs1";
        "ingestion.worker.count" :value    => "1";
        "ingestion.intern.q.size" :value   => "200";
        "numpartitions" :value             => "16";
        "deconstruction.task.count" :value => "58";
        "datapartition.task.count" :value  => "18";
        "objstore.task.count" :value       => "72";
        "metadata.task.count" :value       => "24";
        "indexing.task.count" :value       => "72";
        "export.task.count" :value         => "10";
        "recon.task.count" :value          => "16";
        "rawstore.enable" :value           => "true";


        ### Hold and Unhold ###
        "large.holdtag.topic": value             => "largeHoldTagTopic";
        "medium.holdtag.topic": value            => "mediumHoldTagTopic";
        "small.holdtag.topic": value             => "smallHoldTagTopic";
        "holdtag.worker.count" :value            => "1";
        "holdtag.intern.q.size" :value           => "200";
        "holdtag.numpartitions" :value           => "16";
        "holdtag.metadata.task.count" :value     => "60";
        "holdtag.indexing.task.count" :value     => "60";
        "holdtag.objectstore.task.count" :value  => "60";
        "holdtag.retention.task.count" :value    => "60";  
        "large.holdtag.consumer.group" :value    => "largeHoldTagConsumerGrp";
        "medium.holdtag.consumer.group" :value   => "mediumHoldTagConsumerGrp";
        "small.holdtag.consumer.group" :value    => "smallHoldTagConsumerGrp";


        #### Jobs Topic ###
        "jobs.topic": value               => "jobs";
        "purge.topic": value              => "purge.topic";
        "ingestion.largemsg.topic": value => "largemsg";

        ### Ceph Details ##
        "server.primary.object.store.provider": value   => "swift";
        "server.primary.object.store.identity": value   => "sysops:swift";
        "server.primary.object.store.credential": value => "";
        "server.primary.object.store.host.url": value   => "";

        #### Townsend Details ###
        "server.keystore.filepath": value       => "/apps/config/keystore/admin_one_keystore.jks";
        "server.truststore.filepath": value     => "/apps/config/keystore/CATrustStore.jks";
        "server.clientkeystore.filepath": value => "/apps/config/keystore/client_alcatraz_cert_keystore.jks";
        "server.keystore.password": value       => "actiance";
        "server.truststore.password": value     => "actiance";
        "server.ip": value                      => "fab-apac01-twn-h1";
        "server.username": value                => "alcatraz";
        "server.groupname": value               => "alcatrazgroup";

        ## SMTP Details ###
        "mail.smtp.host": value        => "fab-apac01-rh1-h1";
        "mail.smtp.port": value        => "25";
        "mail.smtp.user.id": value     => "";
        "mail.smtp.password": value    => "";
        "mail.smtp.tls.enabled": value => "";
        "mail.smtp.auth.reqd": value   => "";
        "mail.nocemailaddress": value  => "";

        ### 
        "master.scheduler.frequency.time": value                => "1";
        "tenant.export.defaults.xheader": value                 => "";
        "admin.oneclick.download.limit": value                  => "20000000";
        "indexmanager.lock.timeout.seconds": value              => "5";
        "report.savedsearch.scroll.page.size": value            => "1000";
        "report.savedsearch.scroll.time": value                 => "60000";
        "es.fetch.child.max.limit": value                       => "5000";
        "export.file.folder.limit": value                       => "";
        "retention.policy.queue.id.resync.interval.secs": value => "180";
        "metadata.doc.count.small.topic": value                 => "10";
        "metadata.doc.count.medium.topic": value                => "30";
        "metadata.doc.count.large.topic": value                 => "40";
        "indexable.file.max.count": value                       => "20";
        "disclaimer.cache.timeout": value                       => "24";
        "disclaimer.cache.timeunit": value                      => "h";
        "enable.ingestion.participant.cache": value             => "true";
        "report.rollup.batch.size": value                       => "500";
        "report.rollup.results.size": value                     => "0";
        "report.rollup.retry.limit ": value                     => "5";
        "max.metadata.payload.size": value                      => "104857600";
        "kafkaproducer.acks": value                             => "all";
        "kafkaconsumer.max.poll.interval.ms": value             => "300000";
        "kafkaconsumer.session.timeout.ms": value               => "60000";
        "max.export.payload.size": value                        => "104857600";
        "kafkaconsumer.enable.auto.commit": value               => "false";
        "kafkaconsumer.heartbeat.interval.ms": value            => "3000";
        "max.job.payload.size": value                           => "104857600";
        "kafka.consumer.timeout": value                         => "1000";
        "kafkaconsumer.consumer.timeout.ms": value              => "10";
        "indexmanager.archive.schemaVersion": value             => "4";
        "indexmanager.metrics.schemaVersion": value             => "4";
        "max.reindex.payload.size": value                       => "104857600";
        "kafkaproducer.compression.type": value                 => "none";
        "kafkaproducer.max.request.size": value                 => "31457280";
        "kafkaproducer.retries": value                          => "0";
        "kafkaconsumer.auto.offset.reset": value                => "earliest";
	"apc.portola.domain.name": value                        => "jpmc.actiance.net";
        "apc.alcatraz.domain.name": value                       => "dig.jpmc.actiance.net";



    }

#    class { "sp_deploy":
#        zoo_host => "fab-apac01-warden-h1",
#        zoo_port => "2471",
#        alcatraz_version => "2.5.1.1",
#    }


#   Class["sp_merge"] -> Class["sp_deploy"]

        

}

node /fab-apac01-kafzoo/ {
    class { 'kafka_zoo':
        apps_dir                          => "/apps",
        zookeepr_dir                      => "/apps/zookeeper-3.4.6",
        tick_time                         => "2000",
        init_limit                        => "10",
        sync_limit                        => "5",
        zoo_data_dir                      => "/data1/zookeeper",
        servers                           => ['fab-apac01-kafzoo-h1'],
        zoo_port                          => "2471",
        kafka_port                        => "9552",
        zoo_minmem                        => "1g",
        zoo_maxmem                        => "2g",
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
        consumer_servers                  => ['fab-apac01-kafzoo-h1'],
        kafka_consumer_grp_id             => "test-consumer-group",
        producers_brker_list              => ['fab-apac01-kafzoo-h1'], 
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
