#!/bin/bash
set -x
for i in seavvsan01  seavvsan03  seavvsan02 seavvsan04
do
	for j in `cat ${i}`
	do
		ssh seavvnetapp01 snap delete -vs ${i} -volume ${j} -snapshot Oct19
	done
done

for i in tukvvsan01 tukvvsan02 tukvvsan03 tukvvsan04
do
        for j in `cat ${i}`
        do
                ssh tukvvnetapp01 snap delete -vs ${i} -volume ${j} -snapshot Oct19
        done
done

