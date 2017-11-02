class kafka_zoo($apps_dir, $zookeepr_dir, $tick_time, $init_limit, $sync_limit, $zoo_data_dir, $servers, $zoo_port, $kafka_port, $zoo_minmem, $zoo_maxmem, $zoo_myid_nodeno, $kafka_dir, $zoo_log_dir, $zookeeper_user, $zookeeper_group, $autopurge_snapRetainCount, $autopurge_purgeInterval, $broker_id, $kafka_user, $kafka_group,  $kafka_logs_dir, $kafka_partitions, $kafka_metric_dir, $consumer_servers, $kafka_consumer_grp_id, $producers_brker_list, $kafka_syslog_dir, $kafka_syslog_file, $kafka_num_network_threads, $kafka_num_io_threads, $kafka_socket_send_buffer_bytes, $kafka_socket_receive_buffer_bytes, $kafka_socket_request_max_bytes,$kafka_log_flush_interval_message, $kafka_log_flush_interval_ms, $kafka_log_segment_bytes, $kafka_log_cleanup_interval_mins, $kafka_zookeeper_conn_timeout_ms, $kafka_producer_type, $kafka_compression_codec, $kafka_serializer_class){



package {
    'software-properties-common':
        ensure => installed;
    'python-software-properties':
        ensure => installed;
}

exec { 'add-webupd8-repo':
    command => 'sudo add-apt-repository ppa:webupd8team/java',
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    notify => Exec["apt-update"],
}

exec { 'apt-update':
    command => 'sudo apt-get update',
    path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
}

exec {
    'set-licence-selected':
        command => 'echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
    'set-licence-seen':
        command => 'echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections',
        path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"];
}

package { 'oracle-java7-installer':
    ensure => present,
    require => [Exec["apt-update"], Exec['add-webupd8-repo'], Exec['set-licence-selected'], Exec['set-licence-seen']],
}

package { 'oracle-java7-set-default':
    ensure => installed,
        require => Package['oracle-java7-installer'],
}

user { $zookeeper_user:
     ensure      => present,
     managehome  => true,
     #  password => pw_hash('alcatraz1400','SHA-512','mysalt'),
     home        => "$apps_dir",
     shell       => "/bin/false",
     #groups     => "sudo",
     gid         => $zookeeper_group,
     require     => Group[$zookeeper_group],
}
group { $zookeeper_group:
     ensure  => present,
     require => Package['oracle-java7-set-default'],
}

#user { $kafka_user:
#     ensure => present,
#     gid => $kafka_group,
#     require => Group[$kafka_group],
#   }
#   group { $kafka_group:
#     ensure => present,
#}

exec { "mkdir_p_${zookeepr_dir}":
     path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
     command => "mkdir -p ${zookeepr_dir} ${kafka_syslog_dir} ${zoo_log_dir} ${zoo_data_dir} ${kafka_logs_dir} ${kafka_metric_dir} ${kafka_logs_dir}",
     require => User[$zookeeper_user],
}

exec { "chown_p_${zookeeper_user}":
     path    => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    command => "chown -R ${zookeeper_user}:${zookeeper_group} ${kafka_syslog_dir} ${zoo_log_dir} ${zoo_data_dir} ${kafka_logs_dir} ${kafka_metric_dir} ${kafka_logs_dir}",
    require => Exec["mkdir_p_${zookeepr_dir}"],
}

file {"$zookeepr_dir":
   ensure => directory,
   recurse => true,
   owner => "$zookeeper_user",
   group => "$zookeeper_group",
   source => "puppet:///modules/common_files/package/zookeeper-3.4.6",
   #source => "/home/puppet/modules/kafka_zoo/package/zookeeper-3.4.6",
   require => [Package['oracle-java7-set-default'], Exec["mkdir_p_${zookeepr_dir}"]]
}

file { "$zookeepr_dir/conf/zoo.cfg":
        ensure => present,
        content => template('kafka_zoo/zoo.cfg.erb'),
        require => File[$zookeepr_dir],
}

file {"$zookeepr_dir/conf/java.env":
	ensure => present,
        content => template('kafka_zoo/java.env.erb'),
        require => File[$zookeepr_dir],
}


file {"$zoo_log_dir":
        ensure => directory,
        owner => "$zookeeper_user",
        group => "$zookeeper_group",
         mode => 755,
        require => File[$zookeepr_dir],
}


file { "/lib/systemd/system/zookeeper.service":
     ensure => present,
     mode => "0755",
     content => template('kafka_zoo/zookeeper_service.erb'),
     require => [File["${zookeepr_dir}/conf/zoo.cfg"], File["${zookeepr_dir}/conf/java.env"], File["${zookeepr_dir}/bin/zkServer.sh"]],
}


file { "$zoo_data_dir":
    ensure => directory,
     recurse => true,
    owner => "$zookeeper_user",
   group => "$zookeeper_group",
    mode   => 777,
    require => File["${zookeepr_dir}/conf/zoo.cfg"],
}

file {"$zoo_data_dir/myid":
     ensure => present,
   #   owner => "$zookeeper_user",
   #group => "$zookeeper_group",
   # mode   => 777,
     content => "$zoo_myid_nodeno",
    require => File[$zoo_data_dir],
}

 #       ensure => running,
  #      enable => true,
   #     hasstatus => true,
    #    require => [File['/etc/init.d/zookeeper'], File["${zoo_data_dir}/myid"]],


file {"$kafka_dir":
   ensure  => directory,
   recurse => true,
   owner   => 'appsuser',
   group   => 'appsuser',
  # source => "/etc/puppet/environments/cs_poc/modules/kafka_zoo/files/package/kafka_2.8.0-0.8.0",
   source => "puppet:///modules/common_files/package/kafka_2.9.1-0.8.1.1_actiance/",
   require => Exec["mkdir_p_${zookeepr_dir}"]
}

file {"$kafka_logs_dir":
        ensure => directory,
        owner => "$kafka_user",
        group => "$kafka_group",
         mode => 766,
        require => File[$kafka_dir],
}

file {"$kafka_metric_dir":
        ensure => directory,
        owner => "$kafka_user", 
        group => "$kafka_group",
         mode => 766,
        require => File[$kafka_dir],
}

file {"$kafka_syslog_dir":
        ensure => directory,
	owner => "$kafka_user",
        group => "$kafka_group",
         mode => 755,
        require => File[$kafka_dir],
}

file {"$kafka_syslog_file":
        ensure => present,
	owner => "$kafka_user",
        group => "$kafka_group",
         mode => 766,
        require => File[$kafka_syslog_dir],
}

file { "$kafka_dir/config/server.properties":
        ensure => present,
        content => template('kafka_zoo/server.properties.erb'),
   #     require => [File[$kafka_metric_dir], File[$kafka_logs_dir]],
      require => File[$kafka_logs_dir],
}

file { "$kafka_dir/config/consumer.properties":
        ensure => present,
        content => template('kafka_zoo/consumer.properties.erb'),
        require => File["${kafka_dir}/config/server.properties"],
}

file { "$kafka_dir/config/producer.properties":
        ensure => present,
        content => template('kafka_zoo/producer.properties.erb'),
        require => File["${kafka_dir}/config/consumer.properties"],
}

file { "$kafka_dir/config/log4j.properties":
        ensure => present,
        content => template('kafka_zoo/log4j.properties.erb'),
        require => File["${kafka_dir}/config/producer.properties"],
}

 #    content => template('kafka_zoo/zookeeper_service.erb'),
  #   require => [File["${zookeepr_dir}/conf/zoo.cfg"], File["${zookeepr_dir}/conf/java.env"]],



file { "$kafka_dir/config/zookeeper.properties":
        ensure => present,
        content => template('kafka_zoo/kafka_zookeeper.properties.erb'),
        require => File["${kafka_dir}/config/producer.properties"],
}


 #    command     => "sudo cp -r ${kafka_dir}/libs/ ${kafka_dir}/kafka_libs_backup",
  #   cwd => "$kafka_dir",
   #  path        => ["/usr/bin", "/usr/sbin", "/usr/local/sbin", "/usr/local/bin", "/sbin", "/bin"],
    # require   => File["${kafka_dir}/kafka_libs_backup"],
     #provider  => shell,
 

file { "/lib/systemd/system/kafka.service":
     ensure => present,
     mode => "0755",
     content => template('kafka_zoo/kafka_service.erb'),
    #require => [File["${kafka_dir}/config/zookeeper.properties"], File["${kafka_dir}/libs"]],
     require => [File["${kafka_dir}/config/zookeeper.properties"] ],
}

file { "${zookeepr_dir}/bin/zkServer.sh":
    mode    => "0755",
    source => "puppet:///modules/common_files/package/zookeeper-3.4.6/bin/zkServer.sh",
}

file { "${kafka_dir}/bin/kafka-server-start.sh":
    mode    => "0755",
    content => template('kafka_zoo/kafka-server-start.sh.erb'),

}


service { 'zookeeper':
        ensure    => running,
        enable    => true,
        hasstatus => true,
        provider  => systemd,
        require   => [File['/lib/systemd/system/zookeeper.service'], File["${zoo_data_dir}/myid"]],
}

service { 'kafka':
        ensure => running,
        enable => true,
        hasstatus => true,
        provider  => systemd,
        require => [File["${kafka_dir}/bin/kafka-server-start.sh"],File['/lib/systemd/system/kafka.service'], Service["zookeeper"]],
}

#exec { 'create_topic':
#	cwd => "${kafka_dir}",
#	path => ['/bin', '/usr/bin'],
#	command => "$kafka_dir/bin/kafka-topics.sh --zookeeper ${servers[0]}:2471, ${servers[1]}:2471,${servers[2]}:2471 --create --topic rs1 --partitions 16 --replication-factor 3",
#	require => [Service["kafka"], Service["zookeeper"]],
	

#}

file { "${kafka_dir}/bin":
    ensure  => "directory",
    mode    => "0755",
    recurse => "true",
    source  => "puppet:///modules/common_files/package/kafka_2.9.1-0.8.1.1_actiance/bin",
    require => File["${kafka_dir}"],
}

file { "${apps_dir}/zookeeper":
   ensure => 'link',
   owner  => "${zookeeper_user}",
   target => "${zookeepr_dir}",
}

file { "${apps_dir}/kafka":
   ensure => 'link',
   owner  => "${kafka_user}",
   target => "${kafka_dir}",
}

}

