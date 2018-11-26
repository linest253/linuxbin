#!/bin/sh

for i in `cat mcgeeprod.txt`
do
	echo $i
	sshpass -p DcgSEAVV@!01 ssh-copy-id -i ~/.ssh/id_rsa.pub root@${i}
	ssh root@${i} mkdir /export/home/tlines
	ssh root@${i} chown tlines /export/home/tlines

	sshpass -p Febr2018 ssh-copy-id -i ~/.ssh/id_rsa.pub tlines@${i}
	sshpass -p Golfball ssh-copy-id -i ~/.ssh/id_rsa.pub tlines@${i}
done

