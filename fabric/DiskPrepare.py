#############################################################
#Author: Subhash K
#Purpose: Disk prepare for the VM on given ESXI host and VM NAME
#
#Function:
#Usage :python DiskPrepare.py Esxi_IP Username Password VMName diskname size_in_GB
#
#Path
#
#
#
#
#
#
#
##############################################################
import paramiko
import logging
import sys
import subprocess
import time
import argparse
import os
import atexit
logging.basicConfig(filename='diskprepare.log',level=logging.INFO)

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

print "disk prepare"
if len(sys.argv)!=8:
  print "***************************************************************************************************"
  print "* Usgae   : python DiskPrepare.py Esxi_IP Username Password VMName DatastoreName diskname size_in_GB "
  print "* Example : python DiskPrepare.py xx.xx.xx.xx root xxxx TESTVM datastore1 disk2 30"
  print "***************************************************************************************************"
  sys.exit()
ehost=sys.argv[1]
euser=sys.argv[2]
epassword=sys.argv[3]
vmname=str(sys.argv[4])
ds=sys.argv[5]
diskname=sys.argv[6]
size=sys.argv[7]
print ds
print sys.argv
remote=myssh(ehost,euser,epassword)
print remote
try:
  print "test",vmname
  cmd="vim-cmd vmsvc/getallvms 2>/dev/null | awk '/"+vmname+"/{print $1}'"
  out,err,retval=remote(cmd)
  print out
  print retval
  if retval!=0:
     print "ERROR : VMID not found for the given VM NAME",str(err)
     logging.error("VMID not found for the given VM NAME"+str(err))
     sys.exit()
  else:
     print "INFO : VMID found for the given VM NAME",str(out[0])
     logging.info("VMID found for the given VM NAME"+str(out[0]))
  print retval
  vmid=out[0]
  cmd="vim-cmd vmsvc/get.datastores "+out[0]+" 2>/dev/null | grep name|awk '{print $2}'"
  out,err, retval=remote(cmd)
  print retval
  """
  if len(err)!=0 or len(out)==0:
     print "ERROR: Datastore is not found for the given VMName"+err
     logging.error("Datastore is not found for the given VM NAME"+err)
     sys.exit()
  else:
     print "INFO: Datastore is found for the given VMName",str(out[0])
     logging.info("Datastore is found for the given VM NAME"+str(out[0]))
  """
  #ds=" ".join(out[0].split())
  #ds="5_TB_Vol13_DevOps"
  NEWVMDK="/vmfs/volumes/"+str(ds)+"/"+vmname+"/"+vmname+diskname+".vmdk"

  cmd="ls -l "+NEWVMDK
  print cmd
  out, err, retval=remote(cmd)
  print retval
  if len(out)!=0:
     print "disk already present and checking wheather disk is associated with current VM"
     logging.info("disk already present and checking wheather disk is associated with current VM")
     cmd="vim-cmd vmsvc/device.getdevices "+str(vmid).strip()+" |grep "+vmname+"disk3"
     out,err, retval=remote(cmd)
     if len(out)!=0:
        print "Disk is associated with VM Name "+vmname+" diskanme is "+ str(out[0])
        logging.info("Disk is associated with VM Name "+vmname+" diskanme is "+ str(out[0]))
     sys.exit()

  cmd="ls -l /vmfs/volumes/"+str(ds)+"/"+vmname
  out,err, retval=remote(cmd)
  if len(out)==0:
     print "VM dir doesn't  exists continue with creation of VM dir"
     cmd="mkdir /vmfs/volumes/"+str(ds)+"/"+vmname
     out, err, retval=remote(cmd)
  else:
     print "VM dir exists continue with creation of disk"

  cmd="vmkfstools -c "+size+"G -a isilogic "+NEWVMDK
  out,err, retval=remote(cmd)
  if len(err)!=0:
     print "ERROR: Creation of disk failed",str(err)
     logging.error("ERROR: Creation of disk failed"+str(err))
     sys.exit()
  else:
     print "INFO: Disk creation successfull",str(out)
     logging.error("Disk creation successfull"+str(out))

  cmd="vim-cmd vmsvc/device.getdevices "+str(vmid).strip()+" |grep fileName"
  out,err, retval=remote(cmd)

  if len(err)!=0:
     print "error",err
     sys.exit()

  cmd="vim-cmd vmsvc/device.diskaddexisting "+str(vmid).strip()+" "+NEWVMDK+" 0 "+str(len(out))
  print cmd
  out,err, retval=remote(cmd)
  logging.info(out)
  logging.error(err)
  if len(err)!=0:
     print "ERROR: adding disk to vm is failed",err
     logging.error("adding disk to vm is failed"+err)
     sys.exit()
  else:
     print "INFO: disk added successfully to VM"

except Exception as e:
   print "error", e

