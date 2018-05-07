#!/bin/bash

cd $(dirname $0)

if [ ! -f address.txt ];then
echo -e "\n file address.txt not exists! \n"
exit
fi

SMI=nvidia-smi

ADDR=$(cat address.txt | head -1 )

DRV=$( $SMI -h |grep Interface | awk -Fv '{print $2}' | cut -d. -f1 )
CARDS=$( $SMI -L | wc -l )

WK=$( /sbin/ifconfig  eth0|grep "inet addr"|awk '{print $2}'|awk -F. '{print $3"x"$4}' )

if [ $DRV -lt 387 ];then
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:cuda8
else
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:cuda9
fi

echo "Driver = $DRV , CARD COUNT=$CARDS , WK=${WK}"

PID=$( pidof miner )
if  [ "$PID" != "" ];then
kill -9 $PID
sleep 1
fi

cd btm-miner
./miner -user ${ADDR}.${WK} $@ 2>&1 >> /var/tmp/miner.log &

touch /var/tmp/miner.log

SS=$( screen -ls|grep minerlog|wc -l )
if [ $SS -ge 1 ];then
screen -q -S minerlog -X quit
fi

screen -dmS minerlog tail -f /var/tmp/miner.log 

