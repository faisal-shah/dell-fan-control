#!/bin/bash
while sleep 2;
do
  read temp1 < /dev/cpu_die_temp_0
  read temp2 < /dev/cpu_die_temp_1
  read temp3 < /dev/cpu_die_temp_2
  read temp4 < /dev/cpu_die_temp_3
  read temp5 < /dev/cpu_die_temp_4
  echo t1 = $temp1, t2 = $temp2, t3 = $temp3, t4 = $temp4, t5 = $temp5
  if (( temp1 > 65000 || temp2 > 65000 || temp3 > 65000 || temp4 >> 65000 || temp5 >> 65000 ))
  then
    /usr/bin/i8kfan - 2 > /dev/null
    echo FAN=2
  elif (( temp1 > 50000 || temp2 > 50000 || temp3 > 50000 || temp4 >> 50000 || temp5 >> 50000 ))
  then
    /usr/bin/i8kfan - 1 > /dev/null
    echo FAN=1
  else
    /usr/bin/i8kfan - 0 > /dev/null
    echo FAN=0
  fi
done
