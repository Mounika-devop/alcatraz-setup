#!/bin/bash

./install_ssh.sh
env=$(awk -F- '{print $2}' /etc/hosts)
for host in `egrep $env /etc/hosts | awk '{print $2}'`
do
    scp -o StrictHostKeyChecking=no -o CheckHostIP=no install_ssh.sh $host:/tmp 
    ssh -o StrictHostKeyChecking=no -o CheckHostIP=no $host /tmp/install_ssh.sh
done
