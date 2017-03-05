#!/bin/sh
BLOK=`echo 0`
>report.txt
for IPADD in `cat ip.list`
do
echo "Reversing"
echo $IPADD
IPADD1=$(echo $IPADD | cut -d"." -f1)
IPADD2=$(echo $IPADD | cut -d"." -f2)
IPADD3=$(echo $IPADD | cut -d"." -f3)
IPADD4=$(echo $IPADD | cut -d"." -f4)
REV="${IPADD4}.${IPADD3}.${IPADD2}.${IPADD1}"
echo $REV
for DNSBLS in `cat dnsbl.list`
do
dig $REV.$DNSBLS | grep "127.0.0"
if [ "$?" != "0" ];then
echo "$IPADD is not listed on $DNSBLS"
else
echo "$IPADD is listed on $DNSBLS" >> report.txt && BLOK=`echo 1`
fi
done
done
if [ "$BLOK" == "1" ];then
echo "Our IP Listed !!!!!!!!!!!!!!" | mail -s "ATTENTION" -a report.txt "YOUR EMAIL ADDRESS"
fi
