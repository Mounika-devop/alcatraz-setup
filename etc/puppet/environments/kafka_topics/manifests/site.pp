node 'fab-dr01-kafzoo-h1' {
   class { 'kafka_topics':
       zoo_hosts        => ['fab-dr01-kafzoo-h1','fab-dr01-kafzoo-h2','fab-dr01-kafzoo-h3'],
       zoo_port => "2471",
   }
}
