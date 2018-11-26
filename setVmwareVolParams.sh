for i in igqprnetapp01  tukvvnetapp01 seavvnetapp01 
do
  for l in `ssh tlines@${i} vserver show | cut -f1 -d' ' | grep -v Vserver | grep -v "-" | sort -nr | uniq`
  do
    for j in T1 T2
    do
      for k in `ssh tlines@${i} volume show -vserver $l -volume ${j}* | grep ${j} | grep -v PSV | cut -f2 -d' '`
      do
        ssh tlines@${i} volume modify -vserver $l -volume $k -space-guarantee volume
        ssh tlines@${i} volume modify -vserver $l -volume  $k -fractional-reserve 0
        ssh tlines@${i} volume modify -vserver $l -volume  $k -percent-snapshot-space 0
        ssh tlines@${i} volume modify -vserver $l -volume  $k -snapshot-policy none -snapdir-access false
        ssh tlines@${i} volume autosize -vserver $l -volume  $k -is-enabled on -maximum-size 25t
        ssh tlines@${i} volume modify -vserver $l -volume  $k -space-mgmt-try-first volume_grow
        ssh tlines@${i} volume snapshot autodelete modify -vserver $l -volume $k -enabled true -commitment destroy -delete-order oldest_first -trigger volume -target-free-space 10
      done
    done
  done
done
