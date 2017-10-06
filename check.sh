#!/bin/bash
. ./dnsbl.config

>report.txt
for ipAddress in "${ipAddresses[@]}"
do
echo "Reversing"
##### Reversing IP address, for example IP 192.168.1.1 reverse is 1.1.168.192
IPADD1=$(echo $ipAddress | cut -d"." -f1)
IPADD2=$(echo $ipAddress | cut -d"." -f2)
IPADD3=$(echo $ipAddress | cut -d"." -f3)
IPADD4=$(echo $ipAddress | cut -d"." -f4)
reversedIP="${IPADD4}.${IPADD3}.${IPADD2}.${IPADD1}"
echo "IP $ipAddress reversed to  $reversedIP"
##### Loop in DNSBL servers
for DNSBLS in "${dnsblList[@]}"
do
##### When dig reverseIP.DNSBL-Server if output contains 127.0.0.1 that IP is blocked in that DNSBL
dig $reversedIP.$DNSBLS | grep "127.0.0"
##### If $? is not equal to 0, this IP not in black list
if [ "$?" != "0" ];then
echo "$ipAddress is not listed on $DNSBLS"
##### If $? is equal to other numbers IP is in black list
else
echo "$ipAddress is listed on $DNSBLS" >> "$logFolder/$logFiles"
fi
done # end of dnsbls loop
if [ "$emailEnable" == "YES"]
then
for emailAddress in "${emailTo[@]}"
do
  echo "Our IP Listed !!!!!!!!!!!!!!" | mail -s "ATTENTION" -a report.txt "YOUR EMAIL ADDRESS"
done # end of email address loops
fi # end of email enable if
if ["$telegramEnable" == "YES"]
then
messageToSend="Your mail server with IP $ipAddress is blocked"
for chatId in "${chatIDs}"
do
curl -X POST "https://api.telegram.org/bot$telegramToken/sendMessage" -d "chat_id=$chatId&text=$messageToSend"
done
fi # end of telegram enable if section
done # end of ip address loop
