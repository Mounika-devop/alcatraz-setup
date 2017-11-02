import TestParamiko
import os
import sys
import xlwt
import csv

if len(sys.argv)!=4:
  print "******************************************************************"
  print "Usage Error: python Report_VMDisk.py esxilist username password"
  print "Usage :python Report_VMDisk.py esxilistfile root XXXXXXX"
  print "******************************************************************"
  sys.exit()
esxilist=sys.argv[1]
username=sys.argv[2]
password=sys.argv[3]


f=open(esxilist,'r')
arr1=[['VMNAME','DISK1','SIZEinGB','DISK2','SIZEinGB','DISK3','SIZEinGB']]
for x in f:
  remote=TestParamiko.myssh(x,username,password)
  cmd="vim-cmd vmsvc/getallvms |awk '{if(NR>1)print $1,$2}'"
  out,err,r=remote(cmd)
  for i in out:
     arr=[]
     cmd="vim-cmd vmsvc/device.getdevices "+i.split()[0]+"|egrep 'vmdk|capacityInKB'"
     out1, err,r=remote(cmd)
     arr.append(str(i.split()[1]))
     for x in range(len(out1)):
         if x%2==1:
            arr.append(int(((str(out1[x].split('=')[1]).strip('\n')).replace('"','')).replace(',',''))/1048576)
         else:
            arr.append(((str(out1[x].split('=')[1]).strip('\n')).replace('"','')).replace(',',''))
     arr1.append(arr)

with open('VMsDiskInfo.csv', 'w') as csvfile:
  writer = csv.writer(csvfile, delimiter=',')
  for x in arr1:
    writer.writerow(x)

