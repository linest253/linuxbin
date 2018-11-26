LIST="seadvsbl8db01 seadvsbl8hdb01 seadvsbl8pdb01 seaqasbl8db01 seaqasbl8db02 seadvsbl8db01_bkup"

for i in `echo $LIST`
do
ssh seatssan01 volume clone split start $i
done


