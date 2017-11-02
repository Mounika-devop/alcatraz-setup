node 'fab-dr01-ganglia-h2' {
    #   include ganglia_master
    class { 'ganglia_master':
        haz_hosts   => ['fab-dr01-haz-h1','fab-dr01-haz-h4','fab-dr01-haz-h5'],
        stm_hosts   => ['fab-dr01-stm-h1','fab-dr01-stm-h2','fab-dr01-stm-h3','fab-dr01-stm-h4','fab-dr01-stm-h5','fab-dr01-stm-h6'],
        karaf_hosts => ['fab-dr01-karafui-h1-1','fab-dr01-karafui-h1-2'],
        nfs_hosts   => ['fab-dr01-nfs-h3','fab-dr01-nfs-h4'],
        mdb_hosts   => ['fab-dr01-mdb-h7','fab-dr01-mdb-h8','fab-dr01-mdb-h9'],
        ess_hosts   => ['fab-dr01-ess-h7-1','fab-dr01-ess-h7-2','fab-dr01-ess-h8-1','fab-dr01-ess-h8-2','fab-dr01-ess-h9-1','fab-dr01-ess-h9-2','fab-dr01-ess-h10-1','fab-dr01-ess-h10-2'],
        essr_hosts  => ['fab-dr01-essr-h7','fab-dr01-essr-h8','fab-dr01-essr-h9','fab-dr01-essr-h10'],
        kaf_hosts   => ['fab-dr01-kaf-h2','fab-dr01-kaf-h4','fab-dr01-kaf-h5'],
        egw_hosts   => ['fab-dr01-egw-h1-1','fab-dr01-egw-h1-2','fab-dr01-egw-h2-1','fab-dr01-egw-h2-2'],
        kdig_hosts  => ['fab-dr01-karafdig-h1-1','fab-dr01-karafdig-h1-2','fab-dr01-h2-1','fab-dr01-h2-2'],
        cmon_hosts  => ['fab-dr01-cephmon-h1','fab-dr01-cephmon-h3','fab-dr01-cephmon-h4'],
        cdep_hosts  => ['fab-dr01-cephdep-h4'],
        crad_hosts  => ['fab-dr01-cephrad-h1','fab-dr01-cephrad-h3','fab-dr01-cephrad-h4'],
        cosd_hosts  => ['fab-dr01-ceph-h11','fab-dr01-ceph-h12','fab-dr01-ceph-h13','fab-dr01-ceph-h14'],
        kib_hosts   => ['fab-dr01-kibana-h1','fab-dr01-kibana-h2'],

    }

}

node default {
    include ganglia_agent
}


