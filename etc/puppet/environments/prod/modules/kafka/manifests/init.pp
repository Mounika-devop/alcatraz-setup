class kafka() {
  $kafka_user_home = "/apps"
  $kafka_dir = "/apps/kafka_2.11-0.11.0.0"
  $kafka_link = "/apps/kafka"
  $kafka_port = "9552"
  $kafka_user = "appsuser"
  $kafka_group = "appsuser"
  $kafka_heap_xmx = "4096M"
  $kafka_heap_xms = "512M"
  $kafka_sys_logs_dir = "/logs/kafka"
  $kafka_metrics_dir = "/data1/kafka_metrics"
  $kafka_logs_dir = "/data1/kafka-logs"
  $java_home = "/usr/lib/jvm/java-7-oracle"

  $zookeeper_connects = "fab-prod-zoo-h1:2471,fab-prod-zoo-h2:2471,fab-prod-zoo-h3:2471"
  $zookeeper_connection_timeout_ms = "1000000"
  $zookeeper_data_dir = "/data1/zookeeper"
  $zookeeper_port = "2471"
  $hostname_str = split($hostname, '-')
  $broker_id = regsubst($hostname_str[-1], 'h', '')
  $broker_list = "fab-prod-kaf-h2:9552,fab-prod-kaf-h3:9552,fab-prod-kaf-h4:9552"

  group { $kafka_group:
	   ensure => present,
  }

  user { $kafka_user:
    ensure     => present,
    managehome => true,
    home       => "/apps",
    shell      => "/bin/false",
    gid        => "$kafka_group",
    require    => Group[$kafka_group],
  }

  file { "$kafka_user_home":
    mode => 0755,
    owner => $kafka_user,
    group => $kafka_group,
    ensure => directory,
    recurse => true
  }

  ####Copy Kafka package from files
  file { "$kafka_dir":
	   ensure    => directory,
	   recurse   => true,
	   source    => "puppet:///modules/kafka/kafka_2.11-0.11.0.0/",
	   owner     => "$kafka_user",
	   group     => "$kafka_group",
	   require   => File["$kafka_user_home"]
  }

  ###Create Kafka Sys logs dir
  file {"$kafka_sys_logs_dir":
	   ensure      => directory,
	   owner       => "$kafka_user",
	   group       => "$kafka_group",
	   mode        => 755,
	   require     => File[$kafka_dir],
  }

  ###Create Kafka logs dir
  file {"$kafka_logs_dir":
	   ensure      => directory,
	   owner       => "$kafka_user",
	   group       => "$kafka_group",
	   mode        => 755,
	   require     => File[$kafka_sys_logs_dir],
  }

  ####Create Kafka Metrics Directory
  file {"$kafka_metrics_dir":
	   ensure => directory,
	   owner => "$kafka_user",
	   group => "$kafka_group",
	   mode => 755,
	   require => File[$kafka_logs_dir],
  }

  ####Change Kafka Server.Properties file
  file { "$kafka_dir/config/server.properties":
  	ensure      => present,
  	owner       => "$kafka_user",
  	group       => "$kafka_group",
  	mode        =>  644,
  	content     => template('kafka/server.properties.erb'),
  	require     => File[$kafka_metrics_dir],
  }

  #### Change kafka Consumer.properties file
  file { "$kafka_dir/config/consumer.properties":
    ensure => present,
    owner     => "$kafka_user",
    group     => "$kafka_group",
    mode      =>  644,
    content => template('kafka/consumer.properties.erb'),
    require => File["${kafka_dir}/config/server.properties"],
  }

  #### Change Kafka Producer properties file
  file { "$kafka_dir/config/producer.properties":
    ensure => present,
    owner     => "$kafka_user",
    group     => "$kafka_group",
    mode      =>  644,
    content => template('kafka/producer.properties.erb'),
    require => File["${kafka_dir}/config/consumer.properties"],
  }

  #### CHnage log4 Property file
  file { "$kafka_dir/config/log4j.properties":
    ensure => present,
    owner     => "$kafka_user",
    group     => "$kafka_group",
    mode      =>  644,
    content => template('kafka/log4j.properties.erb'),
    require => File["${kafka_dir}/config/producer.properties"],
  }

  ####Change zookeeper properties in Kafka
  file { "$kafka_dir/config/zookeeper.properties":
    ensure => present,
    owner     => "$kafka_user",
    group     => "$kafka_group",
    mode      =>  644,
    content => template('kafka/zookeeper.properties.erb'),
    require => File["${kafka_dir}/config/log4j.properties"],
  }

  ####Change zookeeper properties in Kafka
  file { "$kafka_dir/bin/zookeeper-server-start.sh":
    ensure => present,
    mode   => 755,
    owner   => "$kafka_user",
    group   => "$kafka_group",
    content => template('kafka/zookeeper-server-start.sh.erb'),
    require => File["${kafka_dir}/config/zookeeper.properties"],
  }

  #### Update limits.conf
  file { "/etc/security/limits.conf":
    ensure => present,
    content => template('kafka/limits.conf.erb'),
    require => File["${kafka_dir}/bin/zookeeper-server-start.sh"],
  }

  ####Update sysctl.conf
  file { "/etc/sysctl.conf":
    ensure => present,
    content => template('kafka/sysctl.conf.erb'),
    require => File["/etc/security/limits.conf"],
  }

  #### Create kafka link
  file { "$kafka_link":
    ensure  => link,
    target  => "/apps/kafka_2.11-0.11.0.0",
    owner   => "$kafka_user",
    group   => "$kafka_group",
    require => File["/etc/sysctl.conf"],
  }

  #### Kafka service
  file { "/lib/systemd/system/kafka.service":
     ensure => present,
     mode => "0755",
     content => template('kafka/kafka.service.erb'),
     require => File["${$kafka_link}"],
  }

}
