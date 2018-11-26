ssh root@seavvnetapp05a options snapmirror.fixed_rate.enable off 
ssh root@seavvnetapp05a options replication.throttle.enable off 
ssh root@seavvnetapp05a options replication.throttle.outgoing.max_kbs unlimited

ssh root@seavvnetapp05b options snapmirror.fixed_rate.enable off 
ssh root@seavvnetapp05b options replication.throttle.enable off 
ssh root@seavvnetapp05b options replication.throttle.outgoing.max_kbs unlimited

ssh root@tukvvnetapp05a options snapmirror.fixed_rate.enable off 
ssh root@tukvvnetapp05a options replication.throttle.enable off 
ssh root@tukvvnetapp05a options replication.throttle.outgoing.max_kbs unlimited

ssh root@tukvvnetapp05b options snapmirror.fixed_rate.enable off 
ssh root@tukvvnetapp05b  options replication.throttle.enable off 
ssh root@tukvvnetapp05b  options replication.throttle.outgoing.max_kbs unlimited

