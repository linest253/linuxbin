#!/bin/bash

# This script makes assumptions about the aggregate names (aggr1_sas_${NODE}) that might not be true
# in all environments. Adjust accordingly.

set -x

CLUSTER=igqqanetapp01

VSERVERS=`ssh $CLUSTER vserver show -fields vserver | grep -v netapp01 | grep -v '\-\-\-' | grep -v vserver | grep -v san | grep -v entries | dos2unix `

NODES=`ssh $CLUSTER storage aggregate show -fields aggregate | grep aggr1 | grep -v aggr0 | grep -v aggregate | grep -v '\-\-\-' | grep -v entries | cut -d '_' -f3 | dos2unix ` 


for VSERVER in `echo $VSERVERS`
do 
	for NODE in `echo $NODES`
	do
		ROOTVOL=`ssh $CLUSTER volume show -vserver $VSERVER -volume *root -fields volume | grep -v vserver | grep -v '\-\-\-' | cut -d' ' -f2 | dos2unix `
		ssh $CLUSTER volume create -vserver $VSERVER -volume ${ROOTVOL}_${NODE} -aggregate aggr1_sas_${NODE} -size 2GB -type DP
		ssh $CLUSTER snapmirror create -source-path //${VSERVER}/${ROOTVOL} -destination-path //${VSERVER}/${ROOTVOL}_${NODE} -type LS
	sleep 10
	done
	ssh $CLUSTER snapmirror initialize-ls-set //${VSERVER}/${ROOTVOL}
	sleep 10
	ssh $CLUSTER snapmirror modify -source-path ${VSERVER}:${ROOTVOL} -schedule hourly -destination-path \*
done
