#!/bin/sh

for j in seavvnetapp05a seavvnetapp05b
do
	for i in `ssh root@${j} 'lun show' | awk '{print $1}'`
	do
		ssh root@${j} reallocate start -f $i
	done
done


