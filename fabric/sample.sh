#!/bin/bash

for host in `cat hosts`
do
    sshpass -p alcatraz1400 ssh-copy-id -o StrictHostKeyChecking=no -o CheckHostIP=no sysops@$host 
done
