#!/bin/bash
# 
# Creates 5TB datastore and maps it, no snapshots or autogrow

# Variables
CLUSTER=igqqanetapp01
PREFIX=igqqa               # This is the beginning of the SVM name before san0?
DS='T1IN11QGV16'
NODE=1
# igroup examples:igq-qa-dmz2 igq-qa-ora2 igq-qa-sql2 igq-qa-gen2, substitute prd for qa for prod IGQ
IGROUP=igq-qa-gen2

# Get to work:
for i in $DS
do
	ssh $CLUSTER volume create -vserver ${PREFIX}san0${NODE} -volume ${i} -aggregate aggr1_sas_0${NODE} -size 5.2t  -percent-snapshot-space 0% -snapshot-policy  none 
	ssh $CLUSTER lun create  -vserver ${PREFIX}san0${NODE} -path /vol/${i}/${i}  -size 5t -ostype vmware
	ssh $CLUSTER lun map -vserver ${PREFIX}san0${NODE} -path /vol/${i}/${i} -igroup $IGROUP
done
