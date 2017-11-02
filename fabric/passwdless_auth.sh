#!/usr/bin/expect -f
spawn ssh-keygen -t rsa
expect ".ssh/id_rsa): "
send "\r"
expect "passphrase): "
send "\r"
expect "passphrase"
send "\r"
