#!/bin/sh

for j in seavvnetapp05a seavvnetapp05b seavvnetapp3 seavvnetapp4 tuknetapp1 tuknetapp2 tukvvnetapp05a tukvvnetapp05b
do
        for i in `ssh root@${j} 'vol status' | grep raid_dp | awk '{print $1}'`
        do
                ssh root@${j} vol options $i fractional_reserve 0
        done
done

