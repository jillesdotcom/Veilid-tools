#!/bin/bash

if [ "$EUID" -ne 0 ];then
  echo "Please run using sudo"
  exit
fi

public_ip={{ PUBLIC IP ADDRESS HERE use https://www.google.com/search?q=what+is+my+ip }}
public_port={{ FIRST PUBLIC PORT NR HERE eg 5150 }}
private_ip={{ FIRST LOCAL SERVER IP ADDRESS HERE eg 192.168.0.100 }}
private_port=5150
nr_of_servers={{ NUMBER OF LOCAL SERVERS HERE eg 5 }}
RED=$(echo -en '\e[1;6;31m')
GREEN=$(echo -en '\e[1;32m')
NORMAL=$(echo -en '\e[0m')

id=1
while [ $id -le ${nr_of_servers} ]; do
  echo Local server $id
  echo - ${public_ip}:${public_port}
  nmap ${public_ip} -sT -sU -p ${public_port} | grep -E "^${public_port}" | sed -e "s/open.*/${GREEN}open${NORMAL}/g" -e "s/closed.*/${RED}closed${NORMAL}/g" -e "s/^/  /g"
  echo - ${private_ip}:${private_port}
  nmap ${private_ip} -sn -T5 | grep "1 host up" > /dev/null
  if [ $? -eq 1 ];then
    echo "  ${RED}host down${NORMAL}"
  else
    nmap ${private_ip} -sT -sU -p ${private_port} | grep -E "^${private_port}" | sed -e "s/open.*/${GREEN}open${NORMAL}/g" -e "s/closed.*/${RED}closed${NORMAL}/g" -e "s/^/  /g"
  fi
  echo
  id=$(($id+1))
  last_octet=$(echo $private_ip | sed -e "s/.*\.\([0-9]*\)$/\1/g")
  private_ip=$(echo $private_ip | sed -e "s/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)/\1.\2.\3.$(($last_octet+1))/g")
  public_port=$(($public_port+1))
done
