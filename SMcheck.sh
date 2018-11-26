#!/bin/bash

while true
do
	ssh seatsnetapp01  snapmirror show -vs seatssan01 -destination-path seatssan01:seavvairvisdb01_mirror | grep "Total Progress"
	ssh seatsnetapp01  snapmirror show -vs seatssan02 -destination-path seatssan02:seavvairvisdb01_mirror | grep "Total Progress"
	echo -----
	sleep 300
done

