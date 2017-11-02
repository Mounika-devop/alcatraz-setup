
import paramiko
import atexit
import logging
import sys
import subprocess
import time
import argparse
import os
from subprocess import Popen,PIPE,STDOUT
import datetime
active_ips=[]
inactive_ips=[]
sys_arr=[]
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

def ping(hostname):
       result=subprocess.Popen(["ping", "-c", "1", "-n", "-W", "2", hostname]).wait()
       if result:
               inactive_ips.append(hostname)
       else:
               active_ips.append(hostname)
#arr=['fab-emea01-haz-h1','fab-emea01-haz-h2','fab-emea01-haz-h3','fab-emea01-stm-h1','fab-emea01-karafui-h1-1']
karaf=['fab-emea01-karafui-h1-1','fab-emea01-karafui-h1-2','fab-emea01-karafui-h2-1','fab-emea01-karafui-h2-2','fab-emea01-karafdig-h1-1','fab-emea01-karafdig-h1-2','fab-emea01-karafdig-h2-1','fab-emea01-karafdig-h2-2']
haz=['fab-emea01-haz-h1','fab-emea01-haz-h2','fab-emea01-haz-h3']
stm=['fab-emea01-stm-h1','fab-emea01-stm-h2','fab-emea01-stm-h3']
nfs=['fab-emea01-nfs-h2','fab-emea01-nfs-h3']
arr=karaf+haz+stm+nfs
print arr
#for i in arr:
#    ping(i)

#print inactive_ips,"IN"
#print active_ips,"ACT"

def System_info(hostname):
    res_arr=[]
    res_arr.append(hostname)
    system={}
    system["Mount_check"] = "cat /etc/fstab|egrep 'data|log|nfs-path' && df -h |egrep 'data|log|nfs-path'"
    system["mongo_cert"] = "keytool -list -keystore /usr/lib/jvm/java-7-oracle/jre/lib/security/cacerts  -storepass changeit | grep mongodb"
    system["nfs_perm"] = "ls -l /nfs-path"
    system["ssl_check"] = "ls -l /etc/ssl/ |egrep 'mongo|truststore|node'"
    system["user_check"] = "cat /etc/passwd |grep apps"
    system["mongo_check"] = "echo show dbs|mongo --port 23757 --ssl --sslAllowInvalidCertificates -u admin -p 'alcatraz1400' --authenticationDatabase admin"
    system["md5sum_twn"]='md5sum /apps/config/keystore/*'
    remote=myssh(hostname,'sysops','alcatraz1400')
    for key in system:
        try:
            out,err,rval=remote(system[key])
            res_arr.append(out)
        except Exception, e:
            res_arr.append(e)

    return res_arr

for i in arr:
    sys_arr.append(System_info(i))
filename=datetime.datetime.now().strftime('%s')+'.html'
f=open(filename,'w')
f.write('<h1>Compute Nodes Comman check</h1> ')
f.write('<table border = "1"><tr><td width="20px">HOSTNAME</td><td>SSL INFO</td><td>NFS Share Permission</td><td>Mount Points</td><td>Townsend MD5sum</td><td>Mongo Connectivity</td><td>Mongo Certificate</td><td>Appsuser Info</td></tr>')
#f.write('<table border = "1">')
for i in sys_arr:
     f.write('<tr>')
     for x in i:
         if type(x) is list:
             f.write('<td>')
             for y in x:
                #print y
                f.write('<h5>'+y+'</h5>')
             f.write('</td>')
         else:
             #print "value",x
             f.write('<td><h5>'+str(x)+'</h5></td>')
     f.write('</tr>')
f.write('</table>')
 

def Karaf_info(hostname):
    res_karaf=[]
    res_karaf.append(hostname)
    system={}
    system["karaf_xmx"] = "cat /apps/karaf/bin/setenv |grep JAVA_MAX_MEM | tail -1"
    system["mongo_cert"] = "keytool -list -keystore /usr/lib/jvm/java-7-oracle/jre/lib/security/cacerts  -storepass changeit | grep egw"
    system["karaf_log"] = "cat /apps/karaf/etc/org.ops4j.pax.logging.cfg |grep  log4j.appender.out.maxFileSize"
    system["karaf_secfile"] = "ls -l /apps/karaf/etc/security/.keystore"
    system["kafka_maxfile"] = "cat /apps/karaf/etc/actiance/apc-system/apc-config/kafka.properties |grep kafka.max.message.size"
    system["karaf_ulimt"] = "cat /proc/`ps -ef |grep karaf |awk '{print $2}' |head -1`/limits |grep open"
    remote=myssh(hostname,'sysops','alcatraz1400')
    for key in system:
        try:
            out,err,rval=remote(system[key])
            res_karaf.append(out)
        except Exception, e:
            res_karaf.append(e)

    return res_karaf
karaf_arr=[]
for i in karaf:
     karaf_arr.append(Karaf_info(i))

f.write('<h1>Karaf Nodes Comman check</h1> ')
f.write('<table border = "1"><tr><td width="20px">HOSTNAME</td><td>Log File Size</td><td>Ulimit</td><td>Keystore File</td><td>EGW Cert</td><td>XMX Value</td><td>Kafka Message Size</td></tr>')
#f.write('<table border = "1">')
for k in karaf_arr:
     f.write('<tr>')
     for x in k:
         if type(x) is list:
             f.write('<td>')
             for y in x:
                #print z
                f.write('<h5>'+y+'</h5>')
             f.write('</td>')
         else:
             #print "value",x
             f.write('<td><h5>'+str(x)+'</h5></td>')
     f.write('</tr>')
f.write('</table>')

def Haz_info(hostname):
    res_haz=[]
    res_haz.append(hostname)
    system={}
    system["haz_ulimt"] = "cat /proc/$(ps -ef |grep haz |grep -v grep | grep appsuser |awk '{print $2}')/limits |grep open"
    system["haz_log"] = "cat /apps/alcatraz_cache-1.0/conf/cluster.xml |grep maxFile |cut -d'>' -f2|cut -d'<' -f1 |head -1"
    system["haz_xmx"] = "cat /apps/alcatraz_cache-1.0/bin/start.sh |egrep -io \"xmx[0-9]+(m|g)\""
    system["haz_maxfile"] = "cat /apps/alcatraz_cache-1.0/conf/kafka.properties |grep kafka.max.message.size"
    remote=myssh(hostname,'sysops','alcatraz1400')
    for key in system:
        try:
            out,err,rval=remote(system[key])
            res_haz.append(out)
        except Exception, e:
            res_haz.append(e)

    return res_haz
haz_arr=[]
for i in haz:
     haz_arr.append(Haz_info(i))
f.write('<h1>Hazelcast Nodes Comman check</h1> ')
f.write('<table border = "1"><tr><td width="20px">HOSTNAME</td><td>XMX Value</td><td>Log File Size</td><td>Ulimit</td><td>Kafka Message Size</td></tr>')
#f.write('<table border = "1">')
for k in haz_arr:
     f.write('<tr>')
     for x in k:
         if type(x) is list:
             f.write('<td>')
             for y in x:
                #print y
                f.write('<h5>'+y+'</h5>')
             f.write('</td>')
         else:
             #print "value",x
             f.write('<td><h5>'+str(x)+'</h5></td>')
     f.write('</tr>')

f.close()
