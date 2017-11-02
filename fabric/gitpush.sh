#!/usr/bin/expect -f
spawn git push origin master
expect "Username" 
send "anto.daniel@gmail.com\r"
expect "Password"
send "1ds01is005\r"
