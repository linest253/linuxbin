#!/bin/sh

ssh root@seavvnetapp05a 'stats show disk:*:disk_busy'
ssh root@seavvnetapp05b 'stats show disk:*:disk_busy'
