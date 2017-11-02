#############################################################
#Author: Subhash K
#Purpose: CreatePartion for the give disk and mount it on give mountpath
#
#Function:
#Usage : python PartitionandMount.py VM_IP Username Password device_Name fstype,mountpath
#
#Path:
#
#
#
#
#
#
#
##############################################################
import paramiko
import atexit
import logging
import sys
import subprocess
import time
import argparse
import os

class myssh:

    def __init__(self, host, user, password, port = 22):
        client = paramiko.SSHClient()
        #print "test"
        #client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(host, port=port, username=user, password=password)
        atexit.register(client.close)
        self.client = client

    def __call__(self, command):
        stdin,stdout,stderr = self.client.exec_command(command)
        sshdata = stdout.readlines()
        ssherr = stderr.readlines()
        retval = stdout.channel.recv_exit_status()
        return sshdata, ssherr, retval

logging.basicConfig(filename='partitionandmount.log',level=logging.INFO)
if len(sys.argv)!=7:
         print "****************************************************************************************************"
         print "* Usgae   : python PartitionandMount.py VM_IP Username Password device_Name fstype,mountpath"
         print "* Example : python PartitionandMount.py xx.xx.xx.xx root xxxx /dev/sdb ext4 /data"
         print "****************************************************************************************************"
         sys.exit()
print "mount file"
host=sys.argv[1]
user=sys.argv[2]
password=sys.argv[3]
diskname=sys.argv[4]
fstype=sys.argv[5]
mountpath=sys.argv[6]
#remote=TestParamiko.myssh(host,user,password)


cmd='echo "'+password+'" | sudo -S parted -s -a optimal '+ diskname+' -- mkpart primary '+fstype+' 1 -1'
cmd1='echo "'+password+'" | sudo -S mkfs -t '+fstype+' '+diskname+'1'
cmd2='echo "'+password+'" | sudo -S mkdir '+mountpath
cmd3='echo "'+password+'" | sudo -S mount '+diskname+'1 '+mountpath
cmd4='echo "'+password+'" | sudo -S parted '+diskname+' mklabel msdos y'
cmd5='echo "'+password+'" | sudo -S sed -i "$ a '+diskname+'1       '+mountpath+'           auto    defaults        0       0"  /etc/fstab '


try:
  remote=myssh(host,user,password)
  out,err,rval=remote("partprobe")
  print "Testing Return val",rval
  if rval==0:
     print "Command excuted successfully"
  else:
     print "Command not excuted successfully",str(err)
  print out,err
  out,err,rval=remote(cmd4)
  print out,err
  print "Testing Return val",rval
  if rval==0:
     print "Command excuted successfully",str(out)
  else:
     print "Command not excuted successfully",str(err)

  print cmd
  out,err,rval=remote(cmd)
  print "Testing Return val",rval

  print err,out
  if rval!=0:
     print "ERROR: Partion creation error",str(err)
     logging.error("partion creation error"+str(err))
     sys.exit()
  else:
     print "INFO: Partition created successfully",str(out)
     logging.info("INFO: Partition created successfully"+str(out))

  print cmd1
  out,err,rval=remote(cmd1)
  print "Testing Return val",rval

  logging.info(out)
  print err

  if rval!=0:
     print "ERROR: File system creation :",str(err)
     logging.error("Filesystem creation error"+str(err))
     sys.exit()
  else:
     print "INFO: Filesystem created successfully"
     logging.info("INFO: Filesystem created successfully"+str(out))
  print out

  print cmd2
  out,err,rval=remote(cmd2)
  print "Testing Return val",rval
  logging.info(out)
  logging.error(err)
  if rval!=0:
     print "ERROR: Directory creation :",str(err)
     logging.error("Directory creation error"+str(err))
     sys.exit()
  else:
     print "INFO: Directory created successfully",str(out)
     logging.info("INFO: Directory created successfully"+str(out))

  print cmd3
  out,err,rval=remote(cmd3)
  print "Testing Return val",rval

  logging.info(out)
  logging.error(err)
  if rval!=0:
     print "ERROR: Mounting error :",str(err)
     logging.error("Mounting error"+str(err))
     sys.exit()
  else:
     print "INFO: Successfully mounted partion",str(out)
     logging.info("INFO: Successfully mounted partition"+str(out))
  out,err,rval=remote(cmd5)
  if rval!=0:
     print "ERROR :Updating /etc/fstab failed",str(err)
     logging.error("Updating /etc/fstab failed"+str(err))
     sys.exit()
  else:
     print "INFO: Successfully Updated /etc/fstab ",str(out)
     logging.info("INFO: Successfully Updated /etc/fstab "+str(out))
except Exception as e:
  print "exception ",e

