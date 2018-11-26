FILER=tukvvnetapp05a
ssh $FILER snapmirror status | grep -v "Snapmirror is on"
FILER=tukvvnetapp05b
ssh $FILER snapmirror status | grep -v "Snapmirror is on" | grep -v "^Source"
FILER=seatsnetapp06a
ssh $FILER snapmirror status | grep -v "Snapmirror is on"
FILER=seatsnetapp06b
ssh $FILER snapmirror status | grep -v "Snapmirror is on" | grep -v "^Source"
FILER=tukvvfile1
ssh $FILER snapmirror status | grep -v "Snapmirror is on" | grep -v "^Source"
FILER=tukvvmaintfs1
ssh $FILER snapmirror status | grep -v "Snapmirror is on" | grep -v "^Source"
