#!/bin/bash

for FILER in seavvnetapp05a seavvnetapp05b seavvnetapp3 seavvnetapp4 seatsnetapp06a seatsnetapp06b tukvvnetapp05a tukvvnetapp05b tuknetapp1 tuknetapp2
do
	for i in `ssh root@${FILER} vol status | grep online | awk '{print $1}'`
	do
		ssh ${FILER} vol options $i convert_ucode on
		ssh ${FILER} vol options $i create_ucode on
	done
done
