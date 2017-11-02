#!/bin/bash 

user='sysops'
passwd='alcatraz1400'
ssh_params='-o StrictHostKeyChecking=no -o CheckHostIP=no'

echo $passwd | sudo -S apt-get install sshpass -y >> stdout.txt 2>> stderr.txt 
if [ $? -ne 0 ]; then
    echo -e "ERROR: sshpass package did not install\n"
    exit 1
else
    echo -e "INFO: sshpass package installed"
fi

cnt=0
for host in `egrep fab /etc/hosts | awk '{print $2}'`
do
    arr[$cnt]="$host"
    let cnt=$cnt+1
done

#echo ${arr[@]}

for host in ${arr[@]}
do
    sshpass -p ${passwd} ssh-copy-id ${ssh_params} ${user}@${host}
done
