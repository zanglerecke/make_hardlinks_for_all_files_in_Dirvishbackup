#!/bin/bash

nothingtodo=0;
count=1;
MAXRUN=200;
Orig=`date -d "1 day ago" +"%Y%m%d"`;
Copy=`date -d "0 day ago" +"%Y%m%d"`;
VERBOSE=0;
remidinode=true;

if [ $0 == "bash" ]; then 
  shift 
fi;

while [[ $# > 1 ]];
do
key="$1"

case $key in
    -MAXRUN|-maxrun)
    MAXRUN="$2"
    shift # past argument
    echo "maxrun ="$MAXRUN
    ;;
    -orig)
    orig="$@"
    shift # past argument
    ;;
    -linkin)
    shift
    Copy="$@"
#    shift # past argument
    ;;
    -v)
    VERBOSE=1
    ;;
    -removeidentinode)
    remidinode=true
    ;;
    -keepidentinode)
    remidinode=false
    ;;
    -h)
    echo "options are: \n-MAXRUN X | -maxrun X \n-keep FOLDERNAME \n -linkin FOLDERNAME \n -removeidentinode (default)| -keepidentinode"        # unknown option
    exit
;;
esac
shift # past argument or value
done

if [ -f only_first_occurence.log ]; then
  echo " NOT THE FIRST TIME THIS SEARCH IS DONE"
else
  echo "COMMAND: rdfind -removeidentinode "$remidinode" -makeresultsfile true -outputname ./rdfind.log -makehardlinks true "$Orig"/   "$Copy"/ "
  rdfind -removeidentinode $remidinode -makeresultsfile true -outputname ./rdfind.log -makehardlinks true $Orig/   $Copy/  | tee out
  cat rdfind.log | grep DUPTYPE_FIRST_OCCURRENCE | cut -d " " -f 8 > only_first_occurence.log 
  cat ./rdfind.log >> ./rdfind_all.log
fi
nothingtodo=$( cat ./out | grep -ic "Making 0 links" )

while [ `cat ./out | grep -ic "Making 0 links"`  -eq 0 ]  || [ $count -gt $MAXRUN ];
 do
 for i in `cat only_first_occurence.log`; do
  if [ -e $i ]; then echo $i >> Oonly_first_occurence.log; fi
 done
 rm only_first_occurence.log && mv Oonly_first_occurence.log only_first_occurence.log
  rdfind -removeidentinode $remidinode -makeresultsfile true -outputname ./rdfind.log -makehardlinks true `head -n 20 only_first_occurence.log` $Orig/   $Copy/ | tee out
  count=`expr $count + 1`
  cat ./rdfind.log >> ./rdfind_all.log
  echo "rdfind has completed the "$count" run. "$((MAXRUN-count))" to go..."
  for i in `head -n 20 only_first_occurence.log | cut -d " " -f 8`; do
    if [ -e $i ]; then ls -l  $i 2> /dev/null | awk '{ print $2 "\t" $9}' > duplikate.txt; fi
  done
 done
echo "rdfind took "$count" runs to complete!"
if [ $VERBOSE -eq 0 ]; then
rm out
rm only_first_occurence.log
rm rdfind.log
rm rdfind_all.log
fi
