
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
import ConfigParser
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

def cmd_execute(hostname, system):
    full_res=[]
    print hostname, system
    for host in hostname:
        res_arr=[host]
        remote=myssh(host,'sysops','alcatraz1400')
        for key in system:
            try:
                out,err,rval=remote(system[key])
                res_arr.append(out)
                print out,err
            except Exception, e:
                res_arr.append(e)
        full_res.append(res_arr)
    return full_res

def makeTable(data_dict,sys_arr,f):
    f.write('<table border = "1"><tr><td>Hostname</td>')
    for key in data_dict.keys():
        f.write("<td>"+key+"</td>")
    f.write("</tr>")

    for i in sys_arr:
        f.write('<tr>')
        for x in i:
            if type(x) is list:
                f.write('<td>')
                for y in x:
                    f.write('<h5>'+y+'</h5>')
                f.write('</td>')
            else:
                f.write('<td><h5>'+str(x)+'</h5></td>')
        f.write('</tr>')
    f.write('</table>')
Config = ConfigParser.ConfigParser()
Config.read('command.properties')
server_dict={}
for i in Config.options('server'):
    print i
    server_dict.update({i:Config.get("server",i).split(',')})
print server_dict['stm']

command_dict={}
for i in Config.sections():
    if i=='server':
        None
    else:
        command_dict.update({i:Config.options(i)})
print command_dict

haz_dict={}
common_dict={}
karaf_dict={}
nfs_dict={}
stm_dict={}
for i in Config.options("common_commands"):
    common_dict.update({i:Config.get("common_commands",i)})
for i in Config.options("haz_commands"):
    haz_dict.update({i:Config.get("haz_commands",i)})
for i in Config.options("karaf_commands"):
    karaf_dict.update({i:Config.get("karaf_commands",i)})
for i in Config.options("stm_commands"):
    stm_dict.update({i:Config.get("stm_commands",i)})
haz_arr=cmd_execute(server_dict["haz"],haz_dict)
karaf_arr=cmd_execute(server_dict["karaf"],karaf_dict)
stm_arr=cmd_execute(server_dict["stm"],stm_dict)
common_arr=cmd_execute(server_dict["haz"]+server_dict["karaf"]+server_dict["stm"],common_dict)
filename=datetime.datetime.now().strftime('%s')+'.html'
f=open(filename,'w')
f.write('<h1>Compute Nodes Comman check</h1> ')
makeTable(common_dict,common_arr,f)
f.write('<h1>Karaf Nodes Comman check</h1> ')
makeTable(karaf_dict,karaf_arr,f)
f.write('<h1>Hazelcast Nodes Comman check</h1> ')
makeTable(haz_dict,haz_arr,f)
f.write('<h1>Storm Nodes Comman check</h1> ')
makeTable(stm_dict,stm_arr,f)
