#!/bin/bash
. ./dnsbl.config

##### Create log folder if it does not exsits
[ -d $logFolder ] || mkdir $logFolder

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
continue
##### If $? is not equal to 0, this IP not in black list (Is black listed)
if [ "$?" != "0" ];then
echo "$ipAddress is not listed on $DNSBLS"
##### If $? is equal to other numbers IP is in black list
else
##### Logging server blocked
echo "$ipAddress is listed on $DNSBLS" >> "$logFolder/$logFiles"
##### Check is email notification enable, If enabled send email
messageToSend="Your mail server with IP $ipAddress is blocked in $DNSBLS"

if [ "$emailEnable" == "YES"]
then
for emailAddress in "${emailTo[@]}"
do

echo $messageToSend | mail -v -s "DNSBL Alert" $emailAddress -aFrom:$emailFrom -S smtp=$SMTPServerIP -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user=$mailUserName -S smtp-auth-password=$mailPassword -S ssl-verify=ignore
done # end of email address loops
fi # end of email enable if
##### Check is Telegram notification enable, If enabled send message to telegram
if ["$telegramEnable" == "YES"]
then
for chatId in "${chatIDs}"
do
curl -X POST "https://api.telegram.org/bot$telegramToken/sendMessage" -d "chat_id=$chatId&text=$messageToSend"
done
fi # end of telegram enable if section

fi # end of is blacklisted if
done # end of dnsbls loop

done # end of ip address loop
