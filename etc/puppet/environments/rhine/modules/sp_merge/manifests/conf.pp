define sp_merge::conf ($value) {

  include sp_merge
  # $title contains the title of each instance of this defined type

  # guid of this entry
  $key = $title
  $alcatraz_version = $sp_merge::alcatraz_version
  $sp_merge::fabrics.each |String $x| {
      augeas { "$x/$key":
          lens        => "Properties.lns",
          incl        => "/tmp/$alcatraz_version/$x.server.properties",
          onlyif      => "match $key size == 1",
          changes     => "set $key '$value'",
      }
  }
}
