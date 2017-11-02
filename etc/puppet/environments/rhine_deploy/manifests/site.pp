node /fab-apac01-ganglia-h2/ {
  class {'sp_deploy':
  	zoo_host => "fab-apac01-warden-h1",
  	zoo_port => "2471",
  	alcatraz_version => "2.5.1.1",
  }
}
