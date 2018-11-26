#for i in seadvs4a2db01 seadvs4a2db02 seadvs4adb01 seadvs4adb02 seaqas4a2db01 seaqas4a2db02 seaqas4adb01 seaqas4adb02 seatss4a2db01 seatss4adb01
#for i in seadvs4a2app01 seadvs4a2app02 seadvs4aapp01 seadvs4aapp02 seaqas4a2app01 seaqas4a2app02 seaqas4a2app03 seaqas4a2app04 seaqas4aapp01 seaqas4aapp02 seaqas4aapp03 seaqas4aapp04 seatss4a2app01 seatss4a2app02 seatss4aapp01 seatss4aapp02


for i in seadvsbl8db01 seaqatitandb01 seatssbl8db01 seatssolasm01 seatsorads seatstwsdb01 seadvzn03 seaqaewalletdb01 seatsewalletdb01 tukvvtwsdb01 seavvtitandb01 seavvtwsdb01 seavvpspmdb01 seavvewalletdb01
do
ssh root@${i} cp /net/seavvarchive1/vol/unixarch/oralinux/RH6/pam.d/system-auth /etc/pam.d
done

