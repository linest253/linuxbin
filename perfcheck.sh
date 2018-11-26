#    !/bin/bash


#RSH=/usr/bin/rsh
LOGFILE=`date | awk '{print $1"_"$2"_"$3"_"$4}'`
i=1

while [ "$i" -lt 10000 ]
do
	date | awk '{print $1"_"$2"_"$3"_"$4}' >> $LOGFILE
	ssh $1 'priv set -q diag ; statit -b' >> $LOGFILE
	ssh $1 'priv set -q diag ; nfs_hist -z' >> $LOGFILE

	## generic
	ssh $1 sysstat -c 30 -x -s 1 >> $LOGFILE

	## output after 10 seconds
	ssh $1 'priv set -q diag ; statit -e' >> $LOGFILE
	ssh $1 'priv set -q diag ; nfs_hist' >> $LOGFILE
done
