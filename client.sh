#!/bin/bash

cat /dev/null > /var/tmp/out_put.txt

#hostname
HOSTNAME=$(hostname)
host_name='<td>'"$HOSTNAME"'</td>'

#------------------------
dy=`uptime | awk '{print $3}'`
chk=`uptime | awk '{print $4}'`

#Cpu Output
cpu1=`top -n 1 -b | grep "Cpu" | awk '{print $5}' | sed s/,//g | sed s/%id//g`
cpu=${cpu1/.*}
#echo $cpu
if [ "$cpu" -lt 5 ]
then
cpu_idle='<td style=\"background-color:Red\">' $cpu'%</td>'
else
cpu_idle='<td>'"$cpu"'%</td>'
fi


#Uptime check
#-----------------------------------------------------------------------------------------------
#if [ $chk = 'days,' ]
#then
#        let fin_dy=$dy*24;
#else
        fin_dy=`echo $dy | awk -F : '{print $1}'`
#fi

uptime_data=`uptime | awk '{print $3" "$4}' | sed s/,//g`

#if [ $fin_dy -le 24 ]
if [ $chk = 'days,' ]
then
       up_stat=$fin_dy
           tb_up_stat="<td style=\"background-color:Green\"> $uptime_data </td>"
        else
       up_stat=$fin_dy
           tb_up_stat="<td style=\"background-color:Red\"> $uptime_data </td>"
fi

#Swap Memory
#-----------------------------------------------------------------------------------------------
#for i in `sar -S | tail | awk '{print $5}' | grep -v 'swpused' | grep -v '86_64'`
#do
#per=`echo $i | awk -F . '{print $1}'`
#per=${per_tmp/.*}
per_tmp=$(free | grep Swap | awk '{print $3/$2 * 100.0}')
per=${per_tmp/.*}
if [ "$per" -gt 25 ]
then
sw_stat="$per"
tb_sw_st='<td style=\"background-color:Red\">'$sw_stat'%</td>'
else
sw_stat="$per"
tb_sw_st='<td>'"$sw_stat"'%</td>'
fi
#done

#Memory Status
#-----------------------------------------------------------------------------------------------
for i in `sar -r | tail -n 15 | grep -v 'Average' | awk '{print $5}' | grep -v 'swpused' | grep -v '86_64' | grep -v 'memused'`
do
per=`echo $i | awk -F . '{print $1}'`
if [ "$per" -gt 95 ]
then
memory_stat=$i
#tb_memory_st="<td style=\"background-color:Red\"> $memory_stat% </td>"
tb_memory_st="<td>  $memory_stat% </td>"
else
memory_stat=$i
tb_memory_st="<td> $memory_stat% </td>"
fi
done

echo $host_name >> /var/tmp/out_put.txt
echo $tb_up_stat >> /var/tmp/out_put.txt
echo $cpu_idle >> /var/tmp/out_put.txt
echo $tb_sw_st >> /var/tmp/out_put.txt
echo $tb_memory_st >> /var/tmp/out_put.txt

#File system check
#------------------------------------------------------------------------------------------------
df -h | grep % | grep -v Use | awk '{print $(NF-1)":"$NF}' > /var/tmp/test.txt
#df -h | grep % | grep -v Use | awk '{print $NF" is "$(NF-1)}' > /var/tmp/test.txt
cat /dev/null > /var/tmp/fl1.txt
for i in `cat /var/tmp/test.txt | sed s/%//g`; do
cm1=`echo $i| awk -F : '{print $1}'`
cm2=`echo $i| awk -F : '{print $2}'`
if [ "$cm1" -lt 101 -a "$cm1" -gt 89 ]; then
        fs_info=`echo $cm2 is $cm1%`
        echo "$fs_info" >> /var/tmp/fl1.txt
fi
done

fs_info_normal=`echo FS Usage Normal`
fs_info_out=`cat /var/tmp/fl1.txt | paste -s -d,`

