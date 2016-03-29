#!/bin/bash

nothingtodo=0
count=1;
date
#time (...)
whoami
pwd
rdfind -makeresultsfile true -outputname ./rdfind.log -makehardlinks true ./
date

nothingtodo=$( cat ./rdfind.log | grep -ic "Making 0 links" )

while [  $nothingtodo -eq 0 ];
 do
  date
  cat ./rdfind.log >> ./rdfind_all.log
  rdfind -makeresultsfile true -outputname ./rdfind.log -makehardlinks true ./
  nothingtodo=$( cat ./rdfind.log | grep -ic "Making 0 links" )
  count=`expr $count + 1`
  echo "rdfind has completed the "$count" run"
  cut -d " " -f 8 rdfind.log > rdfind_onlynames.log
 done
date
cat ./rdfind.log >> ./rdfind_all.log
echo "rdfind took "$count" runs to complete!"

