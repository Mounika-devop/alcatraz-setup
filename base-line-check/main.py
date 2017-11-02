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
fileread = open("hosts.txt")
f = fileread.read()
arr=f.split('\n')
#for host in f:
   # print host
    #arr.append(host)

def ping(hostname):
       result=subprocess.Popen(["ping", "-c", "1", "-n", "-W", "2", hostname]).wait()
       if result:
               #print hostname, "inactive"
               inactive_ips.append(hostname)
       else:
               #print hostname, "active"
               active_ips.append(hostname)
#arr=['fab-storlab-haz-h1','fab-storlab-stm-h1','fab-storlab-puppet-h4']
for i in arr:
    ping(i)

print inactive_ips,"IN"
print active_ips,"ACT"

def System_info(hostname):
    res_arr=[]
    res_arr.append(hostname)
    system={}
    system["os_ver_cmd"] = "lsb_release -d | cut -d':' -f2|sed 's/\t//g'"
    system["mem_cmd"] = "cat /proc/meminfo  | grep MemTotal | awk '{print $2}' | xargs -I{} echo {}/1000000 | bc"
    system["ulimit_cmd"] = "ulimit -n"
    system["java_ver_cmd"] = "dpkg -l | grep oracle-java7-installer | awk '{print $2}'"
    system["user_chk"] = "grep appsuser /etc/passwd | awk -F: '{print $1}'"
    system["dns_chk"] = "host "+hostname
    #print system

    remote=myssh(hostname,'sysops','alcatraz1400')
    for key in system:
        try:
            out,err,rval=remote(system[key])
            print out
            if len(out)==0:
                res_arr.append(out)
            else:
                res_arr.append(out[0].strip())
        except Exception, e:      
            res_arr.append(e)


    #print out6[0]
    sys_arr.append(res_arr)

for i in active_ips:
    System_info(i)

print sys_arr


filename=datetime.datetime.now().strftime('%Y-%m-%d_%H_%M_%S')+'.html'
f=open(filename,'w')
f.write("<html><body>")
f.write('<table border = "1" cellpadding = "1" cellspacing = "0">\n<tr><td>IP/HOSTNAME</td><td>ULIMIT</td><td>JAVA_VERSION</td><td>DNS</td><td>RAM</td><td>OS_VERSION</td><td>USER</td></tr>')
for data in sys_arr:
        f.write('<tr>')
        for d in data:
                f.write("<td>")
                f.write(str(d).strip())
                f.write("</td>")
        f.write('</tr>')
f.write('</table>')
f.write('<br>')
f.write('<h3>Non reachable servers</h3>')
f.write('\n'.join(inactive_ips))