if [ -z "$fs_info" ]; then
#echo 'FS Usage Normal' > /var/tmp/fl1.txt
echo '<td>'$fs_info_normal'</td>' >> /var/tmp/out_put.txt
else
echo '<td style="background-color:Red">'$fs_info_out'</td>' >> /var/tmp/out_put.txt

fi

#cat /var/tmp/fl1.txt | head -n 1 > /var/tmp/one.txt
#sed -i '1d' /var/tmp/fl1.txt

#fst_lin_cm1=`cat /var/tmp/one.txt | awk -F : '{print $1}'`
#fst_lin_cm2=`cat /var/tmp/one.txt | awk -F : '{print $2}'`


#echo $host_name >> /var/tmp/out_put.txt
#echo $tb_up_stat >> /var/tmp/out_put.txt
#echo $cpu_idle >> /var/tmp/out_put.txt
#echo $tb_sw_st >> /var/tmp/out_put.txt
#echo $tb_memory_st >> /var/tmp/out_put.txt


#if [ "$fst_lin_cm1" == 'FS Usage Normal' ] ; then
#echo '<td>'$fst_lin_cm1'</td>' >> /var/tmp/out_put.txt
#echo '<td>'$fst_lin_cm2'</td>' >> /var/tmp/out_put.txt
#echo '</tr>' >> /var/tmp/out_put.txt
#else
#echo '<td style="background-color:Red">'$fst_lin_cm1'</td>' >> /var/tmp/out_put.txt
#echo '<td style="background-color:Red">'$fst_lin_cm2'</td>' >> /var/tmp/out_put.txt
#echo '</tr>' >> /var/tmp/out_put.txt
#fi


#for i in `cat /var/tmp/fl1.txt`;do
#scd_lin_cm1=`echo $i | awk -F : '{print $1}'`
#scd_lin_cm2=`echo $i | awk -F : '{print $2}'`
#echo '<td></td><td></td><td></td><td></td><td></td><td style="background-color:Red">'$scd_lin_cm1'</td><td style="background-color:Red">'$scd_lin_cm2'</td></tr>' >> /var/tmp/out_put.txt
#done


#Process Check
#------------------------------------------------------------------------------------------------
cat /dev/null > /var/tmp/proc_out_put.txt

ps -ef | grep ssh | grep -v grep > /var/tmp/test.txt
rtn_code=$?
if [ $rtn_code -ne 0 ]
then
echo 'SSH is Down' >> /var/tmp/proc_out_put.txt
fi

#ps -ef | grep syslog | grep -v grep > /var/tmp/test.txt
#rtn_code=$?
#if [ $rtn_code -ne 0 ]
#then
#echo 'Syslogd is Down' >> /var/tmp/proc_out_put.txt
#fi

ps -ef | grep cron | grep -v grep > /var/tmp/test.txt
rtn_code=$?
if [ $rtn_code -ne 0 ]
then
echo 'CRON is Down' >> /var/tmp/proc_out_put.txt
fi

ps -ef | grep PatrolAgent | grep -v grep > /var/tmp/test.txt
rtn_code=$?
if [ $rtn_code -ne 0 ]
then
echo 'PatrolAgent is Down' >> /var/tmp/proc_out_put.txt
fi

ps -ef | grep java | grep -v grep > /var/tmp/test.txt
rtn_code=$?
if [ $rtn_code -ne 0 ]
then
echo 'JBoss is Down' >> /var/tmp/proc_out_put.txt
fi

ps -ef | grep postfix  | grep -v grep > /var/tmp/test.txt
rtn_code=$?
if [ $rtn_code -ne 0 ]
then
echo 'Postfix is Down' >> /var/tmp/proc_out_put.txt
fi

proc_info=`cat /var/tmp/proc_out_put.txt`
proc_info_out=`cat /var/tmp/proc_out_put.txt | paste -s -d,`
if [ -z "$proc_info" ]; then
echo '<td>'Process Normal'</td>' >> /var/tmp/out_put.txt
else
echo '<td style="background-color:Red">'$proc_info_out'</td>' >> /var/tmp/out_put.txt
fi

